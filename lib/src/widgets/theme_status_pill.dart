import 'package:flutter/material.dart';

import 'package:theme/src/typography/app_typography.dart';
import 'package:theme/src/shadows/app_shadow_theme.dart';

enum ThemeStatus { success, error, warning, info, neutral }

class ThemeStatusPill extends StatelessWidget {
  const ThemeStatusPill({
    super.key,
    required this.label,
    this.status = ThemeStatus.neutral,
    this.icon,
  });

  final String label;
  final ThemeStatus status;
  final IconData? icon;

  double _buttonRadius(BuildContext context) {
    final shape = Theme.of(context).filledButtonTheme.style?.shape?.resolve({});
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shadows = Theme.of(context).extension<AppShadowTheme>() ?? const AppShadowTheme();
    final color = switch (status) {
      ThemeStatus.success => Colors.green.shade600,
      ThemeStatus.error => scheme.error,
      ThemeStatus.warning => Colors.orange.shade700,
      ThemeStatus.info => scheme.primary,
      ThemeStatus.neutral => scheme.onSurface.withValues(alpha: 0.6),
    };
    final text = shadows.textTransform == ThemeTextTransform.uppercase
        ? label.toUpperCase()
        : label;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(_buttonRadius(context)),
        border: shadows.borderWidth > 0
            ? Border.all(color: shadows.borderColor ?? color, width: shadows.borderWidth * 0.5)
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(text, style: AppTypography.labelLarge.copyWith(color: color)),
        ],
      ),
    );
  }
}
