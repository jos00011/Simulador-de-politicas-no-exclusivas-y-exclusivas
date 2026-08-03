// lib/providers/app_state.dart

import 'package:flutter/foundation.dart';
import '../models/process.dart';
import '../models/simulation_result.dart';
import '../algorithms/scheduler.dart';

class AppState extends ChangeNotifier {
  List<Process> _processes = [];
  SimulationResult? _result;
  SchedulingPolicy _policy = SchedulingPolicy.fcfs;
  int _quantum = 2;
  bool _isRunning = false;
  int _ganttStep = 0;
  String? _errorMessage;
  String _searchQuery = '';

  // ─── GETTERS ──────────────────────────────────────────────────
  List<Process> get processes => _processes;
  SimulationResult? get result => _result;
  SchedulingPolicy get policy => _policy;
  int get quantum => _quantum;
  bool get isRunning => _isRunning;
  int get ganttStep => _ganttStep;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;

  List<Process> get filteredProcesses {
    if (_searchQuery.isEmpty) return _processes;
    final q = _searchQuery.toLowerCase();
    return _processes.where((p) => p.id.toLowerCase().contains(q)).toList();
  }

  List<Process> get filteredResultProcesses {
    if (_result == null) return [];
    if (_searchQuery.isEmpty) return _result!.processes;
    final q = _searchQuery.toLowerCase();
    return _result!.processes.where((p) => p.id.toLowerCase().contains(q)).toList();
  }

  // ─── ACCIONES DE PROCESOS ────────────────────────────────────
  void setProcesses(List<Process> processes) {
    _processes = processes;
    _result = null;
    _ganttStep = 0;
    _errorMessage = null;
    notifyListeners();
  }

  void addProcess(Process p) {
    _processes.add(p);
    notifyListeners();
  }

  void removeProcess(int index) {
    _processes.removeAt(index);
    notifyListeners();
  }

  void updateProcess(int index, Process p) {
    _processes[index] = p;
    notifyListeners();
  }

  void clearProcesses() {
    _processes = [];
    _result = null;
    _ganttStep = 0;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── CONFIGURACIÓN ───────────────────────────────────────────
  void setPolicy(SchedulingPolicy policy) {
    _policy = policy;
    notifyListeners();
  }

  void setQuantum(int q) {
    if (q <= 0) return;
    _quantum = q;
    notifyListeners();
  }

  void setSearchQuery(String q) {
    _searchQuery = q;
    notifyListeners();
  }

  void setError(String? msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  // ─── SIMULACIÓN ──────────────────────────────────────────────
  Future<void> runSimulation() async {
    if (_processes.isEmpty) {
      _errorMessage = 'No hay procesos para simular.';
      notifyListeners();
      return;
    }

    _isRunning = true;
    _ganttStep = 0;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      SimulationResult res;
      switch (_policy) {
        case SchedulingPolicy.fcfs:
          res = Scheduler.fcfs(_processes);
          break;
        case SchedulingPolicy.spn:
          res = Scheduler.spn(_processes);
          break;
        case SchedulingPolicy.srt:
          res = Scheduler.srt(_processes);
          break;
        case SchedulingPolicy.rr:
          res = Scheduler.roundRobin(_processes, _quantum);
          break;
      }
      _result = res;
    } catch (e) {
      _errorMessage = 'Error al simular: $e';
    }

    _isRunning = false;
    notifyListeners();

    if (_result != null) {
      _animateGantt();
    }
  }

  Future<void> _animateGantt() async {
    _ganttStep = 0;
    final total = _result!.ganttChart.length;
    for (int i = 0; i <= total; i++) {
      _ganttStep = i;
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 120));
    }
  }

  void resetSimulation() {
    _result = null;
    _ganttStep = 0;
    _errorMessage = null;
    notifyListeners();
  }

  // ─── HELPERS ──────────────────────────────────────────────────
  int get totalMemory {
    return _processes.fold(0, (sum, p) => sum + p.memorySize);
  }

  int get processCount => _processes.length;

  bool get hasProcesses => _processes.isNotEmpty;

  bool get hasResults => _result != null;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}