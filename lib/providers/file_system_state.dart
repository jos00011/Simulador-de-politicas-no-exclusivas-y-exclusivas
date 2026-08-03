// lib/providers/file_system_state.dart

import 'package:flutter/foundation.dart';
import '../models/process.dart';
import '../models/file_block.dart';
import '../models/file_allocation_event.dart';
import '../models/file_allocation_result.dart';
import '../models/advanced_fs_result.dart';
import '../models/fat_table.dart';
import '../models/extent.dart';
import '../models/inode.dart';
import '../models/bitmap.dart';
import '../algorithms/file_system/file_system_facade.dart';
import '../core/app_constants.dart';

enum FsMethod {
  contiguous,
  linked,
  indexed,
  fat,
  extent,
  multilevel,
  bitmap,
}

extension FsMethodDisplay on FsMethod {
  String get displayName {
    switch (this) {
      case FsMethod.contiguous:
        return 'Contigua';
      case FsMethod.linked:
        return 'Enlazada';
      case FsMethod.indexed:
        return 'Indexada';
      case FsMethod.fat:
        return 'FAT';
      case FsMethod.extent:
        return 'Extensión';
      case FsMethod.multilevel:
        return 'Multinivel';
      case FsMethod.bitmap:
        return 'Bitmap';
    }
  }

  bool get isClassic => [FsMethod.contiguous, FsMethod.linked, FsMethod.indexed].contains(this);
  bool get isAdvanced => !isClassic;
}

class FileSystemState extends ChangeNotifier {
  // ─── CONFIGURACIÓN ──────────────────────────────────────────
  FsMethod _method = FsMethod.contiguous;
  int _totalDiskSize = AppConstants.defaultDiskSize;
  int _blockSize = AppConstants.defaultBlockSize;

  // ─── RESULTADOS ─────────────────────────────────────────────
  FileAllocationResult? _classicResult;
  AdvancedFsResult? _advancedResult;

  // ─── ESTADO DE ANIMACIÓN ────────────────────────────────────
  int _stepIndex = 0;
  bool _isAnimating = false;
  List<FileBlock> _currentBlocks = [];
  String? _errorMessage;

  // ─── GETTERS ──────────────────────────────────────────────────
  FsMethod get method => _method;
  int get totalDiskSize => _totalDiskSize;
  int get blockSize => _blockSize;
  int get stepIndex => _stepIndex;
  bool get isAnimating => _isAnimating;
  List<FileBlock> get currentBlocks => _currentBlocks;
  String? get errorMessage => _errorMessage;

  // ⭐ GETTER `result` - RETORNA EL RESULTADO SEGÚN EL MÉTODO
  dynamic get result => isClassic ? _classicResult : _advancedResult;

  FileAllocationResult? get classicResult => _classicResult;
  AdvancedFsResult? get advancedResult => _advancedResult;

  bool get isClassic => _method.isClassic;
  bool get isAdvanced => _method.isAdvanced;

  int get totalSteps {
    if (isClassic) return _classicResult?.events.length ?? 0;
    return _advancedResult?.events.length ?? 0;
  }

  FileAllocationEvent? get currentEvent {
    if (isClassic && _classicResult != null && _stepIndex > 0) {
      return _classicResult!.events[_stepIndex - 1];
    }
    if (isAdvanced && _advancedResult != null && _stepIndex > 0) {
      return _advancedResult!.events[_stepIndex - 1];
    }
    return null;
  }

  FATTable? get fatTable => _advancedResult?.fatTable;
  List<FileExtents>? get fileExtents => _advancedResult?.fileExtents;
  Map<String, Inode>? get inodes => _advancedResult?.inodes;
  Bitmap? get bitmap => _advancedResult?.bitmap;

  // ─── ACCIONES ──────────────────────────────────────────────────
  void setMethod(FsMethod method) {
    if (_method == method) return;
    _method = method;
    _resetState();
    notifyListeners();
  }

  void setTotalDiskSize(int size) {
    if (size <= 0) return;
    _totalDiskSize = size;
    notifyListeners();
  }

  void setBlockSize(int size) {
    if (size <= 0) return;
    _blockSize = size;
    notifyListeners();
  }

  void runSimulation(List<Process> processes) {
    if (processes.isEmpty) {
      _errorMessage = 'No hay procesos para asignar.';
      notifyListeners();
      return;
    }

    _errorMessage = null;
    _resetState();

    try {
      final result = FileSystemFacade.simulate(
        processes: processes,
        totalDiskSize: _totalDiskSize,
        blockSize: _blockSize,
        method: _method,
      );

      if (isClassic) {
        _classicResult = result as FileAllocationResult;
        _currentBlocks = _classicResult!.finalState;
      } else {
        _advancedResult = result as AdvancedFsResult;
        _currentBlocks = _advancedResult!.finalState;
      }
      notifyListeners();
      _animateSteps();
    } catch (e) {
      _errorMessage = 'Error en simulación: $e';
      notifyListeners();
    }
  }

  void goToStep(int step) {
    if (totalSteps == 0) return;
    _stepIndex = step.clamp(0, totalSteps);
    if (_stepIndex == 0) {
      _currentBlocks = List.generate(
        _totalDiskSize ~/ _blockSize,
        (i) => FileBlock(blockIndex: i),
      );
    } else {
      if (isClassic && _classicResult != null) {
        _currentBlocks = _classicResult!.events[_stepIndex - 1].snapshotAfter;
      } else if (isAdvanced && _advancedResult != null) {
        _currentBlocks = _advancedResult!.events[_stepIndex - 1].snapshotAfter;
      }
    }
    notifyListeners();
  }

  void reset() {
    _resetState();
    notifyListeners();
  }

  void _resetState() {
    _classicResult = null;
    _advancedResult = null;
    _stepIndex = 0;
    _currentBlocks = [];
    _errorMessage = null;
    _isAnimating = false;
  }

  Future<void> _animateSteps() async {
    _isAnimating = true;
    notifyListeners();
    for (int i = 1; i <= totalSteps; i++) {
      await Future.delayed(AppConstants.animationDuration);
      goToStep(i);
    }
    _isAnimating = false;
    notifyListeners();
  }

  Map<String, List<int>> getFileAllocations() {
    if (isClassic && _classicResult != null) {
      return _classicResult!.fileAllocations;
    }
    if (isAdvanced && _advancedResult != null) {
      return _advancedResult!.fileAllocations;
    }
    return {};
  }

  int getSuggestedDiskSize(List<Process> processes) {
    if (processes.isEmpty) return 1024;
    final totalMemory = processes.fold(0, (sum, p) => sum + p.memorySize);
    final suggested = (totalMemory * 1.2).ceil();
    return ((suggested + _blockSize - 1) ~/ _blockSize) * _blockSize;
  }

  void autoSetDiskSize(List<Process> processes) {
    final suggested = getSuggestedDiskSize(processes);
    if (_totalDiskSize != suggested) {
      _totalDiskSize = suggested;
      notifyListeners();
    }
  }

  Map<String, dynamic> getVisualizerData() {
    if (isAdvanced && _advancedResult != null) {
      return {
        'method': _method.displayName,
        'fatTable': _advancedResult!.fatTable,
        'fileExtents': _advancedResult!.fileExtents,
        'inodes': _advancedResult!.inodes,
        'bitmap': _advancedResult!.bitmap,
        'stats': _advancedResult!.getMethodStats(),
        'hint': _advancedResult!.visualizerHint,
      };
    }
    return {};
  }
}