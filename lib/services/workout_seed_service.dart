import 'database_service.dart';

class WorkoutSeedService {
  static Future<void> seedFitNotesWorkouts(
    AppDatabase database,
  ) async {
    // ==========================================================
    // FITNOTES WORKOUT DATA
    // ==========================================================

    final workouts = <DateTime, List<Map<String, dynamic>>>{
      // ==========================================================
      // MONDAY — 7 SEP 2026
      // ==========================================================

      DateTime(2026, 9, 7): [
        {
          'exercise': 'Lat Pulldown',
          'sets': [
            [45.0, 10],
            [45.0, 9],
            [45.0, 8],
            [45.0, 7],
          ],
        },
        {
          'exercise': 'Chest Supported Row',
          'sets': [
            [35.0, 10],
            [35.0, 10],
            [35.0, 10],
          ],
        },
        {
          'exercise': 'Close Grip Seated Cable Row',
          'sets': [
            [40.0, 12],
            [40.0, 11],
            [40.0, 10],
          ],
        },
        {
          'exercise': 'Rear Delt Fly Machine',
          'sets': [
            [20.0, 15],
            [20.0, 0],
            [20.0, 0],
          ],
        },
        {
          'exercise': 'EZ Bar Curl',
          'sets': [
            [35.0, 10],
            [35.0, 10],
            [35.0, 8],
          ],
        },
        {
          'exercise': 'Incline Dumbbell Curl',
          'sets': [
            [7.5, 10],
            [7.5, 10],
            [7.5, 10],
          ],
        },
        {
          'exercise': 'Reverse Curl',
          'sets': [
            [20.0, 12],
            [20.0, 12],
            [20.0, 10],
          ],
        },
      ],

      // ==========================================================
      // TUESDAY — 8 SEP 2026
      // ==========================================================

      DateTime(2026, 9, 8): [
        {
          'exercise': 'Incline Smith Machine Press',
          'sets': [
            [25.0, 10],
            [25.0, 10],
            [25.0, 8],
            [25.0, 7],
          ],
        },
        {
          'exercise': 'Bench Press',
          'sets': [
            [25.0, 8],
            [25.0, 7],
            [25.0, 6],
            [25.0, 6],
          ],
        },
        {
          'exercise': 'Pec Deck',
          'sets': [
            [0.0, 12],
            [35.0, 10],
            [35.0, 10],
            [35.0, 8],
          ],
        },
        {
          'exercise': 'Chest Press Machine',
          'sets': [
            [45.0, 8],
            [45.0, 7],
            [40.0, 6],
          ],
        },
        {
          'exercise': 'Overhead Cable Triceps Extension',
          'sets': [
            [25.0, 12],
            [25.0, 10],
            [25.0, 8],
          ],
        },
        {
          'exercise': 'Triceps Pushdown',
          'sets': [
            [25.0, 12],
            [25.0, 9],
            [25.0, 8],
          ],
        },
        {
          'exercise': 'Crunch Machine',
          'sets': [
            [35.0, 12],
            [35.0, 11],
            [35.0, 10],
          ],
        },
        {
          'exercise': 'Reverse Crunch',
          'sets': [
            [1.0, 0],
            [1.0, 0],
          ],
        },
      ],

      // ==========================================================
      // WEDNESDAY — 9 SEP 2026
      // ==========================================================

      DateTime(2026, 9, 9): [
        {
          'exercise': 'Hack Squat',
          'sets': [
            [20.0, 10],
            [20.0, 10],
            [20.0, 10],
          ],
        },
        {
          'exercise': 'Leg Press',
          'sets': [
            [30.0, 12],
            [30.0, 9],
            [30.0, 8],
          ],
        },
        {
          'exercise': 'Leg Curl',
          'sets': [
            [1.0, 0],
            [1.0, 0],
          ],
        },
        {
          'exercise': 'Leg Extension',
          'sets': [
            [20.0, 15],
            [25.0, 13],
            [25.0, 13],
          ],
        },
        {
          'exercise': 'Calf Raise',
          'sets': [
            [1.0, 0],
            [1.0, 0],
            [1.0, 0],
          ],
        },
        {
          'exercise': 'Machine Shoulder Press',
          'sets': [
            [20.0, 11],
            [20.0, 9],
            [20.0, 8],
          ],
        },
        {
          'exercise': 'Lateral Raise Machine',
          'sets': [
            [20.0, 15],
            [20.0, 14],
            [20.0, 12],
            [20.0, 10],
          ],
        },
        {
          'exercise': 'Shrugs',
          'sets': [
            [15.0, 14],
            [15.0, 11],
            [15.0, 11],
          ],
        },
      ],

      // ==========================================================
      // THURSDAY — 10 SEP 2026
      // ==========================================================

      DateTime(2026, 9, 10): [
        {
          'exercise': 'Preacher Curl',
          'sets': [
            [20.0, 12],
            [20.0, 12],
            [20.0, 11],
          ],
        },
        {
          'exercise': 'Hammer Curl',
          'sets': [
            [12.5, 11],
            [12.5, 10],
            [12.0, 9],
          ],
        },
        {
          'exercise': 'Overhead Cable Triceps Extension',
          'sets': [
            [25.0, 12],
            [25.0, 12],
            [20.0, 11],
          ],
        },
        {
          'exercise': 'Triceps Pushdown',
          'sets': [
            [25.0, 12],
            [25.0, 12],
            [25.0, 10],
          ],
        },
        {
          'exercise': 'Wrist Curl',
          'sets': [
            [35.0, 15],
            [30.0, 15],
            [30.0, 15],
          ],
        },
        {
          'exercise': 'Reverse Wrist Curl',
          'sets': [
            [20.0, 15],
            [20.0, 15],
            [20.0, 15],
          ],
        },
        {
          'exercise': 'Machine Crunch',
          'sets': [
            [35.0, 12],
            [35.0, 12],
            [35.0, 10],
          ],
        },
        {
          'exercise': 'Hanging Leg Raise',
          'sets': [
            [1.0, 0],
            [1.0, 0],
            [1.0, 0],
          ],
        },
      ],

      // ==========================================================
      // FRIDAY — 11 SEP 2026
      // ==========================================================

      DateTime(2026, 9, 11): [
        {
          'exercise': 'Incline Smith Machine Press',
          'sets': [
            [25.0, 10],
            [25.0, 10],
            [25.0, 9],
            [25.0, 8],
          ],
        },
        {
          'exercise': 'Chest Press Machine',
          'sets': [
            [40.0, 12],
            [40.0, 12],
            [40.0, 12],
          ],
        },
        {
          'exercise': 'Lat Pulldown',
          'sets': [
            [40.0, 10],
            [40.0, 10],
            [40.0, 8],
            [40.0, 8],
          ],
        },
        {
          'exercise': 'Chest Supported Row',
          'sets': [
            [35.0, 10],
            [35.0, 10],
            [35.0, 10],
          ],
        },
        {
          'exercise': 'Face Pull',
          'sets': [
            [15.0, 15],
            [15.0, 12],
            [15.0, 12],
          ],
        },
      ],

      // ==========================================================
      // SATURDAY — 12 SEP 2026
      // ==========================================================

      DateTime(2026, 9, 12): [
        {
          'exercise': 'Machine Shoulder Press',
          'sets': [
            [20.0, 12],
            [20.0, 9],
            [20.0, 8],
          ],
        },
        {
          'exercise': 'Lateral Raise Machine',
          'sets': [
            [20.0, 15],
            [20.0, 15],
            [20.0, 15],
            [20.0, 15],
          ],
        },
        {
          'exercise': 'Rear Delt Fly Machine',
          'sets': [
            [20.0, 15],
            [20.0, 15],
            [20.0, 15],
          ],
        },
        {
          'exercise': 'Incline Dumbbell Curl',
          'sets': [
            [10.0, 12],
            [10.0, 10],
            [10.0, 8],
          ],
        },
        {
          'exercise': 'Overhead Cable Triceps Extension',
          'sets': [
            [25.0, 12],
            [25.0, 12],
            [25.0, 10],
          ],
        },
        {
          'exercise': 'Triceps Pushdown',
          'sets': [
            [25.0, 12],
            [25.0, 11],
            [25.0, 10],
          ],
        },
        {
          'exercise': 'Machine Crunch',
          'sets': [
            [35.0, 12],
            [35.0, 10],
            [35.0, 10],
          ],
        },
      ],
    };

    // ==========================================================
    // SEED FOR BOTH USERS
    // ==========================================================

    for (final userId in ['user1', 'user2']) {
      for (final entry in workouts.entries) {
        final date = entry.key;
        final workout = entry.value;

        // Don't duplicate existing workout data.
        final existingSets = await database.getSetsByDate(
          userId: userId,
          date: date,
        );

        if (existingSets.isNotEmpty) {
          continue;
        }

        // Save every exercise and every set.
        for (final exercise in workout) {
          final exerciseName =
              exercise['exercise'] as String;

          final sets =
              exercise['sets'] as List<List<dynamic>>;

          for (final set in sets) {
            await database.saveSet(
              userId: userId,
              exerciseName: exerciseName,
              weight: (set[0] as num).toDouble(),
              reps: set[1] as int,
              date: date,
            );
          }
        }
      }
    }
  }
}