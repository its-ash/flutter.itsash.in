import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiActivityRing {
  const UiActivityRing(this.value, {this.label, this.color, this.icon});

  final double value;
  final String? label;
  final Color? color;
  final IconData? icon;
}

class UiActivityRings extends StatefulWidget {
  const UiActivityRings({
    super.key,
    required this.rings,
    this.size = 160,
    this.stroke = 16,
    this.gap = 4,
    this.center,
    this.legend = false,
    this.duration = const Duration(milliseconds: 900),
  });

  final List<UiActivityRing> rings;
  final double size;
  final double stroke;
  final double gap;
  final Widget? center;
  final bool legend;
  final Duration duration;

  @override
  State<UiActivityRings> createState() => _UiActivityRingsState();
}

class _UiActivityRingsState extends State<UiActivityRings> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration)..forward();
  List<double> _from = const [];
  late List<double> _to = _vals(widget.rings);

  static double _safe(double v) => v.isFinite && v > 0 ? v : 0;

  List<double> _vals(List<UiActivityRing> r) => [for (final x in r.take(3)) _safe(x.value)];

  List<double> _at(double t) => [
        for (var i = 0; i < _to.length; i++) lerpDouble(i < _from.length ? _from[i] : 0, _to[i], t)!,
      ];

  @override
  void didUpdateWidget(UiActivityRings old) {
    super.didUpdateWidget(old);
    final next = _vals(widget.rings);
    if (listEquals(next, _to)) return;
    _from = _at(UiCurve.standard.transform(_c.value));
    _to = next;
    _c
      ..duration = widget.duration
      ..forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final defaults = [cs.primary, cs.tertiary, cs.secondary];
    final rings = widget.rings.take(3).toList();
    final colors = [for (var i = 0; i < rings.length; i++) rings[i].color ?? defaults[i]];
    final size = math.max(48.0, widget.size);
    final stroke = widget.stroke.clamp(2.0, size / 6);
    final label = [
      for (var i = 0; i < rings.length; i++) '${rings[i].label ?? 'Ring ${i + 1}'} ${(_to[i] * 100).round()}%',
    ].join(', ');

    final chart = Semantics(
      label: label,
      child: SizedBox.square(
        dimension: size,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, child) => CustomPaint(
            painter: _RingsPainter(
              values: _at(UiCurve.standard.transform(_c.value)),
              colors: colors,
              stroke: stroke,
              gap: widget.gap > 0 ? widget.gap : 0,
            ),
            child: child,
          ),
          child: widget.center == null ? null : Center(child: widget.center),
        ),
      ),
    );

    if (!widget.legend || rings.isEmpty) return chart;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        chart,
        const UiGap.xl(),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < rings.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      rings[i].icon != null
                          ? Icon(rings[i].icon, size: 18, color: colors[i])
                          : Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(color: colors[i], shape: BoxShape.circle),
                            ),
                      const UiGap.sm(),
                      Flexible(
                        child: Text(
                          rings[i].label ?? 'Ring ${i + 1}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      ),
                      const UiGap.sm(),
                      Text(
                        '${(_to[i] * 100).round()}%',
                        style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: colors[i]),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RingsPainter extends CustomPainter {
  _RingsPainter({required this.values, required this.colors, required this.stroke, required this.gap});

  final List<double> values;
  final List<Color> colors;
  final double stroke;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    for (var i = 0; i < values.length && i < colors.length; i++) {
      final r = size.shortestSide / 2 - stroke / 2 - i * (stroke + gap);
      if (r <= stroke / 2) break;
      final rect = Rect.fromCircle(center: c, radius: r);
      final base = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(c, r, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = colors[i].withValues(alpha: 0.18));
      final v = values[i];
      if (v <= 0) continue;
      if (v < 1) {
        canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * v, false, base..color = colors[i]);
        continue;
      }
      canvas.drawCircle(c, r, Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = colors[i]);
      final lap = v - v.floorToDouble();
      final sweep = 2 * math.pi * (lap == 0 ? 0.001 : lap);
      final end = -math.pi / 2 + sweep;
      final tip = c + Offset(math.cos(end), math.sin(end)) * r;
      canvas.drawCircle(
        tip + Offset(math.cos(end + math.pi / 2), math.sin(end + math.pi / 2)) * (stroke * 0.12),
        stroke / 2,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.28)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, stroke * 0.18),
      );
      canvas.drawArc(rect, -math.pi / 2, sweep, false, base..color = Color.lerp(colors[i], Colors.white, 0.08)!);
    }
  }

  @override
  bool shouldRepaint(_RingsPainter old) =>
      !listEquals(old.values, values) || !listEquals(old.colors, colors) || old.stroke != stroke || old.gap != gap;
}
