import 'package:flutter/material.dart';

import 'package:theme/src/display/ui_charts.dart';
import 'package:theme/src/foundation/ui_money.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiSpendItem {
  const UiSpendItem(this.label, this.value, {this.color, this.icon});

  final String label;
  final double value;
  final Color? color;
  final IconData? icon;
}

class UiSpendingBreakdown extends StatelessWidget {
  const UiSpendingBreakdown({
    super.key,
    required this.items,
    this.symbol,
    this.centerLabel = 'Total',
    this.emptyLabel = 'No spending yet',
    this.size = 180,
    this.stroke = 22,
    this.legend = true,
  });

  final List<UiSpendItem> items;
  final String? symbol;
  final String centerLabel;
  final String emptyLabel;
  final double size;
  final double stroke;
  final bool legend;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final p = context.palette;
    final defaults = [cs.primary, cs.tertiary, cs.secondary, p.info, p.warning, p.success, cs.error];
    final vals = [for (final i in items) i.value.isFinite && i.value > 0 ? i.value : 0.0];
    final total = vals.fold(0.0, (a, b) => a + b);
    final colors = [for (var i = 0; i < items.length; i++) items[i].color ?? defaults[i % defaults.length]];
    final dim = size.clamp(80.0, 400.0);
    final sw = stroke.clamp(4.0, dim / 4);
    String pct(double v) => total == 0 ? '0%' : '${(v / total * 100).toStringAsFixed(v / total < 0.1 && v > 0 ? 1 : 0)}%';

    final chart = Semantics(
      label: total == 0
          ? emptyLabel
          : 'Spending ${UiMoney.format(total, symbol: symbol)}: ${[for (var i = 0; i < items.length; i++) '${items[i].label} ${pct(vals[i])}'].join(', ')}',
      excludeSemantics: true,
      child: UiDonutChart(
        [for (var i = 0; i < items.length; i++) UiChartSegment(items[i].label, vals[i], color: colors[i])],
        size: dim,
        thickness: sw,
        legend: false,
        center: Column(
          mainAxisSize: MainAxisSize.min,
          children: total == 0
              ? [
                  Text(
                    emptyLabel,
                    textAlign: TextAlign.center,
                    style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ]
              : [
                  Text(centerLabel, style: context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                  Text(
                    UiMoney.format(total, symbol: symbol, compact: total >= 100000),
                    style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
        ),
      ),
    );

    if (!legend || items.isEmpty) return Center(child: chart);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: chart),
        const UiGap.xl(),
        for (var i = 0; i < items.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: UiSpace.xs + 2),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(color: colors[i].withValues(alpha: 0.16), borderRadius: context.tokens.xs),
                  child: items[i].icon == null
                      ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle),
                          ),
                        )
                      : Icon(items[i].icon, size: 16, color: colors[i]),
                ),
                const UiGap.md(),
                Expanded(
                  child: Text(
                    items[i].label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                Text(
                  UiMoney.format(vals[i], symbol: symbol),
                  style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    pct(vals[i]),
                    textAlign: TextAlign.end,
                    style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
