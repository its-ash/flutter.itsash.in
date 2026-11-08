import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

double _norm(double v) => v.isFinite ? v.clamp(0.0, 1.0) : 0.0;

String _pct(double v) => '${(v * 100).round()}%';

class UiProgressBar extends StatelessWidget {
  const UiProgressBar(
    this.value, {
    super.key,
    this.label,
    this.trailing,
    this.showPercent = false,
    this.status,
    this.color,
    this.height = 8,
    this.animate = true,
  });

  final double value;
  final String? label;
  final String? trailing;
  final bool showPercent;
  final UiStatus? status;
  final Color? color;
  final double height;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final v = _norm(value);
    final fill = color ?? (status == null ? cs.primary : context.tone(status!).color);
    final end = trailing ?? (showPercent ? _pct(v) : null);
    final h = height <= 0 ? 8.0 : height;
    final bar = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: v),
      duration: animate ? UiDuration.slow : Duration.zero,
      curve: UiCurve.standard,
      builder: (_, x, _) => Container(
        height: h,
        decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(h)),
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: x,
          child: Container(decoration: BoxDecoration(color: fill, borderRadius: BorderRadius.circular(h))),
        ),
      ),
    );
    return Semantics(
      label: label,
      value: _pct(v),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (label != null || end != null) ...[
            Row(
              children: [
                if (label != null)
                  Expanded(child: Text(label!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelLarge))
                else
                  const Spacer(),
                if (end != null)
                  Text(end, style: context.text.labelLarge?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700)),
              ],
            ),
            const UiGap.sm(),
          ],
          ExcludeSemantics(child: bar),
        ],
      ),
    );
  }
}

class UiProgressRing extends StatelessWidget {
  const UiProgressRing(
    this.value, {
    super.key,
    this.size = 72,
    this.stroke = 8,
    this.child,
    this.label,
    this.showPercent = true,
    this.status,
    this.color,
    this.trackColor,
    this.animate = true,
  });

  final double value;
  final double size;
  final double stroke;
  final Widget? child;
  final String? label;
  final bool showPercent;
  final UiStatus? status;
  final Color? color;
  final Color? trackColor;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final v = _norm(value);
    final fill = color ?? (status == null ? cs.primary : context.tone(status!).color);
    final s = size <= 0 ? 72.0 : size;
    final w = stroke.clamp(1.0, s / 3);
    final center = child ??
        (showPercent || label != null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showPercent)
                    Text(_pct(v), style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800, fontSize: s * 0.22)),
                  if (label != null)
                    Text(label!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              )
            : null);
    return Semantics(
      label: label,
      value: _pct(v),
      child: SizedBox.square(
        dimension: s,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: v),
          duration: animate ? UiDuration.slow : Duration.zero,
          curve: UiCurve.standard,
          builder: (_, x, c) => CustomPaint(
            painter: _RingPainter(x, w, trackColor ?? cs.surfaceContainerHighest, fill),
            child: c,
          ),
          child: center == null ? null : Center(child: Padding(padding: EdgeInsets.all(w + 2), child: FittedBox(fit: BoxFit.scaleDown, child: center))),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.v, this.w, this.track, this.fill);

  final double v;
  final double w;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(w / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(r, 0, math.pi * 2, false, p..color = track);
    if (v > 0) canvas.drawArc(r, -math.pi / 2, math.pi * 2 * v, false, p..color = fill);
  }

  @override
  bool shouldRepaint(_RingPainter o) => o.v != v || o.w != w || o.track != track || o.fill != fill;
}

class UiStatusDot extends StatefulWidget {
  const UiStatusDot({super.key, this.status = UiStatus.success, this.size = 10, this.pulse = false, this.label, this.color});

  final UiStatus status;
  final double size;
  final bool pulse;
  final String? label;
  final Color? color;

  @override
  State<UiStatusDot> createState() => _UiStatusDotState();
}

class _UiStatusDotState extends State<UiStatusDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void initState() {
    super.initState();
    if (widget.pulse) _c.repeat();
  }

  @override
  void didUpdateWidget(UiStatusDot old) {
    super.didUpdateWidget(old);
    if (widget.pulse && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.pulse && _c.isAnimating) {
      _c
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? context.tone(widget.status).color;
    final s = widget.size <= 0 ? 10.0 : widget.size;
    final dot = SizedBox.square(
      dimension: widget.pulse ? s * 2 : s,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => Stack(
          alignment: Alignment.center,
          children: [
            if (widget.pulse)
              Container(
                width: s + s * _c.value,
                height: s + s * _c.value,
                decoration: BoxDecoration(shape: BoxShape.circle, color: c.withValues(alpha: 0.45 * (1 - _c.value))),
              ),
            Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
          ],
        ),
      ),
    );
    final body = widget.label == null
        ? dot
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              dot,
              const SizedBox(width: UiSpace.xs),
              Text(widget.label!, style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant, fontWeight: FontWeight.w600)),
            ],
          );
    return Semantics(label: widget.label ?? widget.status.name, child: ExcludeSemantics(child: body));
  }
}

class UiBadge extends StatelessWidget {
  const UiBadge({
    super.key,
    required this.child,
    this.count,
    this.dot = false,
    this.max = 99,
    this.status = UiStatus.danger,
    this.show = true,
    this.offset,
  });

  final Widget child;
  final int? count;
  final bool dot;
  final int max;
  final UiStatus status;
  final bool show;
  final Offset? offset;

  @override
  Widget build(BuildContext context) {
    final n = count ?? 0;
    final visible = show && (dot || n > 0);
    final t = context.tone(status);
    final text = n > max ? '$max+' : '$n';
    return Semantics(
      label: visible ? (dot ? 'New' : '$text new') : null,
      child: Badge(
        isLabelVisible: visible,
        backgroundColor: t.color,
        textColor: t.onColor,
        smallSize: 9,
        offset: offset,
        label: dot ? null : Text(text, style: const TextStyle(fontWeight: FontWeight.w700)),
        child: child,
      ),
    );
  }
}

class UiTooltip extends StatelessWidget {
  const UiTooltip(this.message, {super.key, required this.child, this.tap = false});

  final String message;
  final Widget child;
  final bool tap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    if (message.trim().isEmpty) return child;
    return Tooltip(
      message: message,
      triggerMode: tap ? TooltipTriggerMode.tap : null,
      waitDuration: const Duration(milliseconds: 400),
      showDuration: const Duration(seconds: 3),
      padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.sm),
      margin: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
      decoration: BoxDecoration(color: cs.inverseSurface, borderRadius: context.tokens.sm),
      textStyle: context.text.bodySmall?.copyWith(color: cs.onInverseSurface, fontWeight: FontWeight.w500),
      child: child,
    );
  }
}
