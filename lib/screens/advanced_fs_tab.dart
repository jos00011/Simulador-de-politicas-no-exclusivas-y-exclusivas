// lib/screens/advanced_fs_tab.dart
// Pestaña de Asignación Avanzada (FAT, Extensión, Multinivel, Bitmap)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/app_state.dart';
import '../providers/file_system_state.dart';
import '../widgets/storage/disk_grid_canvas.dart';
import '../widgets/storage/fat_table_widget.dart';
import '../widgets/storage/bitmap_widget.dart';
import '../widgets/storage/inode_viewer.dart';
import '../widgets/storage/extent_list_widget.dart';
import '../models/file_allocation_event.dart';

class AdvancedFsTab extends StatelessWidget {
  const AdvancedFsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final fsState = context.watch<FileSystemState>();

    if (fsState.result == null) {
      return _buildEmptyState(appState, fsState);
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna principal (70%)
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mapa de disco
                DiskGridCanvas(
                  blocks: fsState.currentBlocks,
                  totalBlocks: fsState.result!.totalBlocks,
                  blockSize: fsState.blockSize,
                  currentEvent: fsState.currentEvent,
                  animationEnabled: true,
                ),
                const SizedBox(height: 12),
                // Visualizador específico del método
                _buildVisualizer(fsState),
                const SizedBox(height: 12),
                // Controles de paso
                _buildStepControls(fsState),
              ],
            ),
          ),
        ),
        // Divisor
        Container(width: 1, color: AppTheme.borderDark),
        // Columna derecha: Eventos
        SizedBox(
          width: 320,
          child: _buildEventLog(fsState),
        ),
      ],
    );
  }

  Widget _buildVisualizer(FileSystemState fsState) {
    final method = fsState.method;

    switch (method) {
      case FsMethod.fat:
        if (fsState.fatTable != null) {
          return FATTableWidget(
            fatTable: fsState.fatTable!,
            highlightChain: fsState.currentEvent?.allocatedBlocks,
          );
        }
        break;
      case FsMethod.extent:
        if (fsState.fileExtents != null) {
          return ExtentListWidget(
            fileExtents: fsState.fileExtents!,
            selectedFileId: fsState.currentEvent?.fileId,
          );
        }
        break;
      case FsMethod.multilevel:
        if (fsState.inodes != null) {
          return InodeViewer(
            inodes: fsState.inodes!,
            selectedFileId: fsState.currentEvent?.fileId,
          );
        }
        break;
      case FsMethod.bitmap:
        if (fsState.bitmap != null) {
          return BitmapWidget(
            bitmap: fsState.bitmap!,
            highlightBlocks: fsState.currentEvent?.allocatedBlocks,
          );
        }
        break;
      default:
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: AppTheme.glassCard(borderRadius: 12),
          child: Text(
            'Visualizador no disponible para ${method.displayName}',
            style: const TextStyle(color: AppTheme.textSecondary),
          ),
        );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glassCard(borderRadius: 12),
      child: const Text(
        'No hay datos para visualizar',
        style: TextStyle(color: AppTheme.textSecondary),
      ),
    );
  }

  Widget _buildStepControls(FileSystemState fsState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glassCard(
        borderColor: AppTheme.neonCyan,
        borderRadius: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Paso ${fsState.stepIndex} / ${fsState.totalSteps}',
                style: const TextStyle(
                  color: AppTheme.neonCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (fsState.isAnimating) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppTheme.neonCyan,
                  ),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Animando...',
                  style: TextStyle(color: AppTheme.textDim, fontSize: 10),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: fsState.stepIndex.toDouble(),
            min: 0,
            max: fsState.totalSteps.toDouble(),
            divisions: fsState.totalSteps > 0 ? fsState.totalSteps : 1,
            activeColor: AppTheme.neonCyan,
            inactiveColor: AppTheme.borderDark,
            onChanged: (v) => fsState.goToStep(v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepBtn(Icons.skip_previous, () => fsState.goToStep(0)),
              const SizedBox(width: 6),
              _stepBtn(Icons.chevron_left, () => fsState.goToStep(fsState.stepIndex - 1)),
              const SizedBox(width: 6),
              _stepBtn(Icons.chevron_right, () => fsState.goToStep(fsState.stepIndex + 1)),
              const SizedBox(width: 6),
              _stepBtn(Icons.skip_next, () => fsState.goToStep(fsState.totalSteps)),
            ],
          ),
          if (fsState.currentEvent != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.neonCyan.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppTheme.neonCyan.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                fsState.currentEvent!.description,
                style: const TextStyle(
                  color: AppTheme.neonCyan,
                  fontSize: 10,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _stepBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.borderDark),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.textSecondary, size: 14),
      ),
    );
  }

  Widget _buildEventLog(FileSystemState fsState) {
    final events = fsState.advancedResult?.events ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: AppTheme.bgElevated,
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                color: AppTheme.neonCyan,
                margin: const EdgeInsets.only(right: 8),
              ),
              const Text(
                'REGISTRO DE EVENTOS',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Text(
                '${events.length} eventos',
                style: const TextStyle(color: AppTheme.textDim, fontSize: 9),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.borderDark),
        Expanded(
          child: ListView.separated(
            itemCount: events.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.borderDark),
            itemBuilder: (ctx, i) {
              final e = events[i];
              final isCurrent = fsState.stepIndex == i + 1;
              final isPast = fsState.stepIndex > i + 1;
              final color = e.type == FileAllocationEventType.fail
                  ? AppTheme.neonRed
                  : AppTheme.neonCyan;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: isCurrent
                    ? color.withValues(alpha: 0.12)
                    : isPast
                        ? AppTheme.bgCard
                        : AppTheme.bgDeep,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: isCurrent
                                ? color
                                : isPast
                                    ? color.withValues(alpha: 0.3)
                                    : AppTheme.bgElevated,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              color: isCurrent ? AppTheme.bgDeep : color,
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (i < events.length - 1)
                          Container(width: 1, height: 20, color: AppTheme.borderDark),
                      ],
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                e.type == FileAllocationEventType.fail
                                    ? Icons.error_outline
                                    : Icons.folder_open,
                                color: color,
                                size: 11,
                              ),
                              const SizedBox(width: 4),
                              if (e.fileId != null) ...[
                                Text(
                                  e.fileId!,
                                  style: TextStyle(
                                    color: AppTheme.processColor(e.fileId!),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Expanded(
                                child: Text(
                                  e.description,
                                  style: const TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 9,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (e.startBlock != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              'Bloque inicial: ${e.startBlock}  ·  Bloques: ${e.blocksAllocated}',
                              style: const TextStyle(
                                color: AppTheme.textDim,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(AppState appState, FileSystemState fsState) {
    if (appState.processes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sd_storage, color: AppTheme.textSecondary, size: 48),
            const SizedBox(height: 16),
            const Text(
              'Carga procesos en el Simulador primero',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Text(
              'Luego configura el método avanzado y pulsa "SIMULAR"',
              style: const TextStyle(color: AppTheme.textDim, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storage, color: AppTheme.textSecondary, size: 48),
          const SizedBox(height: 16),
          Text(
            'Selecciona un método avanzado y pulsa SIMULAR',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(
            '${appState.processes.length} procesos disponibles',
            style: const TextStyle(color: AppTheme.textDim, fontSize: 11),
          ),
          if (fsState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neonRed.withValues(alpha: 0.1),
                border: Border.all(color: AppTheme.neonRed.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                fsState.errorMessage!,
                style: const TextStyle(color: AppTheme.neonRed, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}