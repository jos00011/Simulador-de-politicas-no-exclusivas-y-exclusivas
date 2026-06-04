// lib/models/process.dart

class Process {
  final String id;
  final int arrivalTime;
  final int burstTime;
  int remainingTime;
  int startTime;
  int finishTime;
  int waitingTime;
  int turnaroundTime;
  int memorySize; // KB

  Process({
    required this.id,
    required this.arrivalTime,
    required this.burstTime,
    this.memorySize = 0,
  })  : remainingTime = burstTime,
        startTime = -1,
        finishTime = -1,
        waitingTime = 0,
        turnaroundTime = 0;

  /// Turnaround Time = Finish - Arrival
  int get tr => finishTime - arrivalTime;

  /// Waiting Time = Turnaround - Burst
  int get te => tr - burstTime;

  Process copyWith() => Process(
        id: id,
        arrivalTime: arrivalTime,
        burstTime: burstTime,
        memorySize: memorySize,
      );

  factory Process.fromCsv(List<dynamic> row) {
    return Process(
      id: row[0].toString().trim(),
      arrivalTime: int.parse(row[1].toString().trim()),
      burstTime: int.parse(row[2].toString().trim()),
      memorySize: row.length > 3 ? int.tryParse(row[3].toString().trim()) ?? 64 : 64,
    );
  }

  factory Process.fromTxt(String line) {
    final parts = line.trim().split(RegExp(r'[\s,;|]+'));
    return Process(
      id: parts[0],
      arrivalTime: int.parse(parts[1]),
      burstTime: int.parse(parts[2]),
      memorySize: parts.length > 3 ? int.tryParse(parts[3]) ?? 64 : 64,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'arrivalTime': arrivalTime,
        'burstTime': burstTime,
        'memorySize': memorySize,
        'finishTime': finishTime,
        'turnaroundTime': tr,
        'waitingTime': te,
      };
}

