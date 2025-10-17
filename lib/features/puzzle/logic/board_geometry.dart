import 'dart:math';

class BoardGeometry {
  static const rows = 8;
  static const cols = 7;

  // PDF’teki etiketlerin birebir TR kısaltmaları (ÇAR, NİS, AĞU, EKİ)
  static const labels = [
    ["1", "2", "3", "4", "OCA", "♥", "PZT"],
    ["5", "6", "7", "8", "SUB", "MAR", "SAL"],
    ["9", "10", "11", "12", "NİS", "MAY", "ÇAR"],
    ["13", "14", "15", "16", "HAZ", "TEM", "PER"],
    ["17", "18", "19", "20", "AĞU", "EYL", "CUM"],
    ["21", "22", "23", "24", "EKİ", "KAS", "CMT"],
    ["25", "26", "27", "28", "ARA", "♥", "PAZ"],
    ["29", "30", "31", "", "", "", ""],
  ];

  // Grid alanı içinde hücre ölçüsünü hesaplamak için yardımcı:
  static double cellSize(double gridWidth, double gridHeight) {
    return min(gridWidth / cols, gridHeight / rows);
  }
}
