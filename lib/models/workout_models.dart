class WorkoutProgram {
  final String id;
  final String name;
  final String? description;
  final List<WorkoutTemplate>? templates;

  WorkoutProgram({
    required this.id,
    required this.name,
    this.description,
    this.templates,
  });

  factory WorkoutProgram.fromJson(Map<String, dynamic> json) {
    var templatesList = json['templates'] as List?;
    return WorkoutProgram(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      templates: templatesList != null
          ? templatesList.map((e) => WorkoutTemplate.fromJson(e)).toList()
          : null,
    );
  }
}

class WorkoutTemplate {
  final String id;
  final String name;
  final String? programId;
  final List<TemplateExercise>? exercises;

  WorkoutTemplate({
    required this.id,
    required this.name,
    this.programId,
    this.exercises,
  });

  factory WorkoutTemplate.fromJson(Map<String, dynamic> json) {
    var exercisesList = json['exercises'] as List?;
    return WorkoutTemplate(
      id: json['id'] as String,
      name: json['name'] as String,
      programId: json['program_id'] as String?,
      exercises: exercisesList != null
          ? exercisesList.map((e) => TemplateExercise.fromJson(e)).toList()
          : null,
    );
  }
}

class TemplateExercise {
  final String id;
  final int sequenceOrder;
  final Exercise exercise;
  final PreviousPerformance? previousPerformance;

  TemplateExercise({
    required this.id,
    required this.sequenceOrder,
    required this.exercise,
    this.previousPerformance,
  });

  factory TemplateExercise.fromJson(Map<String, dynamic> json) {
    return TemplateExercise(
      id: json['id'] as String,
      sequenceOrder: json['sequence_order'] as int? ?? 1,
      exercise: Exercise.fromJson(json['exercise'] as Map<String, dynamic>),
      previousPerformance: json['previous_performance'] != null
          ? PreviousPerformance.fromJson(json['previous_performance'] as Map<String, dynamic>)
          : null,
    );
  }
}

class Exercise {
  final String id;
  final String name;
  final String? muscleGroup;

  Exercise({
    required this.id,
    required this.name,
    this.muscleGroup,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] as String,
      name: json['name'] as String,
      muscleGroup: json['muscle_group'] as String?,
    );
  }
}

class PreviousPerformance {
  final String? workoutId;
  final String? date;
  final List<SetLog> sets;

  PreviousPerformance({
    this.workoutId,
    this.date,
    required this.sets,
  });

  factory PreviousPerformance.fromJson(Map<String, dynamic> json) {
    var setsList = json['sets'] as List?;
    return PreviousPerformance(
      workoutId: json['workout_id'] as String?,
      date: json['date'] as String?,
      sets: setsList != null
          ? setsList.map((e) => SetLog.fromJson(e as Map<String, dynamic>)).toList()
          : [],
    );
  }
}

class SetLog {
  final int reps;
  final double weight;

  SetLog({required this.reps, required this.weight});

  factory SetLog.fromJson(Map<String, dynamic> json) {
    return SetLog(
      reps: json['reps'] as int,
      weight: (json['weight'] as num).toDouble(),
    );
  }
}

class CalendarWorkout {
  final String id;
  final String name;
  final String date;
  final String? templateId;
  final String? templateName;
  final int totalSets;

  CalendarWorkout({
    required this.id,
    required this.name,
    required this.date,
    this.templateId,
    this.templateName,
    required this.totalSets,
  });

  factory CalendarWorkout.fromJson(Map<String, dynamic> json) {
    return CalendarWorkout(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Workout',
      date: json['date'] as String,
      templateId: json['template_id'] as String?,
      templateName: json['template_name'] as String?,
      totalSets: json['total_sets'] as int? ?? 0,
    );
  }
}

class ProgressDataPoint {
  final String setId;
  final String workoutId;
  final String workoutName;
  final String date;
  final int reps;
  final double weight;
  final DateTime createdAt;

  ProgressDataPoint({
    required this.setId,
    required this.workoutId,
    required this.workoutName,
    required this.date,
    required this.reps,
    required this.weight,
    required this.createdAt,
  });

  factory ProgressDataPoint.fromJson(Map<String, dynamic> json) {
    return ProgressDataPoint(
      setId: json['set_id'] as String,
      workoutId: json['workout_id'] as String,
      workoutName: json['workout_name'] as String? ?? '',
      date: json['date'] as String,
      reps: json['reps'] as int,
      weight: (json['weight'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
