import 'package:flutter/material.dart';

class PiecePainter extends CustomPainter {
  final List<List<int>> shape;
  final bool mirrored; // yatay ayna
  final int quarterTurns; // 0,1,2,3 (90°)
  final double unit; // TEK HÜCRE KENARI (board ile aynı olmalı)
  final Color fill; // parça rengi (ahşap yerine düz)

  const PiecePainter({
    required this.shape,
    this.mirrored = false,
    this.quarterTurns = 0,
    this.unit = 24,
    this.fill = const Color(0xFFE7D9C2), // açık ahşap tonu (düz)
  });

  @override
  void paint(Canvas canvas, Size size) {
    // --- mat hazırlık (rotasyon + mirror) ---
    List<List<int>> mat = shape.map((r) => List<int>.from(r)).toList();
    for (int t = 0; t < (quarterTurns % 4); t++) {
      mat = _rot90(mat);
    }
    if (mirrored) {
      mat = mat.map((r) => r.reversed.toList()).toList();
    }

    final rows = mat.length;
    final cols = mat[0].length;

    // İçeriği tam ortala
    final contentW = cols * unit;
    final contentH = rows * unit;
    canvas.translate((size.width - contentW) / 2, (size.height - contentH) / 2);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fill
      ..isAntiAlias = false; // keskin kenar

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.black.withOpacity(0.25)
      ..strokeWidth = 0.8
      ..isAntiAlias = false;

    // DÜMDÜZ kareler: boşluk yok, radius yok.
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        if (mat[y][x] == 0) continue;
        final rect = Rect.fromLTWH(x * unit, y * unit, unit, unit);
        canvas.drawRect(rect, fillPaint);
        canvas.drawRect(rect, stroke);
      }
    }
  }

  @override
  bool shouldRepaint(covariant PiecePainter old) {
    return old.mirrored != mirrored ||
        old.quarterTurns != quarterTurns ||
        old.shape != shape ||
        old.unit != unit ||
        old.fill != fill;
  }

  List<List<int>> _rot90(List<List<int>> a) {
    final h = a.length, w = a[0].length;
    final b = List.generate(w, (_) => List<int>.filled(h, 0));
    for (int y = 0; y < h; y++) {
      for (int x = 0; x < w; x++) {
        b[x][h - 1 - y] = a[y][x];
      }
    }
    return b;
  }
}
