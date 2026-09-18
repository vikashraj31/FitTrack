import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../services/database_service.dart';

class ExerciseScreen extends StatefulWidget {
  final String userId;

  const ExerciseScreen({super.key, this.userId = 'user1'});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  final AppDatabase _database = AppDatabase();
  List<WorkoutSet> _todaySets = [];
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
      if (!mounted) return;
      setState(() {
        _todaySets = sets;
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
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF050B18),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    final exercises = _todayExercises();

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071329),
        elevation: 0,
        title: const Text('Exercise', style: TextStyle(fontWeight: FontWeight.w600)),
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
                    const Text('TODAY', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text(_formatDate(DateTime.now()), style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 20),
                    const Text("Today's Workout", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 12),
                    if (exercises.isEmpty)
                      _emptyCard()
                    else
                      ...exercises.map((exercise) => _exerciseCard(exercise)),
                    const SizedBox(height: 14),
                    _copyCard(),
                    if (exercises.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      _deleteTodayCard(),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _exerciseCard(String exerciseName) {
    final count = _setCount(exerciseName);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        title: Text(exerciseName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('$count ${count == 1 ? 'set' : 'sets'}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: () => _openExercise(exerciseName),
      ),
    );
  }

  Widget _copyCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        leading: const Icon(Icons.content_copy_outlined),
        title: const Text('COPY PREVIOUS EXERCISE', style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text('Choose a previous workout and copy it to today', style: TextStyle(color: Colors.white54, fontSize: 12)),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: _openCopyPreviousExercise,
      ),
    );
  }

  Widget _deleteTodayCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.red.withValues(alpha: 0.18)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        leading: const Icon(Icons.delete_outline, color: Colors.redAccent),
        title: const Text(
          "DELETE TODAY'S WORKOUT",
          style: TextStyle(fontWeight: FontWeight.w600, color: Colors.redAccent),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Text(
            'Remove all exercises and sets recorded today',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
        onTap: _deleteAllTodayExercises,
      ),
    );
  }

  Widget _emptyCard() => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.055), borderRadius: BorderRadius.circular(18)),
    child: const Text('No exercises for today.', style: TextStyle(color: Colors.white60)),
  );
}

// ============================================================
// USER 1 EXERCISE DETAIL
// LAST WORKOUT = REFERENCE ONLY; TODAY = SEPARATE DATA
// ============================================================
class User1ExerciseDetailScreen extends StatefulWidget {
  final String exerciseName;
  final AppDatabase database;

  const User1ExerciseDetailScreen({super.key, required this.exerciseName, required this.database});

  @override
  State<User1ExerciseDetailScreen> createState() => _User1ExerciseDetailScreenState();
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
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _loadData() async {
    try {
      final today = await _database.getSetsByDate(userId: 'user1', date: DateTime.now());
      final history = await _database.getExerciseHistory(userId: 'user1', exerciseName: widget.exerciseName);
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
        _todaySets = today.where((s) => s.exerciseName == widget.exerciseName).toList();
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
    _weightControllers = List.generate(count, (i) => TextEditingController(
      text: i < _todaySets.length ? _formatNumber(_todaySets[i].weight) : '',
    ));
    _repsControllers = List.generate(count, (i) => TextEditingController(
      text: i < _todaySets.length ? _todaySets[i].reps.toString() : '',
    ));
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
      final currentToday = await _database.getSetsByDate(userId: 'user1', date: DateTime.now());
      for (final set in currentToday.where((s) => s.exerciseName == widget.exerciseName)) {
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
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: weight, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (kg)')),
          const SizedBox(height: 12),
          TextField(controller: reps, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps')),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(onPressed: () async {
            final w = double.tryParse(weight.text.trim());
            final r = int.tryParse(reps.text.trim());
            if (w == null || w < 0 || r == null || r <= 0) return;
            await _database.updateSet(id: set.id, exerciseName: set.exerciseName, weight: w, reps: r);
            if (ctx.mounted) Navigator.pop(ctx, true);
          }, child: const Text('SAVE')),
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
        content: Text('${set.weight} kg × ${set.reps} reps on ${_formatDate(set.date)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('DELETE')),
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
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));
  }

