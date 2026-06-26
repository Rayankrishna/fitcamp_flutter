import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../store/workout_store.dart';
import '../../models/workout_models.dart';

class SplitManagerPage extends StatefulWidget {
  const SplitManagerPage({super.key});

  @override
  State<SplitManagerPage> createState() => _SplitManagerPageState();
}

class _SplitManagerPageState extends State<SplitManagerPage> {
  final WorkoutStore _store = WorkoutStore.instance;

  @override
  void initState() {
    super.initState();
    _store.fetchPrograms();
  }

  void _showCreateProgramSheet() {
    final nameController = TextEditingController();
    final descController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              "New Training Split",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Define a new workout split program (e.g. Push/Pull/Legs).",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Split Name",
                hintText: "e.g. PPL Split, Upper/Lower",
                prefixIcon: const Icon(Icons.fitness_center),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descController,
              decoration: InputDecoration(
                labelText: "Description",
                hintText: "e.g. 4-day strength and hypertrophy focus",
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final success = await _store.createProgram(
                      nameController.text,
                      descController.text,
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
                  "Create Split",
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

  void _showCreateTemplateSheet(String programId) {
    final nameController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              "Add Workout Routine",
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              "Create a template routine under this split (e.g. Push Day).",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Routine Name",
                hintText: "e.g. Upper Day, Pull Day",
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty) {
                    final success = await _store.createTemplate(
                      programId,
                      nameController.text,
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
                  "Create Routine",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Split Manager",
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading && (_store.programs?.isEmpty ?? true)) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          final programs = _store.programs ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Intro header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Manage Training Splits",
                        style: Theme.of(context).textTheme.titleLarge,
                      ).animate().fadeIn().slideY(begin: 0.1),
                      const SizedBox(height: 6),
                      Text(
                        "Create customized workout programs and structure routines with specific exercises.",
                        style: TextStyle(color: Colors.grey[600]),
                      ).animate().fadeIn(delay: 100.ms),
                    ],
                  ),
                ),
              ),

              // Split Manager programs list
              if (programs.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        "No splits configured. Tap '+' to create one.",
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final program = programs[index];
                        return _buildProgramCard(program).animate().fadeIn(delay: (150 * index).ms);
                      },
                      childCount: programs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateProgramSheet,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Create Split", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildProgramCard(WorkoutProgram program) {
    final templates = program.templates ?? [];
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Program Header info
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        program.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (program.description != null && program.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          program.description!,
                          style: TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.black),
                  tooltip: "Add Routine",
                  onPressed: () => _showCreateTemplateSheet(program.id),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),

          // Templates list
          if (templates.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  "No routines in this split yet.",
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: templates.length,
              separatorBuilder: (_, __) => const Divider(height: 1, thickness: 1),
              itemBuilder: (context, idx) {
                final template = templates[idx];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(
                    template.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TemplateExercisesPage(template: template),
                      ),
                    ).then((_) => _store.fetchPrograms());
                  },
                );
              },
            ),
        ],
      ),
    );
  }
}

class TemplateExercisesPage extends StatefulWidget {
  final WorkoutTemplate template;

  const TemplateExercisesPage({super.key, required this.template});

  @override
  State<TemplateExercisesPage> createState() => _TemplateExercisesPageState();
}

class _TemplateExercisesPageState extends State<TemplateExercisesPage> {
  final WorkoutStore _store = WorkoutStore.instance;

  @override
  void initState() {
    super.initState();
    _store.fetchTemplateDetails(widget.template.id);
  }

  void _showAddExerciseSheet() async {
    await _store.fetchExercises();
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Add Exercise",
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  // Search box
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search exercises...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (val) {
                      // Filter locally if needed
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Observer(
                      builder: (_) {
                        if (_store.isLoading && (_store.exercises?.isEmpty ?? true)) {
                          return const Center(child: CircularProgressIndicator(color: Colors.black));
                        }
                        final list = _store.exercises ?? [];
                        return ListView.builder(
                          controller: scrollController,
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            final exercise = list[index];
                            return ListTile(
                              title: Text(
                                exercise.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(exercise.muscleGroup ?? 'General'),
                              trailing: const Icon(Icons.add, color: Colors.black),
                              onTap: () async {
                                final currentOrder = (_store.activeTemplate?.exercises?.length ?? 0) + 1;
                                final success = await _store.addExerciseToTemplate(
                                  widget.template.id,
                                  exercise.id,
                                  currentOrder,
                                );
                                if (success && mounted) {
                                  Navigator.pop(context);
                                }
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.template.name,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Observer(
        builder: (_) {
          if (_store.isLoading && _store.activeTemplate == null) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          final template = _store.activeTemplate;
          final exercises = template?.exercises ?? [];

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Structure Routine",
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Add exercises to execute during your '${widget.template.name}' workout session.",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ),

              if (exercises.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Text(
                        "No exercises added to this routine yet.",
                        style: TextStyle(color: Colors.grey[500], fontSize: 16),
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final te = exercises[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    radius: 14,
                                    child: Text(
                                      "${index + 1}",
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        te.exercise.name,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        te.exercise.muscleGroup ?? 'General',
                                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              // Optional placeholder for delete button
                            ],
                          ),
                        ).animate().fadeIn(delay: (100 * index).ms);
                      },
                      childCount: exercises.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddExerciseSheet,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Exercise", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}
