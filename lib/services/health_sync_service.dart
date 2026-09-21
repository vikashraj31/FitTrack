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
    ];

    final permissions = <HealthDataAccess>[
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

      try {
        final totalSteps = await _health.getTotalStepsInInterval(
          midnight,
          now,
        );

        final steps = totalSteps ?? 0;

        debugPrint(
          'Health Connect aggregated steps: $steps',
        );

        return steps;
      } catch (e) {
        debugPrint(
          'Health Connect aggregated step read error: $e',
        );
        return 0;
      }
    } catch (e) {
      debugPrint('Health steps read error: $e');
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

      debugPrint(
        'FitTrack Health Sync → steps=$steps',
      );

      return {
        'steps': steps,
      };
    } catch (e) {
      debugPrint('Health sync error: $e');
      return null;
    }
  }
}