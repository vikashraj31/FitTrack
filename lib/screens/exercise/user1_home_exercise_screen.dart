import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/database_service.dart';
import '../../utils/exercise_catalog.dart';

class User1HomeExerciseScreen extends StatefulWidget {
  const User1HomeExerciseScreen({super.key});

  @override
  State<User1HomeExerciseScreen> createState() =>
      _User1HomeExerciseScreenState();
}

class _User1HomeExerciseScreenState extends State<User1HomeExerciseScreen> {
  final AppDatabase _database = AppDatabase();

  List<WorkoutSet> _todaySets = [];
  List<String> _exerciseOrder = [];
  Set<String> _otherUserTodayExerciseNames = {};
  bool _loading = true;

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

      final sets = await _database.getSetsByDate(userId: 'user1', date: today);

      final otherUserSets = await _database.getSetsByDate(
        userId: 'user2',
        date: today,
      );

      final otherUserTodayNames = <String>{
        for (final set in otherUserSets) set.exerciseName.toLowerCase(),
      };

      final names = <String>[];
      for (final set in sets) {
        if (!names.any(
          (name) => name.toLowerCase() == set.exerciseName.toLowerCase(),
        )) {
          names.add(set.exerciseName);
        }
      }

      final ordered = await _database.getExercisesInSavedOrder(
        userId: 'user1',
        exerciseNames: names,
      );

      if (!mounted) return;

      setState(() {
        _todaySets = sets;
        _exerciseOrder = ordered;
        _otherUserTodayExerciseNames = otherUserTodayNames;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading User 1 workout: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage('Could not load today\'s workout.');
    }
  }

  List<String> _todayExercises() {
    final currentNames = <String>[];

    for (final set in _todaySets) {
      if (!currentNames.any(
        (name) => name.toLowerCase() == set.exerciseName.toLowerCase(),
      )) {
        currentNames.add(set.exerciseName);
      }
    }

    final result = <String>[];

    for (final name in _exerciseOrder) {
      if (currentNames.any(
        (item) => item.toLowerCase() == name.toLowerCase(),
      )) {
        result.add(name);
      }
    }

    for (final name in currentNames) {
      if (!result.any((item) => item.toLowerCase() == name.toLowerCase())) {
        result.add(name);
      }
    }

    return result;
  }

  int _setCountForExercise(String exerciseName) {
    return _todaySets.where((set) => set.exerciseName == exerciseName).length;
  }

