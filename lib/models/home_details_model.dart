class HomeDetailsModel {
  final PersonalInfoModel? personalInfo;
  final GoalsModel? goals;
  final FoodSummaryModel? foodSummary;
  final WorkoutSummaryModel? workoutSummary;

  HomeDetailsModel({
    this.personalInfo,
    this.goals,
    this.foodSummary,
    this.workoutSummary,
  });

  factory HomeDetailsModel.fromJson(Map<String, dynamic> json) {
    return HomeDetailsModel(
      personalInfo: json['personal_info'] != null ? PersonalInfoModel.fromJson(json['personal_info']) : null,
      goals: json['goals'] != null ? GoalsModel.fromJson(json['goals']) : null,
      foodSummary: json['food_summary'] != null ? FoodSummaryModel.fromJson(json['food_summary']) : null,
      workoutSummary: json['workout_summary'] != null ? WorkoutSummaryModel.fromJson(json['workout_summary']) : null,
    );
  }
}

class PersonalInfoModel {
  final String? email;
  final dynamic height;
  final dynamic weight;
  final int? age;
  final String? description;

  PersonalInfoModel({this.email, this.height, this.weight, this.age, this.description});

  factory PersonalInfoModel.fromJson(Map<String, dynamic> json) {
    return PersonalInfoModel(
      email: json['email'],
      height: json['height'],
      weight: json['weight'],
      age: json['age'],
      description: json['description'],
    );
  }
}

class GoalsModel {
  final double? calorieGoal;
  final double? proteinGoal;
  final double? fatGoal;
  final double? carbsGoal;

  GoalsModel({this.calorieGoal, this.proteinGoal, this.fatGoal, this.carbsGoal});

  factory GoalsModel.fromJson(Map<String, dynamic> json) {
    return GoalsModel(
      calorieGoal: _toDouble(json['calorie_goal']),
      proteinGoal: _toDouble(json['protein_goal']),
      fatGoal: _toDouble(json['fat_goal']),
      carbsGoal: _toDouble(json['carbs_goal']),
    );
  }

  static double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }
}

class FoodSummaryModel {
  final String? date;
  final double? totalCalories;
  final double? totalProtein;
  final double? totalCarbs;
  final double? totalFat;
  final int? itemCount;

  FoodSummaryModel({this.date, this.totalCalories, this.totalProtein, this.totalCarbs, this.totalFat, this.itemCount});

  factory FoodSummaryModel.fromJson(Map<String, dynamic> json) {
    return FoodSummaryModel(
      date: json['date'],
      totalCalories: (json['total_calories'] ?? 0).toDouble(),
      totalProtein: (json['total_protein'] ?? 0).toDouble(),
      totalCarbs: (json['total_carbs'] ?? 0).toDouble(),
      totalFat: (json['total_fat'] ?? 0).toDouble(),
      itemCount: json['item_count'],
    );
  }
}

class WorkoutSummaryModel {
  final String? date;
  final List<dynamic>? workouts;
  final int? count;

  WorkoutSummaryModel({this.date, this.workouts, this.count});

  factory WorkoutSummaryModel.fromJson(Map<String, dynamic> json) {
    return WorkoutSummaryModel(
      date: json['date'],
      workouts: json['workouts'],
      count: json['count'],
    );
  }
}
