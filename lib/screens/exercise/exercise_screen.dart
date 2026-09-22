import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/database_service.dart';

class ExerciseScreen extends StatefulWidget {
  final String userId;
  final bool homeMode;

  const ExerciseScreen({
    super.key,
    this.userId = 'user1',
    this.homeMode = false,
  });

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final AppDatabase _database = AppDatabase();
  List<WorkoutSet> _todaySets = [];
  List<ExerciseLibraryData> _exerciseLibrary = [];
  bool _loading = true;

  // User 1 Today shows only exercises that have been
  // recorded or copied to today's date. There is no automatic
  // weekly-plan population on this screen.
  @override
  void initState() {
    super.initState();
    _loadTodayWorkout();
  }

  Future<void> _loadTodayWorkout() async {
    try {
      final sets = await _database.getSetsByDate(
        userId: widget.userId,
        date: DateTime.now(),
      );

      final library = await _database.getExerciseLibrary(userId: widget.userId);

      if (!mounted) return;
      setState(() {
        _todaySets = sets;
        _exerciseLibrary = library;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading User 1 exercises: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  List<String> _todayExercises() {
    final result = <String>[];
    for (final set in _todaySets) {
      if (!result.contains(set.exerciseName)) {
        result.add(set.exerciseName);
      }
    }
    return result;
  }

  int _setCount(String exerciseName) =>
      _todaySets.where((set) => set.exerciseName == exerciseName).length;

  Future<void> _openExercise(String exerciseName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => User1ExerciseDetailScreen(
          exerciseName: exerciseName,
          database: _database,
        ),
      ),
    );
    await _loadTodayWorkout();
  }

  Future<void> _addNewExercise() async {
    // Use a normal page instead of showDialog here. This avoids the
    // Flutter overlay/inherited-element deactivation assertion that was
    // happening when the dialog closed after adding an exercise.
    final exerciseName = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const AddExerciseScreen()),
    );

    if (!mounted || exerciseName == null) return;

    final normalized = exerciseName.trim();
    if (normalized.isEmpty) return;

    final alreadyExists = _exerciseLibrary.any(
      (item) =>
          item.exerciseName.trim().toLowerCase() == normalized.toLowerCase(),
    );

    if (alreadyExists) {
      return;
    }

    try {
      await _database.saveExerciseLibraryItem(
        userId: widget.userId,
        exerciseName: normalized,
      );

      await _loadTodayWorkout();
    } catch (e) {
      debugPrint('Error adding exercise: $e');
    }
  }

  Future<void> _deleteTodayExercise(String exerciseName) async {
    final exerciseSets = _todaySets
        .where((set) => set.exerciseName == exerciseName)
        .toList();

    if (exerciseSets.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101C32),
        title: const Text('Delete Exercise?'),
        content: Text(
          'Delete $exerciseName and its ${exerciseSets.length} set${exerciseSets.length == 1 ? '' : 's'} from today? Previous workout dates will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      for (final set in exerciseSets) {
        await _database.deleteSet(set.id);
      }

      await _loadTodayWorkout();
      _showMessage('$exerciseName deleted from today.');
    } catch (e) {
      debugPrint('Error deleting exercise: $e');
      _showMessage('Could not delete $exerciseName.');
    }
  }

  Future<void> _deleteAllTodayExercises() async {
    if (_todaySets.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101C32),
        title: const Text("Delete Today's Workout?"),
        content: const Text(
          'This will delete all exercises and sets recorded for User 1 today. Previous workout dates will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE ALL'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _database.deleteAllSetsByDate(
        userId: widget.userId,
        date: DateTime.now(),
      );
      await _loadTodayWorkout();
      _showMessage("Today's workout deleted.");
    } catch (e) {
      debugPrint("Error deleting today's User 1 workout: $e");
      _showMessage("Could not delete today's workout.");
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openCopyPreviousExercise() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CopyPreviousWorkoutScreen(
          userId: widget.userId,
          database: _database,
          title: 'Copy Previous Exercise',
        ),
      ),
    );
    await _loadTodayWorkout();
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

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF050B18),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final exercises = _todayExercises();

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071329),
        elevation: 0,
        title: const Text(
          'Exercise',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF08285C), Color(0xFF061A3B), Color(0xFF050B18)],
            stops: [0.0, 0.38, 1.0],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadTodayWorkout,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                  children: [
                    const Text(
                      'TODAY',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Today's Workout",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (exercises.isEmpty)
                      _emptyCard()
                    else
                      ...exercises.map((exercise) => _exerciseCard(exercise)),
                    const SizedBox(height: 14),
                    _copyCard(),
                    if (!widget.homeMode && exercises.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _deleteTodayCard(),
                    ],
                    if (!widget.homeMode) ...[
                      const SizedBox(height: 10),
                      _addExerciseCard(),
                      const SizedBox(height: 10),
                      _createRoutineCard(),
                      const SizedBox(height: 10),
                      _myRoutinesCard(),
                      if (_exerciseLibrary.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'EXERCISE LIBRARY',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.7,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._exerciseLibrary.map(_libraryExerciseCard),
                      ],
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _exerciseCard(String exerciseName) {
  final count = _setCount(exerciseName);

  return InkWell(
    onTap: () => _openExercise(exerciseName),
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$count ${count == 1 ? 'set' : 'sets'}',
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          if (!widget.homeMode)
            IconButton(
              tooltip: 'Delete today',
              icon: const Icon(
                Icons.delete_outline,
                color: Colors.redAccent,
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 32,
                minHeight: 32,
              ),
              onPressed: () => _deleteTodayExercise(exerciseName),
            ),

          const Icon(
            Icons.chevron_right,
            color: Colors.white38,
            size: 20,
          ),
        ],
      ),
    ),
  );
}

  Widget _copyCard() {
  return InkWell(
    onTap: _openCopyPreviousExercise,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.content_copy_outlined,
            size: 19,
            color: Colors.white70,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Copy Previous Exercise',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.white38,
          ),
        ],
      ),
    ),
  );
}

  Widget _deleteTodayCard() {
  return InkWell(
    onTap: _deleteAllTodayExercises,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.delete_outline,
            size: 19,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Delete Today's Workout",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.white38,
          ),
        ],
      ),
    ),
  );
}

  Widget _addExerciseCard() {
  return InkWell(
    onTap: _addNewExercise,
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.add_circle_outline,
            size: 19,
            color: Colors.cyanAccent,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Add New Exercise',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.white38,
          ),
        ],
      ),
    ),
  );
}

  Widget _createRoutineCard() {
  return InkWell(
    onTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CreateRoutineScreen(
            userId: widget.userId,
            database: _database,
          ),
        ),
      );
      await _loadTodayWorkout();
    },
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.event_note_outlined,
            size: 19,
            color: Colors.orangeAccent,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Create New Routine',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.white38,
          ),
        ],
      ),
    ),
  );
}
  Widget _myRoutinesCard() {
  return InkWell(
    onTap: () async {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MyRoutinesScreen(
            userId: widget.userId,
            database: _database,
          ),
        ),
      );
      await _loadTodayWorkout();
    },
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Icon(
            Icons.calendar_month_outlined,
            size: 19,
            color: Colors.cyanAccent,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'My Routines',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.white38,
          ),
        ],
      ),
    ),
  );
}

  Future<void> _deleteLibraryExercise(ExerciseLibraryData exercise) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101C32),
        title: const Text('Delete Exercise?'),
        content: Text(
          'Remove ${exercise.exerciseName} from your Exercise Library?\n\n'
          'This will not delete any workout sets already recorded for this exercise.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _database.deleteExerciseLibraryItem(id: exercise.id);
      await _loadTodayWorkout();
    } catch (e) {
      debugPrint('Error deleting exercise library item: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not delete exercise.')),
        );
      }
    }
  }

  Widget _libraryExerciseCard(ExerciseLibraryData exercise) {
  return InkWell(
    onTap: () => _openExercise(exercise.exerciseName),
    borderRadius: BorderRadius.circular(10),
    child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.fitness_center_outlined,
            size: 18,
            color: Colors.white70,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              exercise.exerciseName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Delete from library',
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.redAccent,
              size: 18,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            onPressed: () => _deleteLibraryExercise(exercise),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: Colors.white38,
          ),
        ],
      ),
    ),
  );
}

  Widget _emptyCard() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        'No exercises for today.',
        style: TextStyle(
          color: Colors.white38,
          fontSize: 13,
        ),
      ),
    );
  }
}

