import 'package:fitcamp_flutter/models/workout_models.dart';
import 'package:fitcamp_flutter/services/service_config.dart';
import 'package:fitcamp_flutter/shared/enums.dart';
import 'package:fitcamp_flutter/shared/app_snackbar.dart';
import 'package:mobx/mobx.dart';

part 'workout_store.g.dart';

class WorkoutStore extends _WorkoutStoreBase with _$WorkoutStore {
  static final WorkoutStore instance = WorkoutStore();
}

abstract class _WorkoutStoreBase with Store {
  HttpClient get _httpClient => http ?? HttpClient.init();

  @observable
  LoadingStatusEnum programsState = LoadingStatusEnum.initial;

  @observable
  LoadingStatusEnum templatesState = LoadingStatusEnum.initial;

  @observable
  LoadingStatusEnum activeWorkoutState = LoadingStatusEnum.initial;

  @observable
  LoadingStatusEnum calendarState = LoadingStatusEnum.initial;

  @observable
  LoadingStatusEnum progressState = LoadingStatusEnum.initial;

  @observable
  LoadingStatusEnum exercisesState = LoadingStatusEnum.initial;

  @observable
  List<WorkoutProgram>? programs;

  @observable
  WorkoutTemplate? activeTemplate;

  @observable
  List<Exercise>? exercises;

  @observable
  List<CalendarWorkout>? calendarWorkouts;

  @observable
  List<ProgressDataPoint>? liftProgress;

  @observable
  Map<String, dynamic>? activeWorkout;

  @computed
  bool get isLoading =>
      programsState == LoadingStatusEnum.loading ||
      templatesState == LoadingStatusEnum.loading ||
      activeWorkoutState == LoadingStatusEnum.loading ||
      calendarState == LoadingStatusEnum.loading ||
      progressState == LoadingStatusEnum.loading ||
      exercisesState == LoadingStatusEnum.loading;

  @action
  Future<void> fetchPrograms() async {
    programsState = LoadingStatusEnum.loading;
    try {
      final response = await _httpClient.get(ServiceConfig.programUrl);
      if (response is List) {
        programs = response.map((e) => WorkoutProgram.fromJson(e)).toList();
      } else {
        programs = [];
      }
      programsState = LoadingStatusEnum.success;
    } catch (e) {
      programsState = LoadingStatusEnum.error;
      AppSnackbar.show(e.toString());
    }
  }

  @action
  Future<bool> createProgram(String name, String description) async {
    programsState = LoadingStatusEnum.loading;
    try {
      await _httpClient.post(
        ServiceConfig.programUrl,
        data: {'name': name, 'description': description},
      );
      await fetchPrograms();
      programsState = LoadingStatusEnum.success;
      return true;
    } catch (e) {
      programsState = LoadingStatusEnum.error;
      AppSnackbar.show(e.toString());
      return false;
    }
  }

  @action
  Future<bool> createTemplate(String programId, String name) async {
    templatesState = LoadingStatusEnum.loading;
    try {
      await _httpClient.post(
        ServiceConfig.templateUrl,
        data: {'program_id': programId, 'name': name},
      );
      await fetchPrograms(); // Refresh programs to load new templates
      templatesState = LoadingStatusEnum.success;
      return true;
    } catch (e) {
      templatesState = LoadingStatusEnum.error;
      AppSnackbar.show(e.toString());
      return false;
    }
  }

  @action
  Future<void> fetchExercises() async {
    exercisesState = LoadingStatusEnum.loading;
    try {
      final response = await _httpClient.get(ServiceConfig.exerciseUrl);
      if (response is List) {
        exercises = response.map((e) => Exercise.fromJson(e)).toList();
      } else {
        exercises = [];
      }
      exercisesState = LoadingStatusEnum.success;
    } catch (e) {
      exercisesState = LoadingStatusEnum.error;
      AppSnackbar.show(e.toString());
    }
  }

  @action
  Future<bool> addExerciseToTemplate(String templateId, String exerciseId, int order) async {
    templatesState = LoadingStatusEnum.loading;
    try {
      await _httpClient.post(
        ServiceConfig.templateExercisesUrl(templateId),
        data: {'exercise_id': exerciseId, 'sequence_order': order},
      );
      await fetchTemplateDetails(templateId); // Refresh template structure
      templatesState = LoadingStatusEnum.success;
      return true;
    } catch (e) {
      templatesState = LoadingStatusEnum.error;
      AppSnackbar.show(e.toString());
      return false;
    }
  }

  @action
  Future<void> fetchTemplateDetails(String templateId) async {
    templatesState = LoadingStatusEnum.loading;
    try {
      final response = await _httpClient.get(ServiceConfig.templateByIdUrl(templateId));
      activeTemplate = WorkoutTemplate.fromJson(response);
      templatesState = LoadingStatusEnum.success;
    } catch (e) {
      templatesState = LoadingStatusEnum.error;
      AppSnackbar.show(e.toString());
    }
  }

  @action
  Future<bool> startWorkoutSession(String templateId, String name) async {
    activeWorkoutState = LoadingStatusEnum.loading;
    try {
      final response = await _httpClient.post(
        ServiceConfig.workoutUrl,
        data: {'name': name, 'template_id': templateId},
      );
      activeWorkout = response;
      activeWorkoutState = LoadingStatusEnum.success;
      return true;
    } catch (e) {
      activeWorkoutState = LoadingStatusEnum.error;
      AppSnackbar.show(e.toString());
      return false;
    }
  }

  @action
  Future<bool> logSet(String workoutId, String exerciseId, int reps, double weight) async {
    try {
      await _httpClient.post(
        ServiceConfig.setUrl,
        data: {
          'workout_id': workoutId,
          'exercise_id': exerciseId,
          'reps': reps,
          'weight': weight,
        },
      );
      return true;
    } catch (e) {
      AppSnackbar.show(e.toString());
      return false;
    }
  }

  @action
  Future<void> fetchCalendarWorkouts(String start, String end) async {
    calendarState = LoadingStatusEnum.loading;
    try {
      final response = await _httpClient.get(ServiceConfig.workoutCalendarUrl(start, end));
      if (response is List) {
        calendarWorkouts = response.map((e) => CalendarWorkout.fromJson(e)).toList();
      } else {
        calendarWorkouts = [];
      }
      calendarState = LoadingStatusEnum.success;
    } catch (e) {
      calendarState = LoadingStatusEnum.error;
      AppSnackbar.show(e.toString());
    }
  }

  @action
  Future<void> fetchLiftProgress(String exerciseId) async {
    progressState = LoadingStatusEnum.loading;
    try {
      final response = await _httpClient.get(ServiceConfig.workoutProgressUrl(exerciseId));
      if (response is List) {
        liftProgress = response.map((e) => ProgressDataPoint.fromJson(e)).toList();
      } else {
        liftProgress = [];
      }
      progressState = LoadingStatusEnum.success;
    } catch (e) {
      progressState = LoadingStatusEnum.error;
      AppSnackbar.show(e.toString());
    }
  }
}
