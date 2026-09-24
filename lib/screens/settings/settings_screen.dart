import 'package:drift/drift.dart' show Variable;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:file_picker/file_picker.dart';

import '../../services/backup_service.dart';
import '../../services/database_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with WidgetsBindingObserver {
  final AppDatabase _database = AppDatabase();
  final Health _health = Health();

  String _exerciseUser = 'user1';
  String _weightUser = 'user1';
  bool _loadingExercise = false;
  bool _loadingStep = true;
  bool _loadingWeight = true;
  bool _healthConnected = false;
  bool _healthChecking = true;
  bool _healthConnecting = false;
  List<double> _exerciseVolumes = List<double>.filled(30, 0);
  int _stepTarget = 10000;
  double? _currentWeight;
  List<Map<String, dynamic>> _weightHistory = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initialize();
    _checkHealthConnection();
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

  Future<void> _loadExerciseGraph() async {
    setState(() => _loadingExercise = true);

    final today = DateTime.now();
    final volumes = <double>[];

    for (int i = 29; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day)
          .subtract(Duration(days: i));
      final sets = await _database.getSetsByDate(
        userId: _exerciseUser,
        date: date,
      );

      double volume = 0;
      for (final set in sets) {
        volume += set.weight * set.reps;
      }
      volumes.add(volume);
    }

    if (!mounted) return;
    setState(() {
      _exerciseVolumes = volumes;
      _loadingExercise = false;
    });
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

  Future<void> _saveStepTarget(int target) async {
    final existing = await _database.getDailyTargets(userId: 'user1');

    await _database.saveDailyTargets(
      userId: 'user1',
      calorieTarget: existing?.calorieTarget ?? 2500,
      stepTarget: target,
    );
  }

  Future<void> _checkHealthConnection() async {
    try {
      await _health.configure();

      final types = <HealthDataType>[
        HealthDataType.STEPS,
        HealthDataType.SLEEP_ASLEEP,
      ];

      final permissions = <HealthDataAccess>[
        HealthDataAccess.READ,
        HealthDataAccess.READ,
      ];

      final hasPermissions = await _health.hasPermissions(
        types,
        permissions: permissions,
      );

      if (!mounted) return;
      setState(() {
        _healthConnected = hasPermissions ?? false;
        _healthChecking = false;
      });
    } catch (e) {
      debugPrint('Health Connect status check failed: $e');

      if (!mounted) return;
      setState(() {
        _healthConnected = false;
        _healthChecking = false;
      });
    }
  }

  Future<void> _connectHealth() async {
    if (_healthConnecting) return;

    setState(() => _healthConnecting = true);

    try {
      await _health.configure();

      final types = <HealthDataType>[
        HealthDataType.STEPS,
        HealthDataType.SLEEP_ASLEEP,
      ];

      final permissions = <HealthDataAccess>[
        HealthDataAccess.READ,
        HealthDataAccess.READ,
      ];

      final authorized = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );

      if (!mounted) return;

      setState(() {
        _healthConnected = authorized;
        _healthConnecting = false;
      });

      if (!authorized) {
        _showHealthMessage('Health Connect permission was not granted.');
      }
    } catch (e) {
      debugPrint('Health Connect connection failed: $e');

      if (!mounted) return;
      setState(() {
        _healthConnected = false;
        _healthConnecting = false;
      });

      _showHealthMessage('Could not connect to Health Connect.');
    }
  }

  void _showHealthMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkHealthConnection();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
              _sectionTitle('Exercise Progress'),
              const SizedBox(height: 10),
              _selectorTile(
                icon: Icons.fitness_center_outlined,
                title: '30-Day Exercise Graph',
                subtitle: _exerciseUser == 'user1'
                    ? 'User 1 • Training volume'
                    : 'User 2 • Training volume',
                onTap: _showExerciseUserPicker,
              ),
              const SizedBox(height: 12),
              _exerciseGraphCard(),
              const SizedBox(height: 24),
              _sectionTitle('Tracking'),
              const SizedBox(height: 10),
              _selectorTile(
                icon: Icons.health_and_safety_outlined,
                title: 'Health Connect',
                subtitle: _healthChecking
                    ? 'Checking connection...'
                    : _healthConnected
                        ? 'Connected ✓ • Steps & sleep permissions'
                        : 'Not connected • Tap to connect',
                onTap: _connectHealth,
              ),
              const SizedBox(height: 10),
              _selectorTile(
                icon: Icons.directions_walk_outlined,
                title: 'Step Target',
                subtitle: _loadingStep
                    ? 'Loading User 1 target...'
                    : 'User 1 • $_stepTarget steps per day',
                onTap: _showStepTargetEditor,
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
              _sectionTitle('Data'),
              const SizedBox(height: 10),
              _selectorTile(
                icon: Icons.backup_outlined,
                title: 'Backup & Restore',
                subtitle: 'Save or restore your FitTrack data as a backup file.',
                onTap: _showBackupOptions,
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

  Widget _exerciseGraphCard() {
    if (_loadingExercise) {
      return _card(
        const SizedBox(
          height: 250,
          child: Center(
            child: CircularProgressIndicator(color: Colors.white70),
          ),
        ),
      );
    }

    final maxVolume = _exerciseVolumes.fold<double>(
      0,
      (max, value) => value > max ? value : max,
    );
    final chartMax = maxVolume <= 0 ? 1000.0 : maxVolume * 1.2;

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _exerciseUser == 'user1' ? 'User 1' : 'User 2',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Text(
                '30 DAYS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Daily training volume (kg × reps)',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 29,
                minY: 0,
                maxY: chartMax,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: chartMax / 4,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 42,
                      getTitlesWidget: (value, meta) => Text(
                        _formatAxis(value),
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 7,
                      getTitlesWidget: (value, meta) {
                        final day = DateTime.now().subtract(
                          Duration(days: 29 - value.round()),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${day.day}/${day.month}',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 9,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < _exerciseVolumes.length; i++)
                        FlSpot(i.toDouble(), _exerciseVolumes[i]),
                    ],
                    isCurved: true,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(show: true),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatAxis(double value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toInt().toString();
  }

  Future<void> _showExerciseUserPicker() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF071329),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _userPicker(
        title: 'Exercise Progress',
        selected: _exerciseUser,
      ),
    );

    if (selected == null) return;

    if (!mounted) return;
    setState(() {
      _exerciseUser = selected;
    });

    await _loadExerciseGraph();
  }

  Future<void> _showStepTargetEditor() async {
    final controller = TextEditingController(text: '$_stepTarget');

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF071329),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(sheetContext).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'User 1 Step Target',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Only User 1 has a configurable step target in Settings.',
              style: TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Daily steps'),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final target = int.tryParse(controller.text.trim());
                  if (target == null || target <= 0) return;
                  await _saveStepTarget(target);

                  if (sheetContext.mounted) {
                    Navigator.pop(sheetContext);
                  }

                  if (mounted) {
                    setState(() => _stepTarget = target);
                  }
                },
                child: const Text('SAVE STEP TARGET'),
              ),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
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

  Widget _userPicker({required String title, required String selected}) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 14),
            _pickerOption('User 1', 'user1', selected),
            const SizedBox(height: 8),
            _pickerOption('User 2', 'user2', selected),
          ],
        ),
      ),
    );
  }

  Widget _pickerOption(String label, String value, String selected) {
    return ListTile(
      onTap: () => Navigator.pop(context, value),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      tileColor: Colors.white.withValues(alpha: 0.05),
      leading: const Icon(Icons.person_outline, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: value == selected
          ? const Icon(Icons.check_circle, color: Colors.white)
          : null,
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

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
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

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
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
    );
  }

  Future<void> _showBackupOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF071329),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Backup & Restore',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your workout, diet, targets, weight history and other local FitTrack records are included.',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              _selectorTile(
                icon: Icons.cloud_upload_outlined,
                title: 'Backup Now',
                subtitle: 'Create a JSON backup file',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _backupNow();
                },
              ),
              const SizedBox(height: 10),
              _selectorTile(
                icon: Icons.restore_outlined,
                title: 'Restore Backup',
                subtitle: 'Restore data from a FitTrack JSON backup',
                onTap: () {
                  Navigator.pop(sheetContext);
                  _restoreBackup();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _backupNow() async {
    try {
      _showBackupMessage('Preparing backup...');

      final bytes = await BackupService.createBackupBytes(_database);
      final now = DateTime.now();
      final fileName =
          'FitTrack_Backup_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.json';

      final savedUri = await FilePicker.saveFile(
        dialogTitle: 'Save FitTrack Backup',
        fileName: fileName,
        bytes: bytes,
        mimeType: 'application/json',
        allowedExtensions: ['json'],
      );

      if (!mounted) return;

      _showBackupMessage(
        savedUri == null
            ? 'Backup cancelled.'
            : 'Backup saved successfully.',
      );
    } catch (e) {
      debugPrint('Backup failed: $e');
      if (mounted) {
        _showBackupMessage('Backup failed. Please try again.');
      }
    }
  }

  Future<void> _restoreBackup() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF071329),
        title: const Text(
          'Restore Backup?',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Restoring a backup will replace the current FitTrack local data with the data inside the backup file.\n\nMake sure you have a recent backup of your current data before continuing.',
          style: TextStyle(color: Colors.white70, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('RESTORE'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      _showBackupMessage('Choose your FitTrack backup file...');

      final picked = await FilePicker.pickFile(
        dialogTitle: 'Select FitTrack Backup',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (picked == null) {
        if (mounted) _showBackupMessage('Restore cancelled.');
        return;
      }

      final bytes = await picked.readAsBytes();

      if (!mounted) return;
      _showBackupMessage('Restoring data...');

      final counts = await BackupService.restoreFromBytes(
        _database,
        bytes,
      );

      await _initialize();

      if (!mounted) return;

      final totalRows = counts.values.fold<int>(
        0,
        (sum, count) => sum + count,
      );

      _showBackupMessage(
        'Restore complete • $totalRows records restored.',
      );
    } on FormatException catch (e) {
      debugPrint('Invalid backup: $e');
      if (mounted) {
        _showBackupMessage('Invalid FitTrack backup file.');
      }
    } catch (e) {
      debugPrint('Restore failed: $e');
      if (mounted) {
        _showBackupMessage('Restore failed. Please try again.');
      }
    }
  }

  void _showBackupMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
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
