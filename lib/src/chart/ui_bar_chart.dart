import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:theme/src/chart/chart_utils.dart';
import 'package:theme/src/chart/ui_chart_data.dart';
import 'package:theme/src/foundation/foundation.dart';

/// Bar chart with rounded bars. Pass [bars] for one value per label, or
/// [series] + [labels] for grouped bars. Set [horizontal] for a ranking list.
///
/// ```dart
/// UiBarChart(bars: [UiBarData('Jan', 12), UiBarData('Feb', 18), UiBarData('Mar', 9)])
/// ```
class UiBarChart extends StatefulWidget {
  const UiBarChart({
    super.key,
    this.bars,
    this.series,
    this.labels,
    this.horizontal = false,
    this.height,
    this.showValues = false,
    this.showGrid = true,
    this.showLegend = true,
    this.yFormat,
    this.tickCount = 4,
    this.semanticLabel,
  }) : assert(bars != null || series != null, 'Pass bars or series');

  /// One bar per label.
  final List<UiBarData>? bars;

  /// Grouped bars: one bar per series in each group. Used when [bars] is null.
  final List<UiChartSeries>? series;

  /// Group labels for [series].
  final List<String>? labels;

  /// Bars grow left to right, labels on the left.
  final bool horizontal;

  /// Chart height. Defaults to 220 (vertical) or fits the rows (horizontal).
  final double? height;

  /// Prints each value at the end of its bar.
  final bool showValues;
  final bool showGrid;

  /// Legend under grouped charts.
  final bool showLegend;
  final UiChartFormatter? yFormat;
  final int tickCount;
  final String? semanticLabel;

  @override
  State<UiBarChart> createState() => _UiBarChartState();
}

class _UiBarChartState extends State<UiBarChart> with SingleTickerProviderStateMixin {
  late final UiChartAnimator _anim = UiChartAnimator(this);
  List<List<double>>? _from;
  int? _index;
  bool _pinned = false;

  /// values[group][series]
  List<List<double>> _valuesOf(UiBarChart w) {
    final bars = w.bars;
    if (bars != null) {
      return [
        for (final b in bars) [b.value.toDouble()],
      ];
    }
    final series = w.series!;
    final groups = series.fold<int>(0, (m, s) => math.max(m, s.values.length));
    return [
      for (var g = 0; g < groups; g++) [for (final s in series) g < s.values.length ? s.values[g].toDouble() : 0.0],
    ];
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _anim.start(context);
  }

