import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/foundation/ui_format.dart';

List<double> _clean(List<double> v) => [for (final x in v) x.isFinite ? x : 0.0];

List<Color> _series(BuildContext c) {
  final cs = c.colors;
  final p = c.palette;
  return [cs.primary, cs.tertiary, p.warning, p.success, p.info, cs.error, cs.secondary];
}

Path _curve(List<Offset> pts, bool smooth) {
  final p = Path()..moveTo(pts.first.dx, pts.first.dy);
  for (var i = 1; i < pts.length; i++) {
    final a = pts[i - 1];
    final b = pts[i];
    if (smooth) {
      final mx = (a.dx + b.dx) / 2;
      p.cubicTo(mx, a.dy, mx, b.dy, b.dx, b.dy);
    } else {
      p.lineTo(b.dx, b.dy);
    }
  }
  return p;
}

Widget _reveal({required Widget Function(double t) builder, bool animate = true}) => TweenAnimationBuilder<double>(
      tween: Tween(begin: animate ? 0 : 1, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: UiCurve.standard,
      builder: (_, t, _) => builder(t),
    );

class UiChartSegment {
  const UiChartSegment(this.label, this.value, {this.color});

  final String label;
  final double value;
  final Color? color;
}

class UiSparkline extends StatelessWidget {
  const UiSparkline(
    this.values, {
    super.key,
    this.color,
    this.fill = true,
    this.height = 40,
    this.width,
    this.strokeWidth = 2,
    this.smooth = true,
    this.animate = true,
  });

  final List<double> values;
  final Color? color;
  final bool fill;
  final double height;
  final double? width;
  final double strokeWidth;
  final bool smooth;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final v = _clean(values);
    final c = color ?? context.colors.primary;
    return Semantics(
      label: v.isEmpty ? 'Trend, no data' : 'Trend, ${v.length} points, last ${UiFormat.compact(v.last)}',
      child: SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: v.isEmpty
            ? null
            : _reveal(
                animate: animate,
                builder: (t) => CustomPaint(painter: _SparkPainter(v, c, fill, strokeWidth.clamp(0.5, 8), smooth, t)),
              ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  const _SparkPainter(this.v, this.color, this.fill, this.stroke, this.smooth, this.t);

  final List<double> v;
  final Color color;
  final bool fill;
  final double stroke;
  final bool smooth;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (v.isEmpty || size.isEmpty) return;
    final mn = v.reduce(math.min);
    final mx = v.reduce(math.max);
    final range = mx - mn;
    final pad = stroke;
    final h = size.height - pad * 2;
    double y(double x) => range == 0 ? size.height / 2 : pad + (1 - (x - mn) / range) * h;
    final pts = v.length == 1
        ? [Offset(0, y(v.first)), Offset(size.width, y(v.first))]
        : [for (var i = 0; i < v.length; i++) Offset(i / (v.length - 1) * size.width, y(v[i]))];
    final line = _curve(pts, smooth);
    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width * t, size.height));
    if (fill) {
      final area = Path.from(line)
        ..lineTo(pts.last.dx, size.height)
        ..lineTo(pts.first.dx, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.28), color.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      );
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SparkPainter o) =>
      o.t != t || o.color != color || o.fill != fill || o.stroke != stroke || o.smooth != smooth || !_same(o.v, v);
}

bool _same(List<double> a, List<double> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

class _NoData extends StatelessWidget {
  const _NoData(this.height, this.text);

  final double height;
  final String text;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: Center(
          child: Text(text, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
        ),
      );
}

class UiLineChart extends StatelessWidget {
  const UiLineChart(
    this.values, {
    super.key,
    this.labels = const [],
    this.color,
    this.height = 200,
    this.smooth = true,
    this.dots = true,
    this.grid = true,
    this.fill = true,
    this.gridLines = 4,
    this.format,
    this.emptyText = 'No data',
    this.animate = true,
  });

  final List<double> values;
  final List<String> labels;
  final Color? color;
  final double height;
  final bool smooth;
  final bool dots;
  final bool grid;
  final bool fill;
  final int gridLines;
  final String Function(double value)? format;
  final String emptyText;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final v = _clean(values);
    if (v.isEmpty) return _NoData(height, emptyText);
    final cs = context.colors;
    final fmt = format ?? UiFormat.compact;
    final mn = v.reduce(math.min);
    final mx = v.reduce(math.max);
    return Semantics(
      label: 'Line chart, ${v.length} points, low ${fmt(mn)}, high ${fmt(mx)}, last ${fmt(v.last)}',
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: _reveal(
          animate: animate,
          builder: (t) => CustomPaint(
            painter: _LinePainter(
              v: v,
              labels: labels,
              color: color ?? cs.primary,
              gridColor: cs.outlineVariant.withValues(alpha: 0.5),
              dotFill: cs.surface,
              text: (context.text.labelSmall ?? const TextStyle(fontSize: 11)).copyWith(color: cs.onSurfaceVariant),
              smooth: smooth,
              dots: dots,
              grid: grid,
              fill: fill,
              gridLines: gridLines.clamp(1, 10),
              fmt: fmt,
              scaler: MediaQuery.textScalerOf(context),
              t: t,
            ),
          ),
        ),
      ),
    );
  }
}

