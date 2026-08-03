// lib/algorithms/file_system/contiguous_allocator.dart
// Asignación Contigua de Archivos

import '../../models/process.dart';
import '../../models/file_block.dart';
import '../../models/file_allocation_event.dart';
import '../../models/file_allocation_result.dart';

class ContiguousAllocator {
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
      final startBlock = _findContiguousFree(blocks, neededBlocks);

      if (startBlock == -1) {
        events.add(FileAllocationEvent(
          type: FileAllocationEventType.fail,
          fileId: process.id,
          snapshotAfter: List.from(blocks),
          description: 'FALLO: No hay espacio contiguo de $neededBlocks bloques para ${process.id}',
          fragmentation: _calcFragmentation(blocks, blockSize),
        ));
        continue;
      }

      final allocatedBlocks = <int>[];
      for (int i = 0; i < neededBlocks; i++) {
        final idx = startBlock + i;
        blocks[idx] = blocks[idx].copyWith(
          status: FileBlockStatus.occupied,
          fileId: process.id,
        );
        allocatedBlocks.add(idx);
      }

      fileAllocations[process.id] = allocatedBlocks;

      events.add(FileAllocationEvent(
        type: FileAllocationEventType.allocate,
        fileId: process.id,
        startBlock: startBlock,
        blocksAllocated: neededBlocks,
        allocatedBlocks: allocatedBlocks,
        snapshotAfter: List.from(blocks),
        description: 'ASIGNADO: ${process.id} → bloques $startBlock-${startBlock + neededBlocks - 1} '
            '($neededBlocks bloques contiguos, ${process.memorySize} KB)',
        fragmentation: _calcFragmentation(blocks, blockSize),
      ));
    }

    return FileAllocationResult(
      method: FileAllocationMethod.contiguous,
      totalBlocks: totalBlocks,
      blockSize: blockSize,
      events: events,
      finalState: blocks,
    );
  }

  static int _findContiguousFree(List<FileBlock> blocks, int needed) {
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

  static int _calcFragmentation(List<FileBlock> blocks, int blockSize) {
    int freeBlocks = 0;
    for (final block in blocks) {
      if (block.isFree) freeBlocks++;
    }
    return freeBlocks * blockSize;
  }
}