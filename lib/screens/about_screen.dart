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
            const Text('DOCUMENTACIÓN',
                style: TextStyle(color: AppTheme.amber, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 3)),
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
Este simulador fue desarrollado como herramienta educativa para visualizar y comparar cuatro políticas de planificación de procesos de CPU (FCFS, SPN, SRT y Round Robin) y tres algoritmos de asignación de memoria dinámica (First Fit, Best Fit y Worst Fit).

Permite cargar procesos desde archivos externos (CSV o TXT), ejecutar simulaciones con diagramas de Gantt animados, visualizar mapas de memoria en tiempo real y obtener métricas de rendimiento detalladas.
'''),
                _section('ALGORITMOS DE PLANIFICACIÓN DE CPU', null),
                _algo('FCFS — First Come First Served', 'No expulsiva', '''
Los procesos son atendidos en el orden estricto de llegada.
No interrumpe al proceso en ejecución aunque llegue uno con menor ráfaga.
Simple de implementar pero puede causar el "efecto convoy".''', AppTheme.amber),
                _algo('SPN — Shortest Process Next', 'No expulsiva', '''
Selecciona el proceso con el menor tiempo de servicio CPU entre los disponibles.
Una vez iniciado, el proceso ejecuta hasta completarse.
Minimiza el tiempo promedio de espera. Requiere conocer tiempos a priori.''', AppTheme.amber),
                _algo('SRT — Shortest Remaining Time', 'Expulsiva', '''
Versión expulsiva de SPN. El proceso puede ser interrumpido si llega uno con menor tiempo restante.
Política óptima para minimizar tiempo de espera promedio.
Mayor overhead por cambios de contexto frecuentes.''', AppTheme.amberLight),
                _algo('Round Robin (RR)', 'Expulsiva con quantum', '''
Cada proceso recibe un quantum de tiempo de CPU. Al expirar, va al final de la cola.
Equitativo — ningún proceso sufre inanición indefinida.
El rendimiento depende fuertemente del valor del quantum elegido.''', AppTheme.amberLight),

                _section('ALGORITMOS DE ASIGNACIÓN DE MEMORIA', null),
                _algo('First Fit', 'Particiones Dinámicas', '''
Asigna el primer hueco libre suficientemente grande para el proceso.
Es el más rápido de ejecutar ya que no necesita recorrer toda la lista.
Tiende a fragmentar el inicio de la memoria, dejando huecos pequeños.''', AppTheme.rust),
                _algo('Best Fit', 'Particiones Dinámicas', '''
Busca en toda la lista el hueco que mejor se ajuste al tamaño pedido.
Minimiza el desperdicio inmediato, pero genera residuos muy pequeños que son difíciles de reutilizar.
Genera mayor fragmentación externa a largo plazo.''', AppTheme.rust),
                _algo('Worst Fit', 'Particiones Dinámicas', '''
Asigna el hueco más grande disponible, dejando el residuo más grande posible.
La idea es que el residuo sobrante sea lo suficientemente útil para otro proceso.
Puede causar que procesos grandes no encuentren hueco suficiente.''', AppTheme.rust),

                _section('MÉTRICAS DE PLANIFICACIÓN', '''
• Tiempo de Retorno (TR): TR = T.Fin − T.Llegada
• Tiempo de Espera (TE): TE = TR − T.Servicio
• Uso de CPU: % del tiempo total con la CPU ejecutando procesos reales.
• Promedios: Se calculan automáticamente sobre todos los procesos.'''),

                _section('MÉTRICAS DE MEMORIA', '''
• Utilización: % de la memoria total asignada a procesos activos.
• Fragmentación Externa: Memoria libre total − mayor hueco libre.
  Representa la memoria libre que no puede usarse por estar dispersa.
• Compactación: Reorganiza los bloques para unir todos los huecos libres en uno contiguo.'''),

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
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.borderAccent),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.code, color: AppTheme.amber, size: 14),
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
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(width: 3, height: 16, color: AppTheme.amber, margin: const EdgeInsets.only(right: 10)),
              Text(title, style: const TextStyle(color: AppTheme.amber, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 2)),
            ],
          ),
          if (content != null) ...[
            const SizedBox(height: 8),
            Text(content.trim(), style: const TextStyle(color: AppTheme.cream, fontSize: 12, height: 1.8)),
          ],
          const SizedBox(height: 8),
          const Divider(color: AppTheme.border),
        ],
      ),
    );
  }

  Widget _algo(String name, String type, String desc, Color accent) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
              Container(width: 3, height: 14, color: accent, margin: const EdgeInsets.only(right: 8)),
              Expanded(
                child: Text(name,
                    style: const TextStyle(color: AppTheme.cream, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  border: Border.all(color: accent.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(type, style: TextStyle(color: accent, fontSize: 8, letterSpacing: 0.8)),
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
