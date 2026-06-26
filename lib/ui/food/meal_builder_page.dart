import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../store/auth_store.dart';
import '../../shared/app_snackbar.dart';
import 'barcode_scanner_page.dart';

class MealBuilderPage extends StatefulWidget {
  const MealBuilderPage({super.key});

  @override
  State<MealBuilderPage> createState() => _MealBuilderPageState();
}

class _MealBuilderPageState extends State<MealBuilderPage> {
  final AuthStore _store = AuthStore.instance;
  final List<LocalMealItem> _mealItems = [];
  bool _isSaving = false;

  final List<Map<String, dynamic>> _commonFoods = [
    {
      'barcode': 'common_chappathi',
      'name': 'Chappathi',
      'calories': 260.0,
      'protein': 8.0,
      'carbs': 50.0,
      'fat': 3.0,
      'servingUnit': 'piece(s)',
      'gramsPerServing': 40.0,
    },
    {
      'barcode': 'common_chicken_curry',
      'name': 'Chicken Curry',
      'calories': 150.0,
      'protein': 15.0,
      'carbs': 6.0,
      'fat': 8.0,
      'servingUnit': 'bowl(s)',
      'gramsPerServing': 250.0,
    },
    {
      'barcode': 'common_rice_white',
      'name': 'Cooked White Rice',
      'calories': 130.0,
      'protein': 2.7,
      'carbs': 28.0,
      'fat': 0.3,
      'servingUnit': 'cup(s)',
      'gramsPerServing': 150.0,
    },
    {
      'barcode': 'common_egg_whole',
      'name': 'Whole Egg (Boiled)',
      'calories': 155.0,
      'protein': 13.0,
      'carbs': 1.1,
      'fat': 11.0,
      'servingUnit': 'egg(s)',
      'gramsPerServing': 50.0,
    },
    {
      'barcode': 'common_chicken_breast',
      'name': 'Chicken Breast (Cooked)',
      'calories': 165.0,
      'protein': 31.0,
      'carbs': 0.0,
      'fat': 3.6,
      'servingUnit': 'serving(s)',
      'gramsPerServing': 100.0,
    },
    {
      'barcode': 'common_oats_raw',
      'name': 'Oats (Raw)',
      'calories': 389.0,
      'protein': 16.9,
      'carbs': 66.0,
      'fat': 6.9,
      'servingUnit': 'serving(s)',
      'gramsPerServing': 40.0,
    },
    {
      'barcode': 'common_whey_protein',
      'name': 'Whey Protein',
      'calories': 390.0,
      'protein': 80.0,
      'carbs': 6.0,
      'fat': 5.0,
      'servingUnit': 'scoop(s)',
      'gramsPerServing': 30.0,
    },
    {
      'barcode': 'common_banana',
      'name': 'Banana',
      'calories': 89.0,
      'protein': 1.1,
      'carbs': 23.0,
      'fat': 0.3,
      'servingUnit': 'banana(s)',
      'gramsPerServing': 120.0,
    },
    {
      'barcode': 'common_apple',
      'name': 'Apple',
      'calories': 52.0,
      'protein': 0.3,
      'carbs': 14.0,
      'fat': 0.2,
      'servingUnit': 'apple(s)',
      'gramsPerServing': 150.0,
    },
    {
      'barcode': 'common_whole_milk',
      'name': 'Whole Milk',
      'calories': 61.0,
      'protein': 3.2,
      'carbs': 4.8,
      'fat': 3.3,
      'servingUnit': 'glass(es)',
      'gramsPerServing': 250.0,
    },
    {
      'barcode': 'common_paneer',
      'name': 'Paneer (Cottage Cheese)',
      'calories': 265.0,
      'protein': 18.0,
      'carbs': 1.2,
      'fat': 20.0,
      'servingUnit': 'serving(s)',
      'gramsPerServing': 100.0,
    },
  ];

