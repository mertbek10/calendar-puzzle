import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Bir parça yerleşimini temsil eder (örnek: piece A, koordinatlar listesi)
class CanonicalPlacement {
  final String pieceCode; // "A".."J"
  final List<List<int>> cells; // [[r,c], [r,c], ...]

  CanonicalPlacement({required this.pieceCode, required this.cells});

  factory CanonicalPlacement.fromJson(Map<String, dynamic> json) {
    return CanonicalPlacement(
      pieceCode: json['piece_code'] ?? json['pieceCode'] ?? '',
      cells: (json['cells'] as List).map((e) => List<int>.from(e)).toList(),
    );
  }
}

/// Belirli bir tarihe ait çözüm (birden fazla parça yerleşimi)
class CanonicalSolution {
  final String key; // örn "25 EKI CUM"
  final List<CanonicalPlacement> pieces;

  CanonicalSolution({required this.key, required this.pieces});

  factory CanonicalSolution.fromJson(String key, List<dynamic> list) {
    final pieces = list
        .map((e) => CanonicalPlacement.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    return CanonicalSolution(key: key, pieces: pieces);
  }
}

/// JSON'dan yüklenen tüm kanonik çözümler
class CanonicalSolutionsRepository {
  final Map<String, CanonicalSolution> _solutions = {};

  Future<void> loadFromAsset(String assetPath) async {
    final jsonStr = await rootBundle.loadString(assetPath);
    final data = json.decode(jsonStr) as Map<String, dynamic>;

    for (final entry in data.entries) {
      final key = entry.key;
      final val = entry.value;
      if (val is List && val.isNotEmpty) {
        // sadece ilk çözümü (solution_id: 0) baz alıyoruz
        final firstSolution = val.first['board_state'];
        if (firstSolution != null && firstSolution is List) {
          final placements = _parseBoardState(firstSolution);
          _solutions[key] = CanonicalSolution(key: key, pieces: placements);
        }
      }
    }
  }

  /// JSON içindeki matristen CanonicalPlacement dizisi üretir.
  /// Her hücrede 1-10 arası sayı varsa, o parçanın hangi hücreyi kapladığını çıkarır.
  List<CanonicalPlacement> _parseBoardState(List<dynamic> boardState) {
    final Map<int, List<List<int>>> pieceMap = {};

    for (int r = 0; r < boardState.length; r++) {
      final row = boardState[r] as List;
      for (int c = 0; c < row.length; c++) {
        final val = row[c];
        if (val is int && val > 0) {
          pieceMap.putIfAbsent(val, () => []);
          pieceMap[val]!.add([r, c]);
        }
      }
    }

    return pieceMap.entries.map((e) {
      final code = String.fromCharCode(64 + e.key); // 1->A, 2->B...
      return CanonicalPlacement(pieceCode: code, cells: e.value);
    }).toList();
  }

  CanonicalSolution? get(String key) => _solutions[key];
}
