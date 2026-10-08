import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/database_service.dart';
import '../../services/fitness_calculation_service.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  static const Color _premiumAccent = Color(0xFF6F8CFF);

  final AppDatabase _database = AppDatabase();

  int _selectedDays = 7;
  bool _loading = true;

  List<DailyStats> _stats = [];

  double _avgCalories = 0;
  double _avgSteps = 0;
  double _avgRecovery = 0;
  double _avgEffort = 0;
  double _avgTrainingLoad = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);

    final dailyData = await _database.getDailyDataHistory(
      userId: 'user1',
      days: _selectedDays,
    );

    final result = <DailyStats>[];

    for (final data in dailyData) {
      final sets = await _database.getSetsByDate(
        userId: 'user1',
        date: data.date,
      );

      final trainingLoad = FitnessCalculationService.calculateTrainingLoad(
        sets
            .map(
              (set) => <String, dynamic>{
                'weight': set.weight,
                'reps': set.reps,
              },
            )
            .toList(),
      );

      final actualCalories = await _database.getActualCalories(
        userId: 'user1',
        date: data.date,
      );

      result.add(
        DailyStats(
          date: data.date,
          calories: actualCalories,
          calorieTarget: data.calorieTarget.toDouble(),
          steps: data.steps.toDouble(),
          stepTarget: data.stepTarget.toDouble(),
          recovery: data.recoveryScore,
          effort: data.effortScore,
          trainingLoad: trainingLoad,
        ),
      );
    }

    result.sort((a, b) => b.date.compareTo(a.date));

    double average(List<double> values) {
      if (values.isEmpty) return 0;
      return values.reduce((a, b) => a + b) / values.length;
    }

    if (!mounted) return;

    setState(() {
      _stats = result;
      _avgCalories = average(result.map((e) => e.calories).toList());
      _avgSteps = average(result.map((e) => e.steps).toList());
      _avgRecovery = average(result.map((e) => e.recovery).toList());
      _avgEffort = average(result.map((e) => e.effort).toList());
      _avgTrainingLoad = average(result.map((e) => e.trainingLoad).toList());
      _loading = false;
    });
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  String _dateLabel(DateTime date) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text(
          'Stats',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        backgroundColor: AppTheme.background,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _premiumAccent))
          : RefreshIndicator(
              onRefresh: _loadStats,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                children: [
                  _buildPeriodSelector(),
                  const SizedBox(height: 18),
                  _buildOverviewCard(),
                  const SizedBox(height: 16),
                  _buildMetricGrid(),
                  const SizedBox(height: 20),
                  const Text(
                    'Daily History',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_stats.isEmpty)
                    _buildEmptyState()
                  else
                    ..._stats.map(_buildDailyCard),
                ],
              ),
            ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          _periodButton('7 Days', 7),
          _periodButton('30 Days', 30),
          _periodButton('All', 3650),
        ],
      ),
    );
  }

  Widget _periodButton(String label, int days) {
    final selected = _selectedDays == days;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (_selectedDays == days) return;
          setState(() => _selectedDays = days);
          _loadStats();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? _premiumAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$_selectedDays-Day Overview',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          const Text(
            'User 1 Performance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _overviewValue(
                  'Recovery',
                  '${_avgRecovery.toStringAsFixed(0)}%',
                ),
              ),
              Expanded(
                child: _overviewValue(
                  'Effort',
                  '${_avgEffort.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _overviewValue(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: _premiumAccent,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _metricCard(
          title: 'Avg Calories',
          value: '${_avgCalories.toStringAsFixed(0)} kcal',
          icon: Icons.local_fire_department_outlined,
        ),
        _metricCard(
          title: 'Avg Steps',
          value: _formatNumber(_avgSteps),
          icon: Icons.directions_walk_outlined,
        ),
       
        _metricCard(
          title: 'Training Load',
          value: _formatNumber(_avgTrainingLoad),
          icon: Icons.fitness_center_outlined,
        ),
      ],
    );
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white70, size: 24),
          const SizedBox(height: 9),
          Text(
            title,
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyCard(DailyStats stat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _dateLabel(stat.date),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(
                child: _smallStat(
                  'Calories',
                  '${stat.calories.toStringAsFixed(0)} kcal',
                ),
              ),
              Expanded(child: _smallStat('Steps', _formatNumber(stat.steps))),
            ],
          ),
          const SizedBox(height: 13),
          Row(
            children: [
              Expanded(child: _progressStat('Recovery', stat.recovery)),
              const SizedBox(width: 12),
              Expanded(child: _progressStat('Effort', stat.effort)),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Training Load: ${_formatNumber(stat.trainingLoad)}',
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _smallStat(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _progressStat(String title, double value) {
    final safeValue = value.clamp(0, 100).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
            Text(
              '${safeValue.toStringAsFixed(0)}%',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: safeValue / 100,
            minHeight: 6,
            valueColor: const AlwaysStoppedAnimation(_premiumAccent),
            backgroundColor: Colors.white.withValues(alpha: 0.08),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: const Column(
        children: [
          Icon(Icons.bar_chart_rounded, color: Colors.white54, size: 42),
          SizedBox(height: 10),
          Text(
            'No saved daily data yet',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 5),
          Text(
            'Save Daily Metrics to start building your statistics.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ],
      ),
    );
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}k';
    }
    return value.toStringAsFixed(0);
  }
}

class DailyStats {
  final DateTime date;
  final double calories;
  final double calorieTarget;
  final double steps;
  final double stepTarget;
  final double recovery;
  final double effort;
  final double trainingLoad;

  const DailyStats({
    required this.date,
    required this.calories,
    required this.calorieTarget,
    required this.steps,
    required this.stepTarget,
    required this.recovery,
    required this.effort,
    required this.trainingLoad,
  });
}
