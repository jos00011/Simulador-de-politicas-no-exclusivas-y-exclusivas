// lib/screens/memory_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../utils/memory_state.dart';
import '../models/memory_result.dart';
import '../models/memory_event.dart';
import '../widgets/memory_map.dart';
import '../widgets/memory_metrics.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({super.key});

  @override
  State<MemoryScreen> createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final _memCtrl = TextEditingController(text: '512');

  @override
  void dispose() {
    _memCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final memState = context.watch<MemoryState>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _buildAppBar(context, memState),
      body: Column(
        children: [
          // Config toolbar
          _buildConfigBar(context, appState, memState),
          // Content
          Expanded(
            child: memState.result == null
                ? _buildEmpty(appState)
                : _buildResult(memState),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, MemoryState memState) {
    return AppBar(
      backgroundColor: AppTheme.bgCard,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.sepia, size: 16),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(width: 3, height: 18, color: AppTheme.rust, margin: const EdgeInsets.only(right: 10)),
          const Text('MEMORIA DINÁMICA',
              style: TextStyle(color: AppTheme.rust, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 3)),
          if (memState.result != null) ...[
            const SizedBox(width: 8),
            Text('/ ${memState.result!.algorithm.displayName}',
                style: const TextStyle(color: AppTheme.sepia, fontSize: 12)),
          ],
        ],
      ),
      actions: [
        if (memState.result != null)
          TextButton.icon(
            onPressed: memState.reset,
            icon: const Icon(Icons.refresh, size: 13, color: AppTheme.sepia),
            label: const Text('Reiniciar', style: TextStyle(color: AppTheme.sepia, fontSize: 11)),
          ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.border),
      ),
    );
  }

  Widget _buildConfigBar(BuildContext context, AppState appState, MemoryState memState) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          // Algorithm selector
          const Text('ALGORITMO:', style: TextStyle(color: AppTheme.sepia, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(width: 10),
          ...AllocationAlgorithm.values.map((alg) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _AlgChip(
                  label: alg.displayName,
                  selected: memState.algorithm == alg,
                  onTap: () => memState.setAlgorithm(alg),
                ),
              )),
          const SizedBox(width: 16),
          // Memory size
          const Text('MEM. TOTAL:', style: TextStyle(color: AppTheme.sepia, fontSize: 10, letterSpacing: 1.5)),
          const SizedBox(width: 8),
          SizedBox(
            width: 70,
            child: TextFormField(
              controller: _memCtrl,
              style: const TextStyle(color: AppTheme.cream, fontSize: 12),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                suffixText: 'KB',
                suffixStyle: TextStyle(color: AppTheme.sepia, fontSize: 10),
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                isDense: true,
              ),
              onChanged: (v) {
                final n = int.tryParse(v);
                if (n != null && n > 0) memState.setTotalMemory(n);
              },
            ),
          ),
          const Spacer(),
          // Run button
          SizedBox(
            height: 34,
            child: ElevatedButton.icon(
              onPressed: appState.processes.isEmpty
                  ? null
                  : () => memState.runSimulation(appState.processes),
              icon: const Icon(Icons.memory, size: 15),
              label: const Text('SIMULAR MEMORIA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.rust,
                foregroundColor: AppTheme.cream,
                disabledBackgroundColor: AppTheme.rust.withValues(alpha: 0.3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppState appState) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.storage, color: AppTheme.sepia, size: 48),
          const SizedBox(height: 16),
          Text(
            appState.processes.isEmpty
                ? 'Carga procesos en el Simulador primero'
                : 'Configura el algoritmo y pulsa "Simular Memoria"',
            style: const TextStyle(color: AppTheme.sepia, fontSize: 13),
          ),
          if (appState.processes.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              '${appState.processes.length} proceso(s) disponibles  ·  '
              '${appState.processes.fold(0, (s, p) => s + p.memorySize)} KB solicitados',
              style: const TextStyle(color: AppTheme.amberDim, fontSize: 11),
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
        // Left: Memory visualization + metrics
        Expanded(
          flex: 5,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Metrics row
                MemoryMetricsWidget(result: result),
                const SizedBox(height: 16),
                // Memory map
                const _SectionHeader(title: 'MAPA DE MEMORIA', color: AppTheme.rust),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    border: Border.all(color: AppTheme.border),
                    borderRadius: BorderRadius.circular(4),
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
                  ),
                ),
                const SizedBox(height: 16),
                // Step controls
                const _SectionHeader(title: 'CONTROL DE PASOS', color: AppTheme.sepia),
                const SizedBox(height: 8),
                _buildStepControls(memState),
                const SizedBox(height: 16),
                // Compaction button
                _buildCompactionSection(memState),
              ],
            ),
          ),
        ),
        // Divider
        Container(width: 1, color: AppTheme.border),
        // Right: Event log
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
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Paso ${memState.stepIndex} / ${memState.totalSteps}',
                style: const TextStyle(color: AppTheme.amber, fontSize: 11, fontWeight: FontWeight.w700),
              ),
              if (memState.isAnimating) ...[
                const SizedBox(width: 8),
                const SizedBox(
                  width: 10,
                  height: 10,
                  child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.amber),
                ),
                const SizedBox(width: 4),
                const Text('Animando...', style: TextStyle(color: AppTheme.amberDim, fontSize: 10)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.rust,
              inactiveTrackColor: AppTheme.border,
              thumbColor: AppTheme.rust,
              overlayColor: AppTheme.rust.withValues(alpha: 0.2),
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            ),
            child: Slider(
              value: memState.stepIndex.toDouble(),
              min: 0,
              max: memState.totalSteps.toDouble(),
              divisions: memState.totalSteps > 0 ? memState.totalSteps : 1,
              onChanged: (v) => memState.goToStep(v.round()),
            ),
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
                border: Border.all(color: _eventColor(memState.currentEvent!.type).withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Row(
                children: [
                  Icon(_eventIcon(memState.currentEvent!.type),
                      color: _eventColor(memState.currentEvent!.type), size: 12),
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
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Icon(icon, color: AppTheme.sepia, size: 14),
      ),
    );
  }

  Widget _buildCompactionSection(MemoryState memState) {
    final fragmentation = memState.result!.externalFragmentation;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border.all(color: fragmentation > 0 ? AppTheme.rust.withValues(alpha: 0.4) : AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            Icons.compress,
            color: fragmentation > 0 ? AppTheme.rust : AppTheme.sepia,
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
                    color: fragmentation > 0 ? AppTheme.rust : AppTheme.sepia,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  fragmentation > 0
                      ? 'Fragmentación externa: $fragmentation KB en ${memState.result!.freeBlocks} huecos'
                      : 'Sin fragmentación externa detectable',
                  style: const TextStyle(color: AppTheme.sepia, fontSize: 10),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: fragmentation > 0 ? memState.compactMemory : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.rust,
              foregroundColor: AppTheme.cream,
              disabledBackgroundColor: AppTheme.border,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
            child: const Text('COMPACTAR'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventLog(MemoryState memState) {
    final events = memState.result!.events;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: AppTheme.bgElevated,
          child: Row(
            children: [
              Container(width: 3, height: 14, color: AppTheme.rust, margin: const EdgeInsets.only(right: 8)),
              const Text('REGISTRO DE EVENTOS',
                  style: TextStyle(color: AppTheme.sepia, fontSize: 10, letterSpacing: 2)),
              const Spacer(),
              Text('${events.length} eventos',
                  style: const TextStyle(color: AppTheme.amberDim, fontSize: 9)),
            ],
          ),
        ),
        const Divider(height: 1, color: AppTheme.border),
        Expanded(
          child: ListView.separated(
            itemCount: events.length,
            separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.border),
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
                        : AppTheme.bg,
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
                          child: Text('${i + 1}',
                              style: TextStyle(
                                color: isCurrent ? AppTheme.bg : color,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                        if (i < events.length - 1)
                          Container(width: 1, height: 20, color: AppTheme.border),
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
                                style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700, letterSpacing: 1),
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
                                Text('${e.requestedSize}KB',
                                    style: const TextStyle(color: AppTheme.sepia, fontSize: 9)),
                            ],
                          ),
                          const SizedBox(height: 3),
                          if (e.allocatedStart != null)
                            Text(
                              '@${e.allocatedStart} — ${e.allocatedSize}KB',
                              style: const TextStyle(color: AppTheme.sepia, fontSize: 9),
                            ),
                          Text(
                            'Frag: ${e.fragmentation}KB',
                            style: const TextStyle(color: AppTheme.amberDim, fontSize: 8),
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

  Color _eventColor(MemoryEventType t) {
    switch (t) {
      case MemoryEventType.allocate:
        return AppTheme.amber;
      case MemoryEventType.fail:
        return AppTheme.rust;
      case MemoryEventType.deallocate:
        return AppTheme.sepia;
      case MemoryEventType.compact:
        return AppTheme.amberLight;
      case MemoryEventType.buddyMerge:
        return AppTheme.amberLight;
      case MemoryEventType.buddySplit:
        return AppTheme.amberLight;
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
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: color, margin: const EdgeInsets.only(right: 8)),
        Text(title, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 2)),
      ],
    );
  }
}

class _AlgChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _AlgChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppTheme.rust.withValues(alpha: 0.15) : AppTheme.bgElevated,
          border: Border.all(color: selected ? AppTheme.rust : AppTheme.border),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.rust : AppTheme.cream,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
