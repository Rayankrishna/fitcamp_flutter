import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../store/auth_store.dart';
import '../../store/workout_store.dart';
import '../../models/workout_models.dart';
import '../../shared/bottom_nav_bar.dart';
import 'split_manager_page.dart';
import 'lift_progress_page.dart';
import 'workout_logger_page.dart';

class WorkoutTrackerPage extends StatefulWidget {
  const WorkoutTrackerPage({super.key});

  @override
  State<WorkoutTrackerPage> createState() => _WorkoutTrackerPageState();
}

class _WorkoutTrackerPageState extends State<WorkoutTrackerPage> {
  final AuthStore _store = AuthStore.instance;

  void _showStartWorkoutSheet() async {
    final WorkoutStore workoutStore = WorkoutStore.instance;
    await workoutStore.fetchPrograms();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Choose Workout Routine",
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Select a routine template from your splits to start tracking.",
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              Observer(
                builder: (_) {
                  if (workoutStore.isLoading) {
                    return const Center(child: CircularProgressIndicator(color: Colors.black));
                  }
                  final programs = workoutStore.programs ?? [];
                  if (programs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          "No splits or routines found. Go to 'Split Manager' to create some!",
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final allTemplates = <Map<String, dynamic>>[];
                  for (var p in programs) {
                    for (var t in p.templates ?? []) {
                      allTemplates.add({'program': p.name, 'template': t});
                    }
                  }

                  if (allTemplates.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          "No routines found. Go to 'Split Manager' to create some!",
                          style: TextStyle(color: Colors.grey[500]),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: allTemplates.length,
                    itemBuilder: (context, idx) {
                      final item = allTemplates[idx];
                      final programName = item['program'] as String;
                      final template = item['template'] as WorkoutTemplate;
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(template.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(programName),
                        trailing: const Icon(Icons.play_arrow_rounded, color: Colors.black),
                        onTap: () {
                          Navigator.pop(context); // Close sheet
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => WorkoutLoggerPage(
                                templateId: template.id,
                                templateName: template.name,
                              ),
                            ),
                          ).then((_) => _store.fetchWorkouts());
                        },
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _store.fetchWorkouts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Workouts",
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading && (_store.workouts?.isEmpty ?? true)) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }
          if (_store.errorMessage != null && (_store.workouts?.isEmpty ?? true)) {
            return Center(child: Text(_store.errorMessage!));
          }

          final workouts = _store.workouts ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SplitManagerPage()),
                            );
                          },
                          icon: const Icon(Icons.settings, color: Colors.black, size: 18),
                          label: const Text("Split Manager", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const LiftProgressPage()),
                            );
                          },
                          icon: const Icon(Icons.show_chart, color: Colors.black, size: 18),
                          label: const Text("Lift Charts", style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black, width: 1.5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().slideY(begin: 0.1).fadeIn(),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: _showStartWorkoutSheet,
                    icon: const Icon(Icons.add),
                    label: const Text(
                      "Start New Workout",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ).animate().slideY(begin: 0.1, delay: 100.ms).fadeIn(),

                const SizedBox(height: 48),
                Text(
                  "ACTIVE & PAST SESSIONS",
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(letterSpacing: 2),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 16),

                if (workouts.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        "No workouts tracked yet.",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      ..._store.workouts!.map((workout) => _buildWorkoutCard(workout)),
                      const SizedBox(height: 20),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const FloatingBottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildWorkoutCard(dynamic workout) {
    final elements = workout['sets'] as List? ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                workout['name'] ?? 'Workout Session',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  "COMPLETED",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.event, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                workout['date'] ?? 'Recent',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Tag chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (workout['template_name'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Routine: ${workout['template_name']}",
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              if (workout['total_sets'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "${workout['total_sets']} sets",
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ...elements.map<Widget>((e) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    e['exercises']?['name'] ?? 'Exercise',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, delay: 300.ms).fadeIn();
  }
}
