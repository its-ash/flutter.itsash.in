import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_colors.dart';
import 'package:theme/src/foundation/ui_tokens.dart';

/// Shortcuts to the theme from any widget:
///
/// ```dart
/// Text('Hi', style: context.text.titleMedium?.copyWith(color: context.colors.textMuted));
/// ```
extension UiContext on BuildContext {
  ThemeData get theme => Theme.of(this);

  /// Semantic palette of the current mode.
  UiColors get colors => UiColors.of(this);

  /// Type scale of the current theme.
  TextTheme get text => Theme.of(this).textTheme;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  Size get screenSize => MediaQuery.sizeOf(this);

  /// Window size class of the current screen width.
  UiBreakpoint get breakpoint => UiBreakpoint.of(MediaQuery.sizeOf(this).width);

  bool get isCompact => breakpoint == UiBreakpoint.compact;

  /// Shadows for the current brightness.
  List<BoxShadow> get shadowSm => UiShadows.sm(Theme.of(this).brightness);
  List<BoxShadow> get shadowMd => UiShadows.md(Theme.of(this).brightness);
  List<BoxShadow> get shadowLg => UiShadows.lg(Theme.of(this).brightness);

  /// Returns [d], or zero when the user asked for reduced motion.
  Duration motion(Duration d) => UiMotion.of(this, d);
}

/// Picks a value by window size class. Larger classes fall back to the next
/// smaller value that is set.
///
/// ```dart
/// final cols = context.responsive(compact: 2, medium: 3, expanded: 4);
/// ```
extension UiResponsive on BuildContext {
  T responsive<T>({required T compact, T? medium, T? expanded, T? large}) => switch (breakpoint) {
        UiBreakpoint.compact => compact,
        UiBreakpoint.medium => medium ?? compact,
        UiBreakpoint.expanded => expanded ?? medium ?? compact,
        UiBreakpoint.large => large ?? expanded ?? medium ?? compact,
      };
}

/// Vertical or horizontal gap that adapts to its parent `Flex`.
///
/// Use inside a `Row` or `Column`: `UiGap(UiSpace.md)`.
class UiGap extends StatelessWidget {
  const UiGap(this.size, {super.key});

  final double size;

  @override
  Widget build(BuildContext context) {
    Axis? axis;
    context.visitAncestorElements((e) {
      final w = e.widget;
      if (w is Flex) axis = w.direction;
      return w is! Flex;
    });
    return axis == Axis.horizontal ? SizedBox(width: size) : SizedBox(height: size);
  }
}
