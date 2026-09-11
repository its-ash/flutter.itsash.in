import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

enum ThemeToastType { success, error, warning, info }

class ThemeToast {
  ThemeToast._();

  static final List<OverlayEntry> _active = [];

  static void show(
    BuildContext context,
    String message, {
    ThemeToastType type = ThemeToastType.info,
    Duration duration = const Duration(seconds: 3),
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shadows = theme.extension<AppShadowTheme>() ?? const AppShadowTheme();
    final (bg, fg, icon) = switch (type) {
      ThemeToastType.success => (Colors.green.shade600, Colors.white, Icons.check_circle_outline),
      ThemeToastType.error => (scheme.error, scheme.onError, Icons.error_outline),
      ThemeToastType.warning => (Colors.orange.shade700, Colors.white, Icons.warning_amber_outlined),
      ThemeToastType.info => (scheme.inverseSurface, scheme.onInverseSurface, Icons.info_outline),
    };

    final overlay = Overlay.of(context, rootOverlay: true);
    final slot = _active.length;
    late OverlayEntry entry;

    void remove() {
      if (!_active.remove(entry)) return;
      entry.remove();
    }

    entry = OverlayEntry(
      builder: (context) => _ToastCard(
        message: message,
        bg: bg,
        fg: fg,
        icon: icon,
        slot: slot,
        radius: _cardRadius(theme),
        borderColor: shadows.borderWidth > 0 ? (shadows.borderColor ?? fg) : null,
        borderWidth: shadows.borderWidth * 0.5,
        onDismiss: remove,
      ),
    );

    _active.add(entry);
    overlay.insert(entry);
    Future.delayed(duration, remove);
  }

  static void success(BuildContext context, String message, {Duration? duration}) =>
      show(context, message, type: ThemeToastType.success, duration: duration ?? const Duration(seconds: 3));

  static void error(BuildContext context, String message, {Duration? duration}) =>
      show(context, message, type: ThemeToastType.error, duration: duration ?? const Duration(seconds: 3));

  static void warning(BuildContext context, String message, {Duration? duration}) =>
      show(context, message, type: ThemeToastType.warning, duration: duration ?? const Duration(seconds: 3));

  static void info(BuildContext context, String message, {Duration? duration}) =>
      show(context, message, type: ThemeToastType.info, duration: duration ?? const Duration(seconds: 3));

  static double _cardRadius(ThemeData theme) {
    final shape = theme.cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }
}

class _ToastCard extends StatelessWidget {
  const _ToastCard({
    required this.message,
    required this.bg,
    required this.fg,
    required this.icon,
    required this.slot,
    required this.radius,
    this.borderColor,
    this.borderWidth = 0,
    required this.onDismiss,
  });

  final String message;
  final Color bg;
  final Color fg;
  final IconData icon;
  final int slot;
  final double radius;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 24 + 60.0 * slot,
      left: 24,
      right: 24,
      child: Material(
        color: Colors.transparent,
        child: Dismissible(
          key: ObjectKey(this),
          direction: DismissDirection.horizontal,
          onDismissed: (_) => onDismiss(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 12, offset: const Offset(0, 4))],
              border: borderColor != null ? Border.all(color: borderColor!, width: borderWidth) : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: fg),
                const SizedBox(width: 12),
                Expanded(child: Text(message, style: TextStyle(color: fg))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
