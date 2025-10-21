import 'dart:math';
import 'dart:ui';

class BoardGeometry {
  static const rows = 8;
  static const cols = 7;

  // TR etiketler (sade metin, diakritikler sadeleştirildi)
  static const labels = [
    ["1", "2", "3", "4", "OCA", "HEART", "PZT"],
    ["5", "6", "7", "8", "SUB", "MAR", "SAL"],
    ["9", "10", "11", "12", "NIS", "MAY", "CAR"],
    ["13", "14", "15", "16", "HAZ", "TEM", "PER"],
    ["17", "18", "19", "20", "AGU", "EYL", "CUM"],
    ["21", "22", "23", "24", "EKI", "KAS", "CMT"],
    ["25", "26", "27", "28", "ARA", "HEART", "PAZ"],
    ["29", "30", "31", "", "", "", ""],
  ];

  // BoardPainter ile paylaşılan metrikler
  static const double edgeInset = 14.0; // iç çerçeve boşluğu
  static const double gridPad = 12.0; // iç grid boşluğu

  static Rect innerRect(Size size) {
    return Rect.fromLTWH(
      edgeInset,
      edgeInset,
      size.width - edgeInset * 2,
      size.height - edgeInset * 2,
    );
  }

  static Rect gridRect(Size size) {
    final inner = innerRect(size);
    return Rect.fromLTWH(
      inner.left + gridPad,
      inner.top + gridPad,
      inner.width - gridPad * 2,
      inner.height - gridPad * 2,
    );
  }

  static double cellSizeFromSize(Size size) {
    final grid = squareGridRect(size);
    return grid.width / cols; // kare olduğundan cols ile aynı
  }

  // Kare ızgara alanı: mevcut gridRect içine sığacak şekilde ortalı kareleme
  static Rect squareGridRect(Size size) {
    final g = gridRect(size);
    final unit = min(g.width / cols, g.height / rows);
    final w = unit * cols;
    final h = unit * rows;
    final left = g.left + (g.width - w) / 2;
    final top = g.top + (g.height - h) / 2;
    return Rect.fromLTWH(left, top, w, h);
  }

  // 31'in sağındaki 4 hücre (row=7, col>=3) kullanılamaz
  static bool isForbiddenCell(int row, int col) {
    return row == 7 && col >= 3;
  }
}
