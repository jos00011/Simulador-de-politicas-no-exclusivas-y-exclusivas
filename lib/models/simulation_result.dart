// lib/models/simulation_result.dart

import 'process.dart';
import 'gantt_entry.dart';

enum SchedulingPolicy { fcfs, spn, srt, rr }

extension PolicyName on SchedulingPolicy {
  String get displayName {
    switch (this) {
      case SchedulingPolicy.fcfs:
        return 'FCFS';
      case SchedulingPolicy.spn:
        return 'SPN';
      case SchedulingPolicy.srt:
        return 'SRT';
      case SchedulingPolicy.rr:
        return 'Round Robin';
    }
  }

  String get description {
    switch (this) {
      case SchedulingPolicy.fcfs:
        return 'First Come First Served — No expulsiva';
      case SchedulingPolicy.spn:
        return 'Shortest Process Next — No expulsiva';
      case SchedulingPolicy.srt:
        return 'Shortest Remaining Time — Expulsiva';
      case SchedulingPolicy.rr:
        return 'Round Robin — Expulsiva con quantum';
    }
  }
}

class SimulationResult {
  final SchedulingPolicy policy;
  final List<Process> processes;
  final List<GanttEntry> ganttChart;
  final int quantum; // only for RR

  SimulationResult({
    required this.policy,
    required this.processes,
    required this.ganttChart,
    this.quantum = 1,
  });

  double get avgWaitingTime {
    if (processes.isEmpty) return 0;
    return processes.map((p) => p.te).reduce((a, b) => a + b) / processes.length;
  }

  double get avgTurnaroundTime {
    if (processes.isEmpty) return 0;
    return processes.map((p) => p.tr).reduce((a, b) => a + b) / processes.length;
  }

  int get totalMemory => processes.fold(0, (sum, p) => sum + p.memorySize);

  int get totalTime {
    if (ganttChart.isEmpty) return 0;
    return ganttChart.last.endTime;
  }

  double get cpuUtilization {
    if (totalTime == 0) return 0;
    final busyTime = ganttChart.where((e) => !e.isIdle).fold(0, (s, e) => s + e.duration);
    return busyTime / totalTime * 100;
  }
}

