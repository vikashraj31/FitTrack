import 'dart:math' as math;
import 'screens/calendar/user1_calendar_screen.dart';
import 'screens/user2/user2_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/diet/diet_screen.dart';
import 'screens/home/daily_metrics_screen.dart';
import 'services/database_service.dart';
import 'services/workout_seed_service.dart';
import 'screens/stats/stats_screen.dart';
import 'screens/exercise/exercise_screen.dart';
import 'screens/settings/settings_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = AppDatabase();

  await WorkoutSeedService.seedFitNotesWorkouts(database);

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

class _HomeScreenState extends State<HomeScreen> {
  final AppDatabase _database = AppDatabase();

  DailyDataData? _dailyData;

  @override
  void initState() {
    super.initState();
    _loadDailyData();
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
      MaterialPageRoute(builder: (_) => const User1Screen()),
    );

    await _loadDailyData();
  }

  // ==========================================================
  // OPEN USER 2
  // ==========================================================

  Future<void> _openUser2() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const User2Screen()),
    );
  }

  // ==========================================================
  // OPEN DAILY METRICS
  // ==========================================================

  Future<void> _openDailyMetrics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DailyMetricsScreen()),
    );

    await _loadDailyData();
  }

  // ==========================================================
  // OPEN DIET
  // ==========================================================

  Future<void> _openDiet() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DietScreen()),
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

    return _clamp((_dailyData!.steps / target) * 100);
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
  // CALORIES %
  // ==========================================================

  double _caloriePercent() {
    if (_dailyData == null) {
      return 0;
    }

    if (_dailyData!.calorieTarget <= 0) {
      return 0;
    }

    return _clamp((_dailyData!.calories / _dailyData!.calorieTarget) * 100);
  }

  // ==========================================================
  // SLEEP %
  // ==========================================================

  double _sleepPercent() {
    if (_dailyData == null) {
      return 0;
    }

    return _clamp(_dailyData!.sleepHours * 10);
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
  // DATE TEXT
  // ==========================================================

  String _dateText() {
    final date = DateTime.now();

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  // ==========================================================
  // SLEEP TEXT
  // ==========================================================

  String _sleepText() {
    if (_dailyData == null) {
      return '—';
    }

    final hours = _dailyData!.sleepHours;

    if (hours <= 0) {
      return '—';
    }

    final wholeHours = hours.floor();

    final minutes = ((hours - wholeHours) * 60).round();

    if (minutes == 60) {
      return '${wholeHours + 1}h 0m';
    }

    return '${wholeHours}h ${minutes}m';
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
            colors: [Color(0xFF08285C), Color(0xFF061A3B), Color(0xFF050B18)],
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
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'FitTrack',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),

                          const SizedBox(height: 3),

                          Text(
                            _dateText(),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white60,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: const Icon(
                        Icons.calendar_today_outlined,
                        size: 19,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // =================================================
                // TODAY
                // =================================================
                const Text(
                  'Today',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 18),

                // =================================================
                // MAIN THREE RINGS
                // =================================================
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: _metricRing(
                        value: _stepsPercent(),
                        label: 'Steps',
                        displayValue: _dailyData == null
                            ? '—'
                            : '${_stepsPercent().round()}',
                        color: const Color(0xFFB66CFF),
                      ),
                    ),

                    Expanded(
                      child: _metricRing(
                        value: _recoveryPercent(),
                        label: 'Recovery',
                        displayValue:
                            _dailyData == null || _dailyData!.recoveryScore <= 0
                            ? '—'
                            : '${_recoveryPercent().round()}',
                        color: const Color(0xFF39D98A),
                      ),
                    ),

                    Expanded(
                      child: _metricRing(
                        value: _effortPercent(),
                        label: 'Effort',
                        displayValue:
                            _dailyData == null || _dailyData!.effortScore <= 0
                            ? '—'
                            : '${_effortPercent().round()}',
                        color: const Color(0xFFFF7A21),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _infoCard(
                        icon: Icons.local_fire_department,
                        title: 'Calories',
                        value: _dailyData == null
                            ? '—'
                            : '${_dailyData!.calories.round()} kcal',
                        color: const Color(0xFFFFB52E),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: _infoCard(
                        icon: Icons.bedtime_outlined,
                        title: 'Sleep',
                        value: _sleepText(),
                        color: const Color(0xFF9B6CFF),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // =================================================
                // CALORIE PROGRESS
                // =================================================
                _wideProgressCard(
                  icon: Icons.local_fire_department_outlined,
                  title: 'Calories',
                  value: _dailyData == null
                      ? '—'
                      : '${_dailyData!.calories.round()} / '
                            '${_dailyData!.calorieTarget.round()} kcal',
                  percent: _caloriePercent(),
                  color: const Color(0xFFFFB52E),
                ),

                const SizedBox(height: 12),

                // =================================================
                // SLEEP PROGRESS
                // =================================================
                _wideProgressCard(
                  icon: Icons.bedtime_outlined,
                  title: 'Sleep',
                  value: _dailyData == null ? '—' : _sleepText(),
                  percent: _sleepPercent(),
                  color: const Color(0xFF9B6CFF),
                ),

                const SizedBox(height: 30),

                // =================================================
                // QUICK ACTIONS
                // =================================================
                const Text(
                  'Quick Actions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: _actionCard(
                        icon: Icons.fitness_center,
                        title: 'Exercises',
                        subtitle: 'Workout',
                        onTap: _openUser1,
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

                const SizedBox(height: 12),

                // =================================================
                // DAILY METRICS
                // =================================================
                _wideActionCard(
                  icon: Icons.analytics_outlined,
                  title: 'Daily Metrics',
                  subtitle: 'Update today\'s data',
                  onTap: _openDailyMetrics,
                ),

                const SizedBox(height: 12),

                // =================================================
                // STATS
                // =================================================
                _wideActionCard(
                  icon: Icons.bar_chart,
                  title: 'Stats',
                  subtitle: 'View your progress',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StatsScreen()),
                    );
                  },
                ),

                const SizedBox(height: 30),

                // =================================================
                // USERS
                // =================================================
                const Text(
                  'Users',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
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
        indicatorColor: const Color(0xFF8F5CFF).withValues(alpha: 0.30),

        selectedIndex: 0,

        onDestinationSelected: (index) {
          switch (index) {
            case 0:
              // Already on Home
              break;

            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const User1CalendarScreen()),
              );
              break;

            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ExerciseScreen(userId: 'user1'),
                ),
              );
              break;

            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
  // CIRCULAR METRIC
  // ============================================================

  Widget _metricRing({
    required double value,
    required String label,
    required String displayValue,
    required Color color,
  }) {
    return Column(
      children: [
        SizedBox(
          width: 108,
          height: 108,
          child: CustomPaint(
            painter: _RingPainter(progress: value / 100, color: color),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    displayValue,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    label,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white70,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),

          const SizedBox(height: 14),

          Text(
            title,
            style: const TextStyle(fontSize: 13, color: Colors.white60),
          ),

          const SizedBox(height: 5),

          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // WIDE PROGRESS CARD
  // ============================================================

  Widget _wideProgressCard({
    required IconData icon,
    required String title,
    required String value,
    required double percent,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 21),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),

              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: percent / 100,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 23),

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

            const Icon(Icons.chevron_right, size: 20, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // WIDE ACTION CARD
  // ============================================================

  Widget _wideActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white70, size: 23),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
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

            const Icon(Icons.chevron_right, color: Colors.white54),
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
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 25, color: Colors.white70),

            const SizedBox(height: 15),

            Text(
              name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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

        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Full Tracking',
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Manage your complete fitness data',
                  style: TextStyle(fontSize: 13, color: Colors.white60),
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
                        builder: (_) => const ExerciseScreen(userId: 'user1'),
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
                      MaterialPageRoute(builder: (_) => const DietScreen()),
                    );
                  },
                ),

                const SizedBox(height: 12),

                _user1MenuCard(
                  context,
                  icon: Icons.analytics_outlined,
                  title: 'Daily Metrics',
                  subtitle: 'Steps, sleep, effort and recovery',
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
                      MaterialPageRoute(builder: (_) => const StatsScreen()),
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
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.055),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
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
              child: Icon(icon, color: Colors.white70, size: 22),
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

            const Icon(Icons.chevron_right, color: Colors.white54),
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

  _RingPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

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
      Rect.fromCircle(center: center, radius: radius),
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
        Rect.fromCircle(center: center, radius: radius),
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

    canvas.drawCircle(center, radius - 11, innerPaint);

    // --------------------------------------------------------
    // INNER BORDER
    // --------------------------------------------------------

    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.18);

    canvas.drawCircle(center, radius - 11, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
