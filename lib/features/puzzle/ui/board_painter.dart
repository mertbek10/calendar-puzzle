import 'dart:ui';
import 'package:flutter/material.dart';

class BoardPainter extends CustomPainter {
  BoardPainter({
    required this.day,
    required this.monthAbbr,
    required this.weekdayAbbr,
  });

  final int day;
  final String monthAbbr; // "EKİ"
  final String weekdayAbbr; // "PZT"

  static const int rows = 8;
  static const int cols = 7;

  // PDF’teki TR etiketleri (dikkat: diakritikler)
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

    // Dış çerçeve
    const frameColor = Color(0xFFEEDCC3);
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(outerRadius),
    );
    canvas.drawRRect(outerRect, Paint()..color = frameColor);

    // İç pano
    const edgeInset = 14.0;
    final inner = Rect.fromLTWH(
      edgeInset,
      edgeInset,
      size.width - edgeInset * 2,
      size.height - edgeInset * 2,
    );
    final innerRRect = RRect.fromRectAndRadius(
      inner,
      Radius.circular(innerRadius),
    );

    final woodGrad = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF5A3C25), Color(0xFF3F2919)],
      ).createShader(inner);
    canvas.drawRRect(innerRRect, woodGrad);

    // İç kenar kontur
    canvas.drawRRect(
      innerRRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Color(0xFFEEDCC3),
    );

    // Grid alanı (8x7) — alt logosu artık grid içinde sağ-alttaki 3 boş karede
    const gridPad = 12.0;
    final grid = Rect.fromLTWH(
      inner.left + gridPad,
      inner.top + gridPad,
      inner.width - gridPad * 2,
      inner.height - gridPad * 2,
    );

    final cellW = grid.width / cols;
    final cellH = grid.height / rows;

    final line = Paint()
      ..color = Colors.black.withOpacity(0.25)
      ..strokeWidth = 1;

    // Etiket stili
    final labelStyle = const TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.5,
    );

    // Hedef string’leri
    final dayStr = '$day';
    final mAbbr = monthAbbr;
    final wAbbr = weekdayAbbr;

    // Hücre dolguları
    final targetFill = Paint()..color = const Color(0xFF7A513A); // belirgin
    final targetStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = const Color(0xFFF2C18D);
    final heartFill = Paint()..color = Colors.white.withOpacity(0.08);
    final footerFill = Paint()..color = frameColor; // çerçeveyle aynı

    Rect? footerRect;

    // Hücreleri çiz + hedefleri vurgula
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final label = labels[r][c];
        final cellRect = Rect.fromLTWH(
          grid.left + c * cellW,
          grid.top + r * cellH,
          cellW,
          cellH,
        );

        // sağ-alt 3 boş hücreyi çerçeve rengine boyayıp footerRect biriktir
        if (label.isEmpty && r == 7 && (c == 4 || c == 5 || c == 6)) {
          canvas.drawRect(cellRect, footerFill);
          footerRect = (footerRect == null)
              ? cellRect
              : footerRect!.expandToInclude(cellRect);
        }

        // hedef dolgu
        final isTarget = label == dayStr || label == mAbbr || label == wAbbr;
        if (!label.isEmpty && isTarget) {
          final rr = RRect.fromRectAndRadius(
            cellRect.deflate(cellW * 0.08),
            const Radius.circular(6),
          );
          canvas.drawRRect(rr, targetFill);
          canvas.drawRRect(rr, targetStroke);
        }

        // kalp hücreleri — soft dolgu
        if (label == "♥") {
          final rr = RRect.fromRectAndRadius(
            cellRect.deflate(cellW * 0.12),
            const Radius.circular(6),
          );
          canvas.drawRRect(rr, heartFill);
        }

        // ızgara çizgisi
        canvas.drawLine(
          Offset(cellRect.left, cellRect.top),
          Offset(cellRect.right, cellRect.top),
          line,
        );
        canvas.drawLine(
          Offset(cellRect.left, cellRect.bottom),
          Offset(cellRect.right, cellRect.bottom),
          line,
        );
        canvas.drawLine(
          Offset(cellRect.left, cellRect.top),
          Offset(cellRect.left, cellRect.bottom),
          line,
        );
        canvas.drawLine(
          Offset(cellRect.right, cellRect.top),
          Offset(cellRect.right, cellRect.bottom),
          line,
        );

        // etiket yaz
        if (label.isNotEmpty) {
          final tp = TextPainter(
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            text: TextSpan(
              text: label,
              style: labelStyle.copyWith(
                // hedefte yazıyı biraz daha parlak yap
                color: isTarget ? Colors.white : labelStyle.color,
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
    }

    // footer yazısı (sağ-alt 3 boş hücre birleşimi)
    if (footerRect != null) {
      final tp = TextPainter(
        text: const TextSpan(
          text: "YurtPal Calendar Puzzle",
          style: TextStyle(
            color: Color(0xFF6D5A4C),
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
            fontSize: 13,
          ),
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        maxLines: 1,
      )..layout(maxWidth: footerRect!.width);

      final off = Offset(
        footerRect!.left + (footerRect!.width - tp.width) / 2,
        footerRect!.top + (footerRect!.height - tp.height) / 2,
      );
      tp.paint(canvas, off);
    }
  }

  @override
  bool shouldRepaint(covariant BoardPainter old) {
    return day != old.day ||
        monthAbbr != old.monthAbbr ||
        weekdayAbbr != old.weekdayAbbr;
  }
}
