import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum AppThemeMode { morning, afternoon, night }

class AppTheme {
  static AppThemeMode currentMode = AppThemeMode.night;

  static AppThemeMode getAutoTheme() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 12) return AppThemeMode.morning;
    if (hour >= 12 && hour < 18) return AppThemeMode.afternoon;
    return AppThemeMode.night;
  }

  // FIX 1: Status bar color adapts to theme
  static void applyStatusBar() {
    if (currentMode == AppThemeMode.night) {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ));
    } else {
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ));
    }
  }

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
        return const Color(0xFFFFFFFF);
      case AppThemeMode.afternoon:
        return const Color(0xFFFFFFFF);
      case AppThemeMode.night:
        return const Color(0xFF1D1E33);
    }
  }

  static Color get textPrimary {
    switch (currentMode) {
      case AppThemeMode.morning:
        return const Color(0xFF1A1A2E);
      case AppThemeMode.afternoon:
        return const Color(0xFF1A1A2E);
      case AppThemeMode.night:
        return const Color(0xFFFFFFFF);
    }
  }

  static Color get textSecondary {
    switch (currentMode) {
      case AppThemeMode.morning:
        return const Color(0xFF666680);
      case AppThemeMode.afternoon:
        return const Color(0xFF666680);
      case AppThemeMode.night:
        return const Color(0xFF8A8BB0);
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
        return const Color(0xFFFFD700);
      case AppThemeMode.afternoon:
        return const Color(0xFF00C9FF);
      case AppThemeMode.night:
        return const Color(0xFF00D2FF);
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
}
