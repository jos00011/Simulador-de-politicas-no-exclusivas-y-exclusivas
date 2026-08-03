// lib/core/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  static const Color bgDeep = Color(0xFF08080E);
  static const Color bgCard = Color(0xFF12121E);
  static const Color bgElevated = Color(0xFF1A1A2E);
  static const Color borderDark = Color(0xFF2A2A44);

  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonPink = Color(0xFFFF007F);
  static const Color neonAmber = Color(0xFFFFB300);
  static const Color neonGreen = Color(0xFF00FF88);
  static const Color neonPurple = Color(0xFFB388FF);
  static const Color neonOrange = Color(0xFFFF6D00);
  static const Color neonRed = Color(0xFFFF1744);

  static const Color textPrimary = Color(0xFFF0F0F0);
  static const Color textSecondary = Color(0xFF8899BB);
  static const Color textDim = Color(0xFF445566);

  static const LinearGradient gradientCyanPink = LinearGradient(
    colors: [neonCyan, neonPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static BoxDecoration glassCard({
    Color? borderColor,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: (borderColor ?? neonCyan).withValues(alpha: 0.15),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: (borderColor ?? neonCyan).withValues(alpha: 0.08),
          blurRadius: 30,
          spreadRadius: -8,
        ),
      ],
    );
  }

  static const List<Color> vibrantColors = [
    neonCyan, neonPink, neonAmber, neonGreen, neonPurple,
    neonOrange, neonRed, Color(0xFF00E5FF), Color(0xFFFF4081),
    Color(0xFFFFAB00), Color(0xFF69F0AE), Color(0xFFB39DDB),
    Color(0xFFFF6E40), Color(0xFFFF5252), Color(0xFF18FFFF),
    Color(0xFFEA80FC),
  ];

  static Color processColor(String id) {
    int hash = 0;
    for (int i = 0; i < id.length; i++) {
      hash = (hash * 31 + id.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return vibrantColors[hash.abs() % vibrantColors.length];
  }

  static Color processColorByIndex(int index) {
    return vibrantColors[index % vibrantColors.length];
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgDeep,
      primaryColor: neonCyan,
      colorScheme: const ColorScheme.dark(
        primary: neonCyan,
        secondary: neonPink,
        surface: bgCard,
        error: neonRed,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.04)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgElevated,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: borderDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neonCyan, width: 2),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textDim),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonCyan,
          foregroundColor: bgDeep,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, letterSpacing: 1.2),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontSize: 28, fontWeight: FontWeight.w200, letterSpacing: 6, color: textPrimary),
        headlineMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, letterSpacing: 2, color: textPrimary),
        bodyLarge: TextStyle(color: textPrimary, fontSize: 14),
        bodyMedium: TextStyle(color: textSecondary, fontSize: 13),
        labelLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
      ),
      dividerTheme: const DividerThemeData(color: borderDark, thickness: 1),
      iconTheme: const IconThemeData(color: textSecondary, size: 20),
      sliderTheme: SliderThemeData(
        activeTrackColor: neonCyan,
        inactiveTrackColor: borderDark,
        thumbColor: neonCyan,
        overlayColor: neonCyan.withValues(alpha: 0.2),
        trackHeight: 3,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
      ),
    );
  }
}