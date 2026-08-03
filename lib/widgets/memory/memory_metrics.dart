// lib/widgets/memory/memory_metrics.dart

import 'package:flutter/material.dart';
import '../../models/memory_result.dart';
import '../../core/app_theme.dart';

class MemoryMetricsWidget extends StatelessWidget {
  final MemoryResult result;

  const MemoryMetricsWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isBuddy = result.algorithm == AllocationAlgorithm.buddySystem;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.glassCard(
        borderColor: isBuddy ? AppTheme.neonPurple : AppTheme.neonAmber,
        borderRadius: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBuddy) ...[
            Row(
              children: [
                Container(
                  width: 3,
                  height: 12,
                  color: AppTheme.neonPurple,
                  margin: const EdgeInsets.only(right: 6),
                ),
                const Text(
                  'BUDDY SYSTEM — MÉTRICAS',
                  style: TextStyle(
                    color: AppTheme.neonPurple,
                    fontSize: 9,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              _tile(
                'Utilización',
                '${result.utilizationPercent.toStringAsFixed(1)}%',
                Icons.pie_chart_outline,
                AppTheme.neonAmber,
              ),
              _divider(),
              _tile(
                'Usado',
                _fmt(result.usedMemory),
                Icons.storage,
                AppTheme.neonCyan,
              ),
              _divider(),
              _tile(
                'Libre',
                _fmt(result.freeMemory),
                Icons.inbox_outlined,
                AppTheme.textSecondary,
              ),
              _divider(),
              _tile(
                'Frag. Externa',
                _fmt(result.externalFragmentation),
                Icons.broken_image_outlined,
                AppTheme.neonRed,
              ),
              if (isBuddy) ...[
                _divider(),
                _tile(
                  'Frag. Interna',
                  _fmt(result.internalFragmentation),
                  Icons.layers_outlined,
                  AppTheme.neonOrange,
                ),
              ],
              _divider(),
              _tile(
                'Bloques libres',
                '${result.freeBlocks}',
                Icons.grid_view,
                AppTheme.textSecondary,
              ),
              _divider(),
              _tile(
                'Algoritmo',
                result.algorithm.displayName,
                Icons.account_tree_outlined,
                isBuddy ? AppTheme.neonPurple : AppTheme.neonAmber,
              ),
            ],
          ),
          if (isBuddy) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.bgElevated,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.neonPurple.withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.neonPurple,
                    size: 11,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Buddy System: bloques siempre potencia de 2. '
                      'La fragmentación interna (${_fmt(result.internalFragmentation)}) es '
                      'espacio desperdiciado dentro de bloques asignados. '
                      'Los gemelos libres se fusionan automáticamente.',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 9,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _tile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 13),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 36, color: AppTheme.borderDark);

  String _fmt(int kb) =>
      kb >= 1024
          ? '${(kb / 1024).toStringAsFixed(1)}MB'
          : '${kb}KB';
}