  String _formatNumber(num value) => value.toDouble() == value.toDouble().roundToDouble() ? value.toDouble().toStringAsFixed(0) : value.toString();

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
      appBar: AppBar(backgroundColor: const Color(0xFF071329), elevation: 0, title: Text(widget.exerciseName)),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF08285C), Color(0xFF061A3B), Color(0xFF050B18)])),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
                children: [
                  _sectionTitle('LAST WORKOUT'),
                  if (_lastWorkout.isEmpty)
                    _mutedCard('No previous workout for this exercise.')
                  else ...[
                    Text(_formatDate(_lastWorkout.first.date), style: const TextStyle(color: Colors.white60, fontSize: 13)),
                    const SizedBox(height: 8),
                    _referenceCard(_lastWorkout),
                  ],
                  const SizedBox(height: 24),
                  _sectionTitle('TODAY'),
                  Text(_formatDate(DateTime.now()), style: const TextStyle(color: Colors.white60, fontSize: 13)),
                  const SizedBox(height: 12),
                  ...List.generate(_weightControllers.length, (i) => _todayRow(i)),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(onPressed: _addSet, icon: const Icon(Icons.add), label: const Text('ADD SET')),
                  const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _saving ? null : _saveToday, child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('SAVE TODAY'))),
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

  Widget _sectionTitle(String title) => Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700));

  Widget _mutedCard(String text) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.055), borderRadius: BorderRadius.circular(16)), child: Text(text, style: const TextStyle(color: Colors.white54)));

  Widget _referenceCard(List<WorkoutSet> sets) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.055), borderRadius: BorderRadius.circular(16)),
    child: Column(children: sets.asMap().entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 5), child: Row(children: [SizedBox(width: 52, child: Text('Set ${e.key + 1}', style: const TextStyle(color: Colors.white60))), Expanded(child: Text('${_formatNumber(e.value.weight)} kg × ${e.value.reps}', style: const TextStyle(fontWeight: FontWeight.w600)))]))).toList()),
  );

  Widget _todayRow(int i) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(children: [
      SizedBox(width: 52, child: Text('Set ${i + 1}', style: const TextStyle(color: Colors.white60, fontSize: 12))),
      Expanded(child: TextField(controller: _weightControllers[i], keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Weight (kg)', filled: true))),
      const SizedBox(width: 10),
      Expanded(child: TextField(controller: _repsControllers[i], keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Reps', filled: true))),
    ]),
  );

  List<Widget> _historyCards() {
    final grouped = <String, List<WorkoutSet>>{};
    for (final set in _history) {
      grouped.putIfAbsent(_dateKey(set.date), () => []).add(set);
    }
    final entries = grouped.entries.toList()..sort((a, b) => b.key.compareTo(a.key));
    return entries.map((entry) {
      final sets = entry.value;
      final date = sets.first.date;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.055), borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_formatDate(date), style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...sets.asMap().entries.map((e) => ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: Text('Set ${e.key + 1}   ${_formatNumber(e.value.weight)} kg × ${e.value.reps}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(onPressed: () => _editHistorySet(e.value), icon: const Icon(Icons.edit_outlined, size: 19)),
              IconButton(onPressed: () => _deleteHistorySet(e.value), icon: const Icon(Icons.delete_outline, size: 19)),
            ]),
          )),
        ]),
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

  const CopyPreviousWorkoutScreen({super.key, required this.userId, required this.database, this.title = 'Copy Previous Workout'});

  @override
  State<CopyPreviousWorkoutScreen> createState() => _CopyPreviousWorkoutScreenState();
}

class _CopyPreviousWorkoutScreenState extends State<CopyPreviousWorkoutScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<String> _workoutDates = {};
  List<WorkoutSet> _selectedDaySets = [];
  bool _loading = true;
  bool _loadingSets = false;
  bool _copying = false;

  @override
  void initState() { super.initState(); _loadWorkoutDates(); }

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
  bool _hasWorkout(DateTime d) => _workoutDates.contains(_dateKey(d));
  String _formatDate(DateTime d) {
    const months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  Future<void> _loadWorkoutDates() async {
    final dates = await widget.database.getWorkoutDates(widget.userId);
    if (!mounted) return;
    setState(() { _workoutDates = dates.map(_dateKey).toSet(); _loading = false; });
  }

  Future<void> _selectDate(DateTime selected, DateTime focused) async {
    setState(() { _selectedDay = selected; _focusedDay = focused; _loadingSets = true; });
    if (isSameDay(selected, DateTime.now())) {
      setState(() { _selectedDaySets = []; _loadingSets = false; });
      _showMessage('Today cannot be used as a previous workout.');
      return;
    }
    if (!_hasWorkout(selected)) {
      setState(() { _selectedDaySets = []; _loadingSets = false; });
      _showMessage('No workout on ${_formatDate(selected)}.');
      return;
    }
    final sets = await widget.database.getSetsByDate(userId: widget.userId, date: selected);
    if (!mounted) return;
    setState(() { _selectedDaySets = sets; _loadingSets = false; });
  }

  Future<void> _copyToToday() async {
    if (_copying || _selectedDaySets.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF101C32),
        title: const Text('Copy to Today?'),
        content: Text('Copy ${_selectedDaySets.length} sets from ${_formatDate(_selectedDay!)} to today?'),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('CANCEL')), ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('COPY'))],
      ),
    );
    if (confirmed != true) return;
    setState(() => _copying = true);
    try {
      for (final set in _selectedDaySets) {
        await widget.database.saveSet(userId: widget.userId, exerciseName: set.exerciseName, weight: set.weight, reps: set.reps, date: DateTime.now());
      }
      if (!mounted) return;
      _showMessage('Workout copied to today.');
      await Future<void>.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error copying workout: $e');
      if (mounted) { setState(() => _copying = false); _showMessage('Could not copy workout.'); }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(backgroundColor: const Color(0xFF071329), elevation: 0, title: Text(widget.title)),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Column(children: [
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(12), child: Column(children: [
          TableCalendar<dynamic>(
            firstDay: DateTime(2025, 1, 1), lastDay: DateTime(2035, 12, 31), focusedDay: _focusedDay,
            selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
            eventLoader: (d) => _hasWorkout(d) ? [true] : [],
            onDaySelected: _selectDate,
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            calendarStyle: CalendarStyle(
              outsideDaysVisible: false,
              defaultTextStyle: const TextStyle(color: Colors.white),
              weekendTextStyle: const TextStyle(color: Colors.white),
              selectedDecoration: const BoxDecoration(color: Color(0xFF1688C4), shape: BoxShape.circle),
              todayDecoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.10), shape: BoxShape.circle),
              markerDecoration: const BoxDecoration(color: Color(0xFF39D98A), shape: BoxShape.circle), markerSize: 7,
            ),
            headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true, titleTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 18),
          if (_loadingSets) const CircularProgressIndicator()
          else if (_selectedDaySets.isNotEmpty) _selectedWorkoutCard()
          else const Text('Select a previous workout date to see the workout.', style: TextStyle(color: Colors.white54)),
        ])),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedDaySets.isEmpty || _copying ? null : _copyToToday,
                child: _copying
                    ? const CircularProgressIndicator()
                    : const Text('COPY TO TODAY'),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _selectedWorkoutCard() {
    final grouped = <String, List<WorkoutSet>>{};
    for (final set in _selectedDaySets) {
      grouped.putIfAbsent(set.exerciseName, () => []).add(set);
    }
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.055), borderRadius: BorderRadius.circular(18)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_formatDate(_selectedDay!), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ...grouped.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.key, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 5),
          ...e.value.asMap().entries.map((x) => Text('Set ${x.key + 1}   ${x.value.weight} kg × ${x.value.reps}', style: const TextStyle(color: Colors.white70))),
        ]))),
      ]),
    );
  }

  @override
  void dispose() { super.dispose(); }
}

