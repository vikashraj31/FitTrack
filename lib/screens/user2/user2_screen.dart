import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/database_service.dart';

class User2Screen extends StatefulWidget {
  const User2Screen({super.key});

  @override
  State<User2Screen> createState() => _User2ScreenState();
}

class _User2ScreenState extends State<User2Screen> {
  final AppDatabase _database = AppDatabase();

  List<WorkoutSet> _todaySets = [];
  bool _loading = true;

  // User 2 weekly exercise plan.
  // IMPORTANT:
  // This plan is only used when selecting exercises manually.
  // It is NOT automatically shown on Today.
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

  static const Map<String, String> targets = {
    'Incline Chest Press Machine': '4 × 6–10',
    'Machine Chest Press': '3 × 10–12',
    'Pec Deck Fly': '3 × 12–15',
    'Rope Triceps Pushdown': '3 × 10–12',
    'Overhead Rope Extension': '3 × 10–12',
    'Crunch Machine': '3 × 12–15',
    'Lat Pulldown': '4 × 8–12',
    'Chest Supported Row': '3 × 8–12',
    'Straight Arm Pulldown': '3 × 10–15',
    'Face Pull': '3 × 12–15',
    'Cable Curl': '3 × 10–12',
    'Hip Thrust': '4 × 8–12',
    'Romanian Deadlift': '3 × 8–10',
    'Bulgarian Split Squat': '3 × 8–12',
    'Walking Lunges': '3 × 10–12',
    'Lying Leg Curl': '3 × 10–15',
    'Hip Abduction Machine': '3 × 12–15',
    'Machine Shoulder Press': '3 × 8–12',
    'Lateral Raise': '3 × 12–15',
    'Rear Delt Fly': '3 × 12–15',
    'Hammer Curl': '3 × 10–12',
    'Close Grip Seated Cable Row': '3 × 8–12',
    'Hip Thrust Machine': '4 × 8–12',
    'Hack Squat': '3 × 8–12',
    'Smith Machine Squat': '3 × 8–12',
    'Leg Press': '3 × 10–12',
    'Leg Extension': '3 × 10–15',
  };

  @override
  void initState() {
    super.initState();
    _loadTodayWorkout();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
      );
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _loadTodayWorkout() async {
    try {
      final today = _dateOnly(DateTime.now());

      final sets = await _database.getSetsByDate(userId: 'user2', date: today);

      if (!mounted) return;

      setState(() {
        _todaySets = sets;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading User 2 workout: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage('Could not load today\'s workout.');
    }
  }

  List<String> _todayExercises() {
    final names = <String>[];

    for (final set in _todaySets) {
      if (!names.contains(set.exerciseName)) {
        names.add(set.exerciseName);
      }
    }

    return names;
  }

  int _setCountForExercise(String exerciseName) {
    return _todaySets.where((set) => set.exerciseName == exerciseName).length;
  }

  Future<void> _openExercise(String exerciseName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          userId: 'user2',
          exerciseName: exerciseName,
          target: targets[exerciseName] ?? 'Recorded workout',
        ),
      ),
    );

