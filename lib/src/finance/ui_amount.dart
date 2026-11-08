import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/ui_money.dart';

class UiAmount extends StatelessWidget {
  const UiAmount(
    this.value, {
    super.key,
    this.symbol,
    this.decimals,
    this.compact = false,
    this.masked = false,
    this.signed = true,
    this.colored = true,
    this.negativeAsDanger = false,
    this.strike = false,
    this.splitDecimals = false,
    this.style,
  });

  final num value;
  final String? symbol;
  final int? decimals;
  final bool compact;
  final bool masked;
  final bool signed;
  final bool colored;
  final bool negativeAsDanger;
  final bool strike;
  final bool splitDecimals;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final base = (style ?? context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700) ?? const TextStyle())
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    final v = value.isFinite ? value : 0;
    final color = masked || !colored
        ? base.color
        : v > 0 && signed
            ? context.palette.success
            : v < 0 && negativeAsDanger
                ? cs.error
                : base.color;
    final s = base.copyWith(color: color, decoration: strike ? TextDecoration.lineThrough : null);
    final text = masked
        ? '${symbol ?? UiMoney.symbol}${UiFormat.mask}'
        : UiMoney.format(v, symbol: symbol, decimals: decimals, compact: compact, sign: signed);
    final semantics = masked ? 'Amount hidden' : (text.startsWith('-') ? 'minus ${text.substring(1)}' : text);

    final dot = text.lastIndexOf(UiMoney.decimalSeparator);
    if (!splitDecimals || masked || compact || dot < 0) {
      return Text(text, style: s, maxLines: 1, overflow: TextOverflow.ellipsis, semanticsLabel: semantics);
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, dot)),
          TextSpan(
            text: text.substring(dot),
            style: TextStyle(fontSize: (s.fontSize ?? 16) * 0.6, color: (color ?? DefaultTextStyle.of(context).style.color ?? cs.onSurface).withValues(alpha: 0.75)),
          ),
        ],
      ),
      style: s,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      semanticsLabel: semantics,
    );
  }
}
