import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Placement {
  final String pieceCode; // "A".."J"
  final int row; // grid row (top-left)
  final int col; // grid col (top-left)
  final bool mirrored;
  final int quarterTurns; // 0..3
  const Placement(this.pieceCode, this.row, this.col,
      {this.mirrored = false, this.quarterTurns = 0});
}

class PuzzleState extends Equatable {
  final List<Placement> placedPieces;
  final int hintsLeft;
  final int elapsedSeconds;
  final DateTime currentDate;
  final bool isCompleted;
  final HoverPreview? preview; // sürükleme vurgusu

  const PuzzleState({
    required this.placedPieces,
    required this.hintsLeft,
    required this.elapsedSeconds,
    required this.currentDate,
    required this.isCompleted,
    this.preview,
  });

  factory PuzzleState.initial(DateTime now) => PuzzleState(
    placedPieces: const [],
    hintsLeft: 3,
    elapsedSeconds: 0,
    currentDate: DateTime(now.year, now.month, now.day),
    isCompleted: false,
    preview: null,
  );

  PuzzleState copyWith({
    List<Placement>? placedPieces,
    int? hintsLeft,
    int? elapsedSeconds,
    DateTime? currentDate,
    bool? isCompleted,
    HoverPreview? preview,
  }) => PuzzleState(
    placedPieces: placedPieces ?? this.placedPieces,
    hintsLeft: hintsLeft ?? this.hintsLeft,
    elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
    currentDate: currentDate ?? this.currentDate,
    isCompleted: isCompleted ?? this.isCompleted,
    preview: preview ?? this.preview,
  );

  @override
  List<Object?> get props => [
    placedPieces,
    hintsLeft,
    elapsedSeconds,
    currentDate,
    isCompleted,
    preview,
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

  // --- Yerleştirme mantığı ---
  bool tryPlace(dynamic dragData, int row, int col) {
    // dragData: DragPieceData tanımı UI katmanında
    final code = dragData.code as String;
    final mirrored = dragData.mirrored as bool;
    final quarterTurns = dragData.quarterTurns as int;

    // Her parçadan yalnızca 1 tane
    if (state.placedPieces.any((p) => p.pieceCode == code)) {
      return false;
    }

    // Parça matrisini hazırla
    List<List<int>> mat = _shapeOf(code);
    for (int t = 0; t < (quarterTurns % 4); t++) {
      mat = _rot90(mat);
    }
    if (mirrored) {
      mat = mat.map((r) => r.reversed.toList()).toList();
    }

    final rows = mat.length, cols = mat[0].length;
    const boardRows = 8, boardCols = 7;

    final occupied = _occupiedCells(state.placedPieces);
    final best = _bestAnchor(row, col, mat, occupied, boardRows, boardCols);

    if (best == null) return false;

    final newList = List<Placement>.from(state.placedPieces)
      ..add(Placement(code, best.$1, best.$2, mirrored: mirrored, quarterTurns: quarterTurns));
    emit(state.copyWith(placedPieces: newList, preview: null));
    return true;
  }

  // helpers
  List<List<int>> _shapeOf(String code) => _shapes[code]!;

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

  Set<String> _occupiedCells(List<Placement> placed) {
    final s = <String>{};
    for (final p in placed) {
      var m = _shapeOf(p.pieceCode);
      for (int t = 0; t < (p.quarterTurns % 4); t++) { m = _rot90(m); }
      if (p.mirrored) m = m.map((r) => r.reversed.toList()).toList();
      for (int y = 0; y < m.length; y++) {
        for (int x = 0; x < m[0].length; x++) {
          if (m[y][x] == 1) s.add('${p.row + y}:${p.col + x}');
        }
      }
    }
    return s;
  }

  bool _canPlaceAt(int row, int col, List<List<int>> mat, Set<String> occupied,
      int boardRows, int boardCols) {
    for (int y = 0; y < mat.length; y++) {
      for (int x = 0; x < mat[0].length; x++) {
        if (mat[y][x] == 0) continue;
        final rr = row + y;
        final cc = col + x;
        if (rr < 0 || cc < 0 || rr >= boardRows || cc >= boardCols) return false;
        if (rr == 7 && cc >= 3) return false; // yasak bölge
        if (occupied.contains('$rr:$cc')) return false; // çakışma
      }
    }
    return true;
  }

  /// En yakın geçerli top-left hücreyi döndürür; yoksa null
  (int, int)? _bestAnchor(int row, int col, List<List<int>> mat, Set<String> occ,
      int boardRows, int boardCols) {
    // Öncelikle doğrudan kendi hücresini dener
    if (_canPlaceAt(row, col, mat, occ, boardRows, boardCols)) return (row, col);

    // Çevredeki adaylar: yarıçap 3 içinde, mesafeye göre sıralı
    final candidates = <List<int>>[];
    for (int dy = -3; dy <= 3; dy++) {
      for (int dx = -3; dx <= 3; dx++) {
        if (dx == 0 && dy == 0) continue;
        final d2 = dx * dx + dy * dy;
        candidates.add([dy, dx, d2]);
      }
    }
    candidates.sort((a, b) {
      final c = a[2].compareTo(b[2]);
      if (c != 0) return c;
      final ma = (a[0].abs() + a[1].abs());
      final mb = (b[0].abs() + b[1].abs());
      return ma.compareTo(mb);
    });

    for (final o in candidates) {
      final r = row + o[0];
      final c = col + o[1];
      if (_canPlaceAt(r, c, mat, occ, boardRows, boardCols)) return (r, c);
    }
    return null;
  }
}

extension PuzzleEditing on PuzzleCubit {
  Placement? removePiece(String code) {
    final idx = state.placedPieces.indexWhere((p) => p.pieceCode == code);
    if (idx == -1) return null;
    final list = List<Placement>.from(state.placedPieces);
    final removed = list.removeAt(idx);
    emit(state.copyWith(placedPieces: list));
    return removed;
  }

