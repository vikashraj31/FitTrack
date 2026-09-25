import 'package:flutter/material.dart';

import '../../services/database_service.dart';

/// User 1 weekly diet plan.
///
/// IMPORTANT:
/// The supplied diet chart gives quantities and daily/meal calorie ranges,
/// but it does not give calories for every individual food item.
/// Therefore item-level planned calories are intentionally stored as 0.
/// Actual calories remain editable when the user logs what was really eaten.
class DietScreen extends StatefulWidget {
  final bool todayOnly;

  const DietScreen({super.key, this.todayOnly = false});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final AppDatabase _database = AppDatabase();

  bool get _todayOnly => widget.todayOnly;

  DateTime _selectedDate = DateTime.now();
  List<DietEntry> _entries = [];
  List<ExtraCaloriesEntry> _extraCalories = [];
  bool _loading = true;

  static const List<String> _meals = [
    'Breakfast',
    'Lunch',
    'Evening',
    'Dinner',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ==========================================================
  // WEEKLY PLAN
  // ==========================================================

  // ==========================================================
  // LOAD + SEED
  // ==========================================================

  Future<void> _loadData() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }


    final entries = await _database.getDietEntries(
      userId: 'user1',
      date: _selectedDate,
    );

    final extra = await _database.getExtraCalories(
      userId: 'user1',
      date: _selectedDate,
    );

    if (!mounted) return;

