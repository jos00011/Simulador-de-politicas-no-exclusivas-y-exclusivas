// lib/models/file_block.dart

enum FileBlockStatus { free, occupied, indexBlock }

class FileBlock {
  final int blockIndex;
  final FileBlockStatus status;
  final String? fileId;
  final int? nextBlockIndex;
  final bool isIndexBlock;
  final List<int>? indexedBlocks;

  const FileBlock({
    required this.blockIndex,
    this.status = FileBlockStatus.free,
    this.fileId,
    this.nextBlockIndex,
    this.isIndexBlock = false,
    this.indexedBlocks,
  });

  bool get isFree => status == FileBlockStatus.free;
  bool get isOccupied => status == FileBlockStatus.occupied;
  bool get isIndex => status == FileBlockStatus.indexBlock;

  FileBlock copyWith({
    int? blockIndex,
    FileBlockStatus? status,
    String? fileId,
    int? nextBlockIndex,
    bool? isIndexBlock,
    List<int>? indexedBlocks,
  }) {
    return FileBlock(
      blockIndex: blockIndex ?? this.blockIndex,
      status: status ?? this.status,
      fileId: fileId ?? this.fileId,
      nextBlockIndex: nextBlockIndex ?? this.nextBlockIndex,
      isIndexBlock: isIndexBlock ?? this.isIndexBlock,
      indexedBlocks: indexedBlocks ?? this.indexedBlocks,
    );
  }
}