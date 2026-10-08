import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import '../calendar/user1_calendar_screen.dart';
import '../../utils/exercise_catalog.dart';
import '../../services/database_service.dart';
import '../../theme/app_theme.dart';

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
  bool _loading = true;

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

      if (!mounted) return;

      setState(() {
        _todaySets = sets;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading User 1 exercises: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
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

  int _setCount(String exerciseName) {
    return _todaySets.where((set) => set.exerciseName == exerciseName).length;
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

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

  Future<void> _createNewExercise() async {
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text(
          'Create New Exercise',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Exercise name',
            hintText: 'e.g. Cable Crossover',
            labelStyle: const TextStyle(color: Colors.white54),
            hintStyle: const TextStyle(color: Colors.white30),
            filled: true,
            fillColor: AppTheme.surfaceElevated,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onSubmitted: (value) => Navigator.pop(dialogContext, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('ADD'),
          ),
        ],
      ),
    );

    controller.dispose();

    if (!mounted || name == null) return;

    final clean = name.trim();
    if (clean.isEmpty) return;

    final library = await _database.getExerciseLibrary(userId: widget.userId);

    final existsInDefaults = ExerciseCatalog.defaultExercises.any(
      (exercise) => exercise.toLowerCase() == clean.toLowerCase(),
    );

    final existsInLibrary = library.any(
      (item) => item.exerciseName.toLowerCase() == clean.toLowerCase(),
    );

    if (existsInDefaults || existsInLibrary) {
      _showMessage('Exercise already exists.');
      final existingName = existsInDefaults
          ? ExerciseCatalog.defaultExercises.firstWhere(
              (exercise) => exercise.toLowerCase() == clean.toLowerCase(),
            )
          : library
                .firstWhere(
                  (item) =>
                      item.exerciseName.toLowerCase() == clean.toLowerCase(),
                )
                .exerciseName;
      await _openExercise(existingName);
      return;
    }

    await _database.saveExerciseLibraryItem(
      userId: widget.userId,
      exerciseName: clean,
    );

    if (!mounted) return;

    _showMessage('$clean added to Exercise Library.');
    await _openExercise(clean);
  }

  Future<void> _showExercisePicker() async {
    final library = await _database.getExerciseLibrary(userId: widget.userId);

    final exerciseNames = <String>[...ExerciseCatalog.defaultExercises];

    for (final item in library) {
      final name = item.exerciseName.trim();
      if (name.isEmpty) continue;
      if (!exerciseNames.any(
        (exercise) => exercise.toLowerCase() == name.toLowerCase(),
      )) {
        exerciseNames.add(name);
      }
    }

    exerciseNames.sort();

    if (!mounted) return;

    final selectedExercise = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.80,
            child: Column(
              children: [
                const SizedBox(height: 16),

                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'SELECT EXERCISE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                ListTile(
                  leading: const Icon(
                    Icons.add_circle_outline,
                    color: AppTheme.primaryLight,
                  ),
                  title: const Text(
                    'CREATE NEW EXERCISE',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: const Text(
                    'Add an exercise that is not in the list',
                    style: TextStyle(color: Colors.white54),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.white54,
                  ),
                  onTap: () {
                    Navigator.pop(sheetContext);
                    _createNewExercise();
                  },
                ),

                const Divider(color: Colors.white12, height: 20),

                Expanded(
                  child: ListView.builder(
                    itemCount: exerciseNames.length,
                    itemBuilder: (_, index) {
                      final exercise = exerciseNames[index];

                      return ListTile(
                        title: Text(
                          exercise,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: const Text(
                          'Exercise',
                          style: TextStyle(color: Colors.white54),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                        ),
                        onTap: () {
                          Navigator.pop(sheetContext, exercise);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (selectedExercise == null || !mounted) {
      return;
    }

    await _openExercise(selectedExercise);
  }

  Future<void> _openCopyPreviousExercise() async {
    final result = await Navigator.push<Map<String, List<_CopiedSetDraft>>>(
      context,
      MaterialPageRoute(
        builder: (_) => CopyPreviousWorkoutScreen(
          userId: widget.userId,
          database: _database,
          title: 'Copy Previous Workout',
        ),
      ),
    );

    if (!mounted || result == null || result.isEmpty) {
      return;
    }

    // Copying prepares a draft only. It does not create WorkoutSets.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _CopiedWorkoutDraftScreen(
          userId: widget.userId,
          database: _database,
          copiedSets: result,
        ),
      ),
    );

    await _loadTodayWorkout();
  }

  Future<void> _deleteTodayExercise(String exerciseName) async {
    final exerciseSets = _todaySets
        .where((set) => set.exerciseName == exerciseName)
        .toList();

    if (exerciseSets.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Delete Exercise?'),
          content: Text(
            'Delete $exerciseName and its '
            '${exerciseSets.length} '
            'set${exerciseSets.length == 1 ? '' : 's'} from today?',
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
        );
      },
    );

    if (confirmed != true) return;

    try {
      for (final set in exerciseSets) {
        await _database.deleteSet(id: set.id, userId: widget.userId);
      }

      await _loadTodayWorkout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$exerciseName deleted from today.')),
        );
      }
    } catch (e) {
      debugPrint('Error deleting exercise: $e');
    }
  }

  Future<void> _deleteAllTodayExercises() async {
    if (_todaySets.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text("Delete Today's Workout?"),
          content: const Text(
            "This will delete all exercises and sets recorded for User 1 today. "
            "Previous workout dates will not be affected.",
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
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _database.deleteAllSetsByDate(
        userId: widget.userId,
        date: DateTime.now(),
      );

      await _loadTodayWorkout();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Today's workout deleted.")),
        );
      }
    } catch (e) {
      debugPrint("Error deleting today's workout: $e");
    }
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text(
          'Exercise',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
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
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
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
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'No exercises for today.',
                          style: TextStyle(color: Colors.white38, fontSize: 13),
                        ),
                      )
                    else
                      ...exercises.map((exercise) => _exerciseCard(exercise)),
                    const SizedBox(height: 14),
                    _copyWorkoutCard(),
                    const SizedBox(height: 8),
                    _addExerciseCard(),

                    const SizedBox(height: 8),
                    _calendarCard(),

                    if (exercises.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      _deleteTodayCard(),
                    ],
                    if (!widget.homeMode) ...[
                      const SizedBox(height: 8),
                      _createRoutineCard(),
                      const SizedBox(height: 8),
                      _myRoutinesCard(),
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
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppTheme.primaryLight.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.fitness_center_outlined,
                color: AppTheme.primaryLight,
                size: 20,
              ),
            ),
            const SizedBox(width: 13),
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
                  const SizedBox(height: 4),
                  Text(
                    '$count ${count == 1 ? 'set' : 'sets'}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (!widget.homeMode)
              IconButton(
                onPressed: () => _deleteTodayExercise(exerciseName),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 18,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            const Icon(Icons.chevron_right, color: Colors.white38, size: 21),
          ],
        ),
      ),
    );
  }

  Widget _copyWorkoutCard() {
    return _actionCard(
      icon: Icons.content_copy_outlined,
      iconColor: Colors.white70,
      title: 'COPY PREVIOUS WORKOUT',
      onTap: _openCopyPreviousExercise,
    );
  }

  Widget _addExerciseCard() {
    return _actionCard(
      icon: Icons.add_circle_outline,
      iconColor: AppTheme.primaryLight,
      title: 'ADD EXERCISE',
      onTap: _showExercisePicker,
    );
  }

  Widget _calendarCard() {
    return _actionCard(
      icon: Icons.calendar_month_outlined,
      iconColor: AppTheme.primaryLight,
      title: 'CALENDAR',
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const User1CalendarScreen()),
        );

        await _loadTodayWorkout();
      },
    );
  }

  Widget _deleteTodayCard() {
    return _actionCard(
      icon: Icons.delete_outline,
      iconColor: Colors.redAccent,
      title: "DELETE TODAY'S WORKOUT",
      titleColor: Colors.redAccent,
      onTap: _deleteAllTodayExercises,
    );
  }

  Widget _createRoutineCard() {
    return _actionCard(
      icon: Icons.event_note_outlined,
      iconColor: Colors.orangeAccent,
      title: 'CREATE NEW ROUTINE',
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CreateRoutineScreen(userId: widget.userId, database: _database),
          ),
        );

        await _loadTodayWorkout();
      },
    );
  }

  Widget _myRoutinesCard() {
    return _actionCard(
      icon: Icons.calendar_month_outlined,
      iconColor: AppTheme.primaryLight,
      title: 'MY ROUTINES',
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                MyRoutinesScreen(userId: widget.userId, database: _database),
          ),
        );

        await _loadTodayWorkout();
      },
    );
  }

  Widget _actionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
          ),
          child: Row(
            children: [
              Icon(icon, size: 19, color: iconColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: titleColor ?? Colors.white,
                    letterSpacing: 0.15,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 20, color: Colors.white38),
            ],
          ),
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
        userId: widget.userId,
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
      backgroundColor: AppTheme.surface,
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

    for (
      var exerciseIndex = 0;
      exerciseIndex < _exercises.length;
      exerciseIndex++
    ) {
      final exercise = _exercises[exerciseIndex];
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
  userId: widget.userId,
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
          userId: widget.userId,
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          widget.routine == null ? 'Create Routine' : 'Edit Routine',
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.15,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
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
                      color: AppTheme.primaryLight,
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
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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
        backgroundColor: AppTheme.surface,
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
    await widget.database.deleteWorkoutRoutine(
  id: routine.id,
  userId: widget.userId,
);
    await _load();
  }

  Future<void> _deleteAllRoutines() async {
    if (_routines.isEmpty) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surface,
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text(
          'My Routines',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.15,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
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
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.06),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.14),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ],
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
      future: widget.database.getRoutineSets(
        routineId: routine.id,
        userId: widget.userId,
      ),
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
                        color: AppTheme.primaryLight,
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
        userId: widget.userId,
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

      for (var i = 0; i < values.length; i++) {
        final value = values[i];

        await widget.database.saveSet(
          userId: widget.userId,
          exerciseName: value.exerciseName,
          weight: value.weight,
          reps: value.reps,
          date: performedDate,
        );

        await widget.database.updateRoutineSet(
          id: value.routineSetId,
          userId: widget.userId,
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text(
          'Start Workout',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.15,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
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
  final List<String> exerciseNames;

  const AddExerciseScreen({super.key, required this.exerciseNames});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _creatingNew = false;

  void _selectExisting(String exerciseName) {
    Navigator.of(context).pop(exerciseName);
  }

  void _createNew() {
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text(
          'Add Exercise',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.15,
          ),
        ),
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
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
          children: [
            const Text(
              'SELECT EXERCISE',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),

            if (!_creatingNew) ...[
              ...widget.exerciseNames.map(
                (exerciseName) => InkWell(
                  onTap: () => _selectExisting(exerciseName),
                  borderRadius: BorderRadius.circular(10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 2,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            exerciseName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Colors.white54),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 18),

            if (_creatingNew) ...[
              TextField(
                controller: _controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _createNew(),
                decoration: InputDecoration(
                  labelText: 'Exercise name',
                  hintText: 'e.g. Incline Dumbbell Press',
                  filled: true,
                  fillColor: AppTheme.surfaceElevated,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _createNew,
                  icon: const Icon(Icons.add),
                  label: const Text('ADD NEW EXERCISE'),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() {
                    _creatingNew = false;
                    _controller.clear();
                  });
                },
                child: const Text('BACK TO EXERCISES'),
              ),
            ] else ...[
              const Divider(color: Colors.white12, height: 28),
              InkWell(
                onTap: () {
                  setState(() {
                    _creatingNew = true;
                  });
                },
                borderRadius: BorderRadius.circular(10),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: AppTheme.primaryLight),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'CREATE NEW EXERCISE',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class User1ExerciseDetailScreen extends StatefulWidget {
  final String exerciseName;
  final AppDatabase database;
  final DateTime? workoutDate;

  const User1ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
    required this.database,
    this.workoutDate,
  });

  @override
  State<User1ExerciseDetailScreen> createState() =>
      _User1ExerciseDetailScreenState();
}

class _User1ExerciseDetailScreenState extends State<User1ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  late AppDatabase _database;
  late TabController _tabController;
  late DateTime _workoutDate;

  List<WorkoutSet> _todaySets = [];
  List<WorkoutSet> _history = [];
  List<WorkoutSet> _otherUserHistory = [];

  List<TextEditingController> _weightControllers = [];
  List<TextEditingController> _repsControllers = [];

  bool _loading = true;
  bool _saving = false;

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
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

  String _formatNumber(num value) {
    final d = value.toDouble();
    return d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toString();
  }

  @override
  void initState() {
    super.initState();

    _database = widget.database;
    _workoutDate = DateTime(
      (widget.workoutDate ?? DateTime.now()).year,
      (widget.workoutDate ?? DateTime.now()).month,
      (widget.workoutDate ?? DateTime.now()).day,
    );

    _tabController = TabController(length: 3, vsync: this);

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final today = await _database.getSetsByDate(
        userId: 'user1',
        date: _workoutDate,
      );

      final history = await _database.getExerciseHistory(
        userId: 'user1',
        exerciseName: widget.exerciseName,
      );

      final otherUserHistory = await _database.getExerciseHistory(
        userId: 'user2',
        exerciseName: widget.exerciseName,
      );

      if (!mounted) return;

      _disposeControllers();

      setState(() {
        _todaySets = today
            .where((set) => set.exerciseName == widget.exerciseName)
            .toList();

        _history = history;
        _otherUserHistory = otherUserHistory;
        _loading = false;
      });

      _loadTodayControllers();
    } catch (e) {
      debugPrint('Error loading User 1 exercise detail: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  void _loadTodayControllers() {
    final source = _todaySets;

    final count = source.isEmpty ? 3 : source.length;

    _weightControllers = List.generate(
      count,
      (index) => TextEditingController(
        text: index < source.length ? _formatNumber(source[index].weight) : '',
      ),
    );

    _repsControllers = List.generate(
      count,
      (index) => TextEditingController(
        text: index < source.length ? source[index].reps.toString() : '',
      ),
    );
  }

  void _disposeControllers() {
    for (final controller in _weightControllers) {
      controller.dispose();
    }

    for (final controller in _repsControllers) {
      controller.dispose();
    }

    _weightControllers = [];
    _repsControllers = [];
  }

  void _addSet() {
    setState(() {
      _weightControllers.add(TextEditingController());

      _repsControllers.add(TextEditingController());
    });
  }

  void _removeSet(int index) {
    if (_weightControllers.length <= 1) return;

    final weight = _weightControllers.removeAt(index);
    final reps = _repsControllers.removeAt(index);

    weight.dispose();
    reps.dispose();

    setState(() {});
  }

  Future<void> _saveWorkout() async {
    if (_saving) return;

    final values = <({double weight, int reps})>[];

    for (var i = 0; i < _weightControllers.length; i++) {
      final weightText = _weightControllers[i].text.trim();
      final repsText = _repsControllers[i].text.trim();

      if (weightText.isEmpty && repsText.isEmpty) {
        continue;
      }

      final weight = double.tryParse(weightText);
      final reps = int.tryParse(repsText);

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

    setState(() {
      _saving = true;
    });

    try {
      final today = _workoutDate;

      final currentToday = await _database.getSetsByDate(
        userId: 'user1',
        date: today,
      );

      for (final set in currentToday.where(
        (s) => s.exerciseName == widget.exerciseName,
      )) {
        await _database.deleteSet(id: set.id, userId: 'user1');
      }

      for (var i = 0; i < values.length; i++) {
        final value = values[i];

        await _database.saveSet(
          userId: 'user1',
          exerciseName: widget.exerciseName,
          weight: value.weight,
          reps: value.reps,
          date: today,
        );
      }

      await _loadData();

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage('Workout saved successfully.');
    } catch (e) {
      debugPrint('Error saving User 1 exercise: $e');

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage('Could not save workout.');
    }
  }

  Future<void> _editHistorySet(WorkoutSet set) async {
    final weightController = TextEditingController(
      text: _formatNumber(set.weight),
    );

    final repsController = TextEditingController(text: set.reps.toString());

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Edit Set'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  filled: true,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: repsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Reps',
                  filled: true,
                ),
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
                final weight = double.tryParse(weightController.text.trim());

                final reps = int.tryParse(repsController.text.trim());

                if (weight == null || weight < 0 || reps == null || reps <= 0) {
                  return;
                }

                await _database.updateSet(
                  id: set.id,
                  userId: 'user1',
                  exerciseName: set.exerciseName,
                  weight: weight,
                  reps: reps,
                );

                if (ctx.mounted) {
                  Navigator.pop(ctx, true);
                }
              },
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    weightController.dispose();
    repsController.dispose();

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _deleteHistorySet(WorkoutSet set) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTheme.surface,
          title: const Text('Delete Set?'),
          content: Text(
            '${_formatNumber(set.weight)} kg × '
            '${set.reps} reps on ${_formatDate(set.date)}',
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
        );
      },
    );

    if (confirmed != true) return;

    await _database.deleteSet(id: set.id, userId: 'user1');
    await _loadData();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _disposeControllers();
    _tabController.dispose();
    super.dispose();
  }

  Widget _otherUserHistoryTab() {
    if (_otherUserHistory.isEmpty) {
      return const Center(
        child: Text(
          'No User 2 history for this exercise.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final grouped = <DateTime, List<WorkoutSet>>{};
    for (final set in _otherUserHistory) {
      final date = DateTime(set.date.year, set.date.month, set.date.day);
      grouped.putIfAbsent(date, () => []).add(set);
    }

    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.person_outline, color: AppTheme.primaryLight),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'User 2 • Read-only history',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...dates.map((date) {
          final sets = grouped[date]!;
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF111D34),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                ...List.generate(sets.length, (index) {
                  final set = sets[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Set ${index + 1}    ${_formatNumber(set.weight)} kg × ${set.reps}',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 13,
                      ),
                    ),
                  );
                }),
              ],
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          widget.exerciseName,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.15,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryLight,
          indicatorSize: TabBarIndicatorSize.label,
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'TRACK'),
            Tab(text: 'HISTORY'),
            Tab(text: 'OTHER USER'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
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
                  stops: [0.0, 0.38, 1.0],
                ),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [_trackTab(), _historyTab(), _otherUserHistoryTab()],
              ),
            ),
    );
  }

  Widget _trackTab() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
      children: [
        const Text(
          'TODAY',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 5),
        Text(
          _formatDate(_workoutDate),
          style: const TextStyle(color: Colors.white60, fontSize: 13),
        ),
        const SizedBox(height: 18),
        ...List.generate(_weightControllers.length, (index) => _setRow(index)),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: _addSet,
          icon: const Icon(Icons.add),
          label: const Text('ADD SET'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _saving ? null : _saveWorkout,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'SAVE WORKOUT',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _setRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Text(
              'SET ${index + 1}',
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _weightControllers[index],
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
              controller: _repsControllers[index],
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Reps',
                filled: true,
              ),
            ),
          ),
          if (_weightControllers.length > 1)
            IconButton(
              onPressed: () => _removeSet(index),
              icon: const Icon(
                Icons.remove_circle_outline,
                color: Colors.white54,
                size: 19,
              ),
            ),
        ],
      ),
    );
  }

  Widget _historyTab() {
    if (_history.isEmpty) {
      return const Center(
        child: Text(
          'No workout history yet.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    final grouped = <String, List<WorkoutSet>>{};

    for (final set in _history) {
      grouped.putIfAbsent(_dateKey(set.date), () => []).add(set);
    }

    final entries = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
      children: entries.map((entry) {
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
              ...sets.asMap().entries.map((entry) {
                final set = entry.value;

                return ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Set ${entry.key + 1}   '
                    '${_formatNumber(set.weight)} kg × ${set.reps}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () => _editHistorySet(set),
                        icon: const Icon(Icons.edit_outlined, size: 19),
                      ),
                      IconButton(
                        onPressed: () => _deleteHistorySet(set),
                        icon: const Icon(Icons.delete_outline, size: 19),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      }).toList(),
    );
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
      final sets = await widget.database.getRoutineSets(
        routineId: routine.id,
        userId: widget.userId,
      );
      routineSets.addAll(sets);
    }

    if (!mounted) return;

    setState(() {
      _selectedDaySets = workoutSets;
      _selectedRoutineSets = routineSets;
      // Nothing is selected automatically. The user chooses exercises.
      _selectedExerciseNames = {};
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
        backgroundColor: AppTheme.surface,
        title: const Text('Prepare Workout?'),
        content: Text(
          "Prepare $selectedExerciseCount exercise"
          "${selectedExerciseCount == 1 ? '' : 's'} "
          "($totalSets sets) from '${_formatDate(_selectedDay!)}' for today?\n\n"
          "This only pre-fills the workout. It will NOT count as today's "
          "workout until you press SAVE WORKOUT.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('PREPARE'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _copying = true);

    try {
      final drafts = <String, List<_CopiedSetDraft>>{};

      for (final set in selectedWorkoutSets) {
        drafts.putIfAbsent(set.exerciseName, () => []).add(
          _CopiedSetDraft(weight: set.weight, reps: set.reps),
        );
      }

      for (final set in selectedRoutineSets) {
        drafts.putIfAbsent(set.exerciseName, () => []).add(
          _CopiedSetDraft(weight: set.weight, reps: set.reps),
        );
      }

      if (mounted) {
        Navigator.pop(context, drafts);
      }
    } catch (e) {
      debugPrint('Error preparing copied workout: $e');

      if (mounted) {
        setState(() => _copying = false);
        _showMessage('Could not prepare workout.');
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.15,
          ),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 18,
                              sigmaY: 18,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    const Color(0xFF0A315C).withValues(alpha: 0.58),
                                    AppTheme.surface.withValues(alpha: 0.48),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.08),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF3D8BFF).withValues(alpha: 0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: TableCalendar<dynamic>(
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
                              color: AppTheme.primary,
                              shape: BoxShape.circle,
                            ),
                            todayDecoration: BoxDecoration(
                              color: const Color(0xFF3D8BFF).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            markerDecoration: const BoxDecoration(
                              color: AppTheme.success,
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
                            _selectedExerciseNames.isEmpty || _copying
                                ? null
                                : _copyToToday,
                        child: _copying
                            ? const CircularProgressIndicator()
                            : const Text('PREPARE FOR TODAY'),
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
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
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
            'Select the exercises you want to prepare for today. '
            'Nothing is logged until you save the workout.',
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


class _CopiedSetDraft {
  final double weight;
  final int reps;

  const _CopiedSetDraft({
    required this.weight,
    required this.reps,
  });
}

class _DraftSetControllers {
  final TextEditingController weightController;
  final TextEditingController repsController;

  _DraftSetControllers({
    String weight = '',
    String reps = '',
  })  : weightController = TextEditingController(text: weight),
        repsController = TextEditingController(text: reps);

  void dispose() {
    weightController.dispose();
    repsController.dispose();
  }
}

class _DraftExercise {
  final String exerciseName;
  final List<_DraftSetControllers> sets;

  _DraftExercise({
    required this.exerciseName,
    required this.sets,
  });

  void dispose() {
    for (final set in sets) {
      set.dispose();
    }
  }
}

class _CopiedWorkoutDraftScreen extends StatefulWidget {
  final String userId;
  final AppDatabase database;
  final Map<String, List<_CopiedSetDraft>> copiedSets;

  const _CopiedWorkoutDraftScreen({
    required this.userId,
    required this.database,
    required this.copiedSets,
  });

  @override
  State<_CopiedWorkoutDraftScreen> createState() =>
      _CopiedWorkoutDraftScreenState();
}

class _CopiedWorkoutDraftScreenState extends State<_CopiedWorkoutDraftScreen> {
  late final List<_DraftExercise> _exercises;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _exercises = widget.copiedSets.entries.map((entry) {
      return _DraftExercise(
        exerciseName: entry.key,
        sets: entry.value
            .map(
              (set) => _DraftSetControllers(
                weight: _formatNumber(set.weight),
                reps: set.reps.toString(),
              ),
            )
            .toList(),
      );
    }).toList();
  }

  String _formatNumber(num value) {
    final d = value.toDouble();
    return d == d.roundToDouble() ? d.toStringAsFixed(0) : d.toString();
  }

  void _addSet(_DraftExercise exercise) {
    setState(() {
      exercise.sets.add(_DraftSetControllers());
    });
  }

  void _removeSet(_DraftExercise exercise, int index) {
    if (exercise.sets.length <= 1) return;

    final set = exercise.sets.removeAt(index);
    set.dispose();
    setState(() {});
  }

  Future<void> _saveWorkout() async {
    if (_saving) return;

    final values = <({String exerciseName, double weight, int reps})>[];

    for (final exercise in _exercises) {
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
            'Enter valid weight and reps for ${exercise.exerciseName}, '
            'Set ${i + 1}.',
          );
          return;
        }

        values.add(
          (
            exerciseName: exercise.exerciseName,
            weight: weight,
            reps: reps,
          ),
        );
      }
    }

    if (values.isEmpty) {
      _showMessage('Enter at least one set.');
      return;
    }

    setState(() => _saving = true);

    try {
      final today = DateTime.now();

      // Only this explicit action creates real WorkoutSets. Until now,
      // copying was only a local draft and could not count as a workout day.
      for (final value in values) {
        await widget.database.saveSet(
          userId: widget.userId,
          exerciseName: value.exerciseName,
          weight: value.weight,
          reps: value.reps,
          date: today,
        );
      }

      if (!mounted) return;

      _showMessage('Workout saved successfully.');
      await Future<void>.delayed(const Duration(milliseconds: 350));

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint('Error saving prepared workout: $e');

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
    for (final exercise in _exercises) {
      exercise.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: const Text(
          'Prepared Workout',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.15,
          ),
        ),
      ),
      body: Container(
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
                children: [
                  const Text(
                    "TODAY'S PREPARED WORKOUT",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'These sets are only prepared. Save the workout when you '
                    'actually perform it.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ..._exercises.map(_exerciseCard),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _saveWorkout,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'SAVE WORKOUT',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseCard(_DraftExercise exercise) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.14),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            exercise.exerciseName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ...exercise.sets.asMap().entries.map((entry) {
            final index = entry.key;
            final set = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  SizedBox(
                    width: 45,
                    child: Text(
                      'Set ${index + 1}',
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
                        labelText: 'Weight kg',
                        filled: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
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
                  if (exercise.sets.length > 1)
                    IconButton(
                      onPressed: () => _removeSet(exercise, index),
                      icon: const Icon(
                        Icons.remove_circle_outline,
                        color: Colors.white54,
                        size: 19,
                      ),
                    ),
                ],
              ),
            );
          }),
          TextButton.icon(
            onPressed: () => _addSet(exercise),
            icon: const Icon(Icons.add, size: 17),
            label: const Text('ADD SET'),
          ),
        ],
      ),
    );
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          widget.exerciseName,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.15,
          ),
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
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
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
