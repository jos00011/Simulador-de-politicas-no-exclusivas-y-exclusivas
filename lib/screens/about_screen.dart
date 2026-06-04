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
Este simulador fue desarrollado como herramienta educativa para visualizar y comparar cuatro políticas de planificación de procesos de CPU (FCFS, SPN, SRT y Round Robin), tres algoritmos de asignación de memoria dinámica (First Fit, Best Fit y Worst Fit) y los conceptos fundamentales de PAGINACIÓN con TLB.

Permite cargar procesos desde archivos externos (CSV o TXT), ejecutar simulaciones con diagramas de Gantt animados, visualizar mapas de memoria en tiempo real, traducir direcciones lógicas a físicas y obtener métricas de rendimiento detalladas.
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

                // ═══════════════════════════════════════════════════════════════
                // NUEVA SECCIÓN: PAGINACIÓN
                // ═══════════════════════════════════════════════════════════════
                _section('PAGINACIÓN Y MEMORIA VIRTUAL', null),
                _algo('¿Qué es la Paginación?', 'Esquema de memoria no contigua', '''
La paginación permite que el espacio de direcciones físicas de un proceso sea NO CONTIGUO. Esto elimina la fragmentación externa y la necesidad de compactación.

• La memoria física se divide en bloques de tamaño fijo llamados MARCOS (frames)
• La memoria lógica del proceso se divide en bloques del mismo tamaño llamados PÁGINAS (pages)
• La TABLA DE PÁGINAS mapea cada página lógica a un marco físico
• Bit de validez: indica si la página está cargada en memoria física''', AppTheme.rust),

                _algo('TLB — Translation Lookaside Buffer', 'Caché de traducciones', '''
La TLB es una memoria caché ultrarrápida dentro de la MMU que almacena traducciones recientes de página → marco.

FÓRMULA DEL TIEMPO EFECTIVO DE ACCESO (EAT):
• Con TLB hit:  EAT = TLB + MEM
• Con TLB miss: EAT = TLB + 2·MEM

EAT promedio = h·(TLB+MEM) + (1-h)·(TLB+2·MEM)

Donde:
• h = tasa de aciertos TLB (0-1)
• TLB = tiempo de acceso a TLB (nanosegundos)
• MEM = tiempo de acceso a memoria principal (nanosegundos)''', AppTheme.rust),

                _algo('Fallo de Página', 'Paginación por demanda', '''
Cuando una página no está en memoria física (bit de validez = 0), ocurre un FALLO DE PÁGINA. El sistema operativo debe traer la página desde el disco.

FÓRMULA COMPLETA CON FALLOS:
EAT = (1-p)·[h·(TLB+MEM) + (1-h)·(TLB+2·MEM)] + p·T_fallo

Donde:
• p = tasa de fallos de página
• T_fallo = tiempo de resolver un fallo (acceso a disco en milisegundos)

Ejemplo típico: TLB=10ns, MEM=80ns, T_fallo=20ms
• Con h=95% y sin fallos → EAT = 79.5 ns
• Con 1 fallo por millón → EAT = 200.1 ns''', AppTheme.rust),

                _algo('Algoritmos de Reemplazo de Páginas', 'FIFO · LRU · CLOCK', '''
Cuando la memoria está llena y ocurre un fallo de página, se debe elegir qué página reemplazar:

• FIFO (First In First Out): reemplaza la página más antigua. Simple pero puede sufrir "anomalía de Belady".

• LRU (Least Recently Used): reemplaza la página no usada por más tiempo. Óptimo en teoría pero costoso de implementar.

• CLOCK (Algoritmo del Reloj): aproximación eficiente a LRU usando un bit de referencia. Cada página tiene un bit que se activa al ser referenciada. El puntero del reloj avanza hasta encontrar una página con bit = 0.''', AppTheme.rust),

                _algo('Traducción de Direcciones', 'Lógica → Física', '''
La dirección lógica se descompone en dos partes:
• Número de página (P) = dirección ÷ tamaño_página
• Desplazamiento (d) = dirección % tamaño_página

Dirección física = (marco × tamaño_página) + desplazamiento

Ejemplo con tamaño de página = 2KB (2048 bytes):
Dirección lógica 3,500 → P = 1, d = 1,452
Si página 1 está en marco 4 → física = 4×2048 + 1452 = 9,644 bytes''', AppTheme.rust),

                _section('MÉTRICAS DE PLANIFICACIÓN', '''
• Tiempo de Retorno (TR): TR = T.Fin − T.Llegada
• Tiempo de Espera (TE): TE = TR − T.Servicio
• Uso de CPU: % del tiempo total con la CPU ejecutando procesos reales.
• Promedios: Se calculan automáticamente sobre todos los procesos.'''),

                _section('MÉTRICAS DE MEMORIA', '''
• Utilización: % de la memoria total asignada a procesos activos.
• Fragmentación Externa: Memoria libre total − mayor hueco libre.
  Representa la memoria libre que no puede usarse por estar dispersa.
• Compactación: Reorganiza los bloques para unir todos los huecos libres en uno contiguo.
• Tasa de aciertos TLB (TLB Hit Rate): hits / accesos totales.
• Tasa de fallos de página: page faults / accesos totales.'''),

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

                _section('PROBLEMAS RESUELTOS (TALLER)', '''
Problema 3: ¿Tasa de aciertos TLB mínima para EAT < 100 ns?
• Datos: TLB=10ns, MEM=80ns
• Fórmula: EAT = TLB + MEM·(2 - h) < 100
• Resultado: h > 87.5%

Problema 4: Con h=95%, TLB=10ns, MEM=80ns, T_fallo=20ms
• a) EAT sin fallos = 79.5 ns
• b) EAT con p=1/1,000,000 = 200.1 ns
• c) p máxima para EAT < 100 ns ≈ 1.025×10⁻⁶ (1 fallo cada 975,000 accesos)'''),

                _section('REFERENCIAS', '''
• Silberschatz, A., Galvin, P. B., Gagne, G. (2018). Operating System Concepts. 10th Ed. Wiley.
• Stallings, W. (2018). Operating Systems: Internals and Design Principles. 9th Ed. Pearson.
• Tanenbaum, A. S. (2015). Modern Operating Systems. 4th Ed. Pearson.
• Carretero, J., García, F., et al. (2001). Sistemas Operativos: una visión aplicada. 1ra Ed., McGraw Hill.'''),

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