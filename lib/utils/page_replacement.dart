// lib/utils/page_replacement.dart
// Algoritmos: FIFO, LRU, Clock
// Ref: Silberschatz, "Operating System Concepts", 10th Ed. Cap. 10

enum ReplacementAlgorithm { fifo, lru, clock }

class ReplacementStep {
  final int pageReferenced;
  final List<int?> frames;
  final bool pageFault;
  final int? replacedPage;

  ReplacementStep({
    required this.pageReferenced,
    required this.frames,
    required this.pageFault,
    this.replacedPage,
  });
}

class ReplacementSimulationResult {
  final List<ReplacementStep> steps;
  final int totalPageFaults;
  final int totalAccesses;
  final double faultRate;
  final ReplacementAlgorithm algorithm;
  final int frameCount;

  ReplacementSimulationResult({
    required this.steps,
    required this.totalPageFaults,
    required this.totalAccesses,
    required this.faultRate,
    required this.algorithm,
    required this.frameCount,
  });
}

class PageReplacementSimulator {
  final int frameCount;
  final List<int> pageReferences;
  final ReplacementAlgorithm algorithm;

  PageReplacementSimulator({
    required this.frameCount,
    required this.pageReferences,
    required this.algorithm,
  });

  ReplacementSimulationResult run() {
    switch (algorithm) {
      case ReplacementAlgorithm.fifo:
        return _runFifo();
      case ReplacementAlgorithm.lru:
        return _runLru();
      case ReplacementAlgorithm.clock:
        return _runClock();
    }
  }

  // ─────────────────────────────────────────────────────────
  // FIFO — First In First Out
  // Reemplaza la página que lleva más tiempo en memoria
  // ─────────────────────────────────────────────────────────
  ReplacementSimulationResult _runFifo() {
    final frames = List<int?>.filled(frameCount, null);
    final queue = <int>[]; // orden de llegada
    final steps = <ReplacementStep>[];
    int faults = 0;

    for (final page in pageReferences) {
      bool fault = false;
      int? replaced;

      if (!frames.contains(page)) {
        fault = true;
        faults++;

        if (frames.contains(null)) {
          // Hay espacio libre
          final idx = frames.indexOf(null);
          frames[idx] = page;
          queue.add(page);
        } else {
          // Reemplazar el más antiguo
          final victim = queue.removeAt(0);
          final idx = frames.indexOf(victim);
          replaced = victim;
          frames[idx] = page;
          queue.add(page);
        }
      }

      steps.add(ReplacementStep(
        pageReferenced: page,
        frames: List<int?>.from(frames),
        pageFault: fault,
        replacedPage: replaced,
      ));
    }

    return ReplacementSimulationResult(
      steps: steps,
      totalPageFaults: faults,
      totalAccesses: pageReferences.length,
      faultRate: pageReferences.isEmpty ? 0 : faults / pageReferences.length,
      algorithm: ReplacementAlgorithm.fifo,
      frameCount: frameCount,
    );
  }

  // ─────────────────────────────────────────────────────────
  // LRU — Least Recently Used
  // Reemplaza la página que no se usó hace más tiempo
  // ─────────────────────────────────────────────────────────
  ReplacementSimulationResult _runLru() {
    final frames = List<int?>.filled(frameCount, null);
    final lastUsed = <int, int>{}; // page → último tiempo de uso
    final steps = <ReplacementStep>[];
    int faults = 0;
    int time = 0;

    for (final page in pageReferences) {
      bool fault = false;
      int? replaced;

      if (!frames.contains(page)) {
        fault = true;
        faults++;

        if (frames.contains(null)) {
          final idx = frames.indexOf(null);
          frames[idx] = page;
        } else {
          // Encontrar la página usada menos recientemente
          int lruTime = time + 1;
          int lruPage = -1;
          for (final f in frames) {
            if (f != null) {
              final t = lastUsed[f] ?? 0;
              if (t < lruTime) {
                lruTime = t;
                lruPage = f;
              }
            }
          }
          replaced = lruPage;
          final idx = frames.indexOf(lruPage);
          frames[idx] = page;
          lastUsed.remove(lruPage);
        }
      }

      lastUsed[page] = time;
      time++;

      steps.add(ReplacementStep(
        pageReferenced: page,
        frames: List<int?>.from(frames),
        pageFault: fault,
        replacedPage: replaced,
      ));
    }

    return ReplacementSimulationResult(
      steps: steps,
      totalPageFaults: faults,
      totalAccesses: pageReferences.length,
      faultRate: pageReferences.isEmpty ? 0 : faults / pageReferences.length,
      algorithm: ReplacementAlgorithm.lru,
      frameCount: frameCount,
    );
  }

  // ─────────────────────────────────────────────────────────
  // Clock (Segunda Oportunidad)
  // Usa bit de referencia; si está en 1, da segunda oportunidad
  // ─────────────────────────────────────────────────────────
  ReplacementSimulationResult _runClock() {
    final frames = List<int?>.filled(frameCount, null);
    final refBit = List<bool>.filled(frameCount, false);
    final steps = <ReplacementStep>[];
    int faults = 0;
    int hand = 0; // puntero del reloj

    for (final page in pageReferences) {
      bool fault = false;
      int? replaced;

      if (!frames.contains(page)) {
        fault = true;
        faults++;

        // Encontrar víctima con el reloj
        while (true) {
          if (frames[hand] == null) {
            // Marco libre
            frames[hand] = page;
            refBit[hand] = true;
            hand = (hand + 1) % frameCount;
            break;
          } else if (!refBit[hand]) {
            // Víctima encontrada (bit de referencia = 0)
            replaced = frames[hand];
            frames[hand] = page;
            refBit[hand] = true;
            hand = (hand + 1) % frameCount;
            break;
          } else {
            // Bit = 1: dar segunda oportunidad
            refBit[hand] = false;
            hand = (hand + 1) % frameCount;
          }
        }
      } else {
        // Hit: marcar como referenciada
        final idx = frames.indexOf(page);
        refBit[idx] = true;
      }

      steps.add(ReplacementStep(
        pageReferenced: page,
        frames: List<int?>.from(frames),
        pageFault: fault,
        replacedPage: replaced,
      ));
    }

    return ReplacementSimulationResult(
      steps: steps,
      totalPageFaults: faults,
      totalAccesses: pageReferences.length,
      faultRate: pageReferences.isEmpty ? 0 : faults / pageReferences.length,
      algorithm: ReplacementAlgorithm.clock,
      frameCount: frameCount,
    );
  }

  static String algorithmName(ReplacementAlgorithm alg) {
    switch (alg) {
      case ReplacementAlgorithm.fifo:
        return 'FIFO';
      case ReplacementAlgorithm.lru:
        return 'LRU';
      case ReplacementAlgorithm.clock:
        return 'Clock';
    }
  }
}
