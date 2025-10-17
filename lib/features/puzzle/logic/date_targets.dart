/// Günün tarihine göre boş bırakılması gereken 3 hücreyi bulma (gün, ay, gün adı).
/// UI tamamlandığında PuzzleCubit burayı kullanacak.

class DateTargets {
  // Ay ve gün adları haritaları (PDF kısaltmalarına göre)
  static const months = {
    "OCA": 1,
    "SUB": 2,
    "MAR": 3,
    "NİS": 4,
    "MAY": 5,
    "HAZ": 6,
    "TEM": 7,
    "AĞU": 8,
    "EYL": 9,
    "EKİ": 10,
    "KAS": 11,
    "ARA": 12,
  };
  static const weekdays = {
    "PZT": 1,
    "SAL": 2,
    "ÇAR": 3,
    "PER": 4,
    "CUM": 5,
    "CMT": 6,
    "PAZ": 7,
  };

  /// UI’da gösterilecek başlık için (örn: “16 EKİ CUM”)
  static String formatHeader(DateTime dt) {
    final m = months.entries.firstWhere((e) => e.value == dt.month).key;
    final wd = weekdays.entries
        .firstWhere((e) => e.value == ((dt.weekday)))
        .key;
    return "${dt.day} $m $wd";
  }
}
