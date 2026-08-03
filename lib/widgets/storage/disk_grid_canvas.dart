// lib/widgets/storage/disk_grid_canvas.dart
// Grid de disco con efectos neón y animaciones

import 'package:flutter/material.dart';
import '../../models/file_block.dart';
import '../../models/file_allocation_event.dart';
import '../../core/app_theme.dart';

class DiskGridCanvas extends StatefulWidget {
  final List<FileBlock> blocks;
  final int totalBlocks;
  final int blockSize;
  final FileAllocationEvent? currentEvent;
  final bool animationEnabled;
  final Function(int)? onBlockTap;
  final int? highlightBlock;

  const DiskGridCanvas({
    super.key,
    required this.blocks,
    required this.totalBlocks,
    required this.blockSize,
    this.currentEvent,
    this.animationEnabled = true,
    this.onBlockTap,
    this.highlightBlock,
  });

  @override
  State<DiskGridCanvas> createState() => _DiskGridCanvasState();
}

class _DiskGridCanvasState extends State<DiskGridCanvas>
    with SingleTickerProviderStateMixin {
  int? _hoveredBlock;
  final Map<int, double> _scaleAnim = {};
  final Map<int, double> _glowAnim = {};
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    _initAnimations();
  }

  void _initAnimations() {
    for (int i = 0; i < widget.totalBlocks; i++) {
      _scaleAnim[i] = 1.0;
      _glowAnim[i] = 0.0;
    }
  }

  @override
  void didUpdateWidget(DiskGridCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentEvent != oldWidget.currentEvent &&
        widget.currentEvent != null &&
        widget.currentEvent!.allocatedBlocks != null) {
      final allocated = widget.currentEvent!.allocatedBlocks!;
      for (final idx in allocated) {
        if (idx < widget.totalBlocks) {
          setState(() {
            _scaleAnim[idx] = 1.4;
            _glowAnim[idx] = 1.0;
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _scaleAnim[idx] = 1.0;
              });
            }
          });
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) {
              setState(() {
                _glowAnim[idx] = 0.0;
              });
            }
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Color _blockColor(FileBlock block) {
    if (block.isFree) return AppTheme.borderDark;
    if (block.isIndex) return AppTheme.neonPurple;
    if (block.fileId != null) return AppTheme.processColor(block.fileId!);
    return AppTheme.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    const blockSize = 40.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Leyenda
        _buildLegend(),
        const SizedBox(height: 8),
        // Grid
        Container(
          padding: const EdgeInsets.all(12),
          decoration: AppTheme.glassCard(
            borderColor: AppTheme.neonCyan,
            borderRadius: 12,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: List.generate(widget.totalBlocks, (index) {
                    final block = index < widget.blocks.length
                        ? widget.blocks[index]
                        : FileBlock(blockIndex: index);
                    final color = _blockColor(block);
                    final isHovered = _hoveredBlock == index;
                    final isAllocating = widget.currentEvent?.allocatedBlocks?.contains(index) ?? false;
                    final isHighlighted = widget.highlightBlock == index;
                    final scale = _scaleAnim[index] ?? 1.0;
                    final glow = _glowAnim[index] ?? 0.0;

                    return _buildBlock(
                      block: block,
                      index: index,
                      color: color,
                      isHovered: isHovered,
                      isAllocating: isAllocating,
                      isHighlighted: isHighlighted,
                      scale: scale,
                      glow: glow,
                      blockSize: blockSize,
                    );
                  }),
                ),
              );
            },
          ),
        ),
        // Info del bloque hover
        if (_hoveredBlock != null) ...[
          const SizedBox(height: 8),
          _buildBlockInfo(_hoveredBlock!),
        ],
        // Estadísticas rápidas
        const SizedBox(height: 8),
        _buildStats(),
      ],
    );
  }

  Widget _buildBlock({
    required FileBlock block,
    required int index,
    required Color color,
    required bool isHovered,
    required bool isAllocating,
    required bool isHighlighted,
    required double scale,
    required double glow,
    required double blockSize,
  }) {
    return AnimatedBuilder(
      animation: _pulseCtrl,
      builder: (context, child) {
        final pulseValue = _pulseCtrl.value;
        final isPulsing = isAllocating || isHighlighted;

        return MouseRegion(
          onEnter: (_) => setState(() => _hoveredBlock = index),
          onExit: (_) => setState(() => _hoveredBlock = null),
          child: GestureDetector(
            onTap: () => widget.onBlockTap?.call(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: blockSize,
              height: blockSize,
              decoration: BoxDecoration(
                color: isHovered
                    ? color.withValues(alpha: 0.9)
                    : color.withValues(alpha: block.isFree ? 0.15 : 0.6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isHovered
                      ? Colors.white
                      : isPulsing
                          ? AppTheme.neonCyan.withValues(alpha: 0.6 + 0.4 * pulseValue)
                          : color.withValues(alpha: block.isFree ? 0.2 : 0.5),
                  width: isPulsing ? 2.0 : 1.0,
                ),
                boxShadow: (isPulsing || glow > 0)
                    ? [
                        BoxShadow(
                          color: AppTheme.neonCyan.withValues(alpha: 0.3 + 0.3 * glow),
                          blurRadius: 10 + glow * 15,
                          spreadRadius: 2 + glow * 4,
                        ),
                      ]
                    : null,
              ),
              child: Transform.scale(
                scale: scale,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (block.isIndex)
                      const Icon(
                        Icons.folder_special,
                        color: Colors.white,
                        size: 14,
                      )
                    else if (block.isOccupied && block.fileId != null)
                      Text(
                        block.fileId!,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      )
                    else if (block.isFree)
                      Text(
                        '$index',
                        style: TextStyle(
                          color: AppTheme.textDim.withValues(alpha: 0.4),
                          fontSize: 7,
                          fontFamily: 'monospace',
                        ),
                      ),
                    if (isAllocating)
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppTheme.neonCyan,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          color: AppTheme.neonCyan,
          margin: const EdgeInsets.only(right: 8),
        ),
        const Text(
          'MAPA DE DISCO',
          style: TextStyle(
            color: AppTheme.neonCyan,
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(width: 12),
        _legendDot(AppTheme.borderDark, 'Libre'),
        _legendDot(AppTheme.neonPurple, 'Índice'),
        _legendDot(AppTheme.neonCyan, 'Ocupado'),
        const Spacer(),
        Text(
          '${widget.blocks.where((b) => b.isOccupied || b.isIndex).length}/${widget.totalBlocks}',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockInfo(int index) {
    final block = index < widget.blocks.length
        ? widget.blocks[index]
        : FileBlock(blockIndex: index);

    String info;
    if (block.isFree) {
      info = 'Bloque $index: Libre (${widget.blockSize} KB)';
    } else if (block.isIndex) {
      final dataBlocks = block.indexedBlocks ?? [];
      info = 'Bloque $index: Índice de ${block.fileId} → ${dataBlocks.length} bloques de datos';
    } else if (block.isOccupied) {
      info = 'Bloque $index: ${block.fileId} (${widget.blockSize} KB)';
      if (block.nextBlockIndex != null && block.nextBlockIndex! >= 0) {
        info += ' → Siguiente: ${block.nextBlockIndex}';
      } else if (block.nextBlockIndex == -1) {
        info += ' → Último bloque';
      }
    } else {
      info = 'Bloque $index';
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: AppTheme.glassCard(borderRadius: 8),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppTheme.textSecondary, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              info,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    final used = widget.blocks.where((b) => b.isOccupied || b.isIndex).length;
    final free = widget.totalBlocks - used;
    final percent = widget.totalBlocks > 0 ? (used / widget.totalBlocks * 100) : 0;

    return Row(
      children: [
        _statItem('Usados', '$used', AppTheme.neonCyan),
        _statItem('Libres', '$free', AppTheme.textSecondary),
        _statItem('Uso', '${percent.toStringAsFixed(1)}%', AppTheme.neonAmber),
        const Spacer(),
        Text(
          '${widget.blockSize} KB/bloque',
          style: const TextStyle(
            color: AppTheme.textDim,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}