import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

enum UiCardVariant { filled, outlined, elevated, tonal, gradient }

class UiCard extends StatelessWidget {
  const UiCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.variant = UiCardVariant.filled,
    this.padding = UiSpace.card,
    this.margin,
    this.color,
    this.radius,
    this.width,
    this.height,
    this.selected = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final UiCardVariant variant;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final BorderRadius? radius;
  final double? width;
  final double? height;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final r = radius ?? context.tokens.lg;
    final bg = color ??
        switch (variant) {
          UiCardVariant.filled => cs.surfaceContainerLow,
          UiCardVariant.outlined => cs.surface,
          UiCardVariant.elevated => cs.surfaceContainerLowest,
          UiCardVariant.tonal => cs.secondaryContainer,
          UiCardVariant.gradient => null,
        };
    final side = selected
        ? BorderSide(color: cs.primary, width: 2)
        : variant == UiCardVariant.outlined
            ? BorderSide(color: cs.outlineVariant)
            : variant == UiCardVariant.filled
                ? BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4))
                : BorderSide.none;
    final fg = variant == UiCardVariant.gradient
        ? cs.onPrimary
        : variant == UiCardVariant.tonal
            ? cs.onSecondaryContainer
            : cs.onSurface;

    Widget body = Padding(padding: padding, child: child);
    if (onTap != null || onLongPress != null) {
      body = InkWell(onTap: onTap, onLongPress: onLongPress, borderRadius: r, child: body);
    }

    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        gradient: variant == UiCardVariant.gradient && color == null ? context.palette.gradient : null,
        borderRadius: r,
        border: Border.fromBorderSide(side),
        boxShadow: variant == UiCardVariant.elevated
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: context.isDark ? 0.4 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: r,
        clipBehavior: Clip.antiAlias,
        child: DefaultTextStyle.merge(
          style: TextStyle(color: fg),
          child: IconTheme.merge(data: IconThemeData(color: fg), child: body),
        ),
      ),
    );
  }
}
