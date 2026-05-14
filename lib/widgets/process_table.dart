// lib/widgets/process_table.dart

import 'package:flutter/material.dart';
import '../models/process.dart';
import '../models/simulation_result.dart';
import '../utils/app_theme.dart';

class ProcessResultTable extends StatelessWidget {
  final List<Process> processes;
  final bool showResults;

  const ProcessResultTable({
    super.key,
    required this.processes,
    this.showResults = false,
  });

  @override
  Widget build(BuildContext context) {
    if (processes.isEmpty) {
      return const Center(
        child: Text('Sin resultados', style: TextStyle(color: AppTheme.sepia)),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppTheme.border),
          Expanded(
            child: ListView.separated(
              itemCount: processes.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.border),
              itemBuilder: (ctx, i) => _buildRow(processes[i], i),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.bgElevated,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _hCell('ID', flex: 2),
          _hCell('T.Llegada', flex: 2),
          _hCell('T.Servicio', flex: 2),
          _hCell('Memoria', flex: 2),
          if (showResults) ...[
            _hCell('T.Fin', flex: 2),
            _hCell('T.Retorno', flex: 2),
            _hCell('T.Espera', flex: 2),
          ],
        ],
      ),
    );
  }

  Widget _hCell(String text, {int flex = 2}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.amber,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildRow(Process p, int index) {
    final color = AppTheme.processColor(p.id);
    final isEven = index.isEven;

    return Container(
      color: isEven ? AppTheme.bgCard : AppTheme.bgElevated.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Container(width: 3, height: 14, color: color, margin: const EdgeInsets.only(right: 6)),
                Text(p.id, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ),
          _dCell('${p.arrivalTime}'),
          _dCell('${p.burstTime}'),
          _dCell('${p.memorySize} KB'),
          if (showResults) ...[
            _dCell(p.finishTime >= 0 ? '${p.finishTime}' : '—'),
            _dCell(p.finishTime >= 0 ? '${p.tr}' : '—', highlight: true),
            _dCell(p.finishTime >= 0 ? '${p.te}' : '—', highlight: true),
          ],
        ],
      ),
    );
  }

  Widget _dCell(String text, {bool highlight = false}) {
    return Expanded(
      flex: 2,
      child: Text(
        text,
        style: TextStyle(
          color: highlight ? AppTheme.amberLight : AppTheme.cream,
          fontSize: 12,
        ),
      ),
    );
  }
}

class EditableProcessTable extends StatelessWidget {
  final List<Process> processes;
  final VoidCallback onAdd;
  final Function(int) onRemove;

  const EditableProcessTable({
    super.key,
    required this.processes,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1, color: AppTheme.border),
          Expanded(
            child: processes.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_outlined, color: AppTheme.sepia, size: 32),
                        SizedBox(height: 8),
                        Text('Sin procesos. Agrega uno o carga un archivo.',
                            style: TextStyle(color: AppTheme.sepia, fontSize: 12)),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: processes.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.border),
                    itemBuilder: (ctx, i) => _buildRow(processes[i], i),
                  ),
          ),
          const Divider(height: 1, color: AppTheme.border),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: AppTheme.bgElevated,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _hCell('ID'),
          _hCell('T.Llegada'),
          _hCell('T.Servicio (CPU)'),
          _hCell('Memoria (KB)'),
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  Widget _hCell(String text) {
    return Expanded(
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.amber,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildRow(Process p, int index) {
    final color = AppTheme.processColor(p.id);
    return Container(
      color: index.isEven ? AppTheme.bgCard : AppTheme.bgElevated.withValues(alpha: 0.3),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(width: 3, height: 14, color: color, margin: const EdgeInsets.only(right: 6)),
                Text(p.id, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
              ],
            ),
          ),
          Expanded(child: Text('${p.arrivalTime}', style: const TextStyle(color: AppTheme.cream, fontSize: 12))),
          Expanded(child: Text('${p.burstTime}', style: const TextStyle(color: AppTheme.cream, fontSize: 12))),
          Expanded(child: Text('${p.memorySize} KB', style: const TextStyle(color: AppTheme.cream, fontSize: 12))),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.rust, size: 16),
            onPressed: () => onRemove(index),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 30),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      color: AppTheme.bgElevated,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Row(
        children: [
          Text('${processes.length} proceso(s) cargados', style: const TextStyle(color: AppTheme.sepia, fontSize: 10)),
          const Spacer(),
          TextButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 14, color: AppTheme.amber),
            label: const Text('Agregar proceso', style: TextStyle(color: AppTheme.amber, fontSize: 11)),
          ),
        ],
      ),
    );
  }
}
