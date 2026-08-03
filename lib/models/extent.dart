// lib/models/extent.dart

class Extent {
  final int startBlock;
  final int length;

  const Extent(this.startBlock, this.length);

  int get endBlock => startBlock + length - 1;

  Map<String, dynamic> toMap() => {
        'startBlock': startBlock,
        'length': length,
        'endBlock': endBlock,
      };

  Extent copyWith({int? startBlock, int? length}) {
    return Extent(
      startBlock ?? this.startBlock,
      length ?? this.length,
    );
  }

  bool contains(int blockIndex) {
    return blockIndex >= startBlock && blockIndex <= endBlock;
  }

  bool isAdjacent(Extent other) {
    return endBlock + 1 == other.startBlock || other.endBlock + 1 == startBlock;
  }

  Extent merge(Extent other) {
    final start = startBlock < other.startBlock ? startBlock : other.startBlock;
    final end = endBlock > other.endBlock ? endBlock : other.endBlock;
    return Extent(start, end - start + 1);
  }

  @override
  String toString() => '[$startBlock - $endBlock] ($length bloques)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Extent &&
        other.startBlock == startBlock &&
        other.length == length;
  }

  @override
  int get hashCode => startBlock.hashCode ^ length.hashCode;
}

class FileExtents {
  final String fileId;
  final List<Extent> extents;

  FileExtents({required this.fileId, required this.extents});

  int get totalBlocks => extents.fold(0, (sum, e) => sum + e.length);
  int get extentCount => extents.length;
  bool get hasExtents => extents.isNotEmpty;

  Map<String, dynamic> toMap() => {
        'fileId': fileId,
        'extents': extents.map((e) => e.toMap()).toList(),
        'totalBlocks': totalBlocks,
        'extentCount': extentCount,
      };

  FileExtents copyWith({String? fileId, List<Extent>? extents}) {
    return FileExtents(
      fileId: fileId ?? this.fileId,
      extents: extents ?? this.extents,
    );
  }

  FileExtents addExtent(Extent newExtent) {
    final newExtents = <Extent>[];
    bool merged = false;
    for (final e in extents) {
      if (e.isAdjacent(newExtent) && !merged) {
        newExtents.add(e.merge(newExtent));
        merged = true;
      } else {
        newExtents.add(e);
      }
    }
    if (!merged) {
      newExtents.add(newExtent);
      newExtents.sort((a, b) => a.startBlock.compareTo(b.startBlock));
    }
    return FileExtents(fileId: fileId, extents: newExtents);
  }

  @override
  String toString() => '$fileId: ${extents.join(', ')}';
}

class ExtentAllocationResult {
  final String fileId;
  final List<Extent> allocatedExtents;
  final List<FileExtents> allExtents;
  final bool success;
  final String? error;

  ExtentAllocationResult({
    required this.fileId,
    required this.allocatedExtents,
    required this.allExtents,
    required this.success,
    this.error,
  });

  Map<String, dynamic> toMap() => {
        'fileId': fileId,
        'allocatedExtents': allocatedExtents.map((e) => e.toMap()).toList(),
        'allExtents': allExtents.map((e) => e.toMap()).toList(),
        'success': success,
        'error': error,
      };
}