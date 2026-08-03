// lib/widgets/common/neon_button.dart
// Botón con efecto neón y animaciones hover

import 'package:flutter/material.dart';
import '../../core/app_theme.dart';

class NeonButton extends StatefulWidget {
  final String text;
  final IconData? icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool outlined;
  final double? width;
  final double? height;
  final bool isLoading;

  const NeonButton({
    super.key,
    required this.text,
    this.icon,
    this.color = AppTheme.neonCyan,
    this.onPressed,
    this.outlined = false,
    this.width,
    this.height,
    this.isLoading = false,
  });

  @override
  State<NeonButton> createState() => _NeonButtonState();
}

class _NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
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
    final isEnabled = widget.onPressed != null && !widget.isLoading;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final pulseValue = _pulseAnim.value;
        final glowIntensity = widget.outlined ? 0.3 + 0.3 * pulseValue : 0.15 + 0.2 * pulseValue;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: isEnabled ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.width,
              height: widget.height ?? 40,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: widget.outlined
                    ? Colors.transparent
                    : (isEnabled
                        ? widget.color.withValues(alpha: 0.12 + 0.08 * (_isHovered ? 1 : 0))
                        : AppTheme.bgElevated),
                border: Border.all(
                  color: isEnabled
                      ? (widget.outlined
                          ? widget.color.withValues(alpha: 0.6 + 0.4 * (_isHovered ? 1 : 0))
                          : widget.color.withValues(alpha: 0.3 + 0.3 * (_isHovered ? 1 : 0)))
                      : AppTheme.borderDark,
                  width: widget.outlined ? 2.0 : 1.5,
                ),
                borderRadius: BorderRadius.circular(40),
                boxShadow: isEnabled && _isHovered
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: glowIntensity),
                          blurRadius: 20 + 10 * pulseValue,
                          spreadRadius: -4,
                        ),
                        BoxShadow(
                          color: widget.color.withValues(alpha: glowIntensity * 0.5),
                          blurRadius: 40,
                          spreadRadius: -8,
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: widget.color,
                      ),
                    )
                  else if (widget.icon != null)
                    Icon(
                      widget.icon,
                      color: isEnabled ? widget.color : AppTheme.textDim,
                      size: 16,
                    ),
                  if (widget.icon != null && !widget.isLoading)
                    const SizedBox(width: 8),
                  if (!widget.isLoading)
                    Text(
                      widget.text,
                      style: TextStyle(
                        color: isEnabled
                            ? (widget.outlined ? widget.color : widget.color)
                            : AppTheme.textDim,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── BOTÓN ICONO NEÓN ────────────────────────────────────────────
class NeonIconButton extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final double size;

  const NeonIconButton({
    super.key,
    required this.icon,
    this.color = AppTheme.neonCyan,
    this.onPressed,
    this.size = 24,
  });

  @override
  State<NeonIconButton> createState() => _NeonIconButtonState();
}

class _NeonIconButtonState extends State<NeonIconButton>
    with SingleTickerProviderStateMixin {
  bool _isHovered = false;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;

    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final pulseValue = _pulseCtrl.value;
        final glowIntensity = 0.2 + 0.3 * pulseValue;

        return MouseRegion(
          onEnter: (_) => setState(() => _isHovered = true),
          onExit: (_) => setState(() => _isHovered = false),
          child: GestureDetector(
            onTap: isEnabled ? widget.onPressed : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEnabled && _isHovered
                    ? widget.color.withValues(alpha: 0.12)
                    : Colors.transparent,
                shape: BoxShape.circle,
                boxShadow: isEnabled && _isHovered
                    ? [
                        BoxShadow(
                          color: widget.color.withValues(alpha: glowIntensity),
                          blurRadius: 20,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
              child: Icon(
                widget.icon,
                color: isEnabled
                    ? (widget.color)
                    : AppTheme.textDim,
                size: widget.size,
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── BOTÓN TOGGLE NEÓN ────────────────────────────────────────────
class NeonToggleButton extends StatefulWidget {
  final List<String> options;
  final int selectedIndex;
  final Color color;
  final ValueChanged<int> onChanged;

  const NeonToggleButton({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.color = AppTheme.neonCyan,
  });

  @override
  State<NeonToggleButton> createState() => _NeonToggleButtonState();
}

class _NeonToggleButtonState extends State<NeonToggleButton> {
  int _hoveredIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(widget.options.length, (index) {
          final isSelected = index == widget.selectedIndex;
          final isHovered = index == _hoveredIndex;

          return MouseRegion(
            onEnter: (_) => setState(() => _hoveredIndex = index),
            onExit: (_) => setState(() => _hoveredIndex = -1),
            child: GestureDetector(
              onTap: () => widget.onChanged(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? widget.color.withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected
                        ? widget.color
                        : Colors.transparent,
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: widget.color.withValues(alpha: 0.2),
                            blurRadius: 12,
                            spreadRadius: -2,
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  widget.options[index],
                  style: TextStyle(
                    color: isSelected
                        ? widget.color
                        : (isHovered
                            ? widget.color.withValues(alpha: 0.6)
                            : AppTheme.textSecondary),
                    fontSize: 11,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}