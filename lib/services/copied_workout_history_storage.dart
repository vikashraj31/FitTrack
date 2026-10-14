import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Stores the copied workout snapshot separately from completed workout sets.
///
/// Stores copied workout snapshots separately from completed workout sets.
/// The snapshot keeps every copied exercise available for copying that workout
/// again later. History-facing queries return only entries marked performed;
/// copied-but-unperformed exercises do not appear as exercise history. This
/// keeps the app's SQLite schema at version 14 and prevents copied values from
/// inflating workout statistics.
class CopiedExerciseSetSnapshot {
  final double weight;
  final int reps;

  const CopiedExerciseSetSnapshot({required this.weight, required this.reps});

  factory CopiedExerciseSetSnapshot.fromJson(dynamic value) {
    if (value is! Map) {
      throw const FormatException('Invalid copied workout set');
    }
    final weight = (value['weight'] as num?)?.toDouble();
    final reps = (value['reps'] as num?)?.toInt();
    if (weight == null || reps == null || weight < 0 || reps <= 0) {
      throw const FormatException('Invalid copied workout set values');
    }
    return CopiedExerciseSetSnapshot(weight: weight, reps: reps);
  }

  Map<String, dynamic> toJson() => {'weight': weight, 'reps': reps};
}

class CopiedExerciseHistoryEntry {
  final DateTime date;
  final String exerciseName;
  final List<CopiedExerciseSetSnapshot> sets;
  final bool performed;

  const CopiedExerciseHistoryEntry({
    required this.date,
    required this.exerciseName,
    required this.sets,
    required this.performed,
  });

