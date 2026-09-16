import 'package:flutter/material.dart';

import 'screens/user2/user2_screen.dart';
import 'screens/diet/diet_screen.dart';
import 'screens/home/daily_metrics_screen.dart';
import 'services/database_service.dart';

void main() {
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
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        useMaterial3: true,
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

class _HomeScreenState extends State<HomeScreen> {
  final AppDatabase _database = AppDatabase();

  // IMPORTANT:
  // Drift returns DailyDataData, not DailyData.
  DailyDataData? _dailyData;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadDailyData();
  }

  // ============================================================
  // LOAD TODAY'S DAILY DATA
  // ============================================================

  Future<void> _loadDailyData() async {
    try {
      final data = await _database.getDailyData(
        userId: 'user1',
        date: DateTime.now(),
      );

      if (!mounted) return;

      setState(() {
        _dailyData = data;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Error loading daily data: $e');

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ============================================================
  // FORMAT STEPS
  // ============================================================

  String _stepsValue() {
    if (_loading || _dailyData == null) {
      return '—';
    }

    return _dailyData!.steps.toString();
  }

  // ============================================================
  // FORMAT CALORIES
  // ============================================================

  String _caloriesValue() {
    if (_loading || _dailyData == null) {
      return '—';
    }

    return _dailyData!.calories.round().toString();
  }

  // ============================================================
  // FORMAT SLEEP
  // ============================================================

  String _sleepValue() {
    if (_loading || _dailyData == null) {
      return '—';
    }

    final double hours = _dailyData!.sleepHours;

    final int wholeHours = hours.floor();

    final int minutes = ((hours - wholeHours) * 60).round();

    if (minutes == 60) {
      return '${wholeHours + 1}h 0m';
    }

    return '${wholeHours}h ${minutes}m';
  }

  // ============================================================
  // EFFORT
  // ============================================================

  String _effortValue() {
    if (_loading || _dailyData == null) {
      return '—';
    }

    final double score = _dailyData!.effortScore;

    if (score <= 0) {
      return '—';
    }

    return '${score.round()}%';
  }

  // ============================================================
  // RECOVERY
  // ============================================================

  String _recoveryValue() {
    if (_loading || _dailyData == null) {
      return '—';
    }

    final double score = _dailyData!.recoveryScore;

    if (score <= 0) {
      return '—';
    }

    return '${score.round()}%';
  }

  // ============================================================
  // OPEN DAILY METRICS
  // ============================================================

  Future<void> _openDailyMetrics() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const DailyMetricsScreen(),
      ),
    );

    // Refresh Home after returning.
    await _loadDailyData();
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ==================================================
            // USER
            // ==================================================

            const Text(
              'User 1',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 20),

            // ==================================================
            // EFFORT
            // ==================================================

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Today's Effort",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _effortValue(),
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ==================================================
            // METRICS ROW 1
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    'Recovery',
                    _recoveryValue(),
                    Icons.battery_charging_full,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _metricCard(
                    'Steps',
                    _stepsValue(),
                    Icons.directions_walk,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ==================================================
            // METRICS ROW 2
            // ==================================================

            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    'Calories',
                    _caloriesValue(),
                    Icons.local_fire_department,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _metricCard(
                    'Sleep',
                    _sleepValue(),
                    Icons.bedtime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ==================================================
            // PROGRESS
            // ==================================================

            const Text(
              'Progress',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Container(
              height: 220,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text(
                  'Progress Graph',
                  style: TextStyle(
                    color: Colors.white54,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // QUICK ACTIONS
            // ==================================================

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // EXERCISES + DIET
            // --------------------------------------------------

            Row(
              children: [
                Expanded(
                  child: _actionButton(
                    'Exercises',
                    Icons.fitness_center,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _actionButton(
                    'Diet',
                    Icons.restaurant_menu,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // DAILY METRICS
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: _openDailyMetrics,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D24),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: Colors.white70,
                      ),

                      SizedBox(width: 12),

                      Expanded(
                        child: Text(
                          'Daily Metrics',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      Icon(
                        Icons.chevron_right,
                        color: Colors.white54,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // --------------------------------------------------
            // STATS
            // --------------------------------------------------

            SizedBox(
              width: double.infinity,
              child: _actionButton(
                'Stats',
                Icons.bar_chart,
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // USERS
            // ==================================================

            const Text(
              'Users',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _userCard(
                    'User 1',
                    'Full Tracking',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _userCard(
                    'User 2',
                    'Exercise',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // ========================================================
      // BOTTOM NAVIGATION
      // ========================================================

      bottomNavigationBar: NavigationBar(
        backgroundColor: const Color(0xFF15171D),
        selectedIndex: 0,
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
  // METRIC CARD
  // ============================================================

  Widget _metricCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: Colors.white70,
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white60,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // QUICK ACTION BUTTON
  // ============================================================

  Widget _actionButton(
    String title,
    IconData icon,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: title == 'Diet'
          ? () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const DietScreen(),
                ),
              );

              await _loadDailyData();
            }
          : null,

      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D24),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white70,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
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

  // ============================================================
  // USER CARD
  // ============================================================

  Widget _userCard(
    String name,
    String subtitle,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),

      onTap: () {
        if (name == 'User 2') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const User2Screen(),
            ),
          );
        }
      },

      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D24),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.person_outline,
            ),

            const SizedBox(height: 10),

            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}