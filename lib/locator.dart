import 'package:get_it/get_it.dart';
import 'store/auth_store.dart';
import 'store/workout_store.dart';

final locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AuthStore.instance);
  locator.registerLazySingleton(() => WorkoutStore.instance);
}
