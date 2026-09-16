import 'package:flutter/material.dart';

import '../../services/database_service.dart';

class DietScreen extends StatefulWidget {
  const DietScreen({super.key});

  @override
  State<DietScreen> createState() => _DietScreenState();
}

class _DietScreenState extends State<DietScreen> {
  final AppDatabase _database = AppDatabase();

  DateTime _selectedDate = DateTime.now();

  List<DietEntry> _entries = [];
  List<ExtraCaloriesEntry> _extraCalories = [];

  bool _loading = true;

  final List<String> _meals = ['Breakfast', 'Lunch', 'Evening', 'Dinner'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ==========================================================
  // LOAD DATA
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
      _entries = entries;
      _extraCalories = extra;
      _loading = false;
    });
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
  // ADD DIET ENTRY
  // ==========================================================

  Future<void> _addDietEntry(String meal) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) =>
          AddDietDialog(meal: meal, database: _database, date: _selectedDate),
    );

    if (result == true) {
      await _loadData();
    }
  }

  // ==========================================================
  // EDIT DIET ENTRY
  // ==========================================================

  Future<void> _editDietEntry(DietEntry entry) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => EditDietDialog(entry: entry, database: _database),
    );

    if (result == true) {
      await _loadData();
    }
  }

  // ==========================================================
  // DELETE DIET ENTRY
  // ==========================================================

  Future<void> _deleteDietEntry(DietEntry entry) async {
    await _database.deleteDietEntry(entry.id);
    await _loadData();
  }

  // ==========================================================
  // TOGGLE EATEN
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
    await _database.deleteExtraCalories(entry.id);
    await _loadData();
  }

  // ==========================================================
  // CALCULATIONS
  // ==========================================================

  double get _plannedCalories {
    double total = 0;

    for (final entry in _entries) {
      total += entry.plannedCalories;
    }

    return total;
  }

  double get _actualCalories {
    double total = 0;

    for (final entry in _entries) {
      total += entry.actualCalories;
    }

    for (final entry in _extraCalories) {
      total += entry.calories;
    }

    return total;
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
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,

              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),

                children: [
                  // ==================================================
                  // DATE
                  // ==================================================
                  _buildDateCard(),

                  const SizedBox(height: 16),

                  // ==================================================
                  // CALORIE SUMMARY
                  // ==================================================
                  _buildCaloriesSummary(),

                  const SizedBox(height: 24),

                  // ==================================================
                  // MEALS
                  // ==================================================
                  ..._meals.map((meal) => _buildMealSection(meal)),

                  const SizedBox(height: 12),

                  // ==================================================
                  // EXTRA CALORIES
                  // ==================================================
                  _buildExtraCalories(),

                  const SizedBox(height: 20),

                  // ==================================================
                  // FINAL TOTAL
                  // ==================================================
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
            const Icon(Icons.calendar_today, color: Colors.cyan),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected Date',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _formatDate(_selectedDate),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
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

  // ==========================================================
  // CALORIE SUMMARY
  // ==========================================================

  Widget _buildCaloriesSummary() {
    final planned = _plannedCalories;
    final actual = _actualCalories;

    final percentage = planned > 0 ? (actual / planned) * 100 : 0;

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
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),

          const SizedBox(height: 10),

          Row(
            crossAxisAlignment: CrossAxisAlignment.end,

            children: [
              Text(
                '$actual.toStringAsFixed(0)',
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
            'Planned: ${planned.toStringAsFixed(0)} kcal',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),

          const SizedBox(height: 14),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: LinearProgressIndicator(
              value: planned > 0 ? (actual / planned).clamp(0.0, 1.0) : 0,

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

    return Container(
      margin: const EdgeInsets.only(bottom: 16),

      decoration: BoxDecoration(
        color: const Color(0xFF1A1D24),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

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
                  onPressed: () {
                    _addDietEntry(meal);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),

            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 8, bottom: 4),
                child: Text(
                  'No food added',
                  style: TextStyle(color: Colors.white38),
                ),
              ),

            ...entries.map((entry) {
              return _buildFoodItem(entry);
            }),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FOOD ITEM
  // ==========================================================

  Widget _buildFoodItem(DietEntry entry) {
    return Dismissible(
      key: ValueKey(entry.id),

      direction: DismissDirection.endToStart,

      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete food?'),
              content: Text('Delete ${entry.foodName}?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        );
      },

      onDismissed: (_) {
        _deleteDietEntry(entry);
      },

      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),

      child: InkWell(
        onTap: () {
          _editDietEntry(entry);
        },

        child: Container(
          margin: const EdgeInsets.only(bottom: 10),

          padding: const EdgeInsets.all(12),

          decoration: BoxDecoration(
            color: const Color(0xFF22252D),
            borderRadius: BorderRadius.circular(12),
          ),

          child: Row(
            children: [
              Checkbox(
                value: entry.eaten,
                activeColor: Colors.cyan,

                onChanged: (_) {
                  _toggleEaten(entry);
                },
              ),

              const SizedBox(width: 4),

              Expanded(
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
                      'Planned: ${_formatQuantity(entry.plannedQuantity)} ${entry.quantityUnit} • ${entry.plannedCalories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),

                    if (entry.eaten)
                      Text(
                        'Actual: ${_formatQuantity(entry.actualQuantity)} ${entry.quantityUnit} • ${entry.actualCalories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                          color: Colors.cyan,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),

              const Icon(Icons.edit_outlined, size: 18, color: Colors.white38),
            ],
          ),
        ),
      ),
    );
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

          ..._extraCalories.map((entry) {
            return ListTile(
              contentPadding: EdgeInsets.zero,

              title: Text(
                entry.description.isEmpty
                    ? 'Extra calories'
                    : entry.description,
              ),

              subtitle: Text('${entry.calories.toStringAsFixed(0)} kcal'),

              trailing: IconButton(
                onPressed: () {
                  _deleteExtraCalories(entry);
                },
                icon: const Icon(Icons.delete_outline, color: Colors.white54),
              ),
            );
          }),

          if (_extraCalories.isNotEmpty) const Divider(color: Colors.white12),

          if (_extraCalories.isNotEmpty)
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
      ),
    );
  }

  // ==========================================================
  // FINAL TOTAL
  // ==========================================================

  Widget _buildFinalTotal() {
    final planned = _plannedCalories;
    final actual = _actualCalories;

    final difference = actual - planned;

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
                  'Planned',
                  '${planned.toStringAsFixed(0)} kcal',
                ),
              ),

              Expanded(
                child: _totalItem(
                  'Actual',
                  '${actual.toStringAsFixed(0)} kcal',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            difference >= 0
                ? '${difference.toStringAsFixed(0)} kcal above planned'
                : '${difference.abs().toStringAsFixed(0)} kcal remaining',
            style: TextStyle(
              color: difference > 0 ? Colors.orange : Colors.white54,
              fontSize: 13,
            ),
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

    final quantity = double.tryParse(_quantityController.text.trim());

    final calories = double.tryParse(_caloriesController.text.trim());

    final unit = _unitController.text.trim();

    if (food.isEmpty || quantity == null || calories == null || unit.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));

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
      quantityUnit: unit,
      plannedCalories: calories,
      actualQuantity: _eaten ? quantity : 0,
      actualCalories: _eaten ? calories : 0,
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
                hintText: 'Example: 2',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _unitController,
              decoration: const InputDecoration(
                labelText: 'Unit',
                hintText: 'Example: pieces / g / ml',
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Planned calories',
                hintText: 'Example: 140',
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
              : () {
                  Navigator.pop(context);
                },
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
      text: widget.entry.actualQuantity.toString(),
    );

    _caloriesController = TextEditingController(
      text: widget.entry.actualCalories.toString(),
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
    final quantity = double.tryParse(_quantityController.text.trim());

    final calories = double.tryParse(_caloriesController.text.trim());

    if (quantity == null || calories == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter valid quantity and calories')),
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
              'Planned: ${widget.entry.plannedQuantity} ${widget.entry.quantityUnit} • ${widget.entry.plannedCalories.toStringAsFixed(0)} kcal',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Actual quantity'),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _caloriesController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(labelText: 'Actual calories'),
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
          ],
        ),
      ),

      actions: [
        TextButton(
          onPressed: _saving
              ? null
              : () {
                  Navigator.pop(context);
                },
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
// EXTRA CALORIES DIALOG
// =================================================================

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
          onPressed: _saving
              ? null
              : () {
                  Navigator.pop(context);
                },
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
