import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:theme/src/chart/chart_utils.dart';
import 'package:theme/src/chart/ui_chart_data.dart';
import 'package:theme/src/foundation/foundation.dart';

/// Donut chart with rounded, spaced segments. Tap a segment to highlight it
/// and show its value in the middle.
///
/// ```dart
/// UiDonutChart(segments: [UiChartSegment('Rent', 1200), UiChartSegment('Food', 450), UiChartSegment('Fun', 200)])
/// ```
class UiDonutChart extends StatefulWidget {
  const UiDonutChart({
    super.key,
    required this.segments,
    this.center,
    this.size = 180,
    this.thickness = 18,
    this.gap = 3,
    this.showLegend = true,
    this.valueFormat,
    this.onSelect,
    this.semanticLabel,
  });

  final List<UiChartSegment> segments;

  /// Shown in the middle when nothing is selected. Defaults to the total.
  final Widget? center;

  /// Diameter of the ring.
  final double size;

  /// Ring thickness.
  final double thickness;

  /// Space between segments, in pixels.
  final double gap;
  final bool showLegend;

  /// Formats values in the middle and the legend.
  final UiChartFormatter? valueFormat;

  /// Called with the selected segment index, or null when cleared.
  final ValueChanged<int?>? onSelect;
  final String? semanticLabel;

  @override
  State<UiDonutChart> createState() => _UiDonutChartState();
}

class _UiDonutChartState extends State<UiDonutChart> with SingleTickerProviderStateMixin {
  late final UiChartAnimator _anim = UiChartAnimator(this, duration: const Duration(milliseconds: 900));
  List<double>? _from;
  int? _selected;

