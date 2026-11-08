import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_money.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiPrice extends StatelessWidget {
  const UiPrice(
    this.amount, {
    super.key,
    this.compareAt,
    this.size = UiSize.md,
    this.symbol,
    this.decimals,
    this.showDiscount = true,
    this.color,
    this.suffix,
  });

  final num amount;
  final num? compareAt;
  final UiSize size;
  final String? symbol;
  final int? decimals;
  final bool showDiscount;
  final Color? color;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final sale = context.palette.sale;
    final a = math.max(0.0, UiMoney.safe(amount));
    final pct = UiMoney.discountPercent(a, compareAt);
    final was = pct == null ? null : UiMoney.safe(compareAt);
    final (main, sub) = switch (size) {
      UiSize.sm => (context.text.titleSmall, context.text.labelSmall),
      UiSize.md => (context.text.titleMedium, context.text.labelMedium),
      UiSize.lg => (context.text.headlineSmall, context.text.bodyMedium),
    };
    String f(num v) => UiMoney.format(v, symbol: symbol, decimals: decimals);
    final label = StringBuffer('Price ${UiMoney.spoken(a, symbol: symbol, decimals: decimals)}');
    if (suffix != null) label.write(' $suffix');
    if (was != null) label.write(', was ${UiMoney.spoken(was, symbol: symbol, decimals: decimals)}, $pct percent off');
    const tabular = [FontFeature.tabularFigures()];

    return Semantics(
      label: label.toString(),
      excludeSemantics: true,
      child: Wrap(
        spacing: UiSpace.sm - 2,
        runSpacing: UiSpace.xxs,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              text: f(a),
              children: [
                if (suffix != null)
                  TextSpan(text: suffix, style: sub?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w500)),
              ],
            ),
            style: main?.copyWith(
              fontWeight: FontWeight.w800,
              color: color ?? (pct != null ? sale : cs.onSurface),
              fontFeatures: tabular,
            ),
          ),
          if (was != null)
            Text(
              f(was),
              style: sub?.copyWith(
                color: cs.onSurfaceVariant,
                decoration: TextDecoration.lineThrough,
                decorationColor: cs.onSurfaceVariant,
                fontFeatures: tabular,
              ),
            ),
          if (pct != null && showDiscount)
            Text('$pct% off', style: sub?.copyWith(color: sale, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class UiDiscountBadge extends StatelessWidget {
  const UiDiscountBadge(this.label, {super.key, this.status, this.color, this.size = UiSize.sm});

  UiDiscountBadge.percent(num percent, {super.key, this.status, this.color, this.size = UiSize.sm})
      : label = '-${UiMoney.safe(percent).abs().round()}%';

  final String label;
  final UiStatus? status;
  final Color? color;
  final UiSize size;

  @override
  Widget build(BuildContext context) {
    final tone = status == null ? null : context.tone(status!);
    final bg = color ?? tone?.color ?? context.palette.sale;
    final fg = color == null && tone != null
        ? tone.onColor
        : ThemeData.estimateBrightnessForColor(bg) == Brightness.dark
            ? Colors.white
            : Colors.black;
    final (h, v, fs) = switch (size) {
      UiSize.sm => (7.0, 3.0, 11.0),
      UiSize.md => (9.0, 4.0, 12.0),
      UiSize.lg => (11.0, 5.0, 14.0),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: h, vertical: v),
      decoration: BoxDecoration(color: bg, borderRadius: context.tokens.xs),
      child: Text(
        label,
        maxLines: 1,
        style: context.text.labelSmall?.copyWith(color: fg, fontSize: fs, fontWeight: FontWeight.w800, letterSpacing: 0.3),
      ),
    );
  }
}

class UiStockIndicator extends StatelessWidget {
  const UiStockIndicator(
    this.stock, {
    super.key,
    this.lowThreshold = 5,
    this.inStockLabel = 'In stock',
    this.outOfStockLabel = 'Out of stock',
  });

  final int stock;
  final int lowThreshold;
  final String inStockLabel;
  final String outOfStockLabel;

  @override
  Widget build(BuildContext context) {
    final (status, text) = switch (stock) {
      <= 0 => (UiStatus.danger, outOfStockLabel),
      final n when n <= lowThreshold => (UiStatus.warning, 'Only $n left'),
      _ => (UiStatus.success, inStockLabel),
    };
    final c = context.tone(status).color;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
        const UiGap(6),
        Text(text, style: context.text.labelMedium?.copyWith(color: c, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
