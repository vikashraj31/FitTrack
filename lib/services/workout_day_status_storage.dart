import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Persists days where a prepared workout expired without any workout being
/// recorded. Kept outside SQLite so the app's schema version remains 14.
class WorkoutDayStatusStorage {
  static DateTime dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  static String dateKey(DateTime date) {
    final day = dateOnly(date);
    return '${day.year.toString().padLeft(4, '0')}-'
        '${day.month.toString().padLeft(2, '0')}-'
        '${day.day.toString().padLeft(2, '0')}';
  }

  static Future<File> _fileForUser(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final safeUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return File(
      '${directory.path}${Platform.pathSeparator}fittrack_workout_day_status_$safeUserId.json',
    );
  }

  static Future<Set<String>> loadMissedDateKeys({
    required String userId,
  }) async {
    try {
      final file = await _fileForUser(userId);
      if (!await file.exists()) return <String>{};
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map || decoded['missedDates'] is! List) {
        return <String>{};
      }
      return (decoded['missedDates'] as List)
          .whereType<String>()
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }

  static Future<List<DateTime>> loadMissedDates({
    required String userId,
  }) async {
    final keys = await loadMissedDateKeys(userId: userId);
    final result = <DateTime>[];
    for (final key in keys) {
      final date = DateTime.tryParse(key);
      if (date != null) result.add(dateOnly(date));
    }
    result.sort((a, b) => a.compareTo(b));
    return result;
  }

  static Future<void> markMissed({
    required String userId,
    required DateTime date,
  }) async {
    final dates = await loadMissedDateKeys(userId: userId);
    dates.add(dateKey(date));
    await _write(userId: userId, dates: dates);
  }

  static Future<void> clearMissed({
    required String userId,
    required DateTime date,
  }) async {
    final dates = await loadMissedDateKeys(userId: userId);
    dates.remove(dateKey(date));
    await _write(userId: userId, dates: dates);
  }

  static Future<void> _write({
    required String userId,
    required Set<String> dates,
  }) async {
    try {
      final file = await _fileForUser(userId);
      if (dates.isEmpty) {
        if (await file.exists()) await file.delete();
        return;
      }
      final ordered = dates.toList()..sort();
      await file.writeAsString(
        jsonEncode({'version': 1, 'missedDates': ordered}),
        flush: true,
      );
    } catch (_) {
      // Calendar decoration is best-effort and must not block workouts.
    }
  }
}