    await _loadTodayWorkout();
  }

  Future<void> _openCopyWorkout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const User2CopyWorkoutScreen()),
    );

    await _loadTodayWorkout();
  }

  Future<void> _openCalendar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const User2CalendarScreen()),
    );

    await _loadTodayWorkout();
  }

  Future<void> _deleteAllTodayExercises() async {
    if (_todaySets.isEmpty) {
      _showMessage('There is no workout to delete today.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101C32),
          title: const Text(
            'Delete Today\'s Workout?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This will delete all User 2 exercises and sets recorded today. Previous workout dates will not be affected.',
            style: TextStyle(color: Colors.white70),
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
        userId: 'user2',
        date: _dateOnly(DateTime.now()),
      );

      await _loadTodayWorkout();

      _showMessage('Today\'s workout deleted.');
    } catch (e) {
      debugPrint('Error deleting User 2 workout: $e');
      _showMessage('Could not delete today\'s workout.');
    }
  }

  Widget _exerciseCard(String exerciseName) {
    final count = _setCountForExercise(exerciseName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF111D34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        title: Text(
          exerciseName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '$count ${count == 1 ? 'set' : 'sets'}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () => _openExercise(exerciseName),
      ),
    );
  }

  Widget _emptyToday() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: const Color(0xFF111D34),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: const [
          Icon(Icons.fitness_center_outlined, size: 42, color: Colors.white38),
          SizedBox(height: 14),
          Text(
            'No workout recorded today',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Copy a previous workout or add an exercise to start tracking.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _copyWorkoutCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF3B82F6).withValues(alpha: 0.20),
            const Color(0xFF2563EB).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.25)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF2563EB),
          child: Icon(Icons.copy, color: Colors.white),
        ),
        title: const Text(
          'COPY PREVIOUS WORKOUT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Copy an earlier workout to today',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white70),
        onTap: _openCopyWorkout,
      ),
    );
  }

  Widget _deleteTodayCard() {
    if (_todaySets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
        leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
        title: const Text(
          'DELETE TODAY\'S WORKOUT',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.redAccent,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Remove all exercises and sets recorded today',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
        onTap: _deleteAllTodayExercises,
      ),
    );
  }

  Widget _addExerciseCard() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111D34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF1F2937),
          child: Icon(Icons.add, color: Colors.white),
        ),
        title: const Text(
          'ADD EXERCISE',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'Choose an exercise and start tracking',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: _showExercisePicker,
      ),
    );
  }

  Future<void> _showExercisePicker() async {
    final dayExercises =
        weeklyWorkoutPlan[DateTime.now().weekday] ?? const <String>[];

    final allExercises = <String>{...dayExercises, ...targets.keys}.toList();

    allExercises.sort();

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF101C32),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.75,
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
                Expanded(
                  child: ListView.builder(
                    itemCount: allExercises.length,
                    itemBuilder: (_, index) {
                      final exercise = allExercises[index];

                      return ListTile(
                        title: Text(
                          exercise,
                          style: const TextStyle(color: Colors.white),
                        ),
                        subtitle: Text(
                          targets[exercise] ?? 'Custom',
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                        ),
                        onTap: () => Navigator.pop(ctx, exercise),
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

    if (selected == null) return;

    await _openExercise(selected);
  }

  @override
  Widget build(BuildContext context) {
    final todayExercises = _todayExercises();

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07111F),
        elevation: 0,
        title: const Text(
          'User 2',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _openCalendar,
            icon: const Icon(
              Icons.calendar_month_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadTodayWorkout,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                  children: [
                    const Text(
                      'EXERCISE',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'TODAY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatDate(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 22),

                    if (todayExercises.isEmpty)
                      _emptyToday()
                    else ...[
                      ...todayExercises.map(
                        (exercise) => _exerciseCard(exercise),
                      ),
                      _deleteTodayCard(),
                    ],

                    _copyWorkoutCard(),
                    _addExerciseCard(),
                  ],
                ),
              ),
      ),
    );
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
}

// ============================================================
// EXERCISE DETAIL
// ============================================================

class ExerciseDetailScreen extends StatefulWidget {
  final String userId;
  final String exerciseName;
  final String target;

  const ExerciseDetailScreen({
    super.key,
    this.userId = 'user2',
    required this.exerciseName,
    required this.target,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  final AppDatabase _database = AppDatabase();

  late TabController _tabController;

  List<WorkoutSet> _todaySets = [];
  List<WorkoutSet> _history = [];
  List<WorkoutSet> _lastWorkout = [];

  bool _loading = true;

  final List<TextEditingController> _weightControllers = [];
  final List<TextEditingController> _repsControllers = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();

    for (final controller in _weightControllers) {
      controller.dispose();
    }

    for (final controller in _repsControllers) {
      controller.dispose();
    }

    _database.close();

    super.dispose();
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _loadData() async {
    try {
      final today = _dateOnly(DateTime.now());

      final todaySets = await _database.getSetsByDate(
        userId: widget.userId,
        date: today,
      );

      final history = await _database.getExerciseHistory(
        userId: widget.userId,
        exerciseName: widget.exerciseName,
      );

      final previousDates = history
          .map((set) => _dateOnly(set.date))
          .where((date) => date.isBefore(today))
          .toSet()
          .toList();

      previousDates.sort();

      List<WorkoutSet> lastWorkout = [];

      if (previousDates.isNotEmpty) {
        final latestDate = previousDates.last;

        lastWorkout = history.where((set) {
          final date = _dateOnly(set.date);

          return date.year == latestDate.year &&
              date.month == latestDate.month &&
              date.day == latestDate.day;
        }).toList();
      }

      final exerciseTodaySets = todaySets
          .where((set) => set.exerciseName == widget.exerciseName)
          .toList();

      if (!mounted) return;

      setState(() {
        _todaySets = exerciseTodaySets;
        _history = history;
        _lastWorkout = lastWorkout;
        _loading = false;
      });

      _buildTodayControllers();
    } catch (e) {
      debugPrint('Error loading exercise data: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  void _clearControllers() {
    for (final controller in _weightControllers) {
      controller.dispose();
    }

    for (final controller in _repsControllers) {
      controller.dispose();
    }

    _weightControllers.clear();
    _repsControllers.clear();
  }

  void _buildTodayControllers() {
    _clearControllers();

    if (_todaySets.isEmpty) {
      _addControllerPair();
      _addControllerPair();
      _addControllerPair();
      return;
    }

    for (final set in _todaySets) {
      _weightControllers.add(
        TextEditingController(text: _formatNumber(set.weight)),
      );

      _repsControllers.add(TextEditingController(text: set.reps.toString()));
    }
  }

  void _addControllerPair() {
    _weightControllers.add(TextEditingController());

    _repsControllers.add(TextEditingController());
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }

  void _addSet() {
    setState(() {
      _addControllerPair();
    });
  }

  Future<void> _saveToday() async {
    final today = _dateOnly(DateTime.now());

    try {
      final existingToday = await _database.getSetsByDate(
        userId: widget.userId,
        date: today,
      );

      for (final set in existingToday) {
        if (set.exerciseName == widget.exerciseName) {
          await _database.deleteSet(set.id);
        }
      }

      int savedCount = 0;

      for (int i = 0; i < _weightControllers.length; i++) {
        final weightText = _weightControllers[i].text.trim();
        final repsText = _repsControllers[i].text.trim();

        if (weightText.isEmpty && repsText.isEmpty) {
          continue;
        }

        final weight = double.tryParse(weightText);
        final reps = int.tryParse(repsText);

        if (weight == null || reps == null) {
          _showMessage('Enter valid weight and reps for every set.');
          return;
        }

        await _database.saveSet(
          userId: widget.userId,
          exerciseName: widget.exerciseName,
          weight: weight,
          reps: reps,
          date: today,
        );

        savedCount++;
      }

      await _loadData();

      _showMessage(
        savedCount == 0 ? 'No sets saved.' : 'Today\'s workout saved.',
      );
    } catch (e) {
      debugPrint('Error saving workout: $e');
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
          backgroundColor: const Color(0xFF101C32),
          title: Text('Edit Set', style: const TextStyle(color: Colors.white)),
          content: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Weight',
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: repsController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Reps',
                    labelStyle: TextStyle(color: Colors.white54),
                  ),
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
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('SAVE'),
            ),
          ],
        );
      },
    );

    if (result != true) {
      weightController.dispose();
      repsController.dispose();
      return;
    }

    final weight = double.tryParse(weightController.text.trim());

    final reps = int.tryParse(repsController.text.trim());

    weightController.dispose();
    repsController.dispose();

    if (weight == null || reps == null) {
      _showMessage('Enter valid weight and reps.');
      return;
    }

    try {
      await _database.updateSet(
        id: set.id,
        exerciseName: widget.exerciseName,
        weight: weight,
        reps: reps,
      );

      await _loadData();

      _showMessage('Set updated.');
    } catch (e) {
      debugPrint('Error updating set: $e');
      _showMessage('Could not update set.');
    }
  }

  Future<void> _deleteHistorySet(WorkoutSet set) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101C32),
          title: const Text(
            'Delete Set?',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'This will delete only this set. Other sets and dates will remain unchanged.',
            style: TextStyle(color: Colors.white70),
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
      await _database.deleteSet(set.id);

      await _loadData();

      _showMessage('Set deleted.');
    } catch (e) {
      debugPrint('Error deleting set: $e');
      _showMessage('Could not delete set.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _setInputRow(int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111D34),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 35,
            child: Text(
              '${index + 1}',
              style: const TextStyle(
                color: Colors.white54,
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
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
                labelStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _repsControllers[index],
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Reps',
                labelStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _trackTab() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        if (_lastWorkout.isNotEmpty) ...[
          const Text(
            'LAST WORKOUT',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatDate(_lastWorkout.first.date),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_lastWorkout.length, (index) {
            final set = _lastWorkout[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Text(
                'Set ${index + 1}    ${_formatNumber(set.weight)} kg × ${set.reps}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            );
          }),
          const SizedBox(height: 25),
        ],
        const Text(
          'TODAY',
          style: TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatDate(DateTime.now()),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 15),
        ...List.generate(
          _weightControllers.length,
          (index) => _setInputRow(index),
        ),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: _addSet,
          icon: const Icon(Icons.add),
          label: const Text('ADD SET'),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _saveToday,
            child: const Text(
              'SAVE TODAY',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
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

    final grouped = <DateTime, List<WorkoutSet>>{};

    for (final set in _history) {
      final date = _dateOnly(set.date);

      grouped.putIfAbsent(date, () => []);

      grouped[date]!.add(set);
    }

    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: dates.length,
      itemBuilder: (_, dateIndex) {
        final date = dates[dateIndex];
        final sets = grouped[date]!;

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
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
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(sets.length, (index) {
                final set = sets[index];

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: Text(
                    'Set ${index + 1}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '${_formatNumber(set.weight)} kg × ${set.reps}',
                    style: const TextStyle(color: Colors.white54),
                  ),
                  trailing: PopupMenuButton<String>(
                    color: const Color(0xFF17243D),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editHistorySet(set);
                      } else if (value == 'delete') {
                        _deleteHistorySet(set);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text(
                          'Edit',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(
                          'Delete',
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07111F),
        elevation: 0,
        title: Text(
          widget.exerciseName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'TRACK'),
            Tab(text: 'HISTORY'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_trackTab(), _historyTab()],
            ),
    );
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
}

// ============================================================
// COPY PREVIOUS WORKOUT
// ============================================================

class User2CopyWorkoutScreen extends StatefulWidget {
  const User2CopyWorkoutScreen({super.key});

  @override
  State<User2CopyWorkoutScreen> createState() => _User2CopyWorkoutScreenState();
}

class _User2CopyWorkoutScreenState extends State<User2CopyWorkoutScreen> {
  final AppDatabase _database = AppDatabase();

  List<DateTime> _workoutDates = [];
  DateTime? _selectedDate;
  List<WorkoutSet> _selectedSets = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkoutDates();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _loadWorkoutDates() async {
    try {
      final dates = await _database.getWorkoutDates('user2');

      final today = _dateOnly(DateTime.now());

      final previousDates = dates
          .map(_dateOnly)
          .where((date) => date.isBefore(today))
          .toSet()
          .toList();

      previousDates.sort((a, b) => b.compareTo(a));

      if (!mounted) return;

      setState(() {
        _workoutDates = previousDates;
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

  Future<void> _selectDate(DateTime date) async {
    final selected = _dateOnly(date);

    final sets = await _database.getSetsByDate(userId: 'user2', date: selected);

    if (!mounted) return;

    setState(() {
      _selectedDate = selected;
      _selectedSets = sets;
    });
  }

  Future<void> _copyToToday() async {
    if (_selectedDate == null || _selectedSets.isEmpty) {
      _showMessage('Select a previous workout first.');
      return;
    }

    final today = _dateOnly(DateTime.now());

    try {
      // Delete existing User 2 workout for today first.
      await _database.deleteAllSetsByDate(userId: 'user2', date: today);

      for (final set in _selectedSets) {
        await _database.saveSet(
          userId: 'user2',
          exerciseName: set.exerciseName,
          weight: set.weight,
          reps: set.reps,
          date: today,
        );
      }

      if (!mounted) return;

      _showMessage('Workout copied to today.');

      await Future.delayed(const Duration(milliseconds: 400));

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error copying User 2 workout: $e');
      _showMessage('Could not copy workout.');
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07111F),
        elevation: 0,
        title: const Text(
          'Copy Previous Workout',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(18),
              children: [
                const Text(
                  'SELECT A PREVIOUS DATE',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                if (_workoutDates.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111D34),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'No previous workouts available.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                else
                  ..._workoutDates.map((date) {
                    final selected =
                        _selectedDate != null &&
                        date.year == _selectedDate!.year &&
                        date.month == _selectedDate!.month &&
                        date.day == _selectedDate!.day;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF1D4ED8)
                            : const Color(0xFF111D34),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        title: Text(
                          _formatDate(date),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                        ),
                        onTap: () => _selectDate(date),
                      ),
                    );
                  }),
                if (_selectedDate != null && _selectedSets.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text(
                    'WORKOUT — ${_formatDate(_selectedDate!)}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._buildGroupedWorkout(),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _copyToToday,
                      child: const Text(
                        'COPY TO TODAY',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  List<Widget> _buildGroupedWorkout() {
    final grouped = <String, List<WorkoutSet>>{};

    for (final set in _selectedSets) {
      grouped.putIfAbsent(set.exerciseName, () => []);

      grouped[set.exerciseName]!.add(set);
    }

    return grouped.entries.map((entry) {
      final exerciseName = entry.key;
      final sets = entry.value;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: const Color(0xFF111D34),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exerciseName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...List.generate(sets.length, (index) {
              final set = sets[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Set ${index + 1}    ${set.weight} kg × ${set.reps}',
                  style: const TextStyle(color: Colors.white60, fontSize: 13),
                ),
              );
            }),
          ],
        ),
      );
    }).toList();
  }
}

// ============================================================
// USER 2 CALENDAR
// ============================================================

class User2CalendarScreen extends StatefulWidget {
  const User2CalendarScreen({super.key});

  @override
  State<User2CalendarScreen> createState() => _User2CalendarScreenState();
}

class _User2CalendarScreenState extends State<User2CalendarScreen> {
  final AppDatabase _database = AppDatabase();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<DateTime> _workoutDates = [];
  List<WorkoutSet> _selectedSets = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();

    _selectedDay = _dateOnly(DateTime.now());

    _loadCalendar();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _loadCalendar() async {
    try {
      final dates = await _database.getWorkoutDates('user2');

      final today = _dateOnly(DateTime.now());

      final selectedSets = await _database.getSetsByDate(
        userId: 'user2',
        date: _selectedDay ?? today,
      );

      if (!mounted) return;

      setState(() {
        _workoutDates = dates.map(_dateOnly).toList();
        _selectedSets = selectedSets;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading User 2 calendar: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  bool _hasWorkout(DateTime day) {
    final date = _dateOnly(day);

    return _workoutDates.any(
      (workoutDate) =>
          workoutDate.year == date.year &&
          workoutDate.month == date.month &&
          workoutDate.day == date.day,
    );
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    final date = _dateOnly(selectedDay);

    final sets = await _database.getSetsByDate(userId: 'user2', date: date);

    if (!mounted) return;

    setState(() {
      _selectedDay = date;
      _focusedDay = focusedDay;
      _selectedSets = sets;
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

  Map<String, List<WorkoutSet>> _groupExercises() {
    final grouped = <String, List<WorkoutSet>>{};

    for (final set in _selectedSets) {
      grouped.putIfAbsent(set.exerciseName, () => []);

      grouped[set.exerciseName]!.add(set);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupExercises();

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF07111F),
        elevation: 0,
        title: const Text(
          'User 2 Calendar',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(14),
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF111D34),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: TableCalendar(
                    firstDay: DateTime(2025, 1, 1),
                    lastDay: DateTime(2035, 12, 31),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      if (_selectedDay == null) return false;

                      return isSameDay(day, _selectedDay);
                    },
                    onDaySelected: _onDaySelected,
                    calendarFormat: CalendarFormat.month,
                    availableCalendarFormats: const {
                      CalendarFormat.month: 'Month',
                    },
                    calendarStyle: const CalendarStyle(
                      defaultTextStyle: TextStyle(color: Colors.white),
                      weekendTextStyle: TextStyle(color: Colors.white70),
                      outsideTextStyle: TextStyle(color: Colors.white24),
                      todayTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      selectedTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      todayDecoration: BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    headerStyle: const HeaderStyle(
                      titleTextStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                      formatButtonVisible: false,
                      leftChevronIcon: Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),
                      rightChevronIcon: Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (!_hasWorkout(day)) {
                          return null;
                        }

                        return Positioned(
                          bottom: 4,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Colors.blueAccent,
                              shape: BoxShape.circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _formatDate(_selectedDay ?? DateTime.now()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                if (_selectedSets.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111D34),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'No workout recorded on this date.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                else
                  ...grouped.entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111D34),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...List.generate(entry.value.length, (index) {
                            final set = entry.value[index];

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                'Set ${index + 1}    ${set.weight} kg × ${set.reps}',
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
            ),
    );
  }
}
