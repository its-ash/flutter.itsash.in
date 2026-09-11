import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

class ThemeCard extends StatelessWidget {
  const ThemeCard({
    super.key,
    required this.child,
    this.color,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.margin,
    this.selected = false,
    this.selectedColor,
    this.selectedBorderWidth = 2,
  });

  final Widget child;
  final Color? color;
  final double? borderRadius;
  final Clip clipBehavior;
  final EdgeInsetsGeometry? margin;

  /// Draws a border in [selectedColor] (defaults to `colorScheme.primary`)
  /// around the card, sharing this card's own resolved [borderRadius] so
  /// the selection outline never mismatches the card's actual corners.
  final bool selected;
  final Color? selectedColor;
  final double selectedBorderWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadows = theme.extension<AppShadowTheme>() ?? const AppShadowTheme();

    final cardTheme = theme.cardTheme;
    final r = borderRadius ?? _radiusFromShape(cardTheme.shape) ?? 16;
    final m = margin ?? (cardTheme.margin ?? const EdgeInsets.all(8));
    final cardColor = color ?? cardTheme.color ?? theme.colorScheme.surface;
    final radius = BorderRadius.circular(r);

    Widget surface = Material(
      color: cardColor,
      borderRadius: radius,
      clipBehavior: clipBehavior,
      child: child,
    );

    if (shadows.cardBlur > 0) {
      surface = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: shadows.cardBlur,
            sigmaY: shadows.cardBlur,
          ),
          child: surface,
        ),
      );
    }

    final border = selected
        ? Border.all(
            color: selectedColor ?? theme.colorScheme.primary,
            width: selectedBorderWidth,
          )
        : (shadows.cardBorderWidth > 0
            ? Border.all(
                color: shadows.cardBorderColor ?? theme.colorScheme.outline,
                width: shadows.cardBorderWidth,
              )
            : null);

    return Container(
      margin: m,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: shadows.cardShadow,
        border: border,
      ),
      child: surface,
    );
  }

  double? _radiusFromShape(ShapeBorder? shape) {
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return null;
  }
}
