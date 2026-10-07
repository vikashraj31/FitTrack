import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/calendar/user1_calendar_screen.dart';
import 'screens/user2/user2_screen.dart';
import 'screens/diet/diet_screen.dart';
import 'screens/home/daily_metrics_screen.dart';
import 'services/database_service.dart';
import 'services/health_sync_service.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/exercise/user1_home_exercise_screen.dart';
import 'screens/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const FitTrackApp());
}

// ============================================================
// APP
// ============================================================

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FitTrack',
      theme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF050B18),
      ),
      home: const HomeScreen(),
    );
  }
}

// ============================================================
// HOME SCREEN
// ============================================================

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// ============================================================
// HOME STATE
// ============================================================

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  final AppDatabase _database = AppDatabase();

  DailyDataData? _dailyData;
  Timer? _stepRefreshTimer;
  bool _healthSyncInProgress = false;
  static const Map<int, double> _dailyCalorieTargets = {
  DateTime.monday: 2675,
  DateTime.tuesday: 2725,
  DateTime.wednesday: 2660,
  DateTime.thursday: 2760,
  DateTime.friday: 2705,
  DateTime.saturday: 2705,
  DateTime.sunday: 2685,
};

  @override
void initState() {
  super.initState();

  WidgetsBinding.instance.addObserver(this);

  // Let the Home screen render first.
  WidgetsBinding.instance.addPostFrameCallback((_) {
    if (!mounted) return;

    _syncHealthAndLoadData();

    // Refresh Health Connect data periodically without blocking startup.
    _stepRefreshTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _syncStepsAndLoadData(),
    );
  });
}

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncHealthAndLoadData();
    }
  }

  // ==========================================================
  // AUTOMATIC HEALTH SYNC
  // ==========================================================

  Future<void> _syncHealthAndLoadData() async {
    if (_healthSyncInProgress) {
      return;
    }

    _healthSyncInProgress = true;

    try {
      final healthData = await HealthSyncService.syncUser1Health();

      if (healthData != null) {
        final existing = await _database.getDailyData(
          userId: 'user1',
          date: DateTime.now(),
        );

        final targets = await _database.getDailyTargets(
          userId: 'user1',
        );

        final steps = (healthData['steps'] as num?)?.toInt() ?? 0;

        final plannedCalories = await _database.getPlannedCalories(
          userId: 'user1',
          date: DateTime.now(),
        );

        final calorieTarget = plannedCalories > 0
            ? plannedCalories
            : (existing?.calorieTarget ?? 0);

        final stepTarget =
            targets?.stepTarget ?? existing?.stepTarget ?? 10000;

        await _database.saveDailyData(
          userId: 'user1',
          date: DateTime.now(),
          calories: existing?.calories ?? 0,
          calorieTarget: calorieTarget,
          steps: steps,
          stepTarget: stepTarget,
          recoveryScore: existing?.recoveryScore ?? 0,
          effortScore: existing?.effortScore ?? 0,
        );
      }
    } catch (e) {
      debugPrint('Home health sync error: $e');
    } finally {
      _healthSyncInProgress = false;
    }

    await _loadDailyData();
  }

  // ==========================================================
  // FAST STEP-ONLY REFRESH
  // ==========================================================

  Future<void> _syncStepsAndLoadData() async {
    if (_healthSyncInProgress || !mounted) {
      return;
    }

    _healthSyncInProgress = true;

    try {
      final steps = await HealthSyncService.getTodaySteps();

      final existing = await _database.getDailyData(
        userId: 'user1',
        date: DateTime.now(),
      );

      final targets = await _database.getDailyTargets(
        userId: 'user1',
      );

      await _database.saveDailyData(
        userId: 'user1',
        date: DateTime.now(),
        calories: existing?.calories ?? 0,
        calorieTarget: existing?.calorieTarget ?? 0,
        steps: steps,
        stepTarget: targets?.stepTarget ?? existing?.stepTarget ?? 10000,
        recoveryScore: existing?.recoveryScore ?? 0,
        effortScore: existing?.effortScore ?? 0,
      );

      await _loadDailyData();
    } catch (e) {
      debugPrint('Fast step refresh error: $e');
    } finally {
      _healthSyncInProgress = false;
    }
  }

  // ==========================================================
  // LOAD TODAY DATA
  // ==========================================================

  Future<void> _loadDailyData() async {
    try {
      final now = DateTime.now();

      final data = await _database.getDailyData(
        userId: 'user1',
        date: now,
      );

      if (data == null) {
        if (!mounted) return;

        setState(() {
          _dailyData = null;
        });
        return;
      }

   // ==========================================================
// CALORIES — SAME TARGET AS DIET SCREEN
// ==========================================================

final actualCalories = await _database.getActualCalories(
  userId: 'user1',
  date: now,
);

final currentCalorieTarget =
    _dailyCalorieTargets[now.weekday] ?? data.calorieTarget;

// ==========================================================
// STEP TARGET — ALWAYS SYNC WITH SETTINGS
// ==========================================================

final targets = await _database.getDailyTargets(
  userId: 'user1',
);

final currentStepTarget =
    targets?.stepTarget ?? data.stepTarget;

// ==========================================================
// REFRESH HOME DATA
// ==========================================================

final refreshedData = data.copyWith(
  calories: actualCalories,
  calorieTarget: currentCalorieTarget,
  stepTarget: currentStepTarget,
);

// ==========================================================
// KEEP DAILY DATA CACHE IN SYNC
// ==========================================================

final caloriesChanged =
    (data.calories - actualCalories).abs() > 0.001;

final calorieTargetChanged =
    (data.calorieTarget - currentCalorieTarget).abs() > 0.001;

final stepTargetChanged =
    data.stepTarget != currentStepTarget;

if (caloriesChanged ||
    calorieTargetChanged ||
    stepTargetChanged) {
  await _database.saveDailyData(
    userId: 'user1',
    date: now,
    calories: actualCalories,
    calorieTarget: currentCalorieTarget,
    steps: data.steps,
    stepTarget: currentStepTarget,
    recoveryScore: data.recoveryScore,
    effortScore: data.effortScore,
  );
}

      if (!mounted) return;

      setState(() {
        _dailyData = refreshedData;
      });
    } catch (e) {
      debugPrint('Error loading daily data: $e');

      if (!mounted) return;

      setState(() {
        _dailyData = null;
      });
    }
  }

  // ==========================================================
  // OPEN USER 2
  // ==========================================================

  Future<void> _openUser2() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const User2Screen(),
      ),
    );
  }

  // ==========================================================
  // OPEN DIET
  // ==========================================================

  Future<void> _openDiet() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DietScreen(),
      ),
    );

    await _loadDailyData();
  }

  // ==========================================================
  // STEPS %
  // ==========================================================

  double _stepsPercent() {
    if (_dailyData == null) {
      return 0;
    }

    final target = _dailyData!.stepTarget;

    if (target <= 0) {
      return 0;
    }

    return _clamp(
      (_dailyData!.steps / target) * 100,
    );
  }

  // ==========================================================
  // RECOVERY %
  // ==========================================================

  double _recoveryPercent() {
    if (_dailyData == null) {
      return 0;
    }

    return _clamp(_dailyData!.recoveryScore);
  }

  // ==========================================================
  // EFFORT %
  // ==========================================================

  double _effortPercent() {
    if (_dailyData == null) {
      return 0;
    }

    return _clamp(_dailyData!.effortScore);
  }

  // ==========================================================
  // CLAMP
  // ==========================================================

  double _clamp(double value) {
    if (value.isNaN || value.isInfinite) {
      return 0;
    }

    if (value < 0) {
      return 0;
    }

    if (value > 100) {
      return 100;
    }

    return value;
  }

  // ==========================================================
  // TODAY'S INSIGHT
  // ==========================================================

  void _showTodaysInsight() {
    if (!mounted) return;

    final recovery = _recoveryPercent();
    final steps = _dailyData?.steps ?? 0;
    final stepTarget = _dailyData?.stepTarget ?? 0;

    String message;

    if (_dailyData == null) {
      message =
          'Today’s fitness data is still loading. '
          'Your insight will update once today’s activity is available.';
    } else if (recovery <= 30) {
      message =
          'Your recovery is currently low. '
          'Today’s score is influenced by your activity and training load. '
          'If you have already trained, additional rest and avoiding '
          'unnecessary extra activity may support recovery.';
    } else if (recovery <= 60) {
      message =
          'Your recovery is currently moderate. '
          'Your activity and training load are both contributing to '
          'today’s recovery score.';
    } else {
      message =
          'Your recovery is currently in a higher range. '
          'Your activity and training load are contributing to today’s '
          'overall balance.';
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0A1730),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.insights_outlined,
                      color: Colors.white70,
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Today’s Insight',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.white60,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: Colors.white70,
                  ),
                ),
                if (_dailyData != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0x73FFFFFF),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$steps steps'
                    '${stepTarget > 0 ? '  •  Target $stepTarget' : ''}'
                    '  •  Recovery ${recovery.round()}%',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stepRefreshTimer?.cancel();
    _database.close();
    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF050B18),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    final steps = _dailyData?.steps ?? 0;
    final stepTarget = _dailyData?.stepTarget ?? 10000;
    final calories = _dailyData?.calories ?? 0;
    final calorieTarget = _dailyData?.calorieTarget ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A2D63),
              Color(0xFF071D43),
              Color(0xFF050B18),
            ],
            stops: [0.0, 0.34, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================================================
                // HEADER
                // =====================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FitTrack',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _formatHomeDate(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        onTap: _showTodaysInsight,
                        borderRadius: BorderRadius.circular(16),
                        child: const SizedBox(
                          width: 46,
                          height: 46,
                          child: Icon(
                            Icons.insights_outlined,
                            color: Colors.white70,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // =====================================================
                // TODAY SUMMARY
                // =====================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.14),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _summaryStat(
                              label: 'Steps',
                              value: '$steps',
                              subtext: stepTarget > 0
                                  ? 'Target $stepTarget'
                                  : 'Today',
                              icon: Icons.directions_walk_outlined,
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 54,
                            color: Colors.white12,
                          ),
                          Expanded(
                            child: _summaryStat(
                              label: 'Calories',
                              value: calories.toStringAsFixed(0),
                              subtext: calorieTarget > 0
                                  ? 'of ${calorieTarget.toStringAsFixed(0)} kcal'
                                  : 'logged today',
                              icon: Icons.local_fire_department_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // =====================================================
                // SCORE RINGS
                // =====================================================
                const Text(
                  'Daily Score',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(8, 14, 8, 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.11),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.05),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _metricRing(
                          value: _stepsPercent(),
                          label: 'Steps',
                          displayValue: _dailyData == null
                              ? '0'
                              : '${_stepsPercent().round()}',
                          color: const Color(0xFFB66CFF),
                        ),
                      ),
                      Expanded(
                        child: _metricRing(
                          value: _recoveryPercent(),
                          label: 'Recovery',
                          displayValue:
                              _dailyData == null ||
                                      _dailyData!.recoveryScore <= 0
                                  ? '0'
                                  : '${_recoveryPercent().round()}',
                          color: const Color(0xFF39D98A),
                        ),
                      ),
                      Expanded(
                        child: _metricRing(
                          value: _effortPercent(),
                          label: 'Effort',
                          displayValue:
                              _dailyData == null ||
                                      _dailyData!.effortScore <= 0
                                  ? '0'
                                  : '${_effortPercent().round()}',
                          color: const Color(0xFFFF8A3D),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // =====================================================
                // QUICK ACTIONS
                // =====================================================
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _actionCard(
                        icon: Icons.fitness_center_outlined,
                        title: 'Exercises',
                        subtitle: 'Track workout',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const User1HomeExerciseScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionCard(
                        icon: Icons.person_outline,
                        title: 'User 2',
                        subtitle: 'Track Workout',
                        onTap: _openUser2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _actionCard(
                        icon: Icons.bar_chart_outlined,
                        title: 'Stats',
                        subtitle: 'View progress',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const StatsScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _actionCard(
                        icon: Icons.restaurant_menu_outlined,
                        title: 'Diet',
                        subtitle: 'Track meals',
                        onTap: _openDiet,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // =====================================================
                // BOTTOM NAVIGATION PREVIEW / INFO
                // =====================================================
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.04),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.touch_app_outlined,
                        size: 18,
                        color: Colors.white38,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Tap any score ring to see its breakdown.',
                          style: TextStyle(
                            fontSize: 12,
                           color: Color(0x73FFFFFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF071329),
        indicatorColor: const Color(0xFF8F5CFF).withValues(alpha: 0.30),
        selectedIndex: 0,
        onDestinationSelected: (index) async {
          switch (index) {
            case 0:
              break;
            case 1:
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const User1CalendarScreen(),
                ),
              );
              break;
            case 2:
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );

              // Refresh Home immediately after a Settings change.
              await _loadDailyData();
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _summaryStat({
    required String label,
    required String value,
    required String subtext,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white70, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtext,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HOME DATE
  // ============================================================

  String _formatHomeDate(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

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

    return '${weekdays[date.weekday - 1]}, '
        '${date.day} ${months[date.month - 1]}';
  }

  // ============================================================
  // CIRCULAR METRIC
  // ============================================================

  Widget _metricRing({
    required double value,
    required String label,
    required String displayValue,
    required Color color,
  }) {
    return InkWell(
      onTap: () => _showScoreBreakdown(label),
      borderRadius: BorderRadius.circular(60),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            SizedBox(
              width: 108,
              height: 108,
              child: CustomPaint(
                painter: _RingPainter(
                  progress: value / 100,
                  color: color,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        displayValue,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SCORE BREAKDOWN
  // ============================================================

  Future<void> _showScoreBreakdown(String metric) async {
    if (!mounted) return;

    String title;
    String description;

    switch (metric) {
      case 'Steps':
        final steps = _dailyData?.steps ?? 0;
        final target = _dailyData?.stepTarget ?? 0;

        title = 'Steps';

        description = target > 0
            ? 'Your Steps score is based on today’s steps compared '
                'with your step target.\n\n'
                'Today: $steps steps\n'
                'Target: $target steps'
            : 'Your Steps score is based on today’s steps compared '
                'with your step target.';

        break;

      case 'Effort':
        final steps = _dailyData?.steps ?? 0;
        final target = _dailyData?.stepTarget ?? 0;
        final trainingLoad = await _getTodayTrainingLoad();

        final dietScore = await _database.getDietFollowScore(
          userId: 'user1',
          date: DateTime.now(),
        );

        title = 'Effort';

        description =
            'Your Effort score combines three contributors:\n\n'
            '• Steps: 25%\n'
            '• Diet Follow: 20%\n'
            '• Workout: 55%\n\n'
            'Today’s steps: $steps'
            '${target > 0 ? ' / Target: $target' : ''}\n'
            'Diet follow: ${dietScore.round()}%\n'
            'Training load: ${trainingLoad.round()}';

        break;

      case 'Recovery':
        final steps = _dailyData?.steps ?? 0;
        final target = _dailyData?.stepTarget ?? 0;

        final recentLoads = await _database.getRecentTrainingLoads(
          userId: 'user1',
          date: DateTime.now(),
        );

        final recentWorkoutDays =
            await _database.getRecentWorkoutDayCount(
          userId: 'user1',
          date: DateTime.now(),
        );

        final todayLoad =
            recentLoads.isNotEmpty ? recentLoads[0] : 0;
        final yesterdayLoad =
            recentLoads.length > 1 ? recentLoads[1] : 0;
        final twoDaysAgoLoad =
            recentLoads.length > 2 ? recentLoads[2] : 0;

        title = 'Recovery';

        description =
            'Your Recovery score combines three contributors:\n\n'
            '• Recent Training Load: 50%\n'
            '• Activity / Steps: 30%\n'
            '• Rest Days: 20%\n\n'
            'Today’s steps: $steps'
            '${target > 0 ? ' / Target: $target' : ''}\n'
            'Training load — Today: ${todayLoad.round()}\n'
            'Yesterday: ${yesterdayLoad.round()}\n'
            '2 days ago: ${twoDaysAgoLoad.round()}\n'
            'Workout days in recent 3 days: $recentWorkoutDays\n\n'
            'Sleep is not used in the Recovery calculation.';

        break;

      default:
        return;
    }

    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0A1730),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$title Score Breakdown',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      color: Colors.white60,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.55,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // TRAINING LOAD
  // ============================================================

  Future<double> _getTodayTrainingLoad() async {
    final sets = await _database.getSetsByDate(
      userId: 'user1',
      date: DateTime.now(),
    );

    return sets.fold<double>(
      0,
      (total, set) => total + (set.weight * set.reps),
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  Widget _actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        constraints: const BoxConstraints(minHeight: 86),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
              size: 23,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.50),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 20,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // USER CARD
  // ============================================================

}

// ============================================================
// USER 1 SCREEN
// ============================================================

class User1Screen extends StatelessWidget {
  const User1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF050B18),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        backgroundColor: const Color(0xFF071329),
        elevation: 0,
        title: const Text(
          'User 1',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Full Tracking',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Manage your complete fitness data',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white60,
                  ),
                ),
                const SizedBox(height: 28),

                _user1MenuCard(
                  context,
                  icon: Icons.analytics_outlined,
                  title: 'Daily Metrics',
                  subtitle: 'Steps, effort and recovery',
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DailyMetricsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _user1MenuCard(
                  context,
                  icon: Icons.bar_chart,
                  title: 'Stats',
                  subtitle: 'View long-term progress',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StatsScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _user1MenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.07),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white70,
                size: 22,
              ),
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.50),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RING PAINTER
// ============================================================

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;

  _RingPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(
      size.width / 2,
      size.height / 2,
    );

    final radius = size.width / 2 - 8;

    // --------------------------------------------------------
    // BACKGROUND ARC
    // --------------------------------------------------------

    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.10);

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: radius,
      ),
      -math.pi / 2,
      math.pi * 2,
      false,
      backgroundPaint,
    );

    // --------------------------------------------------------
    // PROGRESS ARC
    // --------------------------------------------------------

    if (progress > 0) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeCap = StrokeCap.round
        ..color = color;

      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        -math.pi / 2,
        math.pi * 2 * progress.clamp(0.0, 1.0),
        false,
        progressPaint,
      );
    }

    // --------------------------------------------------------
    // INNER CIRCLE
    // --------------------------------------------------------

    final innerPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color(0xFF07101E);

    canvas.drawCircle(
      center,
      radius - 11,
      innerPaint,
    );

    // --------------------------------------------------------
    // INNER BORDER
    // --------------------------------------------------------

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.18);

    canvas.drawCircle(
      center,
      radius - 11,
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color;
  }
}