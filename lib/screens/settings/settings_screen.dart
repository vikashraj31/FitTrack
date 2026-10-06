import 'package:drift/drift.dart' show Variable;
import 'package:flutter/material.dart';

import '../../services/database_service.dart';
import '../record/check_your_record_screen.dart';
import '../../utils/exercise_catalog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppDatabase _database = AppDatabase();

  String _weightUser = 'user1';
  bool _loadingStep = true;
  bool _loadingWeight = true;
  int _stepTarget = 10000;
  double? _currentWeight;
  List<Map<String, dynamic>> _weightHistory = [];

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    await _ensureWeightTable();
    await Future.wait([
      _loadStepTarget(),
      _loadWeightData(),
    ]);
  }

  Future<void> _ensureWeightTable() async {
    await _database.customStatement('''
      CREATE TABLE IF NOT EXISTS user_weights (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id TEXT NOT NULL,
        weight REAL NOT NULL,
        recorded_at TEXT NOT NULL
      )
    ''');
  }



  Future<void> _loadStepTarget() async {
    final target = await _database.getDailyTargets(userId: 'user1');
    if (!mounted) return;
    setState(() {
      _stepTarget = target?.stepTarget ?? 10000;
      _loadingStep = false;
    });
  }

  Future<void> _loadWeightData() async {
    final rows = await _database.customSelect(
      '''
      SELECT id, weight, recorded_at
      FROM user_weights
      WHERE user_id = ?
      ORDER BY recorded_at DESC
      ''',
      variables: [Variable.withString(_weightUser)],
    ).get();

    if (!mounted) return;
    setState(() {
      _weightHistory = rows.map((row) => {
        'id': row.read<int>('id'),
        'weight': row.read<double>('weight'),
        'recordedAt': row.read<String>('recorded_at'),
      }).toList();
      _currentWeight = _weightHistory.isEmpty
          ? null
          : (_weightHistory.first['weight'] as double);
      _loadingWeight = false;
    });
  }

  Future<void> _saveWeight(double weight) async {
    await _database.customStatement(
      'INSERT INTO user_weights (user_id, weight, recorded_at) VALUES (?, ?, ?)',
      [
        _weightUser,
        weight,
        DateTime.now().toIso8601String(),
      ],
    );
    await _loadWeightData();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFF071329),
        foregroundColor: Colors.white,
        elevation: 0,
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
            stops: [0.0, 0.38, 1.0],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 22, 18, 30),
            children: [
              const Text(
                'FitTrack Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Manage progress, targets and personal tracking data.',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
              const SizedBox(height: 26),
              _sectionTitle('Progress'),
              const SizedBox(height: 10),
              _selectorTile(
                icon: Icons.table_chart_outlined,
                title: 'Check Your Record',
                subtitle:
                    'Monthly steps, effort, diet follow % and gym attendance',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CheckYourRecordScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              _sectionTitle('Tracking'),
              const SizedBox(height: 10),
              _selectorTile(
                icon: Icons.directions_walk_outlined,
                title: 'Step Target',
                subtitle: _loadingStep
                    ? 'Loading User 1 target...'
                    : 'User 1 • $_stepTarget steps per day',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StepTargetSettingsScreen(
                        database: _database,
                        initialTarget: _stepTarget,
                      ),
                    ),
                  );
                  await _loadStepTarget();
                },
              ),
              const SizedBox(height: 10),
              _selectorTile(
                icon: Icons.fitness_center_outlined,
                title: 'Exercise List',
                subtitle: 'Manage default exercises and add your own exercises',
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ExerciseListSettingsScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              _selectorTile(
                icon: Icons.monitor_weight_outlined,
                title: 'Weight',
                subtitle: _loadingWeight
                    ? 'Loading...'
                    : _currentWeight == null
                        ? '${_weightUser == 'user1' ? 'User 1' : 'User 2'} • No weight recorded'
                        : '${_weightUser == 'user1' ? 'User 1' : 'User 2'} • ${_currentWeight!.toStringAsFixed(1)} kg',
                onTap: _showWeightSheet,
              ),
              const SizedBox(height: 24),
              _sectionTitle('About'),
              const SizedBox(height: 10),
              _infoTile(
                icon: Icons.info_outline,
                title: 'FitTrack',
                subtitle:
                    'A personal fitness tracker for workouts, daily activity and long-term progress. Your records stay stored locally on the device.',
                onTap: () => _showAboutDialog(context),
              ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  'FitTrack • Personal fitness tracker',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.40),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }







  Future<void> _showWeightSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF071329),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => _WeightSheet(
        database: _database,
        initialUser: _weightUser,
        onUserChanged: (userId) async {
          setState(() {
            _weightUser = userId;
            _loadingWeight = true;
          });
          await _loadWeightData();
        },
        onSave: _saveWeight,
      ),
    );
  }

  Widget _selectorTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return _infoTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      onTap: onTap,
      trailing: Icons.chevron_right,
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    IconData? trailing,
  }) {
    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white70, size: 21),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.52),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            Icon(trailing, color: Colors.white38),
          ],
        ],
      ),
    );

    return onTap == null
        ? child
        : InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: child,
          );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF071329),
        title: const Text('FitTrack', style: TextStyle(color: Colors.white)),
        content: const Text(
          'FitTrack is a personal fitness tracking app built to keep workout history, daily activity and progress records organized in one place.\n\nWorkout and tracking records are stored locally on the device for quick access and long-term history.',
          style: TextStyle(color: Colors.white70, height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
}

class _WeightSheet extends StatefulWidget {
  final AppDatabase database;
  final String initialUser;
  final Future<void> Function(String userId) onUserChanged;
  final Future<void> Function(double weight) onSave;

  const _WeightSheet({
    required this.database,
    required this.initialUser,
    required this.onUserChanged,
    required this.onSave,
  });

  @override
  State<_WeightSheet> createState() => _WeightSheetState();
}

class _WeightSheetState extends State<_WeightSheet> {
  late String _userId;
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _userId = widget.initialUser;
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _loading = true);
    final rows = await widget.database.customSelect(
      '''
      SELECT weight, recorded_at
      FROM user_weights
      WHERE user_id = ?
      ORDER BY recorded_at DESC
      LIMIT 30
      ''',
      variables: [Variable.withString(_userId)],
    ).get();

    if (!mounted) return;
    setState(() {
      _history = rows.map((row) => {
        'weight': row.read<double>('weight'),
        'recordedAt': row.read<String>('recorded_at'),
      }).toList();
      _loading = false;
    });
  }

  Future<void> _changeUser(String userId) async {
    setState(() => _userId = userId);
    await widget.onUserChanged(userId);
    await _loadHistory();
  }

  Future<void> _save() async {
    final weight = double.tryParse(_controller.text.trim());
    if (weight == null || weight <= 0 || weight > 500) return;

    setState(() => _saving = true);
    await widget.onSave(weight);
    _controller.clear();
    await _loadHistory();
    if (mounted) setState(() => _saving = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weight',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: _userButton('User 1', 'user1')),
                const SizedBox(width: 8),
                Expanded(child: _userButton('User 2', 'user2')),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Weight (kg)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.06),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('SAVE'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '${_userId == 'user1' ? 'User 1' : 'User 2'} Weight History',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(18),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'No weight records yet.',
                  style: TextStyle(color: Colors.white54),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _history.length,
                  separatorBuilder: (_, _) => const Divider(color: Colors.white10),
                  itemBuilder: (context, index) {
                    final row = _history[index];
                    final date = DateTime.tryParse(row['recordedAt'] as String);
                    final dateText = date == null
                        ? row['recordedAt'] as String
                        : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                    return Row(
                      children: [
                        Expanded(
                          child: Text(
                            dateText,
                            style: const TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ),
                        Text(
                          '${(row['weight'] as double).toStringAsFixed(1)} kg',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _userButton(String label, String value) {
    final selected = value == _userId;
    return InkWell(
      onTap: () => _changeUser(value),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? Colors.white.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? Colors.white.withValues(alpha: 0.30)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}


class StepTargetSettingsScreen extends StatefulWidget {
  final AppDatabase database;
  final int initialTarget;

  const StepTargetSettingsScreen({
    super.key,
    required this.database,
    required this.initialTarget,
  });

  @override
  State<StepTargetSettingsScreen> createState() => _StepTargetSettingsScreenState();
}

class _StepTargetSettingsScreenState extends State<StepTargetSettingsScreen> {
  late final TextEditingController _controller;
  bool _saving = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialTarget}');
  }

  Future<void> _save() async {
    final target = int.tryParse(_controller.text.trim());
    if (target == null || target <= 0) {
      setState(() => _message = 'Enter a valid step target.');
      return;
    }

    setState(() {
      _saving = true;
      _message = null;
    });

    try {
      final existing = await widget.database.getDailyTargets(userId: 'user1');
      await widget.database.saveDailyTargets(
        userId: 'user1',
        calorieTarget: existing?.calorieTarget ?? 2500,
        stepTarget: target,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _message = 'Could not save step target.';
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        title: const Text('Step Target'),
        backgroundColor: const Color(0xFF071329),
        foregroundColor: Colors.white,
        elevation: 0,
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
            stops: [0.0, 0.38, 1.0],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'User 1 Step Target',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Set the daily number of steps used by FitTrack for User 1.',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Daily steps',
                  labelStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.06),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.white54),
                  ),
                ),
              ),
              if (_message != null) ...[
                const SizedBox(height: 10),
                Text(_message!, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 18),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('SAVE STEP TARGET'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ExerciseListSettingsScreen extends StatefulWidget {
  const ExerciseListSettingsScreen({super.key});

  @override
  State<ExerciseListSettingsScreen> createState() => _ExerciseListSettingsScreenState();
}

class _ExerciseListSettingsScreenState extends State<ExerciseListSettingsScreen> {
  final AppDatabase _database = AppDatabase();
  final TextEditingController _newExerciseController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _message;
  List<ExerciseLibraryData> _customExercises = [];
  List<String> _hiddenDefaults = [];

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  Future<void> _loadExercises() async {
    setState(() => _loading = true);
    final custom = await _database.getExerciseLibrary(userId: 'user1');
    final hidden = await _database.getHiddenExerciseNames(userId: 'user1');

    if (!mounted) return;
    setState(() {
      _customExercises = custom;
      _hiddenDefaults = hidden;
      _loading = false;
    });
  }

  bool _isHidden(String name) {
    return _hiddenDefaults.any(
      (item) => item.toLowerCase() == name.toLowerCase(),
    );
  }

  Future<void> _addExercise() async {
    if (_saving) return;

    final clean = _newExerciseController.text.trim();
    if (clean.isEmpty) {
      setState(() => _message = 'Enter an exercise name.');
      return;
    }

    final defaultMatch = ExerciseCatalog.defaultExercises.where(
      (item) => item.toLowerCase() == clean.toLowerCase(),
    );

    if (defaultMatch.isNotEmpty) {
      final defaultName = defaultMatch.first;
      if (_isHidden(defaultName)) {
        await _database.unhideExercise(
          userId: 'user1',
          exerciseName: defaultName,
        );
        _newExerciseController.clear();
        setState(() => _message = '$defaultName restored.');
        await _loadExercises();
        return;
      }

      setState(() => _message = 'Exercise already exists in the default list.');
      return;
    }

    final duplicateCustom = _customExercises.any(
      (item) => item.exerciseName.toLowerCase() == clean.toLowerCase(),
    );
    if (duplicateCustom) {
      setState(() => _message = 'Exercise already exists.');
      return;
    }

    setState(() {
      _saving = true;
      _message = null;
    });

    await _database.saveExerciseLibraryItem(
      userId: 'user1',
      exerciseName: clean,
    );

    final all = await _database.getAllExerciseNames(
      userId: 'user1',
      defaultExercises: ExerciseCatalog.defaultExercises,
    );
    await _database.saveExerciseOrder(
      userId: 'user1',
      orderedExerciseNames: [
        ...all.where((item) => item.toLowerCase() != clean.toLowerCase()),
        clean,
      ],
    );

    _newExerciseController.clear();
    if (!mounted) return;
    setState(() {
      _saving = false;
      _message = '$clean added.';
    });
    await _loadExercises();
  }

  Future<void> _deleteExercise(String name, {required bool isDefault}) async {
    if (isDefault) {
      await _database.hideExercise(userId: 'user1', exerciseName: name);
      if (!mounted) return;
      setState(() => _message = '$name removed from the exercise list.');
      await _loadExercises();
      return;
    }

    final item = _customExercises.where(
      (exercise) => exercise.exerciseName.toLowerCase() == name.toLowerCase(),
    );
    if (item.isEmpty) return;

    await _database.deleteExerciseLibraryItem(id: item.first.id);
    if (!mounted) return;
    setState(() => _message = '$name removed from the exercise list.');
    await _loadExercises();
  }

  Widget _exerciseTile({
    required String name,
    required bool isDefault,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: Icon(
          isDefault ? Icons.fitness_center_outlined : Icons.add_circle_outline,
          color: Colors.white70,
        ),
        title: Text(
          name,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          isDefault ? 'Default exercise' : 'Custom exercise',
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
        trailing: IconButton(
          tooltip: 'Remove exercise',
          icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
          onPressed: () => _deleteExercise(name, isDefault: isDefault),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _newExerciseController.dispose();
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleDefaults = ExerciseCatalog.defaultExercises
        .where((name) => !_isHidden(name))
        .toList();

    final allVisible = <Widget>[];
    for (final name in visibleDefaults) {
      allVisible.add(_exerciseTile(name: name, isDefault: true));
    }
    for (final exercise in _customExercises) {
      allVisible.add(_exerciseTile(name: exercise.exerciseName, isDefault: false));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        title: const Text('Exercise List'),
        backgroundColor: const Color(0xFF071329),
        foregroundColor: Colors.white,
        elevation: 0,
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
            stops: [0.0, 0.38, 1.0],
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
                  children: [
                    const Text(
                      'Manage Exercises',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Add a new exercise or remove exercises you do not use. Removing an exercise does not delete its old workout history.',
                      style: TextStyle(color: Colors.white54, fontSize: 13, height: 1.35),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _newExerciseController,
                      textCapitalization: TextCapitalization.words,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'New exercise name',
                        hintText: 'e.g. Cable Crossover',
                        labelStyle: const TextStyle(color: Colors.white54),
                        hintStyle: const TextStyle(color: Colors.white30),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.06),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.white54),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saving ? null : _addExercise,
                        icon: const Icon(Icons.add),
                        label: const Text('ADD NEW EXERCISE'),
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: 10),
                      Text(_message!, style: const TextStyle(color: Colors.white70)),
                    ],
                    const SizedBox(height: 24),
                    const Text(
                      'DEFAULT EXERCISES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...visibleDefaults.map(
                      (name) => _exerciseTile(name: name, isDefault: true),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'CUSTOM EXERCISES',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_customExercises.isEmpty)
                      const Text(
                        'No custom exercises yet.',
                        style: TextStyle(color: Colors.white38),
                      )
                    else
                      ..._customExercises.map(
                        (exercise) => _exerciseTile(
                          name: exercise.exerciseName,
                          isDefault: false,
                        ),
                      ),
                    const SizedBox(height: 18),
                    Text(
                      'Total visible exercises: ${allVisible.length}',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
