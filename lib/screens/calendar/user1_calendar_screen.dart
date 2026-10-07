import 'dart:async';

import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/database_service.dart';
import '../exercise/exercise_screen.dart';

class User1CalendarScreen extends StatefulWidget {
  const User1CalendarScreen({super.key});

  @override
  State<User1CalendarScreen> createState() => _User1CalendarScreenState();
}

class _User1CalendarScreenState extends State<User1CalendarScreen>
    with WidgetsBindingObserver {
  final AppDatabase _database = AppDatabase();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Set<String> _workoutDates = {};
  Set<String> _routineDates = {};
  List<WorkoutSet> _selectedDaySets = [];
  List<WorkoutRoutine> _selectedDayRoutines = [];
  Map<int, List<RoutineSet>> _routineSets = {};
  DailyDataData? _dailyData;
  double _actualCalories = 0;

  bool _loading = true;
  bool _loadingDay = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _selectedDay = _dateOnly(DateTime.now());
    _loadCalendar();
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  String _dateKey(DateTime date) {
    final d = _dateOnly(date);
    return '${d.year}-${d.month}-${d.day}';
  }

  Future<void> _loadCalendar() async {
    if (mounted) {
      setState(() => _loading = true);
    }

    try {
      final dates = await _database.getWorkoutDates('user1');
      final routines = await _database.getWorkoutRoutines(userId: 'user1');

      if (!mounted) return;

      setState(() {
        _workoutDates = dates.map(_dateKey).toSet();
        _routineDates = routines
            .map((routine) => _dateKey(routine.date))
            .toSet();
        _loading = false;
      });

      await _loadSelectedDay();
    } catch (e) {
      debugPrint('User 1 calendar load error: $e');

      if (!mounted) return;
      setState(() => _loading = false);

      await _loadSelectedDay();
    }
  }

  Future<void> _loadSelectedDay() async {
    final day = _selectedDay;
    if (day == null) return;

    if (mounted) {
      setState(() => _loadingDay = true);
    }

    try {
      final sets = await _database.getSetsByDate(userId: 'user1', date: day);

      final dailyData = await _database.getDailyData(
        userId: 'user1',
        date: day,
      );

      final routines = await _database.getWorkoutRoutinesByDate(
        userId: 'user1',
        date: day,
      );

      final routineSets = <int, List<RoutineSet>>{};
      for (final routine in routines) {
        routineSets[routine.id] = await _database.getRoutineSets(
  routineId: routine.id,
  userId: 'user1',
);
      }

      final calories = await _database.getActualCalories(
        userId: 'user1',
        date: day,
      );

      if (!mounted) return;

      setState(() {
        _selectedDaySets = sets;
        _selectedDayRoutines = routines;
        _routineSets = routineSets;
        _dailyData = dailyData;
        _actualCalories = calories;
        _loadingDay = false;
      });
    } catch (e) {
      debugPrint('User 1 selected date load error: $e');

      if (!mounted) return;

      setState(() {
        _selectedDaySets = [];
        _selectedDayRoutines = [];
        _routineSets = {};
        _dailyData = null;
        _actualCalories = 0;
        _loadingDay = false;
      });
    }
  }

  Future<void> _refresh() async {
    final dates = await _database.getWorkoutDates('user1');

    if (!mounted) return;

    final routines = await _database.getWorkoutRoutines(userId: 'user1');

    setState(() {
      _workoutDates = dates.map(_dateKey).toSet();
      _routineDates = routines.map((routine) => _dateKey(routine.date)).toSet();
    });

    await _loadSelectedDay();
  }

  bool _hasWorkout(DateTime day) {
    return _workoutDates.contains(_dateKey(day));
  }

  bool _hasRoutine(DateTime day) {
    return _routineDates.contains(_dateKey(day));
  }

  Map<String, List<WorkoutSet>> _groupSets() {
    final grouped = <String, List<WorkoutSet>>{};

    for (final set in _selectedDaySets) {
      grouped.putIfAbsent(set.exerciseName, () => []).add(set);
    }

    return grouped;
  }

  Future<void> _editSelectedWorkout() async {
    if (_selectedDaySets.isEmpty || _selectedDay == null) {
      return;
    }

    final exercises = _selectedDaySets
        .map((set) => set.exerciseName)
        .toSet()
        .toList();

    final selectedExercise = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF101C32),
      isScrollControlled: true,
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.65,
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
        builder: (_) => User1ExerciseDetailScreen(
          exerciseName: selectedExercise,
          database: _database,
        ),
      ),
    );

    await _refresh();
  }

  Future<void> _deleteSelectedWorkout() async {
    if (_selectedDaySets.isEmpty || _selectedDay == null) {
      return;
    }

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
            'This will delete the complete User 1 workout for ${_formatDate(_selectedDay!)}.',
            style: const TextStyle(color: Colors.white70),
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

    if (confirmed != true) {
      return;
    }

    try {
      await _database.deleteAllSetsByDate(userId: 'user1', date: _selectedDay!);

      await _refresh();

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Workout deleted.')));
    } catch (e) {
      debugPrint('Error deleting User 1 workout: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Could not delete workout.')),
        );
    }
  }

  Future<void> _openHistory(String exerciseName) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseHistoryScreen(
          userId: 'user1',
          exerciseName: exerciseName,
          database: _database,
        ),
      ),
    );

    await _refresh();
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

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  Widget _metric(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, size: 19, color: Colors.cyanAccent),
            const SizedBox(height: 7),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dailySummary() {
    final data = _dailyData;

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101C32),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DAILY SUMMARY',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.7,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric(
                'Calories',
                _actualCalories > 0
                    ? '${_formatNumber(_actualCalories)} kcal'
                    : '—',
                Icons.local_fire_department_outlined,
              ),
              const SizedBox(width: 8),
              _metric(
                'Steps',
                data == null ? '—' : '${data.steps}',
                Icons.directions_walk_outlined,
              ),
              const SizedBox(width: 8),
            ],
          ),
          if (data != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _metric(
                  'Recovery',
                  '${data.recoveryScore.round()}%',
                  Icons.battery_charging_full_outlined,
                ),
                const SizedBox(width: 8),
                _metric(
                  'Effort',
                  '${data.effortScore.round()}%',
                  Icons.bolt_outlined,
                ),
                const SizedBox(width: 8),
                _metric(
                  'Target kcal',
                  '${data.calorieTarget.round()}',
                  Icons.flag_outlined,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _exerciseCard(String exerciseName, List<WorkoutSet> sets) {
    final totalLoad = sets.fold<double>(
      0,
      (sum, set) => sum + (set.weight * set.reps),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF101C32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.055)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        title: Text(
          exerciseName,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${sets.length} sets  •  ${_formatNumber(totalLoad)} kg total load',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () => _openHistory(exerciseName),
      ),
    );
  }

  Widget _routineCard(WorkoutRoutine routine) {
    final sets = _routineSets[routine.id] ?? [];
    final grouped = <String, List<RoutineSet>>{};

    for (final set in sets) {
      grouped.putIfAbsent(set.exerciseName, () => []).add(set);
    }

    // A routine is planned for this calendar date.
    // If workout sets also exist for this date, the routine has been performed.
    final recorded = _selectedDaySets.isNotEmpty;
    final statusText = recorded ? 'RECORDED' : 'PLANNED';
    final statusColor = recorded ? Colors.cyanAccent : Colors.orangeAccent;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF101C32),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orangeAccent.withValues(alpha: 0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.event_note_outlined,
                color: Colors.orangeAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  routine.routineName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '${grouped.length} exercises • ${sets.length} sets',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
          if (grouped.isNotEmpty) ...[
            const SizedBox(height: 10),
            ...grouped.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '${entry.key}  •  ${entry.value.length} set${entry.value.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _plannedRoutinesSection() {
    if (_selectedDayRoutines.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'PLANNED ROUTINE',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            Text(
              '${_selectedDayRoutines.length}',
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ..._selectedDayRoutines.map(_routineCard),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _selectedDayContent() {
    if (_loadingDay) {
      return const Padding(
        padding: EdgeInsets.all(30),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final grouped = _groupSets();
    final exercises = grouped.keys.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _plannedRoutinesSection(),
        _dailySummary(),
        Row(
          children: [
            const Expanded(
              child: Text(
                'WORKOUT',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.7,
                ),
              ),
            ),
            if (exercises.isNotEmpty) ...[
              Text(
                '${_selectedDaySets.length} sets',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: _editSelectedWorkout,
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.white70,
                  size: 20,
                ),
                tooltip: 'Edit workout',
              ),
              IconButton(
                onPressed: _deleteSelectedWorkout,
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.redAccent,
                  size: 20,
                ),
                tooltip: 'Delete workout',
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        if (exercises.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.035),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.event_busy_outlined,
                  size: 34,
                  color: Colors.white38,
                ),
                SizedBox(height: 8),
                Text(
                  'No workout recorded',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 4),
                Text(
                  'There is no User 1 exercise data for this date.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...exercises.map((name) => _exerciseCard(name, grouped[name]!)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedDay ?? DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071329),
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
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
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF101C32),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TableCalendar(
                          firstDay: DateTime(2025, 1, 1),
                          lastDay: DateTime(2035, 12, 31),
                          focusedDay: _focusedDay,
                          selectedDayPredicate: (day) =>
                              isSameDay(_selectedDay, day),
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = _dateOnly(selectedDay);
                              _focusedDay = focusedDay;
                            });
                            _loadSelectedDay();
                          },
                          onPageChanged: (focusedDay) {
                            _focusedDay = focusedDay;
                          },
                          calendarStyle: CalendarStyle(
                            outsideDaysVisible: false,
                            defaultTextStyle: const TextStyle(
                              color: Colors.white70,
                            ),
                            weekendTextStyle: const TextStyle(
                              color: Colors.white70,
                            ),
                            todayDecoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.10),
                              shape: BoxShape.circle,
                            ),
                            selectedDecoration: const BoxDecoration(
                              color: Colors.cyan,
                              shape: BoxShape.circle,
                            ),
                            selectedTextStyle: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                            todayTextStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            markersMaxCount: 1,
                          ),
                          headerStyle: const HeaderStyle(
                            titleCentered: true,
                            formatButtonVisible: false,
                            titleTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            leftChevronIcon: Icon(
                              Icons.chevron_left,
                              color: Colors.white70,
                            ),
                            rightChevronIcon: Icon(
                              Icons.chevron_right,
                              color: Colors.white70,
                            ),
                          ),
                          daysOfWeekStyle: const DaysOfWeekStyle(
                            weekdayStyle: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                            weekendStyle: TextStyle(
                              color: Colors.white38,
                              fontSize: 11,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            markerBuilder: (context, day, events) {
                              if (!_hasWorkout(day) && !_hasRoutine(day)) {
                                return null;
                              }

                              return Positioned(
                                bottom: 4,
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: _hasWorkout(day)
                                        ? Colors.cyanAccent
                                        : Colors.orangeAccent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _formatDate(selected),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _hasWorkout(selected) && _hasRoutine(selected)
                              ? 'Workout recorded • Routine planned'
                              : _hasWorkout(selected)
                              ? 'Workout recorded'
                              : _hasRoutine(selected)
                              ? 'Routine planned'
                              : 'No workout recorded',
                          style: TextStyle(
                            color: _hasWorkout(selected)
                                ? Colors.cyanAccent
                                : Colors.white54,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      _selectedDayContent(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _database.close();
    super.dispose();
  }
}
