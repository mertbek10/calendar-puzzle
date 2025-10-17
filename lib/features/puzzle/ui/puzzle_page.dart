import 'dart:ui';
import 'package:calender_puzzle/features/puzzle/logic/date_targets.dart';
import 'package:calender_puzzle/features/puzzle/state/puzzle_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'board_painter.dart';
import 'hud.dart';
import 'piece_widget.dart';

class PuzzlePage extends StatelessWidget {
  const PuzzlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PuzzleCubit(),
      child: const _PuzzleView(),
    );
  }
}

class _PuzzleView extends StatelessWidget {
  const _PuzzleView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PuzzleCubit>();
    final nowStr = DateTargets.formatHeader(cubit.state.currentDate);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HUD
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: BlocBuilder<PuzzleCubit, PuzzleState>(
                builder: (context, state) {
                  return Hud(
                    title: nowStr,
                    elapsedSeconds: state.elapsedSeconds,
                    hintsLeft: state.hintsLeft,
                    onReset: cubit.resetForToday,
                    onHint: cubit.useHint,
                  );
                },
              ),
            ),

            // Board
            Expanded(
              flex: 6,
              child: Center(
                child: LayoutBuilder(
                  builder: (context, c) {
                    final width = c.maxWidth * 0.92;
                    final height = c.maxHeight * 0.96;
                    return SizedBox(
                      width: width,
                      height: height,
                      child: CustomPaint(
                        painter: BoardPainter(),
                        isComplex: true,
                      ),
                    );
                  },
                ),
              ),
            ),

            // Piece tray (placeholder)
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: const [
                    PieceWidget(code: "A"),
                    PieceWidget(code: "B"),
                    PieceWidget(code: "C"),
                    PieceWidget(code: "D"),
                    PieceWidget(code: "E"),
                    PieceWidget(code: "F"),
                    PieceWidget(code: "G"),
                    PieceWidget(code: "H"),
                    PieceWidget(code: "I"),
                    PieceWidget(code: "J"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
