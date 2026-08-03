// lib/core/app_constants.dart
// Constantes globales para el simulador

class AppConstants {
  // ─── TAMAÑOS POR DEFECTO ──────────────────────────────────
  static const int defaultBlockSize = 64; // KB por bloque
  static const int defaultDiskSize = 1024; // KB (16 bloques de 64KB)
  static const int defaultMemorySize = 512; // KB
  static const int defaultQuantum = 2; // unidades de tiempo para RR

  // ─── LÍMITES PARA INODOS (Multinivel) ────────────────────
  static const int directPointers = 12; // Punteros directos en inodo
  static const int singleIndirectSize = 256; // Bloques por índice simple
  static const int doubleIndirectSize = 256 * 256; // Bloques por índice doble

  // ─── VALORES FAT ──────────────────────────────────────────
  static const int fatFree = -2;
  static const int fatEof = -1;

  // ─── ANIMACIONES ──────────────────────────────────────────
  static const Duration animationDuration = Duration(milliseconds: 350);
  static const Duration transitionDuration = Duration(milliseconds: 300);

  // ─── RESPONSIVE ───────────────────────────────────────────
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
}