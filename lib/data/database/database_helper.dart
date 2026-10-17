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
  static const int _dbVersion = 1;

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
    } catch (e) {
      if (kDebugMode) print('[DatabaseHelper] Fallback schema execution error: $e');
    }
  }

  // --------------------------------------------------------------------------
  // DICTIONARY REPOSITORY METHODS
  // --------------------------------------------------------------------------

  /// Performs an instant, debounced search across Korean, Indonesian, and English.
  Future<List<DictionaryItem>> searchDictionary(
    String query, {
    String? posFilter,
    int limit = 100,
  }) async {
    final db = await database;
    final cleanQuery = query.trim();

    String whereClause = '';
    List<dynamic> whereArgs = [];

    final hasQuery = cleanQuery.isNotEmpty;
    final hasPos = posFilter != null && posFilter.isNotEmpty && posFilter != 'Semua' && posFilter != 'All';

    if (hasQuery && hasPos) {
      whereClause = '(korean_hangul LIKE ? OR korean_roman LIKE ? OR indonesian LIKE ? OR english LIKE ?) AND pos = ?';
      final pattern = '%$cleanQuery%';
      whereArgs = [pattern, pattern, pattern, pattern, posFilter];
    } else if (hasQuery) {
      whereClause = 'korean_hangul LIKE ? OR korean_roman LIKE ? OR indonesian LIKE ? OR english LIKE ?';
      final pattern = '%$cleanQuery%';
      whereArgs = [pattern, pattern, pattern, pattern];
    } else if (hasPos) {
      whereClause = 'pos = ?';
      whereArgs = [posFilter];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'dictionary',
      where: whereClause.isNotEmpty ? whereClause : null,
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

      list.add(ExamPackage.fromMap(map, bestScore: bestScore, bestPercentage: bestPct));
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
