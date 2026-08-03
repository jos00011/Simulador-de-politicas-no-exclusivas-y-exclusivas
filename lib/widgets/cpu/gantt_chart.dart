// lib/widgets/cpu/gantt_chart.dart
// VERSIÓN CON SCROLL HORIZONTAL Y VERTICAL FUNCIONAL

import 'package:flutter/material.dart';
import '../../models/gantt_entry.dart';
import '../../core/app_theme.dart';

class GanttChartWidget extends StatefulWidget {
  final List<GanttEntry> entries;
  final int visibleCount;
  final double timeScale;

  const GanttChartWidget({
    super.key,
    required this.entries,
    required this.visibleCount,
    this.timeScale = 40,
  });

  @override
  State<GanttChartWidget> createState() => _GanttChartWidgetState();
}

class _GanttChartWidgetState extends State<GanttChartWidget> {
  final ScrollController _hScroll = ScrollController();
  final ScrollController _vScroll = ScrollController();

  static const double _labelWidth = 52.0;
  static const double _rowHeight = 26.0;
  static const double _rulerHeight = 28.0;

  late Map<String, Color> _colorMap;
  late List<String> _processIds;

  @override
  void initState() {
    super.initState();
    _buildColorMap();
  }

  @override
  void didUpdateWidget(GanttChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.entries != widget.entries) {
      _buildColorMap();
    }
  }

  void _buildColorMap() {
    _colorMap = {};
    _processIds = [];
    int idx = 0;
    for (final e in widget.entries) {
      if (!e.isIdle && !_colorMap.containsKey(e.processId)) {
        _colorMap[e.processId] = AppTheme.processColorByIndex(idx++);
        _processIds.add(e.processId);
      }
    }
    final order = <String, int>{};
    for (int i = 0; i < widget.entries.length; i++) {
      final e = widget.entries[i];
      if (!e.isIdle && !order.containsKey(e.processId)) {
        order[e.processId] = i;
      }
    }
    _processIds.sort((a, b) => (order[a] ?? 0).compareTo(order[b] ?? 0));
  }

  Color _colorFor(String pid) => _colorMap[pid] ?? AppTheme.textDim;

  @override
  void dispose() {
    _hScroll.dispose();
    _vScroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.entries.take(widget.visibleCount).toList();
    if (visible.isEmpty) {
      return const Center(
        child: Text(
          'Cargando diagrama...',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
      );
    }

    final totalTime = widget.entries.isNotEmpty ? widget.entries.last.endTime : 0;
    final chartWidth = totalTime * widget.timeScale;

    final rowHeight = _processIds.length > 20 ? 22.0 : _rowHeight;

    final Map<String, List<GanttEntry>> byProcess = {};
    for (final pid in _processIds) {
      byProcess[pid] = visible.where((e) => e.processId == pid).toList();
    }

    return Column(
      children: [
        // RULER (con scroll horizontal sincronizado)
        _buildRuler(totalTime, chartWidth),
        // CUERPO PRINCIPAL (scroll horizontal + vertical)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Etiquetas de procesos (scroll vertical sincronizado)
              _buildLabels(rowHeight),
              // Scroll horizontal + vertical
              Expanded(
                child: Scrollbar(
                  controller: _hScroll,
                  thumbVisibility: true,
                  child: Scrollbar(
                    controller: _vScroll,
                    thumbVisibility: true,
                    child: SingleChildScrollView(
                      controller: _hScroll,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: SingleChildScrollView(
                        controller: _vScroll,
                        scrollDirection: Axis.vertical,
                        physics: const BouncingScrollPhysics(),
                        child: _buildBody(byProcess, totalTime, chartWidth, rowHeight),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRuler(int totalTime, double chartWidth) {
    final step = _labelStep(totalTime);
    return Container(
      height: _rulerHeight,
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderDark, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          // Espacio para las etiquetas
          SizedBox(
            width: _labelWidth,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: AppTheme.borderDark, width: 0.5),
                ),
              ),
            ),
          ),
          // Ruler con scroll horizontal
          Expanded(
            child: SingleChildScrollView(
              controller: _hScroll,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: chartWidth,
                height: _rulerHeight,
                child: CustomPaint(
                  painter: _RulerPainter(
                    totalTime: totalTime,
                    timeScale: widget.timeScale,
                    step: step,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabels(double rowHeight) {
    return SizedBox(
      width: _labelWidth,
      child: SingleChildScrollView(
        controller: _vScroll,
        scrollDirection: Axis.vertical,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: _processIds.map((pid) {
            final color = _colorFor(pid);
            final isEven = _processIds.indexOf(pid).isEven;
            return Container(
              height: rowHeight,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 3),
              decoration: BoxDecoration(
                color: isEven
                    ? AppTheme.bgDeep.withValues(alpha: 0.3)
                    : Colors.transparent,
                border: Border(
                  right: BorderSide(color: AppTheme.borderDark, width: 0.5),
                  bottom: BorderSide(color: AppTheme.borderDark, width: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(width: 3, height: 14, color: color),
                  const SizedBox(width: 3),
                  Expanded(
                    child: Text(
                      pid,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: rowHeight > 24 ? 9 : 7,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody(
    Map<String, List<GanttEntry>> byProcess,
    int totalTime,
    double chartWidth,
    double rowHeight,
  ) {
    final fontSize = _processIds.length > 30 ? 6.0 : 8.0;

    return SizedBox(
      width: chartWidth,
      child: Column(
        children: _processIds.asMap().entries.map((entry) {
          final pid = entry.value;
          final index = entry.key;
          final rowEntries = byProcess[pid] ?? [];
          final isEven = index.isEven;
          return _buildRow(pid, rowEntries, totalTime, chartWidth, rowHeight, fontSize, isEven);
        }).toList(),
      ),
    );
  }

  Widget _buildRow(
    String pid,
    List<GanttEntry> rowEntries,
    int totalTime,
    double chartWidth,
    double rowHeight,
    double fontSize,
    bool isEven,
  ) {
    final color = _colorFor(pid);
    return Container(
      height: rowHeight,
      width: chartWidth,
      decoration: BoxDecoration(
        color: isEven
            ? AppTheme.bgDeep.withValues(alpha: 0.15)
            : Colors.transparent,
        border: Border(
          bottom: BorderSide(color: AppTheme.borderDark, width: 0.3),
        ),
      ),
      child: Stack(
        children: [
          // Líneas verticales de tiempo
          ...List.generate(totalTime + 1, (t) {
            if (t % _labelStep(totalTime) != 0) return const SizedBox.shrink();
            return Positioned(
              left: t * widget.timeScale,
              top: 0,
              bottom: 0,
              width: 0.5,
              child: Container(color: AppTheme.borderDark.withValues(alpha: 0.15)),
            );
          }),
          // Bloques de proceso
          ...rowEntries.map((e) {
            final left = e.startTime * widget.timeScale;
            final width = (e.duration * widget.timeScale) - 1;
            if (width <= 1) {
              return Positioned(
                left: left,
                top: 2,
                height: rowHeight - 4,
                width: 2,
                child: Container(
                  color: color,
                ),
              );
            }

            return Positioned(
              left: left,
              top: 2,
              height: rowHeight - 4,
              width: width,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.85),
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.2),
                      blurRadius: 2,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: width > 16
                    ? FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          pid,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: fontSize,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            );
          }),
        ],
      ),
    );
  }

  int _labelStep(int totalTime) {
    if (totalTime <= 20) return 1;
    if (totalTime <= 50) return 5;
    if (totalTime <= 100) return 10;
    if (totalTime <= 200) return 20;
    if (totalTime <= 500) return 25;
    if (totalTime <= 1000) return 50;
    if (totalTime <= 2000) return 100;
    return 200;
  }
}

class _RulerPainter extends CustomPainter {
  final int totalTime;
  final double timeScale;
  final int step;

  const _RulerPainter({
    required this.totalTime,
    required this.timeScale,
    required this.step,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppTheme.borderDark
      ..strokeWidth = 0.5;

    const textStyle = TextStyle(
      color: AppTheme.textSecondary,
      fontSize: 8,
      fontWeight: FontWeight.w400,
    );

    // Fondo
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppTheme.bgCard,
    );

    // Línea inferior
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      linePaint,
    );

    // Dibujar marcas de tiempo
    for (int t = 0; t <= totalTime; t++) {
      final x = t * timeScale;
      final isMajor = t % step == 0;

      if (isMajor && x <= size.width) {
        // Línea principal
        canvas.drawLine(
          Offset(x, size.height - 10),
          Offset(x, size.height - 1),
          linePaint..color = AppTheme.neonAmber.withValues(alpha: 0.4),
        );
        // Número
        final tp = TextPainter(
          text: TextSpan(text: '$t', style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, 2));
      } else if (x <= size.width) {
        // Línea secundaria
        canvas.drawLine(
          Offset(x, size.height - 5),
          Offset(x, size.height - 1),
          linePaint..color = AppTheme.borderDark,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_RulerPainter old) =>
      old.totalTime != totalTime ||
      old.timeScale != timeScale ||
      old.step != step;
}