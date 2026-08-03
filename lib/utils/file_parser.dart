// lib/utils/file_parser.dart

import '../models/process.dart';

class FileParser {
  static List<Process> parse(String content, String extension) {
    if (extension.toLowerCase() == 'csv') {
      return _parseCsv(content);
    }
    return _parseTxt(content);
  }

  static List<Process> _parseCsv(String content) {
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final processes = <Process>[];
    int start = 0;

    // Skip header if first line contains non-numeric first column
    if (lines.isNotEmpty) {
      final firstParts = lines[0].split(',');
      if (firstParts.isNotEmpty && 
          int.tryParse(firstParts[0].trim()) == null && 
          firstParts[0].trim().toLowerCase() != 'p1' && 
          !firstParts[0].trim().startsWith(RegExp(r'[Pp]\d'))) {
        start = 1;
      }
    }

    for (int i = start; i < lines.length; i++) {
      try {
        final parts = lines[i].split(',');
        if (parts.length < 3) continue;
        processes.add(Process(
          id: parts[0].trim(),
          arrivalTime: int.parse(parts[1].trim()),
          burstTime: int.parse(parts[2].trim()),
          memorySize: parts.length > 3 ? int.tryParse(parts[3].trim()) ?? 64 : 64,
        ));
      } catch (_) {
        continue;
      }
    }
    return processes;
  }

  static List<Process> _parseTxt(String content) {
    final lines = content.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final processes = <Process>[];

    for (final line in lines) {
      if (line.startsWith('#') || line.startsWith('//')) continue;
      try {
        final parts = line.trim().split(RegExp(r'[\s,;|]+'));
        if (parts.length < 3) continue;
        processes.add(Process(
          id: parts[0],
          arrivalTime: int.parse(parts[1]),
          burstTime: int.parse(parts[2]),
          memorySize: parts.length > 3 ? int.tryParse(parts[3]) ?? 64 : 64,
        ));
      } catch (_) {
        continue;
      }
    }
    return processes;
  }

  static String generateSampleCsv() {
    return '''ID,T.Llegada,T.Servicio,Memoria(KB)
A,0,9,128
B,3,5,64
C,6,1,32
D,1,7,96
E,4,3,48
''';
  }

  static String generateSampleTxt() {
    return '''# Formato: ID ArrivalTime BurstTime MemoryKB
A 0 9 128
B 3 5 64
C 6 1 32
D 1 7 96
E 4 3 48
''';
  }

  static String? validate(List<Process> processes) {
    if (processes.isEmpty) return 'No se encontraron procesos válidos en el archivo.';
    final ids = processes.map((p) => p.id).toSet();
    if (ids.length != processes.length) return 'Hay IDs de procesos duplicados.';
    for (final p in processes) {
      if (p.burstTime <= 0) return 'El proceso ${p.id} tiene tiempo de servicio inválido (≤ 0).';
      if (p.arrivalTime < 0) return 'El proceso ${p.id} tiene tiempo de llegada negativo.';
      if (p.memorySize <= 0) return 'El proceso ${p.id} tiene memoria inválida (≤ 0).';
    }
    return null;
  }
}