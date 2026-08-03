// lib/widgets/storage/bitmap_widget.dart
// Visualización del Mapa de Bits (Bitmap)

import 'package:flutter/material.dart';
import '../../models/bitmap.dart';
import '../../core/app_theme.dart';

class BitmapWidget extends StatelessWidget {
  final Bitmap bitmap;
  final List<int>? highlightBlocks;

  const BitmapWidget({
    super.key,
    required this.bitmap,
    this.highlightBlocks,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              color: AppTheme.neonGreen,
              margin: const EdgeInsets.only(right: 8),
            ),
            const Text(
              'MAPA DE BITS',
              style: TextStyle(
                color: AppTheme.neonGreen,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.neonGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${bitmap.size} bits',
                style: const TextStyle(
                  color: AppTheme.neonGreen,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Grid de bits
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.glassCard(
            borderColor: AppTheme.neonGreen,
            borderRadius: 12,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Wrap(
                  spacing: 2,
                  runSpacing: 2,
                  children: List.generate(bitmap.size, (index) {
                    final isUsed = bitmap.isUsed(index);
                    final isHighlighted = highlightBlocks?.contains(index) ?? false;
                    return _buildBitCell(index, isUsed, isHighlighted);
                  }),
                ),
              );
            },
          ),
        ),
        // Leyenda y estadísticas
        const SizedBox(height: 8),
        _buildLegend(),
        const SizedBox(height: 8),
        _buildStats(),
      ],
    );
  }

  Widget _buildBitCell(int index, bool isUsed, bool isHighlighted) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isUsed
            ? (isHighlighted
                ? AppTheme.neonPink.withValues(alpha: 0.6)
                : AppTheme.neonPink.withValues(alpha: 0.4))
            : (isHighlighted
                ? AppTheme.neonGreen.withValues(alpha: 0.6)
                : AppTheme.neonGreen.withValues(alpha: 0.15)),
        border: Border.all(
          color: isUsed
              ? (isHighlighted
                  ? AppTheme.neonPink
                  : AppTheme.neonPink.withValues(alpha: 0.3))
              : (isHighlighted
                  ? AppTheme.neonGreen
                  : AppTheme.neonGreen.withValues(alpha: 0.2)),
          width: isHighlighted ? 2.0 : 0.5,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: isHighlighted
            ? [
                BoxShadow(
                  color: (isUsed ? AppTheme.neonPink : AppTheme.neonGreen)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Text(
        isUsed ? '1' : '0',
        style: TextStyle(
          color: isUsed ? AppTheme.neonPink : AppTheme.neonGreen,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _legendItem('0 = Libre', AppTheme.neonGreen, AppTheme.neonGreen.withValues(alpha: 0.15)),
        _legendItem('1 = Ocupado', AppTheme.neonPink, AppTheme.neonPink.withValues(alpha: 0.3)),
        _legendItem('Destacado', AppTheme.neonCyan, AppTheme.neonCyan.withValues(alpha: 0.6)),
      ],
    );
  }

  Widget _legendItem(String label, Color textColor, Color bgColor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: textColor.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildStats() {
    final stats = bitmap.getStats();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: AppTheme.glassCard(borderRadius: 8),
      child: Row(
        children: [
          _statItem('Total', '${stats['totalBlocks']}', AppTheme.textSecondary),
          _statItem('Libres', '${stats['freeBlocks']}', AppTheme.neonGreen),
          _statItem('Usados', '${stats['usedBlocks']}', AppTheme.neonPink),
          _statItem('Uso', '${(stats['utilizationPercent'] as double).toStringAsFixed(1)}%', AppTheme.neonAmber),
          _statItem('Hueco mayor', '${stats['largestFreeHole']}', AppTheme.neonCyan),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}