import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database_service.g.dart';

// ============================================================
// USER 2 - WORKOUT SETS
// ============================================================

class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  TextColumn get exerciseName => text()();

  RealColumn get weight => real()();

  IntColumn get reps => integer()();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime()();
}

// ============================================================
// USER 1 - DAILY DATA
// ============================================================

class DailyData extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  DateTimeColumn get date => dateTime()();

  // Calories
  RealColumn get calories => real().withDefault(
        const Constant(0),
      )();

  RealColumn get calorieTarget => real().withDefault(
        const Constant(0),
      )();

  // Steps
  IntColumn get steps => integer().withDefault(
        const Constant(0),
      )();

  IntColumn get stepTarget => integer().withDefault(
        const Constant(0),
      )();

  // Sleep
  RealColumn get sleepHours => real().withDefault(
        const Constant(0),
      )();

  // Recovery
  RealColumn get recoveryScore => real().withDefault(
        const Constant(0),
      )();

  // Effort
  RealColumn get effortScore => real().withDefault(
        const Constant(0),
      )();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

// ============================================================
// USER 1 - DIET
// ============================================================

class DietEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  DateTimeColumn get date => dateTime()();

  // breakfast / lunch / evening / dinner
  TextColumn get meal => text()();

  TextColumn get foodName => text()();

  // Planned quantity
  RealColumn get plannedQuantity => real().withDefault(
        const Constant(0),
      )();

  TextColumn get quantityUnit => text().withDefault(
        const Constant(''),
      )();

  // Planned calories
  RealColumn get plannedCalories => real().withDefault(
        const Constant(0),
      )();

  // Actual quantity eaten
  RealColumn get actualQuantity => real().withDefault(
        const Constant(0),
      )();

  // Actual calories consumed
  RealColumn get actualCalories => real().withDefault(
        const Constant(0),
      )();

  // Fully eaten or not
  BoolColumn get eaten => boolean().withDefault(
        const Constant(false),
      )();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();
}

// ============================================================
// USER 1 - EXTRA CALORIES
// ============================================================

class ExtraCaloriesEntries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  DateTimeColumn get date => dateTime()();

  RealColumn get calories => real()();

  TextColumn get description => text().withDefault(
        const Constant(''),
      )();

  DateTimeColumn get createdAt => dateTime()();
}

// ============================================================
// DATABASE
// ============================================================

