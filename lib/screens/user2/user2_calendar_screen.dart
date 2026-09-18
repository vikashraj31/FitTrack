import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/database_service.dart';
import 'user2_screen.dart';

class User2CalendarScreen extends StatefulWidget {
  const User2CalendarScreen({super.key});

  @override
  State<User2CalendarScreen> createState() =>
      _User2CalendarScreenState();
}

class _User2CalendarScreenState
    extends State<User2CalendarScreen> {
  final AppDatabase _database = AppDatabase();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  Set<String> _workoutDates = {};

  List<WorkoutSet> _selectedDaySets = [];

  bool _loading = true;
  bool _loadingSets = false;

  @override
  void initState() {
    super.initState();

    _selectedDay = DateTime.now();

    _loadWorkoutDates();
    _loadSelectedDaySets();
  }

  // ==========================================================
  // LOAD ALL WORKOUT DATES
  // ==========================================================

  Future<void> _loadWorkoutDates() async {
    final dates =
        await _database.getWorkoutDates('user2');

    if (!mounted) return;

    setState(() {
      _workoutDates =
          dates.map(_dateKey).toSet();

      _loading = false;
    });
  }

  // ==========================================================
  // LOAD SELECTED DATE SETS
  // ==========================================================

  Future<void> _loadSelectedDaySets() async {
    if (_selectedDay == null) return;

    if (mounted) {
      setState(() {
        _loadingSets = true;
      });
    }

    final sets = await _database.getSetsByDate(
      userId: 'user2',
      date: _selectedDay!,
    );

    if (!mounted) return;

    setState(() {
      _selectedDaySets = sets;
      _loadingSets = false;
    });
  }

  // ==========================================================
  // REFRESH CALENDAR
  // ==========================================================

  Future<void> _refreshCalendar() async {
    await _loadWorkoutDates();
    await _loadSelectedDaySets();
  }

  // ==========================================================
  // DATE KEY
  // ==========================================================

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  // ==========================================================
  // CHECK WORKOUT
  // ==========================================================

  bool _hasWorkout(DateTime day) {
    return _workoutDates.contains(
      _dateKey(day),
    );
  }

  // ==========================================================
  // OPEN EXERCISE DETAIL
  // ==========================================================

  Future<void> _openExercise(
    String exerciseName,
    DateTime date,
  ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExerciseDetailScreen(
          exerciseName: exerciseName,
          target: '',
        ),
      ),
    );

    // Refresh calendar after returning
    await _refreshCalendar();
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        title: const Text(
          'Calendar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // ==================================================
                // CALENDAR
                // ==================================================

                TableCalendar(
                  firstDay: DateTime(2025, 1, 1),
                  lastDay: DateTime(2035, 12, 31),
                  focusedDay: _focusedDay,

                  selectedDayPredicate: (day) {
                    return isSameDay(
                      _selectedDay,
                      day,
                    );
                  },

                  onDaySelected: (
                    selectedDay,
                    focusedDay,
                  ) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });

                    _loadSelectedDaySets();
                  },

                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },

                  calendarFormat:
                      CalendarFormat.month,

                  headerStyle:
                      const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),

                  calendarStyle:
                      const CalendarStyle(
                    outsideDaysVisible: false,

                    defaultTextStyle:
                        TextStyle(
                      color: Colors.white,
                    ),

                    weekendTextStyle:
                        TextStyle(
                      color: Colors.white70,
                    ),

                    todayDecoration:
                        BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),

                    selectedDecoration:
                        BoxDecoration(
                      color: Colors.cyan,
                      shape: BoxShape.circle,
                    ),
                  ),

                  // ==================================================
                  // WORKOUT DATE MARKER
                  // ==================================================

                  eventLoader: (day) {
                    if (_hasWorkout(day)) {
                      return ['workout'];
                    }

                    return [];
                  },

                  calendarBuilders:
                      CalendarBuilders(
                    markerBuilder: (
                      context,
                      day,
                      events,
                    ) {
                      if (events.isEmpty) {
                        return null;
                      }

                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration:
                              const BoxDecoration(
                            color: Colors.cyan,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // SELECTED DATE WORKOUT
                // ==================================================

                Expanded(
                  child:
                      _buildSelectedDayWorkout(),
                ),
              ],
            ),
    );
  }

  // ==========================================================
  // SELECTED DAY WORKOUT
  // ==========================================================

  Widget _buildSelectedDayWorkout() {
    if (_selectedDay == null) {
      return const SizedBox();
    }

    if (_loadingSets) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_selectedDaySets.isEmpty) {
      return _buildNoWorkout();
    }

    // ========================================================
    // GROUP SETS BY EXERCISE
    // ========================================================

    final grouped =
        <String, List<WorkoutSet>>{};

    for (final set in _selectedDaySets) {
      grouped
          .putIfAbsent(
            set.exerciseName,
            () => [],
          )
          .add(set);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        16,
        8,
        16,
        20,
      ),
      children: [
        Text(
          _formatDate(_selectedDay!),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          '${grouped.length} exercise${grouped.length == 1 ? '' : 's'}',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 13,
          ),
        ),

        const SizedBox(height: 14),

        ...grouped.entries.map(
          (entry) {
            return _exerciseHistoryCard(
              entry.key,
              entry.value,
            );
          },
        ),
      ],
    );
  }

  // ==========================================================
  // EXERCISE CARD
  // ==========================================================

  Widget _exerciseHistoryCard(
    String exerciseName,
    List<WorkoutSet> sets,
  ) {
    return GestureDetector(
      onTap: () {
        _openExercise(
          exerciseName,
          _selectedDay!,
        );
      },

      child: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),

        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: const Color(0xFF1A1D24),
          borderRadius:
              BorderRadius.circular(14),
        ),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [
            // ==================================================
            // EXERCISE TITLE
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: Text(
                    exerciseName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Icon(
                  Icons.chevron_right,
                  color: Colors.white54,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // TABLE HEADER
            // ==================================================

            Row(
              children: const [
                SizedBox(
                  width: 35,
                  child: Text(
                    'SET',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  child: Text(
                    'WEIGHT',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Expanded(
                  child: Text(
                    'REPS',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ==================================================
            // SETS
            // ==================================================

            ...sets.asMap().entries.map(
              (entry) {
                final index = entry.key + 1;
                final set = entry.value;

                return Padding(
                  padding:
                      const EdgeInsets.only(
                    bottom: 8,
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
                          '${set.reps}',
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
      ),
    );
  }

  // ==========================================================
  // NO WORKOUT
  // ==========================================================

  Widget _buildNoWorkout() {
    return Padding(
      padding: const EdgeInsets.all(16),

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(20),

        decoration: BoxDecoration(
          color: const Color(0xFF1A1D24),
          borderRadius:
              BorderRadius.circular(14),
        ),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.event_busy,
              size: 40,
              color: Colors.white38,
            ),

            const SizedBox(height: 12),

            Text(
              _formatDate(_selectedDay!),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'No workout recorded',
              style: TextStyle(
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // DATE FORMAT
  // ==========================================================

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