// lib/algorithms/file_system/file_system_facade.dart
// Fachada que orquesta todos los algoritmos de asignación de archivos

import '../../models/process.dart';
import '../../providers/file_system_state.dart';
import 'contiguous_allocator.dart';
import 'linked_allocator.dart';
import 'indexed_allocator.dart';
import 'fat_allocator.dart';
import 'extent_allocator.dart';
import 'multilevel_allocator.dart';
import 'bitmap_manager.dart';

class FileSystemFacade {
  static const int blockSize = 64; // KB por bloque

  /// Punto de entrada único para todos los métodos de asignación
  static dynamic simulate({
    required List<Process> processes,
    required int totalDiskSize,
    required int blockSize,
    required FsMethod method,
  }) {
    final totalBlocks = totalDiskSize ~/ blockSize;

    switch (method) {
      // ─── MÉTODOS CLÁSICOS ──────────────────────────────────────
      case FsMethod.contiguous:
        return ContiguousAllocator.simulate(
          processes: processes,
          totalBlocks: totalBlocks,
          blockSize: blockSize,
        );

      case FsMethod.linked:
        return LinkedAllocator.simulate(
          processes: processes,
          totalBlocks: totalBlocks,
          blockSize: blockSize,
        );

      case FsMethod.indexed:
        return IndexedAllocator.simulate(
          processes: processes,
          totalBlocks: totalBlocks,
          blockSize: blockSize,
        );

      // ─── MÉTODOS AVANZADOS ──────────────────────────────────────
      case FsMethod.fat:
        return FATAllocator.simulate(
          processes: processes,
          totalBlocks: totalBlocks,
          blockSize: blockSize,
        );

      case FsMethod.extent:
        return ExtentAllocator.simulate(
          processes: processes,
          totalBlocks: totalBlocks,
          blockSize: blockSize,
        );

      case FsMethod.multilevel:
        return MultilevelAllocator.simulate(
          processes: processes,
          totalBlocks: totalBlocks,
          blockSize: blockSize,
        );

      case FsMethod.bitmap:
        return BitmapManager.simulate(
          processes: processes,
          totalBlocks: totalBlocks,
          blockSize: blockSize,
        );
    }
  }

  /// Obtiene el nombre del método para mostrar
  static String getMethodDisplayName(FsMethod method) {
    return method.displayName;
  }

  /// Verifica si un método es clásico o avanzado
  static bool isClassic(FsMethod method) => method.isClassic;
  static bool isAdvanced(FsMethod method) => method.isAdvanced;

  /// Lista de todos los métodos disponibles
  static List<FsMethod> get allMethods => FsMethod.values;

  /// Lista de métodos clásicos
  static List<FsMethod> get classicMethods => [
        FsMethod.contiguous,
        FsMethod.linked,
        FsMethod.indexed,
      ];

  /// Lista de métodos avanzados
  static List<FsMethod> get advancedMethods => [
        FsMethod.fat,
        FsMethod.extent,
        FsMethod.multilevel,
        FsMethod.bitmap,
      ];
}