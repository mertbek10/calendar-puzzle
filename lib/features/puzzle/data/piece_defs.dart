/// PDF ve Python referansına göre 10 parça tanımı.
/// Her parça, 1=blok, 0=boş olacak şekilde matris içinde verilmiştir.
/// (Drag & drop ve yerleşim için grid-snap kullanacağız. Solver gömülmeyecek.)

class PieceDefs {
  // A-J sırayla (gerekirse ileride döndürme/ayna varyantlarını runtime'da üreteceğiz)
  static const List<List<List<int>>> shapes = [
    // A: Uzun L-tetromino
    [
      [1, 0],
      [1, 0],
      [1, 0],
      [1, 1],
    ],
    // B: Z-pentomino
    [
      [1, 1, 0],
      [0, 1, 0],
      [0, 1, 1],
    ],
    // C: Aynalı L-tetromino
    [
      [0, 1],
      [0, 1],
      [1, 1],
      [1, 0],
    ],
    // D: Düz 5
    [
      [1, 1, 1, 1, 1],
    ],
    // E: Z-tetromino
    [
      [0, 1, 1],
      [1, 1, 0],
    ],
    // F: L-pentomino
    [
      [0, 0, 1],
      [0, 0, 1],
      [1, 1, 1],
    ],
    // G: T-pentomino
    [
      [1, 1, 1],
      [0, 1, 0],
      [0, 1, 0],
    ],
    // H: Geniş T (mirrored)
    [
      [1, 1, 1],
      [1, 0, 1],
    ],
    // I: Uzun T-pentomino
    [
      [1, 1, 1, 1],
      [0, 0, 1, 0],
    ],
    // J: “skewed block” tetromino
    [
      [0, 1],
      [1, 1],
      [1, 1],
    ],
  ];
}