  Future<void> _openExercise(String exerciseName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => User1HomeExerciseDetailScreen(
          userId: 'user1',
          exerciseName: exerciseName,
          target: 'Recorded workout',
        ),
      ),
    );

    await _loadTodayWorkout();
  }

  Future<void> _openCopyWorkout() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const User1HomeCalendarScreen()),
    );

    await _loadTodayWorkout();
  }

  Future<void> _openCalendar() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const User1HomeCalendarScreen()),
    );

    await _loadTodayWorkout();
  }

  Widget _addExerciseCard() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: const Icon(
          Icons.add_circle_outline,
          size: 20,
          color: Colors.cyanAccent,
        ),
        title: const Text(
          'ADD EXERCISE',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          size: 20,
          color: Colors.white54,
        ),
        onTap: _showExercisePicker,
      ),
    );
  }

  Future<void> _showExercisePicker() async {
    final allExercises = await _database.getAllExerciseNames(
      userId: 'user1',
      defaultExercises: ExerciseCatalog.defaultExercises,
    );

    if (!mounted) return;

    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF101C32),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.80,
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
                  child: allExercises.isEmpty
                      ? const Center(
                          child: Text(
                            'No exercises available.',
                            style: TextStyle(color: Colors.white54),
                          ),
                        )
                      : ListView.builder(
                          itemCount: allExercises.length,
                          itemBuilder: (_, index) {
                            final exercise = allExercises[index];
                            return ListTile(
                              title: Text(
                                exercise,
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: const Text(
                                'Exercise',
                                style: TextStyle(
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

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => User1HomeExerciseDetailScreen(
          userId: 'user1',
          exerciseName: selected,
          target: 'Recorded workout',
        ),
      ),
    );

    await _loadTodayWorkout();
  }

  Future<void> _deleteSelectedTodayExercises() async {
    if (_todaySets.isEmpty) {
      _showMessage('There is no workout to delete today.');
      return;
    }

    final exerciseNames = _todayExercises();
    final selected = <String>{};

    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF101C32),
              title: const Text(
                "Delete Today's Exercises",
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: exerciseNames.length,
                  itemBuilder: (_, index) {
                    final exercise = exerciseNames[index];
                    final isSelected = selected.contains(exercise);
                    return CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setDialogState(() {
                          if (value == true) {
                            selected.add(exercise);
                          } else {
                            selected.remove(exercise);
                          }
                        });
                      },
                      activeColor: Colors.redAccent,
                      checkColor: Colors.white,
                      title: Text(
                        exercise,
                        style: const TextStyle(color: Colors.white),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () => Navigator.pop(dialogContext, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  child: const Text('DELETE SELECTED'),
                ),
              ],
            );
          },
        );
      },
    );

    if (shouldDelete != true || selected.isEmpty) return;

    try {
      final todaySets = List<WorkoutSet>.from(_todaySets);

      for (final set in todaySets) {
        if (selected.contains(set.exerciseName)) {
          await _database.deleteSet(id: set.id, userId: 'user1');
        }
      }

      await _loadTodayWorkout();
      _showMessage(
        "${selected.length} exercise${selected.length == 1 ? '' : 's'} deleted from today.",
      );
    } catch (e) {
      debugPrint('Error deleting selected exercises: $e');
      _showMessage('Could not delete selected exercises.');
    }
  }

  Future<void> _saveCurrentExerciseOrder(List<String> orderedToday) async {
    final all = await _database.getAllExerciseNames(
      userId: 'user1',
      defaultExercises: ExerciseCatalog.defaultExercises,
    );

    final fullOrder = <String>[...orderedToday];
    for (final name in all) {
      if (!fullOrder.any((item) => item.toLowerCase() == name.toLowerCase())) {
        fullOrder.add(name);
      }
    }

    await _database.saveExerciseOrder(
      userId: 'user1',
      orderedExerciseNames: fullOrder,
    );
  }

  Future<void> _reorderTodayExercises(int oldIndex, int newIndex) async {
    final ordered = _todayExercises();
    if (oldIndex < 0 || oldIndex >= ordered.length) return;

    if (newIndex < 0) newIndex = 0;
    if (newIndex >= ordered.length) newIndex = ordered.length - 1;

    final moved = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, moved);

    setState(() => _exerciseOrder = ordered);

    try {
      await _saveCurrentExerciseOrder(ordered);

      final orders = <String, int>{
        for (int i = 0; i < ordered.length; i++) ordered[i]: i,
      };

      await _database.updateExerciseOrder(
        userId: 'user1',
        date: _dateOnly(DateTime.now()),
        exerciseOrders: orders,
      );

      await _loadTodayWorkout();
    } catch (e) {
      debugPrint('Error saving User 1 exercise order: $e');
      _showMessage('Could not save exercise order.');
    }
  }

  Widget _todayExerciseList(List<String> exercises) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      onReorderItem: _reorderTodayExercises,
      buildDefaultDragHandles: false,
      itemBuilder: (_, index) {
        final exercise = exercises[index];
        return _exerciseCard(
          exercise,
          key: ValueKey('today-user1-${exercise.toLowerCase()}'),
          index: index,
        );
      },
    );
  }

  Widget _exerciseCard(String exerciseName, {Key? key, int? index}) {
    final count = _setCountForExercise(exerciseName);
    final isAlsoDoneByOtherUser = _otherUserTodayExerciseNames.contains(
      exerciseName.toLowerCase(),
    );

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isAlsoDoneByOtherUser
            ? Colors.cyanAccent.withValues(alpha: 0.045)
            : const Color(0xFF111D34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isAlsoDoneByOtherUser
              ? Colors.cyanAccent.withValues(alpha: 0.32)
              : Colors.white.withValues(alpha: 0.07),
        ),
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
            isAlsoDoneByOtherUser
                ? '$count ${count == 1 ? 'set' : 'sets'} • User 2 also did this today'
                : '$count ${count == 1 ? 'set' : 'sets'}',
            style: TextStyle(
              color: isAlsoDoneByOtherUser
                  ? Colors.cyanAccent.withValues(alpha: 0.82)
                  : Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.greenAccent, size: 19),
            if (index != null)
              ReorderableDragStartListener(
                index: index,
                child: const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child: Icon(Icons.drag_handle, color: Colors.white54),
                ),
              ),
            const SizedBox(width: 2),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
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
      child: const Column(
        children: [
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
            'Copy a previous workout or start a planned routine to begin tracking.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _copyWorkoutCard() {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: const Icon(
          Icons.copy_outlined,
          size: 20,
          color: Colors.white70,
        ),
        title: const Text(
          'COPY PREVIOUS WORKOUT',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          size: 20,
          color: Colors.white54,
        ),
        onTap: _openCopyWorkout,
      ),
    );
  }

  Widget _deleteTodayCard() {
    if (_todaySets.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: const Icon(
          Icons.delete_outline,
          size: 20,
          color: Colors.redAccent,
        ),
        title: const Text(
          "DELETE TODAY'S WORKOUT",
          style: TextStyle(
            color: Colors.redAccent,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          size: 20,
          color: Colors.white54,
        ),
        onTap: _deleteSelectedTodayExercises,
      ),
    );
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
          'User 1',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _openCalendar,
            icon: const Icon(Icons.calendar_month, color: Colors.white),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTodayWorkout,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
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
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 18),
                  if (todayExercises.isEmpty)
                    _emptyToday()
                  else
                    _todayExerciseList(todayExercises),
                  _addExerciseCard(),
                  _copyWorkoutCard(),
                  _deleteTodayCard(),
                  const SizedBox(height: 30),
                ],
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

