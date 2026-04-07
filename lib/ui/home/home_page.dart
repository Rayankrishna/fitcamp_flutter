import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fitcamp_flutter/shared/enums.dart';
import '../../store/auth_store.dart';
import '../../shared/animated_summary_card.dart';
import '../../shared/bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthStore _homeStore = AuthStore.instance;

  @override
  void initState() {
    super.initState();
    _homeStore.fetchHomeData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Observer(
              builder: (_) {
                if (_homeStore.homeDataState == LoadingStatusEnum.loading && _homeStore.homeData == null) {
                  return const SizedBox(
                    height: 400,
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  );
                }

                if (_homeStore.homeDataState == LoadingStatusEnum.error &&
                    _homeStore.homeData == null) {
                  return Center(child: Text(_homeStore.errorMessage ?? "An error occurred"));
                }

                final personalInfo = _homeStore.homeData?.personalInfo;
                final goals = _homeStore.homeData?.goals;
                final needsSetup =
                    personalInfo?.height == "user data not filled" ||
                    personalInfo?.weight == "user data not filled";
                final needsGoals =
                    goals == null || 
                    goals.calorieGoal == 0 || 
                    goals.calorieGoal == null;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        "Good Morning,",
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                      Text(
                        personalInfo?.email?.split('@')[0] ?? "User",
                        style: Theme.of(context).textTheme.displaySmall,
                      ).animate().fadeIn(duration: 500.ms).slideX(begin: -0.1),

                      if (needsSetup) ...[
                        const SizedBox(height: 24),
                        _buildSetupPrompt(),
                      ],

                      if (!needsSetup && needsGoals) ...[
                        const SizedBox(height: 24),
                        _buildGoalsPrompt(),
                      ],

                      const SizedBox(height: 32),

                      // Nutrition Summary
                      _buildSectionTitle("Today's Nutrition"),
                      const SizedBox(height: 16),
                      AnimatedSummaryCard(
                        delay: 200.ms,
                        child: _buildNutritionSummary(),
                      ),

                      const SizedBox(height: 32),

                      // Workout Summary
                      _buildSectionTitle("Today's Workouts"),
                      const SizedBox(height: 16),
                      AnimatedSummaryCard(
                        delay: 400.ms,
                        child: _buildWorkoutSummary(),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const FloatingBottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildSetupPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Complete Your Profile",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We need your height and weight to provide accurate AI suggestions.",
            style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showSetupBottomSheet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Set Up Now"),
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 600.ms).fadeIn();
  }

  Widget _buildGoalsPrompt() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8FF8B), // A nice vibrant green/yellow
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Set Your Fitness Goals",
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Track your progress by setting daily calorie and macro targets.",
            style: TextStyle(color: Colors.black87, fontSize: 14),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _showGoalsBottomSheet(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("Define Goals"),
            ),
          ),
        ],
      ),
    ).animate().scale(delay: 600.ms).fadeIn();
  }

  void _showGoalsBottomSheet() {
    final calorieController = TextEditingController();
    final proteinController = TextEditingController();
    final fatController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 32,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Daily Goals",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  "Set your daily targets for a healthier you.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: calorieController,
                  decoration: InputDecoration(
                    labelText: "Calorie Goal (kcal)",
                    prefixIcon: const Icon(Icons.local_fire_department),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: proteinController,
                  decoration: InputDecoration(
                    labelText: "Protein Goal (g)",
                    prefixIcon: const Icon(Icons.egg),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: fatController,
                  decoration: InputDecoration(
                    labelText: "Fat Goal (g)",
                    prefixIcon: const Icon(Icons.opacity),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final cal = int.tryParse(calorieController.text);
                      final pro = int.tryParse(proteinController.text);
                      final fat = int.tryParse(fatController.text);
                      if (cal != null && pro != null && fat != null) {
                        final success = await _homeStore.updateGoals(
                          calorieGoal: cal,
                          proteinGoal: pro,
                          fatGoal: fat,
                        );
                        if (success && mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Save Goals",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
    );
  }

  void _showSetupBottomSheet() {
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    final ageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 24,
              right: 24,
              top: 32,
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Profile Details",
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  "Please enter your details to personalize your experience.",
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: heightController,
                  decoration: InputDecoration(
                    labelText: "Height (cm)",
                    prefixIcon: const Icon(Icons.height),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: weightController,
                  decoration: InputDecoration(
                    labelText: "Weight (kg)",
                    prefixIcon: const Icon(Icons.monitor_weight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ageController,
                  decoration: InputDecoration(
                    labelText: "Age",
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final h = int.tryParse(heightController.text);
                      final w = int.tryParse(weightController.text);
                      final a = int.tryParse(ageController.text);
                      if (h != null && w != null && a != null) {
                        final success = await _homeStore.updateProfile(
                          height: h,
                          weight: w,
                          age: a,
                        );
                        if (success && mounted) {
                          Navigator.pop(context);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Save Details",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.white.withAlpha(230),
      surfaceTintColor: Colors.transparent,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "FitCamp",
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          Observer(
            builder:
                (_) => CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(
                    Icons.person,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall,
    ).animate().fadeIn().slideY(begin: 0.2);
  }

  Widget _buildNutritionSummary() {
    final food = _homeStore.homeData?.foodSummary;
    final goals = _homeStore.homeData?.goals;
    if (food == null) return const SizedBox();

    final totalCals = food.totalCalories ?? 0;
    final goalCals = goals?.calorieGoal ?? 2200;
    final remainingCals = (goalCals - totalCals).clamp(0, goalCals).toInt();

    return Column(
      children: [
        Text(
          "Calories Remaining",
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              "$remainingCals",
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(fontSize: 64),
            ),
            const SizedBox(width: 6),
            Text(
              "kcal",
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMacroRing(
              "PROTEIN",
              food.totalProtein ?? 0,
              goals?.proteinGoal ?? 160,
            ),
            _buildMacroRing(
              "CARBS",
              food.totalCarbs ?? 0,
              goals?.carbsGoal ?? 190,
            ),
            _buildMacroRing(
              "FATS",
              food.totalFat ?? 0,
              goals?.fatGoal ?? 60,
            ),
          ],
        ),
        if (goals == null || goals.calorieGoal == 0 || goals.calorieGoal == null) ...[
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () => _showGoalsBottomSheet(),
            icon: const Icon(Icons.edit_rounded, size: 18),
            label: const Text("Update Goals"),
            style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
          ),
        ],
      ],
    );
  }

  Widget _buildMacroRing(String label, double consumed, double goal) {
    final percentage = ((consumed / goal) * 100).toInt().clamp(0, 100);

    return Column(
      children: [
        SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 5,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              CircularProgressIndicator(
                value: percentage / 100,
                strokeWidth: 6,
                color: Colors.black,
                strokeCap: StrokeCap.round,
              ).animate().custom(
                duration: 1000.ms,
                builder: (context, value, child) {
                  return CircularProgressIndicator(
                    value: (percentage / 100) * value,
                    strokeWidth: 6,
                    color: Colors.black,
                    strokeCap: StrokeCap.round,
                  );
                },
              ),
              Center(
                child: Text(
                  "$percentage%",
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${consumed.toInt()}/${goal.toInt()}g",
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildWorkoutSummary() {
    final summary = _homeStore.homeData?.workoutSummary;
    if (summary == null) return const SizedBox();

    final workouts = summary.workouts;
    if (workouts == null || workouts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.grey),
            const SizedBox(width: 12),
            Text(
              "No workouts logged for today.",
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    final latestWorkout = workouts.last;

    return Row(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(18),
          ),
          child: const Icon(
            Icons.fitness_center_rounded,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                latestWorkout['name'] ?? 'Workout',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 6),
              Text(
                "Completed today",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 28),
      ],
    );
  }
}
