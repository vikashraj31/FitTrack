import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database_service.g.dart';

class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get userId => text()();

  TextColumn get exerciseName => text()();

  RealColumn get weight => real()();

  IntColumn get reps => integer()();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime()();
}

@DriftDatabase(tables: [WorkoutSets])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // =========================
  // SAVE SET
  // =========================

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

  // =========================
  // UPDATE SET
  // =========================

  Future<bool> updateSet({
    required int id,
    required String exerciseName,
    required double weight,
    required int reps,
  }) {
    return (update(workoutSets)
          ..where((tbl) => tbl.id.equals(id)))
        .write(
      WorkoutSetsCompanion(
        exerciseName: Value(exerciseName),
        weight: Value(weight),
        reps: Value(reps),
      ),
    )
    .then((rowsUpdated) => rowsUpdated > 0);
  }

  // =========================
  // DELETE SET
  // =========================

  Future<int> deleteSet(int id) {
    return (delete(workoutSets)
          ..where((tbl) => tbl.id.equals(id)))
        .go();
  }

  // =========================
  // TODAY / SELECTED DATE
  // =========================

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

  // =========================
  // EXERCISE HISTORY
  // =========================

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

  // =========================
  // ALL WORKOUT DATES
  // =========================

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

  // =========================
  // SETS BY SELECTED DATE
  // =========================

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