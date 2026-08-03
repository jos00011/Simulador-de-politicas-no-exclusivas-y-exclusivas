// lib/algorithms/file_system/linked_allocator.dart
// Asignación Enlazada de Archivos

import '../../models/process.dart';
import '../../models/file_block.dart';
import '../../models/file_allocation_event.dart';
import '../../models/file_allocation_result.dart';

class LinkedAllocator {
  static const int blockSize = 64;

  static FileAllocationResult simulate({
    required List<Process> processes,
    required int totalBlocks,
    required int blockSize,
  }) {
    var blocks = List.generate(totalBlocks, (i) => FileBlock(blockIndex: i));
    final events = <FileAllocationEvent>[];
    final fileAllocations = <String, List<int>>{};

    for (final process in processes) {
      final neededBlocks = (process.memorySize / blockSize).ceil();

      final allocatedBlocks = _findFreeBlocks(blocks, neededBlocks);

      if (allocatedBlocks.isEmpty) {
        events.add(FileAllocationEvent(
          type: FileAllocationEventType.fail,
          fileId: process.id,
          snapshotAfter: List.from(blocks),
          description: 'FALLO: No hay suficientes bloques libres ($neededBlocks) para ${process.id}',
          fragmentation: _calcFragmentation(blocks, blockSize),
        ));
        continue;
      }

      for (int i = 0; i < allocatedBlocks.length; i++) {
        final idx = allocatedBlocks[i];
        final nextIdx = (i < allocatedBlocks.length - 1) ? allocatedBlocks[i + 1] : -1;

        blocks[idx] = blocks[idx].copyWith(
          status: FileBlockStatus.occupied,
          fileId: process.id,
          nextBlockIndex: nextIdx,
        );
      }

      fileAllocations[process.id] = allocatedBlocks;

      final firstBlock = allocatedBlocks.first;
      final lastBlock = allocatedBlocks.last;

      events.add(FileAllocationEvent(
        type: FileAllocationEventType.allocate,
        fileId: process.id,
        startBlock: firstBlock,
        blocksAllocated: allocatedBlocks.length,
        allocatedBlocks: allocatedBlocks,
        snapshotAfter: List.from(blocks),
        description: 'ASIGNADO: ${process.id} → $firstBlock → ... → $lastBlock (-1 fin) '
            '(${allocatedBlocks.length} bloques enlazados, ${process.memorySize} KB)',
        fragmentation: _calcFragmentation(blocks, blockSize),
      ));
    }

    return FileAllocationResult(
      method: FileAllocationMethod.linked,
      totalBlocks: totalBlocks,
      blockSize: blockSize,
      events: events,
      finalState: blocks,
    );
  }

  static List<int> _findFreeBlocks(List<FileBlock> blocks, int needed) {
    final result = <int>[];
    for (int i = 0; i < blocks.length && result.length < needed; i++) {
      if (blocks[i].isFree) {
        result.add(i);
      }
    }
    return result;
  }

  static int _calcFragmentation(List<FileBlock> blocks, int blockSize) {
    int freeBlocks = 0;
    for (final block in blocks) {
      if (block.isFree) freeBlocks++;
    }
    return freeBlocks * blockSize;
  }
}