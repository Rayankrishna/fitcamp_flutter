// ignore_for_file: library_private_types_in_public_api
import 'package:fitcamp_flutter/models/home_details_model.dart';
import 'package:fitcamp_flutter/shared/enums.dart';
import 'package:fitcamp_flutter/shared/app_snackbar.dart';
import 'package:fitcamp_flutter/storage_manager.dart';
import 'package:mobx/mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/service_config.dart';

part 'auth_store.g.dart';

class AuthStore extends _AuthStoreBase with _$AuthStore {
  static final AuthStore instance = AuthStore();
}

abstract class _AuthStoreBase with Store {
  HttpClient get _httpClient => http ?? HttpClient.init();

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
      final response = await _httpClient.post(
        ServiceConfig.loginUrl,
        data: dto,
      );

      final token = response['session']?['access_token'];

      if (token != null) {
        await StorageManager.instance!.saveStringValue(
          StorageManager.xToken,
          token,
        );
        accessToken = token;
        isAuthenticated = true;

        // Re-initialize HttpClient with the new token
        HttpClient.init(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

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
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await StorageManager.instance!.saveStringValue(StorageManager.xToken, "");
    accessToken = null;
    isAuthenticated = false;

    // Reset HttpClient to guest
    HttpClient.init();
  }

  @action
  Future<bool> register({
    required String email,
    required String password,
    required double height,
    required double weight,
    required int age,
    required String activityLevel,
    required String dietGoal,
  }) async {
    registerState = LoadingStatusEnum.loading;
    errorMessage = null;

    try {
      var dto = {
        'email': email,
        'password': password,
        'height': height,
        'weight': weight,
        'age': age,
        'activity_level': activityLevel,
        'diet_goal': dietGoal,
      };
      final response = await _httpClient.post(
        ServiceConfig.registerUrl,
        data: dto,
      );
      final token = response['session']?['access_token'];

      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', token);
        await StorageManager.instance!.saveStringValue(
          StorageManager.xToken,
          token,
        );
        accessToken = token;
        isAuthenticated = true;

        // Re-initialize HttpClient with the new token
        HttpClient.init(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );

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
      final results = await Future.wait([
        _httpClient.get(ServiceConfig.homeUrl),
        _httpClient.get(ServiceConfig.profileUrl),
      ]);
      homeData = HomeDetailsModel.fromJson(results[0]);
      profileData = results[1] as Map<String, dynamic>?;
      print("fetchHomeData success, profileData: $profileData");
      homeDataState = LoadingStatusEnum.success;
    } catch (e) {
      homeDataState = LoadingStatusEnum.error;
      errorMessage = e.toString();
      AppSnackbar.show(errorMessage ?? 'Error fetching home data');
    }
  }

  @action
  Future<bool> updateGoals({
    int? calorieGoal,
    int? proteinGoal,
    int? fatGoal,
  }) async {
    goalsUpdateState = LoadingStatusEnum.loading;
    errorMessage = null;

    try {
      var dto = <String, dynamic>{};
      if (calorieGoal != null) dto['calorie_goal'] = calorieGoal;
      if (proteinGoal != null) dto['protein_goal'] = proteinGoal;
      if (fatGoal != null) dto['fat_goal'] = fatGoal;

      await _httpClient.post(ServiceConfig.profileGoalsUrl, data: dto);
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
  Future<bool> updateProfile({
    double? height,
    double? weight,
    int? age,
    String? activityLevel,
    String? dietGoal,
  }) async {
    profileUpdateState = LoadingStatusEnum.loading;
    errorMessage = null;

    try {
      var dto = <String, dynamic>{};
      if (height != null) dto['height'] = height;
      if (weight != null) dto['weight'] = weight;
      if (age != null) dto['age'] = age;
      if (activityLevel != null) dto['activity_level'] = activityLevel;
      if (dietGoal != null) dto['diet_goal'] = dietGoal;

      await _httpClient.put(ServiceConfig.profileUrl, data: dto);
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
      final response = await _httpClient.get(
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
    print("fetchWorkouts response ");

    try {
      final today = DateTime.now();
      final start = DateTime(today.year - 1, today.month, today.day).toIso8601String().split('T')[0];
      final end = DateTime(today.year + 1, today.month, today.day).toIso8601String().split('T')[0];
      
      final response = await _httpClient.get(ServiceConfig.workoutCalendarUrl(start, end));
      print("fetchWorkouts response $response");
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
      final response = await _httpClient.get(ServiceConfig.profileUrl);
      profileData = response;
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  @action
  Future<Map<String, dynamic>?> lookupFoodByBarcode(String barcode) async {
    errorMessage = null;
    try {
      final response = await _httpClient.get(ServiceConfig.foodByBarcodeUrl(barcode));
      return response;
    } catch (e) {
      errorMessage = e.toString();
      AppSnackbar.show(errorMessage ?? 'Error looking up barcode');
      return null;
    }
  }

  @action
  Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    errorMessage = null;
    try {
      final response = await _httpClient.get(ServiceConfig.foodSearchUrl(query));
      if (response is List) {
        return List<Map<String, dynamic>>.from(
          response.map((x) => Map<String, dynamic>.from(x as Map)),
        );
      }
      return [];
    } catch (e) {
      errorMessage = e.toString();
      AppSnackbar.show(errorMessage ?? 'Error searching food');
      return [];
    }
  }

  @action
  Future<Map<String, dynamic>?> createCustomFood({
    required String name,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    double fiber = 0.0,
    String? barcode,
  }) async {
    errorMessage = null;
    try {
      final payload = {
        'name': name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        if (barcode != null) 'barcode': barcode,
      };
      final response = await _httpClient.post('/food', data: payload);
      return response;
    } catch (e) {
      errorMessage = e.toString();
      AppSnackbar.show(errorMessage ?? 'Error creating custom food');
      return null;
    }
  }

  @action
  Future<bool> logMeal(List<Map<String, dynamic>> items) async {
    errorMessage = null;
    try {
      final String today = DateTime.now().toIso8601String().split('T')[0];
      final payload = {
        'date': today,
        'items': items,
      };
      await _httpClient.post(ServiceConfig.mealUrl, data: payload);
      await fetchDailyMacros(); // Refresh macros
      await fetchHomeData(); // Refresh home dashboard macros
      return true;
    } catch (e) {
      errorMessage = e.toString();
      AppSnackbar.show(errorMessage ?? 'Error logging meal');
      return false;
    }
  }

  @action
  Future<void> getStoredValues() async {
    // Check if StorageManager is initialized
    if (StorageManager.instance == null) {
      return;
    }

    String? _token = StorageManager.instance!.getStringValue(
      StorageManager.xToken,
    );

    if (_token != null && _token.isNotEmpty) {
      accessToken = _token;
      isAuthenticated = true;
      // Initialize HttpClient with the stored token
      HttpClient.init(
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_token',
        },
      );
    }
  }
}
