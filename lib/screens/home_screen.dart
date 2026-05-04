// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'simulator_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Vintage grid background
          CustomPaint(
            painter: _GridPainter(),
            child: Container(),
          ),
          Center(
            child: SizedBox(
              width: 520,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Title
                  _buildTitle(),
                  const SizedBox(height: 48),
                  // Menu
                  _buildMenu(context),
                  const SizedBox(height: 48),
                  // Footer
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Decorative line
        Row(
          children: [
            const Expanded(child: Divider(color: AppTheme.amberDim)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.amber,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppTheme.amberDim)),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'SIMULADOR DE',
          style: TextStyle(
            color: AppTheme.sepia,
            fontSize: 11,
            letterSpacing: 6,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'PLANIFICACIÓN',
          style: TextStyle(
            color: AppTheme.cream,
            fontSize: 36,
            letterSpacing: 8,
            fontWeight: FontWeight.w200,
          ),
        ),
        const Text(
          'DE PROCESOS',
          style: TextStyle(
            color: AppTheme.amber,
            fontSize: 28,
            letterSpacing: 8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'FCFS  ·  SPN  ·  SRT  ·  ROUND ROBIN',
          style: TextStyle(
            color: AppTheme.sepia,
            fontSize: 10,
            letterSpacing: 3,
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(child: Divider(color: AppTheme.amberDim)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.amber,
                ),
              ),
            ),
            const Expanded(child: Divider(color: AppTheme.amberDim)),
          ],
        ),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Column(
      children: [
        _MenuButton(
          label: 'INICIAR SIMULACIÓN',
          subtitle: 'Cargar procesos y ejecutar algoritmos',
          icon: Icons.play_circle_outline,
          primary: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SimulatorScreen()),
          ),
        ),
        const SizedBox(height: 12),
        _MenuButton(
          label: 'ACERCA DEL SISTEMA',
          subtitle: 'Documentación y algoritmos',
          icon: Icons.info_outline,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AboutScreen()),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return const Text(
      'v1.0.0  ·  Sistemas Operativos  ·  2026',
      style: TextStyle(color: AppTheme.amberDim, fontSize: 10, letterSpacing: 2),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.primary = false,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: widget.primary
                ? (_hovering ? AppTheme.amber : AppTheme.amberDim.withValues(alpha: 0.3))
                : (_hovering ? AppTheme.bgElevated : AppTheme.bgCard),
            border: Border.all(
              color: widget.primary ? AppTheme.amber : (_hovering ? AppTheme.amber.withValues(alpha: 0.5) : AppTheme.border),
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: widget.primary ? (AppTheme.bg) : AppTheme.amber, size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.label,
                      style: TextStyle(
                        color: widget.primary ? AppTheme.bg : AppTheme.cream,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        color: widget.primary ? AppTheme.bg.withValues(alpha: 0.7) : AppTheme.sepia,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 12, color: widget.primary ? AppTheme.bg : AppTheme.sepia),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.border.withValues(alpha: 0.3)
      ..strokeWidth = 0.5;
    const spacing = 32.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
