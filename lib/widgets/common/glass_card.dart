// lib/widgets/common/glass_card.dart
// Tarjeta con efecto Glassmorphism y acentos neón

import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final double borderRadius;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final List<BoxShadow>? customShadows;
  final bool withBlur;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.borderColor,
    this.borderRadius = 16,
    this.width,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.customShadows,
    this.withBlur = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = borderColor ?? AppTheme.neonCyan;
    
    Widget card = Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: withBlur 
            ? Colors.white.withValues(alpha: 0.03)
            : AppTheme.bgCard,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: customShadows ?? [
          BoxShadow(
            color: color.withValues(alpha: 0.06),
            blurRadius: 30,
            spreadRadius: -8,
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

// ─── TARJETA CON BRILLO NEÓN ────────────────────────────────────
class NeonGlowCard extends StatefulWidget {
  final Widget child;
  final Color color;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final bool animated;

  const NeonGlowCard({
    super.key,
    required this.child,
    this.color = AppTheme.neonCyan,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.animated = true,
  });

  @override
  State<NeonGlowCard> createState() => _NeonGlowCardState();
}

class _NeonGlowCardState extends State<NeonGlowCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.animated) {
      _pulseCtrl.repeat(reverse: true);
    } else {
      _pulseCtrl.value = 0.5;
    }
    _pulseAnim = CurvedAnimation(
      parent: _pulseCtrl,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final pulseValue = _pulseAnim.value;
        final glowIntensity = 0.1 + 0.15 * pulseValue;

        return Container(
          margin: widget.margin,
          padding: widget.padding,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(widget.borderRadius),
            border: Border.all(
              color: widget.color.withValues(alpha: 0.2 + 0.2 * pulseValue),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: glowIntensity),
                blurRadius: 30 + 15 * pulseValue,
                spreadRadius: -6,
              ),
              BoxShadow(
                color: widget.color.withValues(alpha: glowIntensity * 0.5),
                blurRadius: 60,
                spreadRadius: -12,
              ),
            ],
          ),
          child: widget.child,
        );
      },
    );
  }
}

// ─── TARJETA CON GRADIENTE NEÓN ─────────────────────────────────
class GradientCard extends StatelessWidget {
  final Widget child;
  final List<Color> colors;
  final Gradient? customGradient;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final VoidCallback? onTap;

  const GradientCard({
    super.key,
    required this.child,
    this.colors = const [AppTheme.neonCyan, AppTheme.neonPurple],
    this.customGradient,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = customGradient ?? LinearGradient(
      colors: colors,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    Widget card = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );

    if (onTap != null) {
      card = GestureDetector(
        onTap: onTap,
        child: card,
      );
    }

    return card;
  }
}

// ─── HEADER DE SECCIÓN CON NEÓN ────────────────────────────────
class NeonSectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  final Widget? trailing;
  final double fontSize;

  const NeonSectionHeader({
    super.key,
    required this.title,
    this.color = AppTheme.neonCyan,
    this.trailing,
    this.fontSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          color: color,
          margin: const EdgeInsets.only(right: 8),
        ),
        Text(
          title,
          style: TextStyle(
            color: color,
            fontSize: fontSize,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

// ─── DIVISOR NEÓN ─────────────────────────────────────────────────
class NeonDivider extends StatelessWidget {
  final Color color;
  final double height;
  final double thickness;

  const NeonDivider({
    super.key,
    this.color = AppTheme.borderDark,
    this.height = 1,
    this.thickness = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      color: color.withValues(alpha: 0.3),
    );
  }
}

// ─── ESTADÍSTICA INDIVIDUAL ──────────────────────────────────────
class NeonStatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData? icon;
  final bool compact;

  const NeonStatItem({
    super.key,
    required this.label,
    required this.value,
    this.color = AppTheme.neonCyan,
    this.icon,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: color,
              size: compact ? 12 : 14,
            ),
            const SizedBox(width: 4),
          ],
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: compact ? 8 : 10,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: compact ? 10 : 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── LISTA DE ESTADÍSTICAS ──────────────────────────────────────
class NeonStatsRow extends StatelessWidget {
  final List<NeonStatItem> stats;

  const NeonStatsRow({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: AppTheme.glassCard(borderRadius: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: stats,
      ),
    );
  }
}

// ─── BADGE NEÓN ────────────────────────────────────────────────────
class NeonBadge extends StatelessWidget {
  final String label;
  final Color color;
  final double fontSize;

  const NeonBadge({
    super.key,
    required this.label,
    this.color = AppTheme.neonCyan,
    this.fontSize = 9,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

// ─── LEYENDA NEÓN ──────────────────────────────────────────────────
class NeonLegend extends StatelessWidget {
  final List<LegendItem> items;

  const NeonLegend({
    super.key,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: items.map((item) => item.build()).toList(),
    );
  }
}

class LegendItem {
  final Color color;
  final String label;
  final double size;

  const LegendItem({
    required this.color,
    required this.label,
    this.size = 10,
  });

  Widget build() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}