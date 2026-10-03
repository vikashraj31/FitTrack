import 'package:flutter/material.dart';

import '../../services/database_service.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final AppDatabase _database = AppDatabase();
  final ScrollController _dietScrollController = ScrollController();

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

  String get _dayName {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return days[_selectedDate.weekday - 1];
  }

  Future<void> _loadData() async {
    await _refreshData(showLoader: true);
  }

  Future<void> _refreshData({bool showLoader = false}) async {
    if (showLoader && mounted) {
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
      _entries = entries;
      _extraCalories = extra;
      _loading = false;
    });
  }

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

    await _refreshData();
  }

  Future<void> _editDietEntry(DietEntry entry) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF1A1D24),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  entry.foodName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.today, color: Colors.cyan),
                  ),
                  title: const Text('Edit for Today'),
                  subtitle: const Text(
                    "Change only today's actual quantity and calories",
                  ),
                  onTap: () => Navigator.pop(sheetContext, 'today'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: Colors.white10,
                    child: Icon(Icons.calendar_month, color: Colors.cyan),
                  ),
                  title: const Text('Edit for Diet'),
                  subtitle: const Text(
                    'Change the planned quantity and calories for the diet',
                  ),
                  onTap: () => Navigator.pop(sheetContext, 'diet'),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || choice == null) return;

    bool? result;

    if (choice == 'today') {
      result = await showDialog<bool>(
        context: context,
        builder: (_) => EditDietTodayDialog(
          entry: entry,
          database: _database,
        ),
      );
    } else {
      result = await showDialog<bool>(
        context: context,
        builder: (_) => EditDietPlanDialog(
          entry: entry,
          database: _database,
          dayOfWeek: _selectedDate.weekday,
        ),
      );
    }

    if (result == true) {
      await _refreshData();
    }
  }

  Future<void> _deleteDietEntry(DietEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1D24),
        title: const Text('Delete food?'),
        content: Text(
          'Delete ${entry.foodName} from ${entry.meal}?',
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

    await _database.deleteDietEntry(entry.id);
    await _refreshData();
  }

  Future<void> _addCustomFood(String meal) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AddDietDialog(
        meal: meal,
        database: _database,
        date: _selectedDate,
      ),
    );

    if (result == true) {
      await _refreshData();
    }
  }

  Future<void> _addExtraCalories() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AddExtraCaloriesDialog(
        database: _database,
        date: _selectedDate,
      ),
    );

    if (result == true) {
      await _refreshData();
    }
  }

  Future<void> _deleteExtraCalories(
    ExtraCaloriesEntry entry,
  ) async {
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
    await _refreshData();
  }

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

  Widget _buildMealSection(String meal) {
    final entries = _entries
        .where((entry) => entry.meal == meal)
        .toList();

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
            if (entries.isEmpty)
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
                    if (!entry.eaten)
                      Text(
                        'Planned: ${_formatQuantity(entry.plannedQuantity)} '
                        '${entry.quantityUnit} • '
                        '${entry.plannedCalories.toStringAsFixed(0)} kcal',
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
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
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
              subtitle: Text(
                '${entry.calories.toStringAsFixed(0)} kcal',
              ),
              trailing: IconButton(
                onPressed: () => _deleteExtraCalories(entry),
                icon: const Icon(
                  Icons.delete_outline,
                  color: Colors.white54,
                ),
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  double get _plannedCalories {
    double total = 0;

    for (final entry in _entries) {
      total += entry.plannedCalories;
    }

    return total;
  }

  double get _caloriePercentage {
    if (_plannedCalories <= 0) return 0;
    return (_actualCalories / _plannedCalories) * 100;
  }

  Widget _buildCaloriesSummary() {
    final planned = _plannedCalories;
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
            'Calories',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                planned.toStringAsFixed(0),
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 6),
              const Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Text(
                  'kcal target',
                  style: TextStyle(color: Colors.white54),
                ),
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
            'Eaten: ${actual.toStringAsFixed(0)} kcal',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 12),
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

  Widget _buildDateCard() {
    return InkWell(
      onTap: _selectDate,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1D24),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today,
              color: Colors.cyan,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Date',
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_dayName • ${_formatDate(_selectedDate)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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

  Widget _buildFinalTotal() {
    final planned = _plannedCalories;
    final actual = _actualCalories;
    final remaining = planned - actual;

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
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _totalValue(
                  'Target',
                  '${planned.toStringAsFixed(0)} kcal',
                ),
              ),
              Expanded(
                child: _totalValue(
                  'Eaten',
                  '${actual.toStringAsFixed(0)} kcal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            remaining >= 0
                ? '${remaining.toStringAsFixed(0)} kcal remaining'
                : '${remaining.abs().toStringAsFixed(0)} kcal over target',
            style: TextStyle(
              color: remaining >= 0 ? Colors.white54 : Colors.orange,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _totalValue(String title, String value) {
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1115),
        elevation: 0,
        title: const Text(
          'Diet',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: _selectDate,
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: _refreshData,
              child: ListView(
                controller: _dietScrollController,
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  30,
                ),
                children: [
                  _buildDateCard(),
                  const SizedBox(height: 16),
                  _buildCaloriesSummary(),
                  const SizedBox(height: 24),
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

  @override
  void dispose() {
    _dietScrollController.dispose();
    _database.close();
    super.dispose();
  }
}

// ================================================================
// ADD DIET DIALOG
// ================================================================

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
  final _unitController = TextEditingController();
  final _caloriesController = TextEditingController();

  bool _eaten = false;
  bool _saving = false;

  @override
  void dispose() {
    _foodController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final food = _foodController.text.trim();

    final quantity = double.tryParse(
      _quantityController.text.trim(),
    );

    final unit = _unitController.text.trim();

    final calories = double.tryParse(
      _caloriesController.text.trim(),
    );

    if (food.isEmpty ||
        quantity == null ||
        quantity <= 0 ||
        unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter food, quantity and unit'),
        ),
      );
      return;
    }

    final plannedCalories = calories ?? 0;

    setState(() {
      _saving = true;
    });

    await widget.database.saveDietEntry(
      userId: 'user1',
      date: widget.date,
      meal: widget.meal,
      foodName: food,
      plannedQuantity: quantity,
      quantityUnit: unit,
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
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1D24),
      title: Text('Add ${widget.meal} Food'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _foodController,
              decoration: const InputDecoration(
                labelText: 'Food name',
                hintText: 'Example: Eggs',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Planned quantity',
                hintText: 'Example: 6',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Quantity / serving',
                hintText: 'Example: eggs / slices / g / serving',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Planned calories (optional)',
                hintText: 'Leave blank if unknown',
              ),
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
          onPressed: _saving
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}

// ================================================================
// EDIT FOR TODAY DIALOG
// ================================================================

class EditDietTodayDialog extends StatefulWidget {
  final DietEntry entry;
  final AppDatabase database;

  const EditDietTodayDialog({
    super.key,
    required this.entry,
    required this.database,
  });

  @override
  State<EditDietTodayDialog> createState() => _EditDietTodayDialogState();
}

class _EditDietTodayDialogState extends State<EditDietTodayDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _caloriesController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.entry.actualQuantity.toString(),
    );
    _caloriesController = TextEditingController(
      text: widget.entry.actualCalories.toString(),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final quantity = double.tryParse(_quantityController.text.trim());
    final calories = double.tryParse(_caloriesController.text.trim());

    if (quantity == null || calories == null || quantity < 0 || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid quantity and calories')),
      );
      return;
    }

    setState(() => _saving = true);

    await widget.database.updateDietEntry(
      id: widget.entry.id,
      actualQuantity: quantity,
      actualCalories: calories,
      eaten: widget.entry.eaten,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1D24),
      title: Text('Edit for Today — ${widget.entry.foodName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Planned: ${widget.entry.quantityUnit} • '
                '${widget.entry.plannedCalories.toStringAsFixed(0)} kcal',
                style: const TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Actual quantity (${widget.entry.quantityUnit})',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Actual calories',
                suffixText: 'kcal',
              ),
            ),
            const SizedBox(height: 10),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'The checkbox still controls whether this food counts as eaten today.',
                style: TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
          ],
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

// ================================================================
// EDIT FOR DIET DIALOG
// ================================================================

class EditDietPlanDialog extends StatefulWidget {
  final DietEntry entry;
  final AppDatabase database;
  final int dayOfWeek;

  const EditDietPlanDialog({
    super.key,
    required this.entry,
    required this.database,
    required this.dayOfWeek,
  });

  @override
  State<EditDietPlanDialog> createState() => _EditDietPlanDialogState();
}

class _EditDietPlanDialogState extends State<EditDietPlanDialog> {
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _caloriesController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _quantityController = TextEditingController(
      text: widget.entry.plannedQuantity.toString(),
    );
    _unitController = TextEditingController(
      text: widget.entry.quantityUnit,
    );
    _caloriesController = TextEditingController(
      text: widget.entry.plannedCalories.toString(),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final quantity = double.tryParse(_quantityController.text.trim());
    final unit = _unitController.text.trim();
    final calories = double.tryParse(_caloriesController.text.trim());

    if (quantity == null || quantity <= 0 || unit.isEmpty ||
        calories == null || calories < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid planned values')),
      );
      return;
    }

    setState(() => _saving = true);

    // Update every already-saved daily entry for this meal/food, while
    // keeping each day's actual/eaten values untouched.
    await widget.database.updateDietPlanForFood(
      userId: 'user1',
      meal: widget.entry.meal,
      foodName: widget.entry.foodName,
      plannedQuantity: quantity,
      quantityUnit: unit,
      plannedCalories: calories,
    );

    // Also update the weekly plan item when a weekly plan exists.
    await widget.database.updateWeeklyDietItemForDay(
      userId: 'user1',
      dayOfWeek: widget.dayOfWeek,
      meal: widget.entry.meal,
      foodName: widget.entry.foodName,
      quantity: quantity,
      quantityUnit: unit,
      calories: calories,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1A1D24),
      title: Text('Edit for Diet — ${widget.entry.foodName}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'This changes the planned value, not today\'s eaten record.',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Planned quantity'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _unitController,
              decoration: const InputDecoration(labelText: 'Unit / serving'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Planned calories',
                suffixText: 'kcal',
              ),
            ),
          ],
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

// ================================================================
// EXTRA CALORIES DIALOG
// ================================================================

class AddExtraCaloriesDialog extends StatefulWidget {
  final AppDatabase database;
  final DateTime date;

  const AddExtraCaloriesDialog({
    super.key,
    required this.database,
    required this.date,
  });

  @override
  State<AddExtraCaloriesDialog> createState() =>
      _AddExtraCaloriesDialogState();
}

class _AddExtraCaloriesDialogState
    extends State<AddExtraCaloriesDialog> {
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
    final calories = double.tryParse(
      _caloriesController.text.trim(),
    );

    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid calories'),
        ),
      );
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
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
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
          onPressed: _saving
              ? null
              : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}