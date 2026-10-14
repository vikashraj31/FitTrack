import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Stores display preferences separately from workout history.
/// This intentionally does not change the Drift schema (schema version 14).
class ExercisePreferenceStorage {
  static Future<File> _fileForUser(String userId) async {
    final directory = await getApplicationDocumentsDirectory();
    final safeUserId = userId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return File(
      '${directory.path}${Platform.pathSeparator}fittrack_exercise_preferences_$safeUserId.json',
    );
  }

  static String exerciseKey(String exerciseName) =>
      exerciseName.trim().toLowerCase();

  static String normalizeLabel(String value) {
    var label = value.trim();
    if (label.isEmpty) return '';
    label = label.replaceAll(RegExp(r'\s*[xX×]\s*'), ' × ');
    label = label.replaceAll(RegExp(r'\s*-\s*'), '–');
    label = label.replaceAll(RegExp(r'\s+'), ' ');
    return label;
  }

  static Future<Map<String, String>> load({required String userId}) async {
    try {
      final file = await _fileForUser(userId);
      if (!await file.exists()) return {};

      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! Map) return {};
      final raw = decoded['preferences'];
      if (raw is! Map) return {};

      final preferences = <String, String>{};
      for (final entry in raw.entries) {
        final key = exerciseKey(entry.key.toString());
        final value = entry.value?.toString().trim() ?? '';
        if (key.isNotEmpty && value.isNotEmpty) {
          preferences[key] = normalizeLabel(value);
        }
      }
      return preferences;
    } catch (_) {
      return {};
    }
  }

  static Future<void> saveAll({
    required String userId,
    required Map<String, String> preferences,
  }) async {
    try {
      final cleaned = <String, String>{};
      for (final entry in preferences.entries) {
        final key = exerciseKey(entry.key);
        final value = normalizeLabel(entry.value);
        if (key.isNotEmpty && value.isNotEmpty) cleaned[key] = value;
      }

      final file = await _fileForUser(userId);
      if (cleaned.isEmpty) {
        if (await file.exists()) await file.delete();
        return;
      }

      await file.writeAsString(
        jsonEncode({'version': 1, 'preferences': cleaned}),
        flush: true,
      );
    } catch (_) {
      // A display preference must never prevent a workout from being saved.
    }
  }
}
