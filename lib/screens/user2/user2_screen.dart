import 'package:flutter/material.dart';

import '../../services/database_service.dart';
import 'user2_calendar_screen.dart';
import 'user2_copy_workout_screen.dart';

class User2Screen extends StatefulWidget {
  const User2Screen({super.key});

  @override
  State<User2Screen> createState() => _User2ScreenState();
}

class _User2ScreenState extends State<User2Screen> {
  final AppDatabase _database = AppDatabase();

  // ------------------------------------------------------------
  // USER 2 WEEKLY WORKOUT PLAN
  // Fixed order for each training day.
  // Actual sets are still stored separately in the database.
  // ------------------------------------------------------------

  static const Map<int, List<String>> weeklyWorkoutPlan = {
    DateTime.monday: [
      'Incline Chest Press Machine',
      'Machine Chest Press',
      'Pec Deck Fly',
      'Rope Triceps Pushdown',
      'Overhead Rope Extension',
      'Crunch Machine',
    ],
    DateTime.tuesday: [
      'Lat Pulldown',
      'Chest Supported Row',
      'Straight Arm Pulldown',
      'Face Pull',
      'Cable Curl',
    ],
    DateTime.wednesday: [
      'Hip Thrust',
      'Romanian Deadlift',
      'Bulgarian Split Squat',
      'Walking Lunges',
      'Lying Leg Curl',
      'Hip Abduction Machine',
    ],
    DateTime.thursday: [
      'Machine Chest Press',
      'Machine Shoulder Press',
      'Lateral Raise',
      'Rear Delt Fly',
      'Crunch Machine',
    ],
    DateTime.friday: [
      'Lat Pulldown',
      'Close Grip Seated Cable Row',
      'Face Pull',
      'Rear Delt Fly',
      'Hammer Curl',
      'Cable Curl',
    ],
    DateTime.saturday: [
      'Hip Thrust Machine',
      'Hack Squat',
      'Smith Machine Squat',
      'Leg Press',
      'Leg Extension',
      'Hip Abduction Machine',
    ],
  };

