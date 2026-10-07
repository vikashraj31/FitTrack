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
    'fittrack_exercise_order',
    'fittrack_hidden_exercises',
  ];

  static const Set<String> _autoIdTables = {
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
  };

  static const Set<String> _compositeKeyTables = {
    'fittrack_exercise_order',
    'fittrack_hidden_exercises',
  };

  static Future<void> _ensureAuxiliaryTables(
    AppDatabase database,
  ) async {
    await database.customStatement('''
      CREATE TABLE IF NOT EXISTS fittrack_exercise_order (
        user_id TEXT NOT NULL,
        exercise_name TEXT NOT NULL,
        order_index INTEGER NOT NULL,
        PRIMARY KEY (user_id, exercise_name)
      )
    ''');

    await database.customStatement('''
      CREATE TABLE IF NOT EXISTS fittrack_hidden_exercises (
        user_id TEXT NOT NULL,
        exercise_name TEXT NOT NULL,
        PRIMARY KEY (user_id, exercise_name)
      )
    ''');
  }

  static Future<void> _ensureWeightTable(
    AppDatabase database,
  ) async {
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
    await _ensureAuxiliaryTables(database);

    final tableData = <String, dynamic>{};

    for (final table in _tables) {
      final rows = await database.customSelect(
        'SELECT * FROM $table',
      ).get();

      tableData[table] = rows
          .map((row) => _normalizeRow(row.data))
          .toList();
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

    final jsonText = const JsonEncoder.withIndent('  ').convert(
      backup,
    );

    return Uint8List.fromList(
      utf8.encode(jsonText),
    );
  }

  static Future<Map<String, int>> restoreFromBytes(
    AppDatabase database,
    Uint8List bytes,
  ) async {
    final dynamic decoded;

    try {
      decoded = jsonDecode(utf8.decode(bytes));
    } catch (_) {
      throw const FormatException(
        'This is not a valid FitTrack backup file.',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Invalid FitTrack backup format.',
      );
    }

    if (decoded['format'] != 'FitTrack Backup') {
      throw const FormatException(
        'This file is not a FitTrack backup.',
      );
    }

    final version = decoded['backupVersion'];

    if (version is! int ||
        version < 1 ||
        version > backupVersion) {
      throw const FormatException(
        'Unsupported FitTrack backup version.',
      );
    }

    final tables = decoded['tables'];

    if (tables is! Map<String, dynamic>) {
      throw const FormatException(
        'Backup data is missing or invalid.',
      );
    }

    // Validate only tables understood by this version.
    for (final entry in tables.entries) {
      if (!_tables.contains(entry.key)) {
        continue;
      }

      if (entry.value is! List) {
        throw FormatException(
          'Invalid data for table "${entry.key}".',
        );
      }

      for (final row in entry.value as List) {
        if (row is! Map) {
          throw FormatException(
            'Invalid row data in "${entry.key}".',
          );
        }
      }
    }

    await _ensureWeightTable(database);
    await _ensureAuxiliaryTables(database);

    final restoredCounts = <String, int>{};

    // Old backup ID -> local/new ID.
    //
    // Required for parent tables because child tables reference
    // these IDs.
    final routineIdMap = <int, int>{};
    final weeklyDietPlanIdMap = <int, int>{};

    await database.transaction(() async {
      for (final table in _tables) {
        final rows = tables[table];

        if (rows is! List || rows.isEmpty) {
          restoredCounts[table] = 0;
          continue;
        }

        var count = 0;

        for (final rawRow in rows) {
          final originalRow =
              Map<String, dynamic>.from(rawRow as Map);

          if (originalRow.isEmpty) {
            continue;
          }

          // ------------------------------------------------------
          // WORKOUT ROUTINES
          // ------------------------------------------------------
          if (table == 'workout_routines') {
            final oldId = originalRow['id'];

            if (oldId is! int || oldId <= 0) {
              throw const FormatException(
                'Invalid workout routine ID in backup.',
              );
            }

            final result = await _restoreParentRow(
              database: database,
              table: table,
              row: originalRow,
            );

            routineIdMap[oldId] = result.id;

            if (result.inserted) {
              count++;
            }

            continue;
          }

          // ------------------------------------------------------
          // WEEKLY DIET PLANS
          // ------------------------------------------------------
          if (table == 'weekly_diet_plans') {
            final oldId = originalRow['id'];

            if (oldId is! int || oldId <= 0) {
              throw const FormatException(
                'Invalid weekly diet plan ID in backup.',
              );
            }

            final result = await _restoreParentRow(
              database: database,
              table: table,
              row: originalRow,
            );

            weeklyDietPlanIdMap[oldId] = result.id;

            if (result.inserted) {
              count++;
            }

            continue;
          }

          // ------------------------------------------------------
          // ROUTINE SETS
          // ------------------------------------------------------
          if (table == 'routine_sets') {
            final oldRoutineId =
                originalRow['routine_id'];

            if (oldRoutineId is! int || oldRoutineId <= 0) {
              throw const FormatException(
                'Invalid routine_id in backup.',
              );
            }

            final mappedRoutineId =
                routineIdMap[oldRoutineId];

            if (mappedRoutineId == null) {
              throw FormatException(
                'Backup contains a routine set whose parent '
                'routine is missing: $oldRoutineId',
              );
            }

            final row = Map<String, dynamic>.from(
              originalRow,
            );

            row['routine_id'] = mappedRoutineId;

            final result = await _restoreAutoIdRow(
              database: database,
              table: table,
              row: row,
            );

            if (result.inserted) {
              count++;
            }

            continue;
          }

          // ------------------------------------------------------
          // WEEKLY DIET ITEMS
          // ------------------------------------------------------
          if (table == 'weekly_diet_items') {
            final oldPlanId =
                originalRow['plan_id'];

            if (oldPlanId is! int || oldPlanId <= 0) {
              throw const FormatException(
                'Invalid plan_id in backup.',
              );
            }

            final mappedPlanId =
                weeklyDietPlanIdMap[oldPlanId];

            if (mappedPlanId == null) {
              throw FormatException(
                'Backup contains a weekly diet item whose '
                'parent plan is missing: $oldPlanId',
              );
            }

            final row = Map<String, dynamic>.from(
              originalRow,
            );

            row['plan_id'] = mappedPlanId;

            final result = await _restoreAutoIdRow(
              database: database,
              table: table,
              row: row,
            );

            if (result.inserted) {
              count++;
            }

            continue;
          }

          // ------------------------------------------------------
          // COMPOSITE-KEY TABLES
          // ------------------------------------------------------
          if (_compositeKeyTables.contains(table)) {
            final inserted = await _restoreCompositeRow(
              database: database,
              table: table,
              row: originalRow,
            );

            if (inserted) {
              count++;
            }

            continue;
          }

          // ------------------------------------------------------
          // NORMAL AUTO-ID TABLES
          // ------------------------------------------------------
          if (_autoIdTables.contains(table)) {
            final result = await _restoreAutoIdRow(
              database: database,
              table: table,
              row: originalRow,
            );

            if (result.inserted) {
              count++;
            }

            continue;
          }

          // Should never be reached because _tables only contains
          // known tables.
          throw FormatException(
            'Unsupported backup table: $table',
          );
        }

        restoredCounts[table] = count;
      }
    });

    return restoredCounts;
  }

  // ============================================================
  // AUTO-ID RESTORE
  // ============================================================

  static Future<_RestoreInsertResult> _restoreAutoIdRow({
    required AppDatabase database,
    required String table,
    required Map<String, dynamic> row,
  }) async {
    final idValue = row['id'];

    // A valid exported auto-ID row normally has an integer ID.
    // Still allow missing IDs by inserting normally.
    if (idValue != null && idValue is! int) {
      throw FormatException(
        'Invalid ID in table "$table".',
      );
    }

    // No ID supplied -> let SQLite generate one.
    if (idValue == null) {
      final result = await _insertRow(
        database: database,
        table: table,
        row: row,
        includeId: false,
      );

      return result;
    }

    final existing = await _getRowById(
      database: database,
      table: table,
      id: idValue,
    );

    // ----------------------------------------------------------
    // No collision -> keep original ID.
    // ----------------------------------------------------------
    if (existing == null) {
      return _insertRow(
        database: database,
        table: table,
        row: row,
        includeId: true,
        forcedId: idValue,
      );
    }

    // ----------------------------------------------------------
    // Same ID + same content -> leave local record untouched.
    // ----------------------------------------------------------
    if (_rowsEquivalent(
      existing,
      row,
      ignoreKeys: {'id'},
    )) {
      return _RestoreInsertResult(
        inserted: false,
        id: idValue,
      );
    }

    // ----------------------------------------------------------
    // Same ID + different content:
    // generate a NEW local ID.
    // ----------------------------------------------------------
    return _insertRow(
      database: database,
      table: table,
      row: row,
      includeId: false,
    );
  }

  // ============================================================
  // PARENT TABLE RESTORE
  // ============================================================

  static Future<_RestoreInsertResult> _restoreParentRow({
    required AppDatabase database,
    required String table,
    required Map<String, dynamic> row,
  }) async {
    final idValue = row['id'];

    if (idValue is! int || idValue <= 0) {
      throw FormatException(
        'Invalid parent ID in table "$table".',
      );
    }

    final existing = await _getRowById(
      database: database,
      table: table,
      id: idValue,
    );

    // No collision.
    if (existing == null) {
      return _insertRow(
        database: database,
        table: table,
        row: row,
        includeId: true,
        forcedId: idValue,
      );
    }

    // Same record already exists locally.
    if (_rowsEquivalent(
      existing,
      row,
      ignoreKeys: {'id'},
    )) {
      return _RestoreInsertResult(
        inserted: false,
        id: idValue,
      );
    }

    // ID belongs to a different local record.
    // Generate a new ID for the imported parent.
    return _insertRow(
      database: database,
      table: table,
      row: row,
      includeId: false,
    );
  }

  // ============================================================
  // COMPOSITE-KEY RESTORE
  // ============================================================

  static Future<bool> _restoreCompositeRow({
    required AppDatabase database,
    required String table,
    required Map<String, dynamic> row,
  }) async {
    final columns = row.keys
        .where(_isSafeIdentifier)
        .toList(growable: false);

    if (columns.isEmpty) {
      return false;
    }

    final placeholders =
        List.filled(columns.length, '?').join(', ');

    final columnSql =
        columns.map((c) => '"$c"').join(', ');

    final values = columns
        .map((column) => _restoreValue(row[column]))
        .toList();

    await database.customStatement(
      'INSERT OR IGNORE INTO $table '
      '($columnSql) VALUES ($placeholders)',
      values,
    );

    final changeRows = await database.customSelect(
      'SELECT changes() AS inserted_count',
    ).get();

    if (changeRows.isEmpty) {
      return false;
    }

    return changeRows.first.read<int>('inserted_count') > 0;
  }

  // ============================================================
  // INSERT HELPER
  // ============================================================

  static Future<_RestoreInsertResult> _insertRow({
    required AppDatabase database,
    required String table,
    required Map<String, dynamic> row,
    required bool includeId,
    int? forcedId,
  }) async {
    final insertRow =
        Map<String, dynamic>.from(row);

    if (!includeId) {
      insertRow.remove('id');
    } else if (forcedId != null) {
      insertRow['id'] = forcedId;
    }

    final columns = insertRow.keys
        .where(_isSafeIdentifier)
        .toList(growable: false);

    if (columns.isEmpty) {
      throw FormatException(
        'No valid columns available for "$table".',
      );
    }

    final placeholders =
        List.filled(columns.length, '?').join(', ');

    final columnSql =
        columns.map((c) => '"$c"').join(', ');

    final values = columns
        .map((column) => _restoreValue(insertRow[column]))
        .toList();

    await database.customStatement(
      'INSERT INTO $table '
      '($columnSql) VALUES ($placeholders)',
      values,
    );

    final changeRows = await database.customSelect(
      'SELECT changes() AS inserted_count',
    ).get();

    if (changeRows.isEmpty ||
        changeRows.first.read<int>('inserted_count') <= 0) {
      throw Exception(
        'Failed to restore row into "$table".',
      );
    }

    final insertedId = includeId && forcedId != null
        ? forcedId
        : await _getLastInsertRowId(database);

    return _RestoreInsertResult(
      inserted: true,
      id: insertedId,
    );
  }

  // ============================================================
  // FIND EXISTING ROW BY ID
  // ============================================================

  static Future<Map<String, dynamic>?> _getRowById({
    required AppDatabase database,
    required String table,
    required int id,
  }) async {
    final rows = await database.customSelect(
      'SELECT * FROM $table '
      'WHERE id = $id '
      'LIMIT 1',
    ).get();

    if (rows.isEmpty) {
      return null;
    }

    return Map<String, dynamic>.from(
      rows.first.data,
    );
  }

  // ============================================================
  // LAST INSERT ID
  // ============================================================

  static Future<int> _getLastInsertRowId(
    AppDatabase database,
  ) async {
    final rows = await database.customSelect(
      'SELECT last_insert_rowid() AS new_id',
    ).get();

    if (rows.isEmpty) {
      throw Exception(
        'Could not determine inserted row ID.',
      );
    }

    final id = rows.first.read<int>('new_id');

    if (id <= 0) {
      throw Exception(
        'Invalid inserted row ID.',
      );
    }

    return id;
  }

  // ============================================================
  // ROW COMPARISON
  // ============================================================

  static bool _rowsEquivalent(
    Map<String, dynamic> existing,
    Map<String, dynamic> incoming, {
    Set<String> ignoreKeys = const {},
  }) {
    final keys = incoming.keys
        .where((key) => !ignoreKeys.contains(key))
        .where(_isSafeIdentifier)
        .toSet();

    for (final key in keys) {
      if (!existing.containsKey(key)) {
        return false;
      }

      final existingValue =
          _canonicalValue(existing[key]);

      final incomingValue =
          _canonicalValue(incoming[key]);

      if (!_deepEquals(
        existingValue,
        incomingValue,
      )) {
        return false;
      }
    }

    return true;
  }

  static bool _deepEquals(
    dynamic a,
    dynamic b,
  ) {
    if (a is num && b is num) {
      return a == b;
    }

    if (a is String && b is String) {
      return a == b;
    }

    if (a is bool && b is bool) {
      return a == b;
    }

    if (a == null || b == null) {
      return a == b;
    }

    if (a is List && b is List) {
      if (a.length != b.length) {
        return false;
      }

      for (var i = 0; i < a.length; i++) {
        if (!_deepEquals(a[i], b[i])) {
          return false;
        }
      }

      return true;
    }

    if (a is Map && b is Map) {
      if (a.length != b.length) {
        return false;
      }

      for (final key in a.keys) {
        if (!b.containsKey(key)) {
          return false;
        }

        if (!_deepEquals(a[key], b[key])) {
          return false;
        }
      }

      return true;
    }

    return a == b;
  }

  static dynamic _canonicalValue(dynamic value) {
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

    if (value is Map) {
      final result = <String, dynamic>{};

      final keys = value.keys
          .map((key) => key.toString())
          .toList()
        ..sort();

      for (final key in keys) {
        result[key] = _canonicalValue(
          value[key],
        );
      }

      return result;
    }

    if (value is List) {
      return value
          .map(_canonicalValue)
          .toList();
    }

    return value.toString();
  }

  // ============================================================
  // BACKUP VALUE NORMALIZATION
  // ============================================================

  static Map<String, dynamic> _normalizeRow(
    Map<String, dynamic> row,
  ) {
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

    if (value is Map) {
      return {
        for (final entry in value.entries)
          entry.key.toString():
              _normalizeValue(entry.value),
      };
    }

    if (value is List) {
      return value
          .map(_normalizeValue)
          .toList();
    }

    return value.toString();
  }

  static dynamic _restoreValue(dynamic value) {
    if (value is Map &&
        value['__type'] == 'blob' &&
        value['base64'] is String) {
      return base64Decode(
        value['base64'] as String,
      );
    }

    return value;
  }

  // ============================================================
  // IDENTIFIER SAFETY
  // ============================================================

  static bool _isSafeIdentifier(
    String value,
  ) {
    return RegExp(
      r'^[A-Za-z_][A-Za-z0-9_]*$',
    ).hasMatch(value);
  }
}

class _RestoreInsertResult {
  final bool inserted;
  final int id;

  const _RestoreInsertResult({
    required this.inserted,
    required this.id,
  });
}