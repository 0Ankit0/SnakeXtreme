import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'utils/app_colors.dart';
import 'screens/splash_screen.dart';

import 'controllers/settings_controller.dart';
import 'services/audio_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Settings & Audio
  await SettingsController().init();
  AudioManager().init();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const SnakeXtremeApp());
}

class SnakeXtremeApp extends StatelessWidget {
  const SnakeXtremeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SnakeXtreme',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.backgroundDark,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.backgroundLight,
        ),
        textTheme: GoogleFonts.outfitTextTheme(
          ThemeData.dark().textTheme,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primary,
          contentTextStyle: GoogleFonts.outfit(
            color: Colors.white,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
