// lib/widgets/storage/fat_table_widget.dart
// Visualización de la Tabla FAT con colores y efectos

import 'package:flutter/material.dart';
import '../../models/fat_table.dart';
import '../../core/app_theme.dart';

class FATTableWidget extends StatelessWidget {
  final FATTable fatTable;
  final int? highlightIndex;
  final List<int>? highlightChain;

  const FATTableWidget({
    super.key,
    required this.fatTable,
    this.highlightIndex,
    this.highlightChain,
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
              color: AppTheme.neonCyan,
              margin: const EdgeInsets.only(right: 8),
            ),
            const Text(
              'TABLA FAT',
              style: TextStyle(
                color: AppTheme.neonCyan,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.neonCyan.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${fatTable.length} entradas',
                style: const TextStyle(
                  color: AppTheme.neonCyan,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Tabla FAT
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.glassCard(
            borderColor: AppTheme.neonCyan,
            borderRadius: 12,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabecera con índices
                Row(
                  children: List.generate(
                    fatTable.length,
                    (index) => _buildHeaderCell(index),
                  ),
                ),
                const SizedBox(height: 4),
                // Valores FAT
                Row(
                  children: List.generate(
                    fatTable.length,
                    (index) => _buildFatCell(index),
                  ),
                ),
              ],
            ),
          ),
        ),
        // Leyenda
        const SizedBox(height: 8),
        _buildLegend(),
        // Estadísticas
        const SizedBox(height: 8),
        _buildStats(),
      ],
    );
  }

  Widget _buildHeaderCell(int index) {
    final isHighlighted = highlightChain?.contains(index) ?? false;
    return Container(
      width: 32,
      height: 20,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppTheme.neonCyan.withOpacity(0.2)
            : AppTheme.bgElevated,
        border: Border.all(
          color: isHighlighted
              ? AppTheme.neonCyan
              : AppTheme.borderDark,
          width: isHighlighted ? 1.5 : 0.5,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        '$index',
        style: TextStyle(
          color: isHighlighted ? AppTheme.neonCyan : AppTheme.textSecondary,
          fontSize: 8,
          fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildFatCell(int index) {
    final value = fatTable.entries[index];
    final isHighlighted = highlightChain?.contains(index) ?? false;
    final isFree = fatTable.isFree(index);
    final isEof = fatTable.isEof(index);
    final isInChain = highlightChain?.contains(index) ?? false;

    Color bgColor;
    Color textColor;
    String displayValue;

    if (isFree) {
      bgColor = AppTheme.bgElevated;
      textColor = AppTheme.textDim;
      displayValue = '·';
    } else if (isEof) {
      bgColor = AppTheme.neonPink.withOpacity(0.15);
      textColor = AppTheme.neonPink;
      displayValue = 'EOF';
    } else {
      bgColor = isInChain
          ? AppTheme.neonCyan.withOpacity(0.25)
          : AppTheme.neonGreen.withOpacity(0.10);
      textColor = isInChain ? AppTheme.neonCyan : AppTheme.neonGreen;
      displayValue = '$value';
    }

    return Container(
      width: 32,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isHighlighted
            ? AppTheme.neonCyan.withOpacity(0.3)
            : bgColor,
        border: Border.all(
          color: isHighlighted
              ? AppTheme.neonCyan
              : isFree
                  ? AppTheme.borderDark
                  : textColor.withOpacity(0.3),
          width: isHighlighted ? 2.0 : 0.5,
        ),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        displayValue,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: isEof ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        _legendItem('· Libre', AppTheme.textDim, AppTheme.bgElevated),
        _legendItem('EOF (Fin)', AppTheme.neonPink, AppTheme.neonPink.withOpacity(0.15)),
        _legendItem('N → Siguiente', AppTheme.neonGreen, AppTheme.neonGreen.withOpacity(0.10)),
        _legendItem('Destacado', AppTheme.neonCyan, AppTheme.neonCyan.withOpacity(0.25)),
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
            border: Border.all(color: textColor.withOpacity(0.4)),
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
    final stats = fatTable.getStats();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: AppTheme.glassCard(borderRadius: 8),
      child: Row(
        children: [
          _statItem('Total', '${stats['totalBlocks']}', AppTheme.textSecondary),
          _statItem('Libres', '${stats['freeBlocks']}', AppTheme.textDim),
          _statItem('Usados', '${stats['usedBlocks']}', AppTheme.neonGreen),
          _statItem('Archivos', '${stats['fileCount']}', AppTheme.neonAmber),
          _statItem('Promedio', '${(stats['averageChainLength'] as double).toStringAsFixed(1)}', AppTheme.neonCyan),
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