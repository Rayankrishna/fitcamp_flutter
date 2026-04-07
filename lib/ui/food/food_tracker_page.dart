import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../store/auth_store.dart';
import '../../shared/bottom_nav_bar.dart';

class FoodTrackerPage extends StatefulWidget {
  const FoodTrackerPage({super.key});

  @override
  State<FoodTrackerPage> createState() => _FoodTrackerPageState();
}

class _FoodTrackerPageState extends State<FoodTrackerPage> {
  final AuthStore _store = AuthStore.instance;

  @override
  void initState() {
    super.initState();
    _store.fetchDailyMacros();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Today's Nutrition", style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }
          if (_store.errorMessage != null && _store.dailyMacros == null) {
            return Center(child: Text(_store.errorMessage!));
          }

          final macros = _store.dailyMacros;
          final totalCalories = macros?['total_calories'] ?? 0;
          final protein = macros?['total_protein'] ?? 0;
          final carbs = macros?['total_carbs'] ?? 0;
          final fat = macros?['total_fat'] ?? 0;
          final items = macros?['items'] as List? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Calorie Bar section
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  child: Column(
                    children: [
                      Text("Total Consumed", style: Theme.of(context).textTheme.labelMedium),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text("$totalCalories", style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 64)),
                          const SizedBox(width: 4),
                          Text("kcal", style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                    ],
                  ),
                ).animate().slideY(begin: 0.1, duration: 400.ms).fadeIn(),

                const SizedBox(height: 24),

                // Macros
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildMacroCard("PROTEIN", "$protein" "g", 0.6),
                    _buildMacroCard("CARBS", "$carbs" "g", 0.3),
                    _buildMacroCard("FATS", "$fat" "g", 0.4),
                  ],
                ).animate().slideY(begin: 0.1, delay: 200.ms).fadeIn(),

                const SizedBox(height: 48),

                // Recent Meals List
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Recent Meals", style: Theme.of(context).textTheme.headlineSmall),
                      Text("View History", style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        decoration: TextDecoration.underline,
                      )),
                    ],
                  ),
                ).animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 16),

                if (items.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text("No meals logged today.", 
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant
                        )
                      ),
                    ),
                  )
                else
                  ...items.map((item) => _buildMealCard(item)),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const FloatingBottomNavBar(currentIndex: 1),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0), // Elevate above nav bar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FloatingActionButton.extended(
              heroTag: "manualAction",
              onPressed: () {},
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 2,
              icon: const Icon(Icons.add_rounded),
              label: const Text("ADD MEAL", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ).animate().slideX(begin: 0.5, delay: 500.ms).fadeIn(),
            const SizedBox(width: 12),
            FloatingActionButton.extended(
              heroTag: "barcodeAction",
              onPressed: () {},
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.barcode_reader),
              label: const Text("SCAN CODE", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ).animate().slideX(begin: -0.5, delay: 500.ms).fadeIn(),
          ],
        ),
      ),
    );
  }

  Widget _buildMacroCard(String label, String value, double percent) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))
        ]
      ),
      child: Column(
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              value: percent,
              strokeWidth: 6,
              color: Colors.black,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              strokeCap: StrokeCap.round,
            ),
          ),
          const SizedBox(height: 16),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildMealCard(dynamic item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.restaurant, color: Colors.grey),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name'] ?? 'Unknown Item',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                ),
                Text(
                  "${item['grams'] ?? 0}g",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item['calories'] ?? 0}",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 24),
              ),
              Text(
                "KCAL",
                style: Theme.of(context).textTheme.labelSmall,
              )
            ],
          )
        ],
      ).animate().fadeIn(duration: 400.ms),
    );
  }
}
