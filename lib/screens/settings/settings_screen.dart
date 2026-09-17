import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                'Manage your app and tracking information',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 26),
              _sectionTitle('Users'),
              const SizedBox(height: 10),
              _infoTile(
                icon: Icons.person_outline,
                title: 'User 1',
                subtitle: 'Full Tracking',
              ),
              const SizedBox(height: 10),
              _infoTile(
                icon: Icons.person_outline,
                title: 'User 2',
                subtitle: 'Exercise Tracking',
              ),
              const SizedBox(height: 24),
              _sectionTitle('Tracking'),
              const SizedBox(height: 10),
              _infoTile(
                icon: Icons.local_fire_department_outlined,
                title: 'Calories',
                subtitle: 'Daily target is managed from Daily Metrics',
              ),
              const SizedBox(height: 10),
              _infoTile(
                icon: Icons.directions_walk_outlined,
                title: 'Steps',
                subtitle: 'Daily target is managed from Daily Metrics',
              ),
              const SizedBox(height: 10),
              _infoTile(
                icon: Icons.bedtime_outlined,
                title: 'Sleep',
                subtitle: 'Daily sleep data is saved with Daily Metrics',
              ),
              const SizedBox(height: 24),
              _sectionTitle('Data'),
              const SizedBox(height: 10),
              _infoTile(
                icon: Icons.storage_outlined,
                title: 'Local Storage',
                subtitle: 'FitTrack stores workout, diet and daily tracking data locally.',
              ),
              const SizedBox(height: 10),
              _infoTile(
                icon: Icons.history_outlined,
                title: 'History',
                subtitle: 'Saved records are kept for long-term tracking.',
              ),
              const SizedBox(height: 24),
              _sectionTitle('About'),
              const SizedBox(height: 10),
              _infoTile(
                icon: Icons.info_outline,
                title: 'FitTrack',
                subtitle: 'Personal fitness and workout tracking app',
              ),
              const SizedBox(height: 28),
              Center(
                child: Text(
                  'FitTrack • Local fitness tracker',
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

  Widget _infoTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.06),
        ),
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
            child: Icon(
              icon,
              color: Colors.white70,
              size: 21,
            ),
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
                    height: 1.25,
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
