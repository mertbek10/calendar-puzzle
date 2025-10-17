import 'dart:ui';
import 'package:flutter/material.dart';

class BoardPainter extends CustomPainter {
  static const int rows = 8;
  static const int cols = 7;

  // PDF’teki TR etiketleri birebir (♥ dahil)
  static const List<List<String>> labels = [
    ["1", "2", "3", "4", "OCA", "♥", "PZT"],
    ["5", "6", "7", "8", "SUB", "MAR", "SAL"],
    ["9", "10", "11", "12", "NİS", "MAY", "ÇAR"],
    ["13", "14", "15", "16", "HAZ", "TEM", "PER"],
    ["17", "18", "19", "20", "AĞU", "EYL", "CUM"],
    ["21", "22", "23", "24", "EKİ", "KAS", "CMT"],
    ["25", "26", "27", "28", "ARA", "♥", "PAZ"],
    ["29", "30", "31", "", "", "", ""],
  ];

  final double outerRadius = 22;
  final double innerRadius = 12;

  @override
  void paint(Canvas canvas, Size size) {
    // Arka plan (koyu)
    final bg = Paint()..color = const Color(0xFF0B0D0F);
    canvas.drawRect(Offset.zero & size, bg);

    // Dış çerçeve (açık ahşap)
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(outerRadius),
    );
    final framePaint = Paint()..color = const Color(0xFFEEDCC3);
    canvas.drawRRect(outerRect, framePaint);

    // İç pano alanı (koyu kahverengi)
    const edgeInset = 14.0;
    final inner = Rect.fromLTWH(
      edgeInset,
      edgeInset,
      size.width - edgeInset * 2,
      size.height - edgeInset * 2 - 40, // alt kısımda logo boşluğu
    );
    final innerRRect = RRect.fromRectAndRadius(
      inner,
      Radius.circular(innerRadius),
    );

    // Ahşap efekt (basit dikey degrade)
    final woodGrad = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF5A3C25), Color(0xFF3F2919)],
      ).createShader(inner);
    canvas.drawRRect(innerRRect, woodGrad);

    // İç kenar kontur
    final innerBorder = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.black.withOpacity(0.6);
    canvas.drawRRect(innerRRect, innerBorder);

    // Grid alanı (8x7)
    const gridPad = 12.0;
    final grid = Rect.fromLTWH(
      inner.left + gridPad,
      inner.top + gridPad,
      inner.width - gridPad * 2,
      inner.height - gridPad * 2,
    );

    final cellW = grid.width / cols;
    final cellH = grid.height / rows;

    // Çizgiler
    final line = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..strokeWidth = 1;

    for (int c = 1; c < cols; c++) {
      final x = grid.left + c * cellW;
      canvas.drawLine(Offset(x, grid.top), Offset(x, grid.bottom), line);
    }
    for (int r = 1; r < rows; r++) {
      final y = grid.top + r * cellH;
      canvas.drawLine(Offset(grid.left, y), Offset(grid.right, y), line);
    }

    // Etiket stili
    final labelStyle = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );

    // Etiketleri yaz
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final label = labels[r][c];
        if (label.isEmpty) continue;

        final cellRect = Rect.fromLTWH(
          grid.left + c * cellW,
          grid.top + r * cellH,
          cellW,
          cellH,
        );

        // ♥ hücreleri — açık renk dolgu
        if (label == "♥") {
          final heartPaint = Paint()..color = Colors.white.withOpacity(0.08);
          final rr = RRect.fromRectAndRadius(
            cellRect.deflate(cellW * 0.12),
            const Radius.circular(6),
          );
          canvas.drawRRect(rr, heartPaint);
        }

        // Metin: gölge + beyaz
        final tp = TextPainter(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: label,
            style: labelStyle.copyWith(
              shadows: const [
                Shadow(
                  offset: Offset(0, 1),
                  blurRadius: 1.5,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
        )..layout(maxWidth: cellW);

        final dx = cellRect.left + (cellW - tp.width) / 2;
        final dy = cellRect.top + (cellH - tp.height) / 2;
        tp.paint(canvas, Offset(dx, dy));
      }
    }

    // Alt sağ köşede AB WOODFUN kabartması
    final badge = Rect.fromLTWH(
      inner.left + inner.width * 0.50,
      inner.bottom + 8,
      inner.width * 0.45,
      28,
    );
    final badgePaint = Paint()
      ..color = const Color(0xFFEEDCC3).withOpacity(0.75);
    canvas.drawRRect(
      RRect.fromRectAndRadius(badge, const Radius.circular(8)),
      badgePaint,
    );

    final brand = TextPainter(
      text: const TextSpan(
        text: "YurtPal Calendar Puzzle",
        style: TextStyle(
          color: Color(0xFF705D47),
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: badge.width);

    brand.paint(
      canvas,
      Offset(
        badge.left + (badge.width - brand.width) / 2,
        badge.top + (badge.height - brand.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
