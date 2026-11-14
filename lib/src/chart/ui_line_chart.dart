import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:theme/src/chart/chart_utils.dart';
import 'package:theme/src/chart/ui_chart_data.dart';
import 'package:theme/src/foundation/foundation.dart';

/// Multi-series line or area chart with y-axis ticks, x labels and a touch
/// tooltip that lists every series at the touched point.
///
/// ```dart
/// UiLineChart(series: [UiChartSeries('Visits', [12, 18, 15, 24, 30])], labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'])
/// ```
class UiLineChart extends StatefulWidget {
  const UiLineChart({
    super.key,
    required this.series,
    this.labels,
    this.height = 220,
    this.curved = true,
    this.area = true,
    this.showGrid = true,
    this.showLegend = true,
    this.yFormat,
    this.tickCount = 4,
    this.animateUpdates = true,
    this.semanticLabel,
  });

  final List<UiChartSeries> series;

  /// X-axis labels, one per point. Crowded labels are thinned out.
  final List<String>? labels;

  /// Height of the plot (legend not included).
  final double height;

  /// Smooth monotone curves instead of straight segments.
  final bool curved;

  /// Fills a fading gradient under each line.
  final bool area;
  final bool showGrid;

  /// Shows a legend under the chart when there are two or more series.
  final bool showLegend;

  /// Formats y-axis ticks and tooltip values. Defaults to compact numbers.
  final UiChartFormatter? yFormat;

  /// Approximate number of y-axis intervals.
  final int tickCount;

  /// Animates data changes (redraw or morph). Set false for live data that
  /// changes every second: the chart animates in once, then repaints in place.
  final bool animateUpdates;
  final String? semanticLabel;

  @override
  State<UiLineChart> createState() => _UiLineChartState();
}

class _UiLineChartState extends State<UiLineChart> with SingleTickerProviderStateMixin {
  late final UiChartAnimator _anim = UiChartAnimator(this);
  List<List<double>>? _from;
  int? _index;
  bool _pinned = false;

  List<List<double>> _valuesOf(List<UiChartSeries> series) => [
    for (final s in series) [for (final v in s.values) v.toDouble()],
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _anim.start(context);
  }

  @override
  void didUpdateWidget(UiLineChart old) {
    super.didUpdateWidget(old);
    final before = _valuesOf(old.series);
    final after = _valuesOf(widget.series);
    final same =
        before.length == after.length &&
        [for (var i = 0; i < before.length; i++) i].every((i) => listEquals(before[i], after[i]));
    if (!same && !widget.animateUpdates) {
      // Live data: show the new values at once. Finishes a running enter animation too.
      _from = null;
      _anim.controller.value = 1;
    } else if (!same) {
      final sameShape =
          before.length == after.length &&
          [for (var i = 0; i < before.length; i++) i].every((i) => before[i].length == after[i].length);
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
    final values = _valuesOf(widget.series);
    final seriesColors = [
      for (var i = 0; i < widget.series.length; i++) widget.series[i].color ?? colors.chartColor(i),
    ];
    final n = values.fold<int>(0, (m, s) => math.max(m, s.length));
    final labelStyle = context.text.labelSmall?.copyWith(
      color: colors.textSubtle,
      fontWeight: FontWeight.w500,
      letterSpacing: 0,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    final chart = SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, c) {
          final g = _LineGeometry.compute(
            size: Size(c.hasBoundedWidth ? c.maxWidth : 320, widget.height),
            values: values,
            count: n,
            labels: widget.labels,
            labelStyle: labelStyle,
            format: format,
            tickCount: widget.tickCount,
          );
          final index = _index != null && _index! < n ? _index : null;
          return UiChartPointer(
            onPoint: (p) {
              if (n > 0) _point(g.indexAt(p));
            },
            onTap: (p) {
              if (n == 0) return;
              final i = g.indexAt(p);
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
                      final morph = _from != null;
                      return CustomPaint(
                        painter: _LinePainter(
                          geometry: g,
                          values: [
                            for (var s = 0; s < values.length; s++)
                              morph ? uiChartLerp(_from![s], values[s], t) : values[s],
                          ],
                          reveal: morph ? 1 : t,
                          colors: seriesColors,
                          grid: widget.showGrid ? colors.border : null,
                          surface: colors.surface,
                          guide: colors.borderStrong,
                          labelStyle: labelStyle,
                          curved: widget.curved,
                          area: widget.area,
                          highlight: index,
                        ),
                      );
                    },
                  ),
                ),
                if (n == 0)
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
                      title: widget.labels != null && index < widget.labels!.length
                          ? widget.labels![index]
                          : 'Point ${index + 1}',
                      rows: [
                        for (var s = 0; s < widget.series.length; s++)
                          if (index < values[s].length)
                            UiChartTooltipRow(widget.series[s].name, format(values[s][index]), color: seriesColors[s]),
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
      label: widget.semanticLabel ?? 'Line chart, ${widget.series.length} series, ${n == 0 ? 'no data' : '$n points'}',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          chart,
          if (widget.showLegend && widget.series.length > 1) ...[
            const SizedBox(height: UiSpace.md),
            UiChartLegend([
              for (var i = 0; i < widget.series.length; i++)
                UiLegendItem(widget.series[i].name, color: seriesColors[i]),
            ]),
          ],
        ],
      ),
    );
  }
}

