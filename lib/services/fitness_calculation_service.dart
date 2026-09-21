class FitnessCalculationService {
  /// Calculates training load from workout sets.
  ///
  /// Training Load = sum of (weight × reps)
  static double calculateTrainingLoad(
    List<Map<String, dynamic>> workoutSets,
  ) {
    double totalLoad = 0;

    for (final set in workoutSets) {
      final weight = (set['weight'] as num?)?.toDouble() ?? 0;
      final reps = (set['reps'] as num?)?.toDouble() ?? 0;

      totalLoad += weight * reps;
    }

    return totalLoad;
  }

  /// Converts a value into a percentage of its target.
  static double calculateTargetPercentage({
    required double value,
    required double target,
  }) {
    if (target <= 0) return 0;

    return (value / target) * 100;
  }

  /// Calculates Effort Score.
  ///
  /// Steps contribute 40%.
  /// Training load contributes 60%.
  static double calculateEffort({
    required double steps,
    required double stepTarget,
    required double trainingLoad,
  }) {
    final stepPercent = calculateTargetPercentage(
      value: steps,
      target: stepTarget,
    );

    // 10,000 total training load is treated as 100%.
    final trainingPercent = calculateTargetPercentage(
      value: trainingLoad,
      target: 10000,
    );

    final effort =
        (stepPercent * 0.40) +
        (trainingPercent * 0.60);

    return effort.clamp(0, 100).toDouble();
  }

  /// Calculates Recovery Score.
  ///
  /// Activity recovery contributes 50%.
  /// Training recovery contributes 50%.
  static double calculateRecovery({
    required double steps,
    required double stepTarget,
    required double trainingLoad,
  }) {
    final stepPercent = calculateTargetPercentage(
      value: steps,
      target: stepTarget,
    );

    // Normal activity = full activity recovery.
    double activityRecovery = 100;

    // Excessive steps reduce recovery slightly.
    if (stepPercent > 100) {
      final excess = stepPercent - 100;
      activityRecovery -= excess * 0.30;
    }

    activityRecovery =
        activityRecovery.clamp(0, 100).toDouble();

    // Higher training load reduces training recovery.
    final trainingPercent = calculateTargetPercentage(
      value: trainingLoad,
      target: 10000,
    );

    final trainingRecovery =
        (100 - (trainingPercent * 0.65))
            .clamp(0, 100)
            .toDouble();

    // Recovery is now completely independent of sleep.
    final recovery =
        (activityRecovery * 0.50) +
        (trainingRecovery * 0.50);

    return recovery.clamp(0, 100).toDouble();
  }
}