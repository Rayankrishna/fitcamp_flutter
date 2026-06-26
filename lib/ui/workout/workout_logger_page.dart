import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../store/workout_store.dart';
import '../../models/workout_models.dart';
import '../../shared/app_snackbar.dart';

class WorkoutLoggerPage extends StatefulWidget {
  final String templateId;
  final String templateName;

  const WorkoutLoggerPage({
    super.key,
    required this.templateId,
    required this.templateName,
  });

  @override
  State<WorkoutLoggerPage> createState() => _WorkoutLoggerPageState();
}

class _WorkoutLoggerPageState extends State<WorkoutLoggerPage> {
  final WorkoutStore _store = WorkoutStore.instance;
  
  // Maps exerciseId to its list of local sets
  final Map<String, List<LocalSetState>> _exerciseSetsMap = {};
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _startSession();
  }

  void _startSession() async {
    // 1. Start workout session via POST /api/workout
    final name = "${widget.templateName} Session";
    final started = await _store.startWorkoutSession(widget.templateId, name);
    if (!started) {
      if (mounted) {
        AppSnackbar.show("Failed to start workout session.");
        Navigator.pop(context);
      }
      return;
    }

    // 2. Fetch template details (exercise list & previous stats)
    await _store.fetchTemplateDetails(widget.templateId);
    
    // 3. Initialize local set states
    if (_store.activeTemplate?.exercises != null) {
      for (var te in _store.activeTemplate!.exercises!) {
        final exerciseId = te.exercise.id;
        final prevSets = te.previousPerformance?.sets ?? [];
        
        final list = <LocalSetState>[];
        if (prevSets.isNotEmpty) {
          for (int i = 0; i < prevSets.length; i++) {
            list.add(
              LocalSetState(
                index: i + 1,
                prevWeight: prevSets[i].weight,
                prevReps: prevSets[i].reps,
                weightController: TextEditingController(),
                repsController: TextEditingController(),
              ),
            );
          }
        } else {
          // Default to 3 empty sets if no history exists
          for (int i = 0; i < 3; i++) {
            list.add(
              LocalSetState(
                index: i + 1,
                weightController: TextEditingController(),
                repsController: TextEditingController(),
              ),
            );
          }
        }
        _exerciseSetsMap[exerciseId] = list;
      }
    }

    setState(() {
      _initialized = true;
    });
  }

  void _addSet(String exerciseId) {
    setState(() {
      final list = _exerciseSetsMap[exerciseId] ?? [];
      double? lastPrevWeight;
      int? lastPrevReps;
      
      if (list.isNotEmpty) {
        lastPrevWeight = list.last.prevWeight;
        lastPrevReps = list.last.prevReps;
      }
      
      list.add(
        LocalSetState(
          index: list.length + 1,
          prevWeight: lastPrevWeight,
          prevReps: lastPrevReps,
          weightController: TextEditingController(),
          repsController: TextEditingController(),
        ),
      );
      _exerciseSetsMap[exerciseId] = list;
    });
  }

  void _removeSet(String exerciseId) {
    setState(() {
      final list = _exerciseSetsMap[exerciseId] ?? [];
      if (list.isNotEmpty) {
        final last = list.last;
        last.weightController.dispose();
        last.repsController.dispose();
        list.removeLast();
        _exerciseSetsMap[exerciseId] = list;
      }
    });
  }

  void _logSetRow(String exerciseId, LocalSetState setRow) async {
    final weightStr = setRow.weightController.text.trim();
    final repsStr = setRow.repsController.text.trim();
    
    if (weightStr.isEmpty || repsStr.isEmpty) {
      // Try to fallback to previous values if available
      if (setRow.prevWeight != null && setRow.prevReps != null) {
        setRow.weightController.text = setRow.prevWeight.toString();
        setRow.repsController.text = setRow.prevReps.toString();
      } else {
        AppSnackbar.show("Please enter weight and reps.");
        return;
      }
    }

    final weight = double.tryParse(setRow.weightController.text) ?? 0.0;
    final reps = int.tryParse(setRow.repsController.text) ?? 0;
    final workoutId = _store.activeWorkout?['id'] as String?;

    if (workoutId == null) {
      AppSnackbar.show("No active workout session found.");
      return;
    }

    setState(() {
      setRow.isLoading = true;
    });

    final success = await _store.logSet(workoutId, exerciseId, reps, weight);

    setState(() {
      setRow.isLoading = false;
      if (success) {
        setRow.isLogged = true;
      }
    });
  }

  @override
  void dispose() {
    _exerciseSetsMap.forEach((_, list) {
      for (var row in list) {
        row.weightController.dispose();
        row.repsController.dispose();
      }
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.templateName,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Observer(
        builder: (_) {
          if (!_initialized || (_store.isLoading && _store.activeTemplate == null)) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.black),
            );
          }

          final template = _store.activeTemplate;
          final exercises = template?.exercises ?? [];

          return Column(
            children: [
              Expanded(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                        child: Text(
                          "Log your workout. Gray placeholders show your stats from last session. Match or beat them for progressive overload!",
                          style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        ).animate().fadeIn(),
                      ),
                    ),
                    
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final te = exercises[index];
                            final setsList = _exerciseSetsMap[te.exercise.id] ?? [];
                            return _buildExerciseCard(te, setsList).animate().fadeIn(delay: (100 * index).ms);
                          },
                          childCount: exercises.length,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Finish workout button
              Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(10),
                      blurRadius: 10,
                      offset: const Offset(0, -4),
                    )
                  ],
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: () {
                      AppSnackbar.show("Workout Finished! Great job!");
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28.r),
                      ),
                    ),
                    child: const Text(
                      "Finish Workout",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildExerciseCard(TemplateExercise te, List<LocalSetState> setsList) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            te.exercise.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            te.exercise.muscleGroup ?? 'General',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          const SizedBox(height: 16),
          
          // Set table header
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  "SET",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 4,
                child: Text(
                  "PREVIOUS",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "KG",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  "REPS",
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 48), // Spacing for check icon
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),

          // Sets list
          ...setsList.map((setRow) => _buildSetRow(te.exercise.id, setRow)),

          const SizedBox(height: 12),

          // Add / Remove set buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _removeSet(te.exercise.id),
                icon: const Icon(Icons.remove, size: 16, color: Colors.red),
                label: const Text("Remove Set", style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => _addSet(te.exercise.id),
                icon: const Icon(Icons.add, size: 16, color: Colors.black),
                label: const Text("Add Set", style: TextStyle(color: Colors.black, fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSetRow(String exerciseId, LocalSetState setRow) {
    final String prevText = (setRow.prevWeight != null && setRow.prevReps != null)
        ? "${setRow.prevWeight} kg x ${setRow.prevReps}"
        : "--";

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          // Set Index
          Expanded(
            flex: 2,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: setRow.isLogged ? Colors.green[100] : Colors.grey[200],
              child: Text(
                "${setRow.index}",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: setRow.isLogged ? Colors.green[800] : Colors.black,
                ),
              ),
            ),
          ),
          
          // Previous stats placeholder
          Expanded(
            flex: 4,
            child: Text(
              prevText,
              style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          
          // Weight input
          Expanded(
            flex: 3,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: setRow.weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                enabled: !setRow.isLogged,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: setRow.prevWeight?.toString() ?? "0.0",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  isDense: true,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          
          // Reps input
          Expanded(
            flex: 3,
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: TextField(
                controller: setRow.repsController,
                keyboardType: TextInputType.number,
                enabled: !setRow.isLogged,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: setRow.prevReps?.toString() ?? "0",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  isDense: true,
                ),
              ),
            ),
          ),
          
          // Action button
          SizedBox(
            width: 48,
            child: setRow.isLoading
                ? const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      setRow.isLogged ? Icons.check_circle : Icons.check_circle_outline,
                      color: setRow.isLogged ? Colors.green : Colors.grey[400],
                    ),
                    onPressed: setRow.isLogged ? null : () => _logSetRow(exerciseId, setRow),
                  ),
          ),
        ],
      ),
    );
  }
}

class LocalSetState {
  final int index;
  final double? prevWeight;
  final int? prevReps;
  final TextEditingController weightController;
  final TextEditingController repsController;
  bool isLogged;
  bool isLoading;

  LocalSetState({
    required this.index,
    this.prevWeight,
    this.prevReps,
    required this.weightController,
    required this.repsController,
    this.isLogged = false,
    this.isLoading = false,
  });
}
