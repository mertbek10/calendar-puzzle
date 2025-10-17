import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Placement {
  final String pieceCode; // "A".."J"
  final int row; // grid row
  final int col; // grid col
  final int rotation; // 0,90,180,270 (ileride kullanacağız)
  const Placement(this.pieceCode, this.row, this.col, {this.rotation = 0});
}

class PuzzleState extends Equatable {
  final List<Placement> placedPieces;
  final int hintsLeft;
  final int elapsedSeconds;
  final DateTime currentDate;
  final bool isCompleted;

  const PuzzleState({
    required this.placedPieces,
    required this.hintsLeft,
    required this.elapsedSeconds,
    required this.currentDate,
    required this.isCompleted,
  });

  factory PuzzleState.initial(DateTime now) => PuzzleState(
    placedPieces: const [],
    hintsLeft: 3,
    elapsedSeconds: 0,
    currentDate: DateTime(now.year, now.month, now.day),
    isCompleted: false,
  );

  PuzzleState copyWith({
    List<Placement>? placedPieces,
    int? hintsLeft,
    int? elapsedSeconds,
    DateTime? currentDate,
    bool? isCompleted,
  }) => PuzzleState(
    placedPieces: placedPieces ?? this.placedPieces,
    hintsLeft: hintsLeft ?? this.hintsLeft,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    currentDate: currentDate ?? this.currentDate,
    isCompleted: isCompleted ?? this.isCompleted,
  );

  @override
  List<Object?> get props => [
    placedPieces,
    hintsLeft,
    elapsedSeconds,
    currentDate,
    isCompleted,
  ];
}

class PuzzleCubit extends Cubit<PuzzleState> {
  PuzzleCubit() : super(PuzzleState.initial(DateTime.now()));

  void resetForToday() {
    emit(PuzzleState.initial(DateTime.now()));
  }

  void tick() {
    emit(state.copyWith(elapsedSeconds: state.elapsedSeconds + 1));
  }

  void useHint() {
    if (state.hintsLeft == 0) return;
    emit(state.copyWith(hintsLeft: state.hintsLeft - 1));
    // Burada kanonik bir yerleşimi otomatik ekleyeceğiz (sonraki adım).
  }
}
