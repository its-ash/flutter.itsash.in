import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Semicircle gauge for a 0..1 value, with the percentage and a label inside.
///
/// ```dart
/// UiGauge(value: 0.72, label: 'Storage used', status: UiStatus.warning)
/// ```
class UiGauge extends StatelessWidget {
  const UiGauge({
    super.key,
    required this.value,
    this.label,
    this.size = 180,
    this.status,
    this.thickness,
    this.center,
    this.semanticLabel,
  });

  /// Progress from 0 to 1. Values outside are clamped.
  final double value;

  /// Small text under the value.
  final String? label;

  /// Width of the gauge. The height is about half of it.
  final double size;

  /// Arc color from `colors.tone(status)`. Defaults to accent.
  final UiStatus? status;

  /// Arc thickness. Defaults to 10% of [size].
  final double? thickness;

  /// Replaces the percentage text.
  final Widget? center;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final v = value.isFinite ? value.clamp(0.0, 1.0) : 0.0;
    final color = status == null ? colors.accent : colors.tone(status!).color;
    final percent = '${(v * 100).round()}%';

    return Semantics(
      label: semanticLabel ?? [?label, percent].join(', '),
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, c) {
          final width = math.max(48.0, c.hasBoundedWidth ? math.min(size, c.maxWidth) : size);
          final stroke = thickness ?? width * 0.1;
          final height = width / 2 + stroke / 2;
          final inner = (width / 2 - stroke) * 2 * 0.78;
          return SizedBox(
            width: width,
            height: height,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: v),
              duration: context.motion(const Duration(milliseconds: 900)),
              curve: UiMotion.emphasized,
              builder: (context, t, _) => Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GaugePainter(value: t, color: color, track: colors.surfaceMuted, stroke: stroke),
                    ),
                  ),
                  SizedBox(
                    width: inner,
                    height: math.max(0, height - stroke * 1.4),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          center ??
                              Text(
                                '${(t * 100).round()}%',
                                style: context.text.headlineMedium?.copyWith(
                                  fontFeatures: const [FontFeature.tabularFigures()],
                                ),
                              ),
                          if (label != null)
                            ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: math.max(inner, 1)),
                              child: Text(
                                label!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: context.text.labelMedium?.copyWith(color: colors.textMuted),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.value, required this.color, required this.track, required this.stroke});

  final double value;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2 - stroke / 2;
    if (radius <= 0) return;
    final center = Offset(size.width / 2, size.height - stroke / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    Paint arc(Color c) => Paint()
      ..color = c
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, math.pi, math.pi, false, arc(track));
    if (value > 0) canvas.drawArc(rect, math.pi, math.pi * value, false, arc(color));
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.color != color || old.track != track || old.stroke != stroke;
}
