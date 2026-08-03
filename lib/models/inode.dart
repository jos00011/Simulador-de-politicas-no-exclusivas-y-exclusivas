// lib/models/inode.dart
// Modelo de Inodo para asignación multinivel (UNIX-like)

import '../core/app_constants.dart';

class Inode {
  // 12 punteros directos a bloques de datos
  final List<int> direct;
  
  // Punteros indirectos (bloques índice)
  final int? singleIndirect;   // Apunta a un bloque con 256 punteros
  final int? doubleIndirect;   // Apunta a un bloque con 256 punteros a bloques índice
  final int? tripleIndirect;   // Apunta a un bloque con 256 punteros a bloques índice doble

  Inode({
    required this.direct,
    this.singleIndirect,
    this.doubleIndirect,
    this.tripleIndirect,
  });

  /// Crea un inodo vacío (todos los punteros en -1)
  factory Inode.empty() {
    return Inode(
      direct: List.filled(AppConstants.directPointers, -1),
      singleIndirect: null,
      doubleIndirect: null,
      tripleIndirect: null,
    );
  }

  /// Crea un inodo con solo punteros directos
  factory Inode.fromDirectBlocks(List<int> blocks) {
    final direct = List.filled(AppConstants.directPointers, -1);
    for (int i = 0; i < blocks.length && i < AppConstants.directPointers; i++) {
      direct[i] = blocks[i];
    }
    return Inode(direct: direct);
  }

  /// Obtiene todos los punteros (directos e indirectos)
  List<int> getAllPointers() {
    final list = <int>[];
    list.addAll(direct.where((p) => p != -1));
    if (singleIndirect != null) list.add(singleIndirect!);
    if (doubleIndirect != null) list.add(doubleIndirect!);
    if (tripleIndirect != null) list.add(tripleIndirect!);
    return list;
  }

  /// Obtiene solo los punteros directos válidos
  List<int> get directPointers => direct.where((p) => p != -1).toList();

  /// Número total de bloques usados por el inodo (incluyendo bloques índice)
  int get totalBlocks {
    int count = direct.where((p) => p != -1).length;
    if (singleIndirect != null) count += 1;
    if (doubleIndirect != null) count += 1;
    if (tripleIndirect != null) count += 1;
    return count;
  }

  /// Número máximo de bloques de datos que puede direccionar este inodo
  int get maxDataBlocks {
    int total = AppConstants.directPointers; // 12 directos
    if (singleIndirect != null) total += AppConstants.singleIndirectSize;
    if (doubleIndirect != null) total += AppConstants.doubleIndirectSize;
    if (tripleIndirect != null) total += AppConstants.doubleIndirectSize * AppConstants.singleIndirectSize;
    return total;
  }

  /// Nivel de indirección máximo usado
  int get maxIndirectionLevel {
    if (tripleIndirect != null) return 3;
    if (doubleIndirect != null) return 2;
    if (singleIndirect != null) return 1;
    return 0;
  }

  /// Verifica si el inodo puede almacenar N bloques
  bool canStore(int blockCount) {
    return blockCount <= maxDataBlocks;
  }

  /// Copia el inodo con modificaciones
  Inode copyWith({
    List<int>? direct,
    int? singleIndirect,
    int? doubleIndirect,
    int? tripleIndirect,
    bool clearSingle = false,
    bool clearDouble = false,
    bool clearTriple = false,
  }) {
    return Inode(
      direct: direct ?? this.direct,
      singleIndirect: clearSingle ? null : (singleIndirect ?? this.singleIndirect),
      doubleIndirect: clearDouble ? null : (doubleIndirect ?? this.doubleIndirect),
      tripleIndirect: clearTriple ? null : (tripleIndirect ?? this.tripleIndirect),
    );
  }

  /// Agrega un bloque directo (si hay espacio)
  Inode addDirectBlock(int blockIndex) {
    final newDirect = List<int>.from(direct);
    for (int i = 0; i < newDirect.length; i++) {
      if (newDirect[i] == -1) {
        newDirect[i] = blockIndex;
        break;
      }
    }
    return copyWith(direct: newDirect);
  }

  /// Obtiene el primer índice libre en directos
  int? get firstFreeDirectSlot {
    for (int i = 0; i < direct.length; i++) {
      if (direct[i] == -1) return i;
    }
    return null;
  }

  /// Verifica si los directos están llenos
  bool get directFull => direct.every((p) => p != -1);

  @override
  String toString() {
    final parts = <String>[];
    final directStr = direct.map((p) => p == -1 ? '·' : p.toString()).join(', ');
    parts.add('direct: [$directStr]');
    if (singleIndirect != null) parts.add('single: ${singleIndirect!}');
    if (doubleIndirect != null) parts.add('double: ${doubleIndirect!}');
    if (tripleIndirect != null) parts.add('triple: ${tripleIndirect!}');
    return 'Inode(${parts.join(', ')})';
  }

  Map<String, dynamic> toMap() => {
        'direct': direct,
        'singleIndirect': singleIndirect,
        'doubleIndirect': doubleIndirect,
        'tripleIndirect': tripleIndirect,
        'totalBlocks': totalBlocks,
        'maxDataBlocks': maxDataBlocks,
        'maxIndirectionLevel': maxIndirectionLevel,
      };
}

/// Resultado de asignación multinivel
class MultilevelAllocationResult {
  final String fileId;
  final Inode inode;
  final List<int> dataBlocks;
  final List<int> indexBlocks; // Bloques índice (indirectos)
  final bool success;
  final String? error;

  MultilevelAllocationResult({
    required this.fileId,
    required this.inode,
    required this.dataBlocks,
    required this.indexBlocks,
    required this.success,
    this.error,
  });

  List<int> get allBlocks => [...dataBlocks, ...indexBlocks];

  Map<String, dynamic> toMap() => {
        'fileId': fileId,
        'inode': inode.toMap(),
        'dataBlocks': dataBlocks,
        'indexBlocks': indexBlocks,
        'success': success,
        'error': error,
      };
}