class _LineGeometry {
  _LineGeometry({
    required this.size,
    required this.plot,
    required this.scale,
    required this.count,
    required this.values,
    required this.yLabels,
    required this.xLabels,
    required this.labelEvery,
  });

  factory _LineGeometry.compute({
    required Size size,
    required List<List<double>> values,
    required int count,
    required List<String>? labels,
    required TextStyle? labelStyle,
    required UiChartFormatter format,
    required int tickCount,
  }) {
    final all = values.expand((s) => s);
    final lo = all.isEmpty ? 0.0 : all.reduce(math.min);
    final hi = all.isEmpty ? 1.0 : all.reduce(math.max);
    final scale = UiChartScale.nice(lo, hi, count: tickCount, includeZero: lo <= hi * 0.5);
    final yLabels = [for (final t in scale.ticks) format(t)];

    var leftWidth = 0.0;
    var labelHeight = 12.0;
    for (final l in yLabels) {
      final tp = uiChartText(l, labelStyle);
      leftWidth = math.max(leftWidth, tp.width);
      labelHeight = tp.height;
      tp.dispose();
    }
    final xLabels = labels == null || labels.isEmpty ? null : labels.take(count).toList();
    final bottom = xLabels == null ? labelHeight / 2 : labelHeight + UiSpace.sm;
    final plot = Rect.fromLTRB(
      leftWidth + UiSpace.sm,
      labelHeight / 2,
      math.max(leftWidth + UiSpace.sm + 1, size.width - UiSpace.xs - 1),
      math.max(labelHeight / 2 + 1, size.height - bottom),
    );

    var every = 1;
    if (xLabels != null && count > 1) {
      var widest = 0.0;
      for (final l in xLabels) {
        final tp = uiChartText(l, labelStyle);
        widest = math.max(widest, tp.width);
        tp.dispose();
      }
      final slot = plot.width / (count - 1);
      every = math.max(1, ((widest + UiSpace.md) / slot).ceil());
    }
    return _LineGeometry(
      size: size,
      plot: plot,
      scale: scale,
      count: count,
      values: values,
      yLabels: yLabels,
      xLabels: xLabels,
      labelEvery: every,
    );
  }

  final Size size;
  final Rect plot;
  final UiChartScale scale;
  final int count;
  final List<List<double>> values;
  final List<String> yLabels;
  final List<String>? xLabels;
  final int labelEvery;

  double x(int i) => count <= 1 ? plot.center.dx : plot.left + plot.width * i / (count - 1);

  double y(double v) => plot.bottom - scale.norm(v) * plot.height;

