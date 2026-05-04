// lib/widgets/add_process_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/process.dart';
import '../utils/app_theme.dart';

class AddProcessDialog extends StatefulWidget {
  final List<Process> existing;

  const AddProcessDialog({super.key, required this.existing});

  @override
  State<AddProcessDialog> createState() => _AddProcessDialogState();
}

class _AddProcessDialogState extends State<AddProcessDialog> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _arrivalCtrl = TextEditingController(text: '0');
  final _burstCtrl = TextEditingController(text: '1');
  final _memCtrl = TextEditingController(text: '64');

  @override
  void initState() {
    super.initState();
    // Suggest next process ID
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
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: SizedBox(
        width: 360,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(width: 3, height: 20, color: AppTheme.amber, margin: const EdgeInsets.only(right: 10)),
                    const Text('NUEVO PROCESO', style: TextStyle(color: AppTheme.amber, fontSize: 13, fontWeight: FontWeight.w700, letterSpacing: 2)),
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
                      child: const Text('Cancelar', style: TextStyle(color: AppTheme.sepia)),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _submit,
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

  Widget _field(String label, TextEditingController ctrl, {bool isId = false, bool isInt = false, int? min}) {
    return TextFormField(
      controller: ctrl,
      style: const TextStyle(color: AppTheme.cream, fontSize: 13),
      keyboardType: isInt ? TextInputType.number : TextInputType.text,
      inputFormatters: isInt ? [FilteringTextInputFormatter.digitsOnly] : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.sepia, fontSize: 12),
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
