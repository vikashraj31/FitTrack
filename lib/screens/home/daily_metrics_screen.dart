import 'package:flutter/material.dart';
import 'package:health/health.dart';

import '../../services/database_service.dart';
import '../../services/health_sync_service.dart';

class DailyMetricsScreen extends StatefulWidget {
  const DailyMetricsScreen({super.key});

  @override
  State<DailyMetricsScreen> createState() => _DailyMetricsScreenState();
}

class _DailyMetricsScreenState extends State<DailyMetricsScreen>
    with WidgetsBindingObserver {
  final AppDatabase _database = AppDatabase();
  final Health _health = Health();

  bool _healthConnected = false;
  bool _healthConnecting = false;

  final TextEditingController _stepTargetController = TextEditingController();

  final TextEditingController _sleepTargetController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  double _plannedCalories = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _loadTargets();
    _checkHealthConnection();
  }

  // ==========================================================
  // APP LIFECYCLE
  // ==========================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Do not automatically check/sync Health Connect on app resume.
    // Health Connect can itself trigger lifecycle changes and cause a loop.
  }

  // ==========================================================
  // CHECK HEALTH CONNECTION
  // ==========================================================

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
      });

      if (_healthConnected) {
        await _syncHealthData();
      }
    } catch (e) {
      debugPrint('Health permission check failed: $e');

      if (!mounted) return;

      setState(() {
        _healthConnected = false;
      });
    }
  }

  // ==========================================================
  // AUTOMATIC HEALTH SYNC
  // ==========================================================

  Future<void> _syncHealthData() async {
    try {
      final healthData = await HealthSyncService.syncUser1Health();

      if (healthData == null) {
        debugPrint('Health authorization not available.');
        return;
      }

      final steps = healthData['steps'] as int? ?? 0;

      final sleepHours = (healthData['sleepHours'] as num?)?.toDouble() ?? 0;

      final now = DateTime.now();

      final targets = await _database.getDailyTargets(userId: 'user1');

      if (targets == null) {
        debugPrint(
          'Daily targets not found. '
          'Health data not saved.',
        );
        return;
      }

      final existing = await _database.getDailyData(userId: 'user1', date: now);

      await _database.saveDailyData(
        userId: 'user1',
        date: now,
        calories: existing?.calories ?? 0,
        calorieTarget: targets.calorieTarget,
        steps: steps,
        stepTarget: targets.stepTarget,
        sleepHours: sleepHours,
        recoveryScore: existing?.recoveryScore ?? 0,
        effortScore: existing?.effortScore ?? 0,
      );

      debugPrint(
        'Automatic health sync complete: '
        '$steps steps, '
        '${sleepHours.toStringAsFixed(1)}h sleep',
      );

      if (!mounted) return;

      setState(() {
        _healthConnected = true;
      });
    } catch (e) {
      debugPrint('Automatic health sync failed: $e');
    }
  }

  // ==========================================================
  // CONNECT HEALTH DATA
  // ==========================================================

  Future<void> _connectHealthData() async {
    if (_healthConnecting) {
      return;
    }

    setState(() {
      _healthConnecting = true;
    });

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

      if (!authorized) {
        if (!mounted) return;

        setState(() {
          _healthConnected = false;
          _healthConnecting = false;
        });

        _showMessage('Health permission was not granted.');

        return;
      }

      // Sync immediately after permission is granted.
      final healthData = await HealthSyncService.syncUser1Health();

      final steps = healthData?['steps'] as int? ?? 0;

      final sleepHours = (healthData?['sleepHours'] as num?)?.toDouble() ?? 0;

      if (!mounted) return;

      setState(() {
        _healthConnected = true;
        _healthConnecting = false;
      });

      _showMessage(
        'Health connected: $steps steps • '
        '${sleepHours.toStringAsFixed(1)}h sleep',
      );
    } catch (e) {
      debugPrint('Health connection error: $e');

      if (!mounted) return;

      setState(() {
        _healthConnected = false;
        _healthConnecting = false;
      });

      _showMessage('Could not connect Health data.');
    }
  }

  // ==========================================================
  // LOAD TARGETS
  // ==========================================================

  Future<void> _loadTargets() async {
    try {
      final targets = await _database.getDailyTargets(userId: 'user1');

      final plannedCalories = await _database.getPlannedCalories(
        userId: 'user1',
        date: DateTime.now(),
      );

      if (!mounted) return;

      if (targets == null) {
        _stepTargetController.text = '10000';
        _sleepTargetController.text = '8';
      } else {
        _stepTargetController.text = targets.stepTarget.toString();

        _sleepTargetController.text = targets.sleepTarget.toStringAsFixed(1);
      }

      _plannedCalories = plannedCalories;

      setState(() {
        _loading = false;
      });
    } catch (e) {
      // keep your existing catch block
    }
  }

  // ==========================================================
  // SAVE TARGETS
  // ==========================================================

  Future<void> _saveTargets() async {
    final stepTarget = int.tryParse(_stepTargetController.text.trim());

    final sleepTarget = double.tryParse(_sleepTargetController.text.trim());

    if (stepTarget == null || sleepTarget == null) {
      _showMessage('Please enter valid target values.');
      return;
    }

    if (stepTarget <= 0 || sleepTarget <= 0 || sleepTarget > 24) {
      _showMessage('Please enter realistic target values.');
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _database.saveDailyTargets(
        userId: 'user1',
        calorieTarget: _plannedCalories,
        stepTarget: stepTarget,
        sleepTarget: sleepTarget,
      );
      await _syncHealthData();

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage('Daily targets saved.');

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint('Error saving daily targets: $e');

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage('Could not save targets.');
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _stepTargetController.dispose();
    _sleepTargetController.dispose();

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
          'Daily Targets',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  const Text(
                    'Set Your Daily Targets',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    'Set your targets once. FitTrack will use '
                    'them for your daily tracking and calculations.',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // CALORIES
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D24),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.cyan.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.local_fire_department,
                            color: Colors.cyan,
                            size: 23,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Calories Target',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 3),
                              const Text(
                                'Automatically calculated from today\'s planned diet',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${_plannedCalories.toStringAsFixed(0)} kcal',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // STEPS
                  // ==================================================
                  _targetCard(
                    icon: Icons.directions_walk,
                    title: 'Steps Target',
                    subtitle: 'Your daily step target',
                    controller: _stepTargetController,
                    hint: '10000',
                    suffix: 'steps',
                    decimal: false,
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // SLEEP
                  // ==================================================
                  _targetCard(
                    icon: Icons.bedtime,
                    title: 'Sleep Target',
                    subtitle: 'Your target sleep duration',
                    controller: _sleepTargetController,
                    hint: '8',
                    suffix: 'hours',
                    decimal: true,
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // INFORMATION
                  // ==================================================
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1D24),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.cyan.withValues(alpha: 0.18),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.cyan, size: 22),

                        SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'Steps and sleep will be tracked '
                            'automatically when phone health '
                            'data is connected. Calories will '
                            'come from your Diet entries.',
                            style: TextStyle(
                              color: Colors.white60,
                              fontSize: 13,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ==================================================
                  // CONNECT HEALTH DATA
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _healthConnecting ? null : _connectHealthData,

                      icon: _healthConnecting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _healthConnected
                                  ? Icons.check_circle_outline
                                  : Icons.favorite_outline,
                            ),

                      label: Text(
                        _healthConnecting
                            ? 'Connecting...'
                            : _healthConnected
                            ? 'Health Data Connected'
                            : 'Connect Health Data',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      style: OutlinedButton.styleFrom(
                        foregroundColor: _healthConnected
                            ? Colors.greenAccent
                            : Colors.cyan,

                        side: BorderSide(
                          color: _healthConnected
                              ? Colors.greenAccent
                              : Colors.cyan,
                        ),

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // ==================================================
                  // SAVE
                  // ==================================================
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _saving ? null : _saveTargets,

                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),

                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            )
                          : const Text(
                              'Save Targets',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  // ==========================================================
  // TARGET CARD
  // ==========================================================

  Widget _targetCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required TextEditingController controller,
    required String hint,
    required String suffix,
    required bool decimal,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icon, color: Colors.cyan, size: 23),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),

                const SizedBox(height: 8),

                TextField(
                  controller: controller,
                  keyboardType: decimal
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.number,
                  decoration: InputDecoration(
                    hintText: hint,
                    suffixText: suffix,
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
