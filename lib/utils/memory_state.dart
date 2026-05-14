// lib/utils/memory_state.dart

import 'package:flutter/foundation.dart';
import '../models/memory_block.dart';
import '../models/memory_event.dart';
import '../models/memory_result.dart';
import '../models/process.dart';
import 'memory_allocator.dart';

/// A workload entry: process + target memory location
class WorkloadEntry {
  final String processId;
  final int requestedSize; // KB
  final int? preferredAddress; // optional: where user wants it placed
  final String? notes;

  const WorkloadEntry({
    required this.processId,
    required this.requestedSize,
    this.preferredAddress,
    this.notes,
  });
}

class MemoryState extends ChangeNotifier {
  AllocationAlgorithm _algorithm = AllocationAlgorithm.firstFit;
  int _totalMemory = 512; // KB
  MemoryResult? _result;
  int _stepIndex = 0;
  bool _isAnimating = false;
  List<MemoryBlock> _currentBlocks = [];

  // ── Workload ─────────────────────────────────────────────────
  /// Custom workload entries typed by the user; null = use app processes
  List<WorkloadEntry>? _customWorkload;

  /// If true, show the RAM visualization overlay
  bool _showRam = false;

  // ── Getters ──────────────────────────────────────────────────
  AllocationAlgorithm get algorithm => _algorithm;
  int get totalMemory => _totalMemory;
  MemoryResult? get result => _result;
  int get stepIndex => _stepIndex;
  bool get isAnimating => _isAnimating;
  List<MemoryBlock> get currentBlocks => _currentBlocks;
  List<WorkloadEntry>? get customWorkload => _customWorkload;
  bool get showRam => _showRam;

  MemoryEvent? get currentEvent =>
      _result != null && _stepIndex > 0 && _stepIndex <= _result!.events.length
          ? _result!.events[_stepIndex - 1]
          : null;

  int get totalSteps => _result?.events.length ?? 0;

  bool get isBuddySystem => _algorithm == AllocationAlgorithm.buddySystem;

  // ── Algorithm ────────────────────────────────────────────────
  void setAlgorithm(AllocationAlgorithm alg) {
    _algorithm = alg;
    notifyListeners();
  }

  void setTotalMemory(int kb) {
    _totalMemory = kb;
    notifyListeners();
  }

  void toggleRam() {
    _showRam = !_showRam;
    notifyListeners();
  }

  // ── Workload management ───────────────────────────────────────
  void setCustomWorkload(List<WorkloadEntry> entries) {
    _customWorkload = entries;
    notifyListeners();
  }

  void clearCustomWorkload() {
    _customWorkload = null;
    notifyListeners();
  }

  void addWorkloadEntry(WorkloadEntry e) {
    _customWorkload ??= [];
    _customWorkload!.add(e);
    notifyListeners();
  }

  void removeWorkloadEntry(int index) {
    if (_customWorkload == null) return;
    _customWorkload!.removeAt(index);
    notifyListeners();
  }

  /// Build a Process list from workload entries (for the allocator)
  List<Process> _workloadToProcesses(List<WorkloadEntry> entries) {
    return entries
        .map((e) => Process(
              id: e.processId,
              arrivalTime: 0,
              burstTime: 1,
              memorySize: e.requestedSize,
            ))
        .toList();
  }

  // ── Simulation ───────────────────────────────────────────────
  void runSimulation(List<Process> appProcesses) {
    final processes = _customWorkload != null && _customWorkload!.isNotEmpty
        ? _workloadToProcesses(_customWorkload!)
        : appProcesses;

    _result = MemoryAllocator.simulate(
      processes: processes,
      totalMemory: _totalMemory,
      algorithm: _algorithm,
    );
    _stepIndex = 0;
    _currentBlocks = [
      MemoryBlock(
        id: 'free_init',
        startAddress: 0,
        size: _result!.totalMemory, // may differ if buddy snapped up
        status: BlockStatus.free,
      )
    ];
    notifyListeners();
    _animateSteps();
  }

  Future<void> _animateSteps() async {
    _isAnimating = true;
    notifyListeners();
    for (int i = 1; i <= totalSteps; i++) {
      await Future.delayed(const Duration(milliseconds: 450));
      _stepIndex = i;
      _currentBlocks = _result!.events[i - 1].snapshotAfter;
      notifyListeners();
    }
    _isAnimating = false;
    notifyListeners();
  }

  void goToStep(int step) {
    if (_result == null) return;
    _stepIndex = step.clamp(0, totalSteps);
    if (_stepIndex == 0) {
      _currentBlocks = [
        MemoryBlock(
          id: 'free_init',
          startAddress: 0,
          size: _result!.totalMemory,
          status: BlockStatus.free,
        )
      ];
    } else {
      _currentBlocks = _result!.events[_stepIndex - 1].snapshotAfter;
    }
    notifyListeners();
  }

  void compactMemory() {
    if (_result == null) return;
    if (isBuddySystem) {
      // For buddy: merge free blocks instead
      _currentBlocks =
          MemoryAllocator.buddyDeallocate(_currentBlocks, '', _result!.totalMemory);
    } else {
      _currentBlocks =
          MemoryAllocator.compact(_currentBlocks, _result!.totalMemory);
    }
    notifyListeners();
  }

  void reset() {
    _result = null;
    _stepIndex = 0;
    _currentBlocks = [];
    notifyListeners();
  }
}