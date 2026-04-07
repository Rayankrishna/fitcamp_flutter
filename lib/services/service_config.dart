class ServiceConfig {
  static const String baseUrl = 'https://fit-camp-backend.vercel.app/api';

  // Auth
  static const String loginUrl = '$baseUrl/auth/login';
  static const String registerUrl = '$baseUrl/auth/register';

  static const String profileUrl = '$baseUrl/profile';
  static const String profileSetupUrl = '$baseUrl/profile/setup';
  static const String profileGoalsUrl = '$baseUrl/profile/goals';
  static const String homeUrl = '$baseUrl/home';

  // Food
  static String foodByBarcodeUrl(String barcode) => '$baseUrl/food/$barcode';
  static const String mealUrl = '$baseUrl/food/meal';
  static String dailyMacrosUrl(String date) =>
      '$baseUrl/food/daily/macros?date=$date';

  // Workout
  static const String workoutUrl = '$baseUrl/workout';
  static const String exerciseUrl = '$baseUrl/workout/exercise';
  static const String setUrl = '$baseUrl/workout/set';
  static String workoutByIdUrl(String id) => '$baseUrl/workout/$id';

  // AI Suggestions
  static const String aiSuggestionsUrl = '$baseUrl/ai/suggestions';
}
