import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'fitness_calculation_service.dart';

part 'database_service.g.dart';

// ============================================================
// WORKOUT SETS TABLE
// ============================================================

class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  TextColumn get exerciseName => text()();

  IntColumn get exerciseOrder =>
      integer().withDefault(const Constant(0))();

  RealColumn get weight => real()();

  IntColumn get reps => integer()();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime()();
}

// ============================================================
// EXERCISE LIBRARY TABLE
// ============================================================

class ExerciseLibrary extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  TextColumn get exerciseName => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

// ============================================================
// WORKOUT ROUTINES TABLE
// ============================================================

class WorkoutRoutines extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  DateTimeColumn get date => dateTime()();

  TextColumn get routineName => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

// ============================================================
// ROUTINE SETS TABLE
// ============================================================

class RoutineSets extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get routineId => integer()();

  TextColumn get exerciseName => text()();

  IntColumn get exerciseOrder =>
      integer().withDefault(const Constant(0))();

  IntColumn get setNumber => integer()();

  RealColumn get weight => real()();

  IntColumn get reps => integer()();
}

// ============================================================
// DAILY DATA TABLE
// ============================================================

class DailyData extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  DateTimeColumn get date => dateTime()();

  RealColumn get calories =>
      real().withDefault(const Constant(0))();

  RealColumn get calorieTarget =>
      real().withDefault(const Constant(2500))();

  IntColumn get steps =>
      integer().withDefault(const Constant(0))();

  IntColumn get stepTarget =>
      integer().withDefault(const Constant(10000))();

  RealColumn get recoveryScore =>
      real().withDefault(const Constant(0))();

  RealColumn get effortScore =>
      real().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

// ============================================================
// DIET ENTRIES TABLE
// ============================================================

class DietEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  DateTimeColumn get date => dateTime()();

  TextColumn get meal => text()();

  TextColumn get foodName => text()();

  RealColumn get plannedQuantity => real()();

  TextColumn get quantityUnit => text()();

  RealColumn get plannedCalories => real()();

  RealColumn get plannedProtein =>
      real().withDefault(const Constant(0))();

  RealColumn get actualQuantity =>
      real().withDefault(const Constant(0))();

  RealColumn get actualCalories =>
      real().withDefault(const Constant(0))();

  RealColumn get actualProtein =>
      real().withDefault(const Constant(0))();

  BoolColumn get eaten =>
      boolean().withDefault(const Constant(false))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

// ============================================================
// FOOD LIBRARY TABLE
// ============================================================

class FoodLibrary extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  TextColumn get foodName => text()();

  TextColumn get defaultMeal => text()();

  RealColumn get quantity => real()();

  TextColumn get quantityUnit => text()();

  RealColumn get calories => real()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

// ============================================================
// WEEKLY DIET PLANS TABLE
// ============================================================

class WeeklyDietPlans extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  // 1 = Monday ... 7 = Sunday
  IntColumn get dayOfWeek => integer()();

  RealColumn get targetCalories =>
      real().withDefault(const Constant(2500))();

  RealColumn get targetProtein =>
      real().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

// ============================================================
// WEEKLY DIET ITEMS TABLE
// ============================================================

class WeeklyDietItems extends Table {
  IntColumn get id => integer().autoIncrement()();

  IntColumn get planId => integer()();

  TextColumn get meal => text()();

  TextColumn get foodName => text()();

  RealColumn get quantity => real()();

  TextColumn get quantityUnit => text()();

  RealColumn get calories =>
      real().withDefault(const Constant(0))();

  RealColumn get protein =>
      real().withDefault(const Constant(0))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

// ============================================================
// EXTRA CALORIES TABLE
// ============================================================

class ExtraCaloriesEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  DateTimeColumn get date => dateTime()();

  RealColumn get calories => real()();

  // "description" conflicts with Drift's Table API.
  // Keep the actual SQLite column name as "description".
  TextColumn get extraDescription =>
      text().named('description').withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();
}

