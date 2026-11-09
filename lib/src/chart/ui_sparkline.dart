import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:theme/src/chart/chart_utils.dart';
import 'package:theme/src/foundation/foundation.dart';

/// Tiny trend line for stat cards and table cells.
///
/// ```dart
/// UiSparkline([4, 6, 5, 9, 12, 10, 14])
/// ```
class UiSparkline extends StatefulWidget {
  const UiSparkline(
    this.values, {
    super.key,
    this.color,
    this.fill = true,
    this.height = 32,
    this.width,
    this.strokeWidth = 2,
    this.curved = true,
    this.showLastDot = true,
    this.semanticLabel,
  });

  final List<num> values;

  /// Line color. Defaults to the first chart color.
  final Color? color;

  /// Fades a gradient under the line.
  final bool fill;
  final double height;

  /// Defaults to the available width.
  final double? width;
  final double strokeWidth;
  final bool curved;

  /// Marks the latest value with a dot.
  final bool showLastDot;
  final String? semanticLabel;

  @override
  State<UiSparkline> createState() => _UiSparklineState();
}

class _UiSparklineState extends State<UiSparkline> with SingleTickerProviderStateMixin {
  late final UiChartAnimator _anim = UiChartAnimator(this);
  List<double>? _from;

  List<double> get _values => [for (final v in widget.values) v.toDouble()];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _anim.start(context);
  }

  @override
  void didUpdateWidget(UiSparkline old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.values, widget.values)) {
      final previous = [for (final v in old.values) v.toDouble()];
      _from = previous.length == widget.values.length ? previous : null;
      _anim.run(context);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = widget.color ?? colors.chartColor(0);
    final values = _values;
    final label =
        widget.semanticLabel ??
        (values.isEmpty ? 'Trend, no data' : 'Trend of ${values.length} values, latest ${uiChartFormat(values.last)}');
    return Semantics(
      label: label,
      child: LayoutBuilder(
        builder: (context, c) => SizedBox(
          // Inside a Row (unbounded width) fall back to a compact 96 px.
          width: widget.width ?? (c.hasBoundedWidth ? c.maxWidth : 96),
          height: widget.height,
          child: AnimatedBuilder(
            animation: _anim.curve,
            builder: (context, _) {
              final t = _anim.value;
              final morph = _from != null;
              return CustomPaint(
                painter: _SparklinePainter(
                  values: morph ? uiChartLerp(_from, values, t) : values,
                  reveal: morph ? 1 : t,
                  color: color,
                  surface: colors.surface,
                  fill: widget.fill,
                  strokeWidth: widget.strokeWidth,
                  curved: widget.curved,
                  dot: widget.showLastDot,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  _SparklinePainter({
    required this.values,
    required this.reveal,
    required this.color,
    required this.surface,
    required this.fill,
    required this.strokeWidth,
    required this.curved,
    required this.dot,
  });

  final List<double> values;
  final double reveal;
  final Color color;
  final Color surface;
  final bool fill;
  final double strokeWidth;
  final bool curved;
  final bool dot;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.isEmpty) return;
    final pad = dot ? strokeWidth + 2.5 : strokeWidth / 2;
    final rect = Rect.fromLTRB(pad, pad, size.width - pad, size.height - pad);
    if (rect.width <= 0 || rect.height <= 0) return;
    final lo = values.reduce(math.min);
    final hi = values.reduce(math.max);
    final span = hi - lo;
    double y(double v) => span == 0 ? rect.center.dy : rect.bottom - (v - lo) / span * rect.height;
    final n = values.length;
    final points = [
      for (var i = 0; i < n; i++) Offset(n == 1 ? rect.right : rect.left + rect.width * i / (n - 1), y(values[i])),
    ];
    final line = uiChartLinePath(points, curved: curved);

    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, rect.left + (rect.width + pad) * reveal, size.height));
    if (fill && n > 1) {
      final area = Path.from(line)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();
      canvas.drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.22), color.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      );
    }
    canvas.drawPath(
      line,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();
    if (dot && reveal >= 1) {
      canvas.drawCircle(points.last, strokeWidth + 1.5, Paint()..color = surface);
      canvas.drawCircle(points.last, strokeWidth + 0.5, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      !listEquals(old.values, values) ||
      old.reveal != reveal ||
      old.color != color ||
      old.surface != surface ||
      old.fill != fill ||
      old.strokeWidth != strokeWidth ||
      old.curved != curved ||
      old.dot != dot;
}
