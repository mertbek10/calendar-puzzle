import 'package:calender_puzzle/features/puzzle/data/piece_defs.dart';
import 'package:calender_puzzle/features/puzzle/ui/board_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../state/puzzle_cubit.dart';
import 'package:flutter/material.dart';
import 'piece_painter.dart';

class PieceWidget extends StatefulWidget {
  final String code; // "A".."J"
  final double? trayUnit; // tepside küçük önizleme
  final double? boardUnit; // sürükleme esnasında hücre boyutu

  const PieceWidget({super.key, required this.code, this.trayUnit, this.boardUnit});

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

    final unit = widget.trayUnit ?? 26.0; // tepsi küçük boyut
    final feedbackUnit = widget.boardUnit ?? unit; // drag sırasında hücreyi kapla

    final w = cols * unit;
    final h = rows * unit;

    final preview = SizedBox(
      width: w,
      height: h,
      child: CustomPaint(
        painter: PiecePainter(
          shape: shape,
          mirrored: mirrored,
          quarterTurns: quarterTurns,
          unit: unit,
          fill: const Color(0xFFE7D9C2),
        ),
      ),
    );

    final isPlaced = context.select((PuzzleCubit c) =>
        c.state.placedPieces.any((p) => p.pieceCode == widget.code));

    if (isPlaced) {
      // Tahtada ise tepside görünmesin (boş yer tutucu ile düzen bozulmasın)
      return SizedBox(width: w, height: h);
    }

    // Özel anchor: kullanıcı neresinden tuttuysa feedback'te aynı nokta imleç altında kalsın
    final dragAnchor = (Draggable<Object> d, BuildContext ctx, Offset globalPos) {
      final box = ctx.findRenderObject() as RenderBox;
      final local = box.globalToLocal(globalPos);
      final fx = (local.dx / box.size.width).clamp(0.0, 1.0);
      final fy = (local.dy / box.size.height).clamp(0.0, 1.0);
      return Offset(fx * (cols * feedbackUnit), fy * (rows * feedbackUnit));
    };

    return Draggable<DragPieceData>(
      data: DragPieceData(code: widget.code, mirrored: mirrored, quarterTurns: quarterTurns),
      dragAnchorStrategy: dragAnchor,
      feedback: Material(
        type: MaterialType.transparency,
        child: CustomPaint(
          size: Size(cols * feedbackUnit, rows * feedbackUnit),
          painter: PiecePainter(
            shape: shape,
            mirrored: mirrored,
            quarterTurns: quarterTurns,
            unit: feedbackUnit,
            fill: const Color(0xFFE7D9C2),
          ),
        ),
      ),
      // Sürüklerken tepside yer tutucu kalsın (şekil kayması olmasın)
      childWhenDragging: SizedBox(width: w, height: h),
      child: GestureDetector(
        onScaleStart: (d) {
          if (d.pointerCount == 2) setState(() => mirrored = !mirrored);
        },
        onLongPress: () {
          setState(() => quarterTurns = (quarterTurns + 1) % 4);
        },
        child: preview,
      ),
    );
  }
}
