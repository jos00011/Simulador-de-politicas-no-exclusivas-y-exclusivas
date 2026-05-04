// lib/widgets/gantt_chart.dart

import 'package:flutter/material.dart';
import '../models/gantt_entry.dart';
import '../utils/app_theme.dart';

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
  final ScrollController _hScroll = ScrollController(); // horizontal (tiempo)
  final ScrollController _vScroll = ScrollController(); // vertical (procesos)
  final ScrollController _rulerScroll = ScrollController(); // regla sincronizada

  static const double _labelWidth = 48.0;
  static const double _rowHeight = 32.0;
  static const double _rulerHeight = 28.0;

  @override
  void dispose() {
    _hScroll.dispose();
    _vScroll.dispose();
    _rulerScroll.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Sincroniza scroll horizontal del cuerpo con el ruler
    _hScroll.addListener(() {
      if (_rulerScroll.hasClients &&
          _rulerScroll.offset != _hScroll.offset) {
        _rulerScroll.jumpTo(_hScroll.offset);
      }
    });
    _rulerScroll.addListener(() {
      if (_hScroll.hasClients && _hScroll.offset != _rulerScroll.offset) {
        _hScroll.jumpTo(_rulerScroll.offset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.entries.take(widget.visibleCount).toList();
    if (visible.isEmpty) return const SizedBox.shrink();

    final totalTime = widget.entries.isNotEmpty ? widget.entries.last.endTime : 0;
    final chartWidth = totalTime * widget.timeScale;

    // IDs únicos de procesos (sin IDLE), en orden de aparición
    final processIds = <String>[];
    for (final e in widget.entries) {
      if (!e.isIdle && !processIds.contains(e.processId)) {
        processIds.add(e.processId);
      }
    }

    // Construye mapa pid -> lista de GanttEntry visibles
    final Map<String, List<GanttEntry>> byProcess = {};
    for (final pid in processIds) {
      byProcess[pid] = visible.where((e) => e.processId == pid).toList();
    }

    return Column(
      children: [
        // Ruler (regla de tiempo) — sincronizada con scroll horizontal del cuerpo
        _buildRuler(totalTime, chartWidth),
        // Cuerpo: scroll vertical de filas + scroll horizontal de bloques
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Columna de etiquetas fija (no hace scroll horizontal)
              _buildLabels(processIds),
              // Área de bloques con doble scroll
              Expanded(
                child: SingleChildScrollView(
                  controller: _vScroll,
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    controller: _hScroll,
                    scrollDirection: Axis.horizontal,
                    child: _buildBody(processIds, byProcess, totalTime, chartWidth),
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
    // Calcula cada cuántos ticks poner etiqueta para no saturar
    final step = _labelStep(totalTime);

    return SizedBox(
      height: _rulerHeight,
      child: Row(
        children: [
          // Espacio igual al ancho de etiquetas
          SizedBox(width: _labelWidth),
          // Ruler scrolleable sincronizado
          Expanded(
            child: SingleChildScrollView(
              controller: _rulerScroll,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: SizedBox(
                width: chartWidth,
                child: CustomPaint(
                  size: Size(chartWidth, _rulerHeight),
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

  Widget _buildLabels(List<String> processIds) {
    return SizedBox(
      width: _labelWidth,
      child: SingleChildScrollView(
        controller: _vScroll,
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: processIds.map((pid) {
            final color = AppTheme.processColor(pid);
            return Container(
              height: _rowHeight,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
              ),
              child: Row(
                children: [
                  Container(width: 3, height: 18, color: color),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      pid,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
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
    List<String> processIds,
    Map<String, List<GanttEntry>> byProcess,
    int totalTime,
    double chartWidth,
  ) {
    return SizedBox(
      width: chartWidth,
      child: Column(
        children: processIds.map((pid) {
          final rowEntries = byProcess[pid] ?? [];
          return _buildRow(pid, rowEntries, totalTime, chartWidth);
        }).toList(),
      ),
    );
  }

  Widget _buildRow(
    String pid,
    List<GanttEntry> rowEntries,
    int totalTime,
    double chartWidth,
  ) {
    final color = AppTheme.processColor(pid);
    return SizedBox(
      height: _rowHeight,
      width: chartWidth,
      child: Stack(
        children: [
          // Fondo de fila
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.bgElevated,
                border: Border(
                  bottom: BorderSide(color: AppTheme.border, width: 0.5),
                ),
              ),
            ),
          ),
          // Líneas verticales de grid cada ciertos ticks
          ...List.generate(totalTime + 1, (t) {
            if (t % _labelStep(totalTime) != 0) return const SizedBox.shrink();
            return Positioned(
              left: t * widget.timeScale,
              top: 0,
              bottom: 0,
              width: 0.5,
              child: Container(color: AppTheme.border.withValues(alpha: 0.4)),
            );
          }),
          // Bloques del proceso
          ...rowEntries.map((e) {
            final left = e.startTime * widget.timeScale;
            final width = (e.duration * widget.timeScale) - 1;
            if (width <= 0) return const SizedBox.shrink();
            return Positioned(
              left: left,
              top: 3,
              height: _rowHeight - 6,
              width: width,
              child: Container(
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.88),
                  border: Border.all(color: color, width: 0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
                alignment: Alignment.center,
                child: width > 16
                    ? Text(
                        pid,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          color: AppTheme.bg,
                          fontSize: width > 30 ? 9 : 7,
                          fontWeight: FontWeight.w800,
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
    if (totalTime <= 500) return 25;
    if (totalTime <= 1000) return 50;
    return 100;
  }
}

class _RulerPainter extends CustomPainter {
  final int totalTime;
  final double timeScale;
  final int step;

  _RulerPainter({
    required this.totalTime,
    required this.timeScale,
    required this.step,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppTheme.border
      ..strokeWidth = 0.8;

    final textStyle = const TextStyle(
      color: AppTheme.sepia,
      fontSize: 9,
    );

    // Fondo del ruler
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = AppTheme.bgCard,
    );

    // Línea base
    canvas.drawLine(
      Offset(0, size.height - 1),
      Offset(size.width, size.height - 1),
      linePaint,
    );

    for (int t = 0; t <= totalTime; t++) {
      final x = t * timeScale;
      final isMajor = t % step == 0;

      if (isMajor) {
        // Tick mayor
        canvas.drawLine(
          Offset(x, size.height - 10),
          Offset(x, size.height - 1),
          linePaint..color = AppTheme.amber,
        );
        // Etiqueta
        final tp = TextPainter(
          text: TextSpan(text: '$t', style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(x - tp.width / 2, 2));
      } else {
        // Tick menor
        canvas.drawLine(
          Offset(x, size.height - 5),
          Offset(x, size.height - 1),
          linePaint..color = AppTheme.border,
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
