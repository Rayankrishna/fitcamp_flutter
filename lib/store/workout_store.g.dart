// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workout_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$WorkoutStore on _WorkoutStoreBase, Store {
  Computed<bool>? _$isLoadingComputed;

  @override
  bool get isLoading =>
      (_$isLoadingComputed ??= Computed<bool>(
            () => super.isLoading,
            name: '_WorkoutStoreBase.isLoading',
          ))
          .value;

  late final _$programsStateAtom = Atom(
    name: '_WorkoutStoreBase.programsState',
    context: context,
  );

  @override
  LoadingStatusEnum get programsState {
    _$programsStateAtom.reportRead();
    return super.programsState;
  }

  @override
  set programsState(LoadingStatusEnum value) {
    _$programsStateAtom.reportWrite(value, super.programsState, () {
      super.programsState = value;
    });
  }

  late final _$templatesStateAtom = Atom(
    name: '_WorkoutStoreBase.templatesState',
    context: context,
  );

  @override
  LoadingStatusEnum get templatesState {
    _$templatesStateAtom.reportRead();
    return super.templatesState;
  }

  @override
  set templatesState(LoadingStatusEnum value) {
    _$templatesStateAtom.reportWrite(value, super.templatesState, () {
      super.templatesState = value;
    });
  }

  late final _$activeWorkoutStateAtom = Atom(
    name: '_WorkoutStoreBase.activeWorkoutState',
    context: context,
  );

  @override
  LoadingStatusEnum get activeWorkoutState {
    _$activeWorkoutStateAtom.reportRead();
    return super.activeWorkoutState;
  }

  @override
  set activeWorkoutState(LoadingStatusEnum value) {
    _$activeWorkoutStateAtom.reportWrite(value, super.activeWorkoutState, () {
      super.activeWorkoutState = value;
    });
  }

  late final _$calendarStateAtom = Atom(
    name: '_WorkoutStoreBase.calendarState',
    context: context,
  );

  @override
  LoadingStatusEnum get calendarState {
    _$calendarStateAtom.reportRead();
    return super.calendarState;
  }

  @override
  set calendarState(LoadingStatusEnum value) {
    _$calendarStateAtom.reportWrite(value, super.calendarState, () {
      super.calendarState = value;
    });
  }

  late final _$progressStateAtom = Atom(
    name: '_WorkoutStoreBase.progressState',
    context: context,
  );

  @override
  LoadingStatusEnum get progressState {
    _$progressStateAtom.reportRead();
    return super.progressState;
  }

  @override
  set progressState(LoadingStatusEnum value) {
    _$progressStateAtom.reportWrite(value, super.progressState, () {
      super.progressState = value;
    });
  }

  late final _$exercisesStateAtom = Atom(
    name: '_WorkoutStoreBase.exercisesState',
    context: context,
  );

  @override
  LoadingStatusEnum get exercisesState {
    _$exercisesStateAtom.reportRead();
    return super.exercisesState;
  }

  @override
  set exercisesState(LoadingStatusEnum value) {
    _$exercisesStateAtom.reportWrite(value, super.exercisesState, () {
      super.exercisesState = value;
    });
  }

  late final _$programsAtom = Atom(
    name: '_WorkoutStoreBase.programs',
    context: context,
  );

  @override
  List<WorkoutProgram>? get programs {
    _$programsAtom.reportRead();
    return super.programs;
  }

  @override
  set programs(List<WorkoutProgram>? value) {
    _$programsAtom.reportWrite(value, super.programs, () {
      super.programs = value;
    });
  }

  late final _$activeTemplateAtom = Atom(
    name: '_WorkoutStoreBase.activeTemplate',
    context: context,
  );

  @override
  WorkoutTemplate? get activeTemplate {
    _$activeTemplateAtom.reportRead();
    return super.activeTemplate;
  }

  @override
  set activeTemplate(WorkoutTemplate? value) {
    _$activeTemplateAtom.reportWrite(value, super.activeTemplate, () {
      super.activeTemplate = value;
    });
  }

  late final _$exercisesAtom = Atom(
    name: '_WorkoutStoreBase.exercises',
    context: context,
  );

  @override
  List<Exercise>? get exercises {
    _$exercisesAtom.reportRead();
    return super.exercises;
  }

  @override
  set exercises(List<Exercise>? value) {
    _$exercisesAtom.reportWrite(value, super.exercises, () {
      super.exercises = value;
    });
  }

  late final _$calendarWorkoutsAtom = Atom(
    name: '_WorkoutStoreBase.calendarWorkouts',
    context: context,
  );

  @override
  List<CalendarWorkout>? get calendarWorkouts {
    _$calendarWorkoutsAtom.reportRead();
    return super.calendarWorkouts;
  }

  @override
  set calendarWorkouts(List<CalendarWorkout>? value) {
    _$calendarWorkoutsAtom.reportWrite(value, super.calendarWorkouts, () {
      super.calendarWorkouts = value;
    });
  }

  late final _$liftProgressAtom = Atom(
    name: '_WorkoutStoreBase.liftProgress',
    context: context,
  );

  @override
  List<ProgressDataPoint>? get liftProgress {
    _$liftProgressAtom.reportRead();
    return super.liftProgress;
  }

  @override
  set liftProgress(List<ProgressDataPoint>? value) {
    _$liftProgressAtom.reportWrite(value, super.liftProgress, () {
      super.liftProgress = value;
    });
  }

  late final _$activeWorkoutAtom = Atom(
    name: '_WorkoutStoreBase.activeWorkout',
    context: context,
  );

  @override
  Map<String, dynamic>? get activeWorkout {
    _$activeWorkoutAtom.reportRead();
    return super.activeWorkout;
  }

  @override
  set activeWorkout(Map<String, dynamic>? value) {
    _$activeWorkoutAtom.reportWrite(value, super.activeWorkout, () {
      super.activeWorkout = value;
    });
  }

  late final _$fetchProgramsAsyncAction = AsyncAction(
    '_WorkoutStoreBase.fetchPrograms',
    context: context,
  );

  @override
  Future<void> fetchPrograms() {
    return _$fetchProgramsAsyncAction.run(() => super.fetchPrograms());
  }

  late final _$createProgramAsyncAction = AsyncAction(
    '_WorkoutStoreBase.createProgram',
    context: context,
  );

  @override
  Future<bool> createProgram(String name, String description) {
    return _$createProgramAsyncAction.run(
      () => super.createProgram(name, description),
    );
  }

  late final _$createTemplateAsyncAction = AsyncAction(
    '_WorkoutStoreBase.createTemplate',
    context: context,
  );

  @override
  Future<bool> createTemplate(String programId, String name) {
    return _$createTemplateAsyncAction.run(
      () => super.createTemplate(programId, name),
    );
  }

  late final _$fetchExercisesAsyncAction = AsyncAction(
    '_WorkoutStoreBase.fetchExercises',
    context: context,
  );

  @override
  Future<void> fetchExercises() {
    return _$fetchExercisesAsyncAction.run(() => super.fetchExercises());
  }

  late final _$addExerciseToTemplateAsyncAction = AsyncAction(
    '_WorkoutStoreBase.addExerciseToTemplate',
    context: context,
  );

  @override
  Future<bool> addExerciseToTemplate(
    String templateId,
    String exerciseId,
    int order,
  ) {
    return _$addExerciseToTemplateAsyncAction.run(
      () => super.addExerciseToTemplate(templateId, exerciseId, order),
    );
  }

  late final _$fetchTemplateDetailsAsyncAction = AsyncAction(
    '_WorkoutStoreBase.fetchTemplateDetails',
    context: context,
  );

  @override
  Future<void> fetchTemplateDetails(String templateId) {
    return _$fetchTemplateDetailsAsyncAction.run(
      () => super.fetchTemplateDetails(templateId),
    );
  }

  late final _$startWorkoutSessionAsyncAction = AsyncAction(
    '_WorkoutStoreBase.startWorkoutSession',
    context: context,
  );

  @override
  Future<bool> startWorkoutSession(String templateId, String name) {
    return _$startWorkoutSessionAsyncAction.run(
      () => super.startWorkoutSession(templateId, name),
    );
  }

  late final _$logSetAsyncAction = AsyncAction(
    '_WorkoutStoreBase.logSet',
    context: context,
  );

  @override
  Future<bool> logSet(
    String workoutId,
    String exerciseId,
    int reps,
    double weight,
  ) {
    return _$logSetAsyncAction.run(
      () => super.logSet(workoutId, exerciseId, reps, weight),
    );
  }

  late final _$fetchCalendarWorkoutsAsyncAction = AsyncAction(
    '_WorkoutStoreBase.fetchCalendarWorkouts',
    context: context,
  );

  @override
  Future<void> fetchCalendarWorkouts(String start, String end) {
    return _$fetchCalendarWorkoutsAsyncAction.run(
      () => super.fetchCalendarWorkouts(start, end),
    );
  }

  late final _$fetchLiftProgressAsyncAction = AsyncAction(
    '_WorkoutStoreBase.fetchLiftProgress',
    context: context,
  );

  @override
  Future<void> fetchLiftProgress(String exerciseId) {
    return _$fetchLiftProgressAsyncAction.run(
      () => super.fetchLiftProgress(exerciseId),
    );
  }

  @override
  String toString() {
    return '''
programsState: ${programsState},
templatesState: ${templatesState},
activeWorkoutState: ${activeWorkoutState},
calendarState: ${calendarState},
progressState: ${progressState},
exercisesState: ${exercisesState},
programs: ${programs},
activeTemplate: ${activeTemplate},
exercises: ${exercises},
calendarWorkouts: ${calendarWorkouts},
liftProgress: ${liftProgress},
activeWorkout: ${activeWorkout},
isLoading: ${isLoading}
    ''';
  }
}
