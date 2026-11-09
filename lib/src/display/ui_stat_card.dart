import 'package:flutter/material.dart';

import 'package:theme/src/display/ui_card.dart';
import 'package:theme/src/display/ui_list.dart';
import 'package:theme/src/foundation/foundation.dart';

/// Direction of a [UiStatCard] change.
enum UiTrend { up, down, neutral }

/// A KPI card: label, big value, and an auto-colored change.
///
/// ```dart
/// UiStatCard(label: 'Revenue', value: '\$12.4k', delta: 8.2, deltaLabel: 'vs last week')
/// ```
class UiStatCard extends StatelessWidget {
  const UiStatCard({
    super.key,
    required this.label,
    required this.value,
    this.delta,
    this.deltaLabel,
    this.deltaUnit = '%',
    this.icon,
    this.iconStatus = UiStatus.accent,
    this.trend,
    this.invertColors = false,
    this.footer,
    this.onTap,
    this.variant = UiCardVariant.outlined,
  });

  final String label;
  final String value;

  /// Change shown as `+8.2%`. Its sign picks the [trend] when [trend] is null.
  final num? delta;

  /// Muted text after the change, e.g. "vs last week".
  final String? deltaLabel;

  /// Unit after [delta]. Defaults to `%`.
  final String deltaUnit;
  final IconData? icon;
  final UiStatus iconStatus;

  /// Overrides the trend picked from [delta].
  final UiTrend? trend;

  /// Use when "down" is good (costs, errors, latency).
  final bool invertColors;

  /// Extra content under the value (sparkline, progress).
  final Widget? footer;
  final VoidCallback? onTap;
  final UiCardVariant variant;

  /// Trend that [delta] implies.
  static UiTrend trendOf(num? delta) => delta == null || delta == 0
      ? UiTrend.neutral
      : delta > 0
      ? UiTrend.up
      : UiTrend.down;

  /// Delta text with sign: `+8.2%`, `-3%`, `0%`.
  static String formatDelta(num delta, [String unit = '%']) {
    final abs = delta.abs();
    final s = abs == abs.roundToDouble() ? abs.round().toString() : abs.toStringAsFixed(1);
    final sign = delta > 0
        ? '+'
        : delta < 0
        ? '-'
        : '';
    return '$sign$s$unit';
  }

  /// Status color of a trend.
  static UiStatus statusOf(UiTrend trend, {bool invert = false}) => switch (trend) {
    UiTrend.up => invert ? UiStatus.danger : UiStatus.success,
    UiTrend.down => invert ? UiStatus.success : UiStatus.danger,
    UiTrend.neutral => UiStatus.neutral,
  };

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final t = trend ?? trendOf(delta);
    final status = statusOf(t, invert: invertColors);
    final tone = colors.tone(status);
    final deltaFg = status == UiStatus.neutral ? colors.textMuted : tone.onSoft;

    return UiCard(
      onTap: onTap,
      variant: variant,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.bodyMedium?.copyWith(color: colors.textMuted, fontWeight: FontWeight.w500),
                ),
              ),
              if (icon != null) ...[const SizedBox(width: UiSpace.sm), UiIconBox(icon!, status: iconStatus, size: 28)],
            ],
          ),
          const SizedBox(height: UiSpace.sm),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: text.headlineMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
            ),
          ),
          if (delta != null || deltaLabel != null) ...[
            const SizedBox(height: UiSpace.sm),
            Row(
              children: [
                if (delta != null)
                  Container(
                    key: const ValueKey('ui-stat-delta'),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: tone.soft, borderRadius: UiRadius.all(UiRadius.full)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          switch (t) {
                            UiTrend.up => Icons.arrow_upward_rounded,
                            UiTrend.down => Icons.arrow_downward_rounded,
                            UiTrend.neutral => Icons.remove_rounded,
                          },
                          size: 12,
                          color: deltaFg,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          formatDelta(delta!, deltaUnit),
                          style: text.labelMedium?.copyWith(color: deltaFg, height: 1.2),
                        ),
                      ],
                    ),
                  ),
                if (delta != null && deltaLabel != null) const SizedBox(width: UiSpace.sm),
                if (deltaLabel != null)
                  Flexible(
                    child: Text(
                      deltaLabel!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(color: colors.textSubtle),
                    ),
                  ),
              ],
            ),
          ],
          if (footer != null) ...[const SizedBox(height: UiSpace.md), footer!],
        ],
      ),
    );
  }
}
