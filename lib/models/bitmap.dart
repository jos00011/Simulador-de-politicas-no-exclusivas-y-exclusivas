// lib/models/bitmap.dart

class Bitmap {
  final List<bool> bits;

  Bitmap({required this.bits});

  int get size => bits.length;
  int get freeBlocks => bits.where((b) => !b).length;
  int get usedBlocks => bits.where((b) => b).length;

  bool isFree(int index) => index >= 0 && index < size && !bits[index];
  bool isUsed(int index) => index >= 0 && index < size && bits[index];

  factory Bitmap.initial(int size) {
    return Bitmap(bits: List.filled(size, false));
  }

  Bitmap copyWith({List<bool>? bits}) {
    return Bitmap(bits: bits ?? this.bits);
  }

  void markUsed(int index) {
    if (index >= 0 && index < size) bits[index] = true;
  }

  void markFree(int index) {
    if (index >= 0 && index < size) bits[index] = false;
  }

  void markRangeUsed(int start, int length) {
    for (int i = start; i < start + length && i < size; i++) {
      bits[i] = true;
    }
  }

  void markRangeFree(int start, int length) {
    for (int i = start; i < start + length && i < size; i++) {
      bits[i] = false;
    }
  }

  List<int> findFreeBlocks(int count) {
    final result = <int>[];
    for (int i = 0; i < size && result.length < count; i++) {
      if (isFree(i)) result.add(i);
    }
    return result;
  }

  int? findContiguousFree(int count) {
    int currentRun = 0, runStart = 0;
    for (int i = 0; i < size; i++) {
      if (isFree(i)) {
        if (currentRun == 0) runStart = i;
        currentRun++;
        if (currentRun >= count) return runStart;
      } else {
        currentRun = 0;
      }
    }
    return null;
  }

  int get largestFreeHole {
    int currentRun = 0, largest = 0;
    for (int i = 0; i < size; i++) {
      if (isFree(i)) {
        currentRun++;
        if (currentRun > largest) largest = currentRun;
      } else {
        currentRun = 0;
      }
    }
    return largest;
  }

  double get utilizationPercent => size == 0 ? 0 : usedBlocks / size * 100;
  int get externalFragmentation => freeBlocks - largestFreeHole;
  String toBinaryString() => bits.map((b) => b ? '1' : '0').join();

  Map<String, dynamic> getStats() {
    return {
      'totalBlocks': size,
      'freeBlocks': freeBlocks,
      'usedBlocks': usedBlocks,
      'utilizationPercent': utilizationPercent,
      'largestFreeHole': largestFreeHole,
      'externalFragmentation': externalFragmentation,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Bitmap && other.bits.length == bits.length &&
        other.bits.asMap().entries.every((e) => e.value == bits[e.key]);
  }

  @override
  int get hashCode => Object.hashAll(bits);
}