  int indexAt(Offset p) {
    if (count <= 1) return 0;
    return ((p.dx - plot.left) / plot.width * (count - 1)).round().clamp(0, count - 1);
  }

  Offset anchor(int i) {
    var top = plot.bottom;
    for (final s in values) {
      if (i < s.length) top = math.min(top, y(s[i]));
    }
    return Offset(x(i), top);
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.geometry,
    required this.values,
    required this.reveal,
    required this.colors,
    required this.grid,
    required this.surface,
    required this.guide,
    required this.labelStyle,
    required this.curved,
    required this.area,
    required this.highlight,
  });

  final _LineGeometry geometry;
  final List<List<double>> values;
  final double reveal;
  final List<Color> colors;
  final Color? grid;
  final Color surface;
  final Color guide;
  final TextStyle? labelStyle;
  final bool curved;
  final bool area;
  final int? highlight;

  @override
  void paint(Canvas canvas, Size size) {
    final g = geometry;
    final plot = g.plot;

    // Grid lines and y labels.
    final ticks = g.scale.ticks;
    final gridColor = grid;
    for (var i = 0; i < ticks.length; i++) {
      final y = g.y(ticks[i]).roundToDouble() + 0.5;
      if (gridColor != null) {
        canvas.drawLine(
          Offset(plot.left, y),
          Offset(plot.right, y),
          Paint()
            ..color = gridColor
            ..strokeWidth = 1,
        );
      }
      final tp = uiChartText(g.yLabels[i], labelStyle);
      tp.paint(canvas, Offset(plot.left - UiSpace.sm - tp.width, y - tp.height / 2));
      tp.dispose();
    }

    // X labels.
    final xl = g.xLabels;
    if (xl != null) {
      for (var i = 0; i < xl.length; i += g.labelEvery) {
        final tp = uiChartText(xl[i], labelStyle);
        final x = (g.x(i) - tp.width / 2).clamp(0.0, math.max(0.0, size.width - tp.width)).toDouble();
        tp.paint(canvas, Offset(x, plot.bottom + UiSpace.sm));
        tp.dispose();
      }
    }

    if (g.count == 0) return;

    // Series.
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, plot.left + (plot.width + UiSpace.sm) * reveal, size.height));
    final multi = values.length > 1;
    for (var s = 0; s < values.length; s++) {
      final v = values[s];
      if (v.isEmpty) continue;
      final color = colors[s];
      final points = [for (var i = 0; i < v.length; i++) Offset(g.x(i), g.y(v[i]))];
      if (points.length == 1) {
        canvas.drawCircle(points.first, 3.5, Paint()..color = color);
        continue;
      }
      final line = uiChartLinePath(points, curved: curved);
      if (area) {
        final baseY = g.y(g.scale.min <= 0 && g.scale.max >= 0 ? 0.0 : g.scale.min);
        final fill = Path.from(line)
          ..lineTo(points.last.dx, baseY)
          ..lineTo(points.first.dx, baseY)
          ..close();
        canvas.drawPath(
          fill,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                color.withValues(alpha: multi ? 0.14 : 0.22),
                color.withValues(alpha: 0),
              ],
            ).createShader(Rect.fromLTRB(plot.left, plot.top, plot.right, baseY)),
        );
      }
      canvas.drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    canvas.restore();

    // Touch guide and points.
    final h = highlight;
    if (h != null && h < g.count) {
      final x = g.x(h).roundToDouble() + 0.5;
      canvas.drawLine(
        Offset(x, plot.top),
        Offset(x, plot.bottom),
        Paint()
          ..color = guide
          ..strokeWidth = 1,
      );
      for (var s = 0; s < values.length; s++) {
        if (h >= values[s].length) continue;
        final p = Offset(g.x(h), g.y(values[s][h]));
        canvas.drawCircle(p, 5.5, Paint()..color = surface);
        canvas.drawCircle(p, 4, Paint()..color = colors[s]);
      }
    }
  }

  @override
  bool shouldRepaint(_LinePainter old) => true;
}
