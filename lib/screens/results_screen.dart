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

class _ResultsScreenState extends State<ResultsScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  double _timeScale = 40.0;
  late AnimationController _headerAnim;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _headerFade = CurvedAnimation(parent: _headerAnim, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic));
    Future.delayed(const Duration(milliseconds: 80), _headerAnim.forward);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _headerAnim.dispose();
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
          // Metrics — animated entrance
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: MetricsSummaryWidget(result: result),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _buildSearchBar(state),
          ),
          const SizedBox(height: 6),
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
          const Text('RESULTADOS',
              style: TextStyle(color: AppTheme.amberLight, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 3)),
          const SizedBox(width: 8),
          Text('/ ${state.result?.policy.name ?? ''}',
              style: const TextStyle(color: AppTheme.sepia, fontSize: 12)),
        ],
      ),
      actions: [
        const Icon(Icons.zoom_out, color: AppTheme.sepia, size: 13),
        SizedBox(
          width: 90,
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: AppTheme.amber,
              inactiveTrackColor: AppTheme.border,
              thumbColor: AppTheme.amber,
              overlayColor: AppTheme.amber.withValues(alpha: 0.15),
              trackHeight: 2,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
            ),
            child: Slider(
              value: _timeScale,
              min: 16,
              max: 80,
              divisions: 16,
              onChanged: (v) => setState(() => _timeScale = v),
            ),
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
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
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

class _GanttTab extends StatefulWidget {
  final dynamic result;
  final int ganttStep;
  final double timeScale;

  const _GanttTab({required this.result, required this.ganttStep, required this.timeScale});

  @override
  State<_GanttTab> createState() => _GanttTabState();
}

class _GanttTabState extends State<_GanttTab> with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    Future.delayed(const Duration(milliseconds: 200), _fadeCtrl.forward);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.result.ganttChart.length as int;
    final isAnimating = widget.ganttStep < total;
    final processCount = (widget.result.processes as List).length;
    final progress = total > 0 ? widget.ganttStep / total : 1.0;

    return FadeTransition(
      opacity: _fadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with animated progress bar
            _buildGanttHeader(isAnimating, total, processCount, progress),
            const SizedBox(height: 8),
            // Gantt chart
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.bgCard,
                  border: Border.all(color: AppTheme.border),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.amber.withValues(alpha: 0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: GanttChartWidget(
                    entries: widget.result.ganttChart,
                    visibleCount: widget.ganttStep,
                    timeScale: widget.timeScale,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Progress bar
            if (isAnimating) _buildProgressBar(progress),
            const SizedBox(height: 6),
            // Legend
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildGanttHeader(bool isAnimating, int total, int processCount, double progress) {
    return Row(
      children: [
        Container(width: 3, height: 14, color: AppTheme.amber, margin: const EdgeInsets.only(right: 8)),
        const Text('DIAGRAMA DE GANTT',
            style: TextStyle(color: AppTheme.sepia, fontSize: 10, letterSpacing: 2)),
        const SizedBox(width: 12),
        if (isAnimating)
          Row(children: [
            const SizedBox(
              width: 10, height: 10,
              child: CircularProgressIndicator(strokeWidth: 1.5, color: AppTheme.amber),
            ),
            const SizedBox(width: 6),
            Text('Renderizando ${widget.ganttStep} / $total',
                style: const TextStyle(color: AppTheme.amberDim, fontSize: 10)),
          ])
        else
          Row(children: [
            Container(
              width: 6, height: 6,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.amber),
            ),
            const SizedBox(width: 5),
            Text('$processCount proc.  ·  $total segmentos completados',
                style: const TextStyle(color: AppTheme.amberDim, fontSize: 10)),
          ]),
      ],
    );
  }

  Widget _buildProgressBar(double progress) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(2),
      child: LinearProgressIndicator(
        value: progress,
        backgroundColor: AppTheme.bgElevated,
        valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.amber),
        minHeight: 2,
      ),
    );
  }

  Widget _buildLegend() {
    return SizedBox(
      height: 20,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...widget.result.processes.map<Widget>((p) {
              final color = AppTheme.processColor(p.id as String);
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Row(children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(p.id as String,
                      style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 3),
                  Text('${p.burstTime}u',
                      style: const TextStyle(color: AppTheme.sepia, fontSize: 8)),
                ]),
              );
            }),
            Row(children: [
              Container(
                width: 10, height: 10,
                decoration: BoxDecoration(color: AppTheme.border, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 4),
              const Text('IDLE', style: TextStyle(color: AppTheme.sepia, fontSize: 9)),
            ]),
          ],
        ),
      ),
    );
  }
}

// ─── Table Tab ────────────────────────────────────────────────────────────────

class _TableTab extends StatefulWidget {
  final AppState state;

  const _TableTab({required this.state});

  @override
  State<_TableTab> createState() => _TableTabState();
}

class _TableTabState extends State<_TableTab> with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    Future.delayed(const Duration(milliseconds: 150), _fadeCtrl.forward);
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final processes = widget.state.filteredResultProcesses;

    return FadeTransition(
      opacity: CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(width: 3, height: 14, color: AppTheme.amber, margin: const EdgeInsets.only(right: 8)),
                const Text('RESULTADOS POR PROCESO',
                    style: TextStyle(color: AppTheme.sepia, fontSize: 10, letterSpacing: 2)),
                const Spacer(),
                if (widget.state.searchQuery.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.amber.withValues(alpha: 0.1),
                      border: Border.all(color: AppTheme.amber.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('${processes.length} resultado(s)',
                        style: const TextStyle(color: AppTheme.amber, fontSize: 9)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ProcessResultTable(processes: processes, showResults: true),
            ),
          ],
        ),
      ),
    );
  }
}
