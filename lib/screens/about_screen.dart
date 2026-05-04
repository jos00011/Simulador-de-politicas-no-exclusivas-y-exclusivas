// lib/screens/about_screen.dart

import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: AppTheme.bgCard,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppTheme.sepia, size: 16),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(width: 3, height: 18, color: AppTheme.amber, margin: const EdgeInsets.only(right: 10)),
            const Text('DOCUMENTACIÓN', style: TextStyle(color: AppTheme.amber, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 3)),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SizedBox(
            width: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _section('OBJETIVO', '''
Este simulador fue desarrollado como herramienta educativa para visualizar y comparar cuatro políticas de planificación de procesos de CPU: FCFS, SPN, SRT y Round Robin.

Permite cargar procesos desde archivos externos (CSV o TXT), ejecutar la simulación paso a paso con un diagrama de Gantt animado, y obtener métricas de rendimiento detalladas.
'''),
                _section('ALGORITMOS IMPLEMENTADOS', null),
                _algo('FCFS — First Come First Served', 'No expulsiva', '''
Los procesos son atendidos en el orden estricto de llegada. 
El proceso que llega primero es el primero en ejecutarse.
No interrumpe al proceso en ejecución aunque llegue uno con menor ráfaga.
Simple de implementar pero puede causar el "efecto convoy".'''),
                _algo('SPN — Shortest Process Next', 'No expulsiva', '''
Selecciona el proceso con el menor tiempo de servicio CPU entre los disponibles.
Una vez iniciado, el proceso ejecuta hasta completarse (no expulsivo).
Minimiza el tiempo promedio de espera.
Requiere conocer los tiempos de servicio a priori.'''),
                _algo('SRT — Shortest Remaining Time', 'Expulsiva', '''
Versión expulsiva de SPN. El proceso en ejecución puede ser interrumpido
si llega un proceso con menor tiempo restante de CPU.
Política óptima para minimizar tiempo de espera promedio.
Mayor overhead por cambios de contexto frecuentes.'''),
                _algo('Round Robin (RR)', 'Expulsiva con quantum', '''
Cada proceso recibe un quantum de tiempo de CPU.
Al expirar el quantum, el proceso es desalojado y enviado al final de la cola.
Equitativo — ningún proceso sufre inanición.
El rendimiento depende fuertemente del valor del quantum elegido.'''),
                _section('MÉTRICAS CALCULADAS', '''
• Tiempo de Retorno (TR): TR = T.Fin − T.Llegada
  Tiempo total desde que el proceso llega hasta que termina.

• Tiempo de Espera (TE): TE = TR − T.Servicio
  Tiempo que el proceso pasa esperando en la cola sin ejecutarse.

• Promedios: Se calculan automáticamente sobre todos los procesos.

• Uso de CPU: Porcentaje del tiempo total en que la CPU ejecuta procesos.

• Memoria Total: Suma del espacio de memoria de todos los procesos cargados.'''),
                _section('FORMATO DE ARCHIVO', '''
CSV (comma-separated values):
  ID,T.Llegada,T.Servicio,Memoria(KB)
  A,0,9,128
  B,3,5,64

TXT (separado por espacios/tabs):
  # Comentarios con #
  A 0 9 128
  B 3 5 64

Campos requeridos: ID, Tiempo de Llegada, Tiempo de Servicio
Campo opcional: Memoria en KB (por defecto 64 KB)'''),
                _section('REFERENCIAS', '''
• Stallings, W. (2018). Operating Systems: Internals and Design Principles. 9th Ed. Pearson.
• Silberschatz, A., Galvin, P. B., Gagne, G. (2018). Operating System Concepts. 10th Ed. Wiley.
• Tanenbaum, A. S. (2015). Modern Operating Systems. 4th Ed. Pearson.'''),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderAccent),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.code, color: AppTheme.amber, size: 16),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Código fuente disponible en GitHub — ver anexo del informe',
                          style: TextStyle(color: AppTheme.sepia, fontSize: 11),
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

  Widget _section(String title, String? content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 16, color: AppTheme.amber, margin: const EdgeInsets.only(right: 10)),
              Text(title, style: const TextStyle(color: AppTheme.amber, fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 2)),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 10),
            Text(content.trim(), style: const TextStyle(color: AppTheme.cream, fontSize: 12, height: 1.8)),
          ],
          const SizedBox(height: 8),
          const Divider(color: AppTheme.border),
        ],
      ),
    );
  }

  Widget _algo(String name, String type, String desc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.bgCard,
        border: Border.all(color: AppTheme.border),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: const TextStyle(color: AppTheme.cream, fontSize: 12, fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.amber.withValues(alpha: 0.15),
                  border: Border.all(color: AppTheme.amberDim),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(type, style: const TextStyle(color: AppTheme.amberLight, fontSize: 9, letterSpacing: 1)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(desc.trim(), style: const TextStyle(color: AppTheme.sepia, fontSize: 11, height: 1.7)),
        ],
      ),
    );
  }
}
