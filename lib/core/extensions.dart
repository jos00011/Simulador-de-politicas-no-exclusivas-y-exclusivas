// lib/core/extensions.dart

import 'package:flutter/material.dart';

extension ColorExtension on Color {
  Color withOpacity(double opacity) {
    return withValues(alpha: opacity.clamp(0.0, 1.0));
  }

  Color darken(double amount) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  Color brighten(double amount) {
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}

extension ContextExtension on BuildContext {
  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1200;
  bool get isDesktop => width >= 1200;
  ThemeData get theme => Theme.of(this);
}

extension ListExtension<T> on List<T> {
  List<T> safeSublist(int start, [int? end]) {
    final e = end ?? length;
    if (start >= length || start >= e) return [];
    return sublist(start.clamp(0, length), e.clamp(0, length));
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

extension IntExtension on int {
  String get formatMemory {
    if (this >= 1024) {
      return '${(this / 1024).toStringAsFixed(1)} MB';
    }
    return '$this KB';
  }
}