  void restorePlacement(Placement p) {
    final list = List<Placement>.from(state.placedPieces)..add(p);
    emit(state.copyWith(placedPieces: list));
  }

  // Drag sırasında vurguyu güncelle
  void updatePreview(dynamic dragData, int row, int col) {
    final code = dragData.code as String;
    final mirrored = dragData.mirrored as bool;
    final quarterTurns = dragData.quarterTurns as int;

    List<List<int>> mat = _shapeOf(code);
    for (int t = 0; t < (quarterTurns % 4); t++) { mat = _rot90(mat); }
    if (mirrored) { mat = mat.map((r) => r.reversed.toList()).toList(); }

    const boardRows = 8, boardCols = 7;
    final occupied = _occupiedCells(state.placedPieces);

    final best = _bestAnchor(row, col, mat, occupied, boardRows, boardCols);
    if (best != null) {
      emit(state.copyWith(
        preview: HoverPreview(
          Placement(code, best.$1, best.$2, mirrored: mirrored, quarterTurns: quarterTurns),
          true,
        ),
      ));
    } else {
      emit(state.copyWith(preview: null));
    }
  }

  void clearPreview() => emit(state.copyWith(preview: null));
}

class HoverPreview {
  final Placement placement;
  final bool isValid;
  const HoverPreview(this.placement, this.isValid);
}

// Shapes for placement checks (UI ile aynı içerik)
const Map<String, List<List<int>>> _shapes = {
  "A": [
    [1, 0],
    [1, 0],
    [1, 0],
    [1, 1],
  ],
  "B": [
    [1, 1, 0],
    [0, 1, 0],
    [0, 1, 1],
  ],
  "C": [
    [0, 1],
    [0, 1],
    [1, 1],
    [1, 0],
  ],
  "D": [
    [1, 1, 1, 1, 1],
  ],
  "E": [
    [0, 1, 1],
    [1, 1, 0],
  ],
  "F": [
    [0, 0, 1],
    [0, 0, 1],
    [1, 1, 1],
  ],
  "G": [
    [1, 1, 1],
    [0, 1, 0],
    [0, 1, 0],
  ],
  "H": [
    [1, 1, 1],
    [1, 0, 1],
  ],
  "I": [
    [1, 1, 1, 1],
    [0, 0, 1, 0],
  ],
  "J": [
    [0, 1],
    [1, 1],
    [1, 1],
  ],
};
