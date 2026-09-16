import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/database_service.dart';

class ExerciseScreen extends StatefulWidget {
  final String userId;

  const ExerciseScreen({
    super.key,
    this.userId = 'user1',
  });

  @override
  State<ExerciseScreen> createState() =>
      _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final AppDatabase _database = AppDatabase();

  final TextEditingController _exerciseController =
      TextEditingController();

  final TextEditingController _weightController =
      TextEditingController();

  final TextEditingController _repsController =
      TextEditingController();

  List<String> _exercises = [];
  String? _selectedExercise;

  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  // ============================================================
  // LOAD EXERCISES
  // ============================================================

  Future<void> _loadExercises() async {
    try {
      final sets = await _database.getTodaySets(
        widget.userId,
        DateTime.now(),
      );

      final names = <String>{};

      for (final set in sets) {
        names.add(set.exerciseName);
      }

      if (!mounted) return;

      setState(() {
        _exercises = names.toList();

        if (_selectedExercise == null &&
            _exercises.isNotEmpty) {
          _selectedExercise = _exercises.first;
        }

        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'Error loading exercises: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // ADD EXERCISE
  // ============================================================

  void _showAddExerciseDialog() {
    _exerciseController.clear();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF101C32),
          title: const Text(
            'Add Exercise',
          ),
          content: TextField(
            controller:
                _exerciseController,
            autofocus: true,
            textCapitalization:
                TextCapitalization.words,
            decoration:
                InputDecoration(
              hintText:
                  'e.g. Bench Press',
              filled: true,
              fillColor:
                  Colors.white.withValues(
                alpha: 0.06,
              ),
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                borderSide:
                    BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name =
                    _exerciseController
                        .text
                        .trim();

                if (name.isEmpty) {
                  return;
                }

                setState(() {
                  if (!_exercises
                      .contains(name)) {
                    _exercises.add(name);
                  }

                  _selectedExercise = name;
                });

                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // SAVE SET
  // ============================================================

  Future<void> _saveSet() async {
    if (_selectedExercise == null) {
      _showMessage(
        'Select an exercise first.',
      );
      return;
    }

    final weight =
        double.tryParse(
      _weightController.text.trim(),
    );

    final reps =
        int.tryParse(
      _repsController.text.trim(),
    );

    if (weight == null ||
        weight < 0) {
      _showMessage(
        'Enter a valid weight.',
      );
      return;
    }

    if (reps == null ||
        reps <= 0) {
      _showMessage(
        'Enter valid reps.',
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _database.saveSet(
        userId: widget.userId,
        exerciseName:
            _selectedExercise!,
        weight: weight,
        reps: reps,
        date: DateTime.now(),
      );

      _weightController.clear();
      _repsController.clear();

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      await _loadExercises();

      if (!mounted) return;

      setState(() {});

      _showMessage(
        'Set saved successfully.',
      );
    } catch (e) {
      debugPrint(
        'Error saving set: $e',
      );

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        'Could not save set.',
      );
    }
  }

  // ============================================================
  // GET SELECTED EXERCISE SETS
  // ============================================================

  Future<List<WorkoutSet>>
      _getSelectedExerciseSets() async {
    if (_selectedExercise == null) {
      return [];
    }

    final sets =
        await _database.getTodaySets(
      widget.userId,
      DateTime.now(),
    );

    return sets
        .where(
          (set) =>
              set.exerciseName ==
              _selectedExercise,
        )
        .toList();
  }

  // ============================================================
  // EDIT SET
  // ============================================================

  Future<void> _editSet(
    WorkoutSet set,
  ) async {
    final weightController =
        TextEditingController(
      text: set.weight.toString(),
    );

    final repsController =
        TextEditingController(
      text: set.reps.toString(),
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF101C32),
          title:
              const Text('Edit Set'),
          content: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              TextField(
                controller:
                    weightController,
                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText:
                      'Weight (kg)',
                ),
              ),
              const SizedBox(
                height: 12,
              ),
              TextField(
                controller:
                    repsController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText: 'Reps',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final weight =
                    double.tryParse(
                  weightController.text
                      .trim(),
                );

                final reps =
                    int.tryParse(
                  repsController.text
                      .trim(),
                );

                if (weight == null ||
                    weight < 0 ||
                    reps == null ||
                    reps <= 0) {
                  return;
                }

                try {
                  await _database.updateSet(
                    id: set.id,
                    exerciseName: set.exerciseName,
                    weight: weight,
                    reps: reps,
                  );

                  if (!dialogContext.mounted) {
                    return;
                  }

                  Navigator.pop(
                    dialogContext,
                  );

                  if (!mounted) return;

                  setState(() {});

                  _showMessage(
                    'Set updated.',
                  );
                } catch (e) {
                  debugPrint(
                    'Error updating set: $e',
                  );
                }
              },
              child:
                  const Text('Save'),
            ),
          ],
        );
      },
    );

    weightController.dispose();
    repsController.dispose();
  }