// ============================================================
// USER 1 EXERCISE DETAIL
// LAST WORKOUT = REFERENCE ONLY; TODAY = SEPARATE DATA
// ============================================================
// ============================================================
// CREATE ROUTINE
// ============================================================

class _RoutineSetDraft {
  final TextEditingController weightController;
  final TextEditingController repsController;

  _RoutineSetDraft({String weight = '', String reps = ''})
    : weightController = TextEditingController(text: weight),
      repsController = TextEditingController(text: reps);

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}

class _RoutineExerciseDraft {
  final String exerciseName;
  final List<_RoutineSetDraft> sets;

  _RoutineExerciseDraft({
    required this.exerciseName,
    List<_RoutineSetDraft>? initialSets,
  }) : sets = initialSets ?? [_RoutineSetDraft()];

  void dispose() {
    for (final set in sets) {
      set.dispose();
    }
  }
}

class CreateRoutineScreen extends StatefulWidget {
  final String userId;
  final AppDatabase database;
  final WorkoutRoutine? routine;

  const CreateRoutineScreen({
    super.key,
    required this.userId,
    required this.database,
    this.routine,
  });

  @override
  State<CreateRoutineScreen> createState() => _CreateRoutineScreenState();
}

class _CreateRoutineScreenState extends State<CreateRoutineScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  List<ExerciseLibraryData> _library = [];
  final List<_RoutineExerciseDraft> _exercises = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    final library = await widget.database.getExerciseLibrary(
      userId: widget.userId,
    );

    if (widget.routine != null) {
      final routine = widget.routine!;
      final routineSets = await widget.database.getRoutineSets(
        routineId: routine.id,
      );

      final grouped = <String, List<RoutineSet>>{};

      for (final set in routineSets) {
        grouped.putIfAbsent(set.exerciseName, () => []).add(set);
      }

      for (final entry in grouped.entries) {
        final initialSets = entry.value
            .map(
              (set) => _RoutineSetDraft(
                weight: set.weight.toString(),
                reps: set.reps.toString(),
              ),
            )
            .toList();

        _exercises.add(
          _RoutineExerciseDraft(
            exerciseName: entry.key,
            initialSets: initialSets,
          ),
        );
      }

      _nameController.text = routine.routineName;
      _selectedDate = routine.date;
    }

    if (!mounted) return;

    setState(() {
      _library = library;
      _loading = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF39D98A),
            surface: Color(0xFF101C32),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addExercise(String name) {
    if (_exercises.any((e) => e.exerciseName == name)) {
      _showMessage('$name is already in this routine.');
      return;
    }
    setState(() {
      _exercises.add(_RoutineExerciseDraft(exerciseName: name));
    });
  }

  Future<void> _chooseExercise() async {
    if (_library.isEmpty) {
      _showMessage('Add an exercise to your Exercise Library first.');
      return;
    }

    final available = _library
        .where(
          (item) => !_exercises.any((e) => e.exerciseName == item.exerciseName),
        )
        .toList();

    if (available.isEmpty) {
      _showMessage('All library exercises are already in this routine.');
      return;
    }

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF101C32),
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 10),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(18, 10, 18, 12),
              child: Text(
                'ADD EXERCISE',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
            ...available.map(
              (item) => ListTile(
                title: Text(item.exerciseName),
                trailing: const Icon(Icons.add),
                onTap: () => Navigator.pop(ctx, item.exerciseName),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) _addExercise(selected);
  }

  void _removeExercise(int index) {
    final exercise = _exercises.removeAt(index);
    exercise.dispose();
    setState(() {});
  }

  void _addSet(int exerciseIndex) {
    setState(() {
      _exercises[exerciseIndex].sets.add(_RoutineSetDraft());
    });
  }

  void _removeSet(int exerciseIndex, int setIndex) {
    if (_exercises[exerciseIndex].sets.length == 1) return;
    final set = _exercises[exerciseIndex].sets.removeAt(setIndex);
    set.dispose();
    setState(() {});
  }

  Future<void> _saveRoutine() async {
    if (_saving) return;

    final name = _nameController.text.trim();

    if (name.isEmpty) {
      _showMessage('Enter a routine name.');
      return;
    }

    if (_exercises.isEmpty) {
      _showMessage('Add at least one exercise.');
      return;
    }

    final routineSets = <RoutineSet>[];

    for (final exercise in _exercises) {
      var setNumber = 1;

      for (var i = 0; i < exercise.sets.length; i++) {
        final set = exercise.sets[i];

        final weightText = set.weightController.text.trim();
        final repsText = set.repsController.text.trim();

        if (weightText.isEmpty && repsText.isEmpty) {
          continue;
        }

        final weight = double.tryParse(weightText);
        final reps = int.tryParse(repsText);

        if (weight == null || weight < 0 || reps == null || reps <= 0) {
          _showMessage(
            'Enter valid weight and reps for '
            '${exercise.exerciseName}, Set ${i + 1}.',
          );
          return;
        }

        routineSets.add(
          RoutineSet(
            id: 0,
            routineId: widget.routine?.id ?? 0,
            exerciseName: exercise.exerciseName,
            setNumber: setNumber,
            weight: weight,
            reps: reps,
          ),
        );

        setNumber++;
      }
    }

    if (routineSets.isEmpty) {
      _showMessage('Add at least one filled set.');
      return;
    }

    setState(() => _saving = true);

    try {
      if (widget.routine == null) {
        // CREATE MODE
        final routineId = await widget.database.saveWorkoutRoutine(
          userId: widget.userId,
          date: _selectedDate,
          routineName: name,
        );

        for (final set in routineSets) {
          await widget.database.saveRoutineSet(
            routineId: routineId,
            exerciseName: set.exerciseName,
            setNumber: set.setNumber,
            weight: set.weight,
            reps: set.reps,
          );
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Routine saved for ${_formatDate(_selectedDate)}.'),
          ),
        );
      } else {
        // EDIT MODE
        final success = await widget.database.updateWorkoutRoutine(
          id: widget.routine!.id,
          date: _selectedDate,
          routineName: name,
          sets: routineSets,
        );

        if (!success) {
          throw Exception('Routine update failed');
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Routine updated successfully.')),
        );
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving/updating routine: $e');

      if (mounted) {
        setState(() => _saving = false);
        _showMessage(
          widget.routine == null
              ? 'Could not save routine.'
              : 'Could not update routine.',
        );
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
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

  @override
  void dispose() {
    _nameController.dispose();
    for (final exercise in _exercises) {
      exercise.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071329),
        elevation: 0,
        title: Text(widget.routine == null ? 'Create Routine' : 'Edit Routine'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF08285C),
                    Color(0xFF061A3B),
                    Color(0xFF050B18),
                  ],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                children: [
                  Text(
                    widget.routine == null ? 'NEW ROUTINE' : 'EDIT ROUTINE',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Routine name',
                      hintText: 'e.g. Chest + Triceps',
                      filled: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 2,
                    ),
                    tileColor: Colors.white.withValues(alpha: 0.055),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.cyanAccent,
                    ),
                    title: const Text('Workout date'),
                    subtitle: Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.white54,
                    ),
                    onTap: _pickDate,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'EXERCISES',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.7,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _chooseExercise,
                        icon: const Icon(Icons.add, size: 18),
                        label: const Text('ADD EXERCISE'),
                      ),
                    ],
                  ),
                  if (_exercises.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.055),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'No exercises added. Tap ADD EXERCISE to build your routine.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  else
                    ..._exercises.asMap().entries.map(
                      (entry) => _exerciseEditor(entry.key, entry.value),
                    ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveRoutine,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              widget.routine == null
                                  ? 'SAVE ROUTINE'
                                  : 'SAVE CHANGES',
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _exerciseEditor(int exerciseIndex, _RoutineExerciseDraft exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  exercise.exerciseName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeExercise(exerciseIndex),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
              ),
            ],
          ),
          ...exercise.sets.asMap().entries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 45,
                    child: Text(
                      'Set ${entry.key + 1}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: entry.value.weightController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Weight kg',
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: entry.value.repsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        filled: true,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _removeSet(exerciseIndex, entry.key),
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.white54,
                      size: 19,
                    ),
                  ),
                ],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => _addSet(exerciseIndex),
            icon: const Icon(Icons.add, size: 17),
            label: const Text('ADD SET'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// MY ROUTINES
// ============================================================

class MyRoutinesScreen extends StatefulWidget {
  final String userId;
  final AppDatabase database;

  const MyRoutinesScreen({
    super.key,
    required this.userId,
    required this.database,
  });

  @override
  State<MyRoutinesScreen> createState() => _MyRoutinesScreenState();
}

class _MyRoutinesScreenState extends State<MyRoutinesScreen> {
  List<WorkoutRoutine> _routines = [];
  bool _loading = true;
  final Set<int> _expanded = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final routines = await widget.database.getWorkoutRoutines(
      userId: widget.userId,
    );
    if (!mounted) return;
    setState(() {
      _routines = routines;
      _loading = false;
    });
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

  Future<void> _deleteRoutine(WorkoutRoutine routine) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101C32),
        title: const Text('Delete Routine?'),
        content: Text(
          'Delete ${routine.routineName} for ${_formatDate(routine.date)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await widget.database.deleteWorkoutRoutine(id: routine.id);
    await _load();
  }

  Future<void> _deleteAllRoutines() async {
    if (_routines.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101C32),
        title: const Text('Delete All Routines?'),
        content: const Text(
          'This will remove all your planned workout routines.\n\n'
          'Your recorded workout history will NOT be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE ALL'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await widget.database.deleteAllWorkoutRoutines(userId: widget.userId);

      _expanded.clear();

      await _load();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('All planned routines deleted.')),
        );
    } catch (e) {
      debugPrint('Error deleting all routines: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not delete all routines.')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071329),
        elevation: 0,
        title: const Text('My Routines'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF08285C),
                    Color(0xFF061A3B),
                    Color(0xFF050B18),
                  ],
                ),
              ),
              child: _routines.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
                      children: [
                        Container(
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.055),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.event_note_outlined,
                                size: 42,
                                color: Colors.white38,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No routines yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Create a new routine to build your workout schedule.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.07),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.red.withValues(alpha: 0.18),
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 7,
                            ),
                            leading: const Icon(
                              Icons.delete_sweep_outlined,
                              color: Colors.redAccent,
                            ),
                            title: const Text(
                              'DELETE ALL MY ROUTINES',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.redAccent,
                              ),
                            ),
                            subtitle: const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'Remove all planned routines without deleting workout history',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.white54,
                            ),
                            onTap: _deleteAllRoutines,
                          ),
                        ),
                        const SizedBox(height: 14),
                        ..._routines.map(_routineCard),
                      ],
                    ),
            ),
    );
  }

  Widget _routineCard(WorkoutRoutine routine) {
    final isExpanded = _expanded.contains(routine.id);
    return FutureBuilder<List<RoutineSet>>(
      future: widget.database.getRoutineSets(routineId: routine.id),
      builder: (context, snapshot) {
        final sets = snapshot.data ?? const <RoutineSet>[];
        final exercises = <String>[];
        for (final set in sets) {
          if (!exercises.contains(set.exerciseName)) {
            exercises.add(set.exerciseName);
          }
        }
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.055),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                leading: const Icon(
                  Icons.fitness_center,
                  color: Colors.orangeAccent,
                ),
                title: Text(
                  routine.routineName,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${_formatDate(routine.date)} • ${exercises.length} exercise${exercises.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Edit routine',
                      onPressed: () async {
                        final updated = await Navigator.push<bool>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateRoutineScreen(
                              userId: widget.userId,
                              database: widget.database,
                              routine: routine,
                            ),
                          ),
                        );

                        if (updated == true) {
                          await _load();
                        }
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.cyanAccent,
                        size: 20,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Delete routine',
                      onPressed: () => _deleteRoutine(routine),
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                    Icon(
                      isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: Colors.white54,
                    ),
                  ],
                ),
                onTap: () => setState(
                  () => isExpanded
                      ? _expanded.remove(routine.id)
                      : _expanded.add(routine.id),
                ),
              ),
              if (isExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Column(
                    children: [
                      if (sets.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StartRoutineWorkoutScreen(
                                    userId: widget.userId,
                                    database: widget.database,
                                    routine: routine,
                                  ),
                                ),
                              );
                              await _load();
                            },
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('START WORKOUT'),
                          ),
                        ),
                      if (sets.isNotEmpty) const SizedBox(height: 8),
                      if (sets.isEmpty)
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'No sets added.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      else
                        ...exercises.map((name) {
                          final exerciseSets = sets
                              .where((set) => set.exerciseName == name)
                              .toList();
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                ...exerciseSets.map(
                                  (set) => Padding(
                                    padding: const EdgeInsets.only(top: 3),
                                    child: Text(
                                      'Set ${set.setNumber}   ${set.weight} kg × ${set.reps}',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// START ROUTINE WORKOUT
// ============================================================

class _PerformedRoutineSet {
  final int routineSetId;
  final String exerciseName;
  final int setNumber;
  final TextEditingController weightController;
  final TextEditingController repsController;

  _PerformedRoutineSet({
    required this.routineSetId,
    required this.exerciseName,
    required this.setNumber,
    required double weight,
    required int reps,
  }) : weightController = TextEditingController(
         text: _formatRoutineNumber(weight),
       ),
       repsController = TextEditingController(text: reps.toString());

  static String _formatRoutineNumber(num value) {
    final d = value.toDouble();
    return d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toString();
  }

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}

class StartRoutineWorkoutScreen extends StatefulWidget {
  final String userId;
  final AppDatabase database;
  final WorkoutRoutine routine;

  const StartRoutineWorkoutScreen({
    super.key,
    required this.userId,
    required this.database,
    required this.routine,
  });

  @override
  State<StartRoutineWorkoutScreen> createState() =>
      _StartRoutineWorkoutScreenState();
}

class _StartRoutineWorkoutScreenState extends State<StartRoutineWorkoutScreen> {
  List<_PerformedRoutineSet> _sets = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadRoutine();
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

  Future<void> _loadRoutine() async {
    try {
      final planned = await widget.database.getRoutineSets(
        routineId: widget.routine.id,
      );

      final drafts = planned
          .map(
            (set) => _PerformedRoutineSet(
              routineSetId: set.id,
              exerciseName: set.exerciseName,
              setNumber: set.setNumber,
              weight: set.weight,
              reps: set.reps,
            ),
          )
          .toList();

      if (!mounted) return;
      setState(() {
        _sets = drafts;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading routine workout: $e');
      if (mounted) {
        setState(() => _loading = false);
        _showMessage('Could not load routine.');
      }
    }
  }

  Future<void> _saveWorkout() async {
    if (_saving) return;

    final values =
        <({int routineSetId, String exerciseName, double weight, int reps})>[];

    for (final set in _sets) {
      final weightText = set.weightController.text.trim();
      final repsText = set.repsController.text.trim();

      final weight = double.tryParse(weightText);
      final reps = int.tryParse(repsText);

      if (weight == null || weight < 0 || reps == null || reps <= 0) {
        _showMessage(
          'Enter valid weight and reps for '
          '${set.exerciseName}, Set ${set.setNumber}.',
        );
        return;
      }

      values.add((
        routineSetId: set.routineSetId,
        exerciseName: set.exerciseName,
        weight: weight,
        reps: reps,
      ));
    }

    if (values.isEmpty) {
      _showMessage('No workout sets to save.');
      return;
    }

    setState(() => _saving = true);

    try {
      final performedDate = DateTime.now();

      for (final value in values) {
        await widget.database.saveSet(
          userId: widget.userId,
          exerciseName: value.exerciseName,
          weight: value.weight,
          reps: value.reps,
          date: performedDate,
        );

        await widget.database.updateRoutineSet(
          id: value.routineSetId,
          weight: value.weight,
          reps: value.reps,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout recorded successfully.')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error saving routine workout: $e');
      if (mounted) {
        setState(() => _saving = false);
        _showMessage('Could not save workout.');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    for (final set in _sets) {
      set.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071329),
        elevation: 0,
        title: const Text('Start Workout'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF08285C),
                    Color(0xFF061A3B),
                    Color(0xFF050B18),
                  ],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                children: [
                  Text(
                    widget.routine.routineName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Planned for ${_formatDate(widget.routine.date)}',
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Edit the planned weights/reps if needed, then save the workout.',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 22),
                  ..._buildExerciseSections(),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _saving ? null : _saveWorkout,
                      icon: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.check),
                      label: Text(_saving ? 'SAVING...' : 'SAVE WORKOUT'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  List<Widget> _buildExerciseSections() {
    final names = <String>[];

    for (final set in _sets) {
      if (!names.contains(set.exerciseName)) {
        names.add(set.exerciseName);
      }
    }

    return names.map((name) {
      final exerciseSets = _sets
          .where((set) => set.exerciseName == name)
          .toList();

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            ...exerciseSets.map(
              (set) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 52,
                      child: Text(
                        'Set ${set.setNumber}',
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: set.weightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Weight (kg)',
                          filled: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: set.repsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Reps',
                          filled: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _controller = TextEditingController();

  void _add() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;

    Navigator.of(context).pop(name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071329),
        elevation: 0,
        title: const Text('Add New Exercise'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF08285C), Color(0xFF061A3B), Color(0xFF050B18)],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 32),
          children: [
            const Text(
              'NEW EXERCISE',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add an exercise to your exercise library.',
              style: TextStyle(color: Colors.white60, fontSize: 13),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _add(),
              decoration: InputDecoration(
                labelText: 'Exercise name',
                hintText: 'e.g. Incline Dumbbell Press',
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.06),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _add,
                icon: const Icon(Icons.add),
                label: const Text('ADD EXERCISE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class User1ExerciseDetailScreen extends StatefulWidget {
  final String exerciseName;
  final AppDatabase database;

  const User1ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
    required this.database,
  });

  @override
  State<User1ExerciseDetailScreen> createState() =>
      _User1ExerciseDetailScreenState();
}

class _User1ExerciseDetailScreenState extends State<User1ExerciseDetailScreen> {
  late AppDatabase _database;
  List<WorkoutSet> _lastWorkout = [];
  List<WorkoutSet> _todaySets = [];
  List<WorkoutSet> _history = [];
  List<TextEditingController> _weightControllers = [];
  List<TextEditingController> _repsControllers = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _database = widget.database;
    _loadData();
  }

  DateTime _dayOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';

  String _formatDate(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _loadData() async {
    try {
      final today = await _database.getSetsByDate(
        userId: 'user1',
        date: DateTime.now(),
      );
      final history = await _database.getExerciseHistory(
        userId: 'user1',
        exerciseName: widget.exerciseName,
      );
      final previousDates = history
          .map((s) => _dayOnly(s.date))
          .where((d) => d.isBefore(_dayOnly(DateTime.now())))
          .toList();
      DateTime? lastDate;
      for (final d in previousDates) {
        if (lastDate == null || d.isAfter(lastDate)) lastDate = d;
      }
      List<WorkoutSet> last = [];
      if (lastDate != null) {
        last = history.where((s) => _dayOnly(s.date) == lastDate).toList();
      }
      if (!mounted) return;
      setState(() {
        _todaySets = today
            .where((s) => s.exerciseName == widget.exerciseName)
            .toList();
        _history = history;
        _lastWorkout = last;
        _loading = false;
      });
      _resetControllersFromToday();
    } catch (e) {
      debugPrint('Error loading exercise detail: $e');
      if (mounted) setState(() => _loading = false);
    }
  }

  void _resetControllersFromToday() {
    for (final c in _weightControllers) {
      c.dispose();
    }
    for (final c in _repsControllers) {
      c.dispose();
    }
    final count = _todaySets.isEmpty ? 1 : _todaySets.length;
    _weightControllers = List.generate(
      count,
      (i) => TextEditingController(
        text: i < _todaySets.length ? _formatNumber(_todaySets[i].weight) : '',
      ),
    );
    _repsControllers = List.generate(
      count,
      (i) => TextEditingController(
        text: i < _todaySets.length ? _todaySets[i].reps.toString() : '',
      ),
    );
  }

  void _addSet() {
    setState(() {
      _weightControllers.add(TextEditingController());
      _repsControllers.add(TextEditingController());
    });
  }

  Future<void> _saveToday() async {
    if (_saving) return;
    final values = <({double weight, int reps})>[];
    for (var i = 0; i < _weightControllers.length; i++) {
      final wText = _weightControllers[i].text.trim();
      final rText = _repsControllers[i].text.trim();
      if (wText.isEmpty && rText.isEmpty) continue;
      final weight = double.tryParse(wText);
      final reps = int.tryParse(rText);
      if (weight == null || weight < 0 || reps == null || reps <= 0) {
        _showMessage('Enter valid weight and reps for Set ${i + 1}.');
        return;
      }
      values.add((weight: weight, reps: reps));
    }
    if (values.isEmpty) {
      _showMessage('Enter at least one set.');
      return;
    }

    setState(() => _saving = true);
    try {
      // Replace ONLY today's records for this exercise. Previous dates remain untouched.
      final currentToday = await _database.getSetsByDate(
        userId: 'user1',
        date: DateTime.now(),
      );
      for (final set in currentToday.where(
        (s) => s.exerciseName == widget.exerciseName,
      )) {
        await _database.deleteSet(set.id);
      }
      for (final value in values) {
        await _database.saveSet(
          userId: 'user1',
          exerciseName: widget.exerciseName,
          weight: value.weight,
          reps: value.reps,
          date: DateTime.now(),
        );
      }
      await _loadData();
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage('Today\'s workout saved.');
    } catch (e) {
      debugPrint('Error saving today exercise: $e');
      if (mounted) {
        setState(() => _saving = false);
        _showMessage('Could not save today\'s workout.');
      }
    }
  }

  Future<void> _editHistorySet(WorkoutSet set) async {
    final weight = TextEditingController(text: _formatNumber(set.weight));
    final reps = TextEditingController(text: set.reps.toString());
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101C32),
        title: const Text('Edit Set'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: weight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reps,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Reps'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              final w = double.tryParse(weight.text.trim());
              final r = int.tryParse(reps.text.trim());
              if (w == null || w < 0 || r == null || r <= 0) return;
              await _database.updateSet(
                id: set.id,
                exerciseName: set.exerciseName,
                weight: w,
                reps: r,
              );
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
    weight.dispose();
    reps.dispose();
    if (result == true) await _loadData();
  }

  Future<void> _deleteHistorySet(WorkoutSet set) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101C32),
        title: const Text('Delete Set?'),
        content: Text(
          '${set.weight} kg × ${set.reps} reps on ${_formatDate(set.date)}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (result == true) {
      await _database.deleteSet(set.id);
      await _loadData();
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatNumber(num value) =>
      value.toDouble() == value.toDouble().roundToDouble()
      ? value.toDouble().toStringAsFixed(0)
      : value.toString();

  @override
  void dispose() {
    for (final c in _weightControllers) {
      c.dispose();
    }
    for (final c in _repsControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071329),
        elevation: 0,
        title: Text(widget.exerciseName),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF08285C),
                    Color(0xFF061A3B),
                    Color(0xFF050B18),
                  ],
                ),
              ),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                children: [
                  _sectionTitle('LAST WORKOUT'),
                  if (_lastWorkout.isEmpty)
                    _mutedCard('No previous workout for this exercise.')
                  else ...[
                    Text(
                      _formatDate(_lastWorkout.first.date),
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _referenceCard(_lastWorkout),
                  ],
                  const SizedBox(height: 24),
                  _sectionTitle('TODAY'),
                  Text(
                    _formatDate(DateTime.now()),
                    style: const TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    _weightControllers.length,
                    (i) => _todayRow(i),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _addSet,
                    icon: const Icon(Icons.add),
                    label: const Text('ADD SET'),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _saveToday,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('SAVE TODAY'),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _sectionTitle('HISTORY'),
                  const SizedBox(height: 10),
                  if (_history.isEmpty)
                    _mutedCard('No workout history yet.')
                  else
                    ..._historyCards(),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String title) => Text(
    title,
    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
  );

  Widget _mutedCard(String text) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.055),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white54)),
  );

  Widget _referenceCard(List<WorkoutSet> sets) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.055),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      children: sets
          .asMap()
          .entries
          .map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Text(
                      'Set ${e.key + 1}',
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      '${_formatNumber(e.value.weight)} kg × ${e.value.reps}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    ),
  );

  Widget _todayRow(int i) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        SizedBox(
          width: 52,
          child: Text(
            'Set ${i + 1}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ),
        Expanded(
          child: TextField(
            controller: _weightControllers[i],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              filled: true,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: _repsControllers[i],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Reps', filled: true),
          ),
        ),
      ],
    ),
  );

  List<Widget> _historyCards() {
    final grouped = <String, List<WorkoutSet>>{};
    for (final set in _history) {
      grouped.putIfAbsent(_dateKey(set.date), () => []).add(set);
    }
    final entries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return entries.map((entry) {
      final sets = entry.value;
      final date = sets.first.date;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(date),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...sets.asMap().entries.map(
              (e) => ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Set ${e.key + 1}   ${_formatNumber(e.value.weight)} kg × ${e.value.reps}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _editHistorySet(e.value),
                      icon: const Icon(Icons.edit_outlined, size: 19),
                    ),
                    IconButton(
                      onPressed: () => _deleteHistorySet(e.value),
                      icon: const Icon(Icons.delete_outline, size: 19),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}

// ============================================================
// COPY PREVIOUS WORKOUT / EXERCISE
// ============================================================
class CopyPreviousWorkoutScreen extends StatefulWidget {
  final String userId;
  final AppDatabase database;
  final String title;

  const CopyPreviousWorkoutScreen({
    super.key,
    required this.userId,
    required this.database,
    this.title = 'Copy Previous Workout',
  });

  @override
  State<CopyPreviousWorkoutScreen> createState() =>
      _CopyPreviousWorkoutScreenState();
}

class _CopyPreviousWorkoutScreenState extends State<CopyPreviousWorkoutScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<String> _workoutDates = {};
  List<WorkoutSet> _selectedDaySets = [];
  bool _loading = true;
  bool _loadingSets = false;
  bool _copying = false;
  Set<String> _selectedExerciseNames = {};
  List<WorkoutRoutine> _routineDates = [];
  List<RoutineSet> _selectedRoutineSets = [];

  Set<String> _exerciseNamesForSelectedDay() {
    return {
      for (final set in _selectedDaySets) set.exerciseName,
      for (final set in _selectedRoutineSets) set.exerciseName,
    };
  }

  @override
  void initState() {
    super.initState();
    _loadWorkoutDates();
  }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
  bool _hasWorkout(DateTime day) {
    final key = _dateKey(day);

    if (_workoutDates.contains(key)) {
      return true;
    }

    return _routineDates.any((routine) => _dateKey(routine.date) == key);
  }

  String _formatDate(DateTime d) {
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
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _loadWorkoutDates() async {
    final dates = await widget.database.getWorkoutDates(widget.userId);
    final routines = await widget.database.getWorkoutRoutines(
      userId: widget.userId,
    );

    if (!mounted) return;

    setState(() {
      _workoutDates = dates.map(_dateKey).toSet();
      _routineDates = routines;
      _loading = false;
    });
  }

  Future<void> _selectDate(DateTime selected, DateTime focused) async {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
      _loadingSets = true;
      _selectedDaySets = [];
      _selectedRoutineSets = [];
      _selectedExerciseNames = {};
    });

    if (isSameDay(selected, DateTime.now())) {
      setState(() => _loadingSets = false);
      _showMessage('Today cannot be used as a previous workout.');
      return;
    }

    final hasWorkout = _workoutDates.contains(_dateKey(selected));

    final routines = await widget.database.getWorkoutRoutinesByDate(
      userId: widget.userId,
      date: selected,
    );

    if (!hasWorkout && routines.isEmpty) {
      if (!mounted) return;

      setState(() => _loadingSets = false);
      _showMessage('No workout or routine on ${_formatDate(selected)}.');
      return;
    }

    List<WorkoutSet> workoutSets = [];

    if (hasWorkout) {
      workoutSets = await widget.database.getSetsByDate(
        userId: widget.userId,
        date: selected,
      );
    }

    final routineSets = <RoutineSet>[];

    for (final routine in routines) {
      final sets = await widget.database.getRoutineSets(routineId: routine.id);
      routineSets.addAll(sets);
    }

    if (!mounted) return;

    final exerciseNames = <String>{
      for (final set in workoutSets) set.exerciseName,
      for (final set in routineSets) set.exerciseName,
    };

    setState(() {
      _selectedDaySets = workoutSets;
      _selectedRoutineSets = routineSets;
      _selectedExerciseNames = exerciseNames;
      _loadingSets = false;
    });
  }

  bool get _allExercisesSelected {
    final names = _exerciseNamesForSelectedDay();
    return names.isNotEmpty && names.every(_selectedExerciseNames.contains);
  }

  void _toggleExercise(String exerciseName, bool selected) {
    setState(() {
      if (selected) {
        _selectedExerciseNames.add(exerciseName);
      } else {
        _selectedExerciseNames.remove(exerciseName);
      }
    });
  }

  void _toggleSelectAll(bool selected) {
    final names = _exerciseNamesForSelectedDay();
    setState(() {
      _selectedExerciseNames = selected ? names.toSet() : <String>{};
    });
  }

  Future<void> _copyToToday() async {
    if (_copying || _selectedExerciseNames.isEmpty) return;

    final selectedWorkoutSets = _selectedDaySets
        .where((set) => _selectedExerciseNames.contains(set.exerciseName))
        .toList();

    final selectedRoutineSets = _selectedRoutineSets
        .where((set) => _selectedExerciseNames.contains(set.exerciseName))
        .toList();

    if (selectedWorkoutSets.isEmpty && selectedRoutineSets.isEmpty) {
      return;
    }

    final totalSets = selectedWorkoutSets.length + selectedRoutineSets.length;

    final selectedExerciseCount = _selectedExerciseNames.length;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101C32),
        title: const Text('Copy to Today?'),
        content: Text(
          'Copy $selectedExerciseCount exercise'
          '${selectedExerciseCount == 1 ? '' : 's'} '
          '($totalSets sets) from '
          '${_formatDate(_selectedDay!)} to today?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('COPY'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _copying = true);

    try {
      // Copy actual workout sets.
      for (final set in selectedWorkoutSets) {
        await widget.database.saveSet(
          userId: widget.userId,
          exerciseName: set.exerciseName,
          weight: set.weight,
          reps: set.reps,
          date: DateTime.now(),
        );
      }

      // Copy planned routine sets as today's workout sets.
      for (final set in selectedRoutineSets) {
        await widget.database.saveSet(
          userId: widget.userId,
          exerciseName: set.exerciseName,
          weight: set.weight,
          reps: set.reps,
          date: DateTime.now(),
        );
      }

      if (!mounted) return;

      _showMessage('Selected exercises copied to today.');

      await Future<void>.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error copying workout: $e');

      if (mounted) {
        setState(() => _copying = false);
        _showMessage('Could not copy workout.');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071329),
        elevation: 0,
        title: Text(widget.title),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        TableCalendar<dynamic>(
                          firstDay: DateTime(2025, 1, 1),
                          lastDay: DateTime(2035, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (d) =>
                              isSameDay(_selectedDay, d),
                          eventLoader: (d) => _hasWorkout(d) ? [true] : [],
                          onDaySelected: _selectDate,
                          calendarFormat: CalendarFormat.month,
                          availableCalendarFormats: const {
                            CalendarFormat.month: 'Month',
                          },
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            defaultTextStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            weekendTextStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Color(0xFF1688C4),
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: const BoxDecoration(
                              color: Color(0xFF39D98A),
                              shape: BoxShape.circle,
                            ),
                            markerSize: 7,
                          ),
                          headerStyle: const HeaderStyle(
                            formatButtonVisible: false,
                            titleCentered: true,
                            titleTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        if (_loadingSets)
                          const CircularProgressIndicator()
                        else if (_selectedDaySets.isNotEmpty ||
                            _selectedRoutineSets.isNotEmpty)
                          _selectedWorkoutCard()
                        else
                          const Text(
                            'Select a previous workout date to see the workout.',
                            style: TextStyle(color: Colors.white54),
                          ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            (_selectedDaySets.isEmpty &&
                                    _selectedRoutineSets.isEmpty) ||
                                _copying
                            ? null
                            : _copyToToday,
                        child: _copying
                            ? const CircularProgressIndicator()
                            : const Text('COPY TO TODAY'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _selectedWorkoutCard() {
    final groupedWorkoutSets = <String, List<WorkoutSet>>{};
    for (final set in _selectedDaySets) {
      groupedWorkoutSets.putIfAbsent(set.exerciseName, () => []).add(set);
    }

    final groupedRoutineSets = <String, List<RoutineSet>>{};
    for (final set in _selectedRoutineSets) {
      groupedRoutineSets.putIfAbsent(set.exerciseName, () => []).add(set);
    }

    final exerciseNames = <String>{
      ...groupedWorkoutSets.keys,
      ...groupedRoutineSets.keys,
    }.toList()..sort();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _formatDate(_selectedDay!),
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Select the exercises you want to copy. All are selected by default.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 8),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            value: _allExercisesSelected,
            tristate: false,
            title: const Text(
              'SELECT ALL',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text(
              '${_selectedExerciseNames.length}/${exerciseNames.length} exercises selected',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            onChanged: (value) => _toggleSelectAll(value ?? false),
            activeColor: const Color(0xFF39D98A),
            checkColor: Colors.black,
          ),
          const Divider(color: Colors.white12),

          ...exerciseNames.map((exerciseName) {
            final workoutSets = groupedWorkoutSets[exerciseName] ?? [];
            final routineSets = groupedRoutineSets[exerciseName] ?? [];

            final totalSets = workoutSets.length + routineSets.length;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    value: _selectedExerciseNames.contains(exerciseName),
                    title: Text(
                      exerciseName,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '$totalSets set${totalSets == 1 ? '' : 's'}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 11,
                      ),
                    ),
                    onChanged: (value) =>
                        _toggleExercise(exerciseName, value ?? false),
                    activeColor: const Color(0xFF39D98A),
                    checkColor: Colors.black,
                  ),

                  if (routineSets.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Column(
                        children: routineSets.asMap().entries.map((x) {
                          final set = x.value;

                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Planned Set ${x.key + 1}   '
                              '${set.weight} kg × ${set.reps}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  if (workoutSets.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 48),
                      child: Column(
                        children: workoutSets.asMap().entries.map((x) {
                          final set = x.value;

                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Set ${x.key + 1}   '
                              '${set.weight} kg × ${set.reps}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class ExerciseHistoryScreen extends StatefulWidget {
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
  State<ExerciseHistoryScreen> createState() => _ExerciseHistoryScreenState();
}

class _ExerciseHistoryScreenState extends State<ExerciseHistoryScreen> {
  bool _loading = true;

  Map<String, List<WorkoutSet>> _history = {};

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
      final sets = await widget.database.getExerciseHistory(
        userId: widget.userId,
        exerciseName: widget.exerciseName,
      );

      final Map<String, List<WorkoutSet>> grouped = {};

      for (final set in sets) {
        final dateKey =
            '${set.date.year}-'
            '${set.date.month.toString().padLeft(2, '0')}-'
            '${set.date.day.toString().padLeft(2, '0')}';

        grouped.putIfAbsent(dateKey, () => []);

        grouped[dateKey]!.add(set);
      }

      if (!mounted) return;

      setState(() {
        _history = grouped;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading history: $e');

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071329),
        elevation: 0,
        title: Text(widget.exerciseName),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF08285C), Color(0xFF061A3B), Color(0xFF050B18)],
            stops: [0.0, 0.38, 1.0],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _history.isEmpty
            ? const Center(
                child: Text(
                  'No workout history yet.',
                  style: TextStyle(color: Colors.white60),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(18),
                children:
                    (_history.entries.toList()
                          ..sort((a, b) => b.key.compareTo(a.key)))
                        .map((entry) {
                          return _historyDayCard(entry.key, entry.value);
                        })
                        .toList(),
              ),
      ),
    );
  }

  // ============================================================
  // HISTORY DAY CARD
  // ============================================================

  Widget _historyDayCard(String date, List<WorkoutSet> sets) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),

          ...sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Text(
                    'Set ${index + 1}',
                    style: const TextStyle(fontSize: 13, color: Colors.white60),
                  ),

                  const Spacer(),

                  Text(
                    '${set.weight} kg × ${set.reps}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