  List<WorkoutSet> _todaySets = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTodayWorkout();
  }

  // ============================================================
  // LOAD TODAY'S ACTUAL WORKOUT
  // ============================================================

  Future<void> _loadTodayWorkout() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    final today = DateTime.now();

    final sets = await _database.getSetsByDate(
      userId: 'user2',
      date: today,
    );

    if (!mounted) return;

    setState(() {
      _todaySets = sets;
      _loading = false;
    });
  }

  // ============================================================
  // UNIQUE EXERCISES RECORDED TODAY
  // ============================================================

  List<String> _todayExercises() {
    final planned = weeklyWorkoutPlan[DateTime.now().weekday];
    final recorded = <String>[];

    for (final set in _todaySets) {
      if (!recorded.contains(set.exerciseName)) {
        recorded.add(set.exerciseName);
      }
    }

    // Show the fixed User 2 order first, then any manually tracked
    // exercise that is not part of today's plan.
    if (planned != null) {
      final result = <String>[...planned];

      for (final exercise in recorded) {
        if (!result.contains(exercise)) {
          result.add(exercise);
        }
      }

      return result;
    }

    return recorded;
  }

  // ============================================================
  // SET COUNT FOR EXERCISE
  // ============================================================

  int _setCount(String exerciseName) {
    return _todaySets
        .where(
          (set) => set.exerciseName == exerciseName,
        )
        .length;
  }

  // ============================================================
  // OPEN EXERCISE
  // ============================================================

  Future<void> _openExercise(
    String exerciseName,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          exerciseName: exerciseName,
          target: 'User 2 workout',
        ),
      ),
    );

    await _loadTodayWorkout();
  }

  // ============================================================
  // COPY PREVIOUS WORKOUT
  // ============================================================

  Future<void> _openCopyWorkout() async {
    final copied = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const User2CopyWorkoutScreen(),
      ),
    );

    if (copied == true) {
      await _loadTodayWorkout();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Workout copied to today.',
          ),
        ),
      );
    } else {
      // Even if the copy screen does not return true,
      // refresh once when coming back.
      await _loadTodayWorkout();
    }
  }

  // ============================================================
  // DELETE ALL TODAY'S EXERCISES
  // ============================================================

  Future<void> _deleteAllTodayWorkout() async {
    if (_todaySets.isEmpty) {
      _showMessage('No workout recorded today.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Delete All Today's Exercises?",
          ),
          content: Text(
            'This will permanently delete '
            '${_todaySets.length} sets from today for User 2.\n\n'
            'Previous workout days will not be affected.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text(
                'DELETE ALL',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _database.deleteAllSetsByDate(
      userId: 'user2',
      date: DateTime.now(),
    );

    await _loadTodayWorkout();

    if (!mounted) return;

    _showMessage("All today's exercises have been deleted.");
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // OPEN CALENDAR
  // ============================================================

  Future<void> _openCalendar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const User2CalendarScreen(),
      ),
    );

    await _loadTodayWorkout();
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

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

  // ============================================================
  // EXERCISE CARD
  // ============================================================

  Widget _exerciseCard(
    String exerciseName,
  ) {
    final count = _setCount(exerciseName);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        title: Text(
          exerciseName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(
            '$count sets recorded',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          color: Colors.white54,
        ),
        onTap: () {
          _openExercise(exerciseName);
        },
      ),
    );
  }

  // ============================================================
  // EMPTY TODAY
  // ============================================================

  Widget _emptyToday() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 30,
      ),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 42,
            color: Colors.white38,
          ),
          SizedBox(height: 12),
          Text(
            'No workout recorded today',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Copy a previous workout or start tracking an exercise.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white54,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // COPY CARD
  // ============================================================

  Widget _copyWorkoutCard() {
    return Container(
      margin: const EdgeInsets.only(
        top: 8,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.08,
          ),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.cyan.withValues(
              alpha: 0.12,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.copy,
            color: Colors.cyan,
          ),
        ),
        title: const Text(
          'COPY PREVIOUS WORKOUT',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Choose any previous workout and copy it to today',
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
        onTap: _openCopyWorkout,
      ),
    );
  }

  // ============================================================
  // DELETE ALL TODAY CARD
  // ============================================================

  Widget _deleteAllTodayCard() {
    return Container(
      margin: const EdgeInsets.only(
        top: 4,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.35),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.red,
          ),
        ),
        title: const Text(
          "DELETE ALL TODAY'S EXERCISES",
          style: TextStyle(
            color: Colors.red,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Delete every set recorded today for User 2',
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
        onTap: _deleteAllTodayWorkout,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final todayExercises = _todayExercises();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        title: const Text(
          'User 2',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.calendar_month,
            ),
            tooltip: 'Workout Calendar',
            onPressed: _openCalendar,
          ),
        ],
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _loadTodayWorkout,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  const Text(
                    'TODAY',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    _formatDate(DateTime.now()),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // TODAY SUMMARY
                  // ==================================================

                  if (_todaySets.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(
                        bottom: 16,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1D24),
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'TODAY\'S WORKOUT',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '${todayExercises.length} exercises',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            '${_todaySets.length} sets',
                            style: const TextStyle(
                              color: Colors.cyan,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ==================================================
                  // EMPTY
                  // ==================================================

                  if (_todaySets.isEmpty)
                    _emptyToday(),

                  // ==================================================
                  // ACTUAL TODAY EXERCISES
                  // ==================================================

                  ...todayExercises.map(
                    (exercise) =>
                        _exerciseCard(exercise),
                  ),

                  const SizedBox(height: 4),

                  // ==================================================
                  // DELETE ALL TODAY'S EXERCISES
                  // ==================================================

                  if (_todaySets.isNotEmpty)
                    _deleteAllTodayCard(),

                  // ==================================================
                  // COPY PREVIOUS WORKOUT
                  // ==================================================

                  _copyWorkoutCard(),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }
}

// ==================================================================
// EXERCISE DETAIL SCREEN
// TRACK | HISTORY
// ==================================================================

class ExerciseDetailScreen extends StatefulWidget {
  final String exerciseName;
  final String target;
  final DateTime? initialDate;

  const ExerciseDetailScreen({
    super.key,
    required this.exerciseName,
    required this.target,
    this.initialDate,
  });

  @override
  State<ExerciseDetailScreen> createState() =>
      _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState
    extends State<ExerciseDetailScreen> {
  final AppDatabase _database = AppDatabase();

  int selectedTab = 0;

  late DateTime selectedDate;

  List<WorkoutSet> todaySets = [];
  List<WorkoutSet> historySets = [];

  final TextEditingController weightController =
      TextEditingController();

  final TextEditingController repsController =
      TextEditingController();

  bool loading = true;

  @override
  void initState() {
    super.initState();

    selectedDate =
        widget.initialDate ?? DateTime.now();

    _loadData();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    final today = await _database.getTodaySets(
      'user2',
      selectedDate,
    );

    final history =
        await _database.getExerciseHistory(
      userId: 'user2',
      exerciseName: widget.exerciseName,
    );

    if (!mounted) return;

    setState(() {
      todaySets = today;
      historySets = history;
      loading = false;
    });
  }

  // ============================================================
  // SAVE SET
  // ============================================================

  Future<void> _saveSet() async {
    final weight = double.tryParse(
      weightController.text.trim(),
    );

    final reps = int.tryParse(
      repsController.text.trim(),
    );

    if (weight == null ||
        reps == null ||
        weight < 0 ||
        reps <= 0) {
      _showMessage(
        'Enter valid weight and reps.',
      );
      return;
    }

    await _database.saveSet(
      userId: 'user2',
      exerciseName: widget.exerciseName,
      weight: weight,
      reps: reps,
      date: selectedDate,
    );

    weightController.clear();
    repsController.clear();

    await _loadData();

    if (!mounted) return;

    _showMessage('Set saved.');
  }

  // ============================================================
  // EDIT SET
  // ============================================================

  Future<void> _editSet(
    WorkoutSet set,
  ) async {
    final editWeightController =
        TextEditingController(
      text: set.weight.toString(),
    );

    final editRepsController =
        TextEditingController(
      text: set.reps.toString(),
    );

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Set'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller:
                    editWeightController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration:
                    const InputDecoration(
                  labelText: 'Weight (kg)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: editRepsController,
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
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final weight =
                    double.tryParse(
                  editWeightController.text.trim(),
                );

                final reps =
                    int.tryParse(
                  editRepsController.text.trim(),
                );

                if (weight == null ||
                    reps == null ||
                    weight < 0 ||
                    reps <= 0) {
                  return;
                }

                await _database.updateSet(
                  id: set.id,
                  exerciseName:
                      widget.exerciseName,
                  weight: weight,
                  reps: reps,
                );

                if (!dialogContext.mounted) {
                  return;
                }

                Navigator.pop(dialogContext);

                await _loadData();

                if (!mounted) return;

                _showMessage('Set updated.');
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );

    editWeightController.dispose();
    editRepsController.dispose();
  }

  // ============================================================
  // DELETE SET
  // ============================================================

  Future<void> _deleteSet(
    WorkoutSet set,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Set?'),
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _database.deleteSet(set.id);

    await _loadData();

    if (!mounted) return;

    _showMessage('Set deleted.');
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // INPUT HELPERS
  // ============================================================

  void _clearFields() {
    weightController.clear();
    repsController.clear();
  }

  void _changeWeight(
    double amount,
  ) {
    final current =
        double.tryParse(
              weightController.text,
            ) ??
            0;

    final value = current + amount;

    if (value >= 0) {
      weightController.text =
          value.toStringAsFixed(
        value % 1 == 0 ? 0 : 1,
      );
    }
  }

  void _changeReps(
    int amount,
  ) {
    final current =
        int.tryParse(
              repsController.text,
            ) ??
            0;

    final value = current + amount;

    if (value >= 0) {
      repsController.text =
          value.toString();
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    weightController.dispose();
    repsController.dispose();
    _database.close();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0F1115),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0F1115),
        elevation: 0,
        title: Text(
          widget.exerciseName,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      body: Column(
        children: [
          _tabBar(),

          Expanded(
            child: loading
                ? const Center(
                    child:
                        CircularProgressIndicator(),
                  )
                : IndexedStack(
                    index: selectedTab,
                    children: [
                      _buildTrackTab(),
                      _buildHistoryTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TAB BAR
  // ============================================================

  Widget _tabBar() {
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xFF17191E),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF30343D),
          ),
        ),
      ),
      child: Row(
        children: [
          _tabButton('TRACK', 0),
          _tabButton('HISTORY', 1),
        ],
      ),
    );
  }

  Widget _tabButton(
    String title,
    int index,
  ) {
    final selected =
        selectedTab == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedTab = index;
          });
        },
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? Colors.cyan
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: selected
                  ? Colors.white
                  : Colors.white54,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TRACK TAB
  // ============================================================

  Widget _buildTrackTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'WEIGHT (kg)',
          style: TextStyle(
            fontSize: 13,
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
                  hintText: '25.0',
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

        const SizedBox(height: 18),

        const Text(
          'REPS',
          style: TextStyle(
            fontSize: 13,
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
                  hintText: '10',
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

        const SizedBox(height: 18),

        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _saveSet,
                child: const Text('SAVE'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton(
                onPressed: _clearFields,
                child: const Text('CLEAR'),
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        Text(
          _formatDate(selectedDate),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        if (todaySets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'No sets recorded for this day.',
                style: TextStyle(
                  color: Colors.white54,
                ),
              ),
            ),
          ),

        ...todaySets.asMap().entries.map(
          (entry) {
            final index =
                entry.key + 1;
            final set = entry.value;

            return GestureDetector(
              onTap: () {
                _editSet(set);
              },
              child: Dismissible(
                key: ValueKey(set.id),
                direction:
                    DismissDirection.endToStart,
                confirmDismiss: (_) async {
                  await _deleteSet(set);
                  return false;
                },
                background: Container(
                  alignment:
                      Alignment.centerRight,
                  padding:
                      const EdgeInsets.only(
                    right: 20,
                  ),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                child: Container(
                  margin:
                      const EdgeInsets.only(
                    bottom: 8,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color:
                        const Color(0xFF1A1D24),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 35,
                        child: Text(
                          '$index',
                          style:
                              const TextStyle(
                            color:
                                Colors.white54,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${set.weight} kg',
                          textAlign:
                              TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          '${set.reps} reps',
                          textAlign:
                              TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // ============================================================
  // HISTORY TAB
  // ============================================================

  Widget _buildHistoryTab() {
    if (historySets.isEmpty) {
      return const Center(
        child: Text(
          'No history available.',
          style: TextStyle(
            color: Colors.white54,
          ),
        ),
      );
    }

    final grouped =
        <String, List<WorkoutSet>>{};

    for (final set in historySets) {
      final key = _dateKey(set.date);

      grouped.putIfAbsent(
        key,
        () => [],
      );

      grouped[key]!.add(set);
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'HISTORY',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white54,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        ...grouped.entries.map(
          (entry) {
            final sets = entry.value;

            return Container(
              margin:
                  const EdgeInsets.only(
                bottom: 12,
              ),
              padding:
                  const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    const Color(0xFF1A1D24),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(
                      sets.first.date,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...sets.asMap().entries.map(
                    (setEntry) {
                      final set =
                          setEntry.value;

                      return Padding(
                        padding:
                            const EdgeInsets.only(
                          bottom: 7,
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 35,
                              child: Text(
                                '${setEntry.key + 1}',
                                style:
                                    const TextStyle(
                                  color:
                                      Colors.white54,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${set.weight} kg',
                                textAlign:
                                    TextAlign.center,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '${set.reps} reps',
                                textAlign:
                                    TextAlign.center,
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
          },
        ),
      ],
    );
  }

  // ============================================================
  // DATE KEY
  // ============================================================

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

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
}