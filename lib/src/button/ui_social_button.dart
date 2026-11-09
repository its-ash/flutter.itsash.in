part of 'ui_button.dart';

/// "Continue with X" sign-in button. Outline style, full width by default.
/// No brand assets are bundled: pass your own logo as [leading] or an [icon].
///
/// ```dart
/// UiSocialButton('Google', leading: Image.asset('assets/google.png', width: 18), onPressed: signIn)
/// ```
class UiSocialButton extends StatelessWidget {
  const UiSocialButton(
    this.provider, {
    super.key,
    this.onPressed,
    this.leading,
    this.icon,
    this.label,
    this.size = UiSize.md,
    this.expand = true,
    this.loading = false,
  });

  /// Provider name, e.g. `Google`.
  final String provider;

  /// Called on tap. Null disables the button.
  final VoidCallback? onPressed;

  /// Logo widget. Wins over [icon].
  final Widget? leading;

  final IconData? icon;

  /// Overrides the default `Continue with <provider>` text.
  final String? label;

  final UiSize size;

  /// Fills the available width.
  final bool expand;

  /// Shows a spinner and blocks taps.
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final lead = leading ?? (icon == null ? null : Icon(icon));
    return _ButtonCore(
      onPressed: onPressed,
      palette: (c, s) {
        final p = _variantPalette(c, UiButtonVariant.outline, null, s);
        return _Palette(Color.alphaBlend(p.bg, c.surface), p.fg, border: p.border);
      },
      size: size,
      expand: expand,
      loading: loading,
      leading: lead == null
          ? null
          : SizedBox.square(
              dimension: size.iconSize + 2,
              child: Center(child: lead),
            ),
      label: Text(label ?? 'Continue with $provider'),
    );
  }
}