class ExerciseHistoryScreen
    extends StatefulWidget {
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
  State<ExerciseHistoryScreen>
      createState() =>
          _ExerciseHistoryScreenState();
}

class _ExerciseHistoryScreenState
    extends State<
        ExerciseHistoryScreen> {
  bool _loading = true;

  Map<String, List<WorkoutSet>>
      _history = {};

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
      final sets =
          await widget.database.getExerciseHistory(
        userId: widget.userId,
        exerciseName: widget.exerciseName,
      );

      final Map<String,
              List<WorkoutSet>>
          grouped = {};

      for (final set in sets) {
        final dateKey =
            '${set.date.year}-'
            '${set.date.month.toString().padLeft(2, '0')}-'
            '${set.date.day.toString().padLeft(2, '0')}';

        grouped.putIfAbsent(
          dateKey,
          () => [],
        );

        grouped[dateKey]!.add(
          set,
        );
      }

      if (!mounted) return;

      setState(() {
        _history = grouped;
        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'Error loading history: $e',
      );

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
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor:
            const Color(0xFF071329),
        elevation: 0,
        title: Text(
          widget.exerciseName,
        ),
      ),
      body: Container(
        decoration:
            const BoxDecoration(
          gradient:
              LinearGradient(
            begin:
                Alignment.topCenter,
            end:
                Alignment.bottomCenter,
            colors: [
              Color(0xFF08285C),
              Color(0xFF061A3B),
              Color(0xFF050B18),
            ],
            stops: [
              0.0,
              0.38,
              1.0,
            ],
          ),
        ),
        child: _loading
            ? const Center(
                child:
                    CircularProgressIndicator(),
              )
            : _history.isEmpty
                ? const Center(
                    child: Text(
                      'No workout history yet.',
                      style:
                          TextStyle(
                        color:
                            Colors.white60,
                      ),
                    ),
                  )
                : ListView(
                    padding:
                        const EdgeInsets
                            .all(
                      18,
                    ),
                    children:
                        _history.entries
                            .map(
                      (entry) {
                        return _historyDayCard(
                          entry.key,
                          entry.value,
                        );
                      },
                    ).toList(),
                  ),
      ),
    );
  }

  // ============================================================
  // HISTORY DAY CARD
  // ============================================================

  Widget _historyDayCard(
    String date,
    List<WorkoutSet> sets,
  ) {
    return Container(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
            Colors.white.withValues(
          alpha: 0.055,
        ),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color:
              Colors.white.withValues(
            alpha: 0.06,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Text(
            date,
            style: const TextStyle(
              fontSize: 16,
              fontWeight:
                  FontWeight.w600,
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          ...sets.asMap().entries.map(
            (entry) {
              final index =
                  entry.key;
              final set =
                  entry.value;

              return Padding(
                padding:
                    const EdgeInsets
                        .only(
                  bottom: 8,
                ),
                child: Row(
                  children: [
                    Text(
                      'Set ${index + 1}',
                      style:
                          const TextStyle(
                        fontSize: 13,
                        color:
                            Colors.white60,
                      ),
                    ),

                    const Spacer(),

                    Text(
                      '${set.weight} kg × ${set.reps}',
                      style:
                          const TextStyle(
                        fontSize: 14,
                        fontWeight:
                            FontWeight.w500,
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
  }
}