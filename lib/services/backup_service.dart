import 'dart:convert';
import 'dart:typed_data';


import 'database_service.dart';

class BackupService {
  static const int backupVersion = 1;

  static const List<String> _tables = [
    'workout_sets',
    'exercise_library',
    'workout_routines',
    'routine_sets',
    'daily_data',
    'diet_entries',
    'extra_calories_entries',
    'daily_targets',
    'food_library',
    'weekly_diet_plans',
    'weekly_diet_items',
    'user_weights',
  ];

  static const List<String> _clearOrder = [
    'weekly_diet_items',
    'weekly_diet_plans',
    'routine_sets',
    'workout_routines',
    'diet_entries',
    'extra_calories_entries',
    'workout_sets',
    'exercise_library',
    'daily_data',
    'daily_targets',
    'food_library',
    'user_weights',
  ];

  static Future<void> _ensureWeightTable(AppDatabase database) async {
    await database.customStatement('''
      CREATE TABLE IF NOT EXISTS user_weights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        weight REAL NOT NULL,
        recorded_at TEXT NOT NULL
      )
    ''');
  }

  static Future<Map<String, dynamic>> createBackup(
    AppDatabase database,
  ) async {
    await _ensureWeightTable(database);

    final tableData = <String, dynamic>{};

    for (final table in _tables) {
      final rows = await database.customSelect(
        'SELECT * FROM $table',
      ).get();

      tableData[table] = rows.map((row) => _normalizeRow(row.data)).toList();
    }

    return {
      'format': 'FitTrack Backup',
      'backupVersion': backupVersion,
      'createdAt': DateTime.now().toIso8601String(),
      'schemaVersion': 14,
      'tables': tableData,
    };
  }

  static Future<Uint8List> createBackupBytes(
    AppDatabase database,
  ) async {
    final backup = await createBackup(database);
    final jsonText = const JsonEncoder.withIndent('  ').convert(backup);
    return Uint8List.fromList(utf8.encode(jsonText));
  }

  static Future<Map<String, int>> restoreFromBytes(
    AppDatabase database,
    Uint8List bytes,
  ) async {
    final dynamic decoded;

    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } catch (_) {
      throw const FormatException('This is not a valid FitTrack backup file.');
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid FitTrack backup format.');
    }

    if (decoded['format'] != 'FitTrack Backup') {
      throw const FormatException('This file is not a FitTrack backup.');
    }

    final version = decoded['backupVersion'];
    if (version is! int || version < 1 || version > backupVersion) {
      throw const FormatException('Unsupported FitTrack backup version.');
    }

    final tables = decoded['tables'];
    if (tables is! Map<String, dynamic>) {
      throw const FormatException('Backup data is missing or invalid.');
    }

    for (final entry in tables.entries) {
      if (!_tables.contains(entry.key)) continue;

      if (entry.value is! List) {
        throw FormatException('Invalid data for table "${entry.key}".');
      }

      for (final row in entry.value as List) {
        if (row is! Map) {
          throw FormatException('Invalid row data in "${entry.key}".');
        }
      }
    }

    await _ensureWeightTable(database);

    final restoredCounts = <String, int>{};

    await database.transaction(() async {
      for (final table in _clearOrder) {
        await database.customStatement('DELETE FROM $table');
      }

      for (final table in _tables) {
        final rows = tables[table];
        if (rows is! List || rows.isEmpty) {
          restoredCounts[table] = 0;
          continue;
        }

        var count = 0;

        for (final rawRow in rows) {
          final row = Map<String, dynamic>.from(rawRow as Map);

          if (row.isEmpty) continue;

          final columns = row.keys
              .where(_isSafeIdentifier)
              .toList(growable: false);

          if (columns.isEmpty) continue;

          final placeholders = List.filled(columns.length, '?').join(', ');
          final columnSql = columns.map((c) => '"$c"').join(', ');
          final values = columns
              .map((column) => _restoreValue(row[column]))
              .toList();

          await database.customStatement(
            'INSERT INTO $table ($columnSql) VALUES ($placeholders)',
            values,
          );

          count++;
        }

        restoredCounts[table] = count;
      }
    });

    return restoredCounts;
  }

  static Map<String, dynamic> _normalizeRow(Map<String, dynamic> row) {
    return {
      for (final entry in row.entries)
        entry.key: _normalizeValue(entry.value),
    };
  }

  static dynamic _normalizeValue(dynamic value) {
    if (value == null ||
        value is String ||
        value is num ||
        value is bool) {
      return value;
    }

    if (value is DateTime) {
      return value.millisecondsSinceEpoch;
    }

    if (value is Uint8List) {
      return {
        '__type': 'blob',
        'base64': base64Encode(value),
      };
    }

    return value.toString();
  }

  static dynamic _restoreValue(dynamic value) {
    if (value is Map &&
        value['__type'] == 'blob' &&
        value['base64'] is String) {
      return base64Decode(value['base64'] as String);
    }

    return value;
  }

  static bool _isSafeIdentifier(String value) {
    return RegExp(r'^[A-Za-z_][A-Za-z0-9_]*$').hasMatch(value);
  }
}
