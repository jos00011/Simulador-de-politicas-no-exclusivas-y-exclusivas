// lib/models/memory_event.dart

import 'memory_block.dart';

enum MemoryEventType { allocate, deallocate, compact, fail, buddyMerge, buddySplit }

class MemoryEvent {
  final MemoryEventType type;
  final String? processId;
  final int? requestedSize;
  final int? allocatedStart;
  final int? allocatedSize;        // actual process size
  final int? buddyBlockSize;       // buddy: power-of-2 block assigned
  final List<MemoryBlock> snapshotAfter;
  final String description;
  final int fragmentation;         // external fragmentation in KB
  final int internalFragmentation; // internal fragmentation in KB (buddy only)

  const MemoryEvent({
    required this.type,
    required this.snapshotAfter,
    required this.description,
    required this.fragmentation,
    this.processId,
    this.requestedSize,
    this.allocatedStart,
    this.allocatedSize,
    this.buddyBlockSize,
    this.internalFragmentation = 0,
  });
}
