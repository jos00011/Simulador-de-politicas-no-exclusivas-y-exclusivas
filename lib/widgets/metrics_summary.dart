// lib/widgets/metrics_summary.dart

import 'package:flutter/material.dart';
import '../models/simulation_result.dart';
import '../utils/app_theme.dart';

class MetricsSummaryWidget extends StatelessWidget {
  final SimulationResult result;

  const MetricsSummaryWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Averages row - shown FIRST and prominently
        _buildAveragesRow(),
        const SizedBox(height: 12),
        // CPU + Memory stats
        _buildStatsRow(),
      ],
    );
  }

  Widget _buildAveragesRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border.all(color: AppTheme.amber.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Expanded(
            child: _MetricTile(
              label: 'Prom. Tiempo Retorno',
              value: result.avgTurnaroundTime.toStringAsFixed(2),
              unit: 'u.t.',
              color: AppTheme.amber,
              icon: Icons.timer_outlined,
            ),
          ),
          Container(width: 1, height: 48, color: AppTheme.border),
          Expanded(
            child: _MetricTile(
              label: 'Prom. Tiempo Espera',
              value: result.avgWaitingTime.toStringAsFixed(2),
              unit: 'u.t.',
              color: AppTheme.amberLight,
              icon: Icons.hourglass_empty,
            ),
          ),
          Container(width: 1, height: 48, color: AppTheme.border),
          Expanded(
            child: _MetricTile(
              label: 'Nº de Procesos',
              value: '${result.processes.length}',
              unit: 'proc.',
              color: AppTheme.sepia,
              icon: Icons.memory,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Uso CPU',
            value: '${result.cpuUtilization.toStringAsFixed(1)}%',
            color: result.cpuUtilization > 80 ? AppTheme.amber : AppTheme.sepia,
            icon: Icons.speed,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Tiempo Total',
            value: '${result.totalTime} u.t.',
            color: AppTheme.sepia,
            icon: Icons.timeline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Memoria Total',
            value: _formatMemory(result.totalMemory),
            color: AppTheme.sepia,
            icon: Icons.storage,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            label: 'Política',
            value: result.policy.displayName,
            color: AppTheme.amberLight,
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

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;
  final IconData icon;

  const _MetricTile({
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
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(color: AppTheme.sepia, fontSize: 10, letterSpacing: 0.5)),
          ],
        ),
        const SizedBox(height: 6),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(color: AppTheme.sepia, fontSize: 11),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppTheme.sepia, fontSize: 9, letterSpacing: 0.5)),
              Text(value, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