  // ============================================================
  // DELETE SET
  // ============================================================

  Future<void> _deleteSet(
    int id,
  ) async {
    try {
      await _database.deleteSet(id);

      if (!mounted) return;

      setState(() {});

      _showMessage(
        'Set deleted.',
      );
    } catch (e) {
      debugPrint(
        'Error deleting set: $e',
      );
    }
  }

  // ============================================================
  // CONFIRM DELETE
  // ============================================================

  Future<void> _confirmDelete(
    WorkoutSet set,
  ) async {
    final result =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF101C32),
          title:
              const Text('Delete Set?'),
          content: Text(
            '${set.weight} kg × ${set.reps} reps',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child:
                  const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child:
                  const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await _deleteSet(set.id);
    }
  }

  // ============================================================
  // COPY PREVIOUS WORKOUT
  // ============================================================

  Future<void> _openCopyPreviousWorkout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CopyPreviousWorkoutScreen(
          userId: widget.userId,
          database: _database,
        ),
      ),
    );

    if (!mounted) return;

    await _loadExercises();
    setState(() {});
  }

  // ============================================================
  // OPEN HISTORY
  // ============================================================

  Future<void> _openHistory() async {
    if (_selectedExercise == null) {
      _showMessage(
        'Select an exercise first.',
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ExerciseHistoryScreen(
          userId: widget.userId,
          exerciseName:
              _selectedExercise!,
          database: _database,
        ),
      ),
    );

    if (!mounted) return;

    setState(() {});
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _exerciseController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _database.close();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    SystemChrome
        .setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor:
            Colors.transparent,
        statusBarIconBrightness:
            Brightness.light,
        systemNavigationBarColor:
            Color(0xFF050B18),
        systemNavigationBarIconBrightness:
            Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor:
          const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF071329),
        elevation: 0,
        title: const Text(
          'Exercise',
          style: TextStyle(
            fontWeight:
                FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                _showAddExerciseDialog,
            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),
      body: Container(
        decoration:
            const BoxDecoration(
          gradient:
              LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: [
              Color(0xFF08285C),
              Color(0xFF061A3B),
              Color(0xFF050B18),
            ],
            stops: [
              0.0,
              0.38,
              1.0,
            ],
          ),
        ),
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.all(
                  18,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    const Text(
                      'Track your workout',
                      style: TextStyle(
                        fontSize: 13,
                        color:
                            Colors.white60,
                      ),
                    ),

                    const SizedBox(
                      height: 20,
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _openCopyPreviousWorkout,
                        icon: const Icon(
                          Icons.content_copy_outlined,
                        ),
                        label: const Text(
                          'COPY PREVIOUS WORKOUT',
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                      height: 24,
                    ),

                    if (_exercises.isEmpty)
                      _emptyExerciseCard()
                    else
                      _exerciseSelector(),

                    const SizedBox(
                      height: 20,
                    ),

                    if (_selectedExercise !=
                        null)
                      _trackCard(),

                    const SizedBox(
                      height: 20,
                    ),

                    if (_selectedExercise !=
                        null)
                      FutureBuilder<
                          List<WorkoutSet>>(
                        future:
                            _getSelectedExerciseSets(),
                        builder:
                            (
                          context,
                          snapshot,
                        ) {
                          if (snapshot
                                  .connectionState ==
                              ConnectionState
                                  .waiting) {
                            return const Center(
                              child:
                                  CircularProgressIndicator(),
                            );
                          }

                          final sets =
                              snapshot.data ??
                                  [];

                          return _todaySetsCard(
                            sets,
                          );
                        },
                      ),

                    const SizedBox(
                      height: 20,
                    ),

                    if (_selectedExercise !=
                        null)
                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            OutlinedButton
                                .icon(
                          onPressed:
                              _openHistory,
                          icon:
                              const Icon(
                            Icons.history,
                          ),
                          label:
                              const Text(
                            'VIEW HISTORY',
                          ),
                          style:
                              OutlinedButton
                                  .styleFrom(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 16,
                            ),
                            shape:
                                RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }

  // ============================================================
  // EMPTY EXERCISE
  // ============================================================

  Widget _emptyExerciseCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.055,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.fitness_center,
            size: 42,
            color: Colors.white54,
          ),

          const SizedBox(
            height: 14,
          ),

          const Text(
            'No exercises yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 6,
          ),

          const Text(
            'Add an exercise to start tracking.',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white54,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          ElevatedButton.icon(
            onPressed:
                _showAddExerciseDialog,
            icon: const Icon(
              Icons.add,
            ),
            label: const Text(
              'ADD EXERCISE',
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EXERCISE SELECTOR
  // ============================================================

  Widget _exerciseSelector() {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.055,
        ),
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color:
              Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child:
          DropdownButtonHideUnderline(
        child:
            DropdownButton<String>(
          value: _selectedExercise,
          isExpanded: true,
          dropdownColor:
              const Color(0xFF101C32),
          icon: const Icon(
            Icons.keyboard_arrow_down,
          ),
          items: _exercises
              .map(
                (
                  exercise,
                ) =>
                    DropdownMenuItem<
                        String>(
                  value: exercise,
                  child:
                      Text(exercise),
                ),
              )
              .toList(),
          onChanged:
              (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _selectedExercise =
                  value;
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // TRACK CARD
  // ============================================================

  Widget _trackCard() {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.055,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            _selectedExercise ?? '',
            style: const TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          Row(
            children: [
              Expanded(
                child: TextField(
                  controller:
                      _weightController,
                  keyboardType:
                      const TextInputType
                          .numberWithOptions(
                    decimal: true,
                  ),
                  decoration:
                      _inputDecoration(
                    'Weight (kg)',
                  ),
                ),
              ),

              const SizedBox(
                width: 12,
              ),

              Expanded(
                child: TextField(
                  controller:
                      _repsController,
                  keyboardType:
                      TextInputType.number,
                  decoration:
                      _inputDecoration(
                    'Reps',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  _saving
                      ? null
                      : _saveSet,
              style:
                  ElevatedButton
                      .styleFrom(
                padding:
                    const EdgeInsets
                        .symmetric(
                  vertical: 15,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'SAVE SET',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TODAY SETS
  // ============================================================

  Widget _todaySetsCard(
    List<WorkoutSet> sets,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.055,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Today\'s Sets',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ),

              Text(
                '${sets.length} sets',
                style: const TextStyle(
                  fontSize: 12,
                  color:
                      Colors.white54,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 14,
          ),

          if (sets.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                vertical: 12,
              ),
              child: Text(
                'No sets recorded yet.',
                style: TextStyle(
                  color:
                      Colors.white54,
                  fontSize: 13,
                ),
              ),
            )
          else
            ...sets.asMap().entries.map(
              (entry) {
                final index =
                    entry.key;
                final set =
                    entry.value;

                return Container(
                  margin:
                      const EdgeInsets
                          .only(
                    bottom: 8,
                  ),
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration:
                      BoxDecoration(
                    color: Colors.white
                        .withValues(
                      alpha: 0.04,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      14,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment:
                            Alignment.center,
                        decoration:
                            BoxDecoration(
                          shape:
                              BoxShape.circle,
                          color: Colors.white
                              .withValues(
                            alpha: 0.07,
                          ),
                        ),
                        child: Text(
                          '${index + 1}',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .w600,
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 12,
                      ),

                      Expanded(
                        child: Text(
                          '${set.weight} kg × ${set.reps} reps',
                          style:
                              const TextStyle(
                            fontSize: 14,
                            fontWeight:
                                FontWeight
                                    .w500,
                          ),
                        ),
                      ),

                      IconButton(
                        onPressed:
                            () => _editSet(
                          set,
                        ),
                        icon:
                            const Icon(
                          Icons
                              .edit_outlined,
                          size: 19,
                        ),
                      ),

                      IconButton(
                        onPressed:
                            () =>
                                _confirmDelete(
                          set,
                        ),
                        icon:
                            const Icon(
                          Icons
                              .delete_outline,
                          size: 19,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration(
    String label,
  ) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor:
          Colors.white.withValues(
        alpha: 0.05,
      ),
      border:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
        borderSide:
            BorderSide.none,
      ),
    );
  }
}


// ============================================================
// COPY PREVIOUS WORKOUT SCREEN
// ============================================================

class CopyPreviousWorkoutScreen extends StatefulWidget {
  final String userId;
  final AppDatabase database;

  const CopyPreviousWorkoutScreen({
    super.key,
    required this.userId,
    required this.database,
  });

  @override
  State<CopyPreviousWorkoutScreen> createState() =>
      _CopyPreviousWorkoutScreenState();
}

class _CopyPreviousWorkoutScreenState
    extends State<CopyPreviousWorkoutScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Set<String> _workoutDates = {};
  bool _loading = true;
  bool _copying = false;

  @override
  void initState() {
    super.initState();
    _loadWorkoutDates();
  }

  Future<void> _loadWorkoutDates() async {
    try {
      final dates = await widget.database.getWorkoutDates(
        widget.userId,
      );

      if (!mounted) return;

      setState(() {
        _workoutDates = dates.map(_dateKey).toSet();
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading workout dates: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  bool _hasWorkout(DateTime day) {
    return _workoutDates.contains(_dateKey(day));
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Future<void> _selectWorkoutDate(
    DateTime selectedDay,
    DateTime focusedDay,
  ) async {
    setState(() {
      _selectedDay = selectedDay;
      _focusedDay = focusedDay;
    });

    if (!_hasWorkout(selectedDay)) {
      _showMessage('No workout on ${_formatDate(selectedDay)}.');
      return;
    }

    final today = DateTime.now();
    if (isSameDay(selectedDay, today)) {
      _showMessage('Today cannot be used as a previous workout.');
      return;
    }

    try {
      final sets = await widget.database.getSetsByDate(
        userId: widget.userId,
        date: selectedDay,
      );

      if (!mounted) return;

      if (sets.isEmpty) {
        _showMessage('No workout found on this date.');
        return;
      }

      final copiedSets = await showDialog<List<_CopySetData>>(
        context: context,
        barrierDismissible: false,
        builder: (_) => _CopyWorkoutDialog(
          workoutDate: selectedDay,
          sets: sets,
        ),
      );

      if (copiedSets == null || copiedSets.isEmpty) return;

      await _copySelectedSets(copiedSets);
    } catch (e) {
      debugPrint('Error selecting workout: $e');
      _showMessage('Could not load this workout.');
    }
  }

  Future<void> _copySelectedSets(List<_CopySetData> sets) async {
    if (_copying) return;

    final today = DateTime.now();

    setState(() {
      _copying = true;
    });

    try {
      for (final set in sets) {
        await widget.database.saveSet(
          userId: widget.userId,
          exerciseName: set.exerciseName,
          weight: set.weight,
          reps: set.reps,
          date: today,
        );
      }

      if (!mounted) return;

      setState(() {
        _copying = false;
      });

      _showMessage(
        '${sets.length} ${sets.length == 1 ? 'set' : 'sets'} copied to today.',
      );

      await Future<void>.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error copying workout: $e');

      if (!mounted) return;

      setState(() {
        _copying = false;
      });

      _showMessage('Could not copy workout.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF202020),
      appBar: AppBar(
        backgroundColor: const Color(0xFF252525),
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  color: const Color(0xFF1688C4),
                  child: const Text(
                    'Select the workout you would like to copy',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 90),
                    child: TableCalendar<dynamic>(
                      firstDay: DateTime(2025, 1, 1),
                      lastDay: DateTime(2035, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) =>
                          isSameDay(_selectedDay, day),
                      eventLoader: (day) {
                        return _hasWorkout(day)
                            ? <dynamic>[true]
                            : <dynamic>[];
                      },
                      onDaySelected: _selectWorkoutDate,
                      calendarFormat: CalendarFormat.month,
                      availableCalendarFormats: const {
                        CalendarFormat.month: 'Month',
                      },
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        defaultTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        weekendTextStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        disabledTextStyle: const TextStyle(
                          color: Colors.white24,
                        ),
                        selectedDecoration: const BoxDecoration(
                          color: Color(0xFF1688C4),
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        markerDecoration: const BoxDecoration(
                          color: Color(0xFF39D98A),
                          shape: BoxShape.circle,
                        ),
                        markerSize: 7,
                        markersMaxCount: 1,
                        cellMargin: const EdgeInsets.all(4),
                      ),
                      headerStyle: const HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                        leftChevronIcon: Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 30,
                        ),
                        rightChevronIcon: Icon(
                          Icons.chevron_right,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      daysOfWeekStyle: const DaysOfWeekStyle(
                        weekdayStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        weekendStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    color: const Color(0xFF292929),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.fitness_center,
                          color: Colors.white54,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${_workoutDates.length} WORKOUTS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

// ============================================================
// COPY WORKOUT DIALOG
// ============================================================

class _CopySetData {
  final int id;
  final String exerciseName;
  double weight;
  int reps;

  _CopySetData({
    required this.id,
    required this.exerciseName,
    required this.weight,
    required this.reps,
  });
}

class _CopyWorkoutDialog extends StatefulWidget {
  final DateTime workoutDate;
  final List<WorkoutSet> sets;

  const _CopyWorkoutDialog({
    required this.workoutDate,
    required this.sets,
  });

  @override
  State<_CopyWorkoutDialog> createState() => _CopyWorkoutDialogState();
}

class _CopyWorkoutDialogState extends State<_CopyWorkoutDialog> {
  late final List<_CopySetData> _sets;
  final Set<int> _selectedIds = {};

  @override
  void initState() {
    super.initState();

    _sets = widget.sets.map((set) {
      _selectedIds.add(set.id);
      return _CopySetData(
        id: set.id,
        exerciseName: set.exerciseName,
        weight: set.weight,
        reps: set.reps,
      );
    }).toList();
  }

  Map<String, List<_CopySetData>> _groupedSets() {
    final grouped = <String, List<_CopySetData>>{};

    for (final set in _sets) {
      grouped.putIfAbsent(set.exerciseName, () => []).add(set);
    }

    return grouped;
  }

  bool get _allSelected =>
      _sets.isNotEmpty && _selectedIds.length == _sets.length;

  List<_CopySetData> get _selectedSets =>
      _sets.where((set) => _selectedIds.contains(set.id)).toList();

  void _toggleAll() {
    setState(() {
      if (_allSelected) {
        _selectedIds.clear();
      } else {
        _selectedIds
          ..clear()
          ..addAll(_sets.map((set) => set.id));
      }
    });
  }

  void _toggleExercise(List<_CopySetData> sets) {
    final ids = sets.map((set) => set.id).toSet();
    final allSelected = ids.every(_selectedIds.contains);

    setState(() {
      if (allSelected) {
        _selectedIds.removeAll(ids);
      } else {
        _selectedIds.addAll(ids);
      }
    });
  }

  void _toggleSet(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  Future<void> _editSelectedSets() async {
    final selected = _selectedSets;

    if (selected.isEmpty) return;

    final weightControllers = <int, TextEditingController>{};
    final repsControllers = <int, TextEditingController>{};

    for (final set in selected) {
      weightControllers[set.id] = TextEditingController(
        text: set.weight.toString(),
      );
      repsControllers[set.id] = TextEditingController(
        text: set.reps.toString(),
      );
    }

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFF292929),
          title: const Text('Edit Selected Sets'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: selected.map((set) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Text(
                            set.exerciseName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: weightControllers[set.id],
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'kg',
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: repsControllers[set.id],
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'reps',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                for (final set in selected) {
                  final weight = double.tryParse(
                    weightControllers[set.id]!.text.trim(),
                  );
                  final reps = int.tryParse(
                    repsControllers[set.id]!.text.trim(),
                  );

                  if (weight != null && weight >= 0) {
                    set.weight = weight;
                  }
                  if (reps != null && reps >= 0) {
                    set.reps = reps;
                  }
                }

                Navigator.pop(dialogContext);
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    for (final controller in weightControllers.values) {
      controller.dispose();
    }
    for (final controller in repsControllers.values) {
      controller.dispose();
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _copy() {
    final selected = _selectedSets
        .map(
          (set) => _CopySetData(
            id: set.id,
            exerciseName: set.exerciseName,
            weight: set.weight,
            reps: set.reps,
          ),
        )
        .toList();

    if (selected.isEmpty) return;

    Navigator.pop(context, selected);
  }

  String _dateText() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${widget.workoutDate.day} ${months[widget.workoutDate.month - 1]} ${widget.workoutDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedSets();

    return Dialog(
      backgroundColor: const Color(0xFF292929),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 48,
        vertical: 28,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.82,
          maxWidth: 430,
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 14, 14, 12),
              decoration: const BoxDecoration(
                color: Color(0xFF303030),
                border: Border(
                  bottom: BorderSide(
                    color: Color(0xFF1688C4),
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Copy Workout',
                      style: TextStyle(
                        color: Color(0xFF42B5EF),
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              color: const Color(0xFF292929),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Select All',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  _CheckBox(
                    value: _allSelected,
                    onChanged: (_) => _toggleAll(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Scrollbar(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Container(
                      color: const Color(0xFF242424),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      child: Text(
                        _dateText(),
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    ...grouped.entries.map(
                      (entry) => _exerciseSection(
                        entry.key,
                        entry.value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF303030),
                border: Border(
                  top: BorderSide(
                    color: Colors.white12,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _bottomButton(
                      label: 'Cancel',
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 52,
                    color: Colors.white12,
                  ),
                  Expanded(
                    child: _bottomButton(
                      label: 'Edit',
                      enabled: _selectedSets.isNotEmpty,
                      onPressed: _editSelectedSets,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 52,
                    color: Colors.white12,
                  ),
                  Expanded(
                    child: _bottomButton(
                      label: 'Copy',
                      enabled: _selectedSets.isNotEmpty,
                      accent: true,
                      onPressed: _copy,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseSection(
    String exerciseName,
    List<_CopySetData> sets,
  ) {
    final ids = sets.map((set) => set.id).toSet();
    final allSelected = ids.every(_selectedIds.contains);

    return Column(
      children: [
        Container(
          color: const Color(0xFF383838),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 7,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$exerciseName  –  ${sets.length} sets',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _CheckBox(
                value: allSelected,
                onChanged: (_) => _toggleExercise(sets),
              ),
            ],
          ),
        ),
        ...sets.asMap().entries.map((entry) {
          final index = entry.key;
          final set = entry.value;

          return Container(
            color: const Color(0xFF292929),
            padding: const EdgeInsets.fromLTRB(18, 8, 8, 8),
            child: Row(
              children: [
                SizedBox(
                  width: 26,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    '${_formatNumber(set.weight)} kgs',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${set.reps} reps',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                _CheckBox(
                  value: _selectedIds.contains(set.id),
                  onChanged: (_) => _toggleSet(set.id),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _bottomButton({
    required String label,
    required VoidCallback onPressed,
    bool enabled = true,
    bool accent = false,
  }) {
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        minimumSize: const Size(0, 52),
        foregroundColor: accent
            ? const Color(0xFF42B5EF)
            : Colors.white,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatNumber(num value) {
    final number = value.toDouble();
    if (number == number.roundToDouble()) {
      return number.toStringAsFixed(1);
    }
    return number.toString();
  }
}

class _CheckBox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CheckBox({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Checkbox(
      value: value,
      onChanged: (value) => onChanged(value ?? false),
      activeColor: const Color(0xFF1688C4),
      checkColor: Colors.white,
      side: const BorderSide(
        color: Colors.white38,
      ),
      visualDensity: VisualDensity.compact,
    );
  }
}


// EXERCISE HISTORY
// ============================================================

class ExerciseHistoryScreen
    extends StatefulWidget {
  final String userId;
  final String exerciseName;
  final AppDatabase database;

  const ExerciseHistoryScreen({
    super.key,
    required this.userId,
    required this.exerciseName,
    required this.database,
  });

  @override
  State<ExerciseHistoryScreen>
      createState() =>
          _ExerciseHistoryScreenState();
}

class _ExerciseHistoryScreenState
    extends State<
        ExerciseHistoryScreen> {
  bool _loading = true;

  Map<String, List<WorkoutSet>>
      _history = {};

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  // ============================================================
  // LOAD HISTORY
  // ============================================================

  Future<void> _loadHistory() async {
    try {
      final sets =
          await widget.database.getExerciseHistory(
        userId: widget.userId,
        exerciseName: widget.exerciseName,
      );

      final Map<String,
              List<WorkoutSet>>
          grouped = {};

      for (final set in sets) {
        final dateKey =
            '${set.date.year}-'
            '${set.date.month.toString().padLeft(2, '0')}-'
            '${set.date.day.toString().padLeft(2, '0')}';

        grouped.putIfAbsent(
          dateKey,
          () => [],
        );

        grouped[dateKey]!.add(
          set,
        );
      }

      if (!mounted) return;

      setState(() {
        _history = grouped;
        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'Error loading history: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF071329),
        elevation: 0,
        title: Text(
          widget.exerciseName,
        ),
      ),
      body: Container(
        decoration:
            const BoxDecoration(
          gradient:
              LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: [
              Color(0xFF08285C),
              Color(0xFF061A3B),
              Color(0xFF050B18),
            ],
            stops: [
              0.0,
              0.38,
              1.0,
            ],
          ),
        ),
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _history.isEmpty
                ? const Center(
                    child: Text(
                      'No workout history yet.',
                      style:
                          TextStyle(
                        color:
                            Colors.white60,
                      ),
                    ),
                  )
                : ListView(
                    padding:
                        const EdgeInsets
                            .all(
                      18,
                    ),
                    children:
                        _history.entries
                            .map(
                      (entry) {
                        return _historyDayCard(
                          entry.key,
                          entry.value,
                        );
                      },
                    ).toList(),
                  ),
      ),
    );
  }

  // ============================================================
  // HISTORY DAY CARD
  // ============================================================

  Widget _historyDayCard(
    String date,
    List<WorkoutSet> sets,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.055,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          ...sets.asMap().entries.map(
            (entry) {
              final index =
                  entry.key;
              final set =
                  entry.value;

              return Padding(
                padding:
                    const EdgeInsets
                        .only(
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Set ${index + 1}',
                      style:
                          const TextStyle(
                        fontSize: 13,
                        color:
                            Colors.white60,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '${set.weight} kg × ${set.reps}',
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}