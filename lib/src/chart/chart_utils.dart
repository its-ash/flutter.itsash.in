// Internal helpers shared by the chart widgets. Not exported from the package.
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Default number format for chart values: 1200 → 1.2k, 0.25 → 0.25.
String uiChartFormat(num value) {
  final v = value.toDouble();
  if (!v.isFinite) return '–';
  final a = v.abs();
  String trim(double x, int digits) {
    var s = x.toStringAsFixed(digits);
    if (s.contains('.')) s = s.replaceFirst(RegExp(r'\.?0+$'), '');
    return s == '-0' ? '0' : s;
  }

  if (a >= 1e9) return '${trim(v / 1e9, 1)}B';
  if (a >= 1e6) return '${trim(v / 1e6, 1)}M';
  if (a >= 1e4) return '${trim(v / 1e3, 1)}k';
  if (a >= 1000) return trim(v, 0);
  if (v == v.roundToDouble()) return v.toInt().toString();
  return trim(v, a < 1 ? 2 : 1);
}

/// Linear value scale with "nice" rounded ticks.
class UiChartScale {
  const UiChartScale(this.min, this.max, this.step);

  /// Builds a scale covering [lo]..[hi] with about [count] intervals.
  /// With [includeZero] the range always contains zero.
  factory UiChartScale.nice(double lo, double hi, {int count = 4, bool includeZero = true}) {
    if (!lo.isFinite || !hi.isFinite) {
      lo = 0;
      hi = 1;
    }
    if (includeZero) {
      lo = math.min(lo, 0);
      hi = math.max(hi, 0);
    }
    if (hi - lo < 1e-9) {
      if (hi == 0) {
        hi = 1;
      } else {
        final pad = hi.abs() * 0.1;
        lo -= pad;
        hi += pad;
      }
    }
    final step = _niceStep((hi - lo) / count);
    final min = (lo / step).floor() * step;
    final max = (hi / step).ceil() * step;
    return UiChartScale(_clean(min), _clean(max), step);
  }

  final double min;
  final double max;
  final double step;

  double get span => max - min;

  /// Position of [v] in 0..1.
  double norm(double v) => span == 0 ? 0 : (v - min) / span;

  List<double> get ticks {
    final n = (span / step).round();
    return [for (var i = 0; i <= n; i++) _clean(min + i * step)];
  }

  static double _niceStep(double raw) {
    final exp = (math.log(raw) / math.ln10).floor();
    final base = math.pow(10, exp).toDouble();
    final f = raw / base;
    final nice = f <= 1
        ? 1.0
        : f <= 2
        ? 2.0
        : f <= 2.5
        ? 2.5
        : f <= 5
        ? 5.0
        : 10.0;
    return nice * base;
  }

  static double _clean(double v) => double.parse(v.toStringAsPrecision(12));
}

/// One line of a [UiChartTooltip].
class UiChartTooltipRow {
  const UiChartTooltipRow(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;
}

/// Dark (inverse) tooltip card used by every chart.
class UiChartTooltip extends StatelessWidget {
  const UiChartTooltip({super.key, this.title, required this.rows});

  final String? title;
  final List<UiChartTooltipRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final on = colors.onSurfaceInverse;
    final base = context.text.labelMedium?.copyWith(color: on, fontFeatures: const [FontFeature.tabularFigures()]);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.surfaceInverse,
          borderRadius: UiRadius.all(UiRadius.sm),
          boxShadow: context.shadowMd,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.md - 2, vertical: UiSpace.sm),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null)
                Padding(
                  padding: EdgeInsets.only(bottom: rows.isEmpty ? 0 : UiSpace.xs),
                  child: Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: base?.copyWith(color: on.withValues(alpha: 0.7), fontWeight: FontWeight.w500),
                  ),
                ),
              for (final r in rows)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 1),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (r.color != null) ...[
                        DecoratedBox(
                          decoration: BoxDecoration(color: r.color, borderRadius: UiRadius.all(2)),
                          child: const SizedBox.square(dimension: 8),
                        ),
                        const SizedBox(width: UiSpace.xs + 2),
                      ],
                      if (r.label.isNotEmpty) ...[
                        Flexible(
                          child: Text(
                            r.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: base?.copyWith(color: on.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: UiSpace.md),
                      ],
                      Text(r.value, style: base),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Places a tooltip above [anchor] (below when there is no room), kept
/// inside the chart bounds.
class UiChartTooltipLayout extends SingleChildLayoutDelegate {
  UiChartTooltipLayout(this.anchor);

  final Offset anchor;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => constraints.loosen();

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final x = (anchor.dx - childSize.width / 2).clamp(0.0, math.max(0.0, size.width - childSize.width)).toDouble();
    var y = anchor.dy - childSize.height - UiSpace.sm;
    if (y < 0) y = anchor.dy + UiSpace.sm;
    y = y.clamp(0.0, math.max(0.0, size.height - childSize.height)).toDouble();
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(UiChartTooltipLayout old) => old.anchor != anchor;
}

/// Positions [tooltip] near [anchor] over a chart. Ignores pointer events.
class UiChartTooltipOverlay extends StatelessWidget {
  const UiChartTooltipOverlay({super.key, required this.anchor, required this.tooltip});

  final Offset anchor;
  final Widget tooltip;

  @override
  Widget build(BuildContext context) => Positioned.fill(
    child: IgnorePointer(
      child: CustomSingleChildLayout(delegate: UiChartTooltipLayout(anchor), child: tooltip),
    ),
  );
}

/// Pointer handling shared by charts: hover and horizontal drag report a
/// position, tap reports a tap. Vertical drags pass through to scrolling.
class UiChartPointer extends StatelessWidget {
  const UiChartPointer({
    super.key,
    required this.onPoint,
    required this.onTap,
    required this.onLeave,
    required this.child,
  });

  final ValueChanged<Offset> onPoint;
  final ValueChanged<Offset> onTap;
  final VoidCallback onLeave;
  final Widget child;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onHover: (e) => onPoint(e.localPosition),
    onExit: (_) => onLeave(),
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapUp: (d) => onTap(d.localPosition),
      onHorizontalDragStart: (d) => onPoint(d.localPosition),
      onHorizontalDragUpdate: (d) => onPoint(d.localPosition),
      // No onHorizontalDragCancel: it also fires when a plain tap wins the
      // gesture arena, which would clear the tooltip the tap just pinned.
      onHorizontalDragEnd: (_) => onLeave(),
      child: child,
    ),
  );
}

