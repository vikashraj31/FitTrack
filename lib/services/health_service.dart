import 'package:health/health.dart';

class HealthService {
  HealthService._();

  static final HealthService instance = HealthService._();

  final Health _health = Health();

  bool _configured = false;

  Future<void> configure() async {
    if (_configured) return;

    await _health.configure();
    _configured = true;
  }

  Future<bool> requestPermissions() async {
    await configure();

    final types = <HealthDataType>[
      HealthDataType.STEPS,
      HealthDataType.SLEEP_ASLEEP,
    ];

    final permissions = <HealthDataAccess>[
      HealthDataAccess.READ,
      HealthDataAccess.READ,
    ];

    return await _health.requestAuthorization(
      types,
      permissions: permissions,
    );
  }

  Future<int> getTodaySteps() async {
    await configure();

    final now = DateTime.now();
    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final steps = await _health.getTotalStepsInInterval(
      startOfDay,
      now,
    );

    return steps ?? 0;
  }

  Future<double> getLastNightSleepHours() async {
    await configure();

    final now = DateTime.now();

    // Look back 24 hours so that last night's sleep
    // is included even when the sleep session crosses midnight.
    final startTime = now.subtract(
      const Duration(hours: 24),
    );

    final data = await _health.getHealthDataFromTypes(
      types: [
        HealthDataType.SLEEP_ASLEEP,
      ],
      startTime: startTime,
      endTime: now,
    );

    double totalMinutes = 0;

    for (final point in data) {
      if (point.type == HealthDataType.SLEEP_ASLEEP) {
        final duration = point.dateTo.difference(point.dateFrom);

        if (duration.inMinutes > 0) {
          totalMinutes += duration.inMinutes;
        }
      }
    }

    return totalMinutes / 60.0;
  }

  Future<HealthSummary> getTodayHealthData() async {
    await configure();

    final steps = await getTodaySteps();
    final sleepHours = await getLastNightSleepHours();

    return HealthSummary(
      steps: steps,
      sleepHours: sleepHours,
    );
  }
}

class HealthSummary {
  final int steps;
  final double sleepHours;

  const HealthSummary({
    required this.steps,
    required this.sleepHours,
  });
}