  void _showSearchAndSelectBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _FoodSearchBottomSheet(
          commonFoods: _commonFoods,
          onFoodSelected: (food, servingUnit, gramsPerServing) {
            _showPortionDialog(food, servingUnit: servingUnit, gramsPerServing: gramsPerServing);
          },
          onScanPressed: () async {
            _scanBarcodeFromSheet();
          },
          onCreateCustomFoodPressed: () {
            _showCustomFoodDialog();
          },
        );
      },
    );
  }

  void _scanBarcodeFromSheet() async {
    final barcode = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const BarcodeScannerPage()),
    );

    if (barcode == null || barcode.trim().isEmpty) return;

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    final food = await _store.lookupFoodByBarcode(barcode.trim());
    if (mounted) Navigator.pop(context);

    if (food != null) {
      _showPortionDialog(food);
    }
  }

  void _showPortionDialog(
    Map<String, dynamic> food, {
    String? servingUnit,
    double? gramsPerServing,
  }) {
    final bool hasServingUnit = servingUnit != null && gramsPerServing != null;
    bool isGramsMode = !hasServingUnit;

    final TextEditingController amountController = TextEditingController(text: isGramsMode ? "100" : "1");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final double amount = double.tryParse(amountController.text.trim()) ?? 0.0;
            final double totalGrams = isGramsMode ? amount : amount * (gramsPerServing ?? 0.0);

            final double cal = ((food['calories'] as num?)?.toDouble() ?? 0.0) * totalGrams / 100.0;
            final double pro = ((food['protein'] as num?)?.toDouble() ?? 0.0) * totalGrams / 100.0;
            final double carb = ((food['carbs'] as num?)?.toDouble() ?? 0.0) * totalGrams / 100.0;
            final double fat = ((food['fat'] as num?)?.toDouble() ?? 0.0) * totalGrams / 100.0;

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'] ?? 'Product Details',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Portion size calculator",
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (hasServingUnit) ...[
                      Row(
                        children: [
                          Expanded(
                            child: ChoiceChip(
                              label: const Center(child: Text("Grams (g)")),
                              selected: isGramsMode,
                              selectedColor: Colors.black,
                              backgroundColor: Colors.grey[100],
                              labelStyle: TextStyle(
                                color: isGramsMode ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (val) {
                                setDialogState(() {
                                  isGramsMode = true;
                                  amountController.text = totalGrams.toInt().toString();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ChoiceChip(
                              label: Center(child: Text(servingUnit)),
                              selected: !isGramsMode,
                              selectedColor: Colors.black,
                              backgroundColor: Colors.grey[100],
                              labelStyle: TextStyle(
                                color: !isGramsMode ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              onSelected: (val) {
                                setDialogState(() {
                                  isGramsMode = false;
                                  amountController.text = (totalGrams / gramsPerServing).toStringAsFixed(1);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                    Text(
                      isGramsMode ? "Enter weight in grams" : "Enter number of $servingUnit",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      onChanged: (val) {
                        setDialogState(() {});
                      },
                      decoration: InputDecoration(
                        suffixText: isGramsMode ? "grams" : servingUnit,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (!isGramsMode) ...[
                      Text(
                        "= ${totalGrams.toInt()}g total weight",
                        style: TextStyle(color: Colors.grey[600], fontSize: 13, fontStyle: FontStyle.italic),
                      ),
                      const SizedBox(height: 12),
                    ],
                    const Divider(height: 24),
                    const Text(
                      "Scaled Macros:",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "${cal.toInt()}",
                                style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                "kcal",
                                style: TextStyle(color: Colors.white70, fontSize: 14),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildMacroMiniPanel("PROTEIN", "${pro.toStringAsFixed(1)}g"),
                              _buildMacroMiniPanel("CARBS", "${carb.toStringAsFixed(1)}g"),
                              _buildMacroMiniPanel("FAT", "${fat.toStringAsFixed(1)}g"),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (totalGrams <= 0) {
                      AppSnackbar.show("Please enter a valid amount");
                      return;
                    }
                    setState(() {
                      _mealItems.add(
                        LocalMealItem(
                          id: food['id'],
                          name: food['name'] ?? 'Product',
                          grams: totalGrams,
                          caloriesPer100g: (food['calories'] as num?)?.toDouble() ?? 0.0,
                          proteinPer100g: (food['protein'] as num?)?.toDouble() ?? 0.0,
                          carbsPer100g: (food['carbs'] as num?)?.toDouble() ?? 0.0,
                          fatPer100g: (food['fat'] as num?)?.toDouble() ?? 0.0,
                        ),
                      );
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  child: const Text("Add to Meal", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCustomFoodDialog() {
    final nameController = TextEditingController();
    final caloriesController = TextEditingController(text: "150");
    final proteinController = TextEditingController(text: "10");
    final carbsController = TextEditingController(text: "15");
    final fatController = TextEditingController(text: "5");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              title: const Text("Create Custom Food", style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: "Food Name (e.g. Protein Bar)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Nutritional Values (per 100g)",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: caloriesController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Calories (kcal)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: proteinController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Protein (g)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: carbsController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Carbohydrates (g)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: fatController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: "Fat (g)",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final cal = double.tryParse(caloriesController.text) ?? 0.0;
                    final pro = double.tryParse(proteinController.text) ?? 0.0;
                    final carb = double.tryParse(carbsController.text) ?? 0.0;
                    final fat = double.tryParse(fatController.text) ?? 0.0;

                    if (name.isEmpty) {
                      AppSnackbar.show("Please enter food name");
                      return;
                    }

                    Navigator.pop(context); // Close inputs dialog

                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator(color: Colors.white)),
                    );

                    final food = await _store.createCustomFood(
                      name: name,
                      calories: cal,
                      protein: pro,
                      carbs: carb,
                      fat: fat,
                    );

                    if (mounted) Navigator.pop(context); // Close loading

                    if (food != null) {
                      _showPortionDialog(food);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Save & Add", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _saveMeal() async {
    if (_mealItems.isEmpty) {
      AppSnackbar.show("Please add at least one food item.");
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final payload = _mealItems.map((e) => {'food_id': e.id, 'grams': e.grams}).toList();
    final success = await _store.logMeal(payload);

    setState(() {
      _isSaving = false;
    });

    if (success && mounted) {
      AppSnackbar.show("Meal logged successfully!");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (var item in _mealItems) {
      totalCalories += (item.caloriesPer100g * item.grams) / 100.0;
      totalProtein += (item.proteinPer100g * item.grams) / 100.0;
      totalCarbs += (item.carbsPer100g * item.grams) / 100.0;
      totalFat += (item.fatPer100g * item.grams) / 100.0;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Meal Builder",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Text("Meal Totals", style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "${totalCalories.toInt()}",
                        style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 4),
                      const Text("kcal", style: TextStyle(color: Colors.white70, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMacroMiniPanel("PROTEIN", "${totalProtein.toStringAsFixed(1)}g"),
                      _buildMacroMiniPanel("CARBS", "${totalCarbs.toStringAsFixed(1)}g"),
                      _buildMacroMiniPanel("FATS", "${totalFat.toStringAsFixed(1)}g"),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),
            Expanded(
              child: _mealItems.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_menu_rounded, size: 64, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          Text(
                            "Tap '+' to add food items to this meal",
                            style: TextStyle(color: Colors.grey[500], fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "e.g. 80g Chappathi + 200g Chicken Curry",
                            style: TextStyle(color: Colors.grey[400], fontSize: 12, fontStyle: FontStyle.italic),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: _mealItems.length,
                      itemBuilder: (context, idx) {
                        final item = _mealItems[idx];
                        final cal = (item.caloriesPer100g * item.grams) / 100.0;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 18,
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      child: Icon(Icons.restaurant, size: 16),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "${item.grams.toInt()}g • ${cal.toInt()} kcal",
                                            style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _mealItems.removeAt(idx);
                                  });
                                },
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: (100 * idx).ms);
                      },
                    ),
            ),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, -4))
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(
                      height: 56.h,
                      margin: const EdgeInsets.only(right: 12),
                      child: OutlinedButton(
                        onPressed: _showSearchAndSelectBottomSheet,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black, width: 1.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                        ),
                        child: const Icon(Icons.add, color: Colors.black),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveMeal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                        ),
                        child: _isSaving
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Log Compound Meal", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroMiniPanel(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class LocalMealItem {
  final String id;
  final String name;
  final double grams;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;

  LocalMealItem({
    required this.id,
    required this.name,
    required this.grams,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
  });
}

class _FoodSearchBottomSheet extends StatefulWidget {
  final List<Map<String, dynamic>> commonFoods;
  final Function(Map<String, dynamic> food, String? servingUnit, double? gramsPerServing) onFoodSelected;
  final VoidCallback onScanPressed;
  final VoidCallback onCreateCustomFoodPressed;

  const _FoodSearchBottomSheet({
    required this.commonFoods,
    required this.onFoodSelected,
    required this.onScanPressed,
    required this.onCreateCustomFoodPressed,
  });

  @override
  State<_FoodSearchBottomSheet> createState() => _FoodSearchBottomSheetState();
}

class _FoodSearchBottomSheetState extends State<_FoodSearchBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  final AuthStore _store = AuthStore.instance;
  String _searchQuery = "";
  bool _isLoadingFood = false;

  // API search integration state
  List<Map<String, dynamic>> _apiResults = [];
  bool _isSearchingApi = false;
  String _lastApiQuery = "";

  static const Map<String, Map<String, dynamic>> _servingInfoMap = {
    'common_chappathi': {'unit': 'piece(s)', 'grams': 40.0},
    'common_wheat_bread': {'unit': 'slice(s)', 'grams': 30.0},
    'common_white_bread': {'unit': 'slice(s)', 'grams': 30.0},
    'common_rice_white': {'unit': 'cup(s)', 'grams': 150.0},
    'common_rice_brown': {'unit': 'cup(s)', 'grams': 150.0},
    'common_rice': {'unit': 'cup(s)', 'grams': 150.0},
    'common_egg_whole': {'unit': 'egg(s)', 'grams': 50.0},
    'common_egg': {'unit': 'egg(s)', 'grams': 50.0},
    'common_egg_white': {'unit': 'egg(s)', 'grams': 33.0},
    'common_banana': {'unit': 'banana(s)', 'grams': 120.0},
    'common_apple': {'unit': 'apple(s)', 'grams': 150.0},
    'common_milk': {'unit': 'glass(es)', 'grams': 250.0},
    'common_whole_milk': {'unit': 'glass(es)', 'grams': 250.0},
    'common_skim_milk': {'unit': 'glass(es)', 'grams': 250.0},
    'common_soy_milk': {'unit': 'glass(es)', 'grams': 250.0},
    'common_almond_milk': {'unit': 'glass(es)', 'grams': 250.0},
    'common_idli': {'unit': 'idli(s)', 'grams': 50.0},
    'common_plain_dosa': {'unit': 'dosa(s)', 'grams': 80.0},
    'common_masala_dosa': {'unit': 'dosa(s)', 'grams': 150.0},
    'common_samosa': {'unit': 'samosa(s)', 'grams': 50.0},
    'common_whey_protein': {'unit': 'scoop(s)', 'grams': 30.0},
    'common_whey': {'unit': 'scoop(s)', 'grams': 30.0},
  };

  void _onSearchChanged(String query) async {
    setState(() {
      _searchQuery = query;
    });

    final queryTrimmed = query.trim();
    if (queryTrimmed.isEmpty) {
      setState(() {
        _apiResults = [];
        _isSearchingApi = false;
      });
      return;
    }

    _lastApiQuery = queryTrimmed;
    setState(() {
      _isSearchingApi = true;
    });

    try {
      final results = await _store.searchFoods(queryTrimmed);
      if (_lastApiQuery == queryTrimmed && mounted) {
        setState(() {
          _apiResults = results;
          _isSearchingApi = false;
        });
      }
    } catch (e) {
      if (_lastApiQuery == queryTrimmed && mounted) {
        setState(() {
          _isSearchingApi = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine which foods to show and deduplicate them
    final List<Map<String, dynamic>> displayedFoods = [];
    if (_searchQuery.isEmpty) {
      displayedFoods.addAll(widget.commonFoods);
    } else {
      // Start with local matches
      final localMatches = widget.commonFoods
          .where((f) => f['name'].toString().toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
      displayedFoods.addAll(localMatches);

      // Add API results that aren't already in the list
      final seenNames = localMatches.map((f) => f['name'].toString().toLowerCase()).toSet();
      final seenBarcodes = localMatches.map((f) => f['barcode']?.toString()).whereType<String>().toSet();

      for (final food in _apiResults) {
        final name = food['name']?.toString().toLowerCase() ?? '';
        final barcode = food['barcode']?.toString();
        
        bool isDuplicate = seenNames.contains(name);
        if (barcode != null && seenBarcodes.contains(barcode)) {
          isDuplicate = true;
        }

        if (!isDuplicate) {
          displayedFoods.add(food);
          if (name.isNotEmpty) seenNames.add(name);
          if (barcode != null) seenBarcodes.add(barcode);
        }
      }
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Add Food to Meal",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TextField(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: "Search food (e.g. Chappathi)",
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    suffixIcon: _isSearchingApi
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Padding(
                              padding: EdgeInsets.all(12.0),
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            ),
                          )
                        : (_searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.black54),
                                onPressed: () {
                                  _searchController.clear();
                                  _onSearchChanged("");
                                },
                              )
                            : null),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onScanPressed,
                        icon: const Icon(Icons.barcode_reader, size: 18),
                        label: const Text("Scan Barcode", style: TextStyle(fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.onCreateCustomFoodPressed,
                        icon: const Icon(Icons.add, size: 18, color: Colors.black),
                        label: const Text("Custom Food", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black, width: 1.5),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _searchQuery.isEmpty ? "Popular Common Foods" : "Search Results",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              displayedFoods.isEmpty && _isSearchingApi
                  ? const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      ),
                    )
                  : Expanded(
                      child: displayedFoods.isEmpty
                          ? Center(
                              child: Text(
                                "No results found for \"$_searchQuery\"",
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              itemCount: displayedFoods.length,
                              itemBuilder: (context, index) {
                                final food = displayedFoods[index];
                                return Card(
                                  elevation: 0,
                                  color: Colors.grey[50],
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(color: Colors.grey[100]!),
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.black12,
                                      child: Text(
                                        (food['name'] ?? 'U').toString().substring(0, 1).toUpperCase(),
                                        style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(
                                      food['name'] ?? 'Unknown',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        "P: ${food['protein']}g  C: ${food['carbs']}g  F: ${food['fat']}g",
                                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                      ),
                                    ),
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${((food['calories'] as num?)?.toDouble() ?? 0.0).toInt()} kcal",
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                                        ),
                                        Text(
                                          "per 100g",
                                          style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                                        ),
                                      ],
                                    ),
                                    onTap: () async {
                                      Map<String, dynamic>? selectedFood = food;

                                      // If the food has no ID but has a barcode, we must resolve/cache it in the DB first
                                      if (food['id'] == null && food['barcode'] != null) {
                                        setState(() {
                                          _isLoadingFood = true;
                                        });
                                        final dbFood = await _store.lookupFoodByBarcode(food['barcode'].toString());
                                        setState(() {
                                          _isLoadingFood = false;
                                        });
                                        if (dbFood != null) {
                                          selectedFood = dbFood;
                                        } else {
                                          return;
                                        }
                                      }

                                      if (selectedFood != null) {
                                        Navigator.pop(context);

                                        // Determine serving units
                                        String? servingUnit = food['servingUnit'] as String?;
                                        double? gramsPerServing = (food['gramsPerServing'] as num?)?.toDouble();

                                        // Try to look up in our common serving info map if not present
                                        final String? barcode = selectedFood['barcode']?.toString();
                                        if (servingUnit == null && barcode != null) {
                                          final info = _servingInfoMap[barcode];
                                          if (info != null) {
                                            servingUnit = info['unit'] as String?;
                                            gramsPerServing = (info['grams'] as num?)?.toDouble();
                                          }
                                        }

                                        widget.onFoodSelected(
                                          selectedFood,
                                          servingUnit,
                                          gramsPerServing,
                                        );
                                      }
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
            ],
          ),
          if (_isLoadingFood)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.2),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.black),
              ),
            ),
        ],
      ),
    );
  }
}