@DriftDatabase(
  tables: [
    WorkoutSets,
    DailyData,
    DietEntries,
    ExtraCaloriesEntries,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  // ==========================================================
  // USER 2 - SAVE SET
  // ==========================================================

  Future<int> saveSet({
    required String userId,
    required String exerciseName,
    required double weight,
    required int reps,
    required DateTime date,
  }) {
    return into(workoutSets).insert(
      WorkoutSetsCompanion.insert(
        userId: userId,
        exerciseName: exerciseName,
        weight: weight,
        reps: reps,
        date: date,
        createdAt: DateTime.now(),
      ),
    );
  }

  // ==========================================================
  // USER 2 - UPDATE SET
  // ==========================================================

  Future<bool> updateSet({
    required int id,
    required String exerciseName,
    required double weight,
    required int reps,
  }) {
    return (update(workoutSets)
          ..where(
            (tbl) => tbl.id.equals(id),
          ))
        .write(
      WorkoutSetsCompanion(
        exerciseName: Value(exerciseName),
        weight: Value(weight),
        reps: Value(reps),
      ),
    )
        .then(
      (rowsUpdated) => rowsUpdated > 0,
    );
  }

  // ==========================================================
  // USER 2 - DELETE SET
  // ==========================================================

  Future<int> deleteSet(int id) {
    return (delete(workoutSets)
          ..where(
            (tbl) => tbl.id.equals(id),
          ))
        .go();
  }

  // ==========================================================
  // USER 2 - TODAY / SELECTED DATE
  // ==========================================================

  Future<List<WorkoutSet>> getTodaySets(
    String userId,
    DateTime date,
  ) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final end = start.add(
      const Duration(days: 1),
    );

    return (select(workoutSets)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.date.isBetweenValues(
                  start,
                  end,
                ),
          )
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                ),
          ]))
        .get();
  }

  // ==========================================================
  // USER 2 - EXERCISE HISTORY
  // ==========================================================

  Future<List<WorkoutSet>> getExerciseHistory({
    required String userId,
    required String exerciseName,
  }) {
    return (select(workoutSets)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.exerciseName.equals(
                  exerciseName,
                ),
          )
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.date,
                  mode: OrderingMode.desc,
                ),
            (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  // ==========================================================
  // USER 2 - ALL WORKOUT DATES
  // ==========================================================

  Future<List<DateTime>> getWorkoutDates(
    String userId,
  ) async {
    final sets = await (select(workoutSets)
          ..where(
            (tbl) => tbl.userId.equals(userId),
          )
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.date,
                  mode: OrderingMode.desc,
                ),
          ]))
        .get();

    final uniqueDates = <String, DateTime>{};

    for (final set in sets) {
      final dateOnly = DateTime(
        set.date.year,
        set.date.month,
        set.date.day,
      );

      final key =
          '${dateOnly.year}-${dateOnly.month}-${dateOnly.day}';

      uniqueDates[key] = dateOnly;
    }

    return uniqueDates.values.toList();
  }

  // ==========================================================
  // USER 2 - SETS BY SELECTED DATE
  // ==========================================================

  Future<List<WorkoutSet>> getSetsByDate({
    required String userId,
    required DateTime date,
  }) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final end = start.add(
      const Duration(days: 1),
    );

    return (select(workoutSets)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.date.isBetweenValues(
                  start,
                  end,
                ),
          )
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  // ==========================================================
  // USER 1 - GET DAILY DATA
  // ==========================================================

  Future<DailyDataData?> getDailyData({
    required String userId,
    required DateTime date,
  }) async {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final end = start.add(
      const Duration(days: 1),
    );

    final query = select(dailyData)
      ..where(
        (tbl) =>
            tbl.userId.equals(userId) &
            tbl.date.isBetweenValues(
              start,
              end,
            ),
      )
      ..limit(1);

    return query.getSingleOrNull();
  }

  // ==========================================================
  // USER 1 - SAVE / UPDATE DAILY DATA
  // ==========================================================

  Future<void> saveDailyData({
    required String userId,
    required DateTime date,
    double? calories,
    double? calorieTarget,
    int? steps,
    int? stepTarget,
    double? sleepHours,
    double? recoveryScore,
    double? effortScore,
  }) async {
    final existing = await getDailyData(
      userId: userId,
      date: date,
    );

    if (existing == null) {
      await into(dailyData).insert(
        DailyDataCompanion.insert(
          userId: userId,
          date: DateTime(
            date.year,
            date.month,
            date.day,
          ),
          calories: Value(calories ?? 0),
          calorieTarget: Value(
            calorieTarget ?? 0,
          ),
          steps: Value(steps ?? 0),
          stepTarget: Value(stepTarget ?? 0),
          sleepHours: Value(sleepHours ?? 0),
          recoveryScore: Value(
            recoveryScore ?? 0,
          ),
          effortScore: Value(
            effortScore ?? 0,
          ),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      return;
    }

    await (update(dailyData)
          ..where(
            (tbl) => tbl.id.equals(existing.id),
          ))
        .write(
      DailyDataCompanion(
        calories: calories == null
            ? const Value.absent()
            : Value(calories),
        calorieTarget: calorieTarget == null
            ? const Value.absent()
            : Value(calorieTarget),
        steps: steps == null
            ? const Value.absent()
            : Value(steps),
        stepTarget: stepTarget == null
            ? const Value.absent()
            : Value(stepTarget),
        sleepHours: sleepHours == null
            ? const Value.absent()
            : Value(sleepHours),
        recoveryScore: recoveryScore == null
            ? const Value.absent()
            : Value(recoveryScore),
        effortScore: effortScore == null
            ? const Value.absent()
            : Value(effortScore),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ==========================================================
  // USER 1 - GET DIET FOR DATE
  // ==========================================================

  Future<List<DietEntry>> getDietEntries({
    required String userId,
    required DateTime date,
  }) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final end = start.add(
      const Duration(days: 1),
    );

    return (select(dietEntries)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.date.isBetweenValues(
                  start,
                  end,
                ),
          )
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  // ==========================================================
  // USER 1 - SAVE DIET ENTRY
  // ==========================================================

  Future<int> saveDietEntry({
    required String userId,
    required DateTime date,
    required String meal,
    required String foodName,
    required double plannedQuantity,
    required String quantityUnit,
    required double plannedCalories,
    double actualQuantity = 0,
    double actualCalories = 0,
    bool eaten = false,
  }) {
    return into(dietEntries).insert(
      DietEntriesCompanion.insert(
        userId: userId,
        date: DateTime(
          date.year,
          date.month,
          date.day,
        ),
        meal: meal,
        foodName: foodName,
        plannedQuantity: Value(
          plannedQuantity,
        ),
        quantityUnit: Value(
          quantityUnit,
        ),
        plannedCalories: Value(
          plannedCalories,
        ),
        actualQuantity: Value(
          actualQuantity,
        ),
        actualCalories: Value(
          actualCalories,
        ),
        eaten: Value(eaten),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  // ==========================================================
  // USER 1 - UPDATE DIET ENTRY
  // ==========================================================

  Future<bool> updateDietEntry({
    required int id,
    double? actualQuantity,
    double? actualCalories,
    bool? eaten,
  }) {
    return (update(dietEntries)
          ..where(
            (tbl) => tbl.id.equals(id),
          ))
        .write(
      DietEntriesCompanion(
        actualQuantity: actualQuantity == null
            ? const Value.absent()
            : Value(actualQuantity),
        actualCalories: actualCalories == null
            ? const Value.absent()
            : Value(actualCalories),
        eaten: eaten == null
            ? const Value.absent()
            : Value(eaten),
        updatedAt: Value(DateTime.now()),
      ),
    )
        .then(
      (rowsUpdated) => rowsUpdated > 0,
    );
  }

  // ==========================================================
  // USER 1 - DELETE DIET ENTRY
  // ==========================================================

  Future<int> deleteDietEntry(int id) {
    return (delete(dietEntries)
          ..where(
            (tbl) => tbl.id.equals(id),
          ))
        .go();
  }

  // ==========================================================
  // USER 1 - GET EXTRA CALORIES
  // ==========================================================

  Future<List<ExtraCaloriesEntry>>
      getExtraCalories({
    required String userId,
    required DateTime date,
  }) {
    final start = DateTime(
      date.year,
      date.month,
      date.day,
    );

    final end = start.add(
      const Duration(days: 1),
    );

    return (select(extraCaloriesEntries)
          ..where(
            (tbl) =>
                tbl.userId.equals(userId) &
                tbl.date.isBetweenValues(
                  start,
                  end,
                ),
          )
          ..orderBy([
            (tbl) => OrderingTerm(
                  expression: tbl.createdAt,
                  mode: OrderingMode.asc,
                ),
          ]))
        .get();
  }

  // ==========================================================
  // USER 1 - SAVE EXTRA CALORIES
  // ==========================================================

  Future<int> saveExtraCalories({
    required String userId,
    required DateTime date,
    required double calories,
    String description = '',
  }) {
    return into(extraCaloriesEntries).insert(
      ExtraCaloriesEntriesCompanion.insert(
        userId: userId,
        date: DateTime(
          date.year,
          date.month,
          date.day,
        ),
        calories: calories,
        description: Value(description),
        createdAt: DateTime.now(),
      ),
    );
  }

  // ==========================================================
  // USER 1 - DELETE EXTRA CALORIES
  // ==========================================================

  Future<int> deleteExtraCalories(int id) {
    return (delete(extraCaloriesEntries)
          ..where(
            (tbl) => tbl.id.equals(id),
          ))
        .go();
  }

  // ==========================================================
  // USER 1 - ACTUAL CALORIES FOR A DATE
  // ==========================================================

  Future<double> getActualCalories({
    required String userId,
    required DateTime date,
  }) async {
    final diet = await getDietEntries(
      userId: userId,
      date: date,
    );

    final extra = await getExtraCalories(
      userId: userId,
      date: date,
    );

    double total = 0;

    for (final entry in diet) {
      total += entry.actualCalories;
    }

    for (final entry in extra) {
      total += entry.calories;
    }

    return total;
  }

  // ==========================================================
  // DATABASE MIGRATION
  // ==========================================================

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },

      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 2) {
          await m.createTable(dailyData);
          await m.createTable(dietEntries);
          await m.createTable(
            extraCaloriesEntries,
          );
        }
      },
    );
  }
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

    return NativeDatabase.createInBackground(
      file,
    );
  });
}