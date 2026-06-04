// lib/utils/memory_allocator.dart

import 'dart:math';
import '../models/memory_block.dart';
import '../models/memory_event.dart';
import '../models/memory_result.dart';
import '../models/process.dart';

class MemoryAllocator {
  // ─────────────────────────────────────────────────────────────
  //  ENTRY POINT
  // ─────────────────────────────────────────────────────────────
  static MemoryResult simulate({
    required List<Process> processes,
    required int totalMemory,
    required AllocationAlgorithm algorithm,
  }) {
    if (algorithm == AllocationAlgorithm.buddySystem) {
      return _simulateBuddy(processes: processes, totalMemory: totalMemory);
    }
    return _simulateClassic(
        processes: processes, totalMemory: totalMemory, algorithm: algorithm);
  }

  // ─────────────────────────────────────────────────────────────
  //  CLASSIC ALGORITHMS (First Fit / Best Fit / Worst Fit)
  // ─────────────────────────────────────────────────────────────
  static MemoryResult _simulateClassic({
    required List<Process> processes,
    required int totalMemory,
    required AllocationAlgorithm algorithm,
  }) {
    var blocks = <MemoryBlock>[
      MemoryBlock(
        id: 'free_0',
        startAddress: 0,
        size: totalMemory,
        status: BlockStatus.free,
      ),
    ];

    final events = <MemoryEvent>[];
    int blockCounter = 1;

    for (final process in processes) {
      final freeList = blocks
          .where((b) => b.isFree && b.size >= process.memorySize)
          .toList();

      if (freeList.isEmpty) {
        events.add(MemoryEvent(
          type: MemoryEventType.fail,
          processId: process.id,
          requestedSize: process.memorySize,
          snapshotAfter: List.from(blocks),
          description:
              'FALLO: No hay hueco libre ≥ ${process.memorySize} KB para ${process.id}',
          fragmentation: _calcExternalFrag(blocks),
        ));
        continue;
      }

      MemoryBlock selected;
      switch (algorithm) {
        case AllocationAlgorithm.firstFit:
          freeList.sort((a, b) => a.startAddress.compareTo(b.startAddress));
          selected = freeList.first;
          break;
        case AllocationAlgorithm.bestFit:
          freeList.sort((a, b) => a.size.compareTo(b.size));
          selected = freeList.first;
          break;
        case AllocationAlgorithm.worstFit:
          freeList.sort((a, b) => b.size.compareTo(a.size));
          selected = freeList.first;
          break;
        default:
          freeList.sort((a, b) => a.startAddress.compareTo(b.startAddress));
          selected = freeList.first;
      }

      final idx = blocks.indexOf(selected);
      final newBlocks = <MemoryBlock>[];

      for (int i = 0; i < blocks.length; i++) {
        if (i != idx) {
          newBlocks.add(blocks[i]);
          continue;
        }
        newBlocks.add(MemoryBlock(
          id: 'occ_${process.id}',
          startAddress: selected.startAddress,
          size: process.memorySize,
          status: BlockStatus.occupied,
          processId: process.id,
        ));
        final remaining = selected.size - process.memorySize;
        if (remaining > 0) {
          newBlocks.add(MemoryBlock(
            id: 'free_${blockCounter++}',
            startAddress: selected.startAddress + process.memorySize,
            size: remaining,
            status: BlockStatus.free,
          ));
        }
      }

      blocks = newBlocks;

      events.add(MemoryEvent(
        type: MemoryEventType.allocate,
        processId: process.id,
        requestedSize: process.memorySize,
        allocatedStart: selected.startAddress,
        allocatedSize: process.memorySize,
        snapshotAfter: List.from(blocks),
        description:
            'ASIGNADO: ${process.id} → ${process.memorySize} KB en @${selected.startAddress} '
            '(hueco era ${selected.size} KB, sobran ${selected.size - process.memorySize} KB)',
        fragmentation: _calcExternalFrag(blocks),
      ));
    }

    return MemoryResult(
      algorithm: algorithm,
      totalMemory: totalMemory,
      events: events,
      finalState: blocks,
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  BUDDY SYSTEM
  // ─────────────────────────────────────────────────────────────

  /// Returns smallest power of 2 >= n
  static int _nextPow2(int n) {
    if (n <= 1) return 1;
    return pow(2, (log(n) / log(2)).ceil()).toInt();
  }

  static int _log2(int n) => (log(n) / log(2)).round();

  static MemoryResult _simulateBuddy({
    required List<Process> processes,
    required int totalMemory,
  }) {
    // totalMemory must be power of 2; snap up if needed
    final memSize = _nextPow2(totalMemory);

    // Buddy tree: map from startAddress → MemoryBlock
    // We represent the state as a flat sorted list for compatibility with
    // the existing UI, but internally we manage a buddy tree.
    var blocks = <MemoryBlock>[
      MemoryBlock(
        id: 'buddy_free_0',
        startAddress: 0,
        size: memSize,
        status: BlockStatus.free,
        buddyLevel: _log2(memSize),
      ),
    ];

    final events = <MemoryEvent>[];
    int blockCounter = 1;

    for (final process in processes) {
      final needed = _nextPow2(process.memorySize);

      // Find the smallest free block that fits `needed`
      final result = _buddyAllocate(blocks, needed, process, blockCounter);

      if (result == null) {
        events.add(MemoryEvent(
          type: MemoryEventType.fail,
          processId: process.id,
          requestedSize: process.memorySize,
          snapshotAfter: List.from(blocks),
          description:
              'FALLO Buddy: No hay bloque libre ≥ $needed KB (pot. 2) para '
              '${process.id} (pide ${process.memorySize} KB)',
          fragmentation: _calcExternalFrag(blocks),
          internalFragmentation: _calcInternalFrag(blocks),
        ));
        continue;
      }

      blocks = result.blocks;
      blockCounter = result.counter;

      final internalWaste = needed - process.memorySize;

      // Record the split steps as sub-events in description
      events.add(MemoryEvent(
        type: MemoryEventType.allocate,
        processId: process.id,
        requestedSize: process.memorySize,
        allocatedStart: result.allocatedStart,
        allocatedSize: process.memorySize,
        buddyBlockSize: needed,
        snapshotAfter: List.from(blocks),
        description:
            'BUDDY ASIGNADO: ${process.id} → ${process.memorySize} KB\n'
            'Bloque gemelo: $needed KB @ @${result.allocatedStart}\n'
            'Fragmentación interna: $internalWaste KB desperdiciados',
        fragmentation: _calcExternalFrag(blocks),
        internalFragmentation: _calcInternalFrag(blocks),
      ));
    }

    return MemoryResult(
      algorithm: AllocationAlgorithm.buddySystem,
      totalMemory: memSize,
      events: events,
      finalState: blocks,
    );
  }

  static _BuddyAllocResult? _buddyAllocate(
    List<MemoryBlock> blocks,
    int needed,
    Process process,
    int counter,
  ) {
    // Sort by address
    final sorted = [...blocks]
      ..sort((a, b) => a.startAddress.compareTo(b.startAddress));

    // Find smallest free block >= needed
    final candidates = sorted
        .where((b) => b.isFree && b.size >= needed)
        .toList()
      ..sort((a, b) => a.size.compareTo(b.size));

    if (candidates.isEmpty) return null;

    var current = [...blocks];
    var chosen = candidates.first;

    // Split until we reach exactly `needed`
    while (chosen.size > needed) {
      final half = chosen.size ~/ 2;
      final idx = current.indexOf(chosen);
      current.removeAt(idx);
      // Left buddy
      final left = MemoryBlock(
        id: 'buddy_free_${counter++}',
        startAddress: chosen.startAddress,
        size: half,
        status: BlockStatus.free,
        buddyLevel: _log2(half),
      );
      // Right buddy
      final right = MemoryBlock(
        id: 'buddy_free_${counter++}',
        startAddress: chosen.startAddress + half,
        size: half,
        status: BlockStatus.free,
        buddyLevel: _log2(half),
      );
      current.insert(idx, right);
      current.insert(idx, left);
      chosen = left; // allocate from left
    }

    // Allocate chosen block
    final allocIdx = current.indexWhere((b) => b.id == chosen.id);
    current[allocIdx] = MemoryBlock(
      id: 'buddy_occ_${process.id}',
      startAddress: chosen.startAddress,
      size: process.memorySize, // actual process size
      status: BlockStatus.occupied,
      processId: process.id,
      buddyAllocatedSize: needed, // power-of-2 block size
      buddyLevel: _log2(needed),
    );

    // If process.memorySize < needed, the leftover inside the block is
    // internal fragmentation — we do NOT split it further (buddy rule).

    current.sort((a, b) => a.startAddress.compareTo(b.startAddress));

    return _BuddyAllocResult(
      blocks: current,
      counter: counter,
      allocatedStart: chosen.startAddress,
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  BUDDY DEALLOCATE + MERGE (for future use / compaction)
  // ─────────────────────────────────────────────────────────────
  static List<MemoryBlock> buddyDeallocate(
      List<MemoryBlock> blocks, String processId, int totalMemory) {
    var current = [...blocks];
    final target = current.firstWhere(
      (b) => b.isOccupied && b.processId == processId,
      orElse: () => current.first,
    );

    if (!target.isOccupied) return blocks;

    final blockSize = target.buddyAllocatedSize ?? target.size;

    // Free the block
    final idx = current.indexOf(target);
    current[idx] = MemoryBlock(
      id: 'buddy_free_released',
      startAddress: target.startAddress,
      size: blockSize,
      status: BlockStatus.free,
      buddyLevel: _log2(blockSize),
    );

    // Merge buddies iteratively
    current = _mergeBuddies(current, totalMemory);
    return current;
  }

  static List<MemoryBlock> _mergeBuddies(
      List<MemoryBlock> blocks, int totalMemory) {
    bool merged = true;
    var current = [...blocks];

    while (merged) {
      merged = false;
      current.sort((a, b) => a.startAddress.compareTo(b.startAddress));

      for (int i = 0; i < current.length - 1; i++) {
        final a = current[i];
        final b = current[i + 1];

        if (!a.isFree || !b.isFree) continue;
        if (a.size != b.size) continue;
        // Buddy condition: same size, adjacent, and start of 'a' is aligned
        if (a.startAddress % (a.size * 2) != 0) continue;
        if (a.startAddress + a.size != b.startAddress) continue;

        // Merge
        final merged_block = MemoryBlock(
          id: 'buddy_merged_${a.startAddress}',
          startAddress: a.startAddress,
          size: a.size * 2,
          status: BlockStatus.free,
          buddyLevel: _log2(a.size * 2),
        );
        current.removeAt(i + 1);
        current.removeAt(i);
        current.insert(i, merged_block);
        merged = true;
        break;
      }
    }

    return current;
  }

  // ─────────────────────────────────────────────────────────────
  //  COMPACT (classic only — buddy uses merge instead)
  // ─────────────────────────────────────────────────────────────
  static List<MemoryBlock> compact(
      List<MemoryBlock> blocks, int totalMemory) {
    final occupied = blocks.where((b) => b.isOccupied).toList();
    int addr = 0;
    final result = <MemoryBlock>[];

    for (final b in occupied) {
      result.add(MemoryBlock(
        id: b.id,
        startAddress: addr,
        size: b.size,
        status: BlockStatus.occupied,
        processId: b.processId,
      ));
      addr += b.size;
    }

    if (addr < totalMemory) {
      result.add(MemoryBlock(
        id: 'free_compact',
        startAddress: addr,
        size: totalMemory - addr,
        status: BlockStatus.free,
      ));
    }

    return result;
  }

  // ─────────────────────────────────────────────────────────────
  //  HELPERS
  // ─────────────────────────────────────────────────────────────
  static int _calcExternalFrag(List<MemoryBlock> blocks) {
    final freeList = blocks.where((b) => b.isFree).toList();
    if (freeList.length <= 1) return 0;
    final total = freeList.fold(0, (s, b) => s + b.size);
    final largest =
        freeList.map((b) => b.size).reduce((a, b) => a > b ? a : b);
    return total - largest;
  }

  static int _calcInternalFrag(List<MemoryBlock> blocks) {
    return blocks.where((b) => b.isOccupied).fold(0, (s, b) {
      if (b.buddyAllocatedSize == null) return s;
      return s + (b.buddyAllocatedSize! - b.size);
    });
  }
}

class _BuddyAllocResult {
  final List<MemoryBlock> blocks;
  final int counter;
  final int allocatedStart;

  _BuddyAllocResult({
    required this.blocks,
    required this.counter,
    required this.allocatedStart,
  });
}
