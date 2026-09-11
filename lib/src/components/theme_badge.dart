import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

class ThemeBadge extends StatelessWidget {
  const ThemeBadge({
    super.key,
    required this.child,
    this.label,
    this.isVisible = true,
  });

  final Widget child;
  final String? label;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final shadows = Theme.of(context).extension<AppShadowTheme>() ?? const AppShadowTheme();
    final text = shadows.textTransform == ThemeTextTransform.uppercase && label != null
        ? label!.toUpperCase()
        : label;
    return Badge(
      label: text != null ? Text(text) : null,
      isLabelVisible: isVisible,
      child: child,
    );
  }
}
