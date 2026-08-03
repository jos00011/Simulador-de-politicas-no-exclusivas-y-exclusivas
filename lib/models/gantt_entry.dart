// lib/models/gantt_entry.dart

class GanttEntry {
  final String processId;
  final int startTime;
  final int endTime;
  final bool isIdle;

  GanttEntry({
    required this.processId,
    required this.startTime,
    required this.endTime,
    this.isIdle = false,
  });

  int get duration => endTime - startTime;
}