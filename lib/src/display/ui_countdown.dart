import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:theme/src/display/ui_format.dart';
import 'package:theme/src/foundation/foundation.dart';

/// A circular countdown ring that drains smoothly and turns warning, then
/// danger, near the end. Great for OTP codes and timers.
///
/// ```dart
/// UiCountdown(period: Duration(seconds: 30), remaining: Duration(seconds: 12), onComplete: refresh)
/// ```
class UiCountdown extends StatefulWidget {
  const UiCountdown({
    super.key,
    required this.period,
    this.remaining,
    this.endsAt,
    this.size = UiSize.md,
    this.diameter,
    this.onComplete,
    this.label,
    this.repeat = false,
    this.showText = true,
    this.warningBelow = 0.34,
    this.dangerBelow = 0.17,
  }) : assert(remaining == null || endsAt == null, 'Pass remaining or endsAt, not both');

  /// Full length of one cycle (the ring is full at this value).
  final Duration period;

  /// Time left at start. Defaults to [period].
  final Duration? remaining;

  /// Wall-clock end time. Use instead of [remaining] to stay in sync with a clock.
  final DateTime? endsAt;

  /// `sm` 32, `md` 44, `lg` 72 px. Ignored when [diameter] is set.
  final UiSize size;
  final double? diameter;

  /// Called when the time runs out (every cycle when [repeat] is true).
  final VoidCallback? onComplete;

  /// Caption inside the ring (large sizes) or beside it.
  final String? label;

  /// Starts a new [period] when the time runs out (TOTP codes).
  final bool repeat;

  /// Shows the seconds left in the middle.
  final bool showText;

  /// Fraction of [period] under which the ring turns warning.
  final double warningBelow;

  /// Fraction of [period] under which the ring turns danger.
  final double dangerBelow;

  @override
  State<UiCountdown> createState() => _UiCountdownState();
}

class _UiCountdownState extends State<UiCountdown> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final ValueNotifier<Duration> _left = ValueNotifier(Duration.zero);
  Duration _base = Duration.zero;
  DateTime? _endAt;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(UiCountdown old) {
    super.didUpdateWidget(old);
    if (old.period != widget.period ||
        old.remaining != widget.remaining ||
        old.endsAt != widget.endsAt ||
        old.repeat != widget.repeat) {
      _start();
    }
  }

  void _start() {
    _ticker.stop();
    _endAt = widget.endsAt;
    final left = _endAt != null ? _endAt!.difference(DateTime.now()) : (widget.remaining ?? widget.period);
    _base = left;
    if (left <= Duration.zero && !widget.repeat) {
      _left.value = Duration.zero;
      return;
    }
    _left.value = left;
    _ticker.start();
  }

  void _tick(Duration elapsed) {
    var left = _endAt != null ? _endAt!.difference(DateTime.now()) : _base - elapsed;
    if (left > Duration.zero) {
      _left.value = left;
      return;
    }
    if (widget.repeat && widget.period > Duration.zero) {
      while (left <= Duration.zero) {
        left += widget.period;
        if (_endAt != null) {
          _endAt = _endAt!.add(widget.period);
        } else {
          _base += widget.period;
        }
      }
      _left.value = left;
      widget.onComplete?.call();
      return;
    }
    _left.value = Duration.zero;
    _ticker.stop();
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _left.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d =
        widget.diameter ??
        switch (widget.size) {
          UiSize.sm => 32.0,
          UiSize.md => 44.0,
          UiSize.lg => 72.0,
        };
    final labelInside = widget.label != null && d >= 64;
    final stroke = (d * 0.08).clamp(3.0, 6.0);

    final ring = ValueListenableBuilder<Duration>(
      valueListenable: _left,
      builder: (context, left, _) {
        final periodMs = widget.period.inMilliseconds;
        final fraction = periodMs <= 0 ? 0.0 : (left.inMilliseconds / periodMs).clamp(0.0, 1.0);
        final status = fraction <= widget.dangerBelow
            ? UiStatus.danger
            : fraction <= widget.warningBelow
            ? UiStatus.warning
            : UiStatus.accent;
        final color = colors.tone(status).color;
        final secs = (left.inMilliseconds / 1000).ceil();
        final label = secs >= 60 ? UiFormat.duration(Duration(seconds: secs)) : '$secs';

        return Semantics(
          label: '${widget.label == null ? '' : '${widget.label}, '}$label seconds left',
          excludeSemantics: true,
          child: TweenAnimationBuilder<Color?>(
            tween: ColorTween(end: color),
            duration: context.motion(UiMotion.normal),
            builder: (context, c, _) => SizedBox.square(
              dimension: d,
              child: CustomPaint(
                painter: _RingPainter(
                  fraction: fraction,
                  color: c ?? color,
                  track: colors.surfaceMuted,
                  stroke: stroke,
                ),
                child: widget.showText
                    ? Padding(
                        padding: EdgeInsets.all(stroke + 2),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                label,
                                maxLines: 1,
                                style: UiTypography.mono(
                                  fontSize: d * (labelInside ? 0.26 : 0.32),
                                  fontWeight: FontWeight.w600,
                                  color: status == UiStatus.accent ? colors.text : c ?? color,
                                ),
                              ),
                              if (labelInside)
                                Text(
                                  widget.label!,
                                  maxLines: 1,
                                  style: context.text.labelSmall?.copyWith(color: colors.textSubtle),
                                ),
                            ],
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        );
      },
    );

    if (widget.label == null || labelInside) return ring;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ring,
        const SizedBox(width: UiSpace.sm),
        Flexible(
          child: Text(
            widget.label!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(color: colors.textMuted),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.color, required this.track, required this.stroke});

  final double fraction;
  final Color color;
  final Color track;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, paint..color = track);
    if (fraction > 0) {
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * fraction, false, paint..color = color);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.color != color || old.track != track || old.stroke != stroke;
}