// ============================================================
// DAILY TARGETS TABLE
// ============================================================

class DailyTargets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  RealColumn get calorieTarget =>
      real().withDefault(const Constant(2500))();

  IntColumn get stepTarget =>
      integer().withDefault(const Constant(10000))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

// ============================================================
// DATABASE
// ============================================================

@DriftDatabase(
  tables: [
    WorkoutSets,
    ExerciseLibrary,
    WorkoutRoutines,
    RoutineSets,
    DailyData,
    DietEntries,
    ExtraCaloriesEntries,
    DailyTargets,
    FoodLibrary,
    WeeklyDietPlans,
    WeeklyDietItems,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  // ==========================================================
  // SCHEMA VERSION
  // ==========================================================

  @override
  int get schemaVersion => 17;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.createTable(dailyData);
            await m.createTable(dietEntries);
            await m.createTable(extraCaloriesEntries);
          }

          if (from < 5) {
            await m.createTable(dailyTargets);
          }

          if (from < 7) {
            await m.createTable(foodLibrary);
          }

          if (from < 8) {
            await m.createTable(exerciseLibrary);
          }

          if (from < 10) {
            await m.createTable(workoutRoutines);
            await m.createTable(routineSets);
          }

          if (from < 11) {
            await m.createTable(weeklyDietPlans);
            await m.createTable(weeklyDietItems);
          }

          if (from < 13) {
            await customStatement(
              'ALTER TABLE daily_targets DROP COLUMN sleep_target',
            );
          }

          if (from < 14) {
            await m.addColumn(
              workoutSets,
              workoutSets.exerciseOrder,
            );
          }

          if (from < 15) {
            await m.addColumn(
              routineSets,
              routineSets.exerciseOrder,
            );
          }

          if (from < 16) {
            await customStatement('''
              UPDATE routine_sets
              SET exercise_order = (
                SELECT COUNT(DISTINCT rs2.exercise_name) - 1
                FROM routine_sets rs2
                WHERE rs2.routine_id = routine_sets.routine_id
                  AND rs2.id <= routine_sets.id
              )
              WHERE exercise_order = 0
            ''');
          }

          if (from < 17) {
            await m.addColumn(
              dietEntries,
              dietEntries.plannedProtein,
            );

            await m.addColumn(
              dietEntries,
              dietEntries.actualProtein,
            );
          }
        },
      );

  // ==========================================================
  // FOOD LIBRARY
  // ==========================================================

  Future<List<FoodLibraryData>> getFoodLibrary({
    required String userId,
  }) async {
    return (select(foodLibrary)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.foodName),
          ]))
        .get();
  }

  Future<int> saveFoodLibraryItem({
    required String userId,
    required String foodName,
    required String defaultMeal,
    required double quantity,
    required String quantityUnit,
    required double calories,
  }) async {
    final now = DateTime.now();

    return into(foodLibrary).insert(
      FoodLibraryCompanion.insert(
        userId: userId,
        foodName: foodName,
        defaultMeal: defaultMeal,
        quantity: quantity,
        quantityUnit: quantityUnit,
        calories: calories,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<bool> updateFoodLibraryItem({
    required int id,
    required String foodName,
    required String defaultMeal,
    required double quantity,
    required String quantityUnit,
    required double calories,
  }) async {
    return (update(foodLibrary)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      FoodLibraryCompanion(
        foodName: Value(foodName),
        defaultMeal: Value(defaultMeal),
        quantity: Value(quantity),
        quantityUnit: Value(quantityUnit),
        calories: Value(calories),
        updatedAt: Value(DateTime.now()),
      ),
    ).then((rows) => rows > 0);
  }

  Future<bool> deleteFoodLibraryItem({
    required int id,
  }) async {
    return (delete(foodLibrary)
          ..where((tbl) => tbl.id.equals(id)))
        .go()
        .then((rows) => rows > 0);
  }

  // ==========================================================
  // EXERCISE LIBRARY
  // ==========================================================

  Future<List<ExerciseLibraryData>> getExerciseLibrary({
    required String userId,
  }) async {
    return (select(exerciseLibrary)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.exerciseName),
          ]))
        .get();
  }

  Future<int> saveExerciseLibraryItem({
    required String userId,
    required String exerciseName,
  }) async {
    final now = DateTime.now();

    return into(exerciseLibrary).insert(
      ExerciseLibraryCompanion.insert(
        userId: userId,
        exerciseName: exerciseName,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<bool> deleteExerciseLibraryItem({
    required int id,
  }) async {
    return (delete(exerciseLibrary)
          ..where((tbl) => tbl.id.equals(id)))
        .go()
        .then((rows) => rows > 0);
  }

  // ==========================================================
  // WORKOUT ROUTINES
  // ==========================================================

  Future<List<WorkoutRoutine>> getWorkoutRoutines({
    required String userId,
  }) async {
    return (select(workoutRoutines)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.date),
            (tbl) => OrderingTerm.asc(tbl.id),
          ]))
        .get();
  }

  Future<List<WorkoutRoutine>> getWorkoutRoutinesByDate({
    required String userId,
    required DateTime date,
  }) async {
    final selectedDate = _dateOnly(date);
    final nextDate = _nextDate(date);

    return (select(workoutRoutines)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.date.isBiggerOrEqualValue(selectedDate) &
                tbl.date.isSmallerThanValue(nextDate),
          )
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.id),
          ]))
        .get();
  }

  Future<int> saveWorkoutRoutine({
    required String userId,
    required DateTime date,
    required String routineName,
  }) async {
    final now = DateTime.now();

    return into(workoutRoutines).insert(
      WorkoutRoutinesCompanion.insert(
        userId: userId,
        date: _dateOnly(date),
        routineName: routineName,
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<int> saveRoutineSet({
    required int routineId,
    required String exerciseName,
    required int exerciseOrder,
    required int setNumber,
    required double weight,
    required int reps,
  }) async {
    return into(routineSets).insert(
      RoutineSetsCompanion.insert(
        routineId: routineId,
        exerciseName: exerciseName,
        exerciseOrder: Value(exerciseOrder),
        setNumber: setNumber,
        weight: weight,
        reps: reps,
      ),
    );
  }

  Future<bool> updateWorkoutRoutine({
    required int id,
    required DateTime date,
    required String routineName,
    required List<RoutineSet> sets,
  }) async {
    try {
      await transaction(() async {
        await (update(workoutRoutines)
              ..where((tbl) => tbl.id.equals(id)))
            .write(
          WorkoutRoutinesCompanion(
            date: Value(_dateOnly(date)),
            routineName: Value(routineName),
            updatedAt: Value(DateTime.now()),
          ),
        );

        await (delete(routineSets)
              ..where((tbl) => tbl.routineId.equals(id)))
            .go();

        for (final set in sets) {
          await into(routineSets).insert(
            RoutineSetsCompanion.insert(
              routineId: id,
              exerciseName: set.exerciseName,
              exerciseOrder: Value(set.exerciseOrder),
              setNumber: set.setNumber,
              weight: set.weight,
              reps: set.reps,
            ),
          );
        }
      });

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<RoutineSet>> getRoutineSets({
    required int routineId,
  }) async {
    return (select(routineSets)
          ..where((tbl) => tbl.routineId.equals(routineId))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.exerciseOrder),
            (tbl) => OrderingTerm.asc(tbl.setNumber),
          ]))
        .get();
  }

  Future<bool> updateRoutineSet({
    required int id,
    required double weight,
    required int reps,
  }) async {
    return (update(routineSets)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      RoutineSetsCompanion(
        weight: Value(weight),
        reps: Value(reps),
      ),
    ).then((rows) => rows > 0);
  }

  Future<bool> deleteWorkoutRoutine({
    required int id,
  }) async {
    await (delete(routineSets)
          ..where((tbl) => tbl.routineId.equals(id)))
        .go();

    final rows = await (delete(workoutRoutines)
          ..where((tbl) => tbl.id.equals(id)))
        .go();

    return rows > 0;
  }

  Future<void> deleteAllWorkoutRoutines({
    required String userId,
  }) async {
    final routines = await getWorkoutRoutines(userId: userId);

    for (final routine in routines) {
      await deleteWorkoutRoutine(id: routine.id);
    }
  }

  // ==========================================================
  // DATE HELPERS
  // ==========================================================

  DateTime _dateOnly(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  DateTime _nextDate(DateTime date) {
    return _dateOnly(date).add(
      const Duration(days: 1),
    );
  }

  // ==========================================================
  // WORKOUT - SAVE SET
  // ==========================================================

  Future<int> saveSet({
    required String userId,
    required String exerciseName,
    required double weight,
    required int reps,
    required DateTime date,
    int exerciseOrder = 0,
  }) async {
    return into(workoutSets).insert(
      WorkoutSetsCompanion.insert(
        userId: userId,
        exerciseName: exerciseName,
        exerciseOrder: Value(exerciseOrder),
        weight: weight,
        reps: reps,
        date: _dateOnly(date),
        createdAt: DateTime.now(),
      ),
    );
  }

  // ==========================================================
  // WORKOUT - UPDATE SET
  // ==========================================================

  Future<bool> updateSet({
    required int id,
    required String exerciseName,
    required double weight,
    required int reps,
  }) async {
    return (update(workoutSets)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      WorkoutSetsCompanion(
        exerciseName: Value(exerciseName),
        weight: Value(weight),
        reps: Value(reps),
      ),
    ).then((rows) => rows > 0);
  }

  // ==========================================================
  // WORKOUT - DELETE SET
  // ==========================================================

  Future<bool> deleteSet(int id) async {
    return (delete(workoutSets)
          ..where((tbl) => tbl.id.equals(id)))
        .go()
        .then((rows) => rows > 0);
  }

  // ==========================================================
  // WORKOUT - DELETE ALL SETS FOR DATE
  // ==========================================================

  Future<void> deleteAllSetsByDate({
    required String userId,
    required DateTime date,
  }) async {
    final sets = await getSetsByDate(
      userId: userId,
      date: date,
    );

    for (final set in sets) {
      await deleteSet(set.id);
    }
  }

  // ==========================================================
  // WORKOUT - GET SETS FOR DATE
  // ==========================================================

  Future<List<WorkoutSet>> getTodaySets(
    String userId,
    DateTime date,
  ) async {
    final selectedDate = _dateOnly(date);
    final nextDate = _nextDate(date);

    return (select(workoutSets)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.date.isBiggerOrEqualValue(selectedDate) &
                tbl.date.isSmallerThanValue(nextDate),
          )
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.exerciseOrder),
            (tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .get();
  }

  // ==========================================================
  // WORKOUT - EXERCISE HISTORY
  // ==========================================================

  Future<List<WorkoutSet>> getExerciseHistory({
    required String userId,
    required String exerciseName,
  }) async {
    return (select(workoutSets)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.exerciseName.equals(exerciseName),
          )
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.date),
            (tbl) => OrderingTerm.asc(tbl.createdAt),
          ]))
        .get();
  }

  // ==========================================================
  // WORKOUT - GET ALL WORKOUT DATES
  // ==========================================================

  Future<List<DateTime>> getWorkoutDates(
    String userId,
  ) async {
    final rows = await (select(workoutSets)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([
            (tbl) => OrderingTerm.desc(tbl.date),
          ]))
        .get();

    final uniqueDates = <String, DateTime>{};

    for (final row in rows) {
      final date = _dateOnly(row.date);
      final key = '${date.year}-${date.month}-${date.day}';
      uniqueDates[key] = date;
    }

    return uniqueDates.values.toList();
  }

  // ==========================================================
  // WORKOUT - UPDATE EXERCISE ORDER
  // ==========================================================

  Future<void> updateExerciseOrder({
    required String userId,
    required DateTime date,
    required Map<String, int> exerciseOrders,
  }) async {
    final sets = await getSetsByDate(
      userId: userId,
      date: date,
    );

    for (final set in sets) {
      final order = exerciseOrders[set.exerciseName];

      if (order == null) continue;

      await (update(workoutSets)
            ..where((tbl) => tbl.id.equals(set.id)))
          .write(
        WorkoutSetsCompanion(
          exerciseOrder: Value(order),
        ),
      );
    }
  }

  Future<List<WorkoutSet>> getSetsByDate({
    required String userId,
    required DateTime date,
  }) async {
    return getTodaySets(userId, date);
  }

  // ============================================================
  // DAILY TARGETS
  // ============================================================

  Future<DailyTarget?> getDailyTargets({
    required String userId,
  }) async {
    return (select(dailyTargets)
          ..where((tbl) => tbl.userId.equals(userId))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> saveDailyTargets({
    required String userId,
    required double calorieTarget,
    required int stepTarget,
  }) async {
    final existing = await getDailyTargets(
      userId: userId,
    );

    final now = DateTime.now();

    if (existing == null) {
      await into(dailyTargets).insert(
        DailyTargetsCompanion.insert(
          userId: userId,
          calorieTarget: Value(calorieTarget),
          stepTarget: Value(stepTarget),
          createdAt: now,
          updatedAt: now,
        ),
      );
    } else {
      await (update(dailyTargets)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        DailyTargetsCompanion(
          calorieTarget: Value(calorieTarget),
          stepTarget: Value(stepTarget),
          updatedAt: Value(now),
        ),
      );
    }
  }

  // ============================================================
  // DAILY DATA - GET
  // ============================================================

  Future<DailyDataData?> getDailyData({
    required String userId,
    required DateTime date,
  }) async {
    final selectedDate = _dateOnly(date);
    final nextDate = _nextDate(date);

    final data = await (select(dailyData)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.date.isBiggerOrEqualValue(selectedDate) &
                tbl.date.isSmallerThanValue(nextDate),
          )
          ..limit(1))
        .getSingleOrNull();

    if (data == null) {
      return null;
    }

    final workoutSets = await getTodaySets(
      userId,
      selectedDate,
    );

    final workoutSetMaps = workoutSets
        .map(
          (set) => <String, dynamic>{
            'weight': set.weight,
            'reps': set.reps,
          },
        )
        .toList();

    final trainingLoad =
        FitnessCalculationService.calculateTrainingLoad(
      workoutSetMaps,
    );

    final calculatedEffort =
        FitnessCalculationService.calculateEffort(
      steps: data.steps.toDouble(),
      stepTarget: data.stepTarget.toDouble(),
      trainingLoad: trainingLoad,
    );

    final calculatedRecovery =
        FitnessCalculationService.calculateRecovery(
      steps: data.steps.toDouble(),
      stepTarget: data.stepTarget.toDouble(),
      trainingLoad: trainingLoad,
    );

    if ((data.effortScore - calculatedEffort).abs() > 0.01 ||
        (data.recoveryScore - calculatedRecovery).abs() > 0.01) {
      final now = DateTime.now();

      await (update(dailyData)
            ..where((tbl) => tbl.id.equals(data.id)))
          .write(
        DailyDataCompanion(
          effortScore: Value(calculatedEffort),
          recoveryScore: Value(calculatedRecovery),
          updatedAt: Value(now),
        ),
      );

      return data.copyWith(
        effortScore: calculatedEffort,
        recoveryScore: calculatedRecovery,
        updatedAt: now,
      );
    }

    return data;
  }

  // ============================================================
  // DAILY DATA - SAVE / UPDATE
  // ============================================================

  Future<void> saveDailyData({
    required String userId,
    required DateTime date,
    required double calories,
    required double calorieTarget,
    required int steps,
    required int stepTarget,
    required double recoveryScore,
    required double effortScore,
  }) async {
    final selectedDate = _dateOnly(date);

    final existing = await getDailyData(
      userId: userId,
      date: selectedDate,
    );

    final workoutSets = await getTodaySets(
      userId,
      selectedDate,
    );

    final workoutSetMaps = workoutSets
        .map(
          (set) => <String, dynamic>{
            'weight': set.weight,
            'reps': set.reps,
          },
        )
        .toList();

    final trainingLoad =
        FitnessCalculationService.calculateTrainingLoad(
      workoutSetMaps,
    );

    final calculatedEffort =
        FitnessCalculationService.calculateEffort(
      steps: steps.toDouble(),
      stepTarget: stepTarget.toDouble(),
      trainingLoad: trainingLoad,
    );

    final calculatedRecovery =
        FitnessCalculationService.calculateRecovery(
      steps: steps.toDouble(),
      stepTarget: stepTarget.toDouble(),
      trainingLoad: trainingLoad,
    );

    if (existing == null) {
      await into(dailyData).insert(
        DailyDataCompanion.insert(
          userId: userId,
          date: selectedDate,
          calories: Value(calories),
          calorieTarget: Value(calorieTarget),
          steps: Value(steps),
          stepTarget: Value(stepTarget),
          recoveryScore: Value(calculatedRecovery),
          effortScore: Value(calculatedEffort),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
    } else {
      await (update(dailyData)
            ..where((tbl) => tbl.id.equals(existing.id)))
          .write(
        DailyDataCompanion(
          calories: Value(calories),
          calorieTarget: Value(calorieTarget),
          steps: Value(steps),
          stepTarget: Value(stepTarget),
          recoveryScore: Value(calculatedRecovery),
          effortScore: Value(calculatedEffort),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  }

  // ============================================================
  // DAILY DATA - HISTORY
  // ============================================================

  Future<List<DailyDataData>> getDailyDataHistory({
    required String userId,
    int days = 7,
  }) async {
    final today = _dateOnly(DateTime.now());
    final startDate =
        today.subtract(Duration(days: days - 1));
    final endDate =
        today.add(const Duration(days: 1));

    return (select(dailyData)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.date.isBiggerOrEqualValue(startDate) &
                tbl.date.isSmallerThanValue(endDate),
          )
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.date),
          ]))
        .get();
  }

  // ============================================================
  // DIET - GET ENTRIES
  // ============================================================

  Future<List<DietEntry>> getDietEntries({
    required String userId,
    required DateTime date,
  }) async {
    final selectedDate = _dateOnly(date);
    final nextDate = _nextDate(date);

    return (select(dietEntries)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.date.isBiggerOrEqualValue(selectedDate) &
                tbl.date.isSmallerThanValue(nextDate),
          )
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.id),
          ]))
        .get();
  }

  // ============================================================
  // DIET - SAVE ENTRY
  // ============================================================

  Future<int> saveDietEntry({
    required String userId,
    required DateTime date,
    required String meal,
    required String foodName,
    required double plannedQuantity,
    required String quantityUnit,
    required double plannedCalories,
    double plannedProtein = 0,
    required double actualQuantity,
    required double actualCalories,
    double actualProtein = 0,
    required bool eaten,
  }) async {
    final now = DateTime.now();

    return into(dietEntries).insert(
      DietEntriesCompanion.insert(
        userId: userId,
        date: _dateOnly(date),
        meal: meal,
        foodName: foodName,
        plannedQuantity: plannedQuantity,
        quantityUnit: quantityUnit,
        plannedCalories: plannedCalories,
        plannedProtein: Value(plannedProtein),
        actualQuantity: Value(actualQuantity),
        actualCalories: Value(actualCalories),
        actualProtein: Value(actualProtein),
        eaten: Value(eaten),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  // ============================================================
  // DIET - UPDATE ENTRY
  // ============================================================

  Future<bool> updateDietEntry({
    required int id,
    required double actualQuantity,
    required double actualCalories,
    required bool eaten,
    double? plannedCalories,
    double? actualProtein,
  }) async {
    return (update(dietEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      DietEntriesCompanion(
        plannedCalories: plannedCalories == null
            ? const Value.absent()
            : Value(plannedCalories),
        actualQuantity: Value(actualQuantity),
        actualCalories: Value(actualCalories),
        actualProtein: actualProtein == null
            ? const Value.absent()
            : Value(actualProtein),
        eaten: Value(eaten),
        updatedAt: Value(DateTime.now()),
      ),
    ).then((rows) => rows > 0);
  }

  // ============================================================
  // DIET - DELETE ENTRY
  // ============================================================

  Future<bool> deleteDietEntry(int id) async {
    return (delete(dietEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .go()
        .then((rows) => rows > 0);
  }

  // ============================================================
  // EXTRA CALORIES
  // ============================================================

  Future<List<ExtraCaloriesEntry>> getExtraCalories({
    required String userId,
    required DateTime date,
  }) async {
    final selectedDate = _dateOnly(date);
    final nextDate = _nextDate(date);

    return (select(extraCaloriesEntries)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.date.isBiggerOrEqualValue(selectedDate) &
                tbl.date.isSmallerThanValue(nextDate),
          )
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.id),
          ]))
        .get();
  }

  Future<int> saveExtraCalories({
    required String userId,
    required DateTime date,
    required double calories,
    required String description,
  }) async {
    return into(extraCaloriesEntries).insert(
      ExtraCaloriesEntriesCompanion.insert(
        userId: userId,
        date: _dateOnly(date),
        calories: calories,
        extraDescription: Value(description),
        createdAt: DateTime.now(),
      ),
    );
  }

  Future<bool> deleteExtraCalories(int id) async {
    return (delete(extraCaloriesEntries)
          ..where((tbl) => tbl.id.equals(id)))
        .go()
        .then((rows) => rows > 0);
  }

  // ============================================================
  // DIET - ACTUAL CALORIES TOTAL
  // ============================================================

  Future<double> getActualCalories({
    required String userId,
    required DateTime date,
  }) async {
    final dietRows = await getDietEntries(
      userId: userId,
      date: date,
    );

    final extraRows = await getExtraCalories(
      userId: userId,
      date: date,
    );

    double total = 0;

    for (final entry in dietRows) {
      if (entry.eaten) {
        total += entry.actualCalories;
      }
    }

    for (final entry in extraRows) {
      total += entry.calories;
    }

    return total;
  }

  Future<double> getPlannedCalories({
    required String userId,
    required DateTime date,
  }) async {
    final dietRows = await getDietEntries(
      userId: userId,
      date: date,
    );

    double total = 0;

    for (final entry in dietRows) {
      total += entry.plannedCalories;
    }

    return total;
  }

  // ============================================================
  // WEEKLY DIET PLANS
  // ============================================================

  Future<List<WeeklyDietPlan>> getWeeklyDietPlans({
    required String userId,
  }) async {
    return (select(weeklyDietPlans)
          ..where((tbl) => tbl.userId.equals(userId))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.dayOfWeek),
          ]))
        .get();
  }

  Future<WeeklyDietPlan?> getWeeklyDietPlan({
    required String userId,
    required int dayOfWeek,
  }) async {
    return (select(weeklyDietPlans)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.dayOfWeek.equals(dayOfWeek),
          )
          ..limit(1))
        .getSingleOrNull();
  }

  Future<int> saveWeeklyDietPlan({
    required String userId,
    required int dayOfWeek,
    required double targetCalories,
    required double targetProtein,
  }) async {
    final existing = await getWeeklyDietPlan(
      userId: userId,
      dayOfWeek: dayOfWeek,
    );

    final now = DateTime.now();

    if (existing == null) {
      return into(weeklyDietPlans).insert(
        WeeklyDietPlansCompanion.insert(
          userId: userId,
          dayOfWeek: dayOfWeek,
          targetCalories: Value(targetCalories),
          targetProtein: Value(targetProtein),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    await (update(weeklyDietPlans)
          ..where((tbl) => tbl.id.equals(existing.id)))
        .write(
      WeeklyDietPlansCompanion(
        targetCalories: Value(targetCalories),
        targetProtein: Value(targetProtein),
        updatedAt: Value(now),
      ),
    );

    return existing.id;
  }

  Future<bool> deleteWeeklyDietPlan({
    required int id,
  }) async {
    await (delete(weeklyDietItems)
          ..where((tbl) => tbl.planId.equals(id)))
        .go();

    final rows = await (delete(weeklyDietPlans)
          ..where((tbl) => tbl.id.equals(id)))
        .go();

    return rows > 0;
  }

  // ============================================================
  // WEEKLY DIET ITEMS
  // ============================================================

  Future<List<WeeklyDietItem>> getWeeklyDietItems({
    required int planId,
  }) async {
    return (select(weeklyDietItems)
          ..where((tbl) => tbl.planId.equals(planId))
          ..orderBy([
            (tbl) => OrderingTerm.asc(tbl.id),
          ]))
        .get();
  }

  Future<int> saveWeeklyDietItem({
    required int planId,
    required String meal,
    required String foodName,
    required double quantity,
    required String quantityUnit,
    required double calories,
    required double protein,
  }) async {
    final now = DateTime.now();

    return into(weeklyDietItems).insert(
      WeeklyDietItemsCompanion.insert(
        planId: planId,
        meal: meal,
        foodName: foodName,
        quantity: quantity,
        quantityUnit: quantityUnit,
        calories: Value(calories),
        protein: Value(protein),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  Future<bool> updateWeeklyDietItem({
    required int id,
    required String meal,
    required String foodName,
    required double quantity,
    required String quantityUnit,
    required double calories,
    required double protein,
  }) async {
    return (update(weeklyDietItems)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      WeeklyDietItemsCompanion(
        meal: Value(meal),
        foodName: Value(foodName),
        quantity: Value(quantity),
        quantityUnit: Value(quantityUnit),
        calories: Value(calories),
        protein: Value(protein),
        updatedAt: Value(DateTime.now()),
      ),
    ).then((rows) => rows > 0);
  }

  Future<bool> deleteWeeklyDietItem({
    required int id,
  }) async {
    return (delete(weeklyDietItems)
          ..where((tbl) => tbl.id.equals(id)))
        .go()
        .then((rows) => rows > 0);
  }

  Future<void> deleteAllWeeklyDietPlans({
    required String userId,
  }) async {
    final plans = await getWeeklyDietPlans(
      userId: userId,
    );

    for (final plan in plans) {
      await (delete(weeklyDietItems)
            ..where((tbl) => tbl.planId.equals(plan.id)))
          .go();
    }

    await (delete(weeklyDietPlans)
          ..where((tbl) => tbl.userId.equals(userId)))
        .go();
  }
}

// ============================================================
// EXTRA CALORIES DESCRIPTION COMPATIBILITY
// ============================================================

extension ExtraCaloriesEntryDescription on ExtraCaloriesEntry {
  String get description => extraDescription;
}

// ============================================================
// DATABASE CONNECTION
// ============================================================

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final directory =
        await getApplicationDocumentsDirectory();

    final file = File(
      p.join(
        directory.path,
        'fittrack.sqlite',
      ),
    );

    return NativeDatabase.createInBackground(file);
  });
}