  List<double> _valuesOf(List<UiChartSegment> s) => [for (final x in s) math.max(0, x.value.toDouble())];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _anim.start(context);
  }

  @override
  void didUpdateWidget(UiDonutChart old) {
    super.didUpdateWidget(old);
    final before = _valuesOf(old.segments);
    final after = _valuesOf(widget.segments);
    if (!listEquals(before, after)) {
      _from = before.length == after.length ? before : null;
      if (_selected != null && _selected! >= after.length) _selected = null;
      _anim.run(context);
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _select(int? i) {
    final next = i == _selected ? null : i;
    if (next == _selected) return;
    setState(() => _selected = next);
    widget.onSelect?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final format = widget.valueFormat ?? uiChartFormat;
    final values = _valuesOf(widget.segments);
    final total = values.fold<double>(0, (a, b) => a + b);
    final segColors = [
      for (var i = 0; i < widget.segments.length; i++) widget.segments[i].color ?? colors.chartColor(i),
    ];
    String percent(double v) => total == 0 ? '0%' : '${(v / total * 100).toStringAsFixed(v / total < 0.1 ? 1 : 0)}%';

    final parts = [for (var i = 0; i < values.length; i++) '${widget.segments[i].label} ${percent(values[i])}'];
    return Semantics(
      label: widget.semanticLabel ?? 'Donut chart. ${parts.join(', ')}',
      child: LayoutBuilder(
        builder: (context, c) {
          final size = math.max(48.0, c.hasBoundedWidth ? math.min(widget.size, c.maxWidth) : widget.size);
          final thickness = math.min(widget.thickness, size / 5);
          final radius = size / 2 - (thickness + 6) / 2;
          final inner = math.max(0.0, (radius - thickness / 2) * 2 * 0.72);
          final sel = _selected;

          Widget middle;
          if (sel != null && sel < values.length) {
            middle = Column(
              key: ValueKey(sel),
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.segments[sel].label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(color: colors.textMuted),
                ),
                Text(format(values[sel]), style: context.text.headlineSmall),
                Text(percent(values[sel]), style: context.text.labelSmall?.copyWith(color: colors.textSubtle)),
              ],
            );
          } else {
            middle = KeyedSubtree(
              key: const ValueKey('center'),
              child:
                  widget.center ??
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(format(total), style: context.text.headlineSmall),
                      Text(
                        total == 0 ? 'No data' : 'Total',
                        style: context.text.labelSmall?.copyWith(color: colors.textSubtle),
                      ),
                    ],
                  ),
            );
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: size,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapUp: (d) => _select(_hit(d.localPosition, size, radius, thickness, values)),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _anim.curve,
                          builder: (context, _) {
                            final t = _anim.value;
                            final morph = _from != null;
                            return CustomPaint(
                              painter: _DonutPainter(
                                values: morph ? uiChartLerp(_from, values, t) : values,
                                sweep: morph ? 1 : t,
                                colors: segColors,
                                track: colors.surfaceMuted,
                                radius: radius,
                                thickness: thickness,
                                gap: widget.gap,
                                selected: sel,
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: inner,
                        height: inner,
                        child: Center(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: math.max(inner, 1)),
                              child: AnimatedSwitcher(duration: context.motion(UiMotion.fast), child: middle),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.showLegend && widget.segments.isNotEmpty) ...[
                const SizedBox(height: UiSpace.lg),
                UiChartLegend(
                  [
                    for (var i = 0; i < widget.segments.length; i++)
                      UiLegendItem(widget.segments[i].label, color: segColors[i], value: percent(values[i])),
                  ],
                  alignment: WrapAlignment.center,
                  selected: sel,
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  int? _hit(Offset p, double size, double radius, double thickness, List<double> values) {
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0) return null;
    final d = p - Offset(size / 2, size / 2);
    final dist = d.distance;
    // Taps outside the ring clear the selection.
    if (dist < radius - thickness || dist > radius + thickness) return _selected;
    var angle = math.atan2(d.dy, d.dx) + math.pi / 2;
    if (angle < 0) angle += math.pi * 2;
    var acc = 0.0;
    for (var i = 0; i < values.length; i++) {
      acc += values[i] / total * math.pi * 2;
      if (angle <= acc) return i;
    }
    return values.length - 1;
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.values,
    required this.sweep,
    required this.colors,
    required this.track,
    required this.radius,
    required this.thickness,
    required this.gap,
    required this.selected,
  });

  final List<double> values;
  final double sweep;
  final List<Color> colors;
  final Color track;
  final double radius;
  final double thickness;
  final double gap;
  final int? selected;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final total = values.fold<double>(0, (a, b) => a + b);
    if (total <= 0 || radius <= 0) {
      canvas.drawCircle(
        center,
        math.max(0, radius),
        Paint()
          ..color = track
          ..style = PaintingStyle.stroke
          ..strokeWidth = thickness,
      );
      return;
    }
    final nonZero = values.where((v) => v > 0).length;
    final full = math.pi * 2 * sweep;
    var start = -math.pi / 2;
    for (var i = 0; i < values.length; i++) {
      final angle = values[i] / total * full;
      if (values[i] <= 0) continue;
      final isSel = selected == i;
      final paint = Paint()
        ..color = colors[i].withValues(alpha: selected == null || isSel ? 1 : 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSel ? thickness + 6 : thickness
        ..strokeCap = StrokeCap.round;
      final rect = Rect.fromCircle(center: center, radius: radius);
      if (nonZero == 1 && sweep >= 1) {
        canvas.drawCircle(center, radius, paint..strokeCap = StrokeCap.butt);
      } else {
        // Round caps stick out by half the thickness on each side, so leave
        // that room plus the visible gap.
        final pad = nonZero == 1 ? 0.0 : (gap + thickness) / radius;
        final visible = angle - pad;
        if (visible > 0.0001) {
          canvas.drawArc(rect, start + pad / 2, visible, false, paint);
        } else if (angle > 0) {
          canvas.drawArc(rect, start + angle / 2, 0.0001, false, paint);
        }
      }
      start += angle;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      !listEquals(old.values, values) ||
      old.sweep != sweep ||
      !listEquals(old.colors, colors) ||
      old.track != track ||
      old.radius != radius ||
      old.thickness != thickness ||
      old.gap != gap ||
      old.selected != selected;
}