  factory CopiedExerciseHistoryEntry.fromJson({
    required DateTime date,
    required String exerciseName,
    required dynamic value,
  }) {
    if (value is! Map) {
      throw const FormatException('Invalid copied exercise history entry');
    }
    final rawSets = value['sets'];
    final parsedSets = <CopiedExerciseSetSnapshot>[];
    if (rawSets is List) {
      for (final rawSet in rawSets) {
        try {
          parsedSets.add(CopiedExerciseSetSnapshot.fromJson(rawSet));
        } catch (_) {
          // Ignore malformed sets without discarding the other history rows.
        }
      }
    }
    return CopiedExerciseHistoryEntry(
      date: DateTime(date.year, date.month, date.day),
      exerciseName: exerciseName,
      sets: parsedSets,
      performed: value['performed'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'sets': sets.map((set) => set.toJson()).toList(),
        'performed': performed,
      };
}

class CopiedWorkoutHistoryStorage {
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String dateKey(DateTime date) {
    final day = dateOnly(date);
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }

  static String _exerciseKey(String name) => name.trim().toLowerCase();

  static Future<File> _fileForUser(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final safeUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return File(
      '${directory.path}${Platform.pathSeparator}'
      'fittrack_copied_workout_history_$safeUserId.json',
    );
  }

  static Future<Map<String, dynamic>> _readRoot(String userId) async {
    try {
      final file = await _fileForUser(userId);
      if (!await file.exists()) return {'version': 1, 'days': <String, dynamic>{}};
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map || decoded['days'] is! Map) {
        return {'version': 1, 'days': <String, dynamic>{}};
      }
      return {
        'version': 1,
        'days': Map<String, dynamic>.from(decoded['days'] as Map),
      };
    } catch (_) {
      return {'version': 1, 'days': <String, dynamic>{}};
    }
  }

  static Future<void> _writeRoot(
    String userId,
    Map<String, dynamic> root,
  ) async {
    try {
      final file = await _fileForUser(userId);
      final days = root['days'];
      if (days is! Map || days.isEmpty) {
        if (await file.exists()) await file.delete();
        return;
      }
      await file.writeAsString(
        jsonEncode({'version': 1, 'days': days}),
        flush: true,
      );
    } catch (_) {
      // A copied-history sidecar must never crash the workout screen.
    }
  }

  static Map<String, CopiedExerciseHistoryEntry> _parseDay({
    required String dateText,
    required dynamic dayValue,
  }) {
    final date = DateTime.tryParse(dateText);
    if (date == null || dayValue is! Map || dayValue['exercises'] is! Map) {
      return <String, CopiedExerciseHistoryEntry>{};
    }

    final result = <String, CopiedExerciseHistoryEntry>{};
    final exercises = dayValue['exercises'] as Map;
    for (final item in exercises.entries) {
      final name = item.key.toString().trim();
      if (name.isEmpty) continue;
      try {
        result[name] = CopiedExerciseHistoryEntry.fromJson(
          date: date,
          exerciseName: name,
          value: item.value,
        );
      } catch (_) {
        // Ignore only the malformed exercise row.
      }
    }
    return result;
  }

  static Future<Map<String, CopiedExerciseHistoryEntry>> loadDay({
    required String userId,
    required DateTime date,
  }) async {
    final root = await _readRoot(userId);
    final days = root['days'];
    if (days is! Map) return <String, CopiedExerciseHistoryEntry>{};
    return _parseDay(dateText: dateKey(date), dayValue: days[dateKey(date)]);
  }

  static Future<Map<DateTime, Map<String, CopiedExerciseHistoryEntry>>>
      loadAllDays({required String userId}) async {
    final root = await _readRoot(userId);
    final days = root['days'];
    final result = <DateTime, Map<String, CopiedExerciseHistoryEntry>>{};
    if (days is! Map) return result;

    for (final item in days.entries) {
      final dateText = item.key.toString();
      final date = DateTime.tryParse(dateText);
      if (date == null) continue;
      final parsed = _parseDay(dateText: dateText, dayValue: item.value);
      if (parsed.isNotEmpty) result[dateOnly(date)] = parsed;
    }
    return result;
  }

  static Future<List<DateTime>> loadDates({required String userId}) async {
    final all = await loadAllDays(userId: userId);
    final dates = all.keys.toList()..sort((a, b) => b.compareTo(a));
    return dates;
  }

  static Future<CopiedExerciseHistoryEntry?> getEntry({
    required String userId,
    required DateTime date,
    required String exerciseName,
  }) async {
    final day = await loadDay(userId: userId, date: date);
    for (final entry in day.entries) {
      if (_exerciseKey(entry.key) == _exerciseKey(exerciseName)) {
        return entry.value;
      }
    }
    return null;
  }

  static Future<List<CopiedExerciseHistoryEntry>> loadExerciseHistory({
    required String userId,
    required String exerciseName,
  }) async {
    final all = await loadAllDays(userId: userId);
    final result = <CopiedExerciseHistoryEntry>[];
    for (final day in all.values) {
      for (final entry in day.entries) {
        if (_exerciseKey(entry.key) == _exerciseKey(exerciseName) &&
            entry.value.performed) {
          result.add(entry.value);
        }
      }
    }
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  /// Replaces the copied snapshot for [date] with all exercises in [exercises].
  /// Existing workout rows in SQLite are not changed by this operation.
  static Future<void> saveCopiedWorkout({
    required String userId,
    required DateTime date,
    required Map<String, List<Map<String, dynamic>>> exercises,
    Set<String> performedExerciseNames = const <String>{},
  }) async {
    final root = await _readRoot(userId);
    final days = Map<String, dynamic>.from(root['days'] as Map);
    final performedKeys = performedExerciseNames.map(_exerciseKey).toSet();
    final exerciseRows = <String, dynamic>{};

    for (final entry in exercises.entries) {
      final name = entry.key.trim();
      if (name.isEmpty) continue;
      final sets = <Map<String, dynamic>>[];
      for (final set in entry.value) {
        final weight = (set['weight'] as num?)?.toDouble();
        final reps = (set['reps'] as num?)?.toInt();
        if (weight == null || reps == null || weight < 0 || reps <= 0) continue;
        sets.add({'weight': weight, 'reps': reps});
      }
      // Save the exercise even if its copied set list is empty, so the app can
      // still report that it was copied but not performed.
      exerciseRows[name] = {
        'sets': sets,
        'performed': performedKeys.contains(_exerciseKey(name)),
      };
    }

    final key = dateKey(date);
    if (exerciseRows.isEmpty) {
      days.remove(key);
    } else {
      days[key] = {'exercises': exerciseRows};
    }
    root['days'] = days;
    await _writeRoot(userId, root);
  }

  static Future<void> markPerformed({
    required String userId,
    required DateTime date,
    required String exerciseName,
    bool performed = true,
    List<Map<String, dynamic>>? sets,
  }) async {
    final root = await _readRoot(userId);
    final days = Map<String, dynamic>.from(root['days'] as Map);
    final key = dateKey(date);
    final dayValue = days[key];
    if (dayValue is! Map || dayValue['exercises'] is! Map) return;

    final exercises = Map<String, dynamic>.from(dayValue['exercises'] as Map);
    String? actualKey;
    for (final candidate in exercises.keys) {
      if (_exerciseKey(candidate.toString()) == _exerciseKey(exerciseName)) {
        actualKey = candidate.toString();
        break;
      }
    }
    if (actualKey == null) return;
    final value = exercises[actualKey];
    if (value is! Map) return;
    final updated = Map<String, dynamic>.from(value);
    updated['performed'] = performed;
    if (sets != null) {
      final validatedSets = <Map<String, dynamic>>[];
      for (final set in sets) {
        final weight = (set['weight'] as num?)?.toDouble();
        final reps = (set['reps'] as num?)?.toInt();
        if (weight == null || reps == null || weight < 0 || reps <= 0) continue;
        validatedSets.add({'weight': weight, 'reps': reps});
      }
      updated['sets'] = validatedSets;
    }
    exercises[actualKey] = updated;
    days[key] = {'exercises': exercises};
    root['days'] = days;
    await _writeRoot(userId, root);
  }

  static Future<void> removeExercise({
    required String userId,
    required DateTime date,
    required String exerciseName,
  }) async {
    final root = await _readRoot(userId);
    final days = Map<String, dynamic>.from(root['days'] as Map);
    final key = dateKey(date);
    final dayValue = days[key];
    if (dayValue is! Map || dayValue['exercises'] is! Map) return;

    final exercises = Map<String, dynamic>.from(dayValue['exercises'] as Map);
    exercises.removeWhere(
      (name, _) => _exerciseKey(name.toString()) == _exerciseKey(exerciseName),
    );
    if (exercises.isEmpty) {
      days.remove(key);
    } else {
      days[key] = {'exercises': exercises};
    }
    root['days'] = days;
    await _writeRoot(userId, root);
  }

  static Future<bool> hasUnperformedExercises({
    required String userId,
    required DateTime date,
  }) async {
    final exercises = await loadDay(userId: userId, date: date);
    return exercises.values.any((entry) => !entry.performed);
  }
}
