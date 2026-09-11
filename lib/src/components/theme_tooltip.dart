import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

class ThemeTooltip extends StatelessWidget {
  const ThemeTooltip({super.key, required this.message, required this.child});

  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadows = theme.extension<AppShadowTheme>() ?? const AppShadowTheme();

    // Tooltips are transient, low-emphasis UI — a full-weight border here
    // reads as visual noise on something that appears and disappears in a
    // fraction of a second, so only a thin, understated stroke is added
    // (a smaller multiplier than surface-like components), and only when
    // the preset actually asks for borders.
    if (shadows.borderWidth <= 0) {
      return Tooltip(message: message, child: child);
    }

    return Tooltip(
      message: message,
      decoration: BoxDecoration(
        color: theme.colorScheme.inverseSurface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: shadows.borderColor ?? theme.colorScheme.outline,
          width: shadows.borderWidth * 0.25,
        ),
      ),
      child: child,
    );
  }
}
