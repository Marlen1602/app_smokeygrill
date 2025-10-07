import 'package:flutter/material.dart';

class AppColors {
  // Colores principales
  static const Color primary = Color(0xFFF97316);
  static const Color secondary = Color(0xFFEA580C);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  // Estados
  static const Color prepBackground = Color(0xFFFEF3C7);
  static const Color prepText = Color(0xFF92400E);

  static const Color readyBackground = Color(0xFFD1FAE5);
  static const Color readyText = Color(0xFF065F46);

  static const Color deliveredBackground = Color(0xFFDBEAFE);
  static const Color deliveredText = Color(0xFF1E40AF);

  static const Color error = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.white,
      fontFamily: 'Inter', // asegúrate de agregar Inter en pubspec.yaml
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
            fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 24),
        headlineMedium: TextStyle(
            fontFamily: 'Inter', fontWeight: FontWeight.bold, fontSize: 20),
        titleMedium: TextStyle(
            fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 16),
        bodyMedium: TextStyle(
            fontFamily: 'Inter', fontWeight: FontWeight.normal, fontSize: 14),
        labelLarge: TextStyle(
            fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
              fontFamily: 'Inter', fontWeight: FontWeight.w500, fontSize: 14),
        ),
      ),
    );
  }
}
