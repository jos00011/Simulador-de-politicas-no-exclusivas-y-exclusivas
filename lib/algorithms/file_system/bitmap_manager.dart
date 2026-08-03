// lib/algorithms/file_system/bitmap_manager.dart
// Gestión de Espacio Libre con Bitmap

import '../../models/process.dart';
import '../../models/file_block.dart';
import '../../models/file_allocation_event.dart';
import '../../models/advanced_fs_result.dart';
import '../../models/bitmap.dart';

class BitmapManager {
  static const int blockSize = 64; // KB por bloque

  static AdvancedFsResult simulate({
    required List<Process> processes,
    required int totalBlocks,
    required int blockSize,
  }) {
    var blocks = List.generate(totalBlocks, (i) => FileBlock(blockIndex: i));
    var bitmap = Bitmap.initial(totalBlocks);
    final events = <FileAllocationEvent>[];
    final fileAllocations = <String, List<int>>{};

    for (final process in processes) {
      final neededBlocks = (process.memorySize / blockSize).ceil();

      final allocatedBlocks = _findFreeBlocks(bitmap, neededBlocks);

      if (allocatedBlocks.isEmpty) {
        events.add(FileAllocationEvent(
          type: FileAllocationEventType.fail,
          fileId: process.id,
          snapshotAfter: List.from(blocks),
          description: 'FALLO BITMAP: No hay suficientes bloques libres ($neededBlocks) para ${process.id}',
          fragmentation: _calcFragmentation(blocks, blockSize),
        ));
        continue;
      }

      for (final idx in allocatedBlocks) {
        bitmap.markUsed(idx);
      }

      for (final idx in allocatedBlocks) {
        blocks[idx] = blocks[idx].copyWith(
          status: FileBlockStatus.occupied,
          fileId: process.id,
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
        description: 'BITMAP ASIGNADO: ${process.id} → $firstBlock ... $lastBlock '
            '(${allocatedBlocks.length} bloques, ${process.memorySize} KB)',
        fragmentation: _calcFragmentation(blocks, blockSize),
      ));
    }

    return AdvancedFsResult(
      method: AdvancedFsMethod.bitmap,
      totalBlocks: totalBlocks,
      blockSize: blockSize,
      events: events,
      finalState: blocks,
      bitmap: bitmap,
    );
  }

  static List<int> _findFreeBlocks(Bitmap bitmap, int needed) {
    final result = <int>[];
    for (int i = 0; i < bitmap.size && result.length < needed; i++) {
      if (bitmap.isFree(i)) {
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