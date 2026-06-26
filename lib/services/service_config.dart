import 'package:dio/dio.dart';
import 'package:fitcamp_flutter/locator.dart';
import 'package:fitcamp_flutter/store/auth_store.dart';

class ServiceConfig {
  static const String serverurl = 'https://fit-camp-backend.vercel.app/api';
  static const String serverImageUrl =
      'https://fit-camp-backend.vercel.app/storage';
  static const String authServiceUrl = serverurl;

  // Auth
  static const String loginUrl = '/auth/login';
  static const String registerUrl = '/auth/register';

  // Profile
  static const String profileUrl = '/profile';
  static const String profileSetupUrl = '/profile/setup';
  static const String profileGoalsUrl = '/profile/goals';
  static const String homeUrl = '/home';

  // Food
  static String foodByBarcodeUrl(String barcode) => '/food/$barcode';
  static const String mealUrl = '/food/meal';
  static String dailyMacrosUrl(String date) => '/food/daily/macros?date=$date';
  static String foodSearchUrl(String query) => '/food/search?q=${Uri.encodeQueryComponent(query)}';

  // Workout
  static const String workoutUrl = '/workout';
  static const String exerciseUrl = '/workout/exercise';
  static const String setUrl = '/workout/set';
  static String workoutByIdUrl(String id) => '/workout/$id';
  static const String programUrl = '/workout/programs';
  static const String templateUrl = '/workout/templates';
  static String templateExercisesUrl(String templateId) => '/workout/templates/$templateId/exercises';
  static String templateByIdUrl(String templateId) => '/workout/templates/$templateId';
  static String workoutCalendarUrl(String start, String end) => '/workout/calendar?start_date=$start&end_date=$end';
  static String workoutProgressUrl(String exerciseId) => '/workout/progress/$exerciseId';

  // AI Suggestions
  static const String aiSuggestionsUrl = '/ai/suggestions';
}

HttpClient? http;

class HttpClient {
  static Map<String, String> requestHeaders = {
    "Content-Type": "application/json",
    "Authorization": "Bearer guest",
  };

  String accessToken = 'guest';
  final Dio authService;

  HttpClient({required this.authService});

  factory HttpClient.init({Map<String, String>? headers}) {
    int timeout = 10000; //ms

    final dio = Dio(
      BaseOptions(
        receiveDataWhenStatusError: true,
        baseUrl: ServiceConfig.serverurl,
        connectTimeout: Duration(milliseconds: timeout),
        receiveTimeout: Duration(milliseconds: timeout),
        headers: headers ?? requestHeaders,
      ),
    );

    http = HttpClient(authService: dio);
    return http!;
  }

  String? parseError(DioException error) {
    // In our project, AuthStore is a singleton instance or from locator
    final AuthStore authStore = locator.get<AuthStore>();

    if (error.response == null) {
      return error.message;
    } else {
      if (error.response!.statusCode == 401) {
        authStore.logout();
        if (error.response!.data is Map) {
          final errVal = error.response!.data['error'] ?? error.response!.data['message'];
          if (errVal != null) return errVal.toString();
        }
        return "Invalid or expired token";
      }
      if (error.response!.statusCode == 500) {
        return error.response!.data is Map
            ? (error.response!.data['error'] ?? error.response!.data['message'] ?? 'Internal Server Error')
            : 'Internal Server Error';
      }
      if (error.response!.statusCode == 403) {
        return error.response!.data is Map
            ? (error.response!.data['error'] ?? error.response!.data['message'] ?? 'Forbidden')
            : 'Forbidden';
      }

      // ... (rest of the error parsing logic but with runtimeType checks)
      if (error.response!.data is Map) {
        final msg = error.response!.data['message'];
        if (msg != null) return msg.toString();

        final err = error.response!.data['error'];
        if (err != null && err is String) return err;
      }

      if (error.response!.data is String) {
        return error.response!.data;
      }

      return 'Something went wrong, please check your internet connection';
    }
  }

  // Helper methods for GET/POST/PUT requests using Dio
  Future<dynamic> get(String path) async {
    try {
      final response = await authService.get(path);
      return _processResponse(response);
    } on DioException catch (e) {
      throw Exception(parseError(e));
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await authService.post(path, data: data);
      return _processResponse(response);
    } on DioException catch (e) {
      throw Exception(parseError(e));
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await authService.put(path, data: data);
      return _processResponse(response);
    } on DioException catch (e) {
      throw Exception(parseError(e));
    }
  }

  dynamic _processResponse(Response response) {
    print("response $response");
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      final data = response.data;
      if (data is Map && data['success'] == true) {
        return data['data'];
      }
      // If it's not our standard success=true format, return data as is if it's successful HTTP
      return data;
    }
    throw Exception('HTTP error ${response.statusCode}');
  }
}
