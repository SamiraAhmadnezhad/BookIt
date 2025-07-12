
import 'package:bookit/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Vazirmatn',
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primaryLight,
        onPrimary: AppColors.white,
        background: AppColors.white,
        onBackground: AppColors.black,
        surface: AppColors.lightGrey,
        onSurface: AppColors.black,
        error: Colors.redAccent,
        onError: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.primary, fontWeight: FontWeight.w900),
        bodyMedium: TextStyle(fontFamily: 'Vazirmatn', color: AppColors.darkGrey),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.lightGrey,
        circularTrackColor: AppColors.lightGrey,
      ),
    );
  }
}