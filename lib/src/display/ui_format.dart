/// Small, dependency-free formatters for sizes, counts, times and durations.
///
/// ```dart
/// UiFormat.bytes(1536);            // 1.5 KB
/// UiFormat.compact(1200);          // 1.2k
/// UiFormat.relativeTime(sentAt);   // 5m
/// UiFormat.duration(d);            // 4:09
/// ```
abstract final class UiFormat {
  static const _byteUnits = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  /// File size with 1024 steps: `512 B`, `1.5 KB`, `12 MB`, `3.4 GB`.
  static String bytes(int bytes, {int decimals = 1}) {
    if (bytes < 1024) return '${bytes < 0 ? 0 : bytes} B';
    var value = bytes.toDouble();
    var unit = 0;
    while (value >= 1024 && unit < _byteUnits.length - 1) {
      value /= 1024;
      unit++;
    }
    // Rounding can produce "1024 KB"; move to the next unit instead.
    if (double.parse(value.toStringAsFixed(decimals)) >= 1024 && unit < _byteUnits.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${_trim(value, decimals)} ${_byteUnits[unit]}';
  }

  /// Short count: `999`, `1.2k`, `45k`, `3.4M`, `1.1B`.
  static String compact(num value, {int decimals = 1}) {
    final sign = value < 0 ? '-' : '';
    var v = value.abs().toDouble();
    if (v < 1000) return '$sign${_trim(v, decimals)}';
    const units = ['', 'k', 'M', 'B', 'T'];
    var unit = 0;
    while (v >= 1000 && unit < units.length - 1) {
      v /= 1000;
      unit++;
    }
    if (double.parse(v.toStringAsFixed(decimals)) >= 1000 && unit < units.length - 1) {
      v /= 1000;
      unit++;
    }
    return '$sign${_trim(v, decimals)}${units[unit]}';
  }

  /// Time since [time]: `just now`, `5m`, `3h`, `2d`, then a date (`Mar 5`,
  /// or `Mar 5, 2024` in another year). Future times read `in 5m`.
  static String relativeTime(DateTime time, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final diff = n.difference(time);
    final future = diff.isNegative;
    final d = diff.abs();
    String rel(String s) => future ? 'in $s' : s;
    if (d.inSeconds < 60) return 'just now';
    if (d.inMinutes < 60) return rel('${d.inMinutes}m');
    if (d.inHours < 24) return rel('${d.inHours}h');
    if (d.inDays < 7) return rel('${d.inDays}d');
    final local = time.toLocal();
    final date = '${_months[local.month - 1]} ${local.day}';
    return local.year == n.toLocal().year ? date : '$date, ${local.year}';
  }

  /// Clock-style duration: `4:09`, `1:05:09`. Negative durations read as `0:00`.
  static String duration(Duration d) {
    if (d.isNegative) d = Duration.zero;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
  }

  static String _trim(double v, int decimals) {
    final s = v.toStringAsFixed(decimals);
    if (!s.contains('.')) return s;
    final t = s.replaceFirst(RegExp(r'0+$'), '');
    return t.endsWith('.') ? t.substring(0, t.length - 1) : t;
  }
}
