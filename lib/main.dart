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
import 'screens/exercise/exercise_screen.dart';
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // Load immediately from Health Connect.
    _syncHealthAndLoadData();

    // Keep today's step value as fresh as Health Connect allows.
    _stepRefreshTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _syncStepsAndLoadData(),
    );
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
      final data = await _database.getDailyData(
        userId: 'user1',
        date: DateTime.now(),
      );

      if (!mounted) return;

      setState(() {
        _dailyData = data;
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
  // OPEN USER 1
  // ==========================================================

  Future<void> _openUser1() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const User1Screen(),
      ),
    );

    await _loadDailyData();
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
        builder: (_) => const DietScreen(todayOnly: true),
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
                      color: Colors.white.withValues(alpha: 0.45),
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

    return Scaffold(
      backgroundColor: const Color(0xFF050B18),

      // ======================================================
      // BODY
      // ======================================================

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
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =================================================
                // HEADER
                // =================================================

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatHomeDate(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Today',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _showTodaysInsight,
                      tooltip: 'Today’s Insight',
                      icon: const Icon(
                        Icons.insights_outlined,
                        color: Colors.white70,
                        size: 23,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 40,
                        minHeight: 40,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Steps - left
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: _metricRing(
                          value: _stepsPercent(),
                          label: 'Steps',
                          displayValue: _dailyData == null
                              ? '0'
                              : '${_stepsPercent().round()}',
                          color: const Color(0xFFB66CFF),
                        ),
                      ),
                    ),

                    // Recovery - center, slightly higher
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

                    // Effort - right
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 28),
                        child: _metricRing(
                          value: _effortPercent(),
                          label: 'Effort',
                          displayValue:
                              _dailyData == null ||
                                      _dailyData!.effortScore <= 0
                                  ? '0'
                                  : '${_effortPercent().round()}',
                          color: const Color(0xFFFF7A21),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 34),

                // =================================================
                // DAILY DATA
                // =================================================

                const Text(
                  'Daily Data',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 14),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: _actionCard(
                        icon: Icons.fitness_center,
                        title: 'Exercises',
                        subtitle: 'Workout',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExerciseScreen(
                                userId: 'user1',
                                homeMode: true,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _actionCard(
                        icon: Icons.restaurant_menu,
                        title: 'Diet',
                        subtitle: 'Meals',
                        onTap: _openDiet,
                      ),
                    ),
                  ],
                ),

                // =================================================
                // USERS
                // =================================================

                const Text(
                  'Users',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _userCard(
                        'User 1',
                        'Full Tracking',
                        Icons.person_outline,
                        _openUser1,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _userCard(
                        'User 2',
                        'Exercise',
                        Icons.person_outline,
                        _openUser2,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF071329),
        indicatorColor:
            const Color(0xFF8F5CFF).withValues(alpha: 0.30),
        selectedIndex: 0,
        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              break;

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const User1CalendarScreen(),
                ),
              );
              break;

            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExerciseScreen(
                    userId: 'user1',
                  ),
                ),
              );
              break;

            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
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
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: 'Workout',
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
        final trainingLoad = await _getTodayTrainingLoad();

        title = 'Effort';

        description =
            'Your Effort score combines two contributors:\n\n'
            '• Steps: 40%\n'
            '• Training Load: 60%\n\n'
            'Today’s steps: $steps\n'
            'Training load: ${trainingLoad.round()}';

        break;

      case 'Recovery':
        final steps = _dailyData?.steps ?? 0;
        final trainingLoad = await _getTodayTrainingLoad();

        title = 'Recovery';

        description =
            'Your Recovery score is based on today’s activity '
            'and training load.\n\n'
            'Activity contribution: based on steps\n'
            'Training contribution: based on training load\n\n'
            'Today’s steps: $steps\n'
            'Training load: ${trainingLoad.round()}';

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

  Widget _userCard(
    String name,
    String subtitle,
    IconData icon,
    VoidCallback? onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 25,
              color: Colors.white70,
            ),
            const SizedBox(height: 15),
            Text(
              name,
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
    );
  }
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
                  icon: Icons.fitness_center,
                  title: 'Exercise',
                  subtitle: 'Track workouts and exercise history',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ExerciseScreen(
                          userId: 'user1',
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _user1MenuCard(
                  context,
                  icon: Icons.restaurant_menu,
                  title: 'Diet',
                  subtitle: 'Track meals and calories',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DietScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 12),

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
                  icon: Icons.calendar_month_outlined,
                  title: 'Calendar',
                  subtitle: 'View your activity by date',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const User1CalendarScreen(),
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

                _user1MenuCard(
                  context,
                  icon: Icons.settings_outlined,
                  title: 'Settings',
                  subtitle: 'Manage FitTrack settings',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
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