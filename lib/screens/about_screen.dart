// lib/screens/about_screen.dart

import 'package:flutter/material.dart';
import '../core/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('OBJETIVO', '''
Este simulador fue desarrollado como herramienta educativa para visualizar y comparar:
• Cuatro políticas de planificación de CPU (FCFS, SPN, SRT y Round Robin)
• Algoritmos de asignación de memoria dinámica (First Fit, Best Fit, Worst Fit y Buddy System)
• Asignación de archivos (Contigua, Enlazada, Indexada, FAT, Extensión, Multinivel y Bitmap)
'''),

                _section('ALGORITMOS DE PLANIFICACIÓN', null),
                _algo('FCFS', 'No expulsiva', 
                    'First Come First Served. Los procesos se atienden en orden de llegada.'),
                _algo('SPN', 'No expulsiva', 
                    'Shortest Process Next. Selecciona el proceso con menor tiempo de CPU.'),
                _algo('SRT', 'Expulsiva', 
                    'Shortest Remaining Time. Versión expulsiva de SPN.'),
                _algo('Round Robin', 'Expulsiva con quantum', 
                    'Cada proceso recibe un quantum de tiempo. Equitativo.'),

                _section('ALGORITMOS DE MEMORIA', null),
                _algo('First Fit', 'Particiones Dinámicas', 
                    'Asigna el primer hueco libre suficientemente grande.'),
                _algo('Best Fit', 'Particiones Dinámicas', 
                    'Busca el hueco que mejor se ajuste al tamaño pedido.'),
                _algo('Worst Fit', 'Particiones Dinámicas', 
                    'Asigna el hueco más grande disponible.'),
                _algo('Buddy System', 'Potencias de 2', 
                    'Divide bloques en potencias de 2. Fusiona gemelos al liberar.'),

                _section('ASIGNACIÓN DE ARCHIVOS', null),
                _algo('Contigua', 'Bloques contiguos', 
                    'Cada archivo ocupa bloques contiguos en disco.'),
                _algo('Enlazada', 'Punteros', 
                    'Cada bloque apunta al siguiente. No requiere contigüidad.'),
                _algo('Indexada', 'Bloque índice', 
                    'Un bloque índice contiene punteros a todos los bloques del archivo.'),
                _algo('FAT', 'Tabla centralizada', 
                    'File Allocation Table. Tabla centralizada de enlaces.'),
                _algo('Extensión', 'Bloques contiguos', 
                    'Cada archivo tiene una o más extensiones (inicio, longitud).'),
                _algo('Multinivel', 'Inodos', 
                    'Inodos con punteros directos e indirectos. Modelo UNIX.'),
                _algo('Bitmap', 'Mapa de bits', 
                    'Mapa de bits donde cada bit indica si un bloque está ocupado.'),

                _section('MÉTRICAS DE PLANIFICACIÓN', '''
• Tiempo de Retorno (TR): TR = T.Fin − T.Llegada
• Tiempo de Espera (TE): TE = TR − T.Servicio
• Uso de CPU: % del tiempo total con la CPU ejecutando procesos reales.
'''),

                _section('MÉTRICAS DE MEMORIA', '''
• Utilización: % de la memoria total asignada a procesos activos.
• Fragmentación Externa: Memoria libre total − mayor hueco libre.
• Fragmentación Interna: Espacio desperdiciado dentro de bloques asignados.
• Compactación: Reorganiza los bloques para unir todos los huecos libres.
'''),

                _section('FORMATO DE ARCHIVO', '''
CSV: ID,T.Llegada,T.Servicio,Memoria(KB)
TXT: ID T.Llegada T.Servicio Memoria(KB)
'''),

                _section('REFERENCIAS', '''
• Silberschatz, A., Galvin, P. B., Gagne, G. (2018). Operating System Concepts. 10th Ed. Wiley.
• Stallings, W. (2018). Operating Systems: Internals and Design Principles. 9th Ed. Pearson.
• Tanenbaum, A. S. (2015). Modern Operating Systems. 4th Ed. Pearson.
'''),

                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.code, color: AppTheme.neonCyan, size: 14),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Simulador de Sistemas Operativos v3.0',
                          style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
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
            'DOCUMENTACIÓN',
            style: TextStyle(
              color: AppTheme.neonCyan,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: AppTheme.borderDark),
      ),
    );
  }

  Widget _section(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                color: AppTheme.neonCyan,
                margin: const EdgeInsets.only(right: 10),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.neonCyan,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 8),
            Text(
              content.trim(),
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                height: 1.8,
              ),
            ),
          ],
          const SizedBox(height: 8),
          const Divider(color: AppTheme.borderDark),
        ],
      ),
    );
  }

  Widget _algo(String name, String type, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border.all(color: AppTheme.borderDark),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 14,
                color: AppTheme.neonCyan,
                margin: const EdgeInsets.only(right: 8),
              ),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.neonCyan.withValues(alpha: 0.12),
                  border: Border.all(color: AppTheme.neonCyan.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  type,
                  style: TextStyle(
                    color: AppTheme.neonCyan,
                    fontSize: 8,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            desc.trim(),
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 11,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}