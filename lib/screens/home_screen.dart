// lib/screens/home_screen.dart
// Pantalla principal rediseñada con 2 tarjetas principales (Procesos + Almacenamiento)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/app_state.dart';
import 'process_simulator_screen.dart';
import 'storage_screen.dart';
import 'about_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {  // ✅ CAMBIADO: SingleTickerProviderStateMixin → TickerProviderStateMixin
  late AnimationController _fadeCtrl;
  late AnimationController _slideCtrl;
  late AnimationController _particleCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _fadeAnim = CurvedAnimation(
      parent: _fadeCtrl,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideCtrl,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _fadeCtrl.forward();
      _slideCtrl.forward();
    });
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _slideCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final processCount = appState.processes.length;

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Stack(
        children: [
          // Fondo con partículas animadas
          _ParticleBackground(controller: _particleCtrl),
          // Contenido principal
          Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SizedBox(
                  width: 640,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Título
                      _buildHeader(),
                      const SizedBox(height: 48),
                      // 2 Tarjetas principales
                      _buildDashboard(context, processCount),
                      const SizedBox(height: 32),
                      // Footer
                      _buildFooter(context),
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

  Widget _buildHeader() {
    return Column(
      children: [
        // Línea decorativa superior
        _decorLine(),
        const SizedBox(height: 20),
        // Título principal
        const Text(
          'SISTEMA OPERATIVO',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 13,
            letterSpacing: 8,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 4),
        ShaderMask(
          shaderCallback: (bounds) => AppTheme.gradientCyanPink.createShader(bounds),
          child: const Text(
            'SIMULADOR',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              letterSpacing: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'PROCESOS · MEMORIA · SISTEMA DE ARCHIVOS',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
              letterSpacing: 3,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _decorLine(),
      ],
    );
  }

  Widget _decorLine() {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppTheme.borderDark)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.neonCyan,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.neonCyan.withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
          ),
        ),
        const Expanded(child: Divider(color: AppTheme.borderDark)),
      ],
    );
  }

  Widget _buildDashboard(BuildContext context, int processCount) {
    return Column(
      children: [
        // Tarjeta 1: Procesos y Memoria
        _DashboardCard(
          icon: Icons.memory,
          iconColor: AppTheme.neonCyan,
          title: 'PROCESOS Y MEMORIA',
          subtitle: 'Planificación CPU · Gestión dinámica · Buddy System',
          processCount: processCount,
          onTap: () => _navigateTo(context, const ProcessSimulatorScreen()),
        ),
        const SizedBox(height: 14),
        // Tarjeta 2: Sistema de Archivos
        _DashboardCard(
          icon: Icons.sd_storage,
          iconColor: AppTheme.neonAmber,
          title: 'SISTEMA DE ARCHIVOS',
          subtitle: 'FAT · Extents · Multinivel · Bitmap · Asignación Clásica',
          processCount: processCount,
          onTap: () => _navigateTo(context, const StorageScreen()),
        ),
        const SizedBox(height: 14),
        // Botón de documentación (secundario)
        _DocumentationButton(
          onTap: () => _navigateTo(context, const AboutScreen()),
        ),
      ],
    );
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => screen,
        transitionsBuilder: (_, anim, __, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 280),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'v3.0  ·  Sistemas Operativos  ·  2026',
          style: TextStyle(
            color: AppTheme.textDim,
            fontSize: 10,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

// ─── TARJETA DE DASHBOARD ─────────────────────────────────────────
class _DashboardCard extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final int processCount;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.processCount,
    required this.onTap,
  });

  @override
  State<_DashboardCard> createState() => _DashboardCardState();
}

class _DashboardCardState extends State<_DashboardCard>
    with SingleTickerProviderStateMixin {  // ✅ Este sí usa SingleTickerProviderStateMixin (solo 1 controller)
  bool _isHovered = false;
  late AnimationController _glowCtrl;
  late Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnim = CurvedAnimation(
      parent: _glowCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedBuilder(
        animation: _glowAnim,
        builder: (context, child) {
          final glowValue = _glowAnim.value;

          return GestureDetector(
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: _isHovered
                    ? widget.iconColor.withValues(alpha: 0.06)
                    : Colors.white.withValues(alpha: 0.02),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isHovered
                      ? widget.iconColor.withValues(alpha: 0.5 + 0.3 * glowValue)
                      : widget.iconColor.withValues(alpha: 0.12),
                  width: _isHovered ? 1.8 : 1.0,
                ),
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: widget.iconColor.withValues(alpha: 0.1 + 0.15 * glowValue),
                          blurRadius: 30 + 15 * glowValue,
                          spreadRadius: -4,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  // Icono grande
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: widget.iconColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.iconColor.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.iconColor,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 18),
                  // Texto
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.title,
                                style: TextStyle(
                                  color: _isHovered ? widget.iconColor : AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            // Contador de procesos
                            if (widget.processCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.neonCyan.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${widget.processCount} proc.',
                                  style: const TextStyle(
                                    color: AppTheme.neonCyan,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.subtitle,
                          style: TextStyle(
                            color: _isHovered
                                ? AppTheme.textSecondary
                                : AppTheme.textDim,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Flecha
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: _isHovered ? widget.iconColor : AppTheme.textDim,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── BOTÓN DE DOCUMENTACIÓN ─────────────────────────────────────
class _DocumentationButton extends StatefulWidget {
  final VoidCallback onTap;

  const _DocumentationButton({required this.onTap});
  @override
  State<_DocumentationButton> createState() => _DocumentationButtonState();
}

class _DocumentationButtonState extends State<_DocumentationButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTheme.textSecondary.withValues(alpha: 0.08)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: _isHovered
                  ? AppTheme.textSecondary.withValues(alpha: 0.3)
                  : AppTheme.borderDark,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                color: _isHovered ? AppTheme.textSecondary : AppTheme.textDim,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'DOCUMENTACIÓN Y REFERENCIAS',
                style: TextStyle(
                  color: _isHovered ? AppTheme.textSecondary : AppTheme.textDim,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── FONDO CON PARTÍCULAS ANIMADAS ─────────────────────────────
class _ParticleBackground extends StatelessWidget {
  final AnimationController controller;

  const _ParticleBackground({required this.controller});

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
    final list = <_Particle>[];
    for (int i = 0; i < 50; i++) {
      list.add(_Particle(
        x: i * 13.7 % 1,
        y: i * 7.3 % 1,
        size: 0.5 + (i % 3) * 0.5,
        speed: 0.3 + (i % 5) * 0.1,
        phase: i * 0.7,
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