part of 'ui_button.dart';

/// Floating action button. Icon only, or extended with a label.
/// Works as `Scaffold.floatingActionButton`.
///
/// ```dart
/// floatingActionButton: UiFab(Icons.add_rounded, label: 'New', onPressed: create)
/// ```
class UiFab extends StatelessWidget {
  const UiFab(this.icon, {super.key, this.onPressed, this.label, this.tooltip, this.variant = UiButtonVariant.primary});

  final IconData icon;

  /// Called on tap. Null disables the button.
  final VoidCallback? onPressed;

  /// Makes the button extended (icon + label).
  final String? label;

  /// Tooltip and screen-reader label. Set it for icon-only buttons.
  final String? tooltip;

  final UiButtonVariant variant;

  /// Height of the button.
  static const double height = 56;

  @override
  Widget build(BuildContext context) {
    final extended = label != null;
    return _ButtonCore(
      onPressed: onPressed,
      palette: (c, s) => _variantPalette(c, variant, null, s),
      size: UiSize.lg,
      height: height,
      radius: UiRadius.lg,
      square: !extended,
      shadow: context.shadowMd,
      tooltip: tooltip,
      leading: Icon(icon, size: 24),
      label: extended ? Text(label!) : null,
    );
  }
}
