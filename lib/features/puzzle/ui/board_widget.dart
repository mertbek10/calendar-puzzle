import 'package:calender_puzzle/features/puzzle/logic/board_geometry.dart';
import 'package:calender_puzzle/features/puzzle/state/puzzle_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'board_painter.dart';
import 'piece_painter.dart';
import '../data/piece_defs.dart';

class BoardWidget extends StatelessWidget {
  const BoardWidget({
    super.key,
    required this.day,
    required this.monthAbbr,
    required this.weekdayAbbr,
  });

  final int day;
  final String monthAbbr;
  final String weekdayAbbr;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final size = Size(c.maxWidth, c.maxHeight);
        final grid = BoardGeometry.squareGridRect(size);
        final unit = BoardGeometry.cellSizeFromSize(size);

        return Stack(
          children: [
            // Board görseli
            SizedBox.expand(
              child: CustomPaint(
                painter: BoardPainter(
                  day: day,
                  monthAbbr: monthAbbr,
                  weekdayAbbr: weekdayAbbr,
                ),
                isComplex: true,
              ),
            ),

            // Yerleştirilen parçaları çiz
            Positioned.fill(
              child: BlocBuilder<PuzzleCubit, PuzzleState>(
                buildWhen: (p, n) => p.placedPieces != n.placedPieces || p.preview != n.preview,
                builder: (context, state) {
                  return Stack(
                    children: [
                      // Hover preview highlight
                      if (state.preview != null && state.preview!.isValid)
                        Positioned(
                          left: grid.left + state.preview!.placement.col * unit,
                          top: grid.top + state.preview!.placement.row * unit,
                          width: unit * BoardWidget._colsOf(state.preview!.placement),
                          height: unit * BoardWidget._rowsOf(state.preview!.placement),
                          child: Opacity(
                            opacity: 0.7,
                            child: CustomPaint(
                              painter: PiecePainter(
                                shape: BoardWidget._transformedShape(state.preview!.placement),
                                mirrored: state.preview!.placement.mirrored,
                                quarterTurns: state.preview!.placement.quarterTurns,
                                unit: unit,
                                fill: const Color(0xFFCCCCCC),
                              ),
                            ),
                          ),
                        ),
                      for (final pl in state.placedPieces)
                        _PlacedDraggable(
                          grid: grid,
                          unit: unit,
                          placement: pl,
                        ),
                    ],
                  );
                },
              ),
            ),

            // Tüm grid alanını kapsayan DragTarget
            Positioned(
              left: grid.left,
              top: grid.top,
              width: grid.width,
              height: grid.height,
              child: _BoardDropArea(unit: unit),
            ),
          ],
        );
      },
    );
  }

  // Helpers for transformed sizes
  static List<List<int>> _transformedShape(Placement pl) {
    List<List<int>> mat = PieceDefs.shapeOf(pl.pieceCode)
        .map((r) => List<int>.from(r))
        .toList();
    for (int t = 0; t < (pl.quarterTurns % 4); t++) {
      mat = _rot90(mat);
    }
    if (pl.mirrored) {
      mat = mat.map((r) => r.reversed.toList()).toList();
    }
    return mat;
  }

  static int _rowsOf(Placement pl) => _transformedShape(pl).length;
  static int _colsOf(Placement pl) => _transformedShape(pl)[0].length;

  static List<List<int>> _rot90(List<List<int>> a) {
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

class _BoardDropArea extends StatelessWidget {
  const _BoardDropArea({required this.unit});
  final double unit;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PuzzleCubit>();
    return DragTarget<DragPieceData>(
      builder: (context, candidate, rejected) {
        return const SizedBox.expand();
      },
      onMove: (details) {
        final rb = context.findRenderObject() as RenderBox;
        final local = rb.globalToLocal(details.offset);
        int col = (local.dx / unit).round().clamp(0, BoardGeometry.cols - 1);
        int row = (local.dy / unit).round().clamp(0, BoardGeometry.rows - 1);
        cubit.updatePreview(details.data, row, col);
      },
      onLeave: (data) => cubit.clearPreview(),
      onAcceptWithDetails: (details) {
        final rb = context.findRenderObject() as RenderBox;
        final local = rb.globalToLocal(details.offset);
        int col = (local.dx / unit).round().clamp(0, BoardGeometry.cols - 1);
        int row = (local.dy / unit).round().clamp(0, BoardGeometry.rows - 1);
        final ok = cubit.tryPlace(details.data, row, col);
        cubit.clearPreview();
        if (!ok && details.data is DragPieceData) {
          final d = details.data as DragPieceData;
          if (d.prevRow != null && d.prevCol != null) {
            cubit.restorePlacement(Placement(
              d.code,
              d.prevRow!,
              d.prevCol!,
              mirrored: d.mirrored,
              quarterTurns: d.quarterTurns,
            ));
          }
        }
      },
    );
  }
}

class DragPieceData {
  final String code;
  final bool mirrored;
  final int quarterTurns;
  final int? prevRow;
  final int? prevCol;
  DragPieceData({
    required this.code,
    required this.mirrored,
    required this.quarterTurns,
    this.prevRow,
    this.prevCol,
  });
}

class _PlacedDraggable extends StatelessWidget {
  const _PlacedDraggable({required this.grid, required this.unit, required this.placement});
  final Rect grid;
  final double unit;
  final Placement placement;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PuzzleCubit>();
    final shape = BoardWidget._transformedShape(placement);
    final rows = shape.length;
    final cols = shape[0].length;

    return Positioned(
      left: grid.left + placement.col * unit,
      top: grid.top + placement.row * unit,
      width: unit * cols,
      height: unit * rows,
      child: Draggable<DragPieceData>(
        data: DragPieceData(
          code: placement.pieceCode,
          mirrored: placement.mirrored,
          quarterTurns: placement.quarterTurns,
          prevRow: placement.row,
          prevCol: placement.col,
        ),
        onDragStarted: () {
          // Tahtadan ayrılırken önce geçici olarak kaldır ve ayrıldığı yeri vurgula
          final prev = cubit.removePiece(placement.pieceCode);
          final p = prev ?? placement;
          cubit.updatePreview(
            DragPieceData(
              code: p.pieceCode,
              mirrored: p.mirrored,
              quarterTurns: p.quarterTurns,
              prevRow: p.row,
              prevCol: p.col,
            ),
            p.row,
            p.col,
          );
        },
        onDragEnd: (details) {
          if (!details.wasAccepted) {
            cubit.restorePlacement(placement);
          }
          cubit.clearPreview();
        },
        dragAnchorStrategy: (d, ctx, globalPos) {
          final box = ctx.findRenderObject() as RenderBox;
          final local = box.globalToLocal(globalPos);
          final fx = (local.dx / box.size.width).clamp(0.0, 1.0);
          final fy = (local.dy / box.size.height).clamp(0.0, 1.0);
          return Offset(fx * (cols * unit), fy * (rows * unit));
        },
        feedback: Material(
          type: MaterialType.transparency,
          child: CustomPaint(
            size: Size(cols * unit, rows * unit),
            painter: PiecePainter(
              shape: shape,
              mirrored: placement.mirrored,
              quarterTurns: placement.quarterTurns,
              unit: unit,
              fill: const Color(0xFFE7D9C2),
            ),
          ),
        ),
        childWhenDragging: const SizedBox.shrink(),
        child: CustomPaint(
          painter: PiecePainter(
            shape: shape,
            mirrored: placement.mirrored,
            quarterTurns: placement.quarterTurns,
            unit: unit,
            fill: const Color(0xFFE7D9C2),
          ),
        ),
      ),
    );
  }
}
