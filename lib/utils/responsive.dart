import 'package:flutter/material.dart';

class R {
  static late MediaQueryData _mediaQuery;
  static late double _width;
  static late double _height;

  static void init(BuildContext context) {
    _mediaQuery = MediaQuery.of(context);
    _width = _mediaQuery.size.width;
    _height = _mediaQuery.size.height;
  }

  // Screen dimensions
  static double get width => _width;
  static double get height => _height;

  // Responsive width percentage
  static double w(double percent) => _width * percent / 100;

  // Responsive height percentage
  static double h(double percent) => _height * percent / 100;

  // Responsive font size
  static double font(double size) {
    // Base design width = 360dp (most common Android)
    final scale = _width / 360;
    // Clamp so text never gets too tiny or huge
    return (size * scale).clamp(size * 0.8, size * 1.3);
  }

  // Responsive padding/spacing
  static double sp(double size) {
    final scale = _width / 360;
    return (size * scale).clamp(size * 0.7, size * 1.4);
  }

  // Responsive icon size
  static double icon(double size) {
    final scale = _width / 360;
    return (size * scale).clamp(size * 0.8, size * 1.2);
  }

  // Device type helpers
  static bool get isSmall => _width < 360;
  static bool get isMedium => _width >= 360 && _width < 480;
  static bool get isLarge => _width >= 480 && _width < 600;
  static bool get isTablet => _width >= 600;
}
