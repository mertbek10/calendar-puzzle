/// Parça şekilleri: 1 = dolu hücre. (PDF'e göre A..J)
class PieceDefs {
  /// A..J harflerine karşılık gelen şekiller (satır x sütun matris)
  static const Map<String, List<List<int>>> shapes = {
    "A": [
      // uzun L
      [1, 0],
      [1, 0],
      [1, 0],
      [1, 1],
    ],
    "B": [
      // Z pentomino
      [1, 1, 0],
      [0, 1, 0],
      [0, 1, 1],
    ],
    "C": [
      // ayna L
      [0, 1],
      [0, 1],
      [1, 1],
      [1, 0],
    ],
    "D": [
      // düz 5
      [1, 1, 1, 1, 1],
    ],
    "E": [
      // Z tetromino
      [0, 1, 1],
      [1, 1, 0],
    ],
    "F": [
      // L pentomino
      [0, 0, 1],
      [0, 0, 1],
      [1, 1, 1],
    ],
    "G": [
      // T pentomino
      [1, 1, 1],
      [0, 1, 0],
      [0, 1, 0],
    ],
    "H": [
      // geniş T (mirrored)
      [1, 1, 1],
      [1, 0, 1],
    ],
    "I": [
      // uzun T
      [1, 1, 1, 1],
      [0, 0, 1, 0],
    ],
    "J": [
      // skewed block
      [0, 1],
      [1, 1],
      [1, 1],
    ],
  };

  static List<List<int>> shapeOf(String code) => shapes[code]!;
}
