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
    ];

    final permissions = <HealthDataAccess>[
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

  Future<HealthSummary> getTodayHealthData() async {
    await configure();

    final steps = await getTodaySteps();

    return HealthSummary(
      steps: steps,
    );
  }
}

class HealthSummary {
  final int steps;

  const HealthSummary({
    required this.steps,
  });
}