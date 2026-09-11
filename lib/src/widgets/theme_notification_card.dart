import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

enum ThemeNotificationType { info, success, warning, error, default_ }

class ThemeNotificationCard extends StatelessWidget {
  const ThemeNotificationCard({
    super.key,
    required this.title,
    this.message,
    this.type = ThemeNotificationType.default_,
    this.leading,
    this.actions = const [],
    this.onDismiss,
    this.timestamp,
    this.margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  });

  final String title;
  final String? message;
  final ThemeNotificationType type;
  final Widget? leading;
  final List<Widget> actions;
  final VoidCallback? onDismiss;
  final String? timestamp;
  final EdgeInsetsGeometry margin;

  double _cardRadius(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }

  double _buttonRadius(BuildContext context) {
    final shape = Theme.of(context).filledButtonTheme.style?.shape?.resolve({});
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final shadows = Theme.of(context).extension<AppShadowTheme>() ?? const AppShadowTheme();
    final (bg, fg, icon) = _colors(scheme);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_cardRadius(context)),
        border: Border.all(
          color: shadows.borderWidth > 0 ? (shadows.borderColor ?? fg) : fg.withValues(alpha: 0.2),
          width: shadows.borderWidth > 0 ? shadows.borderWidth : 1,
        ),
        boxShadow: [BoxShadow(color: scheme.shadow.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: fg.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(_buttonRadius(context))),
            child: leading ?? Icon(icon, color: fg, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600))),
              if (timestamp != null) Text(timestamp!, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
            ]),
            if (message != null) ...[const SizedBox(height: 2), Text(message!, style: Theme.of(context).textTheme.bodyMedium)],
            if (actions.isNotEmpty) ...[const SizedBox(height: 8), Row(children: actions)],
          ])),
          if (onDismiss != null)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: onDismiss,
            ),
        ]),
      ),
    );
  }

  (Color, Color, IconData) _colors(ColorScheme scheme) => switch (type) {
    ThemeNotificationType.info => (scheme.surfaceContainerLow, scheme.primary, Icons.info_outline),
    ThemeNotificationType.success => (Colors.green.shade50, Colors.green.shade700, Icons.check_circle_outline),
    ThemeNotificationType.warning => (Colors.orange.shade50, Colors.orange.shade800, Icons.warning_amber_outlined),
    ThemeNotificationType.error => (scheme.errorContainer, scheme.onErrorContainer, Icons.error_outline),
    ThemeNotificationType.default_ => (scheme.surfaceContainerLow, scheme.onSurface, Icons.notifications_none),
  };
}