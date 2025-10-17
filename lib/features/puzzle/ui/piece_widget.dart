import 'package:calender_puzzle/features/puzzle/data/piece_defs.dart';
import 'package:flutter/material.dart';
import 'piece_painter.dart';

class PieceWidget extends StatefulWidget {
  final String code; // "A".."J"
  final double? trayUnit; // tepsideki kare boyutu (UI önizleme için)

  const PieceWidget({super.key, required this.code, this.trayUnit});

  @override
  State<PieceWidget> createState() => _PieceWidgetState();
}

class _PieceWidgetState extends State<PieceWidget> {
  bool mirrored = false;
  int quarterTurns = 0;

  @override
  Widget build(BuildContext context) {
    final shape = PieceDefs.shapeOf(widget.code);
    final rows = shape.length;
    final cols = shape[0].length;

    // Tepside önizleme için birim (board ile birebir olmak zorunda değil),
    // ama drop’ta BOARD hücre boyutunu kullanacağız.
    final unit = widget.trayUnit ?? 26.0;

    final w = cols * unit;
    final h = rows * unit;

    return GestureDetector(
      // 2 parmak → ayna
      onScaleStart: (d) {
        if (d.pointerCount == 2) setState(() => mirrored = !mirrored);
      },
      // uzun bas → 90° döndür
      onLongPress: () {
        setState(() => quarterTurns = (quarterTurns + 1) % 4);
      },
      child: SizedBox(
        width: w,
        height: h,
        child: CustomPaint(
          painter: PiecePainter(
            shape: shape,
            mirrored: mirrored,
            quarterTurns: quarterTurns,
            unit: unit,
            fill: const Color(0xFFE7D9C2), // düz açık ahşap
          ),
        ),
      ),
    );
  }
}
