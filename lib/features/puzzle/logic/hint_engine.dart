/// İpucu sistemi: Sabit 3 parçayı sırayla otomatik yerleştirmek için iskelet.
/// Not: Yerleşim koordinatlarını ileride kanonik JSON’dan okuyacağız.
/// Şimdilik sadece “hangi parçalar” dizisini tutuyor.

class HintEngine {
  // İPUCU hep aynı 3 parça: örnek A, D, G (sen hangi 3’ü istersen burada belirleyelim)
  static const fixedHintPieces = ["A", "D", "G"]; // A-J harfleri ile

  int index = 0;

  String? nextPieceCode() {
    if (index >= fixedHintPieces.length) return null;
    return fixedHintPieces[index++];
  }

  void reset() => index = 0;
}
