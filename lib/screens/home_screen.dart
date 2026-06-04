// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'simulator_screen.dart';
import 'about_screen.dart';
import 'memory_screen.dart';
// import 'pagination_screen.dart';  // ← ELIMINADA - ya no existe

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _slideCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));

    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeCtrl.forward();
      _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          CustomPaint(painter: _GridPainter(), child: Container()),
          // Ambient glow
          Positioned(
            top: -100,
            left: -50,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.amber.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SizedBox(
                  width: 540,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTitle(),
                      const SizedBox(height: 48),
                      _buildMenu(context),
                      const SizedBox(height: 48),
                      _buildFooter(),
                    ],
                  ),
                ),
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
        _decorLine(),
        const SizedBox(height: 24),
        const Text(
          'SIMULADOR DE',
          style: TextStyle(color: AppTheme.sepia, fontSize: 11, letterSpacing: 6, fontWeight: FontWeight.w400),
        ),
        const SizedBox(height: 4),
        const Text(
          'SISTEMAS',
          style: TextStyle(color: AppTheme.cream, fontSize: 36, letterSpacing: 8, fontWeight: FontWeight.w200),
        ),
        const Text(
          'OPERATIVOS',
          style: TextStyle(color: AppTheme.amber, fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.amberDim),
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Text(
            'PLANIFICACIÓN  ·  MEMORIA  ·  PAGINACIÓN',
            style: TextStyle(color: AppTheme.sepia, fontSize: 9, letterSpacing: 3),
          ),
        ),
        const SizedBox(height: 24),
        _decorLine(),
      ],
    );
  }

  Widget _decorLine() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.amberDim)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            width: 8, height: 8,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.amber),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.amberDim)),
      ],
    );
  }

  Widget _buildMenu(BuildContext context) {
    return Column(
      children: [
        _MenuButton(
          label: 'PLANIFICACIÓN DE CPU',
          subtitle: 'FCFS  ·  SPN  ·  SRT  ·  Round Robin',
          icon: Icons.play_circle_outline,
          accentColor: AppTheme.amber,
          primary: true,
          delay: 0,
          onTap: () => Navigator.push(context, _route(const SimulatorScreen())),
        ),
        const SizedBox(height: 10),
        _MenuButton(
          label: 'GESTIÓN DE MEMORIA',
          subtitle: 'First Fit  ·  Best Fit  ·  Worst Fit  ·  Compactación',
          icon: Icons.storage_outlined,
          accentColor: AppTheme.rust,
          delay: 80,
          onTap: () => Navigator.push(context, _route(const MemoryScreen())),
        ),
        const SizedBox(height: 10),
        // ═══════════════════════════════════════════════════════════════════
        // BOTÓN DE PAGINACIÓN - COMENTADO HASTA QUE EXISTA
        // ═══════════════════════════════════════════════════════════════════
        // _MenuButton(
        //   label: 'PAGINACIÓN Y TLB',
        //   subtitle: 'TLB  ·  Tabla de Páginas  ·  Fallos de Página',
        //   icon: Icons.memory,
        //   accentColor: const Color(0xFF9C27B0),
        //   delay: 120,
        //   onTap: () => Navigator.push(context, _route(const PaginationScreen())),
        // ),
        // const SizedBox(height: 10),
        _MenuButton(
          label: 'DOCUMENTACIÓN',
          subtitle: 'Algoritmos, métricas y referencias',
          icon: Icons.info_outline,
          accentColor: AppTheme.sepia,
          delay: 160,
          onTap: () => Navigator.push(context, _route(const AboutScreen())),
        ),
      ],
    );
  }

  PageRoute _route(Widget screen) =>
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0.03, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
            child: child,
          ),
        ),
        transitionDuration: const Duration(milliseconds: 280),
      );

  Widget _buildFooter() {
    return const Text(
      'v2.0.0  ·  Sistemas Operativos  ·  2026',
      style: TextStyle(color: AppTheme.amberDim, fontSize: 10, letterSpacing: 2),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool primary;
  final int delay;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
    required this.delay,
    this.primary = false,
  });

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> with SingleTickerProviderStateMixin {
  bool _hovering = false;
  late AnimationController _scaleCtrl;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _scaleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween<double>(begin: 1.0, end: 1.008)
        .animate(CurvedAnimation(parent: _scaleCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _scaleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _hovering = true);
        _scaleCtrl.forward();
      },
      onExit: (_) {
        setState(() => _hovering = false);
        _scaleCtrl.reverse();
      },
      child: ScaleTransition(
        scale: _scaleAnim,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: widget.primary
                  ? (_hovering ? widget.accentColor : widget.accentColor.withValues(alpha: 0.12))
                  : (_hovering ? AppTheme.bgElevated : AppTheme.bgCard),
              border: Border.all(
                color: _hovering ? widget.accentColor : (widget.primary ? widget.accentColor.withValues(alpha: 0.5) : AppTheme.border),
                width: _hovering ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(3),
              boxShadow: _hovering
                  ? [BoxShadow(color: widget.accentColor.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4))]
                  : null,
            ),
            child: Row(
              children: [
                Icon(widget.icon,
                    color: widget.primary
                        ? (_hovering ? AppTheme.bg : widget.accentColor)
                        : (_hovering ? widget.accentColor : AppTheme.sepia),
                    size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.primary
                              ? (_hovering ? AppTheme.bg : AppTheme.cream)
                              : (_hovering ? widget.accentColor : AppTheme.cream),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        widget.subtitle,
                        style: TextStyle(
                          color: widget.primary
                              ? (_hovering ? AppTheme.bg.withValues(alpha: 0.7) : AppTheme.sepia)
                              : AppTheme.sepia,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios, size: 11,
                    color: widget.primary
                        ? (_hovering ? AppTheme.bg : AppTheme.sepia)
                        : AppTheme.sepia),
              ],
            ),
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
      ..color = AppTheme.border.withValues(alpha: 0.25)
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