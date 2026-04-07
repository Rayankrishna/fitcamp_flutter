import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'theme/app_theme.dart';
import 'ui/auth/login_page.dart';
import 'shared/app_snackbar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(393, 852), // iPhone 15 size or standard
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'FitCamp',
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: AppSnackbar.messengerKey,
          theme: AppTheme.lightTheme(),
          home: const LoginPage(),
        );
      },
    );
  }
}
