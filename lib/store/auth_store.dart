// ignore_for_file: library_private_types_in_public_api
import 'package:fitcamp_flutter/models/home_details_model.dart';
import 'package:fitcamp_flutter/shared/enums.dart';
import 'package:fitcamp_flutter/shared/app_snackbar.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_provider.dart';
import '../services/service_config.dart';

part 'auth_store.g.dart';

class AuthStore extends _AuthStoreBase with _$AuthStore {
  static final AuthStore instance = AuthStore();
}

abstract class _AuthStoreBase with Store {
  final ApiProvider _apiProvider = ApiProvider();

  @observable
  LoadingStatusEnum loginState = LoadingStatusEnum.initial;

  @observable
  LoadingStatusEnum registerState = LoadingStatusEnum.initial;

  @observable
  LoadingStatusEnum homeDataState = LoadingStatusEnum.initial;

  @observable
  LoadingStatusEnum profileUpdateState = LoadingStatusEnum.initial;

  @observable
  LoadingStatusEnum goalsUpdateState = LoadingStatusEnum.initial;

  @computed
  bool get isLoading =>
      loginState == LoadingStatusEnum.loading ||
      registerState == LoadingStatusEnum.loading ||
      homeDataState == LoadingStatusEnum.loading ||
      profileUpdateState == LoadingStatusEnum.loading ||
      goalsUpdateState == LoadingStatusEnum.loading;

  @observable
  String? accessToken;

  @observable
  HomeDetailsModel? homeData;

  @observable
  String? errorMessage;

  @observable
  bool isAuthenticated = false;

  @observable
  Map<String, dynamic>? aiSuggestions;

  @observable
  Map<String, dynamic>? dailyMacros;

  @observable
  List<dynamic>? workouts;

  @observable
  Map<String, dynamic>? profileData;

  @action
  Future<void> checkAuth() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString('access_token');
    isAuthenticated = accessToken != null;
  }

  @action
  Future<bool> login(String email, String password) async {
    loginState = LoadingStatusEnum.loading;
    errorMessage = null;

    try {
      var dto = {'email': email, 'password': password};
      final response = await _apiProvider.post(ServiceConfig.loginUrl, body: dto);

      final token = response['session']?['access_token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        accessToken = token;
        isAuthenticated = true;
        loginState = LoadingStatusEnum.success;
        return true;
      } else {
        loginState = LoadingStatusEnum.error;
        AppSnackbar.show('Login failed: Token not found');
        return false;
      }
    } catch (e) {
      loginState = LoadingStatusEnum.error;
      errorMessage = e.toString();
      AppSnackbar.show(errorMessage ?? 'Login error');
      return false;
    }
  }

  @action
  Future<bool> register(String email, String password) async {
    registerState = LoadingStatusEnum.loading;
    errorMessage = null;

    try {
      var dto = {'email': email, 'password': password};
      final response = await _apiProvider.post(ServiceConfig.registerUrl, body: dto);
      final token = response['session']?['access_token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        accessToken = token;
        isAuthenticated = true;
        registerState = LoadingStatusEnum.success;
        return true;
      } else {
        registerState = LoadingStatusEnum.error;
        AppSnackbar.show('Registration failed');
        return false;
      }
    } catch (e) {
      registerState = LoadingStatusEnum.error;
      errorMessage = e.toString();
      AppSnackbar.show(errorMessage ?? 'Registration error');
      return false;
    }
  }

  @action
  Future<void> fetchHomeData() async {
    homeDataState = LoadingStatusEnum.loading;
    errorMessage = null;

    try {
      final response = await _apiProvider.get(ServiceConfig.homeUrl);
      homeData = HomeDetailsModel.fromJson(response);
      homeDataState = LoadingStatusEnum.success;
    } catch (e) {
      homeDataState = LoadingStatusEnum.error;
      errorMessage = e.toString();
      AppSnackbar.show(errorMessage ?? 'Error fetching home data');
    }
  }

  @action
  Future<bool> updateGoals({int? calorieGoal, int? proteinGoal, int? fatGoal}) async {
    goalsUpdateState = LoadingStatusEnum.loading;
    errorMessage = null;

    try {
      var dto = <String, dynamic>{};
      if (calorieGoal != null) dto['calorie_goal'] = calorieGoal;
      if (proteinGoal != null) dto['protein_goal'] = proteinGoal;
      if (fatGoal != null) dto['fat_goal'] = fatGoal;

      await _apiProvider.post(ServiceConfig.profileGoalsUrl, body: dto);
      await fetchHomeData(); // Refresh data
      goalsUpdateState = LoadingStatusEnum.success;
      return true;
    } catch (e) {
      goalsUpdateState = LoadingStatusEnum.error;
      errorMessage = e.toString();
      AppSnackbar.show(errorMessage ?? 'Error updating goals');
      return false;
    }
  }

  @action
  Future<bool> updateProfile({int? height, int? weight, int? age}) async {
    profileUpdateState = LoadingStatusEnum.loading;
    errorMessage = null;

    try {
      var dto = <String, dynamic>{};
      if (height != null) dto['height'] = height;
      if (weight != null) dto['weight'] = weight;
      if (age != null) dto['age'] = age;

      await _apiProvider.post(ServiceConfig.profileSetupUrl, body: dto);
      await fetchHomeData(); // Refresh data
      profileUpdateState = LoadingStatusEnum.success;
      return true;
    } catch (e) {
      profileUpdateState = LoadingStatusEnum.error;
      errorMessage = e.toString();
      AppSnackbar.show(errorMessage ?? 'Error updating profile');
      return false;
    }
  }

  @action
  Future<void> fetchDailyMacros() async {
    errorMessage = null;

    try {
      final String today = DateTime.now().toIso8601String().split('T')[0];
      final response = await _apiProvider.get(
        ServiceConfig.dailyMacrosUrl(today),
      );
      dailyMacros = response;
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  @action
  Future<void> fetchWorkouts() async {
    errorMessage = null;

    try {
      final response = await _apiProvider.get(ServiceConfig.workoutUrl);
      if (response is List) {
        workouts = response;
      } else {
        workouts = [response];
      }
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  @action
  Future<void> fetchProfile() async {
    errorMessage = null;

    try {
      final response = await _apiProvider.get(ServiceConfig.profileUrl);
      profileData = response;
    } catch (e) {
      errorMessage = e.toString();
    }
  }
}
