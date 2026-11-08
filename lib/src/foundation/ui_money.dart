import 'package:theme/src/foundation/ui_format.dart';

enum UiSymbolPosition { before, after }

abstract final class UiMoney {
  static String symbol = '\$';
  static int decimals = 2;
  static UiSymbolPosition position = UiSymbolPosition.before;
  static String groupSeparator = ',';
  static String decimalSeparator = '.';
  static final Map<String, String> names = {
    '\$': 'dollars',
    'US\$': 'dollars',
    '€': 'euros',
    '£': 'pounds',
    '₹': 'rupees',
    '¥': 'yen',
    '₩': 'won',
    'R\$': 'reais',
    '₺': 'lira',
    '₦': 'naira',
  };

  static final _nonZero = RegExp('[1-9]');

  static double safe(num? value) => value == null || !value.isFinite ? 0 : value.toDouble();

  static String _number(double v, int decimals, bool trimZeros) {
    final d = decimals.clamp(0, 6);
    final s = UiFormat.number(v, decimals: d, group: groupSeparator, point: decimalSeparator);
    return trimZeros && d > 0 && !_nonZero.hasMatch(s.split(decimalSeparator).last)
        ? UiFormat.number(v, group: groupSeparator, point: decimalSeparator)
        : s;
  }

  static String format(
    num? amount, {
    String? symbol,
    int? decimals,
    UiSymbolPosition? position,
    bool compact = false,
    bool trimZeros = false,
    bool sign = false,
  }) {
    final v = safe(amount);
    final s = symbol ?? UiMoney.symbol;
    final a = v.abs();
    final body = compact && a >= 1000
        ? UiFormat.compact(a).replaceFirst('.', decimalSeparator)
        : _number(a, decimals ?? UiMoney.decimals, trimZeros);
    final out = (position ?? UiMoney.position) == UiSymbolPosition.before ? '$s$body' : '$body $s';
    if (!_nonZero.hasMatch(body)) return out;
    return v < 0 ? '-$out' : (sign ? '+$out' : out);
  }

  static String spoken(num? amount, {String? symbol, int? decimals}) {
    final s = (symbol ?? UiMoney.symbol).trim();
    return '${_number(safe(amount), decimals ?? UiMoney.decimals, true)} ${names[s] ?? s}';
  }

  static int? discountPercent(num? price, num? compareAt) {
    final p = safe(price);
    final c = safe(compareAt);
    if (p < 0 || c <= 0 || c <= p) return null;
    final pct = ((c - p) / c * 100).round();
    return pct > 0 ? pct : null;
  }
}
