// lib/widgets/storage/extent_list_widget.dart
// Visualización de Extensiones (Extents)

import 'package:flutter/material.dart';
import '../../models/extent.dart';
import '../../core/app_theme.dart';

class ExtentListWidget extends StatelessWidget {
  final List<FileExtents> fileExtents;
  final String? selectedFileId;

  const ExtentListWidget({
    super.key,
    required this.fileExtents,
    this.selectedFileId,
  });

  @override
  Widget build(BuildContext context) {
    if (fileExtents.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCard(borderRadius: 12),
        child: const Center(
          child: Text(
            'No hay extensiones para mostrar',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              color: AppTheme.neonAmber,
              margin: const EdgeInsets.only(right: 8),
            ),
            const Text(
              'EXTENSIONES POR ARCHIVO',
              style: TextStyle(
                color: AppTheme.neonAmber,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.neonAmber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${fileExtents.length} archivos',
                style: const TextStyle(
                  color: AppTheme.neonAmber,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Lista de extensiones
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.glassCard(
            borderColor: AppTheme.neonAmber,
            borderRadius: 12,
          ),
          child: Column(
            children: fileExtents.map((fe) {
              final isSelected = fe.fileId == selectedFileId;
              return _buildExtentEntry(fe, isSelected);
            }).toList(),
          ),
        ),
        // Estadísticas
        const SizedBox(height: 8),
        _buildStats(),
      ],
    );
  }

  Widget _buildExtentEntry(FileExtents fe, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.neonAmber.withOpacity(0.12)
            : AppTheme.bgElevated,
        border: Border.all(
          color: isSelected
              ? AppTheme.neonAmber
              : AppTheme.borderDark,
          width: isSelected ? 1.5 : 0.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera del archivo
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                color: AppTheme.processColor(fe.fileId),
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(
                fe.fileId,
                style: TextStyle(
                  color: AppTheme.processColor(fe.fileId),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${fe.totalBlocks} bloques · ${fe.extentCount} extensiones',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // Lista de extensiones
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: fe.extents.map((extent) {
              return _buildExtentChip(extent, isSelected);
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExtentChip(Extent extent, bool isSelected) {
    final color = isSelected ? AppTheme.neonAmber : AppTheme.neonCyan;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(
          color: color.withOpacity(0.4),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.view_array,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            '[${extent.startBlock} → ${extent.endBlock}] (${extent.length})',
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final totalBlocks = fileExtents.fold(0, (sum, fe) => sum + fe.totalBlocks);
    final totalExtents = fileExtents.fold(0, (sum, fe) => sum + fe.extentCount);
    final avgExtentsPerFile = fileExtents.isEmpty ? 0 : totalExtents / fileExtents.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: AppTheme.glassCard(borderRadius: 8),
      child: Row(
        children: [
          _statItem('Archivos', '${fileExtents.length}', AppTheme.neonAmber),
          _statItem('Bloques', '$totalBlocks', AppTheme.neonCyan),
          _statItem('Extensiones', '$totalExtents', AppTheme.neonPurple),
          _statItem('Promedio', '${avgExtentsPerFile.toStringAsFixed(1)}', AppTheme.neonGreen),
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