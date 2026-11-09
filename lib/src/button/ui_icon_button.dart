part of 'ui_button.dart';

/// Square or circular icon-only button with a tooltip and an optional badge.
///
/// ```dart
/// UiIconButton(Icons.notifications_rounded, tooltip: 'Inbox', badge: 3, onPressed: open)
/// ```
class UiIconButton extends StatelessWidget {
  const UiIconButton(
    this.icon, {
    super.key,
    required this.tooltip,
    this.onPressed,
    this.variant = UiButtonVariant.ghost,
    this.size = UiSize.md,
    this.badge,
    this.dot = false,
    this.circular = false,
    this.loading = false,
    this.status,
  });

  final IconData icon;

  /// Tooltip and screen-reader label.
  final String tooltip;

  /// Called on tap. Null disables the button.
  final VoidCallback? onPressed;

  final UiButtonVariant variant;
  final UiSize size;

  /// Count shown in a small pill on the corner. Zero or null hides it. Over 99 shows `99+`.
  final int? badge;

  /// Shows a small dot on the corner (when [badge] is not shown).
  final bool dot;

  /// Round instead of rounded-square.
  final bool circular;

  /// Shows a spinner and blocks taps.
  final bool loading;

  /// Recolors the variant with a status tone.
  final UiStatus? status;

  @override
  Widget build(BuildContext context) {
    final count = badge ?? 0;
    return _ButtonCore(
      onPressed: onPressed,
      palette: (c, s) => _variantPalette(c, variant, status, s),
      size: size,
      square: true,
      circular: circular,
      loading: loading,
      tooltip: tooltip,
      leading: Icon(icon),
      badge: count > 0
          ? _Badge(count: count)
          : dot
          ? const _Badge()
          : null,
    );
  }
}
