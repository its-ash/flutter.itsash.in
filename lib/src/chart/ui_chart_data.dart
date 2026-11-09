import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Formats a chart value for labels and tooltips.
typedef UiChartFormatter = String Function(num value);

/// A named list of values for [UiLineChart] and grouped [UiBarChart].
class UiChartSeries {
  const UiChartSeries(this.name, this.values, {this.color});

  final String name;
  final List<num> values;

  /// Defaults to `colors.chartColor(index)`.
  final Color? color;
}

/// One bar of a simple [UiBarChart].
class UiBarData {
  const UiBarData(this.label, this.value, {this.color});

  final String label;
  final num value;

  /// Defaults to the first chart color.
  final Color? color;
}

/// One slice of a [UiDonutChart].
class UiChartSegment {
  const UiChartSegment(this.label, this.value, {this.color});

  final String label;
  final num value;

  /// Defaults to `colors.chartColor(index)`.
  final Color? color;
}

/// One entry of a [UiChartLegend].
class UiLegendItem {
  const UiLegendItem(this.label, {required this.color, this.value});

  final String label;
  final Color color;

  /// Optional value shown after the label.
  final String? value;
}

/// Wrapping row of colored dots with labels (and optional values).
///
/// ```dart
/// UiChartLegend([UiLegendItem('Revenue', color: c.chartColor(0)), UiLegendItem('Costs', color: c.chartColor(1))])
/// ```
class UiChartLegend extends StatelessWidget {
  const UiChartLegend(this.items, {super.key, this.alignment = WrapAlignment.start, this.selected});

  final List<UiLegendItem> items;
  final WrapAlignment alignment;

  /// Highlights one item and dims the rest.
  final int? selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final label = context.text.labelMedium?.copyWith(color: colors.textMuted, fontWeight: FontWeight.w500);
    final value = context.text.labelMedium?.copyWith(
      color: colors.text,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final duration = context.motion(UiMotion.fast);
    return Wrap(
      alignment: alignment,
      spacing: UiSpace.lg,
      runSpacing: UiSpace.xs + 2,
      children: [
        for (var i = 0; i < items.length; i++)
          AnimatedOpacity(
            duration: duration,
            opacity: selected == null || selected == i ? 1 : 0.4,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(color: items[i].color, borderRadius: UiRadius.all(3)),
                  child: const SizedBox.square(dimension: 10),
                ),
                const SizedBox(width: UiSpace.xs + 2),
                Flexible(
                  child: Text(items[i].label, maxLines: 1, overflow: TextOverflow.ellipsis, style: label),
                ),
                if (items[i].value != null) ...[
                  const SizedBox(width: UiSpace.xs + 2),
                  Text(items[i].value!, style: value),
                ],
              ],
            ),
          ),
      ],
    );
  }
}
