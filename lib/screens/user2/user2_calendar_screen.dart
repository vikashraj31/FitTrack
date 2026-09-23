import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/database_service.dart';
import '../../utils/exercise_catalog.dart';
import 'user2_screen.dart';

class User2CalendarScreen extends StatefulWidget {
  const User2CalendarScreen({super.key});

  @override
  State<User2CalendarScreen> createState() =>
      _User2CalendarScreenState();
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
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  Future<void> _loadCalendar() async {
    try {
      final dates = await _database.getWorkoutDates('user2');

      final selectedDate =
          _selectedDay ?? _dateOnly(DateTime.now());

      final selectedSets = await _database.getSetsByDate(
        userId: 'user2',
        date: selectedDate,
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

  Future<void> _refreshSelectedDate() async {
    final date =
        _selectedDay ?? _dateOnly(DateTime.now());

    try {
      final sets = await _database.getSetsByDate(
        userId: 'user2',
        date: date,
      );

      final dates =
          await _database.getWorkoutDates('user2');

      if (!mounted) return;

      setState(() {
        _selectedSets = sets;
        _workoutDates = dates.map(_dateOnly).toList();
      });
    } catch (e) {
      debugPrint('Error refreshing User 2 calendar: $e');
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

  Future<void> _onDaySelected(
    DateTime selectedDay,
    DateTime focusedDay,
  ) async {
    final date = _dateOnly(selectedDay);

    try {
      final sets = await _database.getSetsByDate(
        userId: 'user2',
        date: date,
      );

      if (!mounted) return;

      setState(() {
        _selectedDay = date;
        _focusedDay = focusedDay;
        _selectedSets = sets;
      });
    } catch (e) {
      debugPrint('Error selecting date: $e');
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

  Map<String, List<WorkoutSet>> _groupExercises() {
    final grouped = <String, List<WorkoutSet>>{};

    for (final set in _selectedSets) {
      grouped.putIfAbsent(
        set.exerciseName,
        () => [],
      );

      grouped[set.exerciseName]!.add(set);
    }

    return grouped;
  }

  Future<String?> _selectExercise({
    String title = 'SELECT EXERCISE',
  }) async {
    final exercises =
        [...ExerciseCatalog.defaultExercises]..sort();

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF101C32),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.of(ctx).size.height * 0.75,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  title,
                  style: const TextStyle(
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
                      final exercise =
                          exercises[index];

                      return ListTile(
                        title: Text(
                          exercise,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.chevron_right,
                          color: Colors.white54,
                        ),
                        onTap: () {
                          Navigator.pop(
                            ctx,
                            exercise,
                          );
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
    final date =
        _selectedDay ?? _dateOnly(DateTime.now());

    final selectedExercise =
        await _selectExercise();

    if (selectedExercise == null ||
        !mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          userId: 'user2',
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
      _showMessage(
        'No workout on this date.',
      );
      return;
    }

    final date =
        _selectedDay ?? _dateOnly(DateTime.now());

    final exercises = _selectedSets
        .map((set) => set.exerciseName)
        .toSet()
        .toList()
      ..sort();

    final selectedExercise =
        await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF101C32),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.of(ctx).size.height * 0.65,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius:
                        BorderRadius.circular(10),
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
                      final exercise =
                          exercises[index];

                      return ListTile(
                        title: Text(
                          exercise,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.edit_outlined,
                          color: Colors.white54,
                        ),
                        onTap: () {
                          Navigator.pop(
                            ctx,
                            exercise,
                          );
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

    if (selectedExercise == null ||
        !mounted) {
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          userId: 'user2',
          exerciseName: selectedExercise,
          target: 'Recorded workout',
          workoutDate: date,
        ),
      ),
    );

    await _refreshSelectedDate();
  }

  Future<void> _deleteWorkoutForSelectedDate() async {
    if (_selectedSets.isEmpty) {
      _showMessage(
        'No workout on this date.',
      );
      return;
    }

    final date =
        _selectedDay ?? _dateOnly(DateTime.now());

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor:
              const Color(0xFF101C32),
          title: const Text(
            'Delete Workout?',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          content: Text(
            'Delete the complete workout for ${_formatDate(date)}?',
            style: const TextStyle(
              color: Colors.white70,
            ),
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
                backgroundColor:
                    Colors.redAccent,
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
      await _database.deleteAllSetsByDate(
        userId: 'user2',
        date: date,
      );

      await _refreshSelectedDate();

      if (!mounted) return;

      _showMessage(
        'Workout deleted.',
      );
    } catch (e) {
      debugPrint(
        'Error deleting workout: $e',
      );

      _showMessage(
        'Could not delete workout.',
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration:
              const Duration(seconds: 2),
        ),
      );
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
        icon: Icon(
          icon,
          color: danger
              ? Colors.redAccent
              : Colors.white,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: danger
                ? Colors.redAccent
                : Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: danger
                ? Colors.redAccent
                    .withValues(alpha: 0.4)
                : Colors.white
                    .withValues(alpha: 0.12),
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _groupExercises();

    final selectedDate =
        _selectedDay ??
            _dateOnly(DateTime.now());

    final hasWorkout =
        _selectedSets.isNotEmpty;

    return Scaffold(
      backgroundColor:
          const Color(0xFF07111F),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF07111F),
        elevation: 0,
        title: const Text(
          'User 2 Calendar',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ListView(
              padding:
                  const EdgeInsets.all(14),
              children: [
                Container(
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(0xFF111D34),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: TableCalendar(
                    firstDay:
                        DateTime(2025, 1, 1),
                    lastDay:
                        DateTime(2035, 12, 31),
                    focusedDay:
                        _focusedDay,
                    selectedDayPredicate:
                        (day) {
                      return _selectedDay !=
                              null &&
                          isSameDay(
                            day,
                            _selectedDay,
                          );
                    },
                    onDaySelected:
                        _onDaySelected,
                    calendarFormat:
                        CalendarFormat.month,
                    availableCalendarFormats:
                        const {
                      CalendarFormat.month:
                          'Month',
                    },
                    calendarStyle:
                        const CalendarStyle(
                      defaultTextStyle:
                          TextStyle(
                        color: Colors.white,
                      ),
                      weekendTextStyle:
                          TextStyle(
                        color:
                            Colors.white70,
                      ),
                      outsideTextStyle:
                          TextStyle(
                        color:
                            Colors.white24,
                      ),
                      todayTextStyle:
                          TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                      selectedTextStyle:
                          TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),
                      todayDecoration:
                          BoxDecoration(
                        color:
                            Colors.transparent,
                        shape:
                            BoxShape.circle,
                      ),
                      selectedDecoration:
                          BoxDecoration(
                        color:
                            Color(0xFF2563EB),
                        shape:
                            BoxShape.circle,
                      ),
                    ),
                    headerStyle:
                        const HeaderStyle(
                      titleTextStyle:
                          TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.w700,
                      ),
                      formatButtonVisible:
                          false,
                      leftChevronIcon:
                          Icon(
                        Icons.chevron_left,
                        color:
                            Colors.white,
                      ),
                      rightChevronIcon:
                          Icon(
                        Icons.chevron_right,
                        color:
                            Colors.white,
                      ),
                    ),
                    calendarBuilders:
                        CalendarBuilders(
                      markerBuilder:
                          (context,
                              day,
                              events) {
                        if (!_hasWorkout(day)) {
                          return null;
                        }

                        return Positioned(
                          bottom: 4,
                          child:
                              IgnorePointer(
                            child:
                                Container(
                              width: 5,
                              height: 5,
                              decoration:
                                  const BoxDecoration(
                                color:
                                    Colors.blueAccent,
                                shape:
                                    BoxShape
                                        .circle,
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
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                // CREATE
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed:
                        _createWorkoutForSelectedDate,
                    icon: const Icon(
                      Icons.add,
                    ),
                    label: const Text(
                      'CREATE WORKOUT',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // EDIT + DELETE
                Row(
                  children: [
                    Expanded(
                      child: _actionButton(
                        label: 'EDIT WORKOUT',
                        icon:
                            Icons.edit_outlined,
                        onPressed:
                            _editWorkoutForSelectedDate,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionButton(
                        label: 'DELETE',
                        icon:
                            Icons.delete_outline,
                        danger: true,
                        onPressed:
                            _deleteWorkoutForSelectedDate,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                if (!hasWorkout)
                  Container(
                    padding:
                        const EdgeInsets.all(22),
                    decoration:
                        BoxDecoration(
                      color:
                          const Color(0xFF111D34),
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                    child: const Text(
                      'No workout recorded on this date.',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            Colors.white54,
                      ),
                    ),
                  )
                else
                  ...grouped.entries.map(
                    (entry) {
                      return Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 10,
                        ),
                        padding:
                            const EdgeInsets.all(
                          15,
                        ),
                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFF111D34,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              entry.key,
                              style:
                                  const TextStyle(
                                color:
                                    Colors.white,
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            ...List.generate(
                              entry.value.length,
                              (index) {
                                final set =
                                    entry.value[
                                        index];

                                return Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    bottom: 4,
                                  ),
                                  child: Text(
                                    'Set ${index + 1}    '
                                    '${set.weight} kg × ${set.reps}',
                                    style:
                                        const TextStyle(
                                      color:
                                          Colors.white60,
                                      fontSize: 13,
                                    ),
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
            ),
    );
  }
}