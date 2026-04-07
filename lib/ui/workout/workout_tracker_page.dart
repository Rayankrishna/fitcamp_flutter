import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../store/auth_store.dart';

class WorkoutTrackerPage extends StatefulWidget {
  const WorkoutTrackerPage({super.key});

  @override
  State<WorkoutTrackerPage> createState() => _WorkoutTrackerPageState();
}

class _WorkoutTrackerPageState extends State<WorkoutTrackerPage> {
  final AuthStore _store = AuthStore.instance;

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
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton.icon(
                    onPressed: () {},
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
                ).animate().slideY(begin: 0.1).fadeIn(),

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
                      const SizedBox(height: 100),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
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
            children:
                elements.map<Widget>((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      e['exercises']?['name'] ?? 'Exercise',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.1, delay: 300.ms).fadeIn();
  }
}
