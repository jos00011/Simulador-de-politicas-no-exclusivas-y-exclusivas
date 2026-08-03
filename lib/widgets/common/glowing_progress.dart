// lib/widgets/common/glowing_progress.dart
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class GlowingProgress extends StatelessWidget {
  final double value;
  final Color color;
  final double height;

  const GlowingProgress({
    super.key,
    required this.value,
    this.color = AppTheme.neonCyan,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(height / 2),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: height,
            ),
          ),
          if (value > 0.01)
            Container(
              width: value.clamp(0.0, 1.0) * double.infinity,
              height: height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(height / 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}