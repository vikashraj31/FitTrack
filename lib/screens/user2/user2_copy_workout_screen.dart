import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/database_service.dart';

class User2CopyWorkoutScreen extends StatefulWidget {
  const User2CopyWorkoutScreen({super.key});

  @override
  State<User2CopyWorkoutScreen> createState() =>
      _User2CopyWorkoutScreenState();
}

class _User2CopyWorkoutScreenState
    extends State<User2CopyWorkoutScreen> {
  final AppDatabase _database = AppDatabase();

  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  List<DateTime> _workoutDates = [];
  List<WorkoutSet> _selectedDaySets = [];

  bool _loadingDates = true;
  bool _loadingSets = false;
  bool _copying = false;

  @override
  void initState() {
    super.initState();

    final today = DateTime.now();

    _selectedDay = DateTime(
      today.year,
      today.month,
      today.day,
    );

    _focusedDay = _selectedDay!;

    _loadWorkoutDates();
  }

  // ============================================================
  // LOAD WORKOUT DATES
  // ============================================================

  Future<void> _loadWorkoutDates() async {
    if (mounted) {
      setState(() {
        _loadingDates = true;
      });
    }

    final dates = await _database.getWorkoutDates('user2');

    if (!mounted) return;

    setState(() {
      _workoutDates = dates;
      _loadingDates = false;
    });

    await _loadSelectedDaySets();
  }

  // ============================================================
  // LOAD SELECTED DATE WORKOUT
  // ============================================================

  Future<void> _loadSelectedDaySets() async {
    if (_selectedDay == null) return;

    if (mounted) {
      setState(() {
        _loadingSets = true;
        _selectedDaySets = [];
      });
    }

    final selectedDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final sets = await _database.getSetsByDate(
      userId: 'user2',
      date: selectedDate,
    );

    if (!mounted) return;

    setState(() {
      _selectedDaySets = sets;
      _loadingSets = false;
    });
  }

  // ============================================================
  // DATE KEY
  // ============================================================

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  // ============================================================
  // CHECK WORKOUT
  // ============================================================

  bool _hasWorkout(DateTime day) {
    final key = _dateKey(day);

    return _workoutDates.any(
      (date) => _dateKey(date) == key,
    );
  }

  // ============================================================
  // CHECK TODAY
  // ============================================================

  bool _isToday(DateTime date) {
    final now = DateTime.now();

    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  // ============================================================
  // COPY WORKOUT
  // ============================================================

  Future<void> _copyWorkout() async {
    if (_selectedDay == null ||
        _selectedDaySets.isEmpty) {
      return;
    }

    final sourceDate = DateTime(
      _selectedDay!.year,
      _selectedDay!.month,
      _selectedDay!.day,
    );

    final now = DateTime.now();

    final todayDate = DateTime(
      now.year,
      now.month,
      now.day,
    );

    // ----------------------------------------------------------
    // PREVENT TODAY → TODAY
    // ----------------------------------------------------------

    if (_isToday(sourceDate)) {
      _showMessage(
        'Select a previous workout date.',
      );
      return;
    }

    // ----------------------------------------------------------
    // CHECK EXISTING TODAY WORKOUT
    // ----------------------------------------------------------

    final existingTodaySets =
        await _database.getSetsByDate(
      userId: 'user2',
      date: todayDate,
    );

    if (!mounted) return;

    // ----------------------------------------------------------
    // CONFIRMATION MESSAGE
    // ----------------------------------------------------------

    String message =
        'Copy the complete workout from '
        '${_formatDate(sourceDate)} to today?\n\n'
        '${_exerciseCount()} exercises • '
        '${_selectedDaySets.length} sets';

    if (existingTodaySets.isNotEmpty) {
      message +=
          '\n\nToday already has '
          '${existingTodaySets.length} sets. '
          'The copied workout will be added to them.';
    }

    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Copy Workout?',
          ),

          content: Text(message),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('CANCEL'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'COPY WORKOUT',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (!mounted) return;

    setState(() {
      _copying = true;
    });

    try {
      // --------------------------------------------------------
      // COPY EVERY SET
      // --------------------------------------------------------

      int copiedSets = 0;

      for (final set in _selectedDaySets) {
        await _database.saveSet(
          userId: 'user2',
          exerciseName: set.exerciseName,
          weight: set.weight,
          reps: set.reps,
          date: todayDate,
        );

        copiedSets++;
      }

      // --------------------------------------------------------
      // VERIFY COPY
      // --------------------------------------------------------

      final copiedTodaySets =
          await _database.getSetsByDate(
        userId: 'user2',
        date: todayDate,
      );

      if (!mounted) return;

      if (copiedTodaySets.length <
          existingTodaySets.length + copiedSets) {
        setState(() {
          _copying = false;
        });

        _showMessage(
          'Copy verification failed.',
        );

        return;
      }

      setState(() {
        _copying = false;
      });

      // --------------------------------------------------------
      // RETURN RESULT TO USER 2 SCREEN
      // --------------------------------------------------------

      Navigator.pop(
        context,
        true,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _copying = false;
      });

      _showMessage(
        'Could not copy workout.',
      );
    }
  }

  // ============================================================
  // EXERCISE COUNT
  // ============================================================

  int _exerciseCount() {
    final names = <String>{};

    for (final set in _selectedDaySets) {
      names.add(set.exerciseName);
    }

    return names.length;
  }

  // ============================================================
  // GROUP WORKOUT
  // ============================================================

  Map<String, List<WorkoutSet>> _groupedWorkout() {
    final grouped =
        <String, List<WorkoutSet>>{};

    for (final set in _selectedDaySets) {
      grouped.putIfAbsent(
        set.exerciseName,
        () => [],
      );

      grouped[set.exerciseName]!.add(set);
    }

    return grouped;
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
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final grouped = _groupedWorkout();

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,

        title: const Text(
          'Copy Previous Workout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _loadingDates
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : ListView(
              padding: const EdgeInsets.all(16),

              children: [
                const Text(
                  'SELECT WORKOUT DATE',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Choose any previous workout to copy to today.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 16),

                // =================================================
                // CALENDAR
                // =================================================

                Container(
                  padding: const EdgeInsets.all(8),

                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D24),
                    borderRadius:
                        BorderRadius.circular(16),
                  ),

                  child: TableCalendar<dynamic>(
                    firstDay:
                        DateTime(2025, 1, 1),

                    lastDay:
                        DateTime(2035, 12, 31),

                    focusedDay: _focusedDay,

                    selectedDayPredicate:
                        (day) {
                      return isSameDay(
                        _selectedDay,
                        day,
                      );
                    },

                    eventLoader: (day) {
                      return _hasWorkout(day)
                          ? <dynamic>[true]
                          : <dynamic>[];
                    },

                    onDaySelected:
                        (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay =
                            selectedDay;
                        _focusedDay =
                            focusedDay;
                      });

                      _loadSelectedDaySets();
                    },

                    onPageChanged:
                        (focusedDay) {
                      _focusedDay =
                          focusedDay;
                    },

                    calendarStyle:
                        CalendarStyle(
                      outsideDaysVisible:
                          false,

                      defaultTextStyle:
                          const TextStyle(
                        color: Colors.white,
                      ),

                      weekendTextStyle:
                          const TextStyle(
                        color: Colors.white,
                      ),

                      todayTextStyle:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),

                      selectedTextStyle:
                          const TextStyle(
                        color: Colors.white,
                        fontWeight:
                            FontWeight.bold,
                      ),

                      todayDecoration:
                          const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),

                      selectedDecoration:
                          const BoxDecoration(
                        color: Colors.cyan,
                        shape: BoxShape.circle,
                      ),

                      markerDecoration:
                          const BoxDecoration(
                        color:
                            Colors.greenAccent,
                        shape: BoxShape.circle,
                      ),

                      markerSize: 6,
                    ),

                    headerStyle:
                        const HeaderStyle(
                      titleTextStyle:
                          TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),

                      formatButtonVisible:
                          false,

                      leftChevronIcon:
                          Icon(
                        Icons.chevron_left,
                        color: Colors.white,
                      ),

                      rightChevronIcon:
                          Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),

                    daysOfWeekStyle:
                        const DaysOfWeekStyle(
                      weekdayStyle:
                          TextStyle(
                        color: Colors.white54,
                      ),

                      weekendStyle:
                          TextStyle(
                        color: Colors.white54,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // =================================================
                // SELECTED DATE
                // =================================================

                if (_selectedDay != null)
                  Text(
                    _formatDate(
                      _selectedDay!,
                    ),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                const SizedBox(height: 12),

                // =================================================
                // LOADING
                // =================================================

                if (_loadingSets)
                  const Padding(
                    padding:
                        EdgeInsets.all(30),

                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  )

                // =================================================
                // NO WORKOUT
                // =================================================

                else if (_selectedDaySets
                    .isEmpty)
                  Container(
                    padding:
                        const EdgeInsets.all(
                      22,
                    ),

                    decoration:
                        BoxDecoration(
                      color:
                          const Color(
                        0xFF1A1D24,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),

                    child: const Column(
                      children: [
                        Icon(
                          Icons
                              .fitness_center,
                          size: 36,
                          color:
                              Colors.white38,
                        ),

                        SizedBox(height: 10),

                        Text(
                          'No workout on this date.',
                          style: TextStyle(
                            color:
                                Colors.white54,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          'Select a marked date.',
                          style: TextStyle(
                            color:
                                Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )

                // =================================================
                // WORKOUT PREVIEW
                // =================================================

                else ...[
                  Text(
                    '${_exerciseCount()} exercises • '
                    '${_selectedDaySets.length} sets',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 14),

                  ...grouped.entries.map(
                    (entry) {
                      final exerciseName =
                          entry.key;

                      final sets =
                          entry.value;

                      return Container(
                        margin:
                            const EdgeInsets.only(
                          bottom: 12,
                        ),

                        padding:
                            const EdgeInsets.all(
                          16,
                        ),

                        decoration:
                            BoxDecoration(
                          color:
                              const Color(
                            0xFF1A1D24,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),

                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [
                            Text(
                              exerciseName,
                              style:
                                  const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            ...sets
                                .asMap()
                                .entries
                                .map(
                              (setEntry) {
                                final index =
                                    setEntry
                                            .key +
                                        1;

                                final set =
                                    setEntry
                                        .value;

                                return Padding(
                                  padding:
                                      const EdgeInsets
                                          .only(
                                    bottom: 7,
                                  ),

                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 35,
                                        child:
                                            Text(
                                          '$index',
                                          style:
                                              const TextStyle(
                                            color:
                                                Colors.white54,
                                          ),
                                        ),
                                      ),

                                      Expanded(
                                        child:
                                            Text(
                                          '${set.weight} kg',
                                          textAlign:
                                              TextAlign
                                                  .center,
                                        ),
                                      ),

                                      Expanded(
                                        child:
                                            Text(
                                          '${set.reps} reps',
                                          textAlign:
                                              TextAlign
                                                  .center,
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

                  const SizedBox(height: 8),

                  // =================================================
                  // COPY BUTTON
                  // =================================================

                  SizedBox(
                    width: double.infinity,

                    child:
                        ElevatedButton.icon(
                      onPressed:
                          _copying
                              ? null
                              : _copyWorkout,

                      icon: _copying
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(
                              Icons.copy,
                            ),

                      label: Text(
                        _copying
                            ? 'COPYING...'
                            : 'COPY WORKOUT',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      style:
                          ElevatedButton
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
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ],
            ),
    );
  }
}