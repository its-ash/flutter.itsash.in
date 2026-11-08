import 'package:flutter/material.dart';

import 'package:theme/src/display/ui_charts.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';

class UiDelta extends StatelessWidget {
  const UiDelta(this.value, {super.key, this.invert = false, this.suffix = '%', this.solid = false});

  final double value;
  final bool invert;
  final String suffix;
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final v = value.isFinite ? value : 0.0;
    final good = invert ? v < 0 : v > 0;
    final status = v == 0 ? UiStatus.neutral : (good ? UiStatus.success : UiStatus.danger);
    final t = context.tone(status);
    final icon = v == 0 ? Icons.remove_rounded : (v > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded);
    final a = v.abs();
    final txt = '${v > 0 ? '+' : v < 0 ? '-' : ''}${a >= 100 || a == a.roundToDouble() ? a.toStringAsFixed(0) : a.toStringAsFixed(1)}$suffix';
    final fg = solid ? t.onContainer : t.color;
    return Semantics(
      label: '${v > 0 ? 'Up' : v < 0 ? 'Down' : 'No change'} $txt',
      child: ExcludeSemantics(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm - 2, vertical: UiSpace.xxs),
          decoration: BoxDecoration(color: solid ? t.container : t.color.withValues(alpha: 0.12), borderRadius: context.tokens.full),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: fg),
              const SizedBox(width: 2),
              Text(txt, style: context.text.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}

class UiStatCard extends StatelessWidget {
  const UiStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.delta,
    this.invertDelta = false,
    this.caption,
    this.sparkline,
    this.status,
    this.onTap,
    this.variant = UiCardVariant.filled,
  });

  final String label;
  final String value;
  final IconData? icon;
  final double? delta;
  final bool invertDelta;
  final String? caption;
  final List<double>? sparkline;
  final UiStatus? status;
  final VoidCallback? onTap;
  final UiCardVariant variant;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final t = status == null ? null : context.tone(status!);
    final iconBg = t?.container ?? cs.primaryContainer;
    final iconFg = t?.onContainer ?? cs.onPrimaryContainer;
    final d = delta;
    final lineColor = d == null || d == 0
        ? (t?.color ?? cs.primary)
        : ((invertDelta ? d < 0 : d > 0) ? context.palette.success : cs.error);
    final spark = sparkline;
    return Semantics(
      container: true,
      child: UiCard(
        variant: variant,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(color: iconBg, borderRadius: context.tokens.sm),
                    child: Icon(icon, size: 20, color: iconFg),
                  )
                else
                  Expanded(
                    child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
                  ),
                if (icon != null) const Spacer(),
                if (d != null) ...[const UiGap.sm(), UiDelta(d, invert: invertDelta)],
              ],
            ),
            const UiGap.md(),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(value, maxLines: 1, style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
            ),
            if (icon != null) ...[
              const SizedBox(height: UiSpace.xxs),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
            ],
            if (caption != null) ...[
              const SizedBox(height: UiSpace.xxs),
              Text(caption!, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ],
            if (spark != null && spark.isNotEmpty) ...[
              const UiGap.md(),
              ExcludeSemantics(child: UiSparkline(spark, color: lineColor, height: 36)),
            ],
          ],
        ),
      ),
    );
  }
}
