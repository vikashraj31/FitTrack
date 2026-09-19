import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthSyncService {
  static final Health _health = Health();

  /// Sync today's steps and sleep from Android Health Connect.
  ///
  /// Returns:
  /// {
  ///   'steps': int,
  ///   'sleepHours': double,
  /// }
  ///
  /// Returns null if Health Connect authorization fails.
  static Future<Map<String, dynamic>?> syncUser1Health() async {
    try {
      // Configure the Health plugin.
      await _health.configure();

      final types = <HealthDataType>[
        HealthDataType.STEPS,
        HealthDataType.SLEEP_ASLEEP,
      ];

      final permissions = <HealthDataAccess>[
        HealthDataAccess.READ,
        HealthDataAccess.READ,
      ];

      // Ask for Health Connect permissions.
      final authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (!authorized) {
        return null;
      }

      final now = DateTime.now();

      // Start of today.
      final midnight = DateTime(
        now.year,
        now.month,
        now.day,
      );

      // ------------------------------------------------------------
      // STEPS
      // ------------------------------------------------------------

      int steps = 0;

      try {
        final totalSteps = await _health.getTotalStepsInInterval(
          midnight,
          now,
        );

        steps = totalSteps ?? 0;
      } catch (e) {
        debugPrint('Health steps sync error: $e');
      }

      // ------------------------------------------------------------
      // SLEEP
      // ------------------------------------------------------------

      double sleepHours = 0;

      try {
        // Sleep usually starts on the previous night, so include
        // the previous 12 hours before today's midnight.
        final sleepStart = midnight.subtract(
          const Duration(hours: 12),
        );

        final sleepData = await _health.getHealthDataFromTypes(
          types: [
            HealthDataType.SLEEP_ASLEEP,
          ],
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

      // ------------------------------------------------------------
      // RESULT
      // ------------------------------------------------------------

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