import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthSyncService {
  static final Health _health = Health();

  static bool _configured = false;
  static bool _authorized = false;

  static Future<void> _configure() async {
    if (_configured) return;
    await _health.configure();
    _configured = true;
  }

  static Future<bool> _ensureAuthorization() async {
    await _configure();

    if (_authorized) return true;

    final types = <HealthDataType>[
      HealthDataType.STEPS,
      HealthDataType.SLEEP_ASLEEP,
    ];

    final permissions = <HealthDataAccess>[
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    try {
      final existingPermissions = await _health.hasPermissions(
        types,
        permissions: permissions,
      );

      if (existingPermissions == true) {
        _authorized = true;
        return true;
      }
    } catch (e) {
      debugPrint('Health permission check error: $e');
    }

    try {
      final authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      _authorized = authorized;
      return authorized;
    } catch (e) {
      debugPrint('Health authorization request error: $e');
      return false;
    }
  }

  /// Reads the latest available step total from Health Connect.
  ///
  /// Google Fit can synchronize its step data into Health Connect.
  /// FitTrack does not count steps itself.
  static Future<int> getTodaySteps() async {
    try {
      if (!await _ensureAuthorization()) {
        return 0;
      }

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final totalSteps = await _health.getTotalStepsInInterval(
        midnight,
        now,
      );

      final steps = totalSteps ?? 0;

      debugPrint('Health Connect / Google Fit steps: $steps');

      return steps;
    } catch (e) {
      debugPrint('Health steps read error: $e');
      return 0;
    }
  }

  static Future<Map<String, dynamic>?> syncUser1Health() async {
    try {
      if (!await _ensureAuthorization()) {
        debugPrint('Health Connect authorization not available.');
        return null;
      }

      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day);

      final steps = await getTodaySteps();

      double sleepHours = 0;

      try {
        final sleepStart = midnight.subtract(const Duration(hours: 12));

        final sleepData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_ASLEEP],
          startTime: sleepStart,
          endTime: now,
        );

        double sleepMinutes = 0;

        for (final point in sleepData) {
          final value = point.value;

          if (value is NumericHealthValue) {
            sleepMinutes += value.numericValue;
          }
        }

        sleepHours = sleepMinutes / 60.0;
      } catch (e) {
        debugPrint('Health sleep sync error: $e');
      }

      return {
        'steps': steps,
        'sleepHours': sleepHours,
      };
    } catch (e) {
      debugPrint('Health sync error: $e');
      return null;
    }
  }
}
