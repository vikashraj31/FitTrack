import 'package:flutter/material.dart';

import '../../services/database_service.dart';

class WeeklyDietScreen extends StatefulWidget {
  const WeeklyDietScreen({super.key});

  @override
  State<WeeklyDietScreen> createState() => _WeeklyDietScreenState();
}

class _WeeklyDietScreenState extends State<WeeklyDietScreen> {
  final AppDatabase _database = AppDatabase();

  int _selectedDay = DateTime.monday;

  WeeklyDietPlan? _selectedPlan;
  List<WeeklyDietItem> _items = [];

  bool _loading = true;

  static const List<String> _dayNames = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _loadSelectedDay();
  }

  @override
  void dispose() {
    _database.close();
    super.dispose();
  }

  Future<void> _loadSelectedDay() async {
    setState(() {
      _loading = true;
    });

    final plan = await _database.getWeeklyDietPlan(
      userId: 'user1',
      dayOfWeek: _selectedDay,
    );

    List<WeeklyDietItem> items = [];

    if (plan != null) {
      items = await _database.getWeeklyDietItems(planId: plan.id);
    }

    if (!mounted) return;

    setState(() {
      _selectedPlan = plan;
      _items = items;
      _loading = false;
    });
  }

  String get _selectedDayName => _dayNames[_selectedDay - 1];

  double get _totalCalories {
    return _items.fold(0, (sum, item) => sum + item.calories);
  }

  double get _totalProtein {
    return _items.fold(0, (sum, item) => sum + item.protein);
  }

  Future<void> _showPlanDialog() async {
    final calorieController = TextEditingController(
      text: _selectedPlan?.targetCalories.toStringAsFixed(0) ?? '',
    );

    final proteinController = TextEditingController(
      text: _selectedPlan?.targetProtein.toStringAsFixed(0) ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$_selectedDayName Target'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: calorieController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Calories (kcal)',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: proteinController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Protein (g)',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final calories =
                    double.tryParse(calorieController.text.trim()) ?? 0;

                final protein =
                    double.tryParse(proteinController.text.trim()) ?? 0;

                if (calories <= 0) return;

                await _database.saveWeeklyDietPlan(
                  userId: 'user1',
                  dayOfWeek: _selectedDay,
                  targetCalories: calories,
                  targetProtein: protein,
                );

                if (context.mounted) {
                  Navigator.pop(context, true);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    calorieController.dispose();
    proteinController.dispose();

    if (result == true) {
      await _loadSelectedDay();
    }
  }

  Future<void> _showAddFoodDialog() async {
    if (_selectedPlan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Set the day target first.')),
      );
      return;
    }

    final foodController = TextEditingController();
    final quantityController = TextEditingController();
    final caloriesController = TextEditingController();
    final proteinController = TextEditingController();

    String meal = 'Breakfast';
    String unit = 'g';

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Add Food'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: meal,
                      decoration: const InputDecoration(labelText: 'Meal'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Breakfast',
                          child: Text('Breakfast'),
                        ),
                        DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                        DropdownMenuItem(
                          value: 'Evening',
                          child: Text('Evening'),
                        ),
                        DropdownMenuItem(
                          value: 'Dinner',
                          child: Text('Dinner'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            meal = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: foodController,
                      decoration: const InputDecoration(
                        labelText: 'Food Name',
                        hintText: 'Rice',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                              hintText: '200',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: unit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'g', child: Text('g')),
                              DropdownMenuItem(value: 'ml', child: Text('ml')),
                              DropdownMenuItem(
                                value: 'pcs',
                                child: Text('pcs'),
                              ),
                              DropdownMenuItem(
                                value: 'serving',
                                child: Text('serving'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  unit = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Calories (kcal)',
                        hintText: '260',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: proteinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Protein (g)',
                        hintText: '5',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final foodName = foodController.text.trim();
                    final quantity =
                        double.tryParse(quantityController.text.trim()) ?? 0;
                    final calories =
                        double.tryParse(caloriesController.text.trim()) ?? 0;
                    final protein =
                        double.tryParse(proteinController.text.trim()) ?? 0;

                    if (foodName.isEmpty || quantity <= 0 || calories < 0) {
                      return;
                    }

                    await _database.saveWeeklyDietItem(
                      planId: _selectedPlan!.id,
                      meal: meal,
                      foodName: foodName,
                      quantity: quantity,
                      quantityUnit: unit,
                      calories: calories,
                      protein: protein,
                    );

                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );

    foodController.dispose();
    quantityController.dispose();
    caloriesController.dispose();
    proteinController.dispose();

    if (result == true) {
      await _loadSelectedDay();
    }
  }

  Future<void> _showEditFoodDialog(WeeklyDietItem item) async {
    final foodController = TextEditingController(text: item.foodName);
    final quantityController = TextEditingController(
      text: item.quantity.toString(),
    );
    final caloriesController = TextEditingController(
      text: item.calories.toString(),
    );
    final proteinController = TextEditingController(
      text: item.protein.toString(),
    );

    String meal = item.meal;
    String unit = item.quantityUnit;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Edit Food'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: meal,
                      decoration: const InputDecoration(labelText: 'Meal'),
                      items: const [
                        DropdownMenuItem(
                          value: 'Breakfast',
                          child: Text('Breakfast'),
                        ),
                        DropdownMenuItem(value: 'Lunch', child: Text('Lunch')),
                        DropdownMenuItem(
                          value: 'Evening',
                          child: Text('Evening'),
                        ),
                        DropdownMenuItem(
                          value: 'Dinner',
                          child: Text('Dinner'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            meal = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: foodController,
                      decoration: const InputDecoration(labelText: 'Food Name'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: quantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: unit,
                            decoration: const InputDecoration(
                              labelText: 'Unit',
                            ),
                            items: const [
                              DropdownMenuItem(value: 'g', child: Text('g')),
                              DropdownMenuItem(value: 'ml', child: Text('ml')),
                              DropdownMenuItem(
                                value: 'pcs',
                                child: Text('pcs'),
                              ),
                              DropdownMenuItem(
                                value: 'serving',
                                child: Text('serving'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setDialogState(() {
                                  unit = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Calories (kcal)',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: proteinController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Protein (g)',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final foodName = foodController.text.trim();
                    final quantity =
                        double.tryParse(quantityController.text.trim()) ?? 0;
                    final calories =
                        double.tryParse(caloriesController.text.trim()) ?? 0;
                    final protein =
                        double.tryParse(proteinController.text.trim()) ?? 0;

                    if (foodName.isEmpty ||
                        quantity <= 0 ||
                        calories < 0 ||
                        protein < 0) {
                      return;
                    }

                    await _database.updateWeeklyDietItem(
                      id: item.id,
                      meal: meal,
                      foodName: foodName,
                      quantity: quantity,
                      quantityUnit: unit,
                      calories: calories,
                      protein: protein,
                    );

                    if (context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    foodController.dispose();
    quantityController.dispose();
    caloriesController.dispose();
    proteinController.dispose();

    if (result == true) {
      await _loadSelectedDay();
    }
  }

  Future<void> _deleteFood(WeeklyDietItem item) async {
    await _database.deleteWeeklyDietItem(id: item.id);
    await _loadSelectedDay();
  }

  Future<void> _deleteDayPlan() async {
    if (_selectedPlan == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete $_selectedDayName plan?'),
          content: const Text(
            'This will delete the target and all foods saved for this day.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _database.deleteWeeklyDietPlan(id: _selectedPlan!.id);

    await _loadSelectedDay();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weekly Diet')),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // --------------------------------------------------
            // DAYS
            // --------------------------------------------------
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: 7,
                itemBuilder: (context, index) {
                  final day = index + 1;
                  final selected = day == _selectedDay;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(_dayNames[index]),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          _selectedDay = day;
                        });
                        _loadSelectedDay();
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _loadSelectedDay,
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        children: [
                          // ------------------------------------------------
                          // TARGET
                          // ------------------------------------------------

                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _selectedDayName,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: _showPlanDialog,
                                        icon: const Icon(Icons.edit),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _selectedPlan == null
                                        ? 'No target set'
                                        : '${_selectedPlan!.targetCalories.toStringAsFixed(0)} kcal • '
                                              '${_selectedPlan!.targetProtein.toStringAsFixed(0)} g protein',
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Foods: ${_items.length} • '
                                    '${_totalCalories.toStringAsFixed(0)} kcal • '
                                    '${_totalProtein.toStringAsFixed(0)} g protein',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ------------------------------------------------
                          // FOOD LIST
                          // ------------------------------------------------
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Foods',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _showAddFoodDialog,
                                icon: const Icon(Icons.add),
                                label: const Text('Add Food'),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          if (_items.isEmpty)
                            const Card(
                              child: Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: Text('No foods added for this day.'),
                                ),
                              ),
                            )
                          else
                            ..._items.map(
                              (item) => Card(
                                child: ListTile(
                                  title: Text(item.foodName),
                                  subtitle: Text(
                                    '${item.meal} • '
                                    '${item.quantity.toStringAsFixed(0)} '
                                    '${item.quantityUnit} • '
                                    '${item.protein.toStringAsFixed(0)} g protein',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${item.calories.toStringAsFixed(0)} kcal',
                                      ),
                                      IconButton(
                                        onPressed: () =>
                                            _showEditFoodDialog(item),
                                        icon: const Icon(Icons.edit_outlined),
                                      ),
                                      IconButton(
                                        onPressed: () => _deleteFood(item),
                                        icon: const Icon(Icons.delete_outline),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          if (_selectedPlan != null) ...[
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: _deleteDayPlan,
                              icon: const Icon(Icons.delete_outline),
                              label: Text('Delete $_selectedDayName Plan'),
                            ),
                          ],
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
