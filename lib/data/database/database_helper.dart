import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/dictionary_item.dart';
import '../models/exam_model.dart';

/// Embedded Local Storage Engine using SQLite (via sqflite).
/// Operates 100% offline with zero cloud dependency.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'dictionary.db';
  static const int _dbVersion = 2;

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initializes the SQLite database by copying from asset bundle on first run.
  /// If asset loading fails or is empty, gracefully creates schema and seeds data.
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, _dbName);

    // Check if the database already exists in internal storage
    final exists = await databaseExists(path);

    if (!exists) {
      if (kDebugMode) {
        print('[DatabaseHelper] Database not found at $path. Copying from assets...');
      }

      // Ensure directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (e) {
        if (kDebugMode) print('[DatabaseHelper] Error creating directory: $e');
      }

      bool copiedFromAsset = false;
      try {
        // Load database binary from APK assets
        final ByteData data = await rootBundle.load('assets/db/$_dbName');
        final List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        await File(path).writeAsBytes(bytes, flush: true);
        copiedFromAsset = true;
        if (kDebugMode) {
          print('[DatabaseHelper] Copied ${bytes.length} bytes from assets/db/$_dbName successfully.');
        }
      } catch (e) {
        if (kDebugMode) {
          print('[DatabaseHelper] Warning: Failed to copy asset binary: $e. Falling back to SQL initialization.');
        }
      }

      if (!copiedFromAsset) {
        // Fallback: Open and create schema with seed data
        return await openDatabase(
          path,
          version: _dbVersion,
          onCreate: (db, version) async {
            await _createSchemaAndSeed(db);
          },
          onUpgrade: (db, oldV, newV) async {
            await _createSchemaAndSeed(db);
          },
        );
      }
    }

    // Open existing or newly copied database
    final db = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await _createSchemaAndSeed(db);
      },
      onUpgrade: (db, oldV, newV) async {
        await _createSchemaAndSeed(db);
      },
    );

    // Ensure user_quiz_history table exists if copied from older assets
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_quiz_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        package_id INTEGER NOT NULL,
        score INTEGER NOT NULL,
        total_questions INTEGER NOT NULL,
        percentage REAL NOT NULL,
        completed_at TEXT NOT NULL
      );
    ''');

    // Self-healing / Upgrade check: ensure 'category' column exists and enriched data is seeded
    try {
      final info = await db.rawQuery('PRAGMA table_info(dictionary)');
      final hasCategory = info.any((col) => col['name'] == 'category');
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM dictionary')) ?? 0;

      if (!hasCategory || count < 150) {
        if (kDebugMode) print('[DatabaseHelper] Upgrading dictionary to V2 schema with 230+ entries...');
        await _createSchemaAndSeed(db);
      }
    } catch (e) {
      if (kDebugMode) print('[DatabaseHelper] Self-healing migration error: $e');
    }

    return db;
  }

  /// Executes DDL schema and initial seed data if DB needs to be built from script.
  Future<void> _createSchemaAndSeed(Database db) async {
    try {
      final sqlScript = await rootBundle.loadString('assets/sql/init.sql');
      final statements = sqlScript.split(';\n');
      for (final stmt in statements) {
        final trimmed = stmt.trim();
        if (trimmed.isNotEmpty) {
          await db.execute(trimmed);
        }
      }
      if (kDebugMode) print('[DatabaseHelper] Schema and seed data executed successfully.');
    } catch (e) {
      if (kDebugMode) print('[DatabaseHelper] Fallback schema execution error: $e');
    }
  }

  // --------------------------------------------------------------------------
  // DICTIONARY REPOSITORY METHODS
  // --------------------------------------------------------------------------

  /// Performs an instant, debounced search across Korean, Indonesian, and English.
  /// Supports optional POS and Category (Aktivitas) filters.
  Future<List<DictionaryItem>> searchDictionary(
    String query, {
    String? posFilter,
    String? categoryFilter,
    int limit = 300,
  }) async {
    final db = await database;
    final cleanQuery = query.trim();

    List<String> conditions = [];
    List<dynamic> whereArgs = [];

    if (cleanQuery.isNotEmpty) {
      conditions.add('(korean_hangul LIKE ? OR korean_roman LIKE ? OR indonesian LIKE ? OR english LIKE ?)');
      final pattern = '%$cleanQuery%';
      whereArgs.addAll([pattern, pattern, pattern, pattern]);
    }

    if (posFilter != null && posFilter.isNotEmpty && posFilter != 'Semua' && posFilter != 'All') {
      conditions.add('pos = ?');
      whereArgs.add(posFilter);
    }

    if (categoryFilter != null &&
        categoryFilter.isNotEmpty &&
        categoryFilter != 'Semua' &&
        categoryFilter != 'Semua Kegiatan' &&
        categoryFilter != 'All') {
      conditions.add('category = ?');
      whereArgs.add(categoryFilter);
    }

    final whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'dictionary',
      where: whereClause,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
      orderBy: 'korean_hangul ASC',
      limit: limit,
    );

    return List.generate(maps.length, (i) => DictionaryItem.fromMap(maps[i]));
  }

  /// Retrieves all unique Parts of Speech (POS) available in the dictionary.
  Future<List<String>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT DISTINCT pos FROM dictionary ORDER BY pos ASC',
    );
    return results.map((row) => row['pos'] as String).toList();
  }

  /// Retrieves all unique Activity Categories available in the dictionary.
  Future<List<String>> getAllActivityCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.rawQuery(
      'SELECT DISTINCT category FROM dictionary WHERE category IS NOT NULL AND category != "" ORDER BY category ASC',
    );
    return results.map((row) => row['category'] as String).toList();
  }

  // --------------------------------------------------------------------------
  // EXAM & QUIZ REPOSITORY METHODS
  // --------------------------------------------------------------------------

  /// Retrieves all Exam Packages along with user's best recorded score.
  Future<List<ExamPackage>> getExamPackages() async {
    final db = await database;
    final List<Map<String, dynamic>> packagesMap = await db.query(
      'exam_packages',
      orderBy: 'level ASC',
    );

    final List<ExamPackage> list = [];
    for (final map in packagesMap) {
      final packageId = map['id'] as int;

      // Query dynamic question count to always reflect true question count in DB
      final countRes = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM exam_questions WHERE package_id = ?',
        [packageId],
      )) ?? (map['total_questions'] as int? ?? 0);

      // Query best score from user_quiz_history
      final history = await db.rawQuery('''
        SELECT MAX(score) as best_score, MAX(percentage) as best_pct 
        FROM user_quiz_history 
        WHERE package_id = ?
      ''', [packageId]);

      int? bestScore;
      double? bestPct;

      if (history.isNotEmpty && history.first['best_score'] != null) {
        bestScore = history.first['best_score'] as int?;
        final numPct = history.first['best_pct'] as num?;
        bestPct = numPct?.toDouble();
      }

      list.add(ExamPackage(
        id: packageId,
        title: map['title'] as String? ?? '',
        level: map['level'] as int? ?? 1,
        totalQuestions: countRes,
        bestScore: bestScore,
        bestPercentage: bestPct,
      ));
    }

    return list;
  }

  /// Retrieves all questions belonging to a specific package.
  Future<List<ExamQuestion>> getQuestionsForPackage(int packageId) async {
    final db = await database;
    final List<Map<String, dynamic>> questionsMap = await db.query(
      'exam_questions',
      where: 'package_id = ?',
      whereArgs: [packageId],
      orderBy: 'id ASC',
    );

    return List.generate(questionsMap.length, (i) => ExamQuestion.fromMap(questionsMap[i]));
  }

  /// Records the completed quiz result to local offline storage.
  Future<int> saveQuizResult(UserQuizHistory history) async {
    final db = await database;
    return await db.insert('user_quiz_history', history.toMap());
  }

  /// Closes database connection.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
