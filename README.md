# Simulador de Sistemas Operativos

Simulador educativo desarrollado en Flutter/Dart que permite visualizar, comparar y analizar de forma interactiva los principales algoritmos y estructuras de datos empleados por un sistema operativo: planificación de CPU, gestión de memoria principal, asignación de archivos en disco y reemplazo de páginas.

## Descripción

Este proyecto traduce conceptos abstractos de la asignatura de Sistemas Operativos —tiempos de espera, fragmentación, tasas de acierto— en representaciones visuales animadas y comparables entre sí. El usuario puede definir una carga de trabajo (procesos, tamaño de memoria, secuencias de referencia a página) y observar cómo distintas políticas responden ante los mismos datos de entrada, obteniendo métricas cuantitativas que permiten argumentar con evidencia por qué un algoritmo resulta preferible a otro en un escenario determinado.

El simulador cubre diecisiete algoritmos distintos, agrupados en cuatro módulos principales.

## Características principales

- Visualizaciones interactivas y animadas: diagrama de Gantt, mapa de memoria en tiempo real, mapa de disco tipo cuadrícula y simulación de marcos de página.
- Comparación directa de la misma carga de trabajo bajo distintas políticas o algoritmos.
- Entrada de datos manual o mediante archivos CSV/TXT.
- Cálculo de métricas de rendimiento: tiempo de espera, tiempo de retorno, utilización de CPU, fragmentación interna y externa, tasa de aciertos.
- Interfaz con identidad visual propia («cyber-neón») basada en efectos de glassmorphism.
- Arquitectura en capas con separación estricta entre lógica algorítmica y presentación.
- Soporte multiplataforma: Windows, Android, iOS y Web desde una única base de código.

## Módulos y algoritmos implementados

### Planificación de CPU
- FCFS (First Come First Served)
- SPN (Shortest Process Next)
- SRT (Shortest Remaining Time)
- Round Robin (RR)

### Gestión de memoria
- First Fit
- Best Fit
- Worst Fit
- Buddy System
- Compactación de memoria

### Asignación de archivos

**Métodos clásicos**
- Asignación contigua
- Asignación enlazada
- Asignación indexada

**Métodos avanzados**
- FAT (File Allocation Table)
- Asignación por extensión (extents)
- Inodos multinivel
- Bitmap de bloques libres

### Paginación y TLB
- FIFO
- LRU (Least Recently Used)
- Clock (segunda oportunidad)

## Tecnologías utilizadas

| Componente | Tecnología |
|---|---|
| Framework | Flutter 3.x |
| Lenguaje | Dart 3.x (null-safety) |
| Gestión de estado | Provider (sobre ChangeNotifier) |
| Plataformas objetivo | Windows, Android, iOS, Web |
| Herramientas de apoyo | Dart Analyzer, Flutter DevTools, Git |

## Arquitectura

El proyecto sigue una organización en capas, donde cada capa depende únicamente de la inmediatamente inferior:

1. **Interfaz de usuario** — Home Screen, Process Simulator, Storage, About
2. **Widgets comunes** — NeonButton, GlassCard, GlowingProgress, Particles
3. **Providers (estado)** — AppState, MemoryState, FileSystemState
4. **Algoritmos** — Scheduler, MemoryAllocator, FileAllocator, PageReplacement
5. **Modelos** — Process, MemoryBlock, FileBlock, Inode, FAT, Bitmap

Ningún algoritmo depende de la interfaz gráfica, lo que permite probarlos de forma aislada. La comunicación entre capas se resuelve mediante el patrón Provider: cada estado (`AppState`, `MemoryState`, `FileSystemState`) gestiona un módulo independiente para evitar reconstrucciones innecesarias de widgets.

## Estructura del proyecto

