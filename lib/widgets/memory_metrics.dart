// lib/widgets/memory_metrics.dart

import 'package:flutter/material.dart';
import '../models/memory_result.dart';
import '../utils/app_theme.dart';

class MemoryMetricsWidget extends StatelessWidget {
  final MemoryResult result;

  const MemoryMetricsWidget({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final isBuddy = result.algorithm == AllocationAlgorithm.buddySystem;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border.all(
          color: isBuddy
              ? AppTheme.amberLight.withValues(alpha: 0.5)
              : AppTheme.amber.withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(4),
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
                    color: AppTheme.amberLight,
                    margin: const EdgeInsets.only(right: 6)),
                const Text('BUDDY SYSTEM — MÉTRICAS',
                    style: TextStyle(
                        color: AppTheme.amberLight,
                        fontSize: 9,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Row(
            children: [
              _tile('Utilización',
                  '${result.utilizationPercent.toStringAsFixed(1)}%',
                  Icons.pie_chart_outline, AppTheme.amber),
              _divider(),
              _tile('Usado', _fmt(result.usedMemory), Icons.storage,
                  AppTheme.amberLight),
              _divider(),
              _tile('Libre', _fmt(result.freeMemory), Icons.inbox_outlined,
                  AppTheme.sepia),
              _divider(),
              _tile(
                  'Frag. Externa',
                  _fmt(result.externalFragmentation),
                  Icons.broken_image_outlined,
                  AppTheme.rust),
              if (isBuddy) ...[
                _divider(),
                _tile(
                    'Frag. Interna',
                    _fmt(result.internalFragmentation),
                    Icons.layers_outlined,
                    Colors.orange.shade300),
              ],
              _divider(),
              _tile('Bloques libres', '${result.freeBlocks}',
                  Icons.grid_view, AppTheme.sepia),
              _divider(),
              _tile('Algoritmo', result.algorithm.displayName,
                  Icons.account_tree_outlined, AppTheme.amberLight),
            ],
          ),
          if (isBuddy) ...[
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.bgElevated,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                    color: AppTheme.amberLight.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: AppTheme.amberLight, size: 11),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Buddy System: bloques siempre potencia de 2. '
                      'La fragmentación interna (${_fmt(result.internalFragmentation)}) es '
                      'espacio desperdiciado dentro de bloques asignados. '
                      'Los gemelos libres se fusionan automáticamente.',
                      style: const TextStyle(
                          color: AppTheme.sepia, fontSize: 9, height: 1.5),
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

  Widget _tile(
      String label, String value, IconData icon, Color color) {
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
                child: Text(label,
                    style: const TextStyle(
                        color: AppTheme.sepia,
                        fontSize: 9,
                        letterSpacing: 0.5),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: color,
                  fontSize: 15,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _divider() =>
      Container(width: 1, height: 36, color: AppTheme.border);

  String _fmt(int kb) =>
      kb >= 1024
          ? '${(kb / 1024).toStringAsFixed(1)}MB'
          : '${kb}KB';
}