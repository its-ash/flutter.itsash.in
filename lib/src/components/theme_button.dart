import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

enum ThemeButtonVariant { elevated, filled, outlined, text }

/// Semantic color override for [ThemeButton]. Reuses the same palette as
/// [Notify]/[ThemeStatusPill] (`success` = green, `warning` = orange,
/// `error` = `colorScheme.error`, `info` = `colorScheme.primary`) so a
/// status button looks consistent with the rest of the status UI.
enum ThemeButtonStatus { success, error, warning, info }

class ThemeButton extends StatelessWidget {
  const ThemeButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ThemeButtonVariant.filled,
    this.icon,
    this.status,
  });

  final String label;
  final VoidCallback? onPressed;
  final ThemeButtonVariant variant;
  final IconData? icon;

  /// When set, overrides the button's color with a semantic status color
  /// instead of the theme's primary color — for actions like "Delete"
  /// (error), "Approve" (success), "Proceed with caution" (warning), or
  /// "Learn more" (info).
  final ThemeButtonStatus? status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shadows = theme.extension<AppShadowTheme>() ?? const AppShadowTheme();
    final hasCustomShadow = shadows.buttonShadow.isNotEmpty;
    final displayLabel =
        shadows.textTransform == ThemeTextTransform.uppercase ? label.toUpperCase() : label;
    final child = Text(displayLabel);
    final iconWidget = icon == null ? null : Icon(icon);

    final statusColor = switch (status) {
      ThemeButtonStatus.success => Colors.green.shade600,
      ThemeButtonStatus.error => scheme.error,
      ThemeButtonStatus.warning => Colors.orange.shade700,
      ThemeButtonStatus.info => scheme.primary,
      null => null,
    };
    final onStatusColor = status == null
        ? null
        : (status == ThemeButtonStatus.error ? scheme.onError : Colors.white);

    Widget button = switch (variant) {
      ThemeButtonVariant.elevated => iconWidget == null
          ? ElevatedButton(
              onPressed: onPressed,
              style: statusColor == null
                  ? null
                  : ElevatedButton.styleFrom(
                      backgroundColor: scheme.surface,
                      foregroundColor: statusColor,
                      side: BorderSide(color: statusColor),
                    ),
              child: child,
            )
          : ElevatedButton.icon(
              onPressed: onPressed,
              icon: iconWidget,
              label: child,
              style: statusColor == null
                  ? null
                  : ElevatedButton.styleFrom(
                      backgroundColor: scheme.surface,
                      foregroundColor: statusColor,
                      side: BorderSide(color: statusColor),
                    ),
            ),
      ThemeButtonVariant.filled => iconWidget == null
          ? FilledButton(
              onPressed: onPressed,
              style: statusColor == null
                  ? null
                  : FilledButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: onStatusColor,
                    ),
              child: child,
            )
          : FilledButton.icon(
              onPressed: onPressed,
              icon: iconWidget,
              label: child,
              style: statusColor == null
                  ? null
                  : FilledButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: onStatusColor,
                    ),
            ),
      ThemeButtonVariant.outlined => iconWidget == null
          ? OutlinedButton(
              onPressed: onPressed,
              style: statusColor == null
                  ? null
                  : OutlinedButton.styleFrom(
                      foregroundColor: statusColor,
                      side: BorderSide(color: statusColor),
                    ),
              child: child,
            )
          : OutlinedButton.icon(
              onPressed: onPressed,
              icon: iconWidget,
              label: child,
              style: statusColor == null
                  ? null
                  : OutlinedButton.styleFrom(
                      foregroundColor: statusColor,
                      side: BorderSide(color: statusColor),
                    ),
            ),
      ThemeButtonVariant.text => iconWidget == null
          ? TextButton(
              onPressed: onPressed,
              style: statusColor == null
                  ? null
                  : TextButton.styleFrom(foregroundColor: statusColor),
              child: child,
            )
          : TextButton.icon(
              onPressed: onPressed,
              icon: iconWidget,
              label: child,
              style: statusColor == null
                  ? null
                  : TextButton.styleFrom(foregroundColor: statusColor),
            ),
    };

    // Text and outlined buttons have a transparent fill, so a solid drop
    // shadow behind them would show straight through as a fake background
    // — only give the stamped shadow to buttons with an opaque fill.
    if (!hasCustomShadow ||
        variant == ThemeButtonVariant.text ||
        variant == ThemeButtonVariant.outlined) {
      return button;
    }

    // A status button (e.g. a green success button) should get a shadow
    // in its own color family, not the theme's fixed multi-color stamp
    // shadow (which would put a pink shadow behind a green button) — but
    // using the exact same color as the fill reads as one flat blob, not
    // a shadow, especially with the zero-blur offset shadows some styles
    // use. Darkening it (same hue, deeper) keeps it recognizably "this
    // button's shadow" while still looking like a shadow.
    //
    // Styles like Claymorphism use a two-tone embossed shadow: a bright
    // top-light (negative offset) + a colored bottom-shadow. Tinting the
    // top-light with the darkened status color would turn it into a dark
    // blob on top of the button — so only the bottom (positive-offset)
    // shadows are tinted; the top-light keeps its original color.
    final shadowStatusColor = statusColor == null
        ? null
        : HSLColor.fromColor(statusColor)
            .withLightness((HSLColor.fromColor(statusColor).lightness * 0.6).clamp(0.0, 1.0))
            .toColor();
    final baseShadow = shadowStatusColor == null
        ? shadows.buttonShadow
        : shadows.buttonShadow
            .map((s) {
              final isLightShadow = s.offset.dy < 0 || (s.offset.dy == 0 && s.offset.dx < 0);
              if (isLightShadow) return s;
              return s.copyWith(color: shadowStatusColor.withValues(alpha: s.color.a));
            })
            .toList();

    // Disabled buttons already dim their own text/fill via Material's
    // disabledForegroundColor/disabledBackgroundColor — wrapping the whole
    // button in Opacity on top of that compounds and can wash text out
    // completely (confirmed on Brutalism). So only the stamped shadow
    // itself is faded here, via its own alpha, leaving the button's own
    // (already-correct) disabled rendering untouched. Dropping the shadow
    // outright instead would make a disabled button look like a flat,
    // different theme, so it's kept — just muted.
    final buttonShadow = onPressed == null
        ? baseShadow.map((s) => s.copyWith(color: s.color.withValues(alpha: s.color.a * 0.4))).toList()
        : baseShadow;

    final radius = _buttonRadius(theme);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: buttonShadow,
      ),
      child: button,
    );
  }

  double _buttonRadius(ThemeData theme) {
    final shape = theme.filledButtonTheme.style?.shape?.resolve({});
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }
}

class ThemeIconButton extends StatelessWidget {
  const ThemeIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: Icon(icon), onPressed: onPressed, tooltip: tooltip);
  }
}

class ThemeTapButton extends StatelessWidget {
  const ThemeTapButton({
    super.key,
    this.child,
    this.onTap,
    this.shape = const RoundedRectangleBorder(),
    this.size,
    this.decoration,
    this.duration = const Duration(milliseconds: 150),
  });

  final Widget? child;
  final VoidCallback? onTap;
  final ShapeBorder shape;
  final Size? size;
  final BoxDecoration? decoration;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: duration,
          width: size?.width,
          height: size?.height,
          alignment: Alignment.center,
          decoration: decoration,
          child: child,
        ),
      ),
    );
  }
}

class ThemeFab extends StatelessWidget {
  const ThemeFab({super.key, required this.icon, this.onPressed, this.label});

  final IconData icon;
  final VoidCallback? onPressed;
  final String? label;

  @override
  Widget build(BuildContext context) {
    if (label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
      );
    }
    return FloatingActionButton(onPressed: onPressed, child: Icon(icon));
  }
}
