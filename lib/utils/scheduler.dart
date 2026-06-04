// lib/utils/scheduler.dart

import '../models/process.dart';
import '../models/gantt_entry.dart';
import '../models/simulation_result.dart';

class Scheduler {
  /// FCFS - First Come First Served (Non-preemptive)
  static SimulationResult fcfs(List<Process> input) {
    final processes = input.map((p) => p.copyWith()).toList();
    processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    int currentTime = 0;
    final gantt = <GanttEntry>[];

    for (final p in processes) {
      if (currentTime < p.arrivalTime) {
        gantt.add(GanttEntry(
          processId: 'IDLE',
          startTime: currentTime,
          endTime: p.arrivalTime,
          isIdle: true,
        ));
        currentTime = p.arrivalTime;
      }
      p.startTime = currentTime;
      gantt.add(GanttEntry(
        processId: p.id,
        startTime: currentTime,
        endTime: currentTime + p.burstTime,
      ));
      currentTime += p.burstTime;
      p.finishTime = currentTime;
    }

    return SimulationResult(
      policy: SchedulingPolicy.fcfs,
      processes: processes,
      ganttChart: gantt,
    );
  }

  /// SPN - Shortest Process Next (Non-preemptive)
  static SimulationResult spn(List<Process> input) {
    final processes = input.map((p) => p.copyWith()).toList();
    final done = <Process>[];
    final gantt = <GanttEntry>[];
    int currentTime = 0;
    final remaining = List<Process>.from(processes);

    while (remaining.isNotEmpty) {
      // Get all processes that have arrived
      final available = remaining
          .where((p) => p.arrivalTime <= currentTime)
          .toList();

      if (available.isEmpty) {
        // CPU idle
        final nextArrival = remaining.map((p) => p.arrivalTime).reduce((a, b) => a < b ? a : b);
        gantt.add(GanttEntry(
          processId: 'IDLE',
          startTime: currentTime,
          endTime: nextArrival,
          isIdle: true,
        ));
        currentTime = nextArrival;
        continue;
      }

      // Pick shortest burst time
      available.sort((a, b) {
        final cmp = a.burstTime.compareTo(b.burstTime);
        return cmp != 0 ? cmp : a.arrivalTime.compareTo(b.arrivalTime);
      });

      final selected = available.first;
      remaining.remove(selected);

      selected.startTime = currentTime;
      gantt.add(GanttEntry(
        processId: selected.id,
        startTime: currentTime,
        endTime: currentTime + selected.burstTime,
      ));
      currentTime += selected.burstTime;
      selected.finishTime = currentTime;
      done.add(selected);
    }

    return SimulationResult(
      policy: SchedulingPolicy.spn,
      processes: done,
      ganttChart: gantt,
    );
  }

  /// SRT - Shortest Remaining Time (Preemptive SPN)
  static SimulationResult srt(List<Process> input) {
    final processes = input.map((p) => p.copyWith()).toList();
    final gantt = <GanttEntry>[];
    int currentTime = 0;
    final remaining = List<Process>.from(processes);
    final done = <Process>[];

    String? lastPid;
    int lastStart = 0;

    while (remaining.isNotEmpty) {
      final available = remaining
          .where((p) => p.arrivalTime <= currentTime)
          .toList();

      if (available.isEmpty) {
        if (lastPid != null && lastPid != 'IDLE') {
          gantt.add(GanttEntry(processId: lastPid, startTime: lastStart, endTime: currentTime));
          lastPid = null;
        }
        final nextArrival = remaining.map((p) => p.arrivalTime).reduce((a, b) => a < b ? a : b);
        gantt.add(GanttEntry(processId: 'IDLE', startTime: currentTime, endTime: nextArrival, isIdle: true));
        lastStart = nextArrival;
        lastPid = 'IDLE';
        currentTime = nextArrival;
        continue;
      }

      available.sort((a, b) {
        final cmp = a.remainingTime.compareTo(b.remainingTime);
        return cmp != 0 ? cmp : a.arrivalTime.compareTo(b.arrivalTime);
      });

      final selected = available.first;

      if (selected.id != lastPid) {
        if (lastPid != null) {
          gantt.add(GanttEntry(processId: lastPid, startTime: lastStart, endTime: currentTime, isIdle: lastPid == 'IDLE'));
        }
        lastPid = selected.id;
        lastStart = currentTime;
      }

      if (selected.startTime == -1) selected.startTime = currentTime;
      selected.remainingTime--;
      currentTime++;

      if (selected.remainingTime == 0) {
        selected.finishTime = currentTime;
        remaining.remove(selected);
        done.add(selected);
        if (selected.id == lastPid) {
          gantt.add(GanttEntry(processId: lastPid!, startTime: lastStart, endTime: currentTime));
          lastPid = null;
        }
      }
    }

    if (lastPid != null) {
      gantt.add(GanttEntry(processId: lastPid, startTime: lastStart, endTime: currentTime, isIdle: lastPid == 'IDLE'));
    }

    // Merge consecutive same-process entries
    final merged = _mergeGantt(gantt);

    return SimulationResult(
      policy: SchedulingPolicy.srt,
      processes: done,
      ganttChart: merged,
    );
  }

  /// Round Robin (Preemptive with quantum)
  static SimulationResult roundRobin(List<Process> input, int quantum) {
    final processes = input.map((p) => p.copyWith()).toList();
    processes.sort((a, b) => a.arrivalTime.compareTo(b.arrivalTime));

    final gantt = <GanttEntry>[];
    final queue = <Process>[];
    int currentTime = 0;
    int index = 0; // next process to add from sorted list
    final done = <Process>[];

    // Add processes that arrive at time 0
    while (index < processes.length && processes[index].arrivalTime <= currentTime) {
      queue.add(processes[index++]);
    }

    while (queue.isNotEmpty || index < processes.length) {
      if (queue.isEmpty) {
        final nextTime = processes[index].arrivalTime;
        gantt.add(GanttEntry(processId: 'IDLE', startTime: currentTime, endTime: nextTime, isIdle: true));
        currentTime = nextTime;
        while (index < processes.length && processes[index].arrivalTime <= currentTime) {
          queue.add(processes[index++]);
        }
        continue;
      }

      final p = queue.removeAt(0);
      if (p.startTime == -1) p.startTime = currentTime;

      final execTime = p.remainingTime < quantum ? p.remainingTime : quantum;
      gantt.add(GanttEntry(processId: p.id, startTime: currentTime, endTime: currentTime + execTime));
      p.remainingTime -= execTime;
      currentTime += execTime;

      // Add newly arrived processes
      while (index < processes.length && processes[index].arrivalTime <= currentTime) {
        queue.add(processes[index++]);
      }

      if (p.remainingTime > 0) {
        queue.add(p);
      } else {
        p.finishTime = currentTime;
        done.add(p);
      }
    }

    return SimulationResult(
      policy: SchedulingPolicy.rr,
      processes: done,
      ganttChart: gantt,
      quantum: quantum,
    );
  }

  static List<GanttEntry> _mergeGantt(List<GanttEntry> entries) {
    if (entries.isEmpty) return entries;
    final merged = <GanttEntry>[];
    var current = entries.first;
    for (int i = 1; i < entries.length; i++) {
      final e = entries[i];
      if (e.processId == current.processId) {
        current = GanttEntry(
          processId: current.processId,
          startTime: current.startTime,
          endTime: e.endTime,
          isIdle: current.isIdle,
        );
      } else {
        merged.add(current);
        current = e;
      }
    }
    merged.add(current);
    return merged;
  }
}

