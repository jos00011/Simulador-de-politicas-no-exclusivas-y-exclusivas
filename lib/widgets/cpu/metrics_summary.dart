// lib/widgets/cpu/metrics_summary.dart

import 'package:flutter/material.dart';
import '../../models/simulation_result.dart';
import '../../core/app_theme.dart';

class MetricsSummaryWidget extends StatefulWidget {
  final SimulationResult result;

  const MetricsSummaryWidget({super.key, required this.result});

  @override
  State<MetricsSummaryWidget> createState() => _MetricsSummaryWidgetState();
}

class _MetricsSummaryWidgetState extends State<MetricsSummaryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _countAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _countAnim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 300), _ctrl.forward);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _countAnim,
      builder: (context, _) {
        final t = _countAnim.value;
        return Column(
          children: [
            _buildAveragesRow(t),
            const SizedBox(height: 10),
            _buildStatsRow(t),
          ],
        );
      },
    );
  }

  Widget _buildAveragesRow(double t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(
        borderColor: AppTheme.neonAmber,
        borderRadius: 12,
      ),
      child: Row(
        children: [
          Expanded(
            child: _AnimatedMetricTile(
              label: 'Prom. Tiempo Retorno',
              value: (widget.result.avgTurnaroundTime * t).toStringAsFixed(2),
              unit: 'u.t.',
              color: AppTheme.neonAmber,
              icon: Icons.timer_outlined,
            ),
          ),
          Container(width: 1, height: 52, color: AppTheme.borderDark),
          Expanded(
            child: _AnimatedMetricTile(
              label: 'Prom. Tiempo Espera',
              value: (widget.result.avgWaitingTime * t).toStringAsFixed(2),
              unit: 'u.t.',
              color: AppTheme.neonCyan,
              icon: Icons.hourglass_empty,
            ),
          ),
          Container(width: 1, height: 52, color: AppTheme.borderDark),
          Expanded(
            child: _AnimatedMetricTile(
              label: 'Procesos',
              value: '${(widget.result.processes.length * t).round()}',
              unit: 'proc.',
              color: AppTheme.neonGreen,
              icon: Icons.memory,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(double t) {
    final cpuVal = widget.result.cpuUtilization * t;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Uso CPU',
            value: '${cpuVal.toStringAsFixed(1)}%',
            color: cpuVal > 80 ? AppTheme.neonAmber : AppTheme.textSecondary,
            icon: Icons.speed,
            barFill: cpuVal / 100,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Tiempo Total',
            value: '${widget.result.totalTime} u.t.',
            color: AppTheme.textSecondary,
            icon: Icons.timeline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Memoria Total',
            value: _formatMemory(widget.result.totalMemory),
            color: AppTheme.textSecondary,
            icon: Icons.storage,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Política',
            value: widget.result.policy.displayName,
            color: AppTheme.neonAmber,
            icon: Icons.account_tree_outlined,
          ),
        ),
      ],
    );
  }

  String _formatMemory(int kb) {
    if (kb >= 1024) return '${(kb / 1024).toStringAsFixed(1)} MB';
    return '$kb KB';
  }
}

class _AnimatedMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  const _AnimatedMetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 9,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatefulWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final double? barFill;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.barFill,
  });

  @override
  State<_StatCard> createState() => _StatCardState();
}

class _StatCardState extends State<_StatCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: _hovered
              ? widget.color.withOpacity(0.06)
              : AppTheme.bgCard,
          border: Border.all(
            color: _hovered
                ? widget.color.withOpacity(0.5)
                : AppTheme.borderDark,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(widget.icon, color: widget.color, size: 14),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 9,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        widget.value,
                        style: TextStyle(
                          color: widget.color,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.barFill != null) ...[
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: widget.barFill!.clamp(0.0, 1.0),
                  backgroundColor: AppTheme.bgElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(widget.color),
                  minHeight: 2,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}