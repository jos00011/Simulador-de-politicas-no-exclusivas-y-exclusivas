// lib/screens/results_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../widgets/gantt_chart.dart';
import '../widgets/metrics_summary.dart';
import '../widgets/process_table.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key});

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  final _searchCtrl = TextEditingController();
  double _timeScale = 40.0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final result = state.result;

    if (result == null) {
      return const Scaffold(
        backgroundColor: AppTheme.bg,
        body: Center(child: CircularProgressIndicator(color: AppTheme.amber)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _buildAppBar(context, state),
      body: Column(
        children: [
          // MÉTRICAS SIEMPRE ARRIBA
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: MetricsSummaryWidget(result: result),
          ),
          const SizedBox(height: 8),
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(state),
          ),
          const SizedBox(height: 6),
          // Tabs
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  _buildTabBar(),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _GanttTab(
                          result: result,
                          ganttStep: state.ganttStep,
                          timeScale: _timeScale,
                        ),
                        _TableTab(state: state),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState state) {
    return AppBar(
      backgroundColor: AppTheme.bgCard,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.sepia, size: 16),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(width: 3, height: 18, color: AppTheme.amberLight, margin: const EdgeInsets.only(right: 10)),
          const Text('RESULTADOS', style: TextStyle(color: AppTheme.amberLight, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 3)),
          const SizedBox(width: 8),
          Text('/ ${state.result?.policy.name ?? ''}',
              style: const TextStyle(color: AppTheme.sepia, fontSize: 12)),
        ],
      ),
      actions: [
        // Zoom slider para Gantt
        const Icon(Icons.zoom_out, color: AppTheme.sepia, size: 13),
        SizedBox(
          width: 90,
          child: Slider(
            value: _timeScale,
            min: 16,
            max: 80,
            divisions: 16,
            activeColor: AppTheme.amber,
            inactiveColor: AppTheme.border,
            onChanged: (v) => setState(() => _timeScale = v),
          ),
        ),
        const Icon(Icons.zoom_in, color: AppTheme.sepia, size: 13),
        const SizedBox(width: 8),
        TextButton.icon(
          onPressed: () {
            Navigator.pop(context);
            state.resetSimulation();
          },
          icon: const Icon(Icons.refresh, size: 13, color: AppTheme.sepia),
          label: const Text('Nueva sim.', style: TextStyle(color: AppTheme.sepia, fontSize: 11)),
        ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.border),
      ),
    );
  }

  Widget _buildSearchBar(AppState state) {
    return TextField(
      controller: _searchCtrl,
      style: const TextStyle(color: AppTheme.cream, fontSize: 12),
      onChanged: state.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'Buscar proceso por ID...',
        prefixIcon: const Icon(Icons.search, color: AppTheme.sepia, size: 16),
        suffixIcon: _searchCtrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppTheme.sepia, size: 14),
                onPressed: () {
                  _searchCtrl.clear();
                  state.setSearchQuery('');
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.bgCard,
      child: const TabBar(
        indicatorColor: AppTheme.amber,
        indicatorWeight: 2,
        labelColor: AppTheme.amber,
        unselectedLabelColor: AppTheme.sepia,
        labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
        tabs: [
          Tab(text: 'DIAGRAMA DE GANTT'),
          Tab(text: 'TABLA DE PROCESOS'),
        ],
      ),
    );
  }
}

// ─── Gantt Tab ────────────────────────────────────────────────────────────────

class _GanttTab extends StatelessWidget {
  final dynamic result;
  final int ganttStep;
  final double timeScale;

  const _GanttTab({
    required this.result,
    required this.ganttStep,
    required this.timeScale,
  });

  @override
  Widget build(BuildContext context) {
    final total = result.ganttChart.length;
    final isAnimating = ganttStep < total;
    final processCount = (result.processes as List).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 3, height: 14, color: AppTheme.amber,
                margin: const EdgeInsets.only(right: 8),
              ),
              const Text('DIAGRAMA DE GANTT',
                  style: TextStyle(color: AppTheme.sepia, fontSize: 10, letterSpacing: 2)),
              const SizedBox(width: 12),
              if (isAnimating)
                Row(children: [
                  SizedBox(
                    width: 10, height: 10,
                    child: CircularProgressIndicator(
                        strokeWidth: 1.5, color: AppTheme.amber),
                  ),
                  const SizedBox(width: 6),
                  Text('Paso $ganttStep / $total',
                      style: const TextStyle(color: AppTheme.amberDim, fontSize: 10)),
                ])
              else
                Text('$processCount proceso(s) · $total segmentos',
                    style: const TextStyle(color: AppTheme.amberDim, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          // Gantt — ocupa todo el espacio restante
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.bgCard,
                border: Border.all(color: AppTheme.border),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: GanttChartWidget(
                  entries: result.ganttChart,
                  visibleCount: ganttStep,
                  timeScale: timeScale,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Leyenda compacta con scroll horizontal
          SizedBox(
            height: 18,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...result.processes.map<Widget>((p) {
                    final color = AppTheme.processColor(p.id);
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(children: [
                        Container(width: 9, height: 9, color: color),
                        const SizedBox(width: 3),
                        Text(p.id,
                            style: TextStyle(
                                color: color,
                                fontSize: 9,
                                fontWeight: FontWeight.w600)),
                      ]),
                    );
                  }),
                  Row(children: [
                    Container(width: 9, height: 9, color: AppTheme.border),
                    const SizedBox(width: 3),
                    const Text('IDLE',
                        style: TextStyle(color: AppTheme.sepia, fontSize: 9)),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Table Tab ────────────────────────────────────────────────────────────────

class _TableTab extends StatelessWidget {
  final AppState state;

  const _TableTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final processes = state.filteredResultProcesses;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 14, color: AppTheme.amber,
                  margin: const EdgeInsets.only(right: 8)),
              const Text('RESULTADOS POR PROCESO',
                  style: TextStyle(color: AppTheme.sepia, fontSize: 10, letterSpacing: 2)),
              const Spacer(),
              if (state.searchQuery.isNotEmpty)
                Text('${processes.length} resultado(s)',
                    style: const TextStyle(color: AppTheme.amberDim, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ProcessResultTable(
              processes: processes,
              showResults: true,
            ),
          ),
        ],
      ),
    );
  }
}
