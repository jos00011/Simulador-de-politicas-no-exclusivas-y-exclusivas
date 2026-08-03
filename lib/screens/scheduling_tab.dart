// lib/screens/scheduling_tab.dart
// Con controles de zoom y scroll mejorados

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/app_state.dart';
import '../widgets/cpu/gantt_chart.dart';
import '../widgets/cpu/metrics_summary.dart';
import '../widgets/common/neon_button.dart';
import '../models/simulation_result.dart';

class SchedulingTab extends StatefulWidget {
  const SchedulingTab({super.key});

  @override
  State<SchedulingTab> createState() => _SchedulingTabState();
}

class _SchedulingTabState extends State<SchedulingTab>
    with SingleTickerProviderStateMixin {
  double _timeScale = 20.0; // Valor más pequeño para ver todo

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final result = state.result;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPolicySelector(state),
          const SizedBox(height: 10),
          if (result != null) ...[
            MetricsSummaryWidget(result: result),
            const SizedBox(height: 10),
          ],
          // Contenedor del Gantt con scroll
          Expanded(
            child: Container(
              decoration: AppTheme.glassCard(
                borderColor: result != null ? AppTheme.neonAmber : AppTheme.borderDark,
                borderRadius: 12,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: result != null
                    ? _GanttView(
                        result: result,
                        ganttStep: state.ganttStep,
                        timeScale: _timeScale,
                      )
                    : _buildEmptyState(state),
              ),
            ),
          ),
          if (result != null) ...[
            const SizedBox(height: 8),
            _buildControls(),
          ],
        ],
      ),
    );
  }

  Widget _buildPolicySelector(AppState state) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: AppTheme.glassCard(
        borderColor: AppTheme.neonAmber,
        borderRadius: 12,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              const Text(
                'POLÍTICA:',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 9,
                  letterSpacing: 1.5,
                ),
              ),
              ...SchedulingPolicy.values.map((policy) => _PolicyChip(
                    label: policy.displayName,
                    selected: state.policy == policy,
                    onTap: () {
                      state.setPolicy(policy);
                      state.resetSimulation();
                    },
                  )),
            ],
          ),
          Wrap(
            spacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              if (state.policy == SchedulingPolicy.rr) ...[
                const Text(
                  'Q:',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                ),
                SizedBox(
                  width: 35,
                  child: TextFormField(
                    initialValue: state.quantum.toString(),
                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 11),
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n > 0) state.setQuantum(n);
                    },
                  ),
                ),
              ],
              if (state.processes.isNotEmpty)
                NeonButton(
                  text: state.isRunning ? '...' : 'SIMULAR',
                  icon: state.isRunning ? null : Icons.play_arrow,
                  color: AppTheme.neonAmber,
                  onPressed: state.isRunning ? null : () => state.runSimulation(),
                  isLoading: state.isRunning,
                  height: 30,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: AppTheme.glassCard(borderRadius: 8),
      child: Row(
        children: [
          const Icon(Icons.zoom_out, color: AppTheme.textSecondary, size: 16),
          const SizedBox(width: 6),
          Expanded(
            child: Slider(
              value: _timeScale,
              min: 8,
              max: 60,
              divisions: 26,
              activeColor: AppTheme.neonAmber,
              inactiveColor: AppTheme.borderDark,
              onChanged: (v) => setState(() => _timeScale = v),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.zoom_in, color: AppTheme.textSecondary, size: 16),
          const SizedBox(width: 6),
          Text(
            '${_timeScale.toStringAsFixed(0)}px',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppState state) {
    if (state.processes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_circle_outline, color: AppTheme.textDim, size: 40),
            SizedBox(height: 10),
            Text(
              'Carga procesos para ver el diagrama de Gantt',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            SizedBox(height: 4),
            Text(
              'Usa "CARGAR ARCHIVO" o "AGREGAR" proceso',
              style: TextStyle(color: AppTheme.textDim, fontSize: 10),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.schedule, color: AppTheme.textDim, size: 40),
          const SizedBox(height: 10),
          Text(
            '${state.processes.length} procesos listos',
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 4),
          const Text(
            'Pulsa "SIMULAR" para ejecutar la planificación',
            style: TextStyle(color: AppTheme.textDim, fontSize: 10),
          ),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.neonRed.withValues(alpha: 0.1),
                border: Border.all(color: AppTheme.neonRed.withValues(alpha: 0.3)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                state.errorMessage!,
                style: const TextStyle(color: AppTheme.neonRed, fontSize: 10),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── GANTT VIEW ───────────────────────────────────────────────────
class _GanttView extends StatefulWidget {
  final SimulationResult result;
  final int ganttStep;
  final double timeScale;

  const _GanttView({
    required this.result,
    required this.ganttStep,
    required this.timeScale,
  });

  @override
  State<_GanttView> createState() => _GanttViewState();
}

class _GanttViewState extends State<_GanttView>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    Future.delayed(const Duration(milliseconds: 50), _fadeCtrl.forward);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.result.ganttChart.length;
    final isAnimating = widget.ganttStep < total;
    final progress = total > 0 ? widget.ganttStep / total : 1.0;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera compacta
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            child: Row(
              children: [
                Container(
                  width: 2,
                  height: 10,
                  color: AppTheme.neonAmber,
                  margin: const EdgeInsets.only(right: 4),
                ),
                Text(
                  'GANTT',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 8,
                    letterSpacing: 1.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                if (isAnimating)
                  Row(
                    children: [
                      const SizedBox(
                        width: 8,
                        height: 8,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: AppTheme.neonAmber,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.ganttStep}/$total',
                        style: const TextStyle(color: AppTheme.textDim, fontSize: 8),
                      ),
                    ],
                  )
                else
                  Text(
                    '${widget.result.processes.length} proc.',
                    style: const TextStyle(color: AppTheme.textDim, fontSize: 8),
                  ),
                if (isAnimating) ...[
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 60,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(1),
                      child: LinearProgressIndicator(
                        value: progress,
                        backgroundColor: AppTheme.bgElevated,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.neonAmber),
                        minHeight: 2,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          // Gantt Chart con scroll
          Expanded(
            child: GanttChartWidget(
              entries: widget.result.ganttChart,
              visibleCount: widget.ganttStep,
              timeScale: widget.timeScale,
            ),
          ),
          // Leyenda solo si hay pocos procesos
          if (widget.result.processes.length <= 15) ...[
            const SizedBox(height: 2),
            _buildLegend(),
          ],
        ],
      ),
    );
  }

  Widget _buildLegend() {
    final processIds = widget.result.processes.map((p) => p.id).toList();

    return SizedBox(
      height: 18,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...processIds.map((pid) {
              final color = AppTheme.processColor(pid);
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      pid,
                      style: TextStyle(
                        color: color,
                        fontSize: 7,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            }),
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppTheme.borderDark,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
                const SizedBox(width: 2),
                const Text(
                  'IDLE',
                  style: TextStyle(
                    color: AppTheme.textDim,
                    fontSize: 7,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── POLICY CHIP ──────────────────────────────────────────────────
class _PolicyChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PolicyChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.neonAmber.withValues(alpha: 0.15)
              : AppTheme.bgElevated,
          border: Border.all(
            color: selected ? AppTheme.neonAmber : AppTheme.borderDark,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.neonAmber : AppTheme.textPrimary,
            fontSize: 9,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}