// lib/widgets/common/particle_background.dart
// Fondo animado con partículas estilo cyber/neon

import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class ParticleBackground extends StatelessWidget {
  final AnimationController controller;

  const ParticleBackground({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _ParticlePainter(
            time: controller.value,
          ),
          child: Container(),
        );
      },
    );
  }
}

class _ParticlePainter extends CustomPainter {
  final double time;
  final List<_Particle> particles;

  _ParticlePainter({required this.time}) : particles = _generateParticles();

  static List<_Particle> _generateParticles() {
    final random = Random(42);
    final list = <_Particle>[];
    for (int i = 0; i < 50; i++) {
      list.add(_Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 0.5 + random.nextDouble() * 1.0,
        speed: 0.3 + random.nextDouble() * 0.4,
        phase: random.nextDouble() * 6.28,
      ));
    }
    return list;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.neonCyan.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    for (final p in particles) {
      final dx = ((p.x + time * p.speed * 0.05) % 1) * size.width;
      final dy = ((p.y + time * p.speed * 0.03 + p.phase * 0.01) % 1) * size.height;
      final radius = p.size * 1.5;
      canvas.drawCircle(Offset(dx, dy), radius, paint);
    }

    final linePaint = Paint()
      ..color = AppTheme.neonCyan.withValues(alpha: 0.02)
      ..strokeWidth = 0.5;

    for (int i = 0; i < particles.length; i++) {
      for (int j = i + 1; j < particles.length; j++) {
        final p1 = particles[i];
        final p2 = particles[j];
        final dx1 = ((p1.x + time * p1.speed * 0.05) % 1) * size.width;
        final dy1 = ((p1.y + time * p1.speed * 0.03 + p1.phase * 0.01) % 1) * size.height;
        final dx2 = ((p2.x + time * p2.speed * 0.05) % 1) * size.width;
        final dy2 = ((p2.y + time * p2.speed * 0.03 + p2.phase * 0.01) % 1) * size.height;

        final dist = (dx1 - dx2).abs() + (dy1 - dy2).abs();
        if (dist < 80) {
          canvas.drawLine(
            Offset(dx1, dy1),
            Offset(dx2, dy2),
            linePaint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;

  _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}