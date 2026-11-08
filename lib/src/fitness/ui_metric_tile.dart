import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';

class UiMetricTile extends StatelessWidget {
  const UiMetricTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.unit,
    this.trend,
    this.trendUpIsGood = true,
    this.color,
    this.tonal = false,
    this.onTap,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? unit;
  final double? trend;
  final bool trendUpIsGood;
  final Color? color;
  final bool tonal;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final accent = color ?? cs.primary;
    final t = trend?.isFinite == true ? trend : null;
    final trendColor = t == null || t == 0
        ? cs.onSurfaceVariant
        : ((t > 0) == trendUpIsGood ? context.palette.success : cs.error);

    return Semantics(
      label: '$label $value${unit == null ? '' : ' $unit'}',
      container: true,
      child: UiCard(
        onTap: onTap,
        color: tonal ? Color.alphaBlend(accent.withValues(alpha: context.isDark ? 0.18 : 0.1), cs.surface) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: accent.withValues(alpha: 0.16), borderRadius: context.tokens.sm),
                  child: Icon(icon, size: 20, color: accent),
                ),
                const Spacer(),
                if (t != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        t > 0 ? Icons.arrow_upward_rounded : (t < 0 ? Icons.arrow_downward_rounded : Icons.remove_rounded),
                        size: 14,
                        color: trendColor,
                      ),
                      Text(
                        '${t.abs().toStringAsFixed(t.abs() < 10 ? 1 : 0)}%',
                        style: context.text.labelMedium?.copyWith(color: trendColor, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
              ],
            ),
            const UiGap.md(),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: value, style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                  if (unit != null)
                    TextSpan(
                      text: ' $unit',
                      style: context.text.labelLarge?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const UiGap.xs(),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
