import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PreparedWorkoutStorage {
  static DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static Future<File> _fileForUser(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final safeUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return File(
      '${directory.path}${Platform.pathSeparator}fittrack_prepared_workout_$safeUserId.json',
    );
  }

  static Future<Map<String, List<Map<String, dynamic>>>> load({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final file = await _fileForUser(userId);
      if (!await file.exists()) {
        return {};
      }

      final raw = jsonDecode(await file.readAsString());
      if (raw is! Map) {
        return {};
      }

      final savedDateText = raw['date'];
      final savedDate =
          savedDateText is String ? DateTime.tryParse(savedDateText) : null;

      if (savedDate == null || !_isSameDay(savedDate, date)) {
        await file.delete();
        return {};
      }

      final rawSets = raw['sets'];
      if (rawSets is! Map) {
        return {};
      }

      final result = <String, List<Map<String, dynamic>>>{};

      for (final entry in rawSets.entries) {
        final exerciseName = entry.key.toString();
        final rawExerciseSets = entry.value;

        if (rawExerciseSets is! List) {
          continue;
        }

        final exerciseSets = <Map<String, dynamic>>[];

        for (final rawSet in rawExerciseSets) {
          if (rawSet is! Map) {
            continue;
          }

          final weight = (rawSet['weight'] as num?)?.toDouble();
          final reps = (rawSet['reps'] as num?)?.toInt();

          if (weight == null || reps == null || weight < 0 || reps <= 0) {
            continue;
          }

          exerciseSets.add({
            'weight': weight,
            'reps': reps,
          });
        }

        if (exerciseSets.isNotEmpty) {
          result[exerciseName] = exerciseSets;
        }
      }

      return result;
    } catch (_) {
      return {};
    }
  }

  static Future<void> save({
    required String userId,
    required DateTime date,
    required Map<String, List<Map<String, dynamic>>> sets,
  }) async {
    try {
      final file = await _fileForUser(userId);

      if (sets.isEmpty) {
        if (await file.exists()) {
          await file.delete();
        }
        return;
      }

      await file.writeAsString(
        jsonEncode({
          'date': _dateOnly(date).toIso8601String(),
          'sets': sets,
        }),
        flush: true,
      );
    } catch (_) {
      // Draft persistence is best-effort. It must never block the workout UI.
    }
  }

  static Future<void> clear({required String userId}) async {
    try {
      final file = await _fileForUser(userId);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Best-effort cleanup.
    }
  }
}