    setState(() {
      _entries = entries
          .toList();
      _extraCalories = extra;
      _loading = false;
    });
  }


  // ==========================================================
  // DATE
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
  // DIET ENTRY ACTIONS
  // ==========================================================

  Future<void> _toggleEaten(DietEntry entry) async {
    if (!entry.eaten) {
      await _database.updateDietEntry(
        id: entry.id,
        actualQuantity: entry.plannedQuantity,
        actualCalories: entry.plannedCalories,
        eaten: true,
      );
    } else {
      await _database.updateDietEntry(
        id: entry.id,
        actualQuantity: 0,
        actualCalories: 0,
        eaten: false,
      );
    }

    await _loadData();
  }

  Future<void> _editDietEntry(DietEntry entry) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EditDietDialog(entry: entry, database: _database),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _deleteDietEntry(DietEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D24),
        title: const Text('Delete food?'),
        content: Text('Delete ${entry.foodName} from ${entry.meal}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _database.deleteDietEntry(entry.id);
    await _loadData();
  }

  // ==========================================================
  // EXTRA CALORIES
  // ==========================================================

  Future<void> _addExtraCalories() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) =>
          AddExtraCaloriesDialog(database: _database, date: _selectedDate),
    );

    if (result == true) {
      await _loadData();
    }
  }

  Future<void> _deleteExtraCalories(ExtraCaloriesEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D24),
        title: const Text('Delete extra calories?'),
        content: Text(
          '${entry.calories.toStringAsFixed(0)} kcal will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await _database.deleteExtraCalories(entry.id);
    await _loadData();
  }

  // ==========================================================
  // CALCULATIONS
  // ==========================================================

  double get _actualCalories {
    double total = 0;

    for (final entry in _entries) {
      if (entry.eaten) {
        total += entry.actualCalories;
      }
    }

    for (final entry in _extraCalories) {
      total += entry.calories;
    }

    return total;
  }

  double get _targetMidpoint => 0;

  double get _caloriePercentage {
    if (_targetMidpoint <= 0) return 0;
    return (_actualCalories / _targetMidpoint) * 100;
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
        title: Text(
          _todayOnly ? "Today's Diet" : 'Diet',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: _todayOnly
            ? null
            : [
                IconButton(
                  onPressed: _selectDate,
                  icon: const Icon(Icons.calendar_month),
                ),
              ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                children: [
                  _buildDateCard(),
                  const SizedBox(height: 12),
                  _buildPlanSummary(),
                  const SizedBox(height: 16),
                  _buildCaloriesSummary(),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: _openFoodLibraryDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Food'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._meals.map(_buildMealSection),
                  const SizedBox(height: 4),
                  _buildExtraCalories(),
                  const SizedBox(height: 20),
                  _buildFinalTotal(),
                ],
              ),
            ),
    );
  }

  // ==========================================================
  // DATE CARD
  // ==========================================================

  Widget _buildDateCard() {
    final card = Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Colors.cyan),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _todayOnly ? 'Today' : 'Selected Date',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  'Diet • ${_formatDate(_selectedDate)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (!_todayOnly)
            const Icon(Icons.chevron_right, color: Colors.white54),
        ],
      ),
    );

    if (_todayOnly) {
      return card;
    }

    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(18),
      child: card,
    );
  }

  // ==========================================================
  // PLAN SUMMARY
  // ==========================================================

  Widget _buildPlanSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF19242D), Color(0xFF172027)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.cyan.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.restaurant_menu, color: Colors.cyan),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Plan',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'No planned calories',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                Text(
                  'Add food to create your plan',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CALORIE SUMMARY
  // ==========================================================

  Widget _buildCaloriesSummary() {
    final actual = _actualCalories;
    final percentage = _caloriePercentage;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calories Eaten',
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                actual.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 5),
                child: Text('kcal', style: TextStyle(color: Colors.white54)),
              ),
              const Spacer(),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Target: ${_targetMidpoint.toStringAsFixed(0)} kcal',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 4),
          const SizedBox(height: 3),
          Text(
            "Today's plan: Add food manually",
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (percentage / 100).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation(Colors.cyan),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // MEAL SECTION
  // ==========================================================

  Widget _buildMealSection(String meal) {
    final entries = _entries.where((entry) => entry.meal == meal).toList();

    final isSundaySkip =
        _selectedDate.weekday == DateTime.sunday && meal == 'Breakfast';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    meal,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _addCustomFood(meal),
                  icon: const Icon(Icons.add_circle_outline),
                  tooltip: 'Add food',
                ),
              ],
            ),
            if (isSundaySkip)
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Text(
                  'SKIP — no planned breakfast',
                  style: TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (entries.isEmpty && !isSundaySkip)
              const Padding(
                padding: EdgeInsets.fromLTRB(4, 8, 4, 8),
                child: Text(
                  'No food added',
                  style: TextStyle(color: Colors.white38),
                ),
              ),
            ...entries.map(_buildFoodItem),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FOOD ITEM
  // ==========================================================

  Widget _buildFoodItem(DietEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF22252D),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: entry.eaten,
            activeColor: Colors.cyan,
            onChanged: (_) => _toggleEaten(entry),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () => _editDietEntry(entry),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.foodName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Planned: ${entry.quantityUnit}',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    if (entry.eaten) ...[
                      const SizedBox(height: 3),
                      Text(
                        'Actual: ${_formatQuantity(entry.actualQuantity)} '
                        '${entry.quantityUnit}',
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 12,
                        ),
                      ),
                      if (entry.actualCalories > 0)
                        Text(
                          '${entry.actualCalories.toStringAsFixed(0)} kcal logged',
                          style: const TextStyle(
                            color: Colors.cyan,
                            fontSize: 12,
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _editDietEntry(entry),
            icon: const Icon(
              Icons.edit_outlined,
              size: 18,
              color: Colors.white38,
            ),
            tooltip: 'Edit',
          ),
          IconButton(
            onPressed: () => _deleteDietEntry(entry),
            icon: const Icon(
              Icons.delete_outline,
              size: 18,
              color: Colors.white38,
            ),
            tooltip: 'Delete',
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // FOOD LIBRARY
  // ==========================================================

  Future<void> _openFoodLibraryDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AddFoodLibraryDialog(database: _database),
    );

    if (result == true && mounted) {
      setState(() {});
    }
  }

  // ADD CUSTOM FOOD
  // ==========================================================

  Future<void> _addCustomFood(String meal) async {
    final result = await showDialog<FoodLibraryPickerResult>(
      context: context,
      builder: (_) => FoodLibraryPickerDialog(
        database: _database,
        meal: meal,
      ),
    );

    if (!mounted || result == null) return;

    if (result.createManually) {
      final manualResult = await showDialog<bool>(
        context: context,
        builder: (_) => AddDietDialog(
          meal: meal,
          database: _database,
          date: _selectedDate,
        ),
      );

      if (manualResult == true) {
        await _loadData();
      }
      return;
    }

    final food = result.food;
    if (food == null) return;

    await _database.saveDietEntry(
      userId: 'user1',
      date: _selectedDate,
      meal: meal,
      foodName: food.foodName,
      plannedQuantity: food.quantity,
      quantityUnit: food.quantityUnit,
      plannedCalories: food.calories,
      actualQuantity: 0,
      actualCalories: 0,
      eaten: false,
    );

    await _loadData();
  }

  // ==========================================================
  // EXTRA CALORIES
  // ==========================================================

  Widget _buildExtraCalories() {
    final totalExtra = _extraCalories.fold<double>(
      0,
      (sum, item) => sum + item.calories,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Extra Calories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                onPressed: _addExtraCalories,
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
          if (_extraCalories.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 6, bottom: 4),
              child: Text(
                'No extra calories',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          ..._extraCalories.map(
            (entry) => ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                entry.description.isEmpty
                    ? 'Extra calories'
                    : entry.description,
              ),
              subtitle: Text('${entry.calories.toStringAsFixed(0)} kcal'),
              trailing: IconButton(
                onPressed: () => _deleteExtraCalories(entry),
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
              ),
            ),
          ),
          if (_extraCalories.isNotEmpty) ...[
            const Divider(color: Colors.white12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Extra Total',
                  style: TextStyle(color: Colors.white70),
                ),
                Text(
                  '${totalExtra.toStringAsFixed(0)} kcal',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // FINAL TOTAL
  // ==========================================================

  Widget _buildFinalTotal() {
    final actual = _actualCalories;
    final target = _targetMidpoint;
    final difference = actual - target;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Total',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _totalItem(
                  'Actual',
                  '${actual.toStringAsFixed(0)} kcal',
                ),
              ),
              Expanded(
                child: _totalItem(
                  'Target midpoint',
                  '${target.toStringAsFixed(0)} kcal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            difference >= 0
                ? '${difference.toStringAsFixed(0)} kcal above midpoint'
                : '${difference.abs().toStringAsFixed(0)} kcal remaining to midpoint',
            style: TextStyle(
              color: difference > 0 ? Colors.orange : Colors.white54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Plan: Add food manually',
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _totalItem(String title, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  String _formatQuantity(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }

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

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }
}

// =================================================================
// PLAN MODELS
// =================================================================

class DietDayPlan {
  final String day;
  final String calorieRange;
  final String proteinRange;
  final Map<String, List<DietPlanItem>> meals;

  const DietDayPlan({
    required this.day,
    required this.calorieRange,
    required this.proteinRange,
    required this.meals,
  });
}

class DietPlanItem {
  final String name;
  final String quantity;

  const DietPlanItem(this.name, this.quantity);
}


// =================================================================
// FOOD CALORIE HELPERS
// =================================================================

String _normalizedFoodName(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .trim();
}

/// Starter defaults used only when the user has not entered a value.
/// Values are intentionally simple estimates; the user can override them.
double _defaultCaloriesFor(String food, String unit) {
  final name = _normalizedFoodName(food);
  final normalizedUnit = unit.toLowerCase().trim();

  if (normalizedUnit == 'g') {
    if (name == 'rice' || name == 'plain rice' || name == 'cooked rice') {
      // USDA FoodData Central: cooked white long-grain rice ≈130 kcal/100 g.
      return 130;
    }
    if (name.contains('egg')) return 155;
    if (name.contains('banana')) return 89;
    if (name.contains('bread')) return 266;
    if (name.contains('oat')) return 389;
    if (name.contains('chicken')) return 165;
    if (name.contains('paneer')) return 265;
    if (name.contains('dal')) return 116;
    if (name.contains('curd') || name.contains('dahi') || name.contains('yogurt')) {
      return 61;
    }
    if (name.contains('milk')) return 61;
  }

  if (normalizedUnit == 'ml' && name.contains('milk')) {
    return 61;
  }

  if (normalizedUnit == 'piece') {
    if (name.contains('egg')) return 78;
    if (name.contains('banana')) return 105;
    if (name.contains('roti') || name.contains('chapati')) return 100;
    if (name.contains('apple')) return 95;
  }

  if (normalizedUnit == 'slice' && name.contains('bread')) return 80;
  if (normalizedUnit == 'scoop' &&
      (name.contains('whey') || name.contains('protein'))) {
    return 120;
  }
  if (normalizedUnit == 'cup' &&
      (name == 'rice' || name == 'plain rice' || name == 'cooked rice')) {
    return 205;
  }

  // User-requested fallback for unknown foods.
  return 1;
}

double _calculateCalories({
  required double quantity,
  required String unit,
  required double caloriesValue,
}) {
  final normalizedUnit = unit.toLowerCase().trim();

  // Gram/ml values are entered on a per-100 basis.
  if (normalizedUnit == 'g' || normalizedUnit == 'ml') {
    return quantity * caloriesValue / 100;
  }

  // All other units are per-piece/per-serving/per-unit.
  return quantity * caloriesValue;
}

String _calorieFieldLabel(String unit) {
  switch (unit.toLowerCase().trim()) {
    case 'g':
      return 'Calories per 100 g';
    case 'ml':
      return 'Calories per 100 ml';
    case 'piece':
      return 'Calories per piece';
    case 'slice':
      return 'Calories per slice';
    case 'serving':
      return 'Calories per serving';
    case 'scoop':
      return 'Calories per scoop';
    case 'cup':
      return 'Calories per cup';
    default:
      return 'Calories per unit';
  }
}

String _unitExample(String unit) {
  switch (unit.toLowerCase().trim()) {
    case 'g':
      return 'Example: 150';
    case 'ml':
      return 'Example: 250';
    case 'piece':
      return 'Example: 2';
    case 'slice':
      return 'Example: 3';
    case 'serving':
      return 'Example: 1';
    case 'scoop':
      return 'Example: 1';
    case 'cup':
      return 'Example: 1';
    default:
      return 'Example: 1';
  }
}

String _formatKcal(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(1);
}

// =================================================================
// ADD DIET DIALOG
// =================================================================

class AddDietDialog extends StatefulWidget {
  final String meal;
  final AppDatabase database;
  final DateTime date;

  const AddDietDialog({
    super.key,
    required this.meal,
    required this.database,
    required this.date,
  });

  @override
  State<AddDietDialog> createState() => _AddDietDialogState();
}

class _AddDietDialogState extends State<AddDietDialog> {
  final _foodController = TextEditingController();
  final _quantityController = TextEditingController();
  final _caloriesController = TextEditingController(text: '1');

  String _unit = 'g';
  bool _eaten = false;
  bool _saving = false;
  bool _caloriesManuallyEdited = false;

  @override
  void dispose() {
    _foodController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _applySuggestedCalories() {
    if (_caloriesManuallyEdited) return;

    final suggestion = _defaultCaloriesFor(
      _foodController.text,
      _unit,
    );

    _caloriesController.text = _formatKcal(suggestion);
  }

  double get _caloriesValue =>
      double.tryParse(_caloriesController.text.trim()) ?? 1;

  double get _calculatedCalories {
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;

    if (quantity <= 0) return 0;

    return _calculateCalories(
      quantity: quantity,
      unit: _unit,
      caloriesValue: _caloriesValue,
    );
  }

  Future<void> _save() async {
    final food = _foodController.text.trim();
    final quantity = double.tryParse(_quantityController.text.trim());
    final plannedCalories = _calculatedCalories;

    if (food.isEmpty || quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter food and a valid planned quantity'),
        ),
      );
      return;
    }

    if (plannedCalories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid calorie value')),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    await widget.database.saveDietEntry(
      userId: 'user1',
      date: widget.date,
      meal: widget.meal,
      foodName: food,
      plannedQuantity: quantity,
      quantityUnit: _unit,
      plannedCalories: plannedCalories,
      actualQuantity: _eaten ? quantity : 0,
      actualCalories: _eaten ? plannedCalories : 0,
      eaten: _eaten,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final calculatedCalories = _calculatedCalories;

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1D24),
      title: Text('Add ${widget.meal} Food'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _foodController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Food name',
                hintText: 'Example: Rice',
              ),
              onChanged: (_) {
                setState(_applySuggestedCalories);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _quantityController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Planned quantity',
                      hintText: _unitExample(_unit),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unit,
                    decoration: const InputDecoration(labelText: 'Unit'),
                    items: const [
                      DropdownMenuItem(value: 'g', child: Text('g')),
                      DropdownMenuItem(value: 'ml', child: Text('ml')),
                      DropdownMenuItem(value: 'piece', child: Text('piece')),
                      DropdownMenuItem(value: 'slice', child: Text('slice')),
                      DropdownMenuItem(value: 'serving', child: Text('serving')),
                      DropdownMenuItem(value: 'scoop', child: Text('scoop')),
                      DropdownMenuItem(value: 'cup', child: Text('cup')),
                    ],
                    onChanged: _saving
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _unit = value;
                              _applySuggestedCalories();
                            });
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: _calorieFieldLabel(_unit),
                hintText: 'Unknown food → 1',
                suffixText: 'kcal',
              ),
              onChanged: (_) {
                _caloriesManuallyEdited = true;
                setState(() {});
              },
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Calculated planned calories: ${_formatKcal(calculatedCalories)} kcal',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'For g/ml, calories are entered per 100 g/ml. For the other units, calories are entered per unit.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Already eaten'),
              value: _eaten,
              onChanged: (value) {
                setState(() {
                  _eaten = value ?? false;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

// =================================================================
// EDIT DIET DIALOG
// =================================================================

class EditDietDialog extends StatefulWidget {
  final DietEntry entry;
  final AppDatabase database;

  const EditDietDialog({
    super.key,
    required this.entry,
    required this.database,
  });

  @override
  State<EditDietDialog> createState() => _EditDietDialogState();
}

class _EditDietDialogState extends State<EditDietDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _caloriesController;
  late bool _eaten;
  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _quantityController = TextEditingController(
      text: widget.entry.actualQuantity == 0
          ? ''
          : widget.entry.actualQuantity.toString(),
    );

    _caloriesController = TextEditingController(
      text: widget.entry.actualCalories == 0
          ? ''
          : widget.entry.actualCalories.toString(),
    );

    _eaten = widget.entry.eaten;
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final quantityText = _quantityController.text.trim();
    final caloriesText = _caloriesController.text.trim();

    final quantity = quantityText.isEmpty ? 0.0 : double.tryParse(quantityText);
    final calories = caloriesText.isEmpty ? 0.0 : double.tryParse(caloriesText);

    if (quantity == null || calories == null || quantity < 0 || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid actual quantity and calories'),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    await widget.database.updateDietEntry(
      id: widget.entry.id,
      actualQuantity: quantity,
      actualCalories: calories,
      eaten: _eaten,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1D24),
      title: Text('Edit ${widget.entry.foodName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Planned: ${widget.entry.quantityUnit}',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Actual quantity',
                hintText: 'Example: 2',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Actual calories',
                hintText: 'Enter calories actually consumed',
              ),
            ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Eaten'),
              value: _eaten,
              onChanged: (value) {
                setState(() {
                  _eaten = value ?? false;
                });
              },
            ),
            const SizedBox(height: 4),
            const Text(
              'You can edit this later even if the meal was eaten hours later.',
              style: TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

// =================================================================
// FOOD LIBRARY PICKER
// =================================================================

class FoodLibraryPickerResult {
  final FoodLibraryData? food;
  final bool createManually;

  const FoodLibraryPickerResult._({
    this.food,
    this.createManually = false,
  });

  const FoodLibraryPickerResult.food(FoodLibraryData value)
      : this._(food: value);

  const FoodLibraryPickerResult.manual()
      : this._(createManually: true);
}

class FoodLibraryPickerDialog extends StatefulWidget {
  final AppDatabase database;
  final String meal;

  const FoodLibraryPickerDialog({
    super.key,
    required this.database,
    required this.meal,
  });

  @override
  State<FoodLibraryPickerDialog> createState() =>
      _FoodLibraryPickerDialogState();
}

class _FoodLibraryPickerDialogState extends State<FoodLibraryPickerDialog> {
  List<FoodLibraryData> _foods = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final foods = await widget.database.getFoodLibrary(userId: 'user1');

    if (!mounted) return;

    setState(() {
      _foods = foods;
      _loading = false;
    });
  }

  Future<void> _createNewFood() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AddFoodLibraryDialog(
        database: widget.database,
        initialMeal: widget.meal,
      ),
    );

    if (result == true) {
      await _loadFoods();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1D24),
      title: Text('Add ${widget.meal} Food'),
      content: SizedBox(
        width: double.maxFinite,
        child: _loading
            ? const SizedBox(
                height: 120,
                child: Center(child: CircularProgressIndicator()),
              )
            : _foods.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Text(
                      'No saved foods yet.',
                      style: TextStyle(color: Colors.white54),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: _foods.length,
                    separatorBuilder: (_, _) =>
                        const Divider(color: Colors.white12),
                    itemBuilder: (context, index) {
                      final food = _foods[index];

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const CircleAvatar(
                          backgroundColor: Colors.white10,
                          child: Icon(Icons.restaurant, color: Colors.cyan),
                        ),
                        title: Text(
                          food.foodName,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${food.quantity} ${food.quantityUnit} • '
                          '${food.calories.toStringAsFixed(0)} kcal',
                          style: const TextStyle(color: Colors.white54),
                        ),
                        trailing: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.cyan,
                        ),
                        onTap: () => Navigator.pop(
                          context,
                          FoodLibraryPickerResult.food(food),
                        ),
                      );
                    },
                  ),
      ),
      actions: [
        TextButton.icon(
          onPressed: _createNewFood,
          icon: const Icon(Icons.add),
          label: const Text('Create New Food'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        if (_foods.isNotEmpty)
          FilledButton.tonal(
            onPressed: () => Navigator.pop(
              context,
              const FoodLibraryPickerResult.manual(),
            ),
            child: const Text('Add Manually'),
          ),
      ],
    );
  }
}

// =================================================================
// EXTRA CALORIES DIALOG
// =================================================================

class AddFoodLibraryDialog extends StatefulWidget {
  final AppDatabase database;
  final String? initialMeal;

  const AddFoodLibraryDialog({
    super.key,
    required this.database,
    this.initialMeal,
  });

  @override
  State<AddFoodLibraryDialog> createState() => _AddFoodLibraryDialogState();
}

class _AddFoodLibraryDialogState extends State<AddFoodLibraryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _foodController = TextEditingController();
  final _quantityController = TextEditingController();
  final _caloriesController = TextEditingController(text: '1');

  String _meal = 'Breakfast';
  String _unit = 'g';
  bool _saving = false;
  bool _caloriesManuallyEdited = false;

  @override
  void initState() {
    super.initState();
    _meal = widget.initialMeal ?? 'Breakfast';
  }

  @override
  void dispose() {
    _foodController.dispose();
    _quantityController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _applySuggestedCalories() {
    if (_caloriesManuallyEdited) return;

    final suggestion = _defaultCaloriesFor(
      _foodController.text,
      _unit,
    );

    _caloriesController.text = _formatKcal(suggestion);
  }

  double get _caloriesValue =>
      double.tryParse(_caloriesController.text.trim()) ?? 1;

  double get _calculatedCalories {
    final quantity = double.tryParse(_quantityController.text.trim()) ?? 0;

    if (quantity <= 0) return 0;

    return _calculateCalories(
      quantity: quantity,
      unit: _unit,
      caloriesValue: _caloriesValue,
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await widget.database.saveFoodLibraryItem(
        userId: 'user1',
        foodName: _foodController.text.trim(),
        defaultMeal: _meal,
        quantity: double.parse(_quantityController.text.trim()),
        quantityUnit: _unit,
        calories: _calculatedCalories,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save food: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final calculatedCalories = _calculatedCalories;

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1D24),
      title: const Text('Add Food'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _foodController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Food name',
                  hintText: 'Example: Rice',
                ),
                onChanged: (_) {
                  setState(_applySuggestedCalories);
                },
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Enter food name'
                        : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _meal,
                decoration: const InputDecoration(labelText: 'Default meal'),
                items: const [
                  DropdownMenuItem(value: 'Breakfast', child: Text('Breakfast')),
                  DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                  DropdownMenuItem(value: 'Evening', child: Text('Evening')),
                  DropdownMenuItem(value: 'Dinner', child: Text('Dinner')),
                ],
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) setState(() => _meal = value);
                      },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: _unitExample(_unit),
                      ),
                      onChanged: (_) => setState(() {}),
                      validator: (value) {
                        final quantity = double.tryParse(
                          value?.trim() ?? '',
                        );
                        return quantity == null || quantity <= 0
                            ? 'Invalid'
                            : null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _unit,
                      decoration: const InputDecoration(labelText: 'Unit'),
                      items: const [
                        DropdownMenuItem(value: 'g', child: Text('g')),
                        DropdownMenuItem(value: 'ml', child: Text('ml')),
                        DropdownMenuItem(value: 'piece', child: Text('piece')),
                        DropdownMenuItem(value: 'slice', child: Text('slice')),
                        DropdownMenuItem(value: 'serving', child: Text('serving')),
                        DropdownMenuItem(value: 'scoop', child: Text('scoop')),
                        DropdownMenuItem(value: 'cup', child: Text('cup')),
                      ],
                      onChanged: _saving
                          ? null
                          : (value) {
                              if (value != null) {
                                setState(() {
                                  _unit = value;
                                  _applySuggestedCalories();
                                });
                              }
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _caloriesController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: _calorieFieldLabel(_unit),
                  hintText: 'Unknown food → 1',
                  suffixText: 'kcal',
                ),
                onChanged: (_) {
                  _caloriesManuallyEdited = true;
                  setState(() {});
                },
                validator: (value) {
                  final calories = double.tryParse(value?.trim() ?? '');
                  return calories == null || calories <= 0 ? 'Invalid' : null;
                },
              ),
              const SizedBox(height: 10),
              Text(
                'Calculated calories: ${_formatKcal(calculatedCalories)} kcal',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'For g/ml, calories are per 100 g/ml. For other units, calories are per unit.',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

class AddExtraCaloriesDialog extends StatefulWidget {
  final AppDatabase database;
  final DateTime date;

  const AddExtraCaloriesDialog({
    super.key,
    required this.database,
    required this.date,
  });

  @override
  State<AddExtraCaloriesDialog> createState() => _AddExtraCaloriesDialogState();
}

class _AddExtraCaloriesDialogState extends State<AddExtraCaloriesDialog> {
  final _caloriesController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _caloriesController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final calories = double.tryParse(_caloriesController.text.trim());

    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter valid calories')));
      return;
    }

    setState(() {
      _saving = true;
    });

    await widget.database.saveExtraCalories(
      userId: 'user1',
      date: widget.date,
      calories: calories,
      description: _descriptionController.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1D24),
      title: const Text('Add Extra Calories'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _caloriesController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Calories',
              hintText: 'Example: 200',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Example: Chocolate',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
