import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/ui_money.dart';

class UiCurrencyInput extends StatefulWidget {
  const UiCurrencyInput({
    super.key,
    this.initial,
    this.symbol,
    this.decimals = 2,
    this.max,
    this.onChanged,
    this.hint,
    this.maxLabel = 'Maximum',
    this.keypad = true,
  });

  final double? initial;
  final String? symbol;
  final int decimals;
  final double? max;
  final ValueChanged<double>? onChanged;
  final String? hint;
  final String maxLabel;
  final bool keypad;

  @override
  State<UiCurrencyInput> createState() => _UiCurrencyInputState();
}

class _UiCurrencyInputState extends State<UiCurrencyInput> {
  static const _maxInt = 9;
  late String _buf = _seed();
  bool _over = false;

  int get _dec => widget.decimals.clamp(0, 4);

  String _seed() {
    final v = widget.initial;
    if (v == null || !v.isFinite || v <= 0) return '';
    final m = widget.max;
    final c = m != null && m.isFinite && m >= 0 && v > m ? m : v;
    final s = c.toStringAsFixed(_dec);
    return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
  }

  double get value => double.tryParse(_buf) ?? 0;

  bool _valid(String s) {
    if (s.isEmpty) return true;
    final parts = s.split('.');
    if (parts.length > 2 || parts.first.length > _maxInt) return false;
    if (parts.length == 2 && (_dec == 0 || parts[1].length > _dec)) return false;
    final m = widget.max;
    if (m != null && m.isFinite && (double.tryParse(s) ?? 0) > m) return false;
    return true;
  }

  void _press(String k) {
    final next = switch (k) {
      '<' => _buf.isEmpty ? _buf : _buf.substring(0, _buf.length - 1),
      '.' => _buf.contains('.') || _dec == 0 ? null : (_buf.isEmpty ? '0.' : '$_buf.'),
      _ => _buf == '0' ? k : '$_buf$k',
    };
    if (next == null) return;
    if (!_valid(next)) {
      HapticFeedback.heavyImpact();
      final m = widget.max;
      setState(() => _over = m != null && (double.tryParse(next) ?? 0) > m);
      return;
    }
    HapticFeedback.selectionClick();
    final changed = next != _buf;
    setState(() {
      _buf = next;
      _over = false;
    });
    if (changed) widget.onChanged?.call(value);
  }

  void _clear() {
    if (_buf.isEmpty) return;
    HapticFeedback.mediumImpact();
    setState(() {
      _buf = '';
      _over = false;
    });
    widget.onChanged?.call(0);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final sym = widget.symbol ?? UiMoney.symbol;
    final parts = _buf.split('.');
    final shown = _buf.isEmpty
        ? '0'
        : '${UiFormat.number(int.tryParse(parts.first) ?? 0)}${parts.length > 1 ? '.${parts[1]}' : ''}';
    final color = _over ? cs.error : (_buf.isEmpty ? cs.onSurfaceVariant.withValues(alpha: 0.6) : cs.onSurface);
    final m = widget.max;
    final hint = _over && m != null
        ? '${widget.maxLabel} ${UiMoney.format(m, symbol: sym, decimals: _dec)}'
        : widget.hint;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: 'Amount',
          value: '$sym$shown',
          liveRegion: true,
          child: ExcludeSemantics(
            child: SizedBox(
              height: 72,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: UiSpace.sm),
                      child: Text(
                        sym,
                        style: context.text.headlineSmall?.copyWith(color: color, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(width: UiSpace.xs),
                    AnimatedDefaultTextStyle(
                      duration: UiDuration.fast,
                      style: (context.text.displayMedium ?? const TextStyle(fontSize: 45)).copyWith(
                        color: color,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      child: Text(shown),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 24,
          child: hint == null
              ? null
              : Text(
                  hint,
                  style: context.text.bodySmall?.copyWith(
                    color: _over ? cs.error : cs.onSurfaceVariant,
                    fontWeight: _over ? FontWeight.w700 : null,
                  ),
                ),
        ),
        if (widget.keypad) ...[
          const UiGap.md(),
          for (final row in [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
            [_dec > 0 ? '.' : '', '0', '<'],
          ])
            Row(
              children: [
                for (final k in row)
                  Expanded(
                    child: k.isEmpty
                        ? const SizedBox(height: 64)
                        : _Key(
                            label: k,
                            onTap: () => _press(k),
                            onLongPress: k == '<' ? _clear : null,
                          ),
                  ),
              ],
            ),
        ],
      ],
    );
  }
}

class _Key extends StatelessWidget {
  const _Key({required this.label, required this.onTap, this.onLongPress});

  final String label;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final back = label == '<';
    return Semantics(
      button: true,
      label: back ? 'Delete' : (label == '.' ? 'Decimal point' : label),
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.all(UiSpace.xs),
          child: Material(
            color: Colors.transparent,
            borderRadius: context.tokens.lg,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onTap,
              onLongPress: onLongPress,
              child: SizedBox(
                height: 56,
                child: Center(
                  child: back
                      ? Icon(Icons.backspace_outlined, color: context.colors.onSurface)
                      : Text(label, style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
