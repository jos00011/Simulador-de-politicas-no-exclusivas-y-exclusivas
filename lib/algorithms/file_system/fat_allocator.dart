// lib/algorithms/file_system/fat_allocator.dart
// Asignación FAT (File Allocation Table)

import '../../models/process.dart';
import '../../models/file_block.dart';
import '../../models/file_allocation_event.dart';
import '../../models/advanced_fs_result.dart';
import '../../models/fat_table.dart';
import '../../core/app_constants.dart';

class FATAllocator {
  static const int blockSize = 64; // KB por bloque

  static AdvancedFsResult simulate({
    required List<Process> processes,
    required int totalBlocks,
    required int blockSize,
  }) {
    var blocks = List.generate(totalBlocks, (i) => FileBlock(blockIndex: i));
    var fat = FATTable.initial(totalBlocks);
    final events = <FileAllocationEvent>[];
    final fileAllocations = <String, List<int>>{};

    for (final process in processes) {
      final neededBlocks = (process.memorySize / blockSize).ceil();

      final allocatedBlocks = _findFreeBlocks(fat, neededBlocks);

      if (allocatedBlocks.isEmpty) {
        events.add(FileAllocationEvent(
          type: FileAllocationEventType.fail,
          fileId: process.id,
          snapshotAfter: List.from(blocks),
          description: 'FALLO FAT: No hay suficientes bloques libres ($neededBlocks) para ${process.id}',
          fragmentation: _calcFragmentation(blocks, blockSize),
        ));
        continue;
      }

      fat = _allocateInFat(fat, allocatedBlocks);

      for (final idx in allocatedBlocks) {
        final nextIdx = _getNextInChain(allocatedBlocks, idx);
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
        description: 'FAT ASIGNADO: ${process.id} → $firstBlock → ... → $lastBlock (-1 fin) '
            '(${allocatedBlocks.length} bloques, ${process.memorySize} KB)',
        fragmentation: _calcFragmentation(blocks, blockSize),
      ));
    }

    return AdvancedFsResult(
      method: AdvancedFsMethod.fat,
      totalBlocks: totalBlocks,
      blockSize: blockSize,
      events: events,
      finalState: blocks,
      fatTable: fat,
    );
  }

  static List<int> _findFreeBlocks(FATTable fat, int needed) {
    final result = <int>[];
    for (int i = 0; i < fat.length && result.length < needed; i++) {
      if (fat.isFree(i)) {
        result.add(i);
      }
    }
    return result;
  }

  static FATTable _allocateInFat(FATTable fat, List<int> blocks) {
    final newEntries = List<int>.from(fat.entries);

    for (int i = 0; i < blocks.length; i++) {
      final current = blocks[i];
      final next = (i < blocks.length - 1) ? blocks[i + 1] : AppConstants.fatEof;
      newEntries[current] = next;
    }

    return FATTable(entries: newEntries);
  }

  static int _getNextInChain(List<int> blocks, int current) {
    final index = blocks.indexOf(current);
    if (index == -1 || index == blocks.length - 1) {
      return -1;
    }
    return blocks[index + 1];
  }

  static int _calcFragmentation(List<FileBlock> blocks, int blockSize) {
    int freeBlocks = 0;
    for (final block in blocks) {
      if (block.isFree) freeBlocks++;
    }
    return freeBlocks * blockSize;
  }
}