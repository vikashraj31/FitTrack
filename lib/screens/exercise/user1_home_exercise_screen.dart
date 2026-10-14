import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/database_service.dart';
import '../../services/copied_workout_history_storage.dart';
import '../../services/exercise_preference_storage.dart';
import '../../services/prepared_workout_storage.dart';
import '../../services/workout_day_status_storage.dart';
import '../../utils/exercise_catalog.dart';

class PreparedWorkoutSet {
  final double weight;
  final int reps;

  const PreparedWorkoutSet({required this.weight, required this.reps});
}

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
  Map<String, List<PreparedWorkoutSet>> _pendingTodaySets = {};
  Map<String, CopiedExerciseHistoryEntry> _copiedTodayEntries = {};
  Map<String, String> _exercisePreferences = {};
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

      // Persist missed-day highlighting from the durable per-exercise copied
      // history. A day remains missed when even one copied exercise was not
      // saved or explicitly marked as performed.
      final copiedByDate = await CopiedWorkoutHistoryStorage.loadAllDays(
        userId: 'user1',
      );
      for (final dayEntry in copiedByDate.entries) {
        if (!dayEntry.key.isBefore(today)) continue;
        final actualDaySets = await _database.getSetsByDate(
          userId: 'user1',
          date: dayEntry.key,
        );
        final actualNamesForDay = {
          for (final set in actualDaySets) set.exerciseName.toLowerCase(),
        };
        for (final copiedEntry in dayEntry.value.entries) {
          if (!copiedEntry.value.performed &&
              actualNamesForDay.contains(copiedEntry.key.toLowerCase())) {
            await CopiedWorkoutHistoryStorage.markPerformed(
              userId: 'user1',
              date: dayEntry.key,
              exerciseName: copiedEntry.key,
              sets: actualDaySets
                  .where(
                    (set) =>
                        set.exerciseName.toLowerCase() ==
                        copiedEntry.key.toLowerCase(),
                  )
                  .map(
                    (set) => <String, dynamic>{
                      'weight': set.weight,
                      'reps': set.reps,
                    },
                  )
                  .toList(),
            );
          }
        }
        final refreshedEntries = await CopiedWorkoutHistoryStorage.loadDay(
          userId: 'user1',
          date: dayEntry.key,
        );
        final hasUnperformed = refreshedEntries.values.any(
          (entry) => !entry.performed,
        );
        if (hasUnperformed) {
          await WorkoutDayStatusStorage.markMissed(
            userId: 'user1',
            date: dayEntry.key,
          );
        } else {
          await WorkoutDayStatusStorage.clearMissed(
            userId: 'user1',
            date: dayEntry.key,
          );
        }
      }

      // Compatibility with prepared-workout drafts created before copied
      // history was introduced. Do not mark a day missed when its durable
      // copied-history rows show that every exercise was completed.
      final expiredDate = await PreparedWorkoutStorage.expiredPreparedDate(
        userId: 'user1',
        date: today,
      );
      if (expiredDate != null && !copiedByDate.containsKey(expiredDate)) {
        await WorkoutDayStatusStorage.markMissed(
          userId: 'user1',
          date: expiredDate,
        );
      }

      final sets = await _database.getSetsByDate(userId: 'user1', date: today);
      final actualNames = {
        for (final set in sets) set.exerciseName.toLowerCase(),
      };

      // Recover a performed flag if an actual saved workout row exists from a
      // prior save path but the sidecar was not updated for some reason.
      var copiedToday = await CopiedWorkoutHistoryStorage.loadDay(
        userId: 'user1',
        date: today,
      );
      for (final entry in copiedToday.entries) {
        if (!entry.value.performed &&
            actualNames.contains(entry.key.toLowerCase())) {
          await CopiedWorkoutHistoryStorage.markPerformed(
            userId: 'user1',
            date: today,
            exerciseName: entry.key,
            sets: sets
                .where(
                  (set) =>
                      set.exerciseName.toLowerCase() == entry.key.toLowerCase(),
                )
                .map(
                  (set) => <String, dynamic>{
                    'weight': set.weight,
                    'reps': set.reps,
                  },
                )
                .toList(),
          );
        }
      }
      copiedToday = await CopiedWorkoutHistoryStorage.loadDay(
        userId: 'user1',
        date: today,
      );

      final otherUserSets = await _database.getSetsByDate(
        userId: 'user2',
        date: today,
      );
      final otherUserTodayNames = <String>{
        for (final set in otherUserSets) set.exerciseName.toLowerCase(),
      };

      final storedPending = await PreparedWorkoutStorage.load(
        userId: 'user1',
        date: today,
      );
      storedPending.removeWhere(
        (name, _) => actualNames.contains(name.toLowerCase()),
      );

      // The sidecar is the permanent copied-history record; this map is only
      // the editable draft for today's not-yet-performed exercises. If the
      // draft file was lost, rebuild it from the saved copy snapshot.
      for (final entry in copiedToday.entries) {
        if (entry.value.performed ||
            actualNames.contains(entry.key.toLowerCase())) {
          continue;
        }
        if (storedPending.keys.any(
          (name) => name.toLowerCase() == entry.key.toLowerCase(),
        )) {
          continue;
        }
        if (entry.value.sets.isNotEmpty) {
          storedPending[entry.key] = entry.value.sets
              .map(
                (set) => <String, dynamic>{
                  'weight': set.weight,
                  'reps': set.reps,
                },
              )
              .toList();
        }
      }

      await PreparedWorkoutStorage.save(
        userId: 'user1',
        date: today,
        sets: storedPending,
      );

      // The configured exercise order is stable regardless of the order in
      // which exercises were opened, edited, or saved.
      final savedExerciseNames = await _database.getAllExerciseNames(
        userId: 'user1',
        defaultExercises: ExerciseCatalog.defaultExercises,
      );
      final orderIndex = <String, int>{};
      for (var i = 0; i < savedExerciseNames.length; i++) {
        orderIndex[savedExerciseNames[i].toLowerCase()] = i;
      }

      final ordered = <String>[];
      void addOrdered(String name) {
        if (!ordered.any((item) => item.toLowerCase() == name.toLowerCase())) {
          ordered.add(name);
        }
      }

      for (final set in sets) {
        addOrdered(set.exerciseName);
      }
      for (final name in storedPending.keys) {
        addOrdered(name);
      }
      for (final name in copiedToday.keys) {
        addOrdered(name);
      }
      ordered.sort((a, b) {
        final aIndex = orderIndex[a.toLowerCase()] ?? 1 << 30;
        final bIndex = orderIndex[b.toLowerCase()] ?? 1 << 30;
        if (aIndex != bIndex) return aIndex.compareTo(bIndex);
        return a.toLowerCase().compareTo(b.toLowerCase());
      });

      final preferences = await ExercisePreferenceStorage.load(userId: 'user1');

      if (!mounted) return;
      setState(() {
        _todaySets = sets;
        _exerciseOrder = ordered;
        _otherUserTodayExerciseNames = otherUserTodayNames;
        _exercisePreferences = preferences;
        _copiedTodayEntries = copiedToday;
        _pendingTodaySets = storedPending.map(
          (name, sets) => MapEntry(
            name,
            sets
                .map(
                  (set) => PreparedWorkoutSet(
                    weight: (set['weight'] as num).toDouble(),
                    reps: (set['reps'] as num).toInt(),
                  ),
                )
                .toList(),
          ),
        );
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading User 1 workout: $e');
      if (!mounted) return;
      setState(() => _loading = false);
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

    for (final name in _pendingTodaySets.keys) {
      if (!currentNames.any(
        (item) => item.toLowerCase() == name.toLowerCase(),
      )) {
        currentNames.add(name);
      }
    }
    for (final name in _copiedTodayEntries.keys) {
      if (!currentNames.any(
        (item) => item.toLowerCase() == name.toLowerCase(),
      )) {
        currentNames.add(name);
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
    final actualCount = _todaySets
        .where(
          (set) => set.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
        )
        .length;

    if (actualCount > 0) {
      return actualCount;
    }

    final pendingCount = _pendingSetsForExercise(exerciseName).length;
    if (pendingCount > 0) return pendingCount;

    final copied = _copiedEntryForExercise(exerciseName);
    return copied?.sets.length ?? 0;
  }

  CopiedExerciseHistoryEntry? _copiedEntryForExercise(String exerciseName) {
    for (final entry in _copiedTodayEntries.entries) {
      if (entry.key.toLowerCase() == exerciseName.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }

  List<PreparedWorkoutSet> _initialSetsForExercise(String exerciseName) {
    final pending = _pendingSetsForExercise(exerciseName);
    if (pending.isNotEmpty) return pending;
    final copied = _copiedEntryForExercise(exerciseName);
    if (copied == null) return const [];
    return copied.sets
        .map((set) => PreparedWorkoutSet(weight: set.weight, reps: set.reps))
        .toList();
  }

  Future<void> _openExercise(String exerciseName) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => User1HomeExerciseDetailScreen(
          userId: 'user1',
          exerciseName: exerciseName,
          target: 'Recorded workout',
          initialSets: _initialSetsForExercise(exerciseName),
        ),
      ),
    );

    if (saved == true) {
      _pendingTodaySets.removeWhere(
        (name, _) => name.toLowerCase() == exerciseName.toLowerCase(),
      );

      await _savePendingTodaySets();
    }

    await _loadTodayWorkout();
  }

  List<PreparedWorkoutSet> _pendingSetsForExercise(String exerciseName) {
    for (final entry in _pendingTodaySets.entries) {
      if (entry.key.toLowerCase() == exerciseName.toLowerCase()) {
        return List<PreparedWorkoutSet>.from(entry.value);
      }
    }

    return const [];
  }

  Future<void> _savePendingTodaySets() async {
    final serialized = <String, List<Map<String, dynamic>>>{};

    for (final entry in _pendingTodaySets.entries) {
      serialized[entry.key] = entry.value
          .map(
            (set) => <String, dynamic>{'weight': set.weight, 'reps': set.reps},
          )
          .toList();
    }

    await PreparedWorkoutStorage.save(
      userId: 'user1',
      date: _dateOnly(DateTime.now()),
      sets: serialized,
    );
  }

  Future<void> _openCopyWorkout() async {
    final result = await Navigator.push<Map<String, List<PreparedWorkoutSet>>>(
      context,
      MaterialPageRoute(builder: (_) => const User1HomeCalendarScreen()),
    );

    if (result != null && mounted) {
      setState(() {
        _pendingTodaySets = result;
      });

      await _savePendingTodaySets();
    }

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

  Future<void> _deleteTodayWorkout() async {
    final exercises = _todayExercises();
    if (exercises.isEmpty) {
      _showMessage('There is no workout to delete today.');
      return;
    }

    final selectedExercises = <String>{};
    final selected = await showModalBottomSheet<Set<String>>(
      context: context,
      backgroundColor: const Color(0xFF101C32),
      isScrollControlled: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final allSelected = selectedExercises.length == exercises.length;
            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.72,
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
                      'SELECT EXERCISES TO DELETE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Only the selected exercises will be removed.',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: allSelected,
                      activeColor: Colors.redAccent,
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
                              ..addAll(exercises);
                          } else {
                            selectedExercises.clear();
                          }
                        });
                      },
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    Expanded(
                      child: ListView.builder(
                        itemCount: exercises.length,
                        itemBuilder: (_, index) {
                          final exercise = exercises[index];
                          final isSelected = selectedExercises.contains(
                            exercise,
                          );
                          return CheckboxListTile(
                            value: isSelected,
                            activeColor: Colors.redAccent,
                            checkColor: Colors.white,
                            title: Text(
                              exercise,
                              style: const TextStyle(color: Colors.white),
                            ),
                            subtitle: Text(
                              '${_setCountForExercise(exercise)} sets',
                              style: const TextStyle(color: Colors.white54),
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
                        height: 50,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                          ),
                          onPressed: selectedExercises.isEmpty
                              ? null
                              : () => Navigator.pop(sheetContext, {
                                  ...selectedExercises,
                                }),
                          icon: const Icon(Icons.delete_outline),
                          label: Text(
                            'DELETE ${selectedExercises.length} EXERCISE${selectedExercises.length == 1 ? '' : 'S'}',
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

    if (selected == null || selected.isEmpty || !mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101C32),
        title: const Text(
          'Confirm Delete',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Delete only these exercises?\n\n${selected.join('\n')}\n\nOther exercises will remain unchanged.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE SELECTED'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      final selectedKeys = selected.map((name) => name.toLowerCase()).toSet();
      for (final set in List<WorkoutSet>.from(_todaySets)) {
        if (selectedKeys.contains(set.exerciseName.toLowerCase())) {
          await _database.deleteSet(id: set.id, userId: 'user1');
        }
      }

      _pendingTodaySets.removeWhere(
        (name, _) => selectedKeys.contains(name.toLowerCase()),
      );
      for (final exercise in selected) {
        await CopiedWorkoutHistoryStorage.removeExercise(
          userId: 'user1',
          date: _dateOnly(DateTime.now()),
          exerciseName: exercise,
        );
      }
      await _savePendingTodaySets();
      await _loadTodayWorkout();
      if (mounted) _showMessage('Selected exercises deleted.');
    } catch (e) {
      debugPrint("Error deleting selected exercises: $e");
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
    if (newIndex < 0 || newIndex >= ordered.length) return;
    if (oldIndex == newIndex) return;

    final moved = ordered.removeAt(oldIndex);
    ordered.insert(newIndex, moved);

    // Keep prepared (not-yet-saved) exercises in exactly the same visible
    // order. Their map is rewritten so the order survives reload/restart.
    final reorderedPending = <String, List<PreparedWorkoutSet>>{};
    for (final name in ordered) {
      for (final entry in _pendingTodaySets.entries) {
        if (entry.key.toLowerCase() == name.toLowerCase()) {
          reorderedPending[name] = List<PreparedWorkoutSet>.from(entry.value);
          break;
        }
      }
    }

    for (final entry in _pendingTodaySets.entries) {
      if (!reorderedPending.keys.any(
        (name) => name.toLowerCase() == entry.key.toLowerCase(),
      )) {
        reorderedPending[entry.key] = List<PreparedWorkoutSet>.from(
          entry.value,
        );
      }
    }

    setState(() {
      _exerciseOrder = List<String>.from(ordered);
      _pendingTodaySets = reorderedPending;
    });

    try {
      await _savePendingTodaySets();
      await _saveCurrentExerciseOrder(ordered);

      // Persist the visible order for this specific day.
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
      debugPrint('Error saving user1 exercise order: $e');
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
    final hasActualSets = _todaySets.any(
      (set) => set.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
    );
    final copiedEntry = _copiedEntryForExercise(exerciseName);
    final isPrepared =
        !hasActualSets &&
        (_pendingSetsForExercise(exerciseName).isNotEmpty ||
            (copiedEntry != null && !copiedEntry.performed));
    final isCopiedButNotDone =
        copiedEntry != null && !copiedEntry.performed && !hasActualSets;
    final isAlsoDoneByOtherUser = _otherUserTodayExerciseNames.contains(
      exerciseName.toLowerCase(),
    );

    final preference =
        _exercisePreferences[ExercisePreferenceStorage.exerciseKey(exerciseName)];
    final targetText = preference?.isNotEmpty == true
        ? preference!
        : '$count ${count == 1 ? 'set' : 'sets'}';
    final subtitle = isCopiedButNotDone
        ? 'NO PERFORM YET • Copied history'
        : isPrepared
            ? '$targetText • Prepared, not saved'
            : hasActualSets && isAlsoDoneByOtherUser
                ? '$targetText • User 2 also did this today'
                : targetText;

    return Container(
      key: key,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2740),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
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
            subtitle,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasActualSets)
              const Icon(
                Icons.check_circle_outline,
                color: Colors.white54,
                size: 19,
              )
            else
              const Icon(
                Icons.radio_button_unchecked,
                color: Colors.white38,
                size: 19,
              ),
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

  Widget _exercisePreferencesCard() {
    if (_todayExercises().isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 10),
      height: 48,
      decoration: BoxDecoration(
        color: Colors.blueAccent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withValues(alpha: 0.20)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: const Icon(
          Icons.tune_rounded,
          size: 20,
          color: Colors.lightBlueAccent,
        ),
        title: const Text(
          'SET EXERCISE PREFERENCES',
          style: TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right,
          size: 20,
          color: Colors.white54,
        ),
        onTap: _editExercisePreferences,
      ),
    );
  }

  Future<void> _editExercisePreferences() async {
    final exercises = _todayExercises();
    if (exercises.isEmpty) {
      _showMessage('Add or copy exercises before setting preferences.');
      return;
    }

    final controllers = <String, TextEditingController>{
      for (final exercise in exercises)
        exercise: TextEditingController(
          text:
              _exercisePreferences[ExercisePreferenceStorage.exerciseKey(
                exercise,
              )] ??
              '',
        ),
    };

    final saved = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: const Color(0xFF101C32),
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: SizedBox(
              height: MediaQuery.of(sheetContext).size.height * 0.78,
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
                  const SizedBox(height: 16),
                  const Text(
                    'PREFERRED SETS & REPS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Example: 3 × 8–10. Leave blank to show the saved set count.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      itemCount: exercises.length,
                      itemBuilder: (_, index) {
                        final exercise = exercises[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF17243A),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: controllers[exercise],
                                textCapitalization: TextCapitalization.none,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: '3 × 8–10',
                                  hintStyle: const TextStyle(
                                    color: Colors.white30,
                                  ),
                                  labelText: 'Sets × rep range',
                                  labelStyle: const TextStyle(
                                    color: Colors.white54,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFF0B1628),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(sheetContext, false),
                            child: const Text('CANCEL'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(sheetContext, true),
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('SAVE'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    try {
      if (saved == true) {
        final preferences = Map<String, String>.from(_exercisePreferences);
        for (final exercise in exercises) {
          final key = ExercisePreferenceStorage.exerciseKey(exercise);
          final value = ExercisePreferenceStorage.normalizeLabel(
            controllers[exercise]!.text,
          );
          if (value.isEmpty) {
            preferences.remove(key);
          } else {
            preferences[key] = value;
          }
        }
        await ExercisePreferenceStorage.saveAll(
          userId: 'user1',
          preferences: preferences,
        );
        if (mounted) {
          setState(() => _exercisePreferences = preferences);
          _showMessage('Exercise preferences saved.');
        }
      }
    } finally {
  await Future<void>.delayed(const Duration(milliseconds: 400));

  for (final controller in controllers.values) {
    controller.dispose();
  }
}
  }

  Widget _deleteTodayCard() {
    if (_todaySets.isEmpty &&
        _pendingTodaySets.isEmpty &&
        _copiedTodayEntries.isEmpty) {
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
        onTap: _deleteTodayWorkout,
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
                  _exercisePreferencesCard(),
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
  final List<PreparedWorkoutSet> initialSets;

  const User1HomeExerciseDetailScreen({
    super.key,
    required this.userId,
    required this.exerciseName,
    required this.target,
    this.workoutDate,
    this.initialSets = const [],
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
      var copiedHistoryEntry = await CopiedWorkoutHistoryStorage.getEntry(
        userId: widget.userId,
        date: today,
        exerciseName: widget.exerciseName,
      );
      if (sets.any(
            (set) =>
                set.exerciseName.toLowerCase() ==
                widget.exerciseName.toLowerCase(),
          ) &&
          copiedHistoryEntry != null &&
          !copiedHistoryEntry.performed) {
        await CopiedWorkoutHistoryStorage.markPerformed(
          userId: widget.userId,
          date: today,
          exerciseName: widget.exerciseName,
          sets: sets
              .where(
                (set) =>
                    set.exerciseName.toLowerCase() ==
                    widget.exerciseName.toLowerCase(),
              )
              .map(
                (set) => <String, dynamic>{
                  'weight': set.weight,
                  'reps': set.reps,
                },
              )
              .toList(),
        );
        copiedHistoryEntry = await CopiedWorkoutHistoryStorage.getEntry(
          userId: widget.userId,
          date: today,
          exerciseName: widget.exerciseName,
        );
      }
    

      final todaySets = sets
          .where(
            (set) =>
                set.exerciseName.toLowerCase() ==
                widget.exerciseName.toLowerCase(),
          )
          .toList();

      _clearControllers();
      final initialSets = widget.initialSets.isNotEmpty
          ? widget.initialSets
          : (copiedHistoryEntry?.sets ?? const <CopiedExerciseSetSnapshot>[])
                .map(
                  (set) =>
                      PreparedWorkoutSet(weight: set.weight, reps: set.reps),
                )
                .toList();

      if (todaySets.isEmpty && initialSets.isNotEmpty) {
        for (final set in initialSets) {
          _addSet(weight: set.weight, reps: set.reps);
        }
      } else if (todaySets.isEmpty) {
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
  if (index < 0 || index >= _weightControllers.length) return;

  late final TextEditingController weightController;
  late final TextEditingController repsController;

  setState(() {
    weightController = _weightControllers.removeAt(index);
    repsController = _repsControllers.removeAt(index);
  });

  // Dispose controllers only after the removed TextFields
  // have been rebuilt out of the widget tree.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    weightController.dispose();
    repsController.dispose();
  });
}

  Future<void> _saveToday() async {
    if (_saving) return;

    setState(() {
      _saving = true;
    });

    try {
      final today = _workoutDate;
      final enteredSets = <Map<String, dynamic>>[];
      for (var i = 0; i < _weightControllers.length; i++) {
        final weightText = _weightControllers[i].text.trim();
        final repsText = _repsControllers[i].text.trim();
        if (weightText.isEmpty && repsText.isEmpty) continue;

        final weight = double.tryParse(weightText) ?? 0;
        final reps = int.tryParse(repsText) ?? 0;
        if (weight <= 0 || reps <= 0) continue;
        enteredSets.add({'weight': weight, 'reps': reps});
      }

      if (enteredSets.isEmpty) {
        _showMessage('Enter at least one valid set before saving.');
        return;
      }

      final existingToday = await _database.getSetsByDate(
        userId: widget.userId,
        date: today,
      );

      // Keep the configured order, not the order in which the user entered
      // sets or opened exercise details.
      final configuredOrder = await _database.getAllExerciseNames(
        userId: widget.userId,
        defaultExercises: ExerciseCatalog.defaultExercises,
      );
      final configuredIndex = <String, int>{
        for (var i = 0; i < configuredOrder.length; i++)
          configuredOrder[i].toLowerCase(): i,
      };
      final exerciseOrder =
          configuredIndex[widget.exerciseName.toLowerCase()] ??
          existingToday.length;

      // Only replace today's rows after validating that at least one valid set
      // is present. Merely opening and closing an exercise cannot erase data.
      for (final set in existingToday) {
        if (set.exerciseName.toLowerCase() ==
            widget.exerciseName.toLowerCase()) {
          await _database.deleteSet(id: set.id, userId: widget.userId);
        }
      }

      for (final set in enteredSets) {
        await _database.saveSet(
          userId: widget.userId,
          exerciseName: widget.exerciseName,
          weight: set['weight'] as double,
          reps: set['reps'] as int,
          date: today,
          exerciseOrder: exerciseOrder,
        );
      }

      // Saving (including saving the copied values unchanged) means the
      // exercise was performed today. A non-copied exercise simply has no
      // sidecar row, so this operation is a safe no-op for it.
      await CopiedWorkoutHistoryStorage.markPerformed(
        userId: widget.userId,
        date: today,
        exerciseName: widget.exerciseName,
        sets: enteredSets,
      );

      final todayAfterSave = await _database.getSetsByDate(
        userId: widget.userId,
        date: today,
      );
      final orderedToday = <String>[];
      for (final set in todayAfterSave) {
        if (!orderedToday.any(
          (name) => name.toLowerCase() == set.exerciseName.toLowerCase(),
        )) {
          orderedToday.add(set.exerciseName);
        }
      }
      final todayOrders = <String, int>{
        for (var i = 0; i < orderedToday.length; i++) orderedToday[i]: i,
      };
      await _database.updateExerciseOrder(
        userId: widget.userId,
        date: today,
        exerciseOrders: todayOrders,
      );

      final hasUnperformed =
          await CopiedWorkoutHistoryStorage.hasUnperformedExercises(
            userId: widget.userId,
            date: today,
          );
      if (!hasUnperformed) {
        await WorkoutDayStatusStorage.clearMissed(
          userId: widget.userId,
          date: today,
        );
      } else if (today.isBefore(_dateOnly(DateTime.now()))) {
        await WorkoutDayStatusStorage.markMissed(
          userId: widget.userId,
          date: today,
        );
      }

      await _loadData();

      if (!mounted) return;
      _showMessage('Workout saved.');
      await Future<void>.delayed(const Duration(milliseconds: 250));
      if (mounted) Navigator.pop(context, true);
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
      await _database.deleteSet(id: set.id, userId: widget.userId);

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
    // History contains only workouts that were actually saved to the database.
    // Copied-but-unperformed exercises remain available as a source workout
    // for future copying, but they do not create a history entry.
    final actualByDate = <DateTime, List<WorkoutSet>>{};
    for (final set in _history) {
      final date = _dateOnly(set.date);
      actualByDate.putIfAbsent(date, () => []).add(set);
    }

    final dates = actualByDate.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    if (dates.isEmpty) {
      return const Center(
        child: Text(
          'No history available.',
          style: TextStyle(color: Colors.white54),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(18),
      children: dates.map((date) {
        final sets = actualByDate[date]!;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF111D34),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
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
                          'Set ${index + 1}    ${set.weight} kg × ${set.reps}',
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
      }).toList(),
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

    final drafts = <String, List<PreparedWorkoutSet>>{};

    for (final set in _selectedSets) {
      drafts
          .putIfAbsent(set.exerciseName, () => [])
          .add(PreparedWorkoutSet(weight: set.weight, reps: set.reps));
    }

    if (!mounted) return;

    Navigator.pop(context, drafts);
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
  Map<String, CopiedExerciseHistoryEntry> _selectedCopiedEntries = {};
  Set<String> _missedWorkoutDateKeys = {};

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
      final copiedByDate = await CopiedWorkoutHistoryStorage.loadAllDays(
        userId: 'user1',
      );
      final today = _dateOnly(DateTime.now());
      for (final dayEntry in copiedByDate.entries) {
        if (!dayEntry.key.isBefore(today)) continue;
        final actualDaySets = await _database.getSetsByDate(
          userId: 'user1',
          date: dayEntry.key,
        );
        final actualNamesForDay = {
          for (final set in actualDaySets) set.exerciseName.toLowerCase(),
        };
        for (final copiedEntry in dayEntry.value.entries) {
          if (!copiedEntry.value.performed &&
              actualNamesForDay.contains(copiedEntry.key.toLowerCase())) {
            await CopiedWorkoutHistoryStorage.markPerformed(
              userId: 'user1',
              date: dayEntry.key,
              exerciseName: copiedEntry.key,
              sets: actualDaySets
                  .where(
                    (set) =>
                        set.exerciseName.toLowerCase() ==
                        copiedEntry.key.toLowerCase(),
                  )
                  .map(
                    (set) => <String, dynamic>{
                      'weight': set.weight,
                      'reps': set.reps,
                    },
                  )
                  .toList(),
            );
          }
        }
        final refreshedEntries = await CopiedWorkoutHistoryStorage.loadDay(
          userId: 'user1',
          date: dayEntry.key,
        );
        final hasUnperformed = refreshedEntries.values.any(
          (entry) => !entry.performed,
        );
        if (hasUnperformed) {
          await WorkoutDayStatusStorage.markMissed(
            userId: 'user1',
            date: dayEntry.key,
          );
        } else {
          await WorkoutDayStatusStorage.clearMissed(
            userId: 'user1',
            date: dayEntry.key,
          );
        }
      }
      final selectedDate = _selectedDay ?? _dateOnly(DateTime.now());
      final selectedSets = await _database.getSetsByDate(
        userId: 'user1',
        date: selectedDate,
      );
      final missedKeys = await WorkoutDayStatusStorage.loadMissedDateKeys(
        userId: 'user1',
      );
      final combinedDates = <DateTime>{
        ...dates.map(_dateOnly),
        ...copiedByDate.keys.map(_dateOnly),
      }.toList()..sort((a, b) => b.compareTo(a));

      if (!mounted) return;
      setState(() {
        _workoutDates = combinedDates;
        _selectedSets = selectedSets;
        _selectedCopiedEntries = copiedByDate[_dateOnly(selectedDate)] ?? {};
        _missedWorkoutDateKeys = missedKeys;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading User 1 calendar: $e');
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshSelectedDate() async {
    final date = _selectedDay ?? _dateOnly(DateTime.now());
    final sets = await _database.getSetsByDate(userId: 'user1', date: date);
    final dates = await _database.getWorkoutDates('user1');
    final copiedByDate = await CopiedWorkoutHistoryStorage.loadAllDays(
      userId: 'user1',
    );
    final missedKeys = await WorkoutDayStatusStorage.loadMissedDateKeys(
      userId: 'user1',
    );

    if (!mounted) return;
    setState(() {
      _selectedSets = sets;
      _workoutDates = <DateTime>{
        ...dates.map(_dateOnly),
        ...copiedByDate.keys.map(_dateOnly),
      }.toList()..sort((a, b) => b.compareTo(a));
      _selectedCopiedEntries = copiedByDate[_dateOnly(date)] ?? {};
      _missedWorkoutDateKeys = missedKeys;
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

  bool _hasMissedWorkout(DateTime day) {
    // A red day can still contain some recorded exercises: it means at least
    // one prepared exercise was not saved before the day ended.
    return _missedWorkoutDateKeys.contains(
      WorkoutDayStatusStorage.dateKey(day),
    );
  }

  Widget? _missedDayCell(DateTime day) {
    if (!_hasMissedWorkout(day)) return null;
    return Container(
      margin: const EdgeInsets.all(6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.13),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.40)),
      ),
      child: Text(
        '${day.day}',
        style: const TextStyle(
          color: Colors.redAccent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    final date = _dateOnly(selectedDay);
    final sets = await _database.getSetsByDate(userId: 'user1', date: date);
    final copied = await CopiedWorkoutHistoryStorage.loadDay(
      userId: 'user1',
      date: date,
    );

    if (!mounted) return;

    setState(() {
      _selectedDay = date;
      _focusedDay = focusedDay;
      _selectedSets = sets;
      _selectedCopiedEntries = copied;
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

  List<PreparedWorkoutSet> _initialSetsForSelectedDate(String exerciseName) {
    for (final entry in _selectedCopiedEntries.entries) {
      if (entry.key.toLowerCase() == exerciseName.toLowerCase()) {
        return entry.value.sets
            .map(
              (set) => PreparedWorkoutSet(weight: set.weight, reps: set.reps),
            )
            .toList();
      }
    }
    return const [];
  }

  Future<void> _editWorkoutForSelectedDate() async {
    if (_selectedSets.isEmpty && _selectedCopiedEntries.isEmpty) {
      _showMessage('No workout on this date.');
      return;
    }

    final date = _selectedDay ?? _dateOnly(DateTime.now());
    final exercises = <String>[];
    for (final set in _selectedSets) {
      if (!exercises.any(
        (name) => name.toLowerCase() == set.exerciseName.toLowerCase(),
      )) {
        exercises.add(set.exerciseName);
      }
    }
    for (final name in _selectedCopiedEntries.keys) {
      if (!exercises.any((item) => item.toLowerCase() == name.toLowerCase())) {
        exercises.add(name);
      }
    }
    exercises.sort();

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
          initialSets: _initialSetsForSelectedDate(selectedExercise),
        ),
      ),
    );

    await _refreshSelectedDate();
  }

  Future<void> _copySelectedWorkoutToToday() async {
    if (_selectedSets.isEmpty && _selectedCopiedEntries.isEmpty) {
      _showMessage('No workout history on this date.');
      return;
    }

    final sourceDate = _selectedDay ?? _dateOnly(DateTime.now());
    final today = _dateOnly(DateTime.now());
    if (!sourceDate.isBefore(today)) {
      _showMessage('Select a previous workout date.');
      return;
    }

    // Union actual workout rows with copied-only history rows. This preserves
    // skipped exercises when a copied workout is copied again on a later day.
    final exerciseNames = <String>[];
    void addExerciseName(String name) {
      if (!exerciseNames.any(
        (item) => item.toLowerCase() == name.toLowerCase(),
      )) {
        exerciseNames.add(name);
      }
    }

    for (final set in _selectedSets) {
      addExerciseName(set.exerciseName);
    }
    for (final name in _selectedCopiedEntries.keys) {
      addExerciseName(name);
    }

    final configuredOrder = await _database.getAllExerciseNames(
      userId: 'user1',
      defaultExercises: ExerciseCatalog.defaultExercises,
    );
    final orderIndex = <String, int>{
      for (var i = 0; i < configuredOrder.length; i++)
        configuredOrder[i].toLowerCase(): i,
    };
    exerciseNames.sort((a, b) {
      final aIndex = orderIndex[a.toLowerCase()] ?? 1 << 30;
      final bIndex = orderIndex[b.toLowerCase()] ?? 1 << 30;
      if (aIndex != bIndex) return aIndex.compareTo(bIndex);
      return a.toLowerCase().compareTo(b.toLowerCase());
    });

    if (!mounted) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101C32),
        title: const Text(
          'Copy Complete Workout?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'All ${exerciseNames.length} exercises from ${_formatDate(sourceDate)} will be copied into today’s workout list.\n\n'
          'Only exercises you save today will appear in today’s history. The full copied workout will remain available for copying again later.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('COPY ALL'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final prepared = <String, List<PreparedWorkoutSet>>{};
    final copySnapshot = <String, List<Map<String, dynamic>>>{};
    for (final exerciseName in exerciseNames) {
      final history = await _database.getExerciseHistory(
        userId: 'user1',
        exerciseName: exerciseName,
      );
      final previous =
          history.where((set) => _dateOnly(set.date).isBefore(today)).toList()
            ..sort((a, b) {
              final dateCompare = _dateOnly(
                b.date,
              ).compareTo(_dateOnly(a.date));
              if (dateCompare != 0) return dateCompare;
              return a.createdAt.compareTo(b.createdAt);
            });

      final fallbackActual = _selectedSets
          .where(
            (set) =>
                set.exerciseName.toLowerCase() == exerciseName.toLowerCase(),
          )
          .toList();
      CopiedExerciseHistoryEntry? fallbackCopied;
      for (final copiedEntry in _selectedCopiedEntries.entries) {
        if (copiedEntry.key.toLowerCase() == exerciseName.toLowerCase()) {
          fallbackCopied = copiedEntry.value;
          break;
        }
      }
      final latestDate = previous.isEmpty
          ? sourceDate
          : _dateOnly(previous.first.date);
      final sourceSets = previous.isEmpty
          ? fallbackActual
          : previous.where((set) => _dateOnly(set.date) == latestDate).toList();

      List<PreparedWorkoutSet> preparedSets;
      if (sourceSets.isNotEmpty) {
        preparedSets = sourceSets
            .map(
              (set) => PreparedWorkoutSet(weight: set.weight, reps: set.reps),
            )
            .toList();
      } else if (fallbackCopied != null) {
        preparedSets = fallbackCopied.sets
            .map(
              (set) => PreparedWorkoutSet(weight: set.weight, reps: set.reps),
            )
            .toList();
      } else {
        // Keep the exercise in copied history even if its past entry had no
        // valid set values. It will clearly remain NO PERFORM YET until saved.
        preparedSets = <PreparedWorkoutSet>[];
      }

      prepared[exerciseName] = preparedSets;
      copySnapshot[exerciseName] = preparedSets
          .map(
            (set) => <String, dynamic>{'weight': set.weight, 'reps': set.reps},
          )
          .toList();
    }

    if (!mounted) return;

    final actualToday = await _database.getSetsByDate(
      userId: 'user1',
      date: today,
    );
    final alreadyPerformedNames = <String>{
      for (final set in actualToday) set.exerciseName,
    };
    await CopiedWorkoutHistoryStorage.saveCopiedWorkout(
      userId: 'user1',
      date: today,
      exercises: copySnapshot,
      performedExerciseNames: alreadyPerformedNames,
    );

    // The prepared draft is editable UI state for today; durable copied history
    // above remains available in the History tab even if the date changes.
    prepared.removeWhere(
      (name, _) => alreadyPerformedNames.any(
        (actualName) => actualName.toLowerCase() == name.toLowerCase(),
      ),
    );
    if (prepared.isNotEmpty) {
      await PreparedWorkoutStorage.save(
        userId: 'user1',
        date: today,
        sets: prepared.map(
          (name, sets) => MapEntry(
            name,
            sets
                .map(
                  (set) => <String, dynamic>{
                    'weight': set.weight,
                    'reps': set.reps,
                  },
                )
                .toList(),
          ),
        ),
      );
    } else {
      await PreparedWorkoutStorage.clear(userId: 'user1');
    }

    // If this date is being re-copied and existing entries remain unperformed,
    // its red calendar state will be set when the day becomes historical.
    if (!mounted) return;
    Navigator.pop(context, prepared);
  }

  Future<void> _deleteWorkoutForSelectedDate() async {
    if (_selectedSets.isEmpty && _selectedCopiedEntries.isEmpty) {
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
            'Delete all actual and copied exercise history for ${_formatDate(date)}?',
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
      final copiedForDate = await CopiedWorkoutHistoryStorage.loadDay(
        userId: 'user1',
        date: date,
      );
      for (final name in copiedForDate.keys) {
        await CopiedWorkoutHistoryStorage.removeExercise(
          userId: 'user1',
          date: date,
          exerciseName: name,
        );
      }
      await WorkoutDayStatusStorage.clearMissed(userId: 'user1', date: date);

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

    final hasWorkout =
        _selectedSets.isNotEmpty || _selectedCopiedEntries.isNotEmpty;

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
                      defaultBuilder: (context, day, focusedDay) =>
                          _missedDayCell(day),
                      selectedBuilder: (context, day, focusedDay) =>
                          _missedDayCell(day) ??
                          Container(
                            margin: const EdgeInsets.all(6),
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2563EB),
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      todayBuilder: (context, day, focusedDay) =>
                          _missedDayCell(day) ??
                          Container(
                            margin: const EdgeInsets.all(6),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.blueAccent),
                            ),
                            child: Text(
                              '${day.day}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      markerBuilder: (context, day, events) {
                        final missed = _hasMissedWorkout(day);
                        if (!missed && !_hasWorkout(day)) return null;
                        return Positioned(
                          bottom: 4,
                          child: IgnorePointer(
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: missed
                                    ? Colors.redAccent
                                    : Colors.blueAccent,
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
                            (_selectedSets.isNotEmpty ||
                                    _selectedCopiedEntries.isNotEmpty) &&
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
                ..._selectedCopiedEntries.entries
                    .where(
                      (copied) => !grouped.keys.any(
                        (name) =>
                            name.toLowerCase() == copied.key.toLowerCase(),
                      ),
                    )
                    .map((copied) {
                      final entry = copied.value;
                      final notPerformed = !entry.performed;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: notPerformed
                              ? Colors.redAccent.withValues(alpha: 0.07)
                              : const Color(0xFF111D34),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: notPerformed
                                ? Colors.redAccent.withValues(alpha: 0.32)
                                : Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    copied.key,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                Text(
                                  entry.performed
                                      ? 'MARKED DONE'
                                      : 'NO PERFORM YET',
                                  style: TextStyle(
                                    color: entry.performed
                                        ? Colors.greenAccent
                                        : Colors.redAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(entry.sets.length, (index) {
                              final set = entry.sets[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  'Set ${index + 1}    ${set.weight} kg × ${set.reps}',
                                  style: TextStyle(
                                    color: notPerformed
                                        ? Colors.redAccent.withValues(
                                            alpha: 0.9,
                                          )
                                        : Colors.white60,
                                    fontSize: 13,
                                  ),
                                ),
                              );
                            }),
                            if (notPerformed)
                              const Text(
                                'Copied history only; this exercise does not count as completed.',
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 11,
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
