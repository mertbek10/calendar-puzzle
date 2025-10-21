import 'package:flutter/material.dart';

class PiecePainter extends CustomPainter {
  final List<List<int>> shape;
  final bool mirrored; // yatay ayna
  final int quarterTurns; // 0,1,2,3 (90°)
  final double unit; // tek hücre kenarı
  final Color fill; // parça rengi (düz)

  const PiecePainter({
    required this.shape,
    this.mirrored = false,
    this.quarterTurns = 0,
    this.unit = 24,
    this.fill = const Color(0xFFE7D9C2),
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Şekli dönüştür (rotasyon + ayna)
    List<List<int>> mat = shape.map((r) => List<int>.from(r)).toList();
    for (int t = 0; t < (quarterTurns % 4); t++) {
      mat = _rot90(mat);
    }
    if (mirrored) {
      mat = mat.map((r) => r.reversed.toList()).toList();
    }

    final rows = mat.length;
    final cols = mat[0].length;

    // İçeriği ortala
    final contentW = cols * unit;
    final contentH = rows * unit;
    canvas.translate((size.width - contentW) / 2, (size.height - contentH) / 2);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = fill
      ..isAntiAlias = false;

    // 1) Dolu hücreleri tek renk doldur
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        if (mat[y][x] == 0) continue;
        final rect = Rect.fromLTWH(x * unit, y * unit, unit, unit);
        canvas.drawRect(rect, fillPaint);
      }
    }

    // 2) Sadece dış çevre çizgisi (komşusu boş olan kenarlar)
    final edgePath = Path();
    for (int y = 0; y < rows; y++) {
      for (int x = 0; x < cols; x++) {
        if (mat[y][x] == 0) continue;

        final l = x * unit;
        final t = y * unit;
        final r = l + unit;
        final b = t + unit;

        if (y == 0 || mat[y - 1][x] == 0) { // üst
          edgePath.moveTo(l, t);
          edgePath.lineTo(r, t);
        }
        if (x == cols - 1 || mat[y][x + 1] == 0) { // sağ
          edgePath.moveTo(r, t);
          edgePath.lineTo(r, b);
        }
        if (y == rows - 1 || mat[y + 1][x] == 0) { // alt
          edgePath.moveTo(r, b);
          edgePath.lineTo(l, b);
        }
        if (x == 0 || mat[y][x - 1] == 0) { // sol
          edgePath.moveTo(l, b);
          edgePath.lineTo(l, t);
        }
      }
    }

    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.square
      ..strokeJoin = StrokeJoin.miter
      ..color = Colors.black
      ..strokeWidth = 1.2
      ..isAntiAlias = false;
    canvas.drawPath(edgePath, border);
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