class _LinePainter extends CustomPainter {
  _LinePainter({
    required this.v,
    required this.labels,
    required this.color,
    required this.gridColor,
    required this.dotFill,
    required this.text,
    required this.smooth,
    required this.dots,
    required this.grid,
    required this.fill,
    required this.gridLines,
    required this.fmt,
    required this.scaler,
    required this.t,
  });

  final List<double> v;
  final List<String> labels;
  final Color color;
  final Color gridColor;
  final Color dotFill;
  final TextStyle text;
  final bool smooth;
  final bool dots;
  final bool grid;
  final bool fill;
  final int gridLines;
  final String Function(double) fmt;
  final TextScaler scaler;
  final double t;

  TextPainter _tp(String s) => TextPainter(
        text: TextSpan(text: s, style: text),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
        maxLines: 1,
      )..layout();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final mn = v.reduce(math.min);
    final mx = v.reduce(math.max);
    var lo = math.min(0.0, mn);
    var hi = mx;
    if (hi <= lo) hi = lo + 1;
    hi += (hi - lo) * 0.1;
    if (mn < 0) lo -= (hi - lo) * 0.05;

    final ticks = [for (var i = 0; i <= gridLines; i++) lo + (hi - lo) * i / gridLines];
    final yPainters = grid ? [for (final x in ticks) _tp(fmt(x))] : <TextPainter>[];
    final axisW = yPainters.isEmpty ? 0.0 : yPainters.map((p) => p.width).reduce(math.max) + UiSpace.sm;
    final xPainters = [for (var i = 0; i < math.min(labels.length, v.length); i++) _tp(labels[i])];
    final bottom = xPainters.isEmpty ? 0.0 : xPainters.first.height + UiSpace.sm;
    final top = yPainters.isEmpty ? 6.0 : yPainters.first.height / 2;
    final plot = Rect.fromLTRB(axisW + 6, top, size.width - 6, size.height - bottom);
    if (plot.width <= 0 || plot.height <= 0) {
      for (final p in [...yPainters, ...xPainters]) {
        p.dispose();
      }
      return;
    }

    double y(double x) => plot.bottom - (x - lo) / (hi - lo) * plot.height;
    double xAt(int i) => v.length == 1 ? plot.center.dx : plot.left + i / (v.length - 1) * plot.width;

