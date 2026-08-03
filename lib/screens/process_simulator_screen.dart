// lib/screens/process_simulator_screen.dart
// Pantalla de Simulación de Procesos con pestañas (Planificación CPU + Memoria)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../core/app_theme.dart';
import '../providers/app_state.dart';
import '../utils/file_parser.dart';
import '../models/process.dart';
import '../models/simulation_result.dart';
import 'scheduling_tab.dart';
import 'memory_tab.dart';
import '../widgets/common/neon_button.dart';

class ProcessSimulatorScreen extends StatefulWidget {
  const ProcessSimulatorScreen({super.key});

  @override
  State<ProcessSimulatorScreen> createState() => _ProcessSimulatorScreenState();
}

class _ProcessSimulatorScreenState extends State<ProcessSimulatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: _buildAppBar(context, appState),
      body: Column(
        children: [
          _buildToolbar(context, appState),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                SchedulingTab(),
                MemoryTab(),
              ],
            ),
          ),
          _buildBottomBar(context, appState),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppState state) {
    return AppBar(
      backgroundColor: AppTheme.bgCard,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: AppTheme.textSecondary, size: 16),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            color: AppTheme.neonAmber,
            margin: const EdgeInsets.only(right: 10),
          ),
          const Text(
            'SIMULADOR DE PROCESOS',
            style: TextStyle(
              color: AppTheme.neonAmber,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          const SizedBox(width: 8),
          if (state.result != null)
            Text(
              '/ ${state.policy.displayName}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
        ],
      ),
      actions: [
        if (state.result != null)
          NeonButton(
            text: 'Reiniciar',
            icon: Icons.refresh,
            color: AppTheme.neonAmber,
            onPressed: () {
              state.resetSimulation();
              _tabController.animateTo(0);
            },
          ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.borderDark),
      ),
    );
  }

  Widget _buildToolbar(BuildContext context, AppState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
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
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.neonAmber,
        indicatorWeight: 2,
        labelColor: AppTheme.neonAmber,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        tabs: const [
          Tab(text: 'PLANIFICACIÓN CPU'),
          Tab(text: 'MEMORIA DINÁMICA'),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AppState state) {
    final isRunning = state.isRunning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(top: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Row(
        children: [
          Icon(
            state.processes.isEmpty ? Icons.warning_amber : Icons.check_circle_outline,
            color: state.processes.isEmpty ? AppTheme.neonRed : AppTheme.neonGreen,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            state.processes.isEmpty
                ? 'Carga procesos para continuar'
                : '${state.processes.length} procesos listos para simular',
            style: TextStyle(
              color: state.processes.isEmpty ? AppTheme.neonRed : AppTheme.textSecondary,
              fontSize: 11,
            ),
          ),
          const Spacer(),
          if (state.result != null)
            NeonButton(
              text: 'VER RESULTADOS',
              icon: Icons.analytics,
              color: AppTheme.neonAmber,
              onPressed: () {
                _tabController.animateTo(0);
              },
            ),
          const SizedBox(width: 8),
          NeonButton(
            text: isRunning ? 'SIMULANDO...' : 'EJECUTAR SIMULACIÓN',
            icon: isRunning ? null : Icons.play_arrow,
            color: AppTheme.neonAmber,
            onPressed: state.processes.isEmpty || isRunning
                ? null
                : () async {
                    await state.runSimulation();
                    if (state.result != null && mounted) {
                      _tabController.animateTo(0);
                    }
                  },
            isLoading: isRunning,
          ),
        ],
      ),
    );
  }

  String _totalMem(AppState state) {
    return '${state.processes.fold(0, (s, p) => s + p.memorySize)}';
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

    if (!mounted) return;

    if (error != null) {
      state.setError(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error', style: const TextStyle(color: AppTheme.neonRed)),
          backgroundColor: AppTheme.bgCard,
        ),
      );
    } else {
      state.setProcesses(processes);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${processes.length} procesos cargados correctamente.'),
          backgroundColor: AppTheme.bgCard,
        ),
      );
    }
  }

  Future<void> _showAddDialog(BuildContext context, AppState state) async {
    final p = await showDialog<Process>(
      context: context,
      builder: (_) => _AddProcessDialog(existing: state.processes),
    );
    if (p != null) state.addProcess(p);
  }

  Future<void> _confirmClear(BuildContext context, AppState state) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: const Text(
          'Limpiar procesos',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: const Text(
          '¿Eliminar todos los procesos cargados?',
          style: TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.neonRed,
            ),
            child: const Text('LIMPIAR'),
          ),
        ],
      ),
    );
    if (ok == true) state.clearProcesses();
  }
}

// ─── TOOL BUTTON ───────────────────────────────────────────────────
class _ToolBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  const _ToolBtn({
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: enabled ? AppTheme.borderDark : AppTheme.borderDark.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: enabled ? AppTheme.neonAmber : AppTheme.textDim,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: enabled ? AppTheme.textPrimary : AppTheme.textDim,
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

// ─── ADD PROCESS DIALOG ──────────────────────────────────────────
class _AddProcessDialog extends StatefulWidget {
  final List<Process> existing;

  const _AddProcessDialog({required this.existing});

  @override
  State<_AddProcessDialog> createState() => _AddProcessDialogState();
}

class _AddProcessDialogState extends State<_AddProcessDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _arrivalCtrl = TextEditingController(text: '0');
  final _burstCtrl = TextEditingController(text: '1');
  final _memCtrl = TextEditingController(text: '64');

  @override
  void initState() {
    super.initState();
    final n = widget.existing.length;
    _idCtrl.text = String.fromCharCode(65 + (n % 26)) + (n >= 26 ? '${n ~/ 26}' : '');
  }

  @override
  void dispose() {
    _idCtrl.dispose();
    _arrivalCtrl.dispose();
    _burstCtrl.dispose();
    _memCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.bgCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.borderDark),
      ),
      child: SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 3,
                      height: 20,
                      color: AppTheme.neonAmber,
                      margin: const EdgeInsets.only(right: 10),
                    ),
                    const Text(
                      'NUEVO PROCESO',
                      style: TextStyle(
                        color: AppTheme.neonAmber,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _field('Identificador', _idCtrl, isId: true),
                const SizedBox(height: 12),
                _field('Tiempo de Llegada', _arrivalCtrl, isInt: true),
                const SizedBox(height: 12),
                _field('Tiempo de Servicio (CPU)', _burstCtrl, isInt: true, min: 1),
                const SizedBox(height: 12),
                _field('Memoria (KB)', _memCtrl, isInt: true, min: 1),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar', style: TextStyle(color: AppTheme.textSecondary)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.neonAmber,
                      ),
                      child: const Text('AGREGAR'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {
    bool isId = false,
    bool isInt = false,
    int? min,
  }) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 13),
      keyboardType: isInt ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
      validator: (val) {
        if (val == null || val.trim().isEmpty) return 'Campo requerido';
        if (isId) {
          if (widget.existing.any((p) => p.id == val.trim())) return 'ID duplicado';
        }
        if (isInt) {
          final n = int.tryParse(val.trim());
          if (n == null) return 'Número inválido';
          if (min != null && n < min) return 'Mínimo $min';
        }
        return null;
      },
    );
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        Process(
          id: _idCtrl.text.trim(),
          arrivalTime: int.parse(_arrivalCtrl.text.trim()),
          burstTime: int.parse(_burstCtrl.text.trim()),
          memorySize: int.parse(_memCtrl.text.trim()),
        ),
      );
    }
  }
}