  @override
  void didUpdateWidget(UiBarChart old) {
    super.didUpdateWidget(old);
    final before = _valuesOf(old);
    final after = _valuesOf(widget);
    final sameShape =
        before.length == after.length &&
        [for (var i = 0; i < before.length; i++) i].every((i) => before[i].length == after[i].length);
    final same = sameShape && [for (var i = 0; i < before.length; i++) i].every((i) => listEquals(before[i], after[i]));
    if (!same) {
      // Morph from the bars on screen, or grow from zero when the shape changed.
      _from = sameShape ? before : null;
      _index = null;
      _anim.run(context);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _point(int? i, {bool pin = false}) {
    if (i == _index && !pin) return;
    setState(() {
      _index = i;
      _pinned = pin && i != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final format = widget.yFormat ?? uiChartFormat;
    final values = _valuesOf(widget);
    final grouped = widget.bars == null;
    final seriesCount = grouped ? widget.series!.length : 1;
    final groupLabels = grouped
        ? [
            for (var g = 0; g < values.length; g++)
              widget.labels != null && g < widget.labels!.length ? widget.labels![g] : '${g + 1}',
          ]
        : [for (final b in widget.bars!) b.label];
    Color colorOf(int g, int s) =>
        grouped ? widget.series![s].color ?? colors.chartColor(s) : widget.bars![g].color ?? colors.chartColor(0);
    final barColors = [
      for (var g = 0; g < values.length; g++) [for (var s = 0; s < seriesCount; s++) colorOf(g, s)],
    ];
    final labelStyle = context.text.labelSmall?.copyWith(
      color: colors.textSubtle,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final valueStyle = labelStyle?.copyWith(color: colors.textMuted, fontWeight: FontWeight.w600);
    final groups = values.length;
    final height =
        widget.height ??
        (widget.horizontal ? math.max(80.0, groups * (seriesCount * 16.0 + (seriesCount - 1) * 3 + 16) + 24) : 220.0);

    final chart = SizedBox(
      height: height,
      child: LayoutBuilder(
        builder: (context, c) {
          final g = _BarGeometry.compute(
            size: Size(c.hasBoundedWidth ? c.maxWidth : 320, height),
            values: values,
            seriesCount: seriesCount,
            labels: groupLabels,
            labelStyle: labelStyle,
            valueStyle: valueStyle,
            format: format,
            tickCount: widget.tickCount,
            horizontal: widget.horizontal,
            showValues: widget.showValues,
          );
          final index = _index != null && _index! < groups ? _index : null;
          return UiChartPointer(
            onPoint: (p) {
              if (groups > 0) _point(g.groupAt(p));
            },
            onTap: (p) {
              if (groups == 0) return;
              final i = g.groupAt(p);
              _point(_pinned && i == _index ? null : i, pin: true);
            },
            onLeave: () => _point(null),
            child: Stack(
              children: [
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _anim.curve,
                    builder: (context, _) {
                      final t = _anim.value;
                      final from = _from;
                      final shown = [
                        for (var i = 0; i < groups; i++)
                          from == null ? [for (final v in values[i]) v * t] : uiChartLerp(from[i], values[i], t),
                      ];
                      return CustomPaint(
                        painter: _BarPainter(
                          geometry: g,
                          values: shown,
                          colors: barColors,
                          grid: widget.showGrid ? colors.border : null,
                          band: colors.surfaceMuted,
                          labelStyle: labelStyle,
                          valueStyle: widget.showValues ? valueStyle : null,
                          format: format,
                          highlight: index,
                        ),
                      );
                    },
                  ),
                ),
                if (groups == 0)
                  Positioned.fromRect(
                    rect: g.plot,
                    child: Center(
                      child: Text('No data', style: context.text.bodySmall?.copyWith(color: colors.textSubtle)),
                    ),
                  ),
                if (index != null)
                  UiChartTooltipOverlay(
                    anchor: g.anchor(index),
                    tooltip: UiChartTooltip(
                      title: groupLabels[index],
                      rows: [
                        for (var s = 0; s < seriesCount; s++)
                          UiChartTooltipRow(
                            grouped ? widget.series![s].name : '',
                            format(values[index][s]),
                            color: barColors[index][s],
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );

    return Semantics(
      label: widget.semanticLabel ?? 'Bar chart, ${groups == 0 ? 'no data' : '$groups bars'}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          chart,
          if (grouped && widget.showLegend && seriesCount > 1) ...[
            const SizedBox(height: UiSpace.md),
            UiChartLegend([
              for (var s = 0; s < seriesCount; s++)
                UiLegendItem(widget.series![s].name, color: widget.series![s].color ?? colors.chartColor(s)),
            ]),
          ],
        ],
      ),
    );
  }
}

class _BarGeometry {
  _BarGeometry({
    required this.plot,
    required this.scale,
    required this.groups,
    required this.seriesCount,
    required this.horizontal,
    required this.labels,
    required this.tickLabels,
    required this.labelEvery,
    required this.categoryWidth,
    required this.values,
  });

  factory _BarGeometry.compute({
    required Size size,
    required List<List<double>> values,
    required int seriesCount,
    required List<String> labels,
    required TextStyle? labelStyle,
    required TextStyle? valueStyle,
    required UiChartFormatter format,
    required int tickCount,
    required bool horizontal,
    required bool showValues,
  }) {
    final all = values.expand((g) => g);
    final lo = all.isEmpty ? 0.0 : all.reduce(math.min);
    final hi = all.isEmpty ? 1.0 : all.reduce(math.max);
    final scale = UiChartScale.nice(lo, hi, count: tickCount);
    final tickLabels = [for (final t in scale.ticks) format(t)];

    double widest(Iterable<String> texts, TextStyle? style) {
      var w = 0.0;
      for (final s in texts) {
        final tp = uiChartText(s, style);
        w = math.max(w, tp.width);
        tp.dispose();
      }
      return w;
    }

    final probe = uiChartText('0', labelStyle);
    final textHeight = probe.height;
    probe.dispose();
    final groups = values.length;
    final valueWidth = showValues ? widest(all.map(format), valueStyle) : 0.0;

    if (horizontal) {
      final categoryWidth = math.min(widest(labels, labelStyle), size.width * 0.35);
      final plot = Rect.fromLTRB(
        categoryWidth + UiSpace.md,
        0,
        math.max(categoryWidth + UiSpace.md + 1, size.width - (showValues ? valueWidth + UiSpace.sm : UiSpace.sm)),
        math.max(1, size.height - textHeight - UiSpace.sm),
      );
      final tickWidth = widest(tickLabels, labelStyle);
      final slot = plot.width / math.max(1, tickLabels.length - 1);
      return _BarGeometry(
        plot: plot,
        scale: scale,
        groups: groups,
        seriesCount: seriesCount,
        horizontal: true,
        labels: labels,
        tickLabels: tickLabels,
        labelEvery: math.max(1, ((tickWidth + UiSpace.md) / slot).ceil()),
        categoryWidth: categoryWidth,
        values: values,
      );
    }

    final left = widest(tickLabels, labelStyle) + UiSpace.sm;
    final top = showValues ? textHeight + UiSpace.xs : textHeight / 2;
    final plot = Rect.fromLTRB(
      left,
      top,
      math.max(left + 1, size.width - UiSpace.xs),
      math.max(top + 1, size.height - textHeight - UiSpace.sm),
    );
    final slot = groups == 0 ? plot.width : plot.width / groups;
    return _BarGeometry(
      plot: plot,
      scale: scale,
      groups: groups,
      seriesCount: seriesCount,
      horizontal: false,
      labels: labels,
      tickLabels: tickLabels,
      labelEvery: math.max(1, ((widest(labels, labelStyle) + UiSpace.sm) / slot).ceil()),
      categoryWidth: 0,
      values: values,
    );
  }

  final Rect plot;
  final UiChartScale scale;
  final int groups;
  final int seriesCount;
  final bool horizontal;
  final List<String> labels;
  final List<String> tickLabels;

  /// Draw every n-th category (vertical) or tick (horizontal) label.
  final int labelEvery;
  final double categoryWidth;
  final List<List<double>> values;

  double get _slot => groups == 0 ? 0 : (horizontal ? plot.height : plot.width) / groups;

  /// Value position along the value axis.
  double pos(double v) =>
      horizontal ? plot.left + scale.norm(v) * plot.width : plot.bottom - scale.norm(v) * plot.height;

  /// Slot of [group] along the category axis.
  Rect band(int group) => horizontal
      ? Rect.fromLTWH(plot.left, plot.top + group * _slot, plot.width, _slot)
      : Rect.fromLTWH(plot.left + group * _slot, plot.top, _slot, plot.height);

  /// Bar rect of [group]/[series] for value [v].
  Rect bar(int group, int series, double v) {
    final slot = _slot;
    final fill = seriesCount == 1 ? 0.62 : 0.78;
    final gap = seriesCount > 1 ? 3.0 : 0.0;
    final maxThick = horizontal ? 22.0 : 44.0;
    final thick = math.max(1.0, math.min(maxThick, (slot * fill - gap * (seriesCount - 1)) / seriesCount));
    final total = thick * seriesCount + gap * (seriesCount - 1);
    final start = group * slot + (slot - total) / 2 + series * (thick + gap);
    final zero = pos(0);
    final end = pos(v);
    return horizontal
        ? Rect.fromLTRB(math.min(zero, end), plot.top + start, math.max(zero, end), plot.top + start + thick)
        : Rect.fromLTRB(plot.left + start, math.min(zero, end), plot.left + start + thick, math.max(zero, end));
  }

  int groupAt(Offset p) {
    if (groups == 0) return 0;
    final d = horizontal ? p.dy - plot.top : p.dx - plot.left;
    return (d / _slot).floor().clamp(0, groups - 1);
  }

  Offset anchor(int group) {
    final b = band(group);
    if (horizontal) {
      var right = plot.left;
      for (var s = 0; s < values[group].length; s++) {
        right = math.max(right, bar(group, s, values[group][s]).right);
      }
      return Offset(right, b.top);
    }
    var top = plot.bottom;
    for (var s = 0; s < values[group].length; s++) {
      top = math.min(top, bar(group, s, values[group][s]).top);
    }
    return Offset(b.center.dx, top);
  }
}

class _BarPainter extends CustomPainter {
  _BarPainter({
    required this.geometry,
    required this.values,
    required this.colors,
    required this.grid,
    required this.band,
    required this.labelStyle,
    required this.valueStyle,
    required this.format,
    required this.highlight,
  });

  final _BarGeometry geometry;
  final List<List<double>> values;
  final List<List<Color>> colors;
  final Color? grid;
  final Color band;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final UiChartFormatter format;
  final int? highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final g = geometry;
    final plot = g.plot;
    final ticks = g.scale.ticks;
    final gridColor = grid;

    // Value axis: grid lines and tick labels.
    for (var i = 0; i < ticks.length; i++) {
      final p = g.pos(ticks[i]).roundToDouble() + 0.5;
      if (gridColor != null) {
        final paint = Paint()
          ..color = gridColor
          ..strokeWidth = 1;
        if (g.horizontal) {
          canvas.drawLine(Offset(p, plot.top), Offset(p, plot.bottom), paint);
        } else {
          canvas.drawLine(Offset(plot.left, p), Offset(plot.right, p), paint);
        }
      }
      if (g.horizontal && i % g.labelEvery != 0) continue;
      final tp = uiChartText(g.tickLabels[i], labelStyle);
      final offset = g.horizontal
          ? Offset((p - tp.width / 2).clamp(0.0, math.max(0.0, size.width - tp.width)), plot.bottom + UiSpace.sm)
          : Offset(plot.left - UiSpace.sm - tp.width, p - tp.height / 2);
      tp.paint(canvas, offset);
      tp.dispose();
    }

    // Highlight band.
    final h = highlight;
    if (h != null && h < g.groups) {
      canvas.drawRRect(RRect.fromRectAndRadius(g.band(h), const Radius.circular(UiRadius.xs)), Paint()..color = band);
    }

    // Category labels.
    for (var i = 0; i < g.groups; i++) {
      if (!g.horizontal && i % g.labelEvery != 0) continue;
      final b = g.band(i);
      if (g.horizontal) {
        final tp = TextPainter(
          text: TextSpan(text: g.labels[i], style: labelStyle),
          textDirection: TextDirection.ltr,
          maxLines: 1,
          ellipsis: '…',
        )..layout(maxWidth: math.max(0, g.categoryWidth));
        tp.paint(canvas, Offset(g.categoryWidth - tp.width, b.center.dy - tp.height / 2));
        tp.dispose();
      } else {
        final tp = uiChartText(g.labels[i], labelStyle);
        final x = (b.center.dx - tp.width / 2).clamp(0.0, math.max(0.0, size.width - tp.width)).toDouble();
        tp.paint(canvas, Offset(x, plot.bottom + UiSpace.sm));
        tp.dispose();
      }
    }

    // Bars.
    for (var i = 0; i < g.groups; i++) {
      for (var s = 0; s < values[i].length; s++) {
        final v = values[i][s];
        final r = g.bar(i, s, v);
        final thick = g.horizontal ? r.height : r.width;
        final radius = Radius.circular(math.min(UiRadius.xs, thick / 2));
        final negative = v < 0;
        final rrect = g.horizontal
            ? RRect.fromRectAndCorners(
                r,
                topRight: negative ? Radius.zero : radius,
                bottomRight: negative ? Radius.zero : radius,
                topLeft: negative ? radius : Radius.zero,
                bottomLeft: negative ? radius : Radius.zero,
              )
            : RRect.fromRectAndCorners(
                r,
                topLeft: negative ? Radius.zero : radius,
                topRight: negative ? Radius.zero : radius,
                bottomLeft: negative ? radius : Radius.zero,
                bottomRight: negative ? radius : Radius.zero,
              );
        final dim = h != null && h != i;
        canvas.drawRRect(rrect, Paint()..color = colors[i][s].withValues(alpha: dim ? 0.45 : 1));

        final vs = valueStyle;
        if (vs != null) {
          final tp = uiChartText(format(g.values[i][s]), vs);
          final offset = g.horizontal
              ? Offset(negative ? r.left - tp.width - UiSpace.xs : r.right + UiSpace.xs, r.center.dy - tp.height / 2)
              : Offset(r.center.dx - tp.width / 2, negative ? r.bottom + UiSpace.xxs : r.top - tp.height - UiSpace.xxs);
          tp.paint(canvas, offset);
          tp.dispose();
        }
      }
    }

    // Zero line.
    if (gridColor != null && g.scale.min < 0) {
      final z = g.pos(0).roundToDouble() + 0.5;
      final paint = Paint()
        ..color = gridColor
        ..strokeWidth = 1.5;
      if (g.horizontal) {
        canvas.drawLine(Offset(z, plot.top), Offset(z, plot.bottom), paint);
      } else {
        canvas.drawLine(Offset(plot.left, z), Offset(plot.right, z), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_BarPainter old) => true;
}
