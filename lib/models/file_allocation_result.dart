// lib/models/file_allocation_result.dart

import 'file_block.dart';
import 'file_allocation_event.dart';

enum FileAllocationMethod { contiguous, linked, indexed }

extension FileAllocationMethodName on FileAllocationMethod {
  String get displayName {
    switch (this) {
      case FileAllocationMethod.contiguous:
        return 'Contigua';
      case FileAllocationMethod.linked:
        return 'Enlazada';
      case FileAllocationMethod.indexed:
        return 'Indexada';
    }
  }
}

class FileAllocationResult {
  final FileAllocationMethod method;
  final int totalBlocks;
  final int blockSize;
  final List<FileAllocationEvent> events;
  final List<FileBlock> finalState;

  const FileAllocationResult({
    required this.method,
    required this.totalBlocks,
    required this.blockSize,
    required this.events,
    required this.finalState,
  });

  int get usedBlocks => finalState.where((b) => b.isOccupied || b.isIndex).length;
  int get freeBlocks => finalState.where((b) => b.isFree).length;
  
  double get utilizationPercent => totalBlocks == 0 ? 0 : usedBlocks / totalBlocks * 100;
  
  int get externalFragmentation {
    int largestFree = 0;
    int currentFree = 0;
    for (final block in finalState) {
      if (block.isFree) {
        currentFree++;
      } else {
        if (currentFree > largestFree) {
          largestFree = currentFree;
        }
        currentFree = 0;
      }
    }
    if (currentFree > largestFree) largestFree = currentFree;
    return (finalState.where((b) => b.isFree).length - largestFree) * blockSize;
  }

  Map<String, List<int>> get fileAllocations {
    final result = <String, List<int>>{};
    for (final block in finalState) {
      if (block.isOccupied && block.fileId != null) {
        result.putIfAbsent(block.fileId!, () => []).add(block.blockIndex);
      }
    }
    return result;
  }
}