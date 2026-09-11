import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

class ThemeDiscountBadge extends StatelessWidget {
  const ThemeDiscountBadge({
    super.key,
    required this.percentOff,
    this.color,
  });

  /// e.g. `20` renders "-20%".
  final int percentOff;
  final Color? color;

  double _buttonRadius(BuildContext context) {
    final shape = Theme.of(context).filledButtonTheme.style?.shape?.resolve({});
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 6;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shadows = Theme.of(context).extension<AppShadowTheme>() ?? const AppShadowTheme();
    final bg = color ?? scheme.error;
    final fg = color == null ? scheme.onError : (bg.computeLuminance() > 0.5 ? Colors.black : Colors.white);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_buttonRadius(context)),
        border: shadows.borderWidth > 0
            ? Border.all(color: shadows.borderColor ?? fg, width: shadows.borderWidth * 0.5)
            : null,
      ),
      child: Text(
        '-$percentOff%',
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
