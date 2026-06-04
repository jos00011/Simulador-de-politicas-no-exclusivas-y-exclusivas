// lib/screens/simulator_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../utils/app_theme.dart';
import '../utils/app_state.dart';
import '../utils/file_parser.dart';
import '../models/simulation_result.dart';
import '../models/process.dart';
import '../widgets/process_table.dart';
import '../widgets/add_process_dialog.dart';
import 'results_screen.dart';

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  State<SimulatorScreen> createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final _searchCtrl = TextEditingController();
  int _quantumValue = 2;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: _buildAppBar(context, state),
      body: Column(
        children: [
          _buildToolbar(context, state),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPolicySelector(state),
                  const SizedBox(height: 16),
                  _buildSearchBar(state),
                  const SizedBox(height: 8),
                  Expanded(
                    child: EditableProcessTable(
                      processes: state.filteredProcesses,
                      onAdd: () => _showAddDialog(context, state),
                      onRemove: (i) {
                        final actual = state.processes.indexOf(state.filteredProcesses[i]);
                        state.removeProcess(actual);
                      },
                    ),
                  ),
                  if (state.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    _buildError(state.errorMessage!),
                  ],
                ],
              ),
            ),
          ),
          _buildBottomBar(context, state),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState state) {
    return AppBar(
      backgroundColor: AppTheme.bgCard,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.sepia, size: 16),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(width: 3, height: 18, color: AppTheme.amber, margin: const EdgeInsets.only(right: 10)),
          const Text('SIMULADOR', style: TextStyle(color: AppTheme.amber, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 3)),
          const SizedBox(width: 8),
          Text('/ ${state.policy.displayName}', style: const TextStyle(color: AppTheme.sepia, fontSize: 12)),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.border),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          _ToolBtn(
            label: 'CARGAR ARCHIVO',
            icon: Icons.upload_file,
            onTap: () => _loadFile(context, state),
          ),
          const SizedBox(width: 8),
          _ToolBtn(
            label: 'AGREGAR',
            icon: Icons.add,
            onTap: () => _showAddDialog(context, state),
          ),
          const SizedBox(width: 8),
          _ToolBtn(
            label: 'LIMPIAR',
            icon: Icons.delete_sweep_outlined,
            onTap: state.processes.isEmpty ? null : () => _confirmClear(context, state),
          ),
          const Spacer(),
          Text(
            '${state.processes.length} proceso(s)  ·  ${_totalMem(state)} KB total',
            style: const TextStyle(color: AppTheme.sepia, fontSize: 11),
          ),
        ],
      ),
    );
  }

  String _totalMem(AppState state) {
    return '${state.processes.fold(0, (s, p) => s + p.memorySize)}';
  }

  Widget _buildPolicySelector(AppState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('POLÍTICA DE PLANIFICACIÓN', style: TextStyle(color: AppTheme.sepia, fontSize: 10, letterSpacing: 2)),
        const SizedBox(height: 8),
        Row(
          children: [
            _PolicyChip(
              label: 'FCFS',
              subtitle: 'No expulsiva',
              selected: state.policy == SchedulingPolicy.fcfs,
              onTap: () => state.setPolicy(SchedulingPolicy.fcfs),
            ),
            const SizedBox(width: 8),
            _PolicyChip(
              label: 'SPN',
              subtitle: 'No expulsiva',
              selected: state.policy == SchedulingPolicy.spn,
              onTap: () => state.setPolicy(SchedulingPolicy.spn),
            ),
            const SizedBox(width: 8),
            _PolicyChip(
              label: 'SRT',
              subtitle: 'Expulsiva',
              selected: state.policy == SchedulingPolicy.srt,
              onTap: () => state.setPolicy(SchedulingPolicy.srt),
            ),
            const SizedBox(width: 8),
            _PolicyChip(
              label: 'RR',
              subtitle: 'Expulsiva',
              selected: state.policy == SchedulingPolicy.rr,
              onTap: () => state.setPolicy(SchedulingPolicy.rr),
            ),
            if (state.policy == SchedulingPolicy.rr) ...[
              const SizedBox(width: 16),
              const Text('Quantum:', style: TextStyle(color: AppTheme.sepia, fontSize: 11)),
              const SizedBox(width: 8),
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: '$_quantumValue',
                  style: const TextStyle(color: AppTheme.cream, fontSize: 13),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null && n > 0) {
                      _quantumValue = n;
                      state.setQuantum(n);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        Text(
          state.policy.description,
          style: const TextStyle(color: AppTheme.amberDim, fontSize: 10, letterSpacing: 0.5),
        ),
      ],
    );
  }

  Widget _buildSearchBar(AppState state) {
    return TextField(
      controller: _searchCtrl,
      style: const TextStyle(color: AppTheme.cream, fontSize: 12),
      onChanged: state.setSearchQuery,
      decoration: InputDecoration(
        hintText: 'Buscar proceso por ID...',
        prefixIcon: const Icon(Icons.search, color: AppTheme.sepia, size: 16),
        suffixIcon: _searchCtrl.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, color: AppTheme.sepia, size: 14),
                onPressed: () {
                  _searchCtrl.clear();
                  state.setSearchQuery('');
                },
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
    );
  }

  Widget _buildError(String msg) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppTheme.rust.withValues(alpha: 0.1),
        border: Border.all(color: AppTheme.rust.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppTheme.rust, size: 14),
          const SizedBox(width: 8),
          Expanded(child: Text(msg, style: const TextStyle(color: AppTheme.rust, fontSize: 11))),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: Row(
        children: [
          Icon(
            state.processes.isEmpty ? Icons.warning_amber : Icons.check_circle_outline,
            color: state.processes.isEmpty ? AppTheme.rust : AppTheme.amber,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            state.processes.isEmpty
                ? 'Carga procesos para continuar'
                : '${state.processes.length} procesos listos para simular',
            style: TextStyle(
              color: state.processes.isEmpty ? AppTheme.rust : AppTheme.sepia,
              fontSize: 11,
            ),
          ),
          const Spacer(),
          SizedBox(
            height: 38,
            child: ElevatedButton.icon(
              onPressed: state.processes.isEmpty || state.isRunning ? null : () => _runAndNavigate(context, state),
              icon: state.isRunning
                  ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.bg))
                  : const Icon(Icons.play_arrow, size: 18),
              label: Text(state.isRunning ? 'SIMULANDO...' : 'EJECUTAR SIMULACIÓN'),
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: AppTheme.amberDim,
                disabledForegroundColor: AppTheme.bg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _runAndNavigate(BuildContext context, AppState state) async {
    await state.runSimulation();
    if (state.result != null && context.mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsScreen()));
    }
  }

  Future<void> _loadFile(BuildContext context, AppState state) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final ext = file.extension ?? 'txt';
    String content;

    if (file.bytes != null) {
      content = String.fromCharCodes(file.bytes!);
    } else if (file.path != null) {
      content = await File(file.path!).readAsString();
    } else {
      return;
    }

    final processes = FileParser.parse(content, ext);
    final error = FileParser.validate(processes);

    if (error != null) {
      state.setError(error);
    } else {
      state.setProcesses(processes);
    }
  }

  Future<void> _showAddDialog(BuildContext context, AppState state) async {
    final p = await showDialog<Process>(
      context: context,
      builder: (_) => AddProcessDialog(existing: state.processes),
    );
    if (p != null) state.addProcess(p);
  }

  Future<void> _confirmClear(BuildContext context, AppState state) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text('Limpiar procesos', style: TextStyle(color: AppTheme.cream)),
        content: const Text('¿Eliminar todos los procesos cargados?', style: TextStyle(color: AppTheme.sepia)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('LIMPIAR')),
        ],
      ),
    );
    if (ok == true) state.clearProcesses();
  }
}

class _ToolBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _ToolBtn({required this.label, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: enabled ? AppTheme.border : AppTheme.border.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: enabled ? AppTheme.amber : AppTheme.sepia.withValues(alpha: 0.4)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: enabled ? AppTheme.cream : AppTheme.sepia.withValues(alpha: 0.4),
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PolicyChip extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PolicyChip({required this.label, required this.subtitle, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.amber.withValues(alpha: 0.15) : AppTheme.bgElevated,
          border: Border.all(color: selected ? AppTheme.amber : AppTheme.border),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: selected ? AppTheme.amber : AppTheme.cream, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1)),
            Text(subtitle, style: TextStyle(color: selected ? AppTheme.amberDim : AppTheme.sepia, fontSize: 9)),
          ],
        ),
      ),
    );
  }
}

