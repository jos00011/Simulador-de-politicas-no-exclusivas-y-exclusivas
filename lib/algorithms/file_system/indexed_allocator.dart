// lib/algorithms/file_system/indexed_allocator.dart
// Asignación Indexada de Archivos

import '../../models/process.dart';
import '../../models/file_block.dart';
import '../../models/file_allocation_event.dart';
import '../../models/file_allocation_result.dart';

class IndexedAllocator {
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
      final neededDataBlocks = (process.memorySize / blockSize).ceil();
      final totalNeeded = neededDataBlocks + 1;

      final allocatedBlocks = _findFreeBlocks(blocks, totalNeeded);

      if (allocatedBlocks.isEmpty || allocatedBlocks.length < totalNeeded) {
        events.add(FileAllocationEvent(
          type: FileAllocationEventType.fail,
          fileId: process.id,
          snapshotAfter: List.from(blocks),
          description: 'FALLO: No hay suficientes bloques libres ($totalNeeded) para ${process.id}',
          fragmentation: _calcFragmentation(blocks, blockSize),
        ));
        continue;
      }

      final indexBlock = allocatedBlocks.first;
      final dataBlocks = allocatedBlocks.sublist(1);

      blocks[indexBlock] = blocks[indexBlock].copyWith(
        status: FileBlockStatus.indexBlock,
        fileId: process.id,
        isIndexBlock: true,
        indexedBlocks: dataBlocks,
      );

      for (final idx in dataBlocks) {
        blocks[idx] = blocks[idx].copyWith(
          status: FileBlockStatus.occupied,
          fileId: process.id,
        );
      }

      fileAllocations[process.id] = allocatedBlocks;

      events.add(FileAllocationEvent(
        type: FileAllocationEventType.allocate,
        fileId: process.id,
        startBlock: indexBlock,
        blocksAllocated: dataBlocks.length,
        allocatedBlocks: allocatedBlocks,
        snapshotAfter: List.from(blocks),
        description: 'ASIGNADO: ${process.id} → Índice: $indexBlock → Datos: ${dataBlocks.join(", ")} '
            '(${dataBlocks.length} bloques de datos, ${process.memorySize} KB)',
        fragmentation: _calcFragmentation(blocks, blockSize),
      ));
    }

    return FileAllocationResult(
      method: FileAllocationMethod.indexed,
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