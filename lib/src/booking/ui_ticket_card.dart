import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiTicketCard extends StatelessWidget {
  const UiTicketCard({
    super.key,
    required this.top,
    required this.bottom,
    this.notch = 12,
    this.color,
    this.foreground,
    this.padding = UiSpace.card,
    this.onTap,
  });

  final Widget top;
  final Widget bottom;
  final double notch;
  final Color? color;
  final Color? foreground;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final fill = color ?? (context.isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest);
    final fg = foreground ??
        (color == null
            ? cs.onSurface
            : (ThemeData.estimateBrightnessForColor(color!) == Brightness.dark ? Colors.white : Colors.black));
    final n = notch.clamp(0.0, 32.0);
    final r = context.tokens.radiusLg;
    final dash = fg.withValues(alpha: 0.25);

    Widget half(Widget child, bool isTop) => CustomPaint(
          painter: _TicketPainter(
            top: isTop,
            notch: n,
            radius: r,
            color: fill,
            shadow: !context.isDark,
            dash: isTop ? null : dash,
          ),
          child: Padding(padding: padding, child: child),
        );

    final body = DefaultTextStyle.merge(
      style: TextStyle(color: fg),
      child: IconTheme.merge(
        data: IconThemeData(color: fg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [half(top, true), half(bottom, false)],
        ),
      ),
    );
    return onTap == null
        ? body
        : Semantics(button: true, child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: onTap, child: body));
  }
}

class _TicketPainter extends CustomPainter {
  _TicketPainter({
    required this.top,
    required this.notch,
    required this.radius,
    required this.color,
    required this.shadow,
    this.dash,
  });

  final bool top;
  final double notch;
  final double radius;
  final Color color;
  final bool shadow;
  final Color? dash;

  Path _shape(Size s) {
    final rr = top
        ? RRect.fromRectAndCorners(Offset.zero & s, topLeft: Radius.circular(radius), topRight: Radius.circular(radius))
        : RRect.fromRectAndCorners(Offset.zero & s, bottomLeft: Radius.circular(radius), bottomRight: Radius.circular(radius));
    final base = Path()..addRRect(rr);
    if (notch <= 0) return base;
    final y = top ? s.height : 0.0;
    final cut = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, y), radius: notch))
      ..addOval(Rect.fromCircle(center: Offset(s.width, y), radius: notch));
    return Path.combine(PathOperation.difference, base, cut);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    final path = _shape(size);
    if (shadow) canvas.drawShadow(path, Colors.black.withValues(alpha: 0.35), 2, false);
    canvas.drawPath(path, Paint()..color = color);
    final d = dash;
    if (d == null) return;
    final line = Paint()
      ..color = d
      ..strokeWidth = 1.5;
    const dw = 6.0;
    const gap = 5.0;
    final end = size.width - notch - 6;
    for (var x = notch + 6; x < end; x += dw + gap) {
      canvas.drawLine(Offset(x, 0.75), Offset(x + dw > end ? end : x + dw, 0.75), line);
    }
  }

  @override
  bool shouldRepaint(_TicketPainter old) =>
      old.top != top ||
      old.notch != notch ||
      old.radius != radius ||
      old.color != color ||
      old.dash != dash ||
      old.shadow != shadow;
}
