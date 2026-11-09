import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Generic container: surface fill, 1 px border, rounded corners, optional
/// shadow, status tint and tap. Other components build on it.
///
/// ```dart
/// UiSurface(child: Text('Hello'));
/// UiSurface(tone: UiStatus.success, child: Text('Saved'));
/// ```
class UiSurface extends StatelessWidget {
  const UiSurface({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(UiSpace.lg),
    this.margin,
    this.radius = UiRadius.lg,
    this.color,
    this.tone,
    this.border = true,
    this.borderColor,
    this.shadow,
    this.onTap,
    this.width,
    this.height,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  /// Fill color. Defaults to `colors.surface`, or the tone's soft color.
  final Color? color;

  /// Tints the fill and border with a status color.
  final UiStatus? tone;

  /// Draws a 1 px border.
  final bool border;
  final Color? borderColor;

  /// Shadow, such as `context.shadowMd`.
  final List<BoxShadow>? shadow;

  /// Makes the surface tappable with an ink ripple.
  final VoidCallback? onTap;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = tone == null ? null : c.tone(tone!);
    final fill = color ?? t?.soft ?? c.surface;
    final side = border
        ? BorderSide(color: borderColor ?? (t == null ? c.border : t.color.withValues(alpha: 0.25)))
        : BorderSide.none;
    final shape = RoundedRectangleBorder(borderRadius: UiRadius.all(radius), side: side);

    Widget inner = Padding(padding: padding, child: child);
    if (onTap != null) inner = InkWell(onTap: onTap, customBorder: shape, child: inner);
    Widget box = Material(color: fill, shape: shape, clipBehavior: Clip.antiAlias, child: inner);
    final shadow = this.shadow;
    if (shadow != null && shadow.isNotEmpty) {
      box = DecoratedBox(
        decoration: BoxDecoration(borderRadius: UiRadius.all(radius), boxShadow: shadow),
        child: box,
      );
    }
    if (width != null || height != null) box = SizedBox(width: width, height: height, child: box);
    if (margin != null) box = Padding(padding: margin!, child: box);
    return box;
  }
}
