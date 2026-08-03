// lib/models/advanced_fs_result.dart

import 'package:flutter/material.dart';
import 'file_block.dart';
import 'file_allocation_event.dart';
import 'fat_table.dart';
import 'extent.dart';
import 'inode.dart';
import 'bitmap.dart';

enum AdvancedFsMethod { fat, extent, multilevel, bitmap }

extension AdvancedFsMethodDisplay on AdvancedFsMethod {
  String get displayName {
    switch (this) {
      case AdvancedFsMethod.fat: return 'FAT';
      case AdvancedFsMethod.extent: return 'Extensión';
      case AdvancedFsMethod.multilevel: return 'Multinivel';
      case AdvancedFsMethod.bitmap: return 'Bitmap';
    }
  }

  IconData get icon {
    switch (this) {
      case AdvancedFsMethod.fat: return Icons.table_chart;
      case AdvancedFsMethod.extent: return Icons.view_array;
      case AdvancedFsMethod.multilevel: return Icons.account_tree;
      case AdvancedFsMethod.bitmap: return Icons.grid_on;
    }
  }
}

class AdvancedFsResult {
  final AdvancedFsMethod method;
  final int totalBlocks;
  final int blockSize;
  final List<FileAllocationEvent> events;
  final List<FileBlock> finalState;
  final FATTable? fatTable;
  final List<FileExtents>? fileExtents;
  final Map<String, Inode>? inodes;
  final Bitmap? bitmap;

  const AdvancedFsResult({
    required this.method,
    required this.totalBlocks,
    required this.blockSize,
    required this.events,
    required this.finalState,
    this.fatTable,
    this.fileExtents,
    this.inodes,
    this.bitmap,
  });

  int get usedBlocks => finalState.where((b) => b.isOccupied || b.isIndex).length;
  int get freeBlocks => totalBlocks - usedBlocks;
  double get utilizationPercent => totalBlocks == 0 ? 0 : usedBlocks / totalBlocks * 100;

  Map<String, List<int>> get fileAllocations {
    final result = <String, List<int>>{};
    for (final block in finalState) {
      if (block.isOccupied && block.fileId != null) {
        result.putIfAbsent(block.fileId!, () => []).add(block.blockIndex);
      }
    }
    return result;
  }

  Map<String, dynamic> getMethodStats() {
    return {
      'method': method.displayName,
      'totalBlocks': totalBlocks,
      'usedBlocks': usedBlocks,
      'freeBlocks': freeBlocks,
      'utilizationPercent': utilizationPercent,
    };
  }

  String get visualizerHint {
    switch (method) {
      case AdvancedFsMethod.fat: return 'Tabla FAT mostrando enlaces entre bloques';
      case AdvancedFsMethod.extent: return 'Lista de extensiones por archivo';
      case AdvancedFsMethod.multilevel: return 'Estructura de inodos con punteros directos e indirectos';
      case AdvancedFsMethod.bitmap: return 'Mapa de bits (█ ocupado, ░ libre)';
    }
  }
}