**lib/**
- `main.dart`

**core/**
- `app_theme.dart`
- `app_constants.dart`
- `extensions.dart`

**models/**
- `process.dart`
- `gantt_entry.dart`
- `simulation_result.dart`
- `memory_block.dart`
- `memory_event.dart`
- `memory_result.dart`
- `file_block.dart`
- `file_allocation_event.dart`
- `file_allocation_result.dart`
- `advanced_fs_result.dart`
- `fat_table.dart`
- `extent.dart`
- `inode.dart`
- `bitmap.dart`

**screens/**
- `home_screen.dart`
- `process_simulator_screen.dart`
- `scheduling_tab.dart`
- `memory_tab.dart`
- `storage_screen.dart`
- `file_allocation_tab.dart`
- `advanced_fs_tab.dart`
- `about_screen.dart`

**widgets/**
- `common/` — neon_button, glass_card, glowing_progress, particles
- `cpu/` — gantt_chart, metrics_summary
- `memory/` — memory_map, memory_metrics
- `storage/` — disk_grid_canvas, fat_table_widget, bitmap_widget, inode_viewer, extent_list_widget, file_explorer_panel

**providers/**
- `app_state.dart`
- `memory_state.dart`
- `file_system_state.dart`

**algorithms/**
- `scheduler.dart`
- `memory_allocator.dart`
- `page_replacement.dart`
- `file_system/`
  - `file_system_facade.dart`
  - `contiguous_allocator.dart`
  - `linked_allocator.dart`
  - `indexed_allocator.dart`
  - `fat_allocator.dart`
  - `extent_allocator.dart`
  - `multilevel_allocator.dart`
  - `bitmap_manager.dart`
  - `file_allocator_base.dart`

## Instalación y ejecución

### Requisitos previos

- Flutter SDK 3.x o superior
- Dart SDK 3.x o superior
- Un editor compatible (VS Code, Android Studio) con los plugins de Flutter y Dart

### Pasos

1. Clonar el repositorio:
```bash
   git clone https://github.com/jos00011/Simulador-de-politicas-no-exclusivas-y-exclusivas.git
   cd Simulador-de-politicas-no-exclusivas-y-exclusivas
```

2. Instalar las dependencias:
```bash
   flutter pub get
```

3. Ejecutar la aplicación:
```bash
   flutter run
```

4. Compilar para una plataforma específica:
```bash
   flutter build windows
   flutter build apk
   flutter build web
```

## Formatos de entrada admitidos

El simulador acepta la definición de procesos mediante archivos CSV o de texto plano.

**Archivo CSV**

ID,T.Llegada,T.Servicio,Memoria(KB)
A,0,8,128
B,3,5,64
C,6,1,32
D,1,7,96
E,4,3,48

**Archivo TXT**

Formato: ID ArrivalTime BurstTime MemoryKB

A 0 8 128
B 3 5 64
C 6 1 32
D 1 7 96
E 4 3 48

## Métricas calculadas

| Módulo | Métricas |
|---|---|
| Planificación | Tiempo de retorno, tiempo de espera, utilización de CPU |
| Memoria | Utilización, fragmentación externa, fragmentación interna |
| Archivos | Utilización, fragmentación, extensión promedio |

## Pruebas y validación

El proyecto combina escenarios de prueba dirigidos —diseñados para cubrir casos límite conocidos de cada algoritmo, como el efecto convoy en FCFS o la paradoja de fragmentación de Best Fit— con validación de invariantes ejecutada automáticamente sobre cualquier resultado de simulación (tiempos no negativos, utilización de CPU dentro de [0, 100], conservación del tamaño total de memoria, ausencia de bloques de disco duplicados entre archivos).

## Mejoras futuras

- Persistencia local de configuraciones y resultados de simulación.
- Exportación de informes en PDF con capturas de las visualizaciones.
- Soporte para múltiples CPUs y políticas de balanceo de carga.
- Incorporación de Priority Scheduling y Multilevel Feedback Queue.
- Modo comparativo simultáneo entre dos o más algoritmos.

## Autor

**Coaguila Alave, José Enrique**
Universidad Nacional del Altiplano — Escuela Profesional de Ingeniería de Sistemas
Curso: Sistemas Operativos — Quinto semestre, 2026-I

## Referencias

- Silberschatz, A., Galvin, P. B., & Gagne, G. (2018). *Operating System Concepts* (10.ª ed.). Wiley.
- Stallings, W. (2018). *Operating Systems: Internals and Design Principles* (9.ª ed.). Pearson.
- Tanenbaum, A. S., & Bos, H. (2015). *Modern Operating Systems* (4.ª ed.). Pearson.
- Carretero, J., García, F., et al. (2001). *Sistemas Operativos: una visión aplicada* (1.ª ed.). McGraw Hill.

## Licencia

Este proyecto se distribuye con fines académicos.

---

## Capturas de pantalla

<!-- Agregar las imágenes correspondientes en cada bloque -->

### Pantalla de inicio

<img width="1917" height="1034" alt="Screenshot 2026-08-06 084221" src="https://github.com/user-attachments/assets/3a980ac6-0e3e-4472-86d5-a6354172208c" />

### Módulo de planificación de CPU

**FCFS**

<img width="1889" height="1032" alt="Screenshot 2026-08-06 084436" src="https://github.com/user-attachments/assets/5b8bc419-6f6e-4371-a63d-1d2cbe41936a" />

**SPN**

<img width="1892" height="1027" alt="Screenshot 2026-08-06 084558" src="https://github.com/user-attachments/assets/d51c2e5a-151d-4777-98b4-a0ff4752f961" />

**SRT**

<img width="1885" height="1034" alt="Screenshot 2026-08-06 084713" src="https://github.com/user-attachments/assets/303448c6-8a13-4145-90c3-f3e912b0ba04" />

**Round Robin**

<img width="1886" height="1032" alt="Screenshot 2026-08-06 084827" src="https://github.com/user-attachments/assets/0f30bbfa-6c23-4011-ba7d-02a4c53f6e00" />

### Módulo de gestión de memoria

**First Fit**

<img width="1893" height="974" alt="Screenshot 2026-08-06 085228" src="https://github.com/user-attachments/assets/28476f2e-2be0-4053-9fe0-7bd7cb98d48b" />

**Best Fit**

<img width="1885" height="978" alt="Screenshot 2026-08-06 085344" src="https://github.com/user-attachments/assets/e8eb71f1-d49b-41c0-86a6-048c96c04139" />

**Worst Fit**

<img width="1883" height="975" alt="Screenshot 2026-08-06 085511" src="https://github.com/user-attachments/assets/8ded7522-a115-416f-a05b-5d184cc6c1ce" />

**Buddy System**

<img width="1886" height="983" alt="Screenshot 2026-08-06 085615" src="https://github.com/user-attachments/assets/c8df3f6a-e6ce-43a8-b3ae-98b6e552fc7a" />

### Módulo de asignación de archivos

**Asignación contigua**

<img width="1894" height="1029" alt="Screenshot 2026-08-06 085825" src="https://github.com/user-attachments/assets/c0ed7ea9-68db-4c9b-aeba-93cfbec03e5a" />


**Asignación enlazada**

<img width="1888" height="1032" alt="Screenshot 2026-08-06 085931" src="https://github.com/user-attachments/assets/8c3a1457-2109-4544-a0f3-5b52460acf8a" />


**Asignación indexada**

<img width="1886" height="1030" alt="Screenshot 2026-08-06 090031" src="https://github.com/user-attachments/assets/e43ad3b1-c6ed-45b1-921d-ced404b504f6" />


**FAT**

<img width="1885" height="1036" alt="Screenshot 2026-08-06 090145" src="https://github.com/user-attachments/assets/0f2769d1-347d-4a88-bf29-0fcaa9b87659" />


**Extensión (extents)**

<img width="1886" height="1037" alt="Screenshot 2026-08-06 090319" src="https://github.com/user-attachments/assets/52b92279-a36f-4a43-80d9-98949464057e" />


**Inodos multinivel**

<img width="1884" height="1031" alt="Screenshot 2026-08-06 090443" src="https://github.com/user-attachments/assets/98cf2591-90b0-4089-993f-393a57880734" />


**Bitmap de bloques libres**

<img width="1891" height="1035" alt="Screenshot 2026-08-06 090549" src="https://github.com/user-attachments/assets/fdcb7e25-f5c9-4a79-baca-9c4101116e0b" />
