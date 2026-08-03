// lib/widgets/storage/file_explorer_panel.dart
// Panel lateral para explorar archivos y sus bloques asignados

import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../models/process.dart';

class FileExplorerPanel extends StatelessWidget {
  final List<Process> processes;
  final Map<String, List<int>> allocations;
  final String? selectedFileId;
  final Function(String)? onFileSelected;

  const FileExplorerPanel({
    super.key,
    required this.processes,
    required this.allocations,
    this.selectedFileId,
    this.onFileSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glassCard(
        borderColor: AppTheme.neonCyan,
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
                color: AppTheme.neonCyan,
                margin: const EdgeInsets.only(right: 8),
              ),
              const Text(
                'EXPLORADOR DE ARCHIVOS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: AppTheme.neonCyan.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${allocations.length} archivos',
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
          // Lista de archivos
          Expanded(
            child: allocations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.folder_open,
                          color: AppTheme.textDim,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'No hay archivos asignados',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: allocations.keys.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppTheme.borderDark),
                    itemBuilder: (ctx, i) {
                      final fileId = allocations.keys.elementAt(i);
                      final blocks = allocations[fileId] ?? [];
                      final isSelected = fileId == selectedFileId;
                      final color = AppTheme.processColor(fileId);

                      return _FileItem(
                        fileId: fileId,
                        blocks: blocks,
                        color: color,
                        isSelected: isSelected,
                        onTap: () => onFileSelected?.call(fileId),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FileItem extends StatelessWidget {
  final String fileId;
  final List<int> blocks;
  final Color color;
  final bool isSelected;
  final VoidCallback? onTap;

  const _FileItem({
    required this.fileId,
    required this.blocks,
    required this.color,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color.withOpacity(0.3) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 20,
              color: color,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileId,
                    style: TextStyle(
                      color: isSelected ? color : AppTheme.textPrimary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '${blocks.length} bloques',
                    style: TextStyle(
                      color: AppTheme.textDim,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
            ),
            // Mini previsualización de bloques
            if (blocks.isNotEmpty)
              Container(
                width: 40,
                height: 16,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: blocks.length > 5 ? 5 : blocks.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 1),
                  itemBuilder: (ctx, i) {
                    return Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    );
                  },
                ),
              ),
            if (blocks.length > 5)
              Padding(
                padding: const EdgeInsets.only(left: 2),
                child: Text(
                  '+${blocks.length - 5}',
                  style: TextStyle(
                    color: AppTheme.textDim,
                    fontSize: 8,
                  ),
                ),
              ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right,
              color: isSelected ? color : AppTheme.textDim,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}