    final gp = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < yPainters.length; i++) {
      final yy = y(ticks[i]);
      canvas.drawLine(Offset(plot.left, yy), Offset(plot.right, yy), gp);
      yPainters[i].paint(canvas, Offset(axisW - UiSpace.sm - yPainters[i].width, yy - yPainters[i].height / 2));
    }

    if (xPainters.isNotEmpty) {
      final maxLabels = (plot.width / 44).floor().clamp(1, xPainters.length);
      final step = (xPainters.length / maxLabels).ceil();
      for (var i = 0; i < xPainters.length; i += step) {
        final p = xPainters[i];
        final dx = (xAt(i) - p.width / 2).clamp(0.0, size.width - p.width);
        p.paint(canvas, Offset(dx, plot.bottom + UiSpace.sm));
      }
    }

    final pts = [for (var i = 0; i < v.length; i++) Offset(xAt(i), y(v[i]))];
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, plot.left + plot.width * t + 6, size.height));
    if (pts.length > 1) {
      final line = _curve(pts, smooth);
      if (fill) {
        final area = Path.from(line)
          ..lineTo(pts.last.dx, plot.bottom)
          ..lineTo(pts.first.dx, plot.bottom)
          ..close();
        canvas.drawPath(
          area,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [color.withValues(alpha: 0.24), color.withValues(alpha: 0)],
            ).createShader(plot),
        );
      }
      canvas.drawPath(
        line,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
    if (dots || pts.length == 1) {
      for (var i = 0; i < pts.length; i++) {
        final last = i == pts.length - 1;
        final r = last ? 5.0 : 3.5;
        canvas.drawCircle(pts[i], r, Paint()..color = dotFill);
        canvas.drawCircle(
          pts[i],
          r,
          Paint()
            ..color = color
            ..style = last ? PaintingStyle.fill : PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
    }
    canvas.restore();
    for (final p in [...yPainters, ...xPainters]) {
      p.dispose();
    }
  }

  @override
  bool shouldRepaint(_LinePainter o) =>
      o.t != t ||
      o.color != color ||
      o.gridColor != gridColor ||
      o.text != text ||
      o.smooth != smooth ||
      o.dots != dots ||
      o.grid != grid ||
      o.fill != fill ||
      o.gridLines != gridLines ||
      o.scaler != scaler ||
      !_same(o.v, v) ||
      o.labels.join('\u0000') != labels.join('\u0000');
}

class UiBarChart extends StatefulWidget {
  const UiBarChart(
    this.values, {
    super.key,
    this.labels = const [],
    this.highlight,
    this.color,
    this.height = 180,
    this.onSelect,
    this.format,
    this.showValues = false,
    this.emptyText = 'No data',
    this.animate = true,
  });

  final List<double> values;
  final List<String> labels;
  final int? highlight;
  final Color? color;
  final double height;
  final ValueChanged<int>? onSelect;
  final String Function(double value)? format;
  final bool showValues;
  final String emptyText;
  final bool animate;

  @override
  State<UiBarChart> createState() => _UiBarChartState();
}

class _UiBarChartState extends State<UiBarChart> {
  late int? _sel = widget.highlight;

  @override
  void didUpdateWidget(UiBarChart old) {
    super.didUpdateWidget(old);
    if (old.highlight != widget.highlight) _sel = widget.highlight;
    if (_sel != null && _sel! >= widget.values.length) _sel = null;
  }

  @override
  Widget build(BuildContext context) {
    final v = [for (final x in _clean(widget.values)) x < 0 ? 0.0 : x];
    if (v.isEmpty) return _NoData(widget.height, widget.emptyText);
    final cs = context.colors;
    final c = widget.color ?? cs.primary;
    final fmt = widget.format ?? UiFormat.compact;
    final mx = v.reduce(math.max);
    final hasLabels = widget.labels.isNotEmpty;
    final valueStyle = context.text.labelSmall?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface);
    final labelStyle = context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant);
    return SizedBox(
      height: math.max(widget.height, 64),
      child: _reveal(
        animate: widget.animate,
        builder: (t) => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < v.length; i++)
              Expanded(
                child: Semantics(
                  button: widget.onSelect != null,
                  selected: _sel == i,
                  label: '${i < widget.labels.length ? widget.labels[i] : 'Item ${i + 1}'}: ${fmt(v[i])}',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() => _sel = i);
                      widget.onSelect?.call(i);
                    },
                    child: ExcludeSemantics(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 18,
                              child: widget.showValues || _sel == i
                                  ? FittedBox(fit: BoxFit.scaleDown, child: Text(fmt(v[i]), style: valueStyle))
                                  : null,
                            ),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (_, box) {
                                  final h = mx == 0 ? 0.0 : box.maxHeight * (v[i] / mx) * t;
                                  final active = _sel == null || _sel == i;
                                  return Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 32),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
                                          borderRadius: context.tokens.sm,
                                        ),
                                        alignment: Alignment.bottomCenter,
                                        child: Container(
                                          height: math.max(h, 3),
                                          decoration: BoxDecoration(
                                            color: active ? c : c.withValues(alpha: 0.35),
                                            borderRadius: context.tokens.sm,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            if (hasLabels) ...[
                              const UiGap.sm(),
                              Text(
                                i < widget.labels.length ? widget.labels[i] : '',
                                maxLines: 1,
                                overflow: TextOverflow.clip,
                                style: _sel == i ? labelStyle?.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700) : labelStyle,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class UiDonutChart extends StatelessWidget {
  const UiDonutChart(
    this.segments, {
    super.key,
    this.size = 160,
    this.thickness = 22,
    this.center,
    this.centerText,
    this.centerLabel,
    this.legend = true,
    this.animate = true,
  });

  final List<UiChartSegment> segments;
  final double size;
  final double thickness;
  final Widget? center;
  final String? centerText;
  final String? centerLabel;
  final bool legend;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final pal = _series(context);
    final segs = [
      for (final (i, s) in segments.indexed)
        (label: s.label, value: s.value.isFinite && s.value > 0 ? s.value : 0.0, color: s.color ?? pal[i % pal.length]),
    ];
    final total = segs.fold(0.0, (a, s) => a + s.value);
    final s = size <= 0 ? 160.0 : size;
    final w = thickness.clamp(2.0, s / 3);
    final mid = center ??
        (centerText == null && centerLabel == null
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (centerText != null) Text(centerText!, style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                  if (centerLabel != null) Text(centerLabel!, style: context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ));
    final chart = Semantics(
      label: total == 0
          ? 'Donut chart, no data'
          : 'Donut chart. ${segs.map((e) => '${e.label} ${(e.value / total * 100).round()}%').join(', ')}',
      child: SizedBox.square(
        dimension: s,
        child: _reveal(
          animate: animate,
          builder: (t) => CustomPaint(
            painter: _DonutPainter([for (final e in segs) (e.value, e.color)], total, w, cs.surfaceContainerHighest, t),
            child: mid == null ? null : Center(child: Padding(padding: EdgeInsets.all(w + 4), child: FittedBox(fit: BoxFit.scaleDown, child: mid))),
          ),
        ),
      ),
    );
    if (!legend || segs.isEmpty) return chart;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        chart,
        const UiGap.lg(),
        _Legend([for (final e in segs) (e.label, e.color, total == 0 ? 0.0 : e.value / total)]),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  const _DonutPainter(this.segs, this.total, this.w, this.track, this.t);

  final List<(double, Color)> segs;
  final double total;
  final double w;
  final Color track;
  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(w / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w;
    canvas.drawArc(r, 0, math.pi * 2, false, p..color = track);
    if (total <= 0) return;
    final nonZero = segs.where((e) => e.$1 > 0).length;
    final gap = nonZero > 1 ? 0.035 : 0.0;
    var start = -math.pi / 2;
    final full = math.pi * 2 * t;
    for (final (v, c) in segs) {
      if (v <= 0) continue;
      final sweep = full * v / total;
      final draw = sweep - gap;
      if (draw > 0) canvas.drawArc(r, start + gap / 2, draw, false, p..color = c);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter o) => true;
}

class _Legend extends StatelessWidget {
  const _Legend(this.items);

  final List<(String, Color, double)> items;

  @override
  Widget build(BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        spacing: UiSpace.lg,
        runSpacing: UiSpace.sm,
        children: [
          for (final (label, color, frac) in items)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: UiSpace.xs + 2),
                Text(label, style: context.text.labelMedium),
                const SizedBox(width: UiSpace.xs),
                Text(
                  '${(frac * 100).round()}%',
                  style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant, fontWeight: FontWeight.w700),
                ),
              ],
            ),
        ],
      );
}

class UiProgressSegments extends StatelessWidget {
  const UiProgressSegments(this.segments, {super.key, this.height = 10, this.legend = false})
      : total = 0,
        done = 0,
        color = null,
        _steps = false;

  const UiProgressSegments.steps({super.key, required this.total, required this.done, this.height = 6, this.color})
      : segments = const [],
        legend = false,
        _steps = true;

  final List<UiChartSegment> segments;
  final int total;
  final int done;
  final double height;
  final bool legend;
  final Color? color;
  final bool _steps;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final h = height <= 0 ? 6.0 : height;
    final track = cs.surfaceContainerHighest;
    if (_steps) {
      final n = total.clamp(0, 100);
      final d = done.clamp(0, n);
      if (n == 0) return SizedBox(height: h);
      return Semantics(
        label: 'Step $d of $n',
        child: Row(
          children: [
            for (var i = 0; i < n; i++) ...[
              if (i > 0) const SizedBox(width: UiSpace.xs),
              Expanded(
                child: AnimatedContainer(
                  duration: UiDuration.normal,
                  height: h,
                  decoration: BoxDecoration(color: i < d ? (color ?? cs.primary) : track, borderRadius: BorderRadius.circular(h)),
                ),
              ),
            ],
          ],
        ),
      );
    }
    final pal = _series(context);
    final segs = [
      for (final (i, s) in segments.indexed)
        (label: s.label, value: s.value.isFinite && s.value > 0 ? s.value : 0.0, color: s.color ?? pal[i % pal.length]),
    ];
    final sum = segs.fold(0.0, (a, s) => a + s.value);
    final bar = ClipRRect(
      borderRadius: BorderRadius.circular(h),
      child: SizedBox(
        height: h,
        child: sum == 0
            ? ColoredBox(color: track)
            : Row(
                children: [
                  for (final (i, e) in segs.where((e) => e.value > 0).indexed) ...[
                    if (i > 0) const SizedBox(width: 2),
                    Expanded(flex: math.max(1, (e.value / sum * 1000).round()), child: ColoredBox(color: e.color)),
                  ],
                ],
              ),
      ),
    );
    return Semantics(
      label: sum == 0 ? 'No data' : segs.map((e) => '${e.label} ${(e.value / sum * 100).round()}%').join(', '),
      child: ExcludeSemantics(
        child: legend
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  bar,
                  const UiGap.md(),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _Legend([for (final e in segs) (e.label, e.color, sum == 0 ? 0.0 : e.value / sum)]),
                  ),
                ],
              )
            : bar,
      ),
    );
  }
}
