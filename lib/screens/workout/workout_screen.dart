import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final AppDatabase _database = AppDatabase();

  final List<String> exercises = [
    'Bench Press',
    'Incline Smith Machine Press',
    'Pec Deck',
    'Chest Press Machine',
    'Triceps Pushdown',
    'Crunch Machine',
  ];

  String selectedExercise = 'Bench Press';

  final TextEditingController weightController =
      TextEditingController();

  final TextEditingController repsController =
      TextEditingController();

  List<WorkoutSet> savedSets = [];

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadTodaySets();
  }

  Future<void> _loadTodaySets() async {
    final sets = await _database.getTodaySets(
      'user1',
      DateTime.now(),
    );

    if (!mounted) return;

    setState(() {
      savedSets = sets;
    });
  }

  Future<void> _saveSet() async {
    final weight = double.tryParse(
      weightController.text.trim(),
    );

    final reps = int.tryParse(
      repsController.text.trim(),
    );

    if (weight == null || reps == null || reps <= 0) {
      _showMessage(
        'Enter valid weight and reps.',
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    await _database.saveSet(
      userId: 'user1',
      exerciseName: selectedExercise,
      weight: weight,
      reps: reps,
      date: DateTime.now(),
    );

    weightController.clear();
    repsController.clear();

    await _loadTodaySets();

    if (!mounted) return;

    setState(() {
      isSaving = false;
    });

    _showMessage('Set saved successfully.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  void _changeWeight(double amount) {
    final current =
        double.tryParse(weightController.text) ?? 0;

    final newValue = current + amount;

    if (newValue >= 0) {
      weightController.text =
          newValue.toStringAsFixed(
        newValue % 1 == 0 ? 0 : 1,
      );
    }
  }

  void _changeReps(int amount) {
    final current =
        int.tryParse(repsController.text) ?? 0;

    final newValue = current + amount;

    if (newValue >= 0) {
      repsController.text = newValue.toString();
    }
  }

  Future<void> _finishWorkout() async {
    if (savedSets.isEmpty) {
      _showMessage(
        'Save at least one set before finishing.',
      );
      return;
    }

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Workout Complete'),
          content: Text(
            '${savedSets.length} set(s) saved today.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    _database.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Track Workout'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Text(
              'Exercise',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              initialValue: selectedExercise,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
              ),
              items: exercises.map((exercise) {
                return DropdownMenuItem(
                  value: exercise,
                  child: Text(exercise),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  selectedExercise = value;
                });
              },
            ),

            const SizedBox(height: 20),

            const Text(
              'Weight (kg)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _changeWeight(-2.5);
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                  ),
                ),

                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textAlign: TextAlign.center,
                    decoration:
                        const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Weight',
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    _changeWeight(2.5);
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Text(
              'Reps',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                IconButton(
                  onPressed: () {
                    _changeReps(-1);
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                  ),
                ),

                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType:
                        TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration:
                        const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Reps',
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () {
                    _changeReps(1);
                  },
                  icon: const Icon(
                    Icons.add_circle_outline,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed:
                    isSaving ? null : _saveSet,
                child: Text(
                  isSaving
                      ? 'Saving...'
                      : 'Save Set',
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Today's Sets",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: savedSets.isEmpty
                  ? const Center(
                      child: Text(
                        'No sets recorded today.',
                      ),
                    )
                  : ListView.builder(
                      itemCount: savedSets.length,
                      itemBuilder:
                          (context, index) {
                        final set =
                            savedSets[index];

                        return Card(
                          child: ListTile(
                            title: Text(
                              set.exerciseName,
                            ),
                            subtitle: Text(
                              '${set.weight} kg × ${set.reps} reps',
                            ),
                            trailing: Text(
                              _formatTime(
                                set.createdAt,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _finishWorkout,
                child: const Text(
                  'Finish Workout',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0
        ? 12
        : time.hour % 12;

    final minute =
        time.minute.toString().padLeft(2, '0');

    final period =
        time.hour >= 12 ? 'PM' : 'AM';

    return '$hour:$minute $period';
  }
}