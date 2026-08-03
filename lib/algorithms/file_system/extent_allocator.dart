// lib/algorithms/file_system/extent_allocator.dart
// Asignación por Extensiones (Extents)

import '../../models/process.dart';
import '../../models/file_block.dart';
import '../../models/file_allocation_event.dart';
import '../../models/advanced_fs_result.dart';
import '../../models/extent.dart';

class ExtentAllocator {
  static const int blockSize = 64; // KB por bloque

  static AdvancedFsResult simulate({
    required List<Process> processes,
    required int totalBlocks,
    required int blockSize,
  }) {
    // Inicializar bloques
    var blocks = List.generate(totalBlocks, (i) => FileBlock(blockIndex: i));
    
    // Lista de extensiones por archivo
    final allExtents = <FileExtents>[];
    
    final events = <FileAllocationEvent>[];
    final fileAllocations = <String, List<int>>{};

    for (final process in processes) {
      final neededBlocks = (process.memorySize / blockSize).ceil();

      // Buscar extensiones contiguas para el archivo
      final result = _allocateExtents(blocks, neededBlocks, process.id);

      if (!result.success) {
        events.add(FileAllocationEvent(
          type: FileAllocationEventType.fail,
          fileId: process.id,
          snapshotAfter: List.from(blocks),
          description: 'FALLO EXTENSIÓN: No hay suficiente espacio contiguo para ${process.id} '
              '(necesita $neededBlocks bloques)',
          fragmentation: _calcFragmentation(blocks, blockSize),
        ));
        continue;
      }

      // Actualizar bloques
      final allocatedBlocks = <int>[];
      for (final extent in result.extents) {
        for (int i = extent.startBlock; i <= extent.endBlock; i++) {
          blocks[i] = blocks[i].copyWith(
            status: FileBlockStatus.occupied,
            fileId: process.id,
          );
          allocatedBlocks.add(i);
        }
      }

      // Guardar extensiones
      allExtents.add(FileExtents(
        fileId: process.id,
        extents: result.extents,
      ));

      fileAllocations[process.id] = allocatedBlocks;

      final extentDesc = result.extents.map((e) => e.toString()).join(', ');

      events.add(FileAllocationEvent(
        type: FileAllocationEventType.allocate,
        fileId: process.id,
        startBlock: result.extents.first.startBlock,
        blocksAllocated: allocatedBlocks.length,
        allocatedBlocks: allocatedBlocks,
        snapshotAfter: List.from(blocks),
        description: 'EXTENSIÓN ASIGNADO: ${process.id} → ${result.extents.length} extensiones '
            '($extentDesc) — ${allocatedBlocks.length} bloques, ${process.memorySize} KB',
        fragmentation: _calcFragmentation(blocks, blockSize),
      ));
    }

    return AdvancedFsResult(
      method: AdvancedFsMethod.extent,
      totalBlocks: totalBlocks,
      blockSize: blockSize,
      events: events,
      finalState: blocks,
      fileExtents: allExtents,
    );
  }

  static _ExtentAllocResult _allocateExtents(
    List<FileBlock> blocks,
    int neededBlocks,
    String fileId,
  ) {
    final extents = <Extent>[];
    int remaining = neededBlocks;
    int currentRun = 0;
    int runStart = 0;

    // Primera pasada: buscar todos los huecos contiguos
    final holes = <Extent>[];
    for (int i = 0; i < blocks.length; i++) {
      if (blocks[i].isFree) {
        if (currentRun == 0) runStart = i;
        currentRun++;
      } else {
        if (currentRun > 0) {
          holes.add(Extent(runStart, currentRun));
          currentRun = 0;
        }
      }
    }
    if (currentRun > 0) {
      holes.add(Extent(runStart, currentRun));
    }

    // Ordenar por tamaño (mayor primero) para usar los huecos más grandes
    holes.sort((a, b) => b.length.compareTo(a.length));

    // Asignar extensiones hasta cubrir la necesidad
    for (final hole in holes) {
      if (remaining <= 0) break;
      final take = hole.length < remaining ? hole.length : remaining;
      extents.add(Extent(hole.startBlock, take));
      remaining -= take;
    }

    if (remaining > 0) {
      return _ExtentAllocResult(success: false, extents: []);
    }

    // Ordenar extensiones por startBlock para mantener consistencia
    extents.sort((a, b) => a.startBlock.compareTo(b.startBlock));
    return _ExtentAllocResult(success: true, extents: extents);
  }

  static int _calcFragmentation(List<FileBlock> blocks, int blockSize) {
    int freeBlocks = 0;
    for (final block in blocks) {
      if (block.isFree) freeBlocks++;
    }
    return freeBlocks * blockSize;
  }
}

class _ExtentAllocResult {
  final bool success;
  final List<Extent> extents;

  _ExtentAllocResult({required this.success, required this.extents});
}