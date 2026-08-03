// lib/widgets/storage/inode_viewer.dart
// Visualización de Inodos (Multinivel)

import 'package:flutter/material.dart';
import '../../models/inode.dart';
import '../../core/app_theme.dart';
import '../../core/app_constants.dart';

class InodeViewer extends StatelessWidget {
  final Map<String, Inode> inodes;
  final String? selectedFileId;

  const InodeViewer({
    super.key,
    required this.inodes,
    this.selectedFileId,
  });

  @override
  Widget build(BuildContext context) {
    if (inodes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.glassCard(borderRadius: 12),
        child: const Center(
          child: Text(
            'No hay inodos para mostrar',
            style: TextStyle(color: AppTheme.textSecondary),
          ),
        ),
      );
    }

    final fileIds = inodes.keys.toList();
    final selectedId = selectedFileId ?? (fileIds.isNotEmpty ? fileIds.first : null);
    final selectedInode = selectedId != null ? inodes[selectedId] : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de archivo
        if (fileIds.length > 1)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 4,
              children: fileIds.map((id) {
                final isSelected = id == selectedId;
                return GestureDetector(
                  onTap: () {
                    // La selección se maneja en el estado padre
                    // Este widget solo muestra el inodo seleccionado
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.neonCyan.withValues(alpha: 0.2)
                          : AppTheme.bgElevated,
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.neonCyan
                            : AppTheme.borderDark,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      id,
                      style: TextStyle(
                        color: isSelected ? AppTheme.neonCyan : AppTheme.textSecondary,
                        fontSize: 10,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

        if (selectedInode != null) ...[
          _buildInodeCard(selectedId!, selectedInode),
          const SizedBox(height: 8),
          _buildStats(selectedInode),
        ],
      ],
    );
  }

  Widget _buildInodeCard(String fileId, Inode inode) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(
        borderColor: AppTheme.neonPurple,
        borderRadius: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                color: AppTheme.neonPurple,
                margin: const EdgeInsets.only(right: 8),
              ),
              Text(
                'INODO: $fileId',
                style: const TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.neonPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Nivel ${inode.maxIndirectionLevel}',
                  style: const TextStyle(
                    color: AppTheme.neonPurple,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Punteros Directos
          _buildDirectPointers(inode),
          const SizedBox(height: 8),

          // Punteros Indirectos
          _buildIndirectPointers(inode),
          const SizedBox(height: 8),

          // Diagrama de estructura
          _buildStructureDiagram(inode),
        ],
      ),
    );
  }

  Widget _buildDirectPointers(Inode inode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PUNTEROS DIRECTOS',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: List.generate(AppConstants.directPointers, (i) {
            final value = inode.direct[i];
            final hasValue = value != -1;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: hasValue
                    ? AppTheme.neonGreen.withValues(alpha: 0.15)
                    : AppTheme.bgElevated,
                border: Border.all(
                  color: hasValue
                      ? AppTheme.neonGreen.withValues(alpha: 0.4)
                      : AppTheme.borderDark,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                hasValue ? '$value' : '·',
                style: TextStyle(
                  color: hasValue ? AppTheme.neonGreen : AppTheme.textDim,
                  fontSize: 9,
                  fontWeight: hasValue ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildIndirectPointers(Inode inode) {
    final hasIndirect = inode.singleIndirect != null ||
        inode.doubleIndirect != null ||
        inode.tripleIndirect != null;

    if (!hasIndirect) {
      return const Text(
        'Sin punteros indirectos',
        style: TextStyle(color: AppTheme.textDim, fontSize: 10),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PUNTEROS INDIRECTOS',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            if (inode.singleIndirect != null)
              _indirectChip('Simple', inode.singleIndirect!, AppTheme.neonCyan),
            if (inode.doubleIndirect != null)
              _indirectChip('Doble', inode.doubleIndirect!, AppTheme.neonPurple),
            if (inode.tripleIndirect != null)
              _indirectChip('Triple', inode.tripleIndirect!, AppTheme.neonPink),
          ],
        ),
      ],
    );
  }

  Widget _indirectChip(String label, int block, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.account_tree,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            '$label → $block',
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

  Widget _buildStructureDiagram(Inode inode) {
    final maxLevel = inode.maxIndirectionLevel;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ESTRUCTURA DE INDIRECCIÓN',
            style: TextStyle(
              color: AppTheme.textDim,
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _levelIndicator('Directo', 0, maxLevel >= 0, AppTheme.neonGreen),
              _levelIndicator('Simple', 1, maxLevel >= 1, AppTheme.neonCyan),
              _levelIndicator('Doble', 2, maxLevel >= 2, AppTheme.neonPurple),
              _levelIndicator('Triple', 3, maxLevel >= 3, AppTheme.neonPink),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Capacidad máxima: ${inode.maxDataBlocks} bloques de datos',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _levelIndicator(String label, int level, bool active, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: active ? color.withValues(alpha: 0.15) : AppTheme.bgCard,
          border: Border.all(
            color: active ? color.withValues(alpha: 0.4) : AppTheme.borderDark,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          children: [
            Icon(
              active ? Icons.check_circle : Icons.cancel,
              color: active ? color : AppTheme.textDim,
              size: 12,
            ),
            Text(
              label,
              style: TextStyle(
                color: active ? color : AppTheme.textDim,
                fontSize: 7,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStats(Inode inode) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: AppTheme.glassCard(borderRadius: 8),
      child: Row(
        children: [
          _statItem('Bloques totales', '${inode.totalBlocks}', AppTheme.neonPurple),
          _statItem('Capacidad', '${inode.maxDataBlocks}', AppTheme.neonCyan),
          _statItem('Nivel máximo', '${inode.maxIndirectionLevel}', AppTheme.neonAmber),
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