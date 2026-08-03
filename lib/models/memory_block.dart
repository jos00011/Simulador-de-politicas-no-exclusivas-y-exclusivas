// lib/models/memory_block.dart

enum BlockStatus { free, occupied }

class MemoryBlock {
  final String id; // unique block id
  final int startAddress;
  final int size;           // actual size of the block (may be power-of-2 for buddy)
  final BlockStatus status;
  final String? processId;  // null if free
  final int? buddyAllocatedSize; // buddy: the power-of-2 size allocated (>= process request)
  final int? buddyLevel;    // buddy: level in the binary tree (log2 of size)

  const MemoryBlock({
    required this.id,
    required this.startAddress,
    required this.size,
    required this.status,
    this.processId,
    this.buddyAllocatedSize,
    this.buddyLevel,
  });

  bool get isFree => status == BlockStatus.free;
  bool get isOccupied => status == BlockStatus.occupied;
  int get endAddress => startAddress + size;

  /// Internal fragmentation for this block (buddy only)
  int get internalFragmentation {
    if (!isOccupied || buddyAllocatedSize == null) return 0;
    return buddyAllocatedSize! - size;
  }

  MemoryBlock copyWith({
    String? id,
    int? startAddress,
    int? size,
    BlockStatus? status,
    String? processId,
    bool clearProcess = false,
    int? buddyAllocatedSize,
    int? buddyLevel,
  }) {
    return MemoryBlock(
      id: id ?? this.id,
      startAddress: startAddress ?? this.startAddress,
      size: size ?? this.size,
      status: status ?? this.status,
      processId: clearProcess ? null : (processId ?? this.processId),
      buddyAllocatedSize: buddyAllocatedSize ?? this.buddyAllocatedSize,
      buddyLevel: buddyLevel ?? this.buddyLevel,
    );
  }

  @override
  String toString() =>
      'MemoryBlock(id: $id, start: $startAddress, size: $size, '
      'status: ${status.name}, process: $processId)';
}