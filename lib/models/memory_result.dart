// lib/models/memory_result.dart

import 'memory_block.dart';
import 'memory_event.dart';

enum AllocationAlgorithm { firstFit, bestFit, worstFit, buddySystem }

extension AlgorithmName on AllocationAlgorithm {
  String get displayName {
    switch (this) {
      case AllocationAlgorithm.firstFit:
        return 'First Fit';
      case AllocationAlgorithm.bestFit:
        return 'Best Fit';
      case AllocationAlgorithm.worstFit:
        return 'Worst Fit';
      case AllocationAlgorithm.buddySystem:
        return 'Buddy System';
    }
  }

  String get description {
    switch (this) {
      case AllocationAlgorithm.firstFit:
        return 'Asigna el primer hueco suficientemente grande — más rápido';
      case AllocationAlgorithm.bestFit:
        return 'Asigna el hueco más pequeño que alcance — menos desperdicio';
      case AllocationAlgorithm.worstFit:
        return 'Asigna el hueco más grande disponible — residuo más útil';
      case AllocationAlgorithm.buddySystem:
        return 'Divide bloques en potencias de 2 — fusiona gemelos al liberar';
    }
  }
}

class MemoryResult {
  final AllocationAlgorithm algorithm;
  final int totalMemory;
  final List<MemoryEvent> events;
  final List<MemoryBlock> finalState;

  const MemoryResult({
    required this.algorithm,
    required this.totalMemory,
    required this.events,
    required this.finalState,
  });

  int get usedMemory =>
      finalState.where((b) => b.isOccupied).fold(0, (s, b) => s + b.size);

  int get freeMemory =>
      finalState.where((b) => b.isFree).fold(0, (s, b) => s + b.size);

  int get freeBlocks => finalState.where((b) => b.isFree).length;

  int get occupiedBlocks => finalState.where((b) => b.isOccupied).length;

  int get externalFragmentation {
    final freeList = finalState.where((b) => b.isFree).toList();
    if (freeList.isEmpty) return 0;
    final largest =
        freeList.map((b) => b.size).reduce((a, b) => a > b ? a : b);
    final total = freeList.fold(0, (s, b) => s + b.size);
    return total - largest;
  }

  /// Internal fragmentation: wasted space inside allocated buddy blocks
  int get internalFragmentation {
    return finalState.where((b) => b.isOccupied).fold(0, (s, b) {
      final waste = (b.buddyAllocatedSize ?? b.size) - b.size;
      return s + (waste > 0 ? waste : 0);
    });
  }

  double get utilizationPercent =>
      totalMemory == 0 ? 0 : usedMemory / totalMemory * 100;
}