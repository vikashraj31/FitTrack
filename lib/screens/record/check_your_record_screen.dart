import 'package:flutter/material.dart';
import '../../services/database_service.dart';

class CheckYourRecordScreen extends StatefulWidget {
  const CheckYourRecordScreen({super.key});

  @override
  State<CheckYourRecordScreen> createState() => _CheckYourRecordScreenState();
}

class _CheckYourRecordScreenState extends State<CheckYourRecordScreen> {
  final AppDatabase _database = AppDatabase();

  final String _userId = 'user1';
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  bool _loading = true;
  List<_RecordDay> _rows = [];

  @override
  void initState() {
    super.initState();
    _loadMonth();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  DateTime _dateOnly(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  double _clampPercent(double value) => value.clamp(0, 100).toDouble();

  Future<void> _loadMonth() async {
    if (mounted) setState(() => _loading = true);

    final first = DateTime(_month.year, _month.month, 1);
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;

    final result = <_RecordDay>[];

    for (var i = 0; i < daysInMonth; i++) {
      final day = _dateOnly(first.add(Duration(days: i)));
      final daily = await _database.getDailyData(userId: _userId, date: day);
      final dietEntries = await _database.getDietEntries(
        userId: _userId,
        date: day,
      );
      final sets = await _database.getSetsByDate(userId: _userId, date: day);

      double? dietPercent;
      if (dietEntries.isNotEmpty) {
        double planned = 0;
        double eaten = 0;
        for (final entry in dietEntries) {
          planned += entry.plannedCalories;
          if (entry.eaten) eaten += entry.actualCalories;
        }
        if (planned > 0) {
          dietPercent = _clampPercent((eaten / planned) * 100);
        }
      }

      final today = _dateOnly(DateTime.now());
      final isFutureDay = day.isAfter(today);

      final gymWent = isFutureDay ? null : sets.isNotEmpty;

      result.add(
        _RecordDay(
          date: day,
          steps: isFutureDay ? null : daily?.steps,
          effort: isFutureDay ? null : daily?.effortScore,
          dietFollow: isFutureDay ? null : dietPercent,
          gymWent: gymWent,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      _rows = result;
      _loading = false;
    });
  }

  Future<void> _changeMonth(int delta) async {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta);
    });
    await _loadMonth();
  }

  String _monthLabel() {
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
    return '${months[_month.month - 1]} ${_month.year}';
  }

  String _percent(double? value) =>
      value == null ? '—' : '${value.toStringAsFixed(0)}%';

  Widget _metricCell(String value) {
    return SizedBox(
      width: 72,
      child: Text(
        value,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'DATE',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          _metricCell('STEPS'),
          _metricCell('EFFORT'),
          _metricCell('DIET %'),
          _metricCell('GYM'),
        ],
      ),
    );
  }

  Widget _row(_RecordDay row, int index) {
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: index.isEven ? const Color(0xFF111D34) : const Color(0xFF0D182A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.035)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${row.date.day.toString().padLeft(2, '0')}/${row.date.month.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          _metricCell(row.steps == null ? '—' : '${row.steps}'),
          _metricCell(_percent(row.effort)),
          _metricCell(_percent(row.dietFollow)),
          _metricCell(
            row.gymWent == null
                ? '—'
                : row.gymWent!
                ? 'Yes'
                : 'No',
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final available = _rows
        .where(
          (r) =>
              r.steps != null ||
              r.effort != null ||
              r.dietFollow != null ||
              r.gymWent != null,
        )
        .toList();

    double average(Iterable<double> values) {
      final list = values.toList();
      if (list.isEmpty) return 0;
      return list.reduce((a, b) => a + b) / list.length;
    }

    final avgSteps = average(
      available.where((r) => r.steps != null).map((r) => r.steps!.toDouble()),
    );
    final avgEffort = average(
      available.where((r) => r.effort != null).map((r) => r.effort!),
    );
    final avgDiet = average(
      available.where((r) => r.dietFollow != null).map((r) => r.dietFollow!),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        children: [
          _summaryItem(
            'Avg Steps',
            available.isEmpty ? '—' : avgSteps.toStringAsFixed(0),
          ),
          _summaryItem(
            'Avg Effort',
            available.isEmpty ? '—' : '${avgEffort.toStringAsFixed(0)}%',
          ),
          _summaryItem(
            'Diet Follow',
            available.isEmpty ? '—' : '${avgDiet.toStringAsFixed(0)}%',
          ),
        ],
      ),
    );
  }

  Widget _summaryItem(String label, String value) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 11),
          ),
          const SizedBox(height: 4),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      appBar: AppBar(
        title: const Text(
          'Check Your Record',
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
            colors: [Color(0xFF08285C), Color(0xFF061A3B), Color(0xFF050B18)],
            stops: [0.0, 0.38, 1.0],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _loadMonth,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 18, 12, 28),
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _changeMonth(-1),
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        _monthLabel(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _changeMonth(1),
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 80),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white70),
                    ),
                  )
                else ...[
                  _summaryCard(),
                  _tableHeader(),
                  ...List.generate(
                    _rows.length,
                    (index) => _row(_rows[index], index),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordDay {
  final DateTime date;
  final int? steps;
  final double? effort;
  final double? dietFollow;
  final bool? gymWent;

  const _RecordDay({
    required this.date,
    required this.steps,
    required this.effort,
    required this.dietFollow,
    required this.gymWent,
  });
}
