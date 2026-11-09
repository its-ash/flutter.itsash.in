import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

String _percent(double v) => '${(v * 100).round()}%';

Color _fill(UiColors c, UiStatus status) => c.tone(status).color;

/// Horizontal progress bar. A null [value] shows an indeterminate bar.
///
/// Value changes animate smoothly.
///
/// ```dart
/// UiProgressBar(0.4, label: 'Uploading', showPercent: true)
/// ```
class UiProgressBar extends StatelessWidget {
  const UiProgressBar(
    this.value, {
    super.key,
    this.status = UiStatus.accent,
    this.label,
    this.showPercent = false,
    this.height = 6,
  });

  /// Same as `UiProgressBar(null)`.
  const UiProgressBar.indeterminate({super.key, this.status = UiStatus.accent, this.label, this.height = 6})
    : value = null,
      showPercent = false;

  /// Progress from 0 to 1, or null for indeterminate.
  final double? value;

  /// Fill color. Defaults to [UiStatus.accent].
  final UiStatus status;

  /// Text above the bar, on the left.
  final String? label;

  /// Shows the percent above the bar, on the right.
  final bool showPercent;

  /// Bar thickness.
  final double height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final v = value?.clamp(0.0, 1.0);
    final color = _fill(c, status);
    final radius = UiRadius.all(UiRadius.full);

    final Widget bar = v == null
        ? LinearProgressIndicator(
            minHeight: height,
            color: color,
            backgroundColor: c.surfaceMuted,
            borderRadius: radius,
          )
        : TweenAnimationBuilder<double>(
            tween: Tween(end: v),
            duration: context.motion(UiMotion.slow),
            curve: UiMotion.standard,
            builder: (context, x, _) => ClipRRect(
              borderRadius: radius,
              child: SizedBox(
                height: height,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColoredBox(color: c.surfaceMuted),
                    FractionallySizedBox(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: x,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: color, borderRadius: radius),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );

    final showHeader = label != null || (showPercent && v != null);
    return Semantics(
      label: label ?? 'Progress',
      value: v == null ? null : _percent(v),
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      label ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelMedium?.copyWith(color: c.textMuted),
                    ),
                  ),
                  if (showPercent && v != null)
                    Text(
                      _percent(v),
                      style: t.labelMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                    ),
                ],
              ),
              const SizedBox(height: UiSpace.sm),
            ],
            bar,
          ],
        ),
      ),
    );
  }
}

/// Circular progress ring. A null [value] spins indeterminately.
///
/// ```dart
/// UiProgressRing(0.72, showPercent: true, size: 64)
/// ```
class UiProgressRing extends StatelessWidget {
  const UiProgressRing(
    this.value, {
    super.key,
    this.size = 44,
    this.stroke = 4,
    this.status = UiStatus.accent,
    this.center,
    this.showPercent = false,
  });

  /// Progress from 0 to 1, or null for indeterminate.
  final double? value;

  /// Outer diameter.
  final double size;

  /// Ring thickness.
  final double stroke;
  final UiStatus status;

  /// Widget in the middle of the ring.
  final Widget? center;

  /// Shows the percent in the middle when [center] is null.
  final bool showPercent;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final v = value?.clamp(0.0, 1.0);
    final color = _fill(c, status);

    Widget? middle = center;
    if (middle == null && showPercent && v != null) {
      middle = Padding(
        padding: EdgeInsets.all(stroke + 2),
        child: FittedBox(
          child: Text(
            _percent(v),
            style: context.text.labelMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
          ),
        ),
      );
    }

    final ring = v == null
        ? CircularProgressIndicator(
            strokeWidth: stroke,
            color: color,
            backgroundColor: c.surfaceMuted,
            strokeCap: StrokeCap.round,
          )
        : TweenAnimationBuilder<double>(
            tween: Tween(end: v),
            duration: context.motion(UiMotion.slow),
            curve: UiMotion.standard,
            builder: (context, x, _) => CustomPaint(
              painter: _RingPainter(value: x, color: color, track: c.surfaceMuted, stroke: stroke),
            ),
          );

    return Semantics(
      label: 'Progress',
      value: v == null ? null : _percent(v),
      child: ExcludeSemantics(
        child: SizedBox.square(
          dimension: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ring,
              if (middle != null) Center(child: middle),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.value, required this.color, required this.track, required this.stroke});

  final double value;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, paint..color = track);
    if (value > 0) {
      canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * value, false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color || old.track != track || old.stroke != stroke;
}

/// Small indeterminate loading spinner.
///
/// ```dart
/// const UiSpinner()
/// ```
class UiSpinner extends StatelessWidget {
  const UiSpinner({super.key, this.size = 20, this.color, this.strokeWidth});

  final double size;

  /// Defaults to the accent color.
  final Color? color;

  /// Defaults to a tenth of [size].
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: SizedBox.square(
        dimension: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth ?? (size / 10).clamp(1.5, 4.0),
          color: color ?? context.colors.accent,
          strokeCap: StrokeCap.round,
        ),
      ),
    );
  }
}
