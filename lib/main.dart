import 'package:fitcamp_flutter/locator.dart';
import 'package:fitcamp_flutter/storage_manager.dart';
import 'package:fitcamp_flutter/store/auth_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'ui/auth/login_page.dart';
import 'ui/home/home_page.dart';
import 'shared/app_snackbar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  final prefs = await SharedPreferences.getInstance();
  StorageManager.init(prefs);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthStore _homeStore = AuthStore.instance;

    _homeStore.getStoredValues();

    return ScreenUtilInit(
      designSize: const Size(393, 852), // iPhone 15 size or standard
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Observer(
          builder: (_) {
            return MaterialApp(
              title: 'FitCamp',
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: AppSnackbar.messengerKey,
              theme: AppTheme.lightTheme(),
              home: _homeStore.accessToken != null ? const HomePage() : const LoginPage(),
            );
          },
        );
      },
    );
  }
}