/// Owns the enter / update animation of a chart.
class UiChartAnimator {
  UiChartAnimator(TickerProvider vsync, {this.duration = const Duration(milliseconds: 700)})
    : controller = AnimationController(vsync: vsync, duration: duration);

  final Duration duration;
  final AnimationController controller;
  late final CurvedAnimation curve = CurvedAnimation(parent: controller, curve: UiMotion.emphasized);
  bool _started = false;

  /// Starts the first animation once (call from `didChangeDependencies`).
  void start(BuildContext context) {
    if (_started) return;
    _started = true;
    run(context);
  }

  /// Plays from 0 to 1, or jumps to the end with reduced motion.
  void run(BuildContext context) {
    final d = context.motion(duration);
    if (d == Duration.zero) {
      controller.value = 1;
    } else {
      controller.duration = d;
      controller.forward(from: 0);
    }
  }

  double get value => curve.value;

  void dispose() {
    curve.dispose();
    controller.dispose();
  }
}

/// Path through [points]. With [curved] it uses monotone cubic
/// interpolation, which never overshoots the data.
Path uiChartLinePath(List<Offset> points, {bool curved = true}) {
  final path = Path();
  if (points.isEmpty) return path;
  path.moveTo(points.first.dx, points.first.dy);
  if (points.length == 1) return path;
  if (!curved || points.length == 2) {
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    return path;
  }
  final n = points.length;
  final dx = List<double>.generate(n - 1, (i) => points[i + 1].dx - points[i].dx);
  final slope = List<double>.generate(n - 1, (i) => dx[i] == 0 ? 0 : (points[i + 1].dy - points[i].dy) / dx[i]);
  final tangent = List<double>.filled(n, 0);
  tangent[0] = slope[0];
  tangent[n - 1] = slope[n - 2];
  for (var i = 1; i < n - 1; i++) {
    if (slope[i - 1] * slope[i] <= 0) {
      tangent[i] = 0;
    } else {
      final w1 = 2 * dx[i] + dx[i - 1];
      final w2 = dx[i] + 2 * dx[i - 1];
      tangent[i] = (w1 + w2) / (w1 / slope[i - 1] + w2 / slope[i]);
    }
  }
  for (var i = 0; i < n - 1; i++) {
    final p0 = points[i];
    final p1 = points[i + 1];
    final h = dx[i] / 3;
    path.cubicTo(p0.dx + h, p0.dy + tangent[i] * h, p1.dx - h, p1.dy - tangent[i + 1] * h, p1.dx, p1.dy);
  }
  return path;
}

/// Lays out [text] once for painting.
TextPainter uiChartText(String text, TextStyle? style, {TextDirection direction = TextDirection.ltr}) => TextPainter(
  text: TextSpan(text: text, style: style),
  textDirection: direction,
  maxLines: 1,
)..layout();

/// Values of [from] blended into [to] at [t]. Missing entries start at [to].
List<double> uiChartLerp(List<double>? from, List<double> to, double t) {
  if (from == null || t >= 1) return to;
  return [for (var i = 0; i < to.length; i++) i < from.length ? from[i] + (to[i] - from[i]) * t : to[i]];
}
