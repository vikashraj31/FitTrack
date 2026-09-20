import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

class HealthSyncService {
  static final Health _health = Health();

  static bool _configured = false;

  static Future<void> _configure() async {
    if (_configured) return;

    await _health.configure();
    _configured = true;
  }

  static Future<bool> _ensureAuthorization() async {
    await _configure();

    final types = <HealthDataType>[
      HealthDataType.STEPS,
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_ASLEEP,
    ];

    final permissions = <HealthDataAccess>[
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    try {
      final existingPermissions = await _health.hasPermissions(
        types,
        permissions: permissions,
      );

      if (existingPermissions == true) {
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

      return authorized;
    } catch (e) {
      debugPrint('Health authorization request error: $e');
      return false;
    }
  }

  // ============================================================
  // STEPS
  // ============================================================

  static Future<int> getTodaySteps() async {
    try {
      if (!await _ensureAuthorization()) {
        debugPrint('Health authorization unavailable for steps.');
        return 0;
      }

      final now = DateTime.now();
      final midnight = DateTime(
        now.year,
        now.month,
        now.day,
      );

      // First try Health Connect's aggregated step total.
      try {
        final totalSteps = await _health.getTotalStepsInInterval(
          midnight,
          now,
        );

        final steps = totalSteps ?? 0;

        debugPrint(
          'Health Connect aggregated steps: $steps',
        );

        if (steps > 0) {
          return steps;
        }
      } catch (e) {
        debugPrint(
          'Health Connect aggregated step read error: $e',
        );
      }

      // Fallback: read the actual Steps records.
      try {
        final stepData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.STEPS],
          startTime: midnight,
          endTime: now,
        );

        double total = 0;

        for (final point in stepData) {
          final value = point.value;

          if (value is NumericHealthValue) {
            total += value.numericValue;
          }
        }

        final steps = total.round();

        debugPrint(
          'Health Connect raw step records: $steps',
        );

        return steps;
      } catch (e) {
        debugPrint(
          'Health Connect raw step read error: $e',
        );
      }

      return 0;
    } catch (e) {
      debugPrint('Health steps read error: $e');
      return 0;
    }
  }

  // ============================================================
  // SLEEP
  // ============================================================

  static Future<double> getSleepHours() async {
    try {
      if (!await _ensureAuthorization()) {
        debugPrint('Health authorization unavailable for sleep.');
        return 0;
      }

      final now = DateTime.now();

      // Cover the previous evening + overnight sleep.
      final sleepStart = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(
        const Duration(hours: 18),
      );

      // ----------------------------------------------------------
      // FIRST: Read complete sleep sessions.
      // ----------------------------------------------------------

      try {
        final sessionData = await _health.getHealthDataFromTypes(
          types: [HealthDataType.SLEEP_SESSION],
          startTime: sleepStart,
          endTime: now,
        );

        double sleepMinutes = 0;

        for (final point in sessionData) {
          final value = point.value;

          if (value is NumericHealthValue) {
            sleepMinutes += value.numericValue;
          }
        }

        if (sleepMinutes > 0) {
          final sleepHours = sleepMinutes / 60.0;

          debugPrint(
            'Health Connect sleep sessions: '
            '${sleepHours.toStringAsFixed(2)} hours',
          );

          return sleepHours;
        }
      } catch (e) {
        debugPrint(
          'Health sleep session read error: $e',
        );
      }

      // ----------------------------------------------------------
      // FALLBACK: Read asleep-stage records.
      // ----------------------------------------------------------

      try {
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

        final sleepHours = sleepMinutes / 60.0;

        debugPrint(
          'Health Connect asleep records: '
          '${sleepHours.toStringAsFixed(2)} hours',
        );

        return sleepHours;
      } catch (e) {
        debugPrint(
          'Health asleep record read error: $e',
        );
      }

      return 0;
    } catch (e) {
      debugPrint('Health sleep read error: $e');
      return 0;
    }
  }

  // ============================================================
  // USER 1 HEALTH SYNC
  // ============================================================

  static Future<Map<String, dynamic>?> syncUser1Health() async {
    try {
      if (!await _ensureAuthorization()) {
        debugPrint(
          'Health Connect authorization not available.',
        );

        return null;
      }

      final steps = await getTodaySteps();
      final sleepHours = await getSleepHours();

      debugPrint(
        'FitTrack Health Sync → '
        'steps=$steps, '
        'sleep=${sleepHours.toStringAsFixed(2)}h',
      );

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