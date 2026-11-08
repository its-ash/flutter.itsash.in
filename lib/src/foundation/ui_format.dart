import 'package:flutter/material.dart';

abstract final class UiFormat {
  static const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const monthsLong = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  static const mask = '••••';

  static final _group = RegExp(r'\B(?=(\d{3})+(?!\d))');
  static final _nonZero = RegExp('[1-9]');

  static String _two(int v) => v.toString().padLeft(2, '0');

  static DateTime dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static bool sameDay(DateTime? a, DateTime? b) => a != null && b != null && a.year == b.year && a.month == b.month && a.day == b.day;

  static int daysInMonth(int year, int month) => DateTime(year, month + 1, 0).day;

  static int daysUntil(DateTime d, {DateTime? now}) {
    final n = now ?? DateTime.now();
    return DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(n.year, n.month, n.day)).inDays;
  }

  static String weekday(DateTime d) => weekdays[d.weekday - 1];

  static String date(DateTime d) => '${d.day} ${months[d.month - 1]} ${d.year}';

  static String shortDate(DateTime d, {DateTime? now}) =>
      '${d.day} ${months[d.month - 1]}${d.year == (now ?? DateTime.now()).year ? '' : ' ${d.year}'}';

  static String day(DateTime d, {bool year = false}) => '${weekday(d)}, ${d.day} ${months[d.month - 1]}${year ? ' ${d.year}' : ''}';

  static String monthYear(DateTime d) => '${monthsLong[d.month - 1]} ${d.year}';

  static String time(Object t, {bool h24 = false}) {
    final v = switch (t) {
      TimeOfDay x => x,
      DateTime x => TimeOfDay.fromDateTime(x),
      _ => throw ArgumentError.value(t, 't', 'Use TimeOfDay or DateTime'),
    };
    final m = _two(v.minute);
    if (h24) return '${_two(v.hour)}:$m';
    return '${v.hourOfPeriod == 0 ? 12 : v.hourOfPeriod}:$m ${v.period == DayPeriod.am ? 'AM' : 'PM'}';
  }

  static String dateTime(DateTime d, {bool h24 = false, bool weekday = false}) =>
      '${weekday ? day(d) : date(d)}, ${time(d, h24: h24)}';

  static String range(DateTimeRange r) {
    final s = r.start;
    final e = r.end;
    if (sameDay(s, e)) return date(s);
    if (s.year == e.year) return '${s.day} ${months[s.month - 1]} – ${date(e)}';
    return '${date(s)} – ${date(e)}';
  }

  static String relative(DateTime t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final d = n.difference(t);
    return switch (d) {
      _ when d.isNegative && d.inMinutes < -1 => shortDate(t, now: n),
      _ when d.inSeconds < 60 => 'now',
      _ when d.inMinutes < 60 => '${d.inMinutes}m',
      _ when d.inHours < 24 => '${d.inHours}h',
      _ when d.inDays < 7 => '${d.inDays}d',
      _ => shortDate(t, now: n),
    };
  }

  static String relativeDay(DateTime d, {DateTime? now}) {
    final n = now ?? DateTime.now();
    return switch (daysUntil(d, now: n)) {
      0 => 'Today',
      -1 => 'Yesterday',
      1 => 'Tomorrow',
      _ => day(d, year: d.year != n.year),
    };
  }

  static String duration(Duration d) {
    final s = d.isNegative ? 0 : d.inSeconds;
    final h = s ~/ 3600;
    final hms = '${_two((s % 3600) ~/ 60)}:${_two(s % 60)}';
    return h > 0 ? '$h:$hms' : hms;
  }

  static String minutes(Duration d) {
    final m = d.isNegative ? 0 : d.inMinutes;
    if (m < 60) return '$m min';
    final r = m % 60;
    return r == 0 ? '${m ~/ 60}h' : '${m ~/ 60}h ${r}m';
  }

  static String number(num? v, {int decimals = 0, bool trimZeros = false, String group = ',', String point = '.'}) {
    final x = v == null || !v.isFinite ? 0.0 : v.toDouble();
    final fixed = x.abs().toStringAsFixed(decimals.clamp(0, 6));
    final parts = fixed.split('.');
    var frac = parts.length > 1 ? parts[1] : '';
    if (trimZeros) frac = frac.replaceFirst(RegExp(r'0+$'), '');
    final neg = x < 0 && _nonZero.hasMatch(fixed);
    return '${neg ? '-' : ''}${parts.first.replaceAllMapped(_group, (_) => group)}${frac.isEmpty ? '' : '$point$frac'}';
  }

  static String compact(num? v, {bool floor = false}) {
    const units = ['', 'k', 'M', 'B', 'T'];
    final x = v == null || !v.isFinite ? 0.0 : v.toDouble();
    var n = x.abs();
    var i = 0;
    while (n >= (floor ? 1000 : 999.5) && i < units.length - 1) {
      n /= 1000;
      i++;
    }
    final dec = n >= 100 ? 0 : 1;
    final p = dec == 0 ? 1 : 10;
    final r = floor ? (n * p).floor() / p : n;
    final body = r.toStringAsFixed(dec).replaceFirst(RegExp(r'\.0$'), '');
    return '${x < 0 && _nonZero.hasMatch(body) ? '-' : ''}$body${units[i]}';
  }

  static String count(int n) => compact(n < 0 ? 0 : n, floor: true);

  static String percent(double v, {bool sign = true, int decimals = 1}) {
    if (!v.isFinite) return '–';
    final s = '${v.abs().toStringAsFixed(decimals.clamp(0, 4))}%';
    return v > 0 && sign ? '+$s' : (v < 0 ? '-$s' : s);
  }

  static String masked(String number, {int visible = 4}) {
    final d = number.replaceAll(RegExp(r'\D'), '');
    if (d.isEmpty) return mask;
    final n = visible.clamp(0, d.length);
    return n == 0 ? mask : '$mask ${d.substring(d.length - n)}';
  }
}
