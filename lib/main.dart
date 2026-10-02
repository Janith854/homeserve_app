import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homeserve_app/firebase_options.dart';
import 'package:homeserve_app/routes/app_router.dart';
import 'package:homeserve_app/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (safely catch if running on unsupported web/desktop platforms during testing)
  try {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      await Firebase.initializeApp();
    }
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const HomeServeApp());
}

class HomeServeApp extends StatelessWidget {
  const HomeServeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'HomeServe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.surface,
          error: AppColors.danger,
        ),
        fontFamily: 'Inter',
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}
