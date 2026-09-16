import 'package:flutter/material.dart';

import '../../services/database_service.dart';
import '../../services/fitness_calculation_service.dart';

class DailyMetricsScreen extends StatefulWidget {
  const DailyMetricsScreen({super.key});

  @override
  State<DailyMetricsScreen> createState() =>
      _DailyMetricsScreenState();
}

class _DailyMetricsScreenState
    extends State<DailyMetricsScreen> {
  final AppDatabase _database = AppDatabase();

  DateTime _selectedDate = DateTime.now();

  final TextEditingController _caloriesController =
      TextEditingController();

  final TextEditingController _calorieTargetController =
      TextEditingController(text: '2500');

  final TextEditingController _stepsController =
      TextEditingController();

  final TextEditingController _stepTargetController =
      TextEditingController(text: '10000');

  final TextEditingController _sleepController =
      TextEditingController();

  bool _loading = true;
  bool _saving = false;

  // Calculated values shown before saving.
  double _effortScore = 0;
  double _recoveryScore = 0;
  double _trainingLoad = 0;

  @override
  void initState() {
    super.initState();

    _loadData();
  }

  // ==========================================================
  // LOAD DAILY DATA
  // ==========================================================

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final data = await _database.getDailyData(
        userId: 'user1',
        date: _selectedDate,
      );

      if (!mounted) return;

      if (data == null) {
        _caloriesController.clear();
        _calorieTargetController.text = '2500';

        _stepsController.clear();
        _stepTargetController.text = '10000';

        _sleepController.clear();

        _effortScore = 0;
        _recoveryScore = 0;
        _trainingLoad = 0;
      } else {
        _caloriesController.text =
            data.calories.toString();

        _calorieTargetController.text =
            data.calorieTarget.toString();

        _stepsController.text =
            data.steps.toString();

        _stepTargetController.text =
            data.stepTarget.toString();

        _sleepController.text =
            data.sleepHours.toString();

        _effortScore = data.effortScore;
        _recoveryScore = data.recoveryScore;
      }

      await _calculatePreview();

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    } catch (e) {
      debugPrint(
        'Error loading daily metrics: $e',
      );

      if (!mounted) return;

      setState(() {
        _loading = false;
      });
    }
  }

  // ==========================================================
  // DATE SELECTOR
  // ==========================================================

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2035, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyan,
              surface: Color(0xFF1A1D24),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    setState(() {
      _selectedDate = picked;
    });

    await _loadData();
  }

  // ==========================================================
  // CALCULATE PREVIEW
  // ==========================================================

  Future<void> _calculatePreview() async {
    final steps =
        int.tryParse(
          _stepsController.text.trim(),
        ) ??
        0;

    final stepTarget =
        int.tryParse(
          _stepTargetController.text.trim(),
        ) ??
        10000;

    final sleepHours =
        double.tryParse(
          _sleepController.text.trim(),
        ) ??
        0;

    if (stepTarget <= 0) {
      _trainingLoad = 0;
      _effortScore = 0;
      _recoveryScore = 0;
      return;
    }

    // --------------------------------------------------------
    // GET WORKOUT DATA
    // --------------------------------------------------------

    final workoutSets =
        await _database.getTodaySets(
      'user1',
      _selectedDate,
    );

    // --------------------------------------------------------
    // CONVERT WORKOUT DATA
    // --------------------------------------------------------

    final workoutData =
        workoutSets.map((set) {
      return <String, dynamic>{
        'weight': set.weight,
        'reps': set.reps,
      };
    }).toList();

    // --------------------------------------------------------
    // TRAINING LOAD
    // --------------------------------------------------------

    _trainingLoad =
        FitnessCalculationService
            .calculateTrainingLoad(
      workoutData,
    );

    // --------------------------------------------------------
    // EFFORT
    // --------------------------------------------------------

    _effortScore =
        FitnessCalculationService.calculateEffort(
      steps: steps.toDouble(),
      stepTarget: stepTarget.toDouble(),
      trainingLoad: _trainingLoad,
    );

    // --------------------------------------------------------
    // RECOVERY
    // --------------------------------------------------------

    _recoveryScore =
        FitnessCalculationService.calculateRecovery(
      sleepHours: sleepHours,
      steps: steps.toDouble(),
      stepTarget: stepTarget.toDouble(),
      trainingLoad: _trainingLoad,
    );
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  Future<void> _save() async {
    final calories = double.tryParse(
      _caloriesController.text.trim(),
    );

    final calorieTarget = double.tryParse(
      _calorieTargetController.text.trim(),
    );

    final steps = int.tryParse(
      _stepsController.text.trim(),
    );

    final stepTarget = int.tryParse(
      _stepTargetController.text.trim(),
    );

    final sleepHours = double.tryParse(
      _sleepController.text.trim(),
    );

    if (calories == null ||
        calorieTarget == null ||
        steps == null ||
        stepTarget == null ||
        sleepHours == null) {
      _showMessage(
        'Please enter valid values.',
      );
      return;
    }

    if (calories < 0 ||
        calorieTarget <= 0 ||
        steps < 0 ||
        stepTarget <= 0 ||
        sleepHours < 0 ||
        sleepHours > 24) {
      _showMessage(
        'Please enter realistic values.',
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      // ------------------------------------------------------
      // CALCULATE FRESH SCORES
      // ------------------------------------------------------

      await _calculatePreview();

      // ------------------------------------------------------
      // SAVE EVERYTHING
      // ------------------------------------------------------

      await _database.saveDailyData(
        userId: 'user1',
        date: _selectedDate,
        calories: calories,
        calorieTarget: calorieTarget,
        steps: steps,
        stepTarget: stepTarget,
        sleepHours: sleepHours,
        recoveryScore: _recoveryScore,
        effortScore: _effortScore,
      );

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        'Daily metrics saved.',
      );

      Navigator.pop(context, true);
    } catch (e) {
      debugPrint(
        'Error saving daily metrics: $e',
      );

      if (!mounted) return;

      setState(() {
        _saving = false;
      });

      _showMessage(
        'Could not save daily metrics.',
      );
    }
  }

  // ==========================================================
  // MESSAGE
  // ==========================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ==========================================================
  // DATE FORMAT
  // ==========================================================

  String _formatDate(DateTime date) {
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

    return '${date.day} '
        '${months[date.month - 1]} '
        '${date.year}';
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    _caloriesController.dispose();
    _calorieTargetController.dispose();
    _stepsController.dispose();
    _stepTargetController.dispose();
    _sleepController.dispose();

    _database.close();

    super.dispose();
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFF0F1115),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF0F1115),
        elevation: 0,
        title: const Text(
          'Daily Metrics',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // DATE
                  // ==================================================

                  const Text(
                    'Selected Date',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 8),

                  InkWell(
                    borderRadius:
                        BorderRadius.circular(18),
                    onTap: _selectDate,
                    child: Container(
                      width: double.infinity,
                      padding:
                          const EdgeInsets.all(18),
                      decoration:
                          BoxDecoration(
                        color:
                            const Color(0xFF1A1D24),
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month,
                            color: Colors.cyan,
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          Expanded(
                            child: Text(
                              _formatDate(
                                _selectedDate,
                              ),
                              style:
                                  const TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right,
                            color:
                                Colors.white54,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // CALORIES
                  // ==================================================

                  const Text(
                    'Calories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _inputCard(
                    icon:
                        Icons.local_fire_department,
                    title:
                        'Calories Consumed',
                    controller:
                        _caloriesController,
                    hint: 'Example: 2350',
                    suffix: 'kcal',
                  ),

                  const SizedBox(height: 12),

                  _inputCard(
                    icon: Icons.flag_outlined,
                    title: 'Calorie Target',
                    controller:
                        _calorieTargetController,
                    hint: 'Example: 2500',
                    suffix: 'kcal',
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // STEPS
                  // ==================================================

                  const Text(
                    'Steps',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _inputCard(
                    icon:
                        Icons.directions_walk,
                    title:
                        'Steps Completed',
                    controller:
                        _stepsController,
                    hint: 'Example: 7842',
                    suffix: 'steps',
                    decimal: false,
                  ),

                  const SizedBox(height: 12),

                  _inputCard(
                    icon: Icons.flag_outlined,
                    title: 'Steps Target',
                    controller:
                        _stepTargetController,
                    hint: 'Example: 10000',
                    suffix: 'steps',
                    decimal: false,
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // SLEEP
                  // ==================================================

                  const Text(
                    'Sleep',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  _inputCard(
                    icon: Icons.bedtime,
                    title:
                        'Sleep Duration',
                    controller:
                        _sleepController,
                    hint: 'Example: 7.5',
                    suffix: 'hours',
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // CALCULATED SCORES
                  // ==================================================

                  _buildCalculatedScores(),

                  const SizedBox(height: 24),

                  // ==================================================
                  // SUMMARY
                  // ==================================================

                  _buildSummary(),

                  const SizedBox(height: 24),

                  // ==================================================
                  // SAVE
                  // ==================================================

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed:
                          _saving ? null : _save,
                      style:
                          FilledButton.styleFrom(
                        backgroundColor:
                            Colors.cyan,
                        foregroundColor:
                            Colors.black,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            16,
                          ),
                        ),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                    Colors.black,
                              ),
                            )
                          : const Text(
                              'Save Daily Metrics',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    FontWeight.bold,
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
  // CALCULATED SCORES CARD
  // ==========================================================

  Widget _buildCalculatedScores() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Calculated Scores',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _scoreItem(
                  icon: Icons.bolt,
                  title: 'Effort',
                  value:
                      '${_effortScore.round()}',
                  color:
                      const Color(0xFFFF7A21),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: _scoreItem(
                  icon:
                      Icons.favorite_outline,
                  title: 'Recovery',
                  value:
                      '${_recoveryScore.round()}%',
                  color:
                      const Color(0xFF39D98A),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              const Icon(
                Icons.fitness_center,
                size: 18,
                color: Colors.white54,
              ),

              const SizedBox(width: 8),

              const Text(
                'Training Load',
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 13,
                ),
              ),

              const Spacer(),

              Text(
                _trainingLoad
                    .toStringAsFixed(0),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SCORE ITEM
  // ==========================================================

  Widget _scoreItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(
          alpha: 0.18,
        ),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),

          const SizedBox(height: 10),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // INPUT CARD
  // ==========================================================

  Widget _inputCard({
    required IconData icon,
    required String title,
    required TextEditingController controller,
    required String hint,
    required String suffix,
    bool decimal = true,
  }) {
    return Container(
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  Colors.cyan.withValues(
                alpha: 0.12,
              ),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.cyan,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style:
                      const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: controller,

                  onChanged: (_) {
                    _calculatePreview()
                        .then((_) {
                      if (mounted) {
                        setState(() {});
                      }
                    });
                  },

                  keyboardType: decimal
                      ? const TextInputType
                          .numberWithOptions(
                          decimal: true,
                        )
                      : TextInputType.number,

                  decoration:
                      InputDecoration(
                    hintText: hint,
                    suffixText: suffix,
                    border:
                        InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.zero,
                  ),

                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SUMMARY
  // ==========================================================

  Widget _buildSummary() {
    final calories =
        double.tryParse(
              _caloriesController.text,
            ) ??
            0;

    final calorieTarget =
        double.tryParse(
              _calorieTargetController.text,
            ) ??
            0;

    final steps =
        int.tryParse(
              _stepsController.text,
            ) ??
            0;

    final stepTarget =
        int.tryParse(
              _stepTargetController.text,
            ) ??
            0;

    final sleep =
        double.tryParse(
              _sleepController.text,
            ) ??
            0;

    final caloriePercent =
        calorieTarget > 0
            ? (calories /
                    calorieTarget) *
                100
            : 0;

    final stepPercent =
        stepTarget > 0
            ? (steps /
                    stepTarget) *
                100
            : 0;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Text(
            'Today Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          _summaryRow(
            'Calories',
            '${calories.toStringAsFixed(0)} / '
                '${calorieTarget.toStringAsFixed(0)} kcal',
            '${caloriePercent.toStringAsFixed(0)}%',
          ),

          const SizedBox(height: 12),

          _summaryRow(
            'Steps',
            '$steps / $stepTarget',
            '${stepPercent.toStringAsFixed(0)}%',
          ),

          const SizedBox(height: 12),

          _summaryRow(
            'Sleep',
            '${sleep.toStringAsFixed(1)} hours',
            '',
          ),

          const SizedBox(height: 12),

          _summaryRow(
            'Effort',
            '${_effortScore.round()} / 100',
            '',
          ),

          const SizedBox(height: 12),

          _summaryRow(
            'Recovery',
            '${_recoveryScore.round()} / 100',
            '',
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SUMMARY ROW
  // ==========================================================

  Widget _summaryRow(
    String title,
    String value,
    String percentage,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ],
          ),
        ),

        if (percentage.isNotEmpty)
          Text(
            percentage,
            style:
                const TextStyle(
              color: Colors.cyan,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
      ],
    );
  }
}