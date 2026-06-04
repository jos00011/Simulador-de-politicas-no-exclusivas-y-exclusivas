// lib/widgets/memory_map.dart

import 'package:flutter/material.dart';
import '../models/memory_block.dart';
import '../models/memory_result.dart';
import '../utils/app_theme.dart';

class MemoryMapWidget extends StatefulWidget {
  final List<MemoryBlock> blocks;
  final int totalMemory;
  final MemoryBlock? highlightBlock;
  final bool showRamView;
  final AllocationAlgorithm? algorithm;

  const MemoryMapWidget({
    super.key,
    required this.blocks,
    required this.totalMemory,
    this.highlightBlock,
    this.showRamView = false,
    this.algorithm,
  });

  @override
  State<MemoryMapWidget> createState() => _MemoryMapWidgetState();
}

class _MemoryMapWidgetState extends State<MemoryMapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  MemoryBlock? _hovered;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color _blockColor(MemoryBlock b) {
    if (b.isFree) return AppTheme.border;
    return AppTheme.processColor(b.processId ?? '?');
  }

  bool get _isBuddy =>
      widget.algorithm == AllocationAlgorithm.buddySystem;

  @override
  Widget build(BuildContext context) {
    if (widget.totalMemory == 0) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showRamView) ...[
          _buildRamView(),
          const SizedBox(height: 16),
          const Divider(color: AppTheme.border),
          const SizedBox(height: 12),
        ],
        _buildBar(),
        const SizedBox(height: 8),
        _buildAddressLabels(),
        const SizedBox(height: 12),
        if (_isBuddy) ...[
          _buildBuddyLevelLegend(),
          const SizedBox(height: 10),
        ],
        _buildBlockList(),
      ],
    );
  }

  // ─── RAM View ────────────────────────────────────────────────────────────────
  Widget _buildRamView() {
    const cellsPerRow = 32;
    final totalCells = widget.totalMemory;
    final cellSize = 14.0;

    // Build a per-KB color map
    final colorMap = <int, Color>{};
    final labelMap = <int, String>{};
    for (final b in widget.blocks) {
      for (int k = b.startAddress; k < b.startAddress + b.size; k++) {
        if (b.isFree) {
          colorMap[k] = AppTheme.border.withValues(alpha: 0.3);
        } else {
          final base = _blockColor(b);
          // Internal fragmentation bytes are shown darker
          final processSize = b.size;
          final buddySize = b.buddyAllocatedSize ?? b.size;
          final internalStart = b.startAddress + processSize;
          if (k >= internalStart && k < b.startAddress + buddySize) {
            colorMap[k] = base.withValues(alpha: 0.25); // wasted
          } else {
            colorMap[k] = base.withValues(alpha: 0.85);
          }
          labelMap[k] = b.processId ?? '';
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 3,
                height: 13,
                color: AppTheme.amberLight,
                margin: const EdgeInsets.only(right: 6)),
            const Text('VISTA RAM — MAPA DE CELDAS',
                style: TextStyle(
                    color: AppTheme.amberLight,
                    fontSize: 9,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w700)),
            const SizedBox(width: 10),
            const Text('(cada celda = 1 KB)',
                style:
                    TextStyle(color: AppTheme.sepia, fontSize: 8)),
            const Spacer(),
            _ramLegend(),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.bgElevated,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row numbers
              for (int row = 0;
                  row < (totalCells / cellsPerRow).ceil();
                  row++) ...[
                Row(
                  children: [
                    // Row address label
                    SizedBox(
                      width: 36,
                      child: Text(
                        '${row * cellsPerRow}',
                        style: const TextStyle(
                            color: AppTheme.sepia,
                            fontSize: 7,
                            fontFamily: 'monospace'),
                      ),
                    ),
                    // Cells
                    ...List.generate(cellsPerRow, (col) {
                      final addr = row * cellsPerRow + col;
                      if (addr >= totalCells) {
                        return SizedBox(width: cellSize, height: cellSize);
                      }
                      final color =
                          colorMap[addr] ?? AppTheme.border.withValues(alpha: 0.2);
                      final label = labelMap[addr] ?? '';
                      return Tooltip(
                        message:
                            'Dirección: $addr KB${label.isNotEmpty ? ' · $label' : ' · LIBRE'}',
                        child: Container(
                          width: cellSize,
                          height: cellSize,
                          margin: const EdgeInsets.all(0.5),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 1),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _ramLegend() {
    return Row(
      children: [
        _legendDot(AppTheme.amber.withValues(alpha: 0.85), 'Proceso'),
        const SizedBox(width: 8),
        _legendDot(AppTheme.amber.withValues(alpha: 0.25), 'Frag. interna'),
        const SizedBox(width: 8),
        _legendDot(AppTheme.border.withValues(alpha: 0.3), 'Libre'),
      ],
    );
  }

  Widget _legendDot(Color c, String label) {
    return Row(
      children: [
        Container(
            width: 8,
            height: 8,
            decoration:
                BoxDecoration(color: c, borderRadius: BorderRadius.circular(1))),
        const SizedBox(width: 3),
        Text(label,
            style:
                const TextStyle(color: AppTheme.sepia, fontSize: 8)),
      ],
    );
  }

  // ─── Horizontal bar ──────────────────────────────────────────────────────────
  Widget _buildBar() {
    return LayoutBuilder(builder: (context, constraints) {
      final total = widget.totalMemory.toDouble();
      return Container(
        height: _isBuddy ? 64 : 48,
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: Row(
            children: widget.blocks.map((b) {
              final displaySize =
                  _isBuddy ? (b.buddyAllocatedSize ?? b.size) : b.size;
              final flex = (displaySize / total * 10000).round().clamp(1, 100000);
              final isHighlighted = widget.highlightBlock?.id == b.id;
              final isHovered = _hovered?.id == b.id;
              final color = _blockColor(b);

              return Flexible(
                flex: flex,
                child: MouseRegion(
                  onEnter: (_) => setState(() => _hovered = b),
                  onExit: (_) => setState(() => _hovered = null),
                  child: AnimatedBuilder(
                    animation: _pulseCtrl,
                    builder: (context, child) {
                      double opacity = b.isFree ? 0.18 : 0.85;
                      if (isHighlighted) {
                        opacity = 0.6 + 0.4 * _pulseCtrl.value;
                      } else if (isHovered) {
                        opacity = 1.0;
                      }

                      return Tooltip(
                        message: b.isFree
                            ? 'LIBRE: ${b.size} KB @ ${b.startAddress}'
                            : '${b.processId}: ${b.size} KB @ ${b.startAddress}'
                                '${b.buddyAllocatedSize != null ? ' (bloque ${b.buddyAllocatedSize} KB)' : ''}',
                        child: Stack(
                          children: [
                            // Full buddy block (allocated size)
                            Container(
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: opacity),
                                border: isHighlighted || isHovered
                                    ? Border.all(color: color, width: 2)
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (displaySize / widget.totalMemory > 0.05)
                                    Text(
                                      b.isFree
                                          ? '··'
                                          : (b.processId ?? ''),
                                      overflow: TextOverflow.clip,
                                      style: TextStyle(
                                        color: b.isFree
                                            ? AppTheme.sepia
                                            : AppTheme.bg,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  if (_isBuddy &&
                                      b.isOccupied &&
                                      b.buddyAllocatedSize != null &&
                                      displaySize / widget.totalMemory > 0.05)
                                    Text(
                                      '${b.buddyAllocatedSize}KB',
                                      style: TextStyle(
                                        color: AppTheme.bg.withValues(alpha: 0.7),
                                        fontSize: 7,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Internal fragmentation overlay (striped)
                            if (_isBuddy &&
                                b.isOccupied &&
                                b.buddyAllocatedSize != null &&
                                b.buddyAllocatedSize! > b.size)
                              Positioned(
                                right: 0,
                                top: 0,
                                bottom: 0,
                                width: (b.buddyAllocatedSize! - b.size) /
                                    b.buddyAllocatedSize! *
                                    double.infinity,
                                child: LayoutBuilder(
                                  builder: (ctx, c) {
                                    final w = (b.buddyAllocatedSize! - b.size) /
                                        b.buddyAllocatedSize! *
                                        c.maxWidth;
                                    return Container(
                                      width: w,
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.25),
                                      ),
                                      child: CustomPaint(
                                        painter: _StripePainter(color),
                                      ),
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  // ─── Address labels ──────────────────────────────────────────────────────────
  Widget _buildAddressLabels() {
    return LayoutBuilder(builder: (context, constraints) {
      final total = widget.totalMemory.toDouble();
      final landmarks = <int>{0};
      for (final b in widget.blocks) {
        landmarks.add(b.startAddress);
        landmarks.add(b.endAddress);
        if (_isBuddy && b.buddyAllocatedSize != null) {
          landmarks.add(b.startAddress + b.buddyAllocatedSize!);
        }
      }
      final sorted = landmarks.toList()..sort();

      return SizedBox(
        height: 14,
        child: Stack(
          children: sorted.map((addr) {
            final x = addr / total * constraints.maxWidth;
            return Positioned(
              left: (x - 12).clamp(0, constraints.maxWidth - 24),
              child: Text(
                '$addr',
                style: const TextStyle(color: AppTheme.sepia, fontSize: 8),
              ),
            );
          }).toList(),
        ),
      );
    });
  }

  // ─── Buddy level legend ──────────────────────────────────────────────────────
  Widget _buildBuddyLevelLegend() {
    final levels = widget.blocks
        .where((b) => b.buddyLevel != null)
        .map((b) => b.buddyLevel!)
        .toSet()
        .toList()
      ..sort();

    if (levels.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: [
        const Text('NIVELES GEMELO:',
            style: TextStyle(
                color: AppTheme.sepia, fontSize: 9, letterSpacing: 1.5)),
        ...levels.map((lvl) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(
                    color: AppTheme.amberLight.withValues(alpha: 0.4)),
                borderRadius: BorderRadius.circular(2),
              ),
              child: Text(
                'L$lvl = ${_pow2(lvl)} KB',
                style: const TextStyle(
                    color: AppTheme.amberLight,
                    fontSize: 8,
                    fontWeight: FontWeight.w700),
              ),
            )),
      ],
    );
  }

  int _pow2(int n) => 1 << n;

  // ─── Block list ──────────────────────────────────────────────────────────────
  Widget _buildBlockList() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: widget.blocks.map((b) {
        final color = _blockColor(b);
        final isHighlighted = widget.highlightBlock?.id == b.id;
        final internalFrag = b.buddyAllocatedSize != null
            ? b.buddyAllocatedSize! - b.size
            : 0;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: b.isFree
                ? AppTheme.bgElevated
                : color.withValues(alpha: 0.12),
            border: Border.all(
              color: isHighlighted
                  ? color
                  : (b.isFree
                      ? AppTheme.border
                      : color.withValues(alpha: 0.4)),
              width: isHighlighted ? 1.5 : 1,
            ),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 6, height: 6, color: color),
              const SizedBox(width: 5),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    b.isFree
                        ? 'LIBRE ${b.size} KB'
                        : '${b.processId} ${b.size} KB',
                    style: TextStyle(
                      color: b.isFree ? AppTheme.sepia : color,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isBuddy && b.isOccupied && b.buddyAllocatedSize != null)
                    Text(
                      'bloque: ${b.buddyAllocatedSize} KB  ·  frag.int: $internalFrag KB',
                      style: TextStyle(
                          color: Colors.orange.shade300, fontSize: 7),
                    ),
                  if (_isBuddy && b.buddyLevel != null)
                    Text(
                      'nivel L${b.buddyLevel}',
                      style: const TextStyle(
                          color: AppTheme.amberLight, fontSize: 7),
                    ),
                ],
              ),
              const SizedBox(width: 4),
              Text(
                '@${b.startAddress}',
                style:
                    const TextStyle(color: AppTheme.sepia, fontSize: 8),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

/// Diagonal stripe painter for internal fragmentation visualization
class _StripePainter extends CustomPainter {
  final Color color;
  const _StripePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    const spacing = 5.0;
    for (double i = -size.height; i < size.width + size.height; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.color != color;
}
