class FitnessCalculationService {
  static double _clamp(double value, [double min = 0, double max = 100]) {
    return value.clamp(min, max).toDouble();
  }

  /// Training load = total external volume for the recorded sets.
  static double calculateTrainingLoad(
    List<Map<String, dynamic>> workoutSets,
  ) {
    double total = 0;

    for (final set in workoutSets) {
      final weight = (set['weight'] as num?)?.toDouble() ?? 0;
      final reps = (set['reps'] as num?)?.toDouble() ?? 0;

      if (weight > 0 && reps > 0) {
        total += weight * reps;
      }
    }

    return total;
  }

  /// EFFORT
  /// 25% steps + 20% diet adherence + 55% workout.
  /// Workout is normalized against the user's personal 30-day average.
  static double calculateEffort({
    required double steps,
    required double stepTarget,
    double dietScore = 0,
    required double trainingLoad,
    double trainingReference = 10000,
  }) {
    if (stepTarget <= 0 || trainingReference <= 0) return 0;

    final stepScore = _clamp((steps / stepTarget) * 100);
    final workoutScore = _clamp(
      (trainingLoad / trainingReference) * 100,
    );
    final foodScore = _clamp(dietScore);

    return _clamp(
      (stepScore * 0.25) +
          (foodScore * 0.20) +
          (workoutScore * 0.55),
    );
  }

  /// RECOVERY — sleep is intentionally NOT used anywhere.
  ///
  /// 50% recent training recovery
  /// 30% activity recovery
  /// 20% rest recovery
  ///
  /// recentTrainingLoads = [today, yesterday, 2-days-ago]
  static double calculateRecovery({
    required double steps,
    required double stepTarget,
    List<double>? recentTrainingLoads,
    double trainingReference = 10000,
    int recentWorkoutDays = 0,
    double? trainingLoad,
    double? sleepHours, // Kept only for source compatibility; never used.
  }) {
    recentTrainingLoads ??= [trainingLoad ?? 0];
    if (stepTarget <= 0 || trainingReference <= 0) return 0;

    // Recent training load: today 50%, yesterday 30%, two days ago 20%.
    final today = recentTrainingLoads.isNotEmpty
        ? recentTrainingLoads[0]
        : 0;
    final yesterday = recentTrainingLoads.length > 1
        ? recentTrainingLoads[1]
        : 0;
    final twoDaysAgo = recentTrainingLoads.length > 2
        ? recentTrainingLoads[2]
        : 0;

    final weightedLoad =
        (today * 0.50) +
        (yesterday * 0.30) +
        (twoDaysAgo * 0.20);

    final recentTrainingScore = _clamp(
      (weightedLoad / trainingReference) * 100,
    );

    final trainingRecovery = _clamp(
      100 - (recentTrainingScore * 0.60),
    );

    // Normal activity up to the step target does not reduce recovery.
    final stepRatio = steps / stepTarget;
    final activityRecovery = _clamp(
      100 - ((stepRatio - 1).clamp(0, 1) * 30),
      70,
      100,
    );

    // More consecutive workout days = less recovery.
    final restRecovery = switch (recentWorkoutDays) {
      0 => 100.0,
      1 => 90.0,
      2 => 75.0,
      _ => 55.0,
    };

    return _clamp(
      (trainingRecovery * 0.50) +
          (activityRecovery * 0.30) +
          (restRecovery * 0.20),
    );
  }
}
