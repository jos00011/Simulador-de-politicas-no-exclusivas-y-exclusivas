// lib/screens/memory_tab.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/app_state.dart';
import '../providers/memory_state.dart';
import '../widgets/memory/memory_map.dart';
import '../widgets/memory/memory_metrics.dart';
import '../models/memory_event.dart';
import '../models/memory_result.dart';
import '../widgets/common/neon_button.dart';

class MemoryTab extends StatefulWidget {
  const MemoryTab({super.key});

  @override
  State<MemoryTab> createState() => _MemoryTabState();
}

class _MemoryTabState extends State<MemoryTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  bool _showRamView = false;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    Future.delayed(const Duration(milliseconds: 200), _fadeCtrl.forward);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final memState = context.watch<MemoryState>();

    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildControls(appState, memState),
            const SizedBox(height: 12),
            Expanded(
              child: memState.result == null
                  ? _buildEmptyState(appState, memState)
                  : _buildResult(memState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(AppState appState, MemoryState memState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glassCard(
        borderColor: AppTheme.neonPurple,
        borderRadius: 12,
      ),
      child: Wrap(
        spacing: 12,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Selector de algoritmo
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'ALGORITMO:',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              ...AllocationAlgorithm.values.map((alg) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _AlgChip(
                      label: alg.displayName,
                      selected: memState.algorithm == alg,
                      onTap: () => memState.setAlgorithm(alg),
                    ),
                  )),
            ],
          ),
          // Tamaño de memoria
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'TAMAÑO:',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 70,
                child: TextFormField(
                  initialValue: memState.totalMemory.toString(),
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    suffixText: 'KB',
                    suffixStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null && n > 0) memState.setTotalMemory(n);
                  },
                ),
              ),
            ],
          ),
          // Acciones
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              NeonButton(
                text: _showRamView ? 'OCULTAR RAM' : 'VER RAM',
                icon: _showRamView ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.neonPurple,
                onPressed: () => setState(() => _showRamView = !_showRamView),
                outlined: true,
              ),
              const SizedBox(width: 8),
              NeonButton(
                text: memState.isAnimating ? 'EJECUTANDO...' : 'SIMULAR MEMORIA',
                icon: memState.isAnimating ? null : Icons.memory,
                color: AppTheme.neonPurple,
                onPressed: appState.processes.isEmpty || memState.isAnimating
                    ? null
                    : () => memState.runSimulation(appState.processes),
                isLoading: memState.isAnimating,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppState appState, MemoryState memState) {
    if (appState.processes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.storage, color: AppTheme.textDim, size: 48),
            SizedBox(height: 12),
            Text(
              'Carga procesos en el Simulador primero',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
            ),
            SizedBox(height: 6),
            Text(
              'Luego configura el algoritmo y pulsa "SIMULAR MEMORIA"',
              style: TextStyle(color: AppTheme.textDim, fontSize: 11),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.memory, color: AppTheme.textDim, size: 48),
          const SizedBox(height: 12),
          Text(
            '${appState.processes.length} proceso(s) disponibles',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            '${appState.processes.fold(0, (s, p) => s + p.memorySize)} KB solicitados',
            style: const TextStyle(color: AppTheme.textDim, fontSize: 11),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pulsa "SIMULAR MEMORIA" para ejecutar la asignación',
            style: TextStyle(color: AppTheme.textDim, fontSize: 11),
          ),
          if (memState.errorMessage != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.neonRed.withValues(alpha: 0.1),
                border: Border.all(color: AppTheme.neonRed.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                memState.errorMessage!,
                style: const TextStyle(color: AppTheme.neonRed, fontSize: 11),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildResult(MemoryState memState) {
    final result = memState.result!;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna principal
        Expanded(
          flex: 7,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MemoryMetricsWidget(result: result),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: AppTheme.glassCard(
                    borderColor: AppTheme.neonPurple,
                    borderRadius: 12,
                  ),
                  child: MemoryMapWidget(
                    blocks: memState.currentBlocks,
                    totalMemory: memState.totalMemory,
                    highlightBlock: memState.currentEvent?.type == MemoryEventType.allocate
                        ? memState.currentBlocks.firstWhere(
                            (b) => b.isOccupied && b.processId == memState.currentEvent?.processId,
                            orElse: () => memState.currentBlocks.first,
                          )
                        : null,
                    showRamView: _showRamView,
                    algorithm: memState.algorithm,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStepControls(memState),
                const SizedBox(height: 12),
                if (memState.algorithm != AllocationAlgorithm.buddySystem)
                  _buildCompactionControls(memState),
              ],
            ),
          ),
        ),
        // Divisor
        Container(width: 1, color: AppTheme.borderDark),
        // Columna derecha: Eventos
        SizedBox(
          width: 320,
          child: _buildEventLog(memState),
        ),
      ],
    );
  }

  Widget _buildStepControls(MemoryState memState) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: AppTheme.glassCard(
        borderColor: AppTheme.neonPurple,
        borderRadius: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Paso ${memState.stepIndex} / ${memState.totalSteps}',
                style: const TextStyle(
                  color: AppTheme.neonPurple,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (memState.isAnimating) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(
                    strokeWidth: 1.5,
                    color: AppTheme.neonPurple,
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
            value: memState.stepIndex.toDouble(),
            min: 0,
            max: memState.totalSteps.toDouble(),
            divisions: memState.totalSteps > 0 ? memState.totalSteps : 1,
            activeColor: AppTheme.neonPurple,
            inactiveColor: AppTheme.borderDark,
            onChanged: (v) => memState.goToStep(v.round()),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _stepBtn(Icons.skip_previous, () => memState.goToStep(0)),
              const SizedBox(width: 6),
              _stepBtn(Icons.chevron_left, () => memState.goToStep(memState.stepIndex - 1)),
              const SizedBox(width: 6),
              _stepBtn(Icons.chevron_right, () => memState.goToStep(memState.stepIndex + 1)),
              const SizedBox(width: 6),
              _stepBtn(Icons.skip_next, () => memState.goToStep(memState.totalSteps)),
            ],
          ),
          if (memState.currentEvent != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _eventColor(memState.currentEvent!.type).withValues(alpha: 0.08),
                border: Border.all(
                  color: _eventColor(memState.currentEvent!.type).withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _eventIcon(memState.currentEvent!.type),
                    color: _eventColor(memState.currentEvent!.type),
                    size: 12,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      memState.currentEvent!.description,
                      style: TextStyle(
                        color: _eventColor(memState.currentEvent!.type),
                        fontSize: 10,
                        height: 1.4,
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

  Widget _buildCompactionControls(MemoryState memState) {
    final fragmentation = memState.result?.externalFragmentation ?? 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: fragmentation > 0
            ? AppTheme.neonOrange.withValues(alpha: 0.08)
            : AppTheme.bgElevated,
        border: Border.all(
          color: fragmentation > 0
              ? AppTheme.neonOrange.withValues(alpha: 0.3)
              : AppTheme.borderDark,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.compress,
            color: fragmentation > 0 ? AppTheme.neonOrange : AppTheme.textDim,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compactación de Memoria',
                  style: TextStyle(
                    color: fragmentation > 0 ? AppTheme.neonOrange : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  fragmentation > 0
                      ? 'Fragmentación externa: $fragmentation KB en ${memState.result!.freeBlocks} huecos'
                      : 'Sin fragmentación externa detectable',
                  style: const TextStyle(color: AppTheme.textDim, fontSize: 10),
                ),
              ],
            ),
          ),
          NeonButton(
            text: 'COMPACTAR',
            icon: Icons.compress,
            color: fragmentation > 0 ? AppTheme.neonOrange : AppTheme.textDim,
            onPressed: fragmentation > 0 ? memState.compactMemory : null,
            outlined: true,
          ),
        ],
      ),
    );
  }

  Color _eventColor(MemoryEventType t) {
    switch (t) {
      case MemoryEventType.allocate:
        return AppTheme.neonAmber;
      case MemoryEventType.fail:
        return AppTheme.neonRed;
      case MemoryEventType.deallocate:
        return AppTheme.textSecondary;
      case MemoryEventType.compact:
        return AppTheme.neonOrange;
      case MemoryEventType.buddyMerge:
        return AppTheme.neonGreen;
      case MemoryEventType.buddySplit:
        return AppTheme.neonCyan;
    }
  }

  IconData _eventIcon(MemoryEventType t) {
    switch (t) {
      case MemoryEventType.allocate:
        return Icons.add_box_outlined;
      case MemoryEventType.fail:
        return Icons.error_outline;
      case MemoryEventType.deallocate:
        return Icons.remove_circle_outline;
      case MemoryEventType.compact:
        return Icons.compress;
      case MemoryEventType.buddyMerge:
        return Icons.merge_type;
      case MemoryEventType.buddySplit:
        return Icons.merge_type;
    }
  }

  Widget _buildEventLog(MemoryState memState) {
    final events = memState.result?.events ?? [];

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
                color: AppTheme.neonPurple,
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
              final isCurrent = memState.stepIndex == i + 1;
              final isPast = memState.stepIndex > i + 1;
              final color = _eventColor(e.type);

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
                            color: isCurrent ? color : (isPast ? color.withValues(alpha: 0.3) : AppTheme.bgElevated),
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
                              Icon(_eventIcon(e.type), color: color, size: 11),
                              const SizedBox(width: 4),
                              Text(
                                e.type == MemoryEventType.allocate
                                    ? 'ASIGNADO'
                                    : e.type == MemoryEventType.fail
                                        ? 'FALLO'
                                        : 'LIBERADO',
                                style: TextStyle(
                                  color: color,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              if (e.processId != null) ...[
                                const SizedBox(width: 4),
                                Text(
                                  e.processId!,
                                  style: TextStyle(
                                    color: AppTheme.processColor(e.processId!),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                              const Spacer(),
                              if (e.requestedSize != null)
                                Text(
                                  '${e.requestedSize}KB',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          if (e.allocatedStart != null)
                            Text(
                              '@${e.allocatedStart} — ${e.allocatedSize}KB',
                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                            ),
                          Text(
                            'Frag: ${e.fragmentation}KB',
                            style: const TextStyle(color: AppTheme.textDim, fontSize: 8),
                          ),
                          if (e.internalFragmentation > 0)
                            Text(
                              'Frag.interna: ${e.internalFragmentation}KB',
                              style: TextStyle(color: AppTheme.neonOrange, fontSize: 8),
                            ),
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
}

class _AlgChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AlgChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.neonPurple.withValues(alpha: 0.15)
              : AppTheme.bgElevated,
          border: Border.all(
            color: selected ? AppTheme.neonPurple : AppTheme.borderDark,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.neonPurple : AppTheme.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}