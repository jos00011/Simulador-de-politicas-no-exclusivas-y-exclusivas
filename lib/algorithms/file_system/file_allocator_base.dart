// lib/algorithms/file_system/file_allocator_base.dart
// Clase base para todos los algoritmos de asignación de archivos

import '../../models/process.dart';
import '../../models/file_block.dart';

/// Clase base abstracta que define el contrato para todos los asignadores de archivos
abstract class FileAllocatorBase {
  static const int defaultBlockSize = 64;

  static dynamic simulate({
    required List<Process> processes,
    required int totalBlocks,
    required int blockSize,
  }) {
    throw UnimplementedError('Cada asignador debe implementar su propio método simulate');
  }

  static List<int> findFreeBlocks(List<FileBlock> blocks, int needed) {
    final result = <int>[];
    for (int i = 0; i < blocks.length && result.length < needed; i++) {
      if (blocks[i].isFree) {
        result.add(i);
      }
    }
    return result;
  }

  static int findContiguousFree(List<FileBlock> blocks, int needed) {
    int currentRun = 0;
    int runStart = 0;

    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].isFree) {
        if (currentRun == 0) runStart = i;
        currentRun++;
        if (currentRun >= needed) {
          return runStart;
        }
      } else {
        currentRun = 0;
      }
    }
    return -1;
  }

  static int calcFragmentation(List<FileBlock> blocks, int blockSize) {
    int freeBlocks = 0;
    int largestFreeRun = 0;
    int currentRun = 0;

    for (final block in blocks) {
      if (block.isFree) {
        freeBlocks++;
        currentRun++;
        if (currentRun > largestFreeRun) {
          largestFreeRun = currentRun;
        }
      } else {
        currentRun = 0;
      }
    }

    final externalFragBlocks = freeBlocks - largestFreeRun;
    return externalFragBlocks * blockSize;
  }

  static double calcUtilization(List<FileBlock> blocks, int totalBlocks) {
    if (totalBlocks == 0) return 0;
    final usedBlocks = blocks.where((b) => b.isOccupied || b.isIndex).length;
    return usedBlocks / totalBlocks * 100;
  }

  static String generateDescription(
    String fileId,
    List<int> blocks,
    String methodName,
  ) {
    if (blocks.isEmpty) {
      return 'FALLO: No se pudo asignar espacio para $fileId';
    }
    return 'ASIGNADO: $fileId → ${blocks.length} bloques ($methodName)';
  }

  static bool validateProcesses(List<Process> processes) {
    if (processes.isEmpty) return false;
    for (final p in processes) {
      if (p.memorySize <= 0) return false;
      if (p.id.isEmpty) return false;
    }
    return true;
  }

  static int calcNeededBlocks(Process process, int blockSize) {
    return (process.memorySize / blockSize).ceil();
  }

  static List<FileBlock> createInitialBlocks(int totalBlocks) {
    return List.generate(totalBlocks, (i) => FileBlock(blockIndex: i));
  }

  static bool hasEnoughFreeBlocks(List<FileBlock> blocks, int needed) {
    int freeCount = 0;
    for (final block in blocks) {
      if (block.isFree) freeCount++;
      if (freeCount >= needed) return true;
    }
    return false;
  }

  static Map<String, dynamic> getStats(List<FileBlock> blocks, int totalBlocks, int blockSize) {
    final usedBlocks = blocks.where((b) => b.isOccupied || b.isIndex).length;
    final freeBlocks = blocks.where((b) => b.isFree).length;
    final indexBlocks = blocks.where((b) => b.isIndex).length;

    return {
      'totalBlocks': totalBlocks,
      'usedBlocks': usedBlocks,
      'freeBlocks': freeBlocks,
      'indexBlocks': indexBlocks,
      'utilization': totalBlocks > 0 ? usedBlocks / totalBlocks * 100 : 0,
      'fragmentation': calcFragmentation(blocks, blockSize),
      'totalSizeKB': totalBlocks * blockSize,
      'usedSizeKB': usedBlocks * blockSize,
      'freeSizeKB': freeBlocks * blockSize,
    };
  }
}

extension FileBlockExtension on FileBlock {
  bool get hasNext => nextBlockIndex != null && nextBlockIndex! >= 0;
  bool get isLast => nextBlockIndex == -1;

  String get shortLabel {
    if (isFree) return '·';
    if (isIndex) return '📋';
    if (isOccupied && fileId != null) return fileId!;
    return '?';
  }

  int get colorHash {
    if (isFree) return 0;
    if (isIndex) return 1;
    if (fileId != null) {
      return fileId!.hashCode.abs();
    }
    return 2;
  }
}