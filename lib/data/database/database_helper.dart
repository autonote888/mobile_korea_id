import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/dictionary_item.dart';
import '../models/exam_model.dart';
import '../models/memorized_item.dart';
import 'memorized_seed_data.dart';

/// Embedded Local Storage Engine using SQLite (via sqflite).
/// Operates 100% offline with zero cloud dependency.
class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static const String _dbName = 'dictionary.db';
  static const int _dbVersion = 3;

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

    // Ensure exam_packages table exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exam_packages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        level INTEGER NOT NULL,
        total_questions INTEGER NOT NULL
      );
    ''');

    // Ensure exam_questions table exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS exam_questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        package_id INTEGER NOT NULL,
        type TEXT NOT NULL,
        question TEXT NOT NULL,
        hangul_audio_text TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        explanation_id TEXT NOT NULL,
        explanation_en TEXT NOT NULL,
        FOREIGN KEY(package_id) REFERENCES exam_packages(id) ON DELETE CASCADE
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_questions_package ON exam_questions(package_id);');

    // Ensure memorized_checklist table exists
    await db.execute('''
      CREATE TABLE IF NOT EXISTS memorized_checklist (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        agenda TEXT NOT NULL,
        korean_hangul TEXT NOT NULL,
        korean_roman TEXT NOT NULL,
        indonesian TEXT NOT NULL,
        english TEXT NOT NULL,
        context_note TEXT,
        is_memorized INTEGER NOT NULL DEFAULT 0,
        memorized_at TEXT
      );
    ''');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_memo_agenda ON memorized_checklist(agenda);');
    await db.execute('CREATE INDEX IF NOT EXISTS idx_memo_status ON memorized_checklist(is_memorized);');

    // Seed initial memorized items if table is empty
    try {
      final memoCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM memorized_checklist'),
      ) ?? 0;
      if (memoCount == 0) {
        if (kDebugMode) print('[DatabaseHelper] Seeding 90 initial daily agenda memorization items...');
        final initialItems = MemorizedSeedData.getInitialItems();
        final batch = db.batch();
        for (final item in initialItems) {
          batch.insert('memorized_checklist', item.toMap());
        }
        await batch.commit(noResult: true);
      }
    } catch (e) {
      if (kDebugMode) print('[DatabaseHelper] Memorized checklist seed error: $e');
    }

    // Verify and seed exam packages & questions if missing or incomplete
    try {
      final pkgCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM exam_packages'),
      ) ?? 0;
      final qCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM exam_questions'),
      ) ?? 0;

      if (pkgCount < 4 || qCount < 30) {
        if (kDebugMode) print('[DatabaseHelper] Seeding missing exam packages ($pkgCount) and questions ($qCount)...');
        await _createSchemaAndSeed(db);
      }
    } catch (e) {
      if (kDebugMode) print('[DatabaseHelper] Exam table verification error: $e');
    }

    // Self-healing / Upgrade check: ensure massive dictionary (1,200+ entries) is populated
    try {
      final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM dictionary')) ?? 0;

      if (count < 1000) {
        if (kDebugMode) print('[DatabaseHelper] Upgrading dictionary to V3 schema with 1,200+ entries (current count: $count)...');
        await db.execute('DELETE FROM dictionary;');
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
      // Normalize line breaks to handle Windows \r\n and Unix \n reliably
      final normalized = sqlScript.replaceAll('\r\n', '\n');
      final statements = normalized.split(';\n');
      for (final stmt in statements) {
        // Strip single line comments from each statement block
        final clean = stmt
            .split('\n')
            .where((l) => !l.trim().startsWith('--'))
            .join('\n')
            .trim();
        if (clean.isNotEmpty) {
          try {
            await db.execute(clean);
          } catch (e) {
            // Continue on individual statement error (e.g. duplicate tables/inserts)
            if (kDebugMode) print('[DatabaseHelper] SQL stmt error: $e');
          }
        }
      }
      if (kDebugMode) print('[DatabaseHelper] Schema and seed data executed successfully.');
    } catch (e) {
      if (kDebugMode) print('[DatabaseHelper] Fallback schema execution error: $e');
    }
  }

  /// Forces clean re-seeding of dictionary from assets/sql/init.sql
  Future<int> forceReloadDictionary() async {
    final db = await database;
    try {
      await db.execute('DELETE FROM dictionary;');
    } catch (_) {}
    await _createSchemaAndSeed(db);
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM dictionary')) ?? 0;
    return count;
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
    int limit = 1500,
  }) async {
    try {
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
    } catch (e) {
      if (kDebugMode) print('[DatabaseHelper] searchDictionary error: $e');
      return [];
    }
  }

  /// Retrieves all unique Parts of Speech (POS) available in the dictionary.
  Future<List<String>> getCategories() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.rawQuery(
        'SELECT DISTINCT pos FROM dictionary ORDER BY pos ASC',
      );
      return results.map((row) => row['pos'] as String).toList();
    } catch (_) {
      return [];
    }
  }

  /// Retrieves all unique Activity Categories available in the dictionary.
  Future<List<String>> getAllActivityCategories() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> results = await db.rawQuery(
        'SELECT DISTINCT category FROM dictionary WHERE category IS NOT NULL AND category != "" ORDER BY category ASC',
      );
      return results.map((row) => row['category'] as String).toList();
    } catch (_) {
      return [];
    }
  }

  // --------------------------------------------------------------------------
  // MEMORIZATION CHECKLIST REPOSITORY METHODS
  // --------------------------------------------------------------------------

  /// Retrieves memorized items with optional agenda, status, and search filters.
  Future<List<MemorizedItem>> getMemorizedItems({
    String? agendaFilter,
    String? statusFilter,
    String? searchQuery,
  }) async {
    try {
      final db = await database;
      List<String> conditions = [];
      List<dynamic> whereArgs = [];

      if (agendaFilter != null && agendaFilter.isNotEmpty && agendaFilter != 'Semua Agenda') {
        conditions.add('agenda = ?');
        whereArgs.add(agendaFilter);
      }

      if (statusFilter != null && statusFilter.isNotEmpty && statusFilter != 'Semua') {
        if (statusFilter == 'Sudah' || statusFilter == 'Terhafal') {
          conditions.add('is_memorized = 1');
        } else if (statusFilter == 'Belum' || statusFilter == 'Belum Hafal') {
          conditions.add('is_memorized = 0');
        }
      }

      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        final pattern = '%${searchQuery.trim()}%';
        conditions.add('(korean_hangul LIKE ? OR korean_roman LIKE ? OR indonesian LIKE ? OR english LIKE ?)');
        whereArgs.addAll([pattern, pattern, pattern, pattern]);
      }

      final whereClause = conditions.isNotEmpty ? conditions.join(' AND ') : null;

      final List<Map<String, dynamic>> maps = await db.query(
        'memorized_checklist',
        where: whereClause,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'id ASC',
      );

      return List.generate(maps.length, (i) => MemorizedItem.fromMap(maps[i]));
    } catch (_) {
      return [];
    }
  }

  /// Toggles the memorization status of an item and updates timestamp.
  Future<void> toggleMemorizedItem(String id, bool isMemorized) async {
    try {
      final db = await database;
      await db.update(
        'memorized_checklist',
        {
          'is_memorized': isMemorized ? 1 : 0,
          'memorized_at': isMemorized ? DateTime.now().toIso8601String() : null,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (_) {}
  }

  /// Returns total items and memorized items counts.
  Future<Map<String, int>> getMemorizedStats() async {
    try {
      final db = await database;
      final total = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM memorized_checklist'),
      ) ?? 0;
      final memorized = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM memorized_checklist WHERE is_memorized = 1'),
      ) ?? 0;

      return {
        'total': total,
        'memorized': memorized,
      };
    } catch (_) {
      return {'total': 0, 'memorized': 0};
    }
  }

  /// Resets all memorized checklist items to unmemorized (0).
  Future<void> resetAllMemorized() async {
    final db = await database;
    await db.update(
      'memorized_checklist',
      {
        'is_memorized': 0,
        'memorized_at': null,
      },
    );
  }

  // --------------------------------------------------------------------------
  // EXAM & QUIZ REPOSITORY METHODS
  // --------------------------------------------------------------------------

  /// Fallback default exam packages in case database is empty or re-initializing
  static const List<ExamPackage> _fallbackPackages = [
    ExamPackage(
      id: 1,
      title: 'Level 1: Hangeul, Percakapan & Tren TOPIK I Terkini',
      level: 1,
      totalQuestions: 15,
    ),
    ExamPackage(
      id: 2,
      title: 'Level 2: Struktur Kalimat SOV & Arah Lokasi',
      level: 2,
      totalQuestions: 5,
    ),
    ExamPackage(
      id: 3,
      title: 'Level 3: Konjugasi Sopan & Kehidupan Sehari-hari',
      level: 3,
      totalQuestions: 5,
    ),
    ExamPackage(
      id: 4,
      title: 'Level 4: TOPIK I Mastery & Tata Bahasa Lanjutan',
      level: 4,
      totalQuestions: 5,
    ),
  ];

  /// Retrieves all Exam Packages along with user's best recorded score.
  Future<List<ExamPackage>> getExamPackages() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> packagesMap = await db.query(
        'exam_packages',
        orderBy: 'level ASC',
      );

      if (packagesMap.isEmpty) {
        if (kDebugMode) print('[DatabaseHelper] exam_packages table is empty, seeding...');
        await _createSchemaAndSeed(db);
        final retryMaps = await db.query('exam_packages', orderBy: 'level ASC');
        if (retryMaps.isEmpty) return _fallbackPackages;
      }

      final activeMaps = packagesMap.isNotEmpty ? packagesMap : await db.query('exam_packages', orderBy: 'level ASC');

      final List<ExamPackage> list = [];
      for (final map in activeMaps) {
        final packageId = map['id'] as int? ?? 1;

        // Query dynamic question count to always reflect true question count in DB
        int countRes = 0;
        try {
          countRes = Sqflite.firstIntValue(await db.rawQuery(
            'SELECT COUNT(*) FROM exam_questions WHERE package_id = ?',
            [packageId],
          )) ?? (map['total_questions'] as int? ?? 15);
        } catch (_) {
          countRes = map['total_questions'] as int? ?? 15;
        }

        // Query best score from user_quiz_history
        int? bestScore;
        double? bestPct;

        try {
          final history = await db.rawQuery('''
            SELECT MAX(score) as best_score, MAX(percentage) as best_pct 
            FROM user_quiz_history 
            WHERE package_id = ?
          ''', [packageId]);

          if (history.isNotEmpty && history.first['best_score'] != null) {
            bestScore = history.first['best_score'] as int?;
            final numPct = history.first['best_pct'] as num?;
            if (numPct != null) {
              bestPct = numPct.toDouble();
            } else if (bestScore != null && countRes > 0) {
              bestPct = (bestScore / countRes) * 100.0;
            }
          }
        } catch (_) {}

        list.add(ExamPackage(
          id: packageId,
          title: map['title'] as String? ?? 'Level $packageId',
          level: map['level'] as int? ?? packageId,
          totalQuestions: countRes > 0 ? countRes : 15,
          bestScore: bestScore,
          bestPercentage: bestPct,
        ));
      }

      return list.isNotEmpty ? list : _fallbackPackages;
    } catch (e) {
      if (kDebugMode) print('[DatabaseHelper] getExamPackages error: $e');
      return _fallbackPackages;
    }
  }

  /// Retrieves all questions belonging to a specific package.
  Future<List<ExamQuestion>> getQuestionsForPackage(int packageId) async {
    try {
      final db = await database;
      List<Map<String, dynamic>> questionsMap = await db.query(
        'exam_questions',
        where: 'package_id = ?',
        whereArgs: [packageId],
        orderBy: 'id ASC',
      );

      if (questionsMap.isEmpty) {
        if (kDebugMode) print('[DatabaseHelper] No questions found for package $packageId, seeding init.sql...');
        await _createSchemaAndSeed(db);
        questionsMap = await db.query(
          'exam_questions',
          where: 'package_id = ?',
          whereArgs: [packageId],
          orderBy: 'id ASC',
        );
      }

      return List.generate(questionsMap.length, (i) => ExamQuestion.fromMap(questionsMap[i]));
    } catch (e) {
      if (kDebugMode) print('[DatabaseHelper] getQuestionsForPackage error: $e');
      return [];
    }
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
