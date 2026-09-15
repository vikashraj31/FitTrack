import 'package:flutter/material.dart';
import 'screens/user2/user2_screen.dart';

void main() {
  runApp(const FitTrackApp());
}

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

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------------- USER ----------------

            const Text(
              'User 1',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- EFFORT ----------------

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1D24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Today's Effort",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),

                  SizedBox(height: 8),

                  Text(
                    '82%',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ---------------- METRICS ROW 1 ----------------

            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    'Recovery',
                    '78%',
                    Icons.battery_charging_full,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _metricCard(
                    'Steps',
                    '7,842',
                    Icons.directions_walk,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ---------------- METRICS ROW 2 ----------------

            Row(
              children: [
                Expanded(
                  child: _metricCard(
                    'Calories',
                    '2,350',
                    Icons.local_fire_department,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _metricCard(
                    'Sleep',
                    '7h 20m',
                    Icons.bedtime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ---------------- PROGRESS ----------------

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

            // ---------------- QUICK ACTIONS ----------------

            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

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

            SizedBox(
              width: double.infinity,
              child: _actionButton(
                'Stats',
                Icons.bar_chart,
              ),
            ),

            const SizedBox(height: 24),

            // ---------------- USERS ----------------

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
                    context,
                    'User 1',
                    'Full Tracking',
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _userCard(
                    context,
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

      // ---------------- BOTTOM NAVIGATION ----------------

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

  // ==================================================
  // METRIC CARD
  // ==================================================

  static Widget _metricCard(
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

  // ==================================================
  // QUICK ACTION BUTTON
  // ==================================================

  static Widget _actionButton(
    String title,
    IconData icon,
  ) {
    return Container(
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
          Icon(icon),

          const SizedBox(width: 12),

          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================================================
  // USER CARD
  // ==================================================

  static Widget _userCard(
    BuildContext context,
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
              builder: (context) => const User2Screen(),
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
            const Icon(Icons.person_outline),

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