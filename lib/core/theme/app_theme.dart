import 'package:flutter/material.dart';

class AppTheme {
  // Base colors (will be overridden by wallpaper extraction)
  static const Color primaryPurple = Color(0xFFA020F0);
  static const Color accentCyan = Color(0xFF00D9FF);
  static const Color accentPink = Color(0xFFFF006E);
  static const Color ghostWhite = Color(0xFFF8F8FF);
  
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryPurple,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: accentCyan,
        tertiary: accentPink,
        surface: Color(0xFF1A1A1A),
        background: Colors.black,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: ghostWhite,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: ghostWhite,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: ghostWhite,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: Color(0xFFB0B0B0),
        ),
      ),
      useMaterial3: true,
    );
  }
}

class AppColors {
  // Adaptive colors (changed by wallpaper)
  static Color ghostTint = AppTheme.ghostWhite;
  static Color auraStart = AppTheme.primaryPurple;
  static Color auraEnd = AppTheme.accentCyan;
  static Color particleColor = AppTheme.accentPink;
  
  // Fixed utility colors
  static const Color success = Color(0xFF00FF88);
  static const Color warning = Color(0xFFFFAA00);
  static const Color error = Color(0xFFFF3366);
  
  static LinearGradient get ghostAuraGradient => LinearGradient(
    colors: [auraStart, auraEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double full = 9999;
}