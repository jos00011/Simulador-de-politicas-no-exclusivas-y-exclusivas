// lib/models/fat_table.dart
// Modelo de la Tabla FAT (File Allocation Table)

import '../core/app_constants.dart';

class FATTable {
  final List<int> entries;
  // -2 = libre (AppConstants.fatFree)
  // -1 = fin de cadena (AppConstants.fatEof)
  // >=0 = siguiente bloque en la cadena

  FATTable({required this.entries});

  int get length => entries.length;
  int get freeBlocks => entries.where((e) => e == AppConstants.fatFree).length;
  int get usedBlocks => length - freeBlocks;

  bool isFree(int index) => entries[index] == AppConstants.fatFree;
  bool isEof(int index) => entries[index] == AppConstants.fatEof;
  bool isValid(int index) => index >= 0 && index < entries.length;

  /// Crea una FAT inicial con todos los bloques libres
  factory FATTable.initial(int size) {
    return FATTable(entries: List.filled(size, AppConstants.fatFree));
  }

  /// Crea una copia con entries modificados
  FATTable copyWith({List<int>? entries}) {
    return FATTable(entries: entries ?? this.entries);
  }

  /// Obtiene la cadena de bloques para un archivo dado su bloque inicial
  List<int> getChain(int startBlock) {
    if (!isValid(startBlock) || isFree(startBlock)) return [];
    final chain = <int>[];
    int current = startBlock;
    while (current >= 0 && !chain.contains(current)) {
      chain.add(current);
      current = entries[current];
      if (current == AppConstants.fatEof) break;
    }
    return chain;
  }

  /// Obtiene todas las cadenas de archivos presentes en la FAT
  Map<int, List<int>> getFileChains() {
    final visited = <int>{};
    final chains = <int, List<int>>{};
    for (int i = 0; i < entries.length; i++) {
      if (visited.contains(i) || isFree(i)) continue;
      final chain = <int>[];
      int current = i;
      while (current >= 0 && !visited.contains(current)) {
        visited.add(current);
        chain.add(current);
        current = entries[current];
      }
      if (chain.isNotEmpty) {
        chains[chain.first] = chain;
      }
    }
    return chains;
  }

  /// Encuentra bloques libres contiguos
  List<int> findFreeBlocks(int count) {
    final result = <int>[];
    for (int i = 0; i < entries.length && result.length < count; i++) {
      if (isFree(i)) result.add(i);
    }
    return result.length == count ? result : [];
  }

  /// Asigna una cadena de bloques en la FAT
  void allocateChain(List<int> blocks) {
    if (blocks.isEmpty) return;
    for (int i = 0; i < blocks.length; i++) {
      final current = blocks[i];
      final next = (i < blocks.length - 1) ? blocks[i + 1] : AppConstants.fatEof;
      if (isValid(current) && isFree(current)) {
        entries[current] = next;
      }
    }
  }

  /// Libera todos los bloques de una cadena
  void freeChain(int startBlock) {
    if (!isValid(startBlock) || isFree(startBlock)) return;
    int current = startBlock;
    while (current >= 0 && !isFree(current)) {
      final next = entries[current];
      entries[current] = AppConstants.fatFree;
      current = next;
    }
  }

  /// Obtiene estadísticas de la FAT
  Map<String, dynamic> getStats() {
    final chains = getFileChains();
    return {
      'totalBlocks': length,
      'freeBlocks': freeBlocks,
      'usedBlocks': usedBlocks,
      'fileCount': chains.length,
      'averageChainLength': chains.isEmpty
          ? 0
          : chains.values.fold(0, (sum, c) => sum + c.length) / chains.length,
      'largestChain': chains.isEmpty
          ? 0
          : chains.values.map((c) => c.length).reduce((a, b) => a > b ? a : b),
    };
  }

  @override
  String toString() => 'FAT: ${entries.join(', ')}';
}

/// Resultado de asignación con FAT
class FATAllocationResult {
  final String fileId;
  final List<int> allocatedBlocks;
  final FATTable updatedFat;
  final bool success;
  final String? error;

  FATAllocationResult({
    required this.fileId,
    required this.allocatedBlocks,
    required this.updatedFat,
    required this.success,
    this.error,
  });
}