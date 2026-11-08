import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

enum UiButtonVariant { primary, secondary, tonal, outline, ghost, danger, success }

class UiButton extends StatelessWidget {
  const UiButton(
    this.label, {
    super.key,
    this.onPressed,
    this.variant = UiButtonVariant.primary,
    this.size = UiSize.md,
    this.icon,
    this.trailingIcon,
    this.loading = false,
    this.expand = false,
  });

  const UiButton.secondary(this.label, {super.key, this.onPressed, this.size = UiSize.md, this.icon, this.trailingIcon, this.loading = false, this.expand = false})
      : variant = UiButtonVariant.secondary;
  const UiButton.tonal(this.label, {super.key, this.onPressed, this.size = UiSize.md, this.icon, this.trailingIcon, this.loading = false, this.expand = false})
      : variant = UiButtonVariant.tonal;
  const UiButton.outline(this.label, {super.key, this.onPressed, this.size = UiSize.md, this.icon, this.trailingIcon, this.loading = false, this.expand = false})
      : variant = UiButtonVariant.outline;
  const UiButton.ghost(this.label, {super.key, this.onPressed, this.size = UiSize.md, this.icon, this.trailingIcon, this.loading = false, this.expand = false})
      : variant = UiButtonVariant.ghost;
  const UiButton.danger(this.label, {super.key, this.onPressed, this.size = UiSize.md, this.icon, this.trailingIcon, this.loading = false, this.expand = false})
      : variant = UiButtonVariant.danger;

  final String label;
  final VoidCallback? onPressed;
  final UiButtonVariant variant;
  final UiSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final p = context.palette;
    final (bg, fg) = switch (variant) {
      UiButtonVariant.primary => (cs.primary, cs.onPrimary),
      UiButtonVariant.secondary => (cs.inverseSurface, cs.onInverseSurface),
      UiButtonVariant.tonal => (cs.secondaryContainer, cs.onSecondaryContainer),
      UiButtonVariant.outline => (Colors.transparent, cs.onSurface),
      UiButtonVariant.ghost => (Colors.transparent, cs.primary),
      UiButtonVariant.danger => (cs.error, cs.onError),
      UiButtonVariant.success => (p.success, p.onSuccess),
    };
    final (h, pad, fs, iconSize) = switch (size) {
      UiSize.sm => (38.0, UiSpace.md, 13.0, 16.0),
      UiSize.md => (context.tokens.controlHeight, UiSpace.xl, 15.0, 20.0),
      UiSize.lg => (60.0, UiSpace.xxl, 16.0, 22.0),
    };
    final enabled = onPressed != null && !loading;
    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(expand ? double.infinity : h, h)),
      padding: WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: pad)),
      elevation: const WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: size == UiSize.sm ? context.tokens.sm : context.tokens.md),
      ),
      side: WidgetStatePropertyAll(
        variant == UiButtonVariant.outline ? BorderSide(color: cs.outlineVariant) : BorderSide.none,
      ),
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled) && bg != Colors.transparent ? cs.onSurface.withValues(alpha: 0.12) : bg,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.disabled) && !loading ? cs.onSurface.withValues(alpha: 0.38) : fg,
      ),
      overlayColor: WidgetStatePropertyAll(fg.withValues(alpha: 0.1)),
      textStyle: WidgetStatePropertyAll(context.text.labelLarge?.copyWith(fontSize: fs, fontWeight: FontWeight.w600)),
      iconSize: WidgetStatePropertyAll(iconSize),
    );

    final content = AnimatedSwitcher(
      duration: UiDuration.fast,
      child: loading
          ? SizedBox.square(
              key: const ValueKey('loading'),
              dimension: iconSize,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon), const UiGap.sm()],
                Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (trailingIcon != null) ...[const UiGap.sm(), Icon(trailingIcon)],
              ],
            ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: loading ? '$label, loading' : null,
      child: TextButton(onPressed: enabled ? onPressed : null, style: style, child: content),
    );
  }
}

enum UiIconButtonVariant { plain, filled, tonal, outline }

class UiIconButton extends StatelessWidget {
  const UiIconButton(
    this.icon, {
    super.key,
    required this.onPressed,
    this.tooltip,
    this.variant = UiIconButtonVariant.tonal,
    this.size = UiSize.md,
    this.badge,
    this.color,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final UiIconButtonVariant variant;
  final UiSize size;
  final String? badge;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final (dim, iconSize) = switch (size) {
      UiSize.sm => (36.0, 18.0),
      UiSize.md => (44.0, 22.0),
      UiSize.lg => (56.0, 26.0),
    };
    final (bg, fg) = switch (variant) {
      UiIconButtonVariant.plain => (Colors.transparent, color ?? cs.onSurface),
      UiIconButtonVariant.filled => (color ?? cs.primary, cs.onPrimary),
      UiIconButtonVariant.tonal => (cs.surfaceContainerHigh, color ?? cs.onSurface),
      UiIconButtonVariant.outline => (Colors.transparent, color ?? cs.onSurface),
    };
    Widget btn = IconButton(
      onPressed: onPressed,
      tooltip: tooltip,
      icon: Icon(icon, size: iconSize),
      style: IconButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        fixedSize: Size.square(dim),
        minimumSize: Size.square(dim),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: context.tokens.full,
          side: variant == UiIconButtonVariant.outline ? BorderSide(color: cs.outlineVariant) : BorderSide.none,
        ),
      ),
    );
    if (badge != null) {
      btn = Badge(
        label: badge!.isEmpty ? null : Text(badge!),
        smallSize: 8,
        offset: const Offset(-2, 2),
        child: btn,
      );
    }
    return btn;
  }
}