class User1HomeExerciseDetailScreen extends StatefulWidget {
  final String userId;
  final String exerciseName;
  final String target;
  final DateTime? workoutDate;

  const User1HomeExerciseDetailScreen({
    super.key,
    required this.userId,
    required this.exerciseName,
    required this.target,
    this.workoutDate,
  });

  @override
  State<User1HomeExerciseDetailScreen> createState() =>
      _User1HomeExerciseDetailScreenState();
}

class _User1HomeExerciseDetailScreenState
    extends State<User1HomeExerciseDetailScreen>
    with SingleTickerProviderStateMixin {
  final AppDatabase _database = AppDatabase();

  late TabController _tabController;

  bool _loading = true;
  bool _saving = false;

  List<WorkoutSet> _history = [];
  List<WorkoutSet> _otherUserHistory = [];

  final List<TextEditingController> _weightControllers = [];
  final List<TextEditingController> _repsControllers = [];

  DateTime get _workoutDate => _dateOnly(widget.workoutDate ?? DateTime.now());

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

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
      final today = _workoutDate;

      final sets = await _database.getSetsByDate(
        userId: widget.userId,
        date: today,
      );

      final history = await _database.getExerciseHistory(
        userId: widget.userId,
        exerciseName: widget.exerciseName,
      );

      final otherUserId = widget.userId == 'user1' ? 'user2' : 'user1';
      final otherUserHistory = await _database.getExerciseHistory(
        userId: otherUserId,
        exerciseName: widget.exerciseName,
      );

      final todaySets = sets
          .where((set) => set.exerciseName == widget.exerciseName)
          .toList();

      _clearControllers();

      if (todaySets.isEmpty) {
        _addEmptySet();
        _addEmptySet();
        _addEmptySet();
      } else {
        for (final set in todaySets) {
          _addSet(weight: set.weight, reps: set.reps);
        }
      }

      if (!mounted) return;

      setState(() {
        _history = history;
        _otherUserHistory = otherUserHistory;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading exercise: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showMessage('Could not load exercise.');
    }
  }

  Widget _otherUserHistoryTab() {
    final otherUserId = widget.userId == 'user1' ? 'user2' : 'user1';
    final label = otherUserId == 'user1' ? 'User 1' : 'User 2';

    if (_otherUserHistory.isEmpty) {
      return Center(
        child: Text(
          'No $label history for this exercise.',
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    final grouped = <DateTime, List<WorkoutSet>>{};
    for (final set in _otherUserHistory) {
      final date = _dateOnly(set.date);
      grouped.putIfAbsent(date, () => []).add(set);
    }

    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.045),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.person_outline, color: Colors.cyanAccent),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '$label • ${widget.exerciseName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                'READ ONLY',
                style: TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        if (_otherUserHistory.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            child: SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => User1HomeExerciseDetailScreen(
                        userId: 'user2',
                        exerciseName: widget.exerciseName,
                        target: 'Recorded workout',
                      ),
                    ),
                  );
                  await _loadData();
                },
                icon: const Icon(Icons.edit_note, size: 19),
                label: const Text('USER 2 TRACK THIS EXERCISE'),
              ),
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
    );
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

  void _addEmptySet() {
    _weightControllers.add(TextEditingController());
    _repsControllers.add(TextEditingController());
  }

  void _addSet({required double weight, required int reps}) {
    _weightControllers.add(TextEditingController(text: weight.toString()));

    _repsControllers.add(TextEditingController(text: reps.toString()));
  }

  void _removeSet(int index) {
    if (_weightControllers.length <= 1) return;

    _weightControllers[index].dispose();
    _repsControllers[index].dispose();

    setState(() {
      _weightControllers.removeAt(index);
      _repsControllers.removeAt(index);
    });
  }

  Future<void> _saveToday() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      final today = _workoutDate;

      final existingToday = await _database.getSetsByDate(
        userId: widget.userId,
        date: today,
      );

      for (final set in existingToday) {
        if (set.exerciseName == widget.exerciseName) {
          await _database.deleteSet(id: set.id, userId: 'user1');
        }
      }

      // Read the permanent exercise order ONCE before saving.
      // This keeps the exercise in its current position.
      final orderList = await _database.getAllExerciseNames(
        userId: widget.userId,
        defaultExercises: ExerciseCatalog.defaultExercises,
      );

      final exerciseOrder = orderList.indexWhere(
        (name) => name.toLowerCase() == widget.exerciseName.toLowerCase(),
      );

      final safeExerciseOrder = exerciseOrder < 0 ? 0 : exerciseOrder;

      for (int i = 0; i < _weightControllers.length; i++) {
        final weightText = _weightControllers[i].text.trim();

        final repsText = _repsControllers[i].text.trim();

        if (weightText.isEmpty && repsText.isEmpty) {
          continue;
        }

        final weight = double.tryParse(weightText) ?? 0;

        final reps = int.tryParse(repsText) ?? 0;

        if (weight <= 0 || reps <= 0) {
          continue;
        }

        await _database.saveSet(
          userId: widget.userId,
          exerciseName: widget.exerciseName,
          weight: weight,
          reps: reps,
          date: today,
          exerciseOrder: safeExerciseOrder,
        );
      }

      // Re-apply the permanent order to all exercises recorded today.
      final todayAfterSave = await _database.getSetsByDate(
        userId: widget.userId,
        date: today,
      );

      final todayNames = <String>[];
      for (final set in todayAfterSave) {
        if (!todayNames.any(
          (name) => name.toLowerCase() == set.exerciseName.toLowerCase(),
        )) {
          todayNames.add(set.exerciseName);
        }
      }

      final orderedToday = await _database.getExercisesInSavedOrder(
        userId: widget.userId,
        exerciseNames: todayNames,
      );

      final todayOrders = <String, int>{
        for (int i = 0; i < orderedToday.length; i++) orderedToday[i]: i,
      };

      await _database.updateExerciseOrder(
        userId: widget.userId,
        date: today,
        exerciseOrders: todayOrders,
      );

      await _loadData();

      if (!mounted) return;

      _showMessage('Workout saved.');
    } catch (e) {
      debugPrint('Error saving exercise: $e');

      if (!mounted) return;

      _showMessage('Could not save workout.');
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _deleteHistorySet(WorkoutSet set) async {
    try {
      await _database.deleteSet(id: set.id, userId: 'user1');

      await _loadData();

      if (!mounted) return;

      _showMessage('Set deleted.');
    } catch (e) {
      debugPrint('Error deleting set: $e');
      _showMessage('Could not delete set.');
    }
  }

  Widget _trackTab() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Text(
          'WORKOUT',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formatDate(_workoutDate),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 20),
        ...List.generate(_weightControllers.length, (index) {
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFF111D34),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 42,
                  child: Text(
                    'SET ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _weightControllers[index],
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0B1628),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _repsControllers[index],
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Reps',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF0B1628),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => _removeSet(index),
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 4),
        OutlinedButton.icon(
          onPressed: () {
            setState(() {
              _addEmptySet();
            });
          },
          icon: const Icon(Icons.add),
          label: const Text('ADD SET'),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _saving ? null : _saveToday,
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
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _historyTab() {
    if (_history.isEmpty) {
      return const Center(
        child: Text(
          'No history available.',
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

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
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
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Set ${index + 1}    '
                            '${set.weight} kg × ${set.reps}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _deleteHistorySet(set),
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 19,
                            color: Colors.redAccent,
                          ),
                        ),
                      ],
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
            Tab(text: 'OTHER USER'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_trackTab(), _historyTab(), _otherUserHistoryTab()],
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

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

// ============================================================
// COPY PREVIOUS WORKOUT
// ============================================================

class User1HomeCopyWorkoutScreen extends StatefulWidget {
  const User1HomeCopyWorkoutScreen({super.key});

  @override
  State<User1HomeCopyWorkoutScreen> createState() =>
      _User1HomeCopyWorkoutScreenState();
}

class _User1HomeCopyWorkoutScreenState
    extends State<User1HomeCopyWorkoutScreen> {
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
      final dates = await _database.getWorkoutDates('user1');

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

    final sets = await _database.getSetsByDate(userId: 'user1', date: selected);

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
      await _database.deleteAllSetsByDate(userId: 'user1', date: today);

      for (final set in _selectedSets) {
        await _database.saveSet(
          userId: 'user1',
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
      debugPrint('Error copying User 1 workout: $e');
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
                if (_selectedSets.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111D34),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatDate(_selectedDate!),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ..._selectedSets.map(
                          (set) => Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: Text(
                              '${set.exerciseName} — '
                              '${set.weight} kg × '
                              '${set.reps}',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            onPressed: _copyToToday,
                            child: const Text(
                              'COPY TO TODAY',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

// ============================================================
// USER 2 CALENDAR
// ============================================================

class User1HomeCalendarScreen extends StatefulWidget {
  const User1HomeCalendarScreen({super.key});

  @override
  State<User1HomeCalendarScreen> createState() =>
      _User1HomeCalendarScreenState();
}

class _User1HomeCalendarScreenState extends State<User1HomeCalendarScreen> {
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
      final dates = await _database.getWorkoutDates('user1');

      final selectedDate = _selectedDay ?? _dateOnly(DateTime.now());

      final selectedSets = await _database.getSetsByDate(
        userId: 'user1',
        date: selectedDate,
      );

      if (!mounted) return;

      setState(() {
        _workoutDates = dates.map(_dateOnly).toList();

        _selectedSets = selectedSets;

        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading User 1 calendar: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _refreshSelectedDate() async {
    final date = _selectedDay ?? _dateOnly(DateTime.now());

    final sets = await _database.getSetsByDate(userId: 'user1', date: date);

    final dates = await _database.getWorkoutDates('user1');

    if (!mounted) return;

    setState(() {
      _selectedSets = sets;
      _workoutDates = dates.map(_dateOnly).toList();
    });
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

    final sets = await _database.getSetsByDate(userId: 'user1', date: date);

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

  Future<String?> _selectExercise() async {
    final exercises = [...ExerciseCatalog.defaultExercises]..sort();

    return showModalBottomSheet<String>(
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
                    itemCount: exercises.length,
                    itemBuilder: (_, index) {
                      final exercise = exercises[index];

                      return ListTile(
                        title: Text(
                          exercise,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                        ),
                        onTap: () {
                          Navigator.pop(ctx, exercise);
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
  }

  Future<void> _createWorkoutForSelectedDate() async {
    final date = _selectedDay ?? _dateOnly(DateTime.now());

    final selectedExercise = await _selectExercise();

    if (selectedExercise == null || !mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => User1HomeExerciseDetailScreen(
          userId: 'user1',
          exerciseName: selectedExercise,
          target: 'Recorded workout',
          workoutDate: date,
        ),
      ),
    );

    await _refreshSelectedDate();
  }

  Future<void> _editWorkoutForSelectedDate() async {
    if (_selectedSets.isEmpty) {
      _showMessage('No workout on this date.');
      return;
    }

    final date = _selectedDay ?? _dateOnly(DateTime.now());

    final exercises =
        _selectedSets.map((set) => set.exerciseName).toSet().toList()..sort();

    final selectedExercise = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF101C32),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.65,
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
                  'EDIT WORKOUT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: ListView.builder(
                    itemCount: exercises.length,
                    itemBuilder: (_, index) {
                      final exercise = exercises[index];

                      return ListTile(
                        title: Text(
                          exercise,
                          style: const TextStyle(color: Colors.white),
                        ),
                        trailing: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white54,
                        ),
                        onTap: () {
                          Navigator.pop(ctx, exercise);
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

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => User1HomeExerciseDetailScreen(
          userId: 'user1',
          exerciseName: selectedExercise,
          target: 'Recorded workout',
          workoutDate: date,
        ),
      ),
    );

    await _refreshSelectedDate();
  }

  Future<void> _copySelectedWorkoutToToday() async {
    if (_selectedSets.isEmpty) {
      _showMessage('No workout on this date.');
      return;
    }

    final sourceDate = _selectedDay ?? _dateOnly(DateTime.now());

    final today = _dateOnly(DateTime.now());

    if (sourceDate == today) {
      _showMessage('Select a previous workout date.');
      return;
    }

    final exerciseNames = <String>[
      ...{for (final set in _selectedSets) set.exerciseName},
    ]..sort();

    final selectedExercises = <String>{...exerciseNames};

    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      backgroundColor: const Color(0xFF101C32),
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final allSelected =
                selectedExercises.length == exerciseNames.length;

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
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
                      'SELECT EXERCISES TO COPY',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      _formatDate(sourceDate),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 12),

                    CheckboxListTile(
                      value: allSelected,
                      activeColor: Colors.blueAccent,
                      checkColor: Colors.white,
                      title: const Text(
                        'SELECT ALL',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          if (value == true) {
                            selectedExercises
                              ..clear()
                              ..addAll(exerciseNames);
                          } else {
                            selectedExercises.clear();
                          }
                        });
                      },
                    ),

                    const Divider(color: Colors.white12, height: 1),

                    Expanded(
                      child: ListView.builder(
                        itemCount: exerciseNames.length,
                        itemBuilder: (_, index) {
                          final exercise = exerciseNames[index];

                          final isSelected = selectedExercises.contains(
                            exercise,
                          );

                          return CheckboxListTile(
                            value: isSelected,
                            activeColor: Colors.blueAccent,
                            checkColor: Colors.white,
                            title: Text(
                              exercise,
                              style: const TextStyle(color: Colors.white),
                            ),
                            onChanged: (value) {
                              setModalState(() {
                                if (value == true) {
                                  selectedExercises.add(exercise);
                                } else {
                                  selectedExercises.remove(exercise);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: selectedExercises.isEmpty
                              ? null
                              : () {
                                  Navigator.pop(sheetContext, {
                                    ...selectedExercises,
                                  });
                                },
                          child: Text(
                            'COPY ${selectedExercises.length} EXERCISE${selectedExercises.length == 1 ? '' : 'S'}',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (!mounted || selected == null || selected.isEmpty) {
      return;
    }
    final setsToCopy = _selectedSets
        .where((set) => selected.contains(set.exerciseName))
        .toList();

    if (setsToCopy.isEmpty) {
      _showMessage('No exercises selected.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101C32),
          title: const Text(
            'Copy Workout?',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Copy ${selected.length} selected exercise${selected.length == 1 ? '' : 's'} '
            'from ${_formatDate(sourceDate)} to today?\n\n'
            '${setsToCopy.length} sets will be copied.',
            style: const TextStyle(color: Colors.white70),
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
        );
      },
    );

    if (confirmed != true) return;

    try {
      for (final set in setsToCopy) {
        await _database.saveSet(
          userId: 'user1',
          exerciseName: set.exerciseName,
          weight: set.weight,
          reps: set.reps,
          date: today,
        );
      }

      if (!mounted) return;

      _showMessage(
        '${selected.length} exercise${selected.length == 1 ? '' : 's'} copied to today.',
      );

      await _loadCalendar();
    } catch (e) {
      debugPrint('Error copying selected User 1 workout: $e');

      _showMessage('Could not copy workout.');
    }
  }

  Future<void> _deleteWorkoutForSelectedDate() async {
    if (_selectedSets.isEmpty) {
      _showMessage('No workout on this date.');
      return;
    }

    final date = _selectedDay ?? _dateOnly(DateTime.now());

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF101C32),

          title: const Text(
            'Delete Workout?',
            style: TextStyle(color: Colors.white),
          ),

          content: Text(
            'Delete the complete workout for ${_formatDate(date)}?',
            style: const TextStyle(color: Colors.white70),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx, false);
              },
              child: const Text('CANCEL'),
            ),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () {
                Navigator.pop(ctx, true);
              },
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await _database.deleteAllSetsByDate(userId: 'user1', date: date);

      await _refreshSelectedDate();

      if (!mounted) return;

      _showMessage('Workout deleted.');
    } catch (e) {
      debugPrint('Error deleting workout: $e');

      _showMessage('Could not delete workout.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
    bool danger = false,
  }) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onPressed,

        icon: Icon(icon, color: danger ? Colors.redAccent : Colors.white),

        label: Text(
          label,
          style: TextStyle(
            color: danger ? Colors.redAccent : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),

        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: danger
                ? Colors.redAccent.withValues(alpha: 0.4)
                : Colors.white.withValues(alpha: 0.12),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupExercises();

    final selectedDate = _selectedDay ?? _dateOnly(DateTime.now());

    final hasWorkout = _selectedSets.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF07111F),

      appBar: AppBar(
        backgroundColor: const Color(0xFF07111F),
        elevation: 0,
        title: const Text(
          'User 1 Calendar',
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
                      return _selectedDay != null &&
                          isSameDay(day, _selectedDay);
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
                          child: IgnorePointer(
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: const BoxDecoration(
                                color: Colors.blueAccent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  _formatDate(selectedDate),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _createWorkoutForSelectedDate,

                    icon: const Icon(Icons.add),

                    label: Text(
                      'CREATE WORKOUT FOR ${_formatDate(selectedDate)}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed:
                            _selectedSets.isNotEmpty &&
                                !isSameDay(_selectedDay, DateTime.now())
                            ? _copySelectedWorkoutToToday
                            : null,
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text(
                          'COPY TO TODAY',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _actionButton(
                            label: 'EDIT WORKOUT',
                            icon: Icons.edit_outlined,
                            onPressed: _editWorkoutForSelectedDate,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: _actionButton(
                            label: 'DELETE',
                            icon: Icons.delete_outline,
                            danger: true,
                            onPressed: _deleteWorkoutForSelectedDate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                if (!hasWorkout)
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
