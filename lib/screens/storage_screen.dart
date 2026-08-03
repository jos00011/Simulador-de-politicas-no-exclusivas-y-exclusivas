// lib/screens/storage_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_theme.dart';
import '../providers/app_state.dart';
import '../providers/file_system_state.dart';
import 'file_allocation_tab.dart';
import 'advanced_fs_tab.dart';
import '../widgets/common/neon_button.dart';

class StorageScreen extends StatefulWidget {
  const StorageScreen({super.key});

  @override
  State<StorageScreen> createState() => _StorageScreenState();
}

class _StorageScreenState extends State<StorageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _diskSizeCtrl = TextEditingController(text: '1024');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _diskSizeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final fsState = context.watch<FileSystemState>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (appState.processes.isNotEmpty) {
        fsState.autoSetDiskSize(appState.processes);
        if (_diskSizeCtrl.text != fsState.totalDiskSize.toString()) {
          _diskSizeCtrl.text = fsState.totalDiskSize.toString();
        }
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: _buildAppBar(context, fsState),
      body: Column(
        children: [
          _buildToolbar(context, appState, fsState),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                FileAllocationTab(),
                AdvancedFsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, FileSystemState fsState) {
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
            color: AppTheme.neonCyan,
            margin: const EdgeInsets.only(right: 10),
          ),
          const Text(
            'SISTEMA DE ARCHIVOS',
            style: TextStyle(
              color: AppTheme.neonCyan,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
          if (fsState.result != null) ...[
            const SizedBox(width: 8),
            Text(
              '/ ${fsState.method.displayName}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
          ],
        ],
      ),
      actions: [
        if (fsState.result != null)
          NeonButton(
            text: 'Reiniciar',
            icon: Icons.refresh,
            color: AppTheme.neonCyan,
            onPressed: fsState.reset,
          ),
        const SizedBox(width: 8),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.borderDark),
      ),
    );
  }

  Widget _buildToolbar(
    BuildContext context,
    AppState appState,
    FileSystemState fsState,
  ) {
    final classicMethods = [
      FsMethod.contiguous,
      FsMethod.linked,
      FsMethod.indexed,
    ];
    final advancedMethods = [
      FsMethod.fat,
      FsMethod.extent,
      FsMethod.multilevel,
      FsMethod.bitmap,
    ];

    final methodsToShow = _tabController.index == 0 ? classicMethods : advancedMethods;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: AppTheme.bgCard,
        border: Border(bottom: BorderSide(color: AppTheme.borderDark)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Selector de método
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'MÉTODO:',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 10),
              ...methodsToShow.map((method) => Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: _MethodChip(
                      label: method.displayName,
                      selected: fsState.method == method,
                      onTap: () => fsState.setMethod(method),
                    ),
                  )),
            ],
          ),
          // Tamaño disco
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'DISCO:',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 80,
                child: TextFormField(
                  controller: _diskSizeCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 12),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    suffixText: 'KB',
                    suffixStyle: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    isDense: true,
                  ),
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null && n > 0) fsState.setTotalDiskSize(n);
                  },
                ),
              ),
              if (appState.processes.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.neonCyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'auto: ${fsState.totalDiskSize} KB',
                    style: const TextStyle(
                      color: AppTheme.neonCyan,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          // Botón simular
          NeonButton(
            text: 'SIMULAR',
            icon: Icons.play_arrow,
            color: AppTheme.neonCyan,
            onPressed: appState.processes.isEmpty
                ? null
                : () => fsState.runSimulation(appState.processes),
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
        indicatorColor: AppTheme.neonCyan,
        indicatorWeight: 2,
        labelColor: AppTheme.neonCyan,
        unselectedLabelColor: AppTheme.textSecondary,
        labelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
        tabs: const [
          Tab(text: 'ASIGNACIÓN CLÁSICA'),
          Tab(text: 'ASIGNACIÓN AVANZADA'),
        ],
      ),
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MethodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.neonCyan.withValues(alpha: 0.15)
              : AppTheme.bgElevated,
          border: Border.all(
            color: selected ? AppTheme.neonCyan : AppTheme.borderDark,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppTheme.neonCyan : AppTheme.textPrimary,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}