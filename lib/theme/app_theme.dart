import 'package:flutter/material.dart';

enum AppThemeMode { morning, afternoon, night }

class AppTheme {
  static AppThemeMode currentMode = AppThemeMode.night;

  static AppThemeMode getAutoTheme() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return AppThemeMode.morning;
    if (hour >= 12 && hour < 18) return AppThemeMode.afternoon;
    return AppThemeMode.night;
  }

  // Background colors
  static Color get background {
    switch (currentMode) {
      case AppThemeMode.morning:
        return const Color(0xFFFFF8F0);
      case AppThemeMode.afternoon:
        return const Color(0xFFF0F4FF);
      case AppThemeMode.night:
        return const Color(0xFF0A0E21);
    }
  }

  static Color get cardColor {
    switch (currentMode) {
      case AppThemeMode.morning:
        return const Color(0xFFFFEDD8);
      case AppThemeMode.afternoon:
        return const Color(0xFFE0EAFF);
      case AppThemeMode.night:
        return const Color(0xFF1D1E33);
    }
  }

  static Color get primaryColor {
    switch (currentMode) {
      case AppThemeMode.morning:
        return const Color(0xFFFF8C42);
      case AppThemeMode.afternoon:
        return const Color(0xFF4A90E2);
      case AppThemeMode.night:
        return const Color(0xFF6C63FF);
    }
  }

  static Color get accentColor {
    switch (currentMode) {
      case AppThemeMode.morning:
        return const Color(0xFFFFB347);
      case AppThemeMode.afternoon:
        return const Color(0xFF00C9FF);
      case AppThemeMode.night:
        return const Color(0xFF00D2FF);
    }
  }

  static Color get textPrimary {
    switch (currentMode) {
      case AppThemeMode.morning:
        return const Color(0xFF2D1B00);
      case AppThemeMode.afternoon:
        return const Color(0xFF0A1A3A);
      case AppThemeMode.night:
        return Colors.white;
    }
  }

  static Color get textSecondary {
    switch (currentMode) {
      case AppThemeMode.morning:
        return const Color(0xFF8B5E3C);
      case AppThemeMode.afternoon:
        return const Color(0xFF4A6FA5);
      case AppThemeMode.night:
        return const Color(0xFF8A8BB0);
    }
  }

  static List<Color> get gradientColors {
    switch (currentMode) {
      case AppThemeMode.morning:
        return [const Color(0xFFFF8C42), const Color(0xFFFFD700)];
      case AppThemeMode.afternoon:
        return [const Color(0xFF4A90E2), const Color(0xFF00C9FF)];
      case AppThemeMode.night:
        return [const Color(0xFF6C63FF), const Color(0xFF00D2FF)];
    }
  }

  static String get themeIcon {
    switch (currentMode) {
      case AppThemeMode.morning:
        return 'morning';
      case AppThemeMode.afternoon:
        return 'afternoon';
      case AppThemeMode.night:
        return 'night';
    }
  }

  static String get themeName {
    switch (currentMode) {
      case AppThemeMode.morning:
        return 'Morning';
      case AppThemeMode.afternoon:
        return 'Afternoon';
      case AppThemeMode.night:
        return 'Night';
    }
  }
}
