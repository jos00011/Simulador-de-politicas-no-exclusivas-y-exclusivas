// lib/models/file_allocation_event.dart

import 'file_block.dart';

enum FileAllocationEventType {
  allocate,
  link,
  indexedAlloc, // Antes 'index' → ahora 'indexedAlloc' para evitar conflicto
  fail,
  free,
  compact
}

class FileAllocationEvent {
  final FileAllocationEventType type;
  final String? fileId;
  final int? startBlock;
  final int? blocksAllocated;
  final List<int>? allocatedBlocks;
  final List<FileBlock> snapshotAfter;
  final String description;
  final int fragmentation;

  const FileAllocationEvent({
    required this.type,
    required this.snapshotAfter,
    required this.description,
    required this.fragmentation,
    this.fileId,
    this.startBlock,
    this.blocksAllocated,
    this.allocatedBlocks,
  });
}