// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AuthStore on _AuthStoreBase, Store {
  Computed<bool>? _$isLoadingComputed;

  @override
  bool get isLoading =>
      (_$isLoadingComputed ??= Computed<bool>(
            () => super.isLoading,
            name: '_AuthStoreBase.isLoading',
          ))
          .value;

  late final _$loginStateAtom = Atom(
    name: '_AuthStoreBase.loginState',
    context: context,
  );

  @override
  LoadingStatusEnum get loginState {
    _$loginStateAtom.reportRead();
    return super.loginState;
  }

  @override
  set loginState(LoadingStatusEnum value) {
    _$loginStateAtom.reportWrite(value, super.loginState, () {
      super.loginState = value;
    });
  }

  late final _$registerStateAtom = Atom(
    name: '_AuthStoreBase.registerState',
    context: context,
  );

  @override
  LoadingStatusEnum get registerState {
    _$registerStateAtom.reportRead();
    return super.registerState;
  }

  @override
  set registerState(LoadingStatusEnum value) {
    _$registerStateAtom.reportWrite(value, super.registerState, () {
      super.registerState = value;
    });
  }

  late final _$homeDataStateAtom = Atom(
    name: '_AuthStoreBase.homeDataState',
    context: context,
  );

  @override
  LoadingStatusEnum get homeDataState {
    _$homeDataStateAtom.reportRead();
    return super.homeDataState;
  }

  @override
  set homeDataState(LoadingStatusEnum value) {
    _$homeDataStateAtom.reportWrite(value, super.homeDataState, () {
      super.homeDataState = value;
    });
  }

  late final _$profileUpdateStateAtom = Atom(
    name: '_AuthStoreBase.profileUpdateState',
    context: context,
  );

  @override
  LoadingStatusEnum get profileUpdateState {
    _$profileUpdateStateAtom.reportRead();
    return super.profileUpdateState;
  }

  @override
  set profileUpdateState(LoadingStatusEnum value) {
    _$profileUpdateStateAtom.reportWrite(value, super.profileUpdateState, () {
      super.profileUpdateState = value;
    });
  }

  late final _$goalsUpdateStateAtom = Atom(
    name: '_AuthStoreBase.goalsUpdateState',
    context: context,
  );

  @override
  LoadingStatusEnum get goalsUpdateState {
    _$goalsUpdateStateAtom.reportRead();
    return super.goalsUpdateState;
  }

  @override
  set goalsUpdateState(LoadingStatusEnum value) {
    _$goalsUpdateStateAtom.reportWrite(value, super.goalsUpdateState, () {
      super.goalsUpdateState = value;
    });
  }

  late final _$accessTokenAtom = Atom(
    name: '_AuthStoreBase.accessToken',
    context: context,
  );

  @override
  String? get accessToken {
    _$accessTokenAtom.reportRead();
    return super.accessToken;
  }

  @override
  set accessToken(String? value) {
    _$accessTokenAtom.reportWrite(value, super.accessToken, () {
      super.accessToken = value;
    });
  }

  late final _$homeDataAtom = Atom(
    name: '_AuthStoreBase.homeData',
    context: context,
  );

  @override
  HomeDetailsModel? get homeData {
    _$homeDataAtom.reportRead();
    return super.homeData;
  }

  @override
  set homeData(HomeDetailsModel? value) {
    _$homeDataAtom.reportWrite(value, super.homeData, () {
      super.homeData = value;
    });
  }

  late final _$errorMessageAtom = Atom(
    name: '_AuthStoreBase.errorMessage',
    context: context,
  );

  @override
  String? get errorMessage {
    _$errorMessageAtom.reportRead();
    return super.errorMessage;
  }

  @override
  set errorMessage(String? value) {
    _$errorMessageAtom.reportWrite(value, super.errorMessage, () {
      super.errorMessage = value;
    });
  }

  late final _$isAuthenticatedAtom = Atom(
    name: '_AuthStoreBase.isAuthenticated',
    context: context,
  );

  @override
  bool get isAuthenticated {
    _$isAuthenticatedAtom.reportRead();
    return super.isAuthenticated;
  }

  @override
  set isAuthenticated(bool value) {
    _$isAuthenticatedAtom.reportWrite(value, super.isAuthenticated, () {
      super.isAuthenticated = value;
    });
  }

  late final _$aiSuggestionsAtom = Atom(
    name: '_AuthStoreBase.aiSuggestions',
    context: context,
  );

  @override
  Map<String, dynamic>? get aiSuggestions {
    _$aiSuggestionsAtom.reportRead();
    return super.aiSuggestions;
  }

  @override
  set aiSuggestions(Map<String, dynamic>? value) {
    _$aiSuggestionsAtom.reportWrite(value, super.aiSuggestions, () {
      super.aiSuggestions = value;
    });
  }

  late final _$dailyMacrosAtom = Atom(
    name: '_AuthStoreBase.dailyMacros',
    context: context,
  );

  @override
  Map<String, dynamic>? get dailyMacros {
    _$dailyMacrosAtom.reportRead();
    return super.dailyMacros;
  }

  @override
  set dailyMacros(Map<String, dynamic>? value) {
    _$dailyMacrosAtom.reportWrite(value, super.dailyMacros, () {
      super.dailyMacros = value;
    });
  }

  late final _$workoutsAtom = Atom(
    name: '_AuthStoreBase.workouts',
    context: context,
  );

  @override
  List<dynamic>? get workouts {
    _$workoutsAtom.reportRead();
    return super.workouts;
  }

  @override
  set workouts(List<dynamic>? value) {
    _$workoutsAtom.reportWrite(value, super.workouts, () {
      super.workouts = value;
    });
  }

  late final _$profileDataAtom = Atom(
    name: '_AuthStoreBase.profileData',
    context: context,
  );

  @override
  Map<String, dynamic>? get profileData {
    _$profileDataAtom.reportRead();
    return super.profileData;
  }

  @override
  set profileData(Map<String, dynamic>? value) {
    _$profileDataAtom.reportWrite(value, super.profileData, () {
      super.profileData = value;
    });
  }

  late final _$checkAuthAsyncAction = AsyncAction(
    '_AuthStoreBase.checkAuth',
    context: context,
  );

  @override
  Future<void> checkAuth() {
    return _$checkAuthAsyncAction.run(() => super.checkAuth());
  }

  late final _$loginAsyncAction = AsyncAction(
    '_AuthStoreBase.login',
    context: context,
  );

  @override
  Future<bool> login(String email, String password) {
    return _$loginAsyncAction.run(() => super.login(email, password));
  }

  late final _$registerAsyncAction = AsyncAction(
    '_AuthStoreBase.register',
    context: context,
  );

  @override
  Future<bool> register(String email, String password) {
    return _$registerAsyncAction.run(() => super.register(email, password));
  }

  late final _$fetchHomeDataAsyncAction = AsyncAction(
    '_AuthStoreBase.fetchHomeData',
    context: context,
  );

  @override
  Future<void> fetchHomeData() {
    return _$fetchHomeDataAsyncAction.run(() => super.fetchHomeData());
  }

  late final _$updateGoalsAsyncAction = AsyncAction(
    '_AuthStoreBase.updateGoals',
    context: context,
  );

  @override
  Future<bool> updateGoals({int? calorieGoal, int? proteinGoal, int? fatGoal}) {
    return _$updateGoalsAsyncAction.run(
      () => super.updateGoals(
        calorieGoal: calorieGoal,
        proteinGoal: proteinGoal,
        fatGoal: fatGoal,
      ),
    );
  }

  late final _$updateProfileAsyncAction = AsyncAction(
    '_AuthStoreBase.updateProfile',
    context: context,
  );

  @override
  Future<bool> updateProfile({int? height, int? weight, int? age}) {
    return _$updateProfileAsyncAction.run(
      () => super.updateProfile(height: height, weight: weight, age: age),
    );
  }

  late final _$fetchDailyMacrosAsyncAction = AsyncAction(
    '_AuthStoreBase.fetchDailyMacros',
    context: context,
  );

  @override
  Future<void> fetchDailyMacros() {
    return _$fetchDailyMacrosAsyncAction.run(() => super.fetchDailyMacros());
  }

  late final _$fetchWorkoutsAsyncAction = AsyncAction(
    '_AuthStoreBase.fetchWorkouts',
    context: context,
  );

  @override
  Future<void> fetchWorkouts() {
    return _$fetchWorkoutsAsyncAction.run(() => super.fetchWorkouts());
  }

  late final _$fetchProfileAsyncAction = AsyncAction(
    '_AuthStoreBase.fetchProfile',
    context: context,
  );

  @override
  Future<void> fetchProfile() {
    return _$fetchProfileAsyncAction.run(() => super.fetchProfile());
  }

  @override
  String toString() {
    return '''
loginState: ${loginState},
registerState: ${registerState},
homeDataState: ${homeDataState},
profileUpdateState: ${profileUpdateState},
goalsUpdateState: ${goalsUpdateState},
accessToken: ${accessToken},
homeData: ${homeData},
errorMessage: ${errorMessage},
isAuthenticated: ${isAuthenticated},
aiSuggestions: ${aiSuggestions},
dailyMacros: ${dailyMacros},
workouts: ${workouts},
profileData: ${profileData},
isLoading: ${isLoading}
    ''';
  }
}
