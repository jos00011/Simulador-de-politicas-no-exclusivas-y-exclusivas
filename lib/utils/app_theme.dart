// lib/utils/app_theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Vintage Dark Palette
  static const Color bg = Color(0xFF0D0D0D);
  static const Color bgCard = Color(0xFF161616);
  static const Color bgElevated = Color(0xFF1E1E1E);
  static const Color border = Color(0xFF2A2A2A);
  static const Color borderAccent = Color(0xFF3D3D2A);

  // Vintage Amber / Sepia Accents
  static const Color amber = Color(0xFFD4A843);
  static const Color amberLight = Color(0xFFF0C84A);
  static const Color amberDim = Color(0xFF7A5A1A);
  static const Color cream = Color(0xFFF2E8C6);
  static const Color sepia = Color(0xFFA08050);
  static const Color rust = Color(0xFFC0522A);

  // Process colors — 16 distinct colors, well spaced
  static const List<Color> processColors = [
    Color(0xFFD4A843), // amber
    Color(0xFF4ECDC4), // teal
    Color(0xFFE07060), // coral
    Color(0xFF7BC86C), // sage green
    Color(0xFF9B8EC4), // lavender
    Color(0xFFE8A04A), // orange
    Color(0xFF5BA4CF), // steel blue
    Color(0xFFD175A0), // rose
    Color(0xFF82C099), // mint
    Color(0xFFCB8F3E), // gold
    Color(0xFF6EC6E6), // sky blue
    Color(0xFFE6956E), // peach
    Color(0xFFB5D86E), // lime
    Color(0xFFB06EC6), // purple
    Color(0xFF6EB5D8), // cerulean
    Color(0xFFD86E6E), // red
  ];

  /// Assigns color based on the full ID string (hash), not just first char.
  /// This ensures A, B, C, D... all get different colors.
  static Color processColor(String id) {
    // Use a hash of the full string for better distribution
    int hash = 0;
    for (int i = 0; i < id.length; i++) {
      hash = (hash * 31 + id.codeUnitAt(i)) & 0xFFFFFFFF;
    }
    return processColors[hash.abs() % processColors.length];
  }

  /// Returns color by sequential index — use when you have an ordered list
  static Color processColorByIndex(int index) {
    return processColors[index % processColors.length];
  }

  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bg,
        colorScheme: const ColorScheme.dark(
          primary: amber,
          secondary: amberLight,
          surface: bgCard,
          error: rust,
        ),
        cardTheme: CardThemeData(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: const BorderSide(color: border),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgElevated,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide: const BorderSide(color: amber),
          ),
          labelStyle: const TextStyle(color: sepia),
          hintStyle: const TextStyle(color: Color(0x80A08050)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: amber,
            foregroundColor: bg,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, letterSpacing: 1.2),
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: cream, fontSize: 28, fontWeight: FontWeight.w300, letterSpacing: 4),
          headlineLarge: TextStyle(color: cream, fontSize: 20, fontWeight: FontWeight.w600, letterSpacing: 2),
          headlineMedium: TextStyle(color: amber, fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 1.5),
          titleLarge: TextStyle(color: cream, fontSize: 14, fontWeight: FontWeight.w600),
          titleMedium: TextStyle(color: sepia, fontSize: 12, letterSpacing: 0.5),
          bodyLarge: TextStyle(color: cream, fontSize: 13),
          bodyMedium: TextStyle(color: sepia, fontSize: 12),
          labelLarge: TextStyle(color: bg, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        ),
        dividerTheme: const DividerThemeData(color: border, thickness: 1),
        iconTheme: const IconThemeData(color: sepia, size: 18),
      );
}
