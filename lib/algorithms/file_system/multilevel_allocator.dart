// lib/algorithms/file_system/multilevel_allocator.dart
// Asignación Multinivel (Inodos UNIX con punteros directos e indirectos)

import '../../models/process.dart';
import '../../models/file_block.dart';
import '../../models/file_allocation_event.dart';
import '../../models/advanced_fs_result.dart';
import '../../models/inode.dart';
import '../../core/app_constants.dart';

class MultilevelAllocator {
  static const int blockSize = 64; // KB por bloque

  static AdvancedFsResult simulate({
    required List<Process> processes,
    required int totalBlocks,
    required int blockSize,
  }) {
    var blocks = List.generate(totalBlocks, (i) => FileBlock(blockIndex: i));
    final inodes = <String, Inode>{};
    final events = <FileAllocationEvent>[];
    final fileAllocations = <String, List<int>>{};

    for (final process in processes) {
      final neededBlocks = (process.memorySize / blockSize).ceil();
      final result = _allocateWithInode(blocks, neededBlocks, process.id);

      if (!result.success) {
        events.add(FileAllocationEvent(
          type: FileAllocationEventType.fail,
          fileId: process.id,
          snapshotAfter: List.from(blocks),
          description: 'FALLO MULTINIVEL: No hay suficientes bloques libres ($neededBlocks) para ${process.id}',
          fragmentation: _calcFragmentation(blocks, blockSize),
        ));
        continue;
      }

      final allBlocks = <int>[];

      for (final idx in result.dataBlocks) {
        blocks[idx] = blocks[idx].copyWith(
          status: FileBlockStatus.occupied,
          fileId: process.id,
        );
        allBlocks.add(idx);
      }

      for (final idx in result.indexBlocks) {
        blocks[idx] = blocks[idx].copyWith(
          status: FileBlockStatus.indexBlock,
          fileId: process.id,
          isIndexBlock: true,
        );
        allBlocks.add(idx);
      }

      inodes[process.id] = result.inode;
      fileAllocations[process.id] = allBlocks;

      final hasIndirect = result.inode.singleIndirect != null ||
          result.inode.doubleIndirect != null ||
          result.inode.tripleIndirect != null;

      events.add(FileAllocationEvent(
        type: FileAllocationEventType.allocate,
        fileId: process.id,
        startBlock: result.dataBlocks.isNotEmpty ? result.dataBlocks.first : -1,
        blocksAllocated: result.dataBlocks.length,
        allocatedBlocks: allBlocks,
        snapshotAfter: List.from(blocks),
        description: 'MULTINIVEL ASIGNADO: ${process.id} → ${result.dataBlocks.length} bloques de datos '
            '${hasIndirect ? 'con indirección' : '(solo directos)'} — ${process.memorySize} KB',
        fragmentation: _calcFragmentation(blocks, blockSize),
      ));
    }

    return AdvancedFsResult(
      method: AdvancedFsMethod.multilevel,
      totalBlocks: totalBlocks,
      blockSize: blockSize,
      events: events,
      finalState: blocks,
      inodes: inodes,
    );
  }

  static _MultilevelAllocResult _allocateWithInode(
    List<FileBlock> blocks,
    int neededBlocks,
    String fileId,
  ) {
    var inode = Inode.empty();
    final dataBlocks = <int>[];
    final indexBlocks = <int>[];

    final freeBlocks = <int>[];
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].isFree) freeBlocks.add(i);
    }

    if (freeBlocks.length < neededBlocks) {
      return _MultilevelAllocResult(
        success: false,
        inode: inode,
        dataBlocks: [],
        indexBlocks: [],
      );
    }

    int dataIndex = 0;
    for (int i = 0; i < AppConstants.directPointers && dataIndex < neededBlocks; i++) {
      final block = freeBlocks[dataIndex];
      inode = inode.addDirectBlock(block);
      dataBlocks.add(block);
      dataIndex++;
    }

    if (dataIndex < neededBlocks) {
      if (dataIndex < freeBlocks.length) {
        final indexBlock = freeBlocks[dataIndex];
        indexBlocks.add(indexBlock);
        inode = inode.copyWith(singleIndirect: indexBlock);
        dataIndex++;

        final remaining = neededBlocks - dataIndex;
        final toAssign = remaining < AppConstants.singleIndirectSize
            ? remaining
            : AppConstants.singleIndirectSize;

        for (int i = 0; i < toAssign && dataIndex < freeBlocks.length; i++) {
          dataBlocks.add(freeBlocks[dataIndex]);
          dataIndex++;
        }
      }
    }

    if (dataIndex < neededBlocks) {
      if (dataIndex < freeBlocks.length) {
        final indexBlock = freeBlocks[dataIndex];
        indexBlocks.add(indexBlock);
        inode = inode.copyWith(doubleIndirect: indexBlock);
        dataIndex++;

        while (dataIndex < neededBlocks && dataIndex < freeBlocks.length) {
          dataBlocks.add(freeBlocks[dataIndex]);
          dataIndex++;
        }
      }
    }

    if (dataIndex < neededBlocks) {
      if (dataIndex < freeBlocks.length) {
        final indexBlock = freeBlocks[dataIndex];
        indexBlocks.add(indexBlock);
        inode = inode.copyWith(tripleIndirect: indexBlock);
        dataIndex++;

        while (dataIndex < neededBlocks && dataIndex < freeBlocks.length) {
          dataBlocks.add(freeBlocks[dataIndex]);
          dataIndex++;
        }
      }
    }

    final success = dataBlocks.length >= neededBlocks;
    final finalDataBlocks = success ? dataBlocks.sublist(0, neededBlocks) : dataBlocks;

    return _MultilevelAllocResult(
      success: success,
      inode: inode,
      dataBlocks: finalDataBlocks,
      indexBlocks: indexBlocks,
    );
  }

  static int _calcFragmentation(List<FileBlock> blocks, int blockSize) {
    int freeBlocks = 0;
    for (final block in blocks) {
      if (block.isFree) freeBlocks++;
    }
    return freeBlocks * blockSize;
  }
}

class _MultilevelAllocResult {
  final bool success;
  final Inode inode;
  final List<int> dataBlocks;
  final List<int> indexBlocks;

  _MultilevelAllocResult({
    required this.success,
    required this.inode,
    required this.dataBlocks,
    required this.indexBlocks,
  });
}