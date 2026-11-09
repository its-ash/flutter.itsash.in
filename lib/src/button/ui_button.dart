import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:theme/src/foundation/foundation.dart';

part 'button_core.dart';
part 'ui_button_bar.dart';
part 'ui_copy_button.dart';
part 'ui_fab.dart';
part 'ui_hold_button.dart';
part 'ui_icon_button.dart';
part 'ui_segmented_control.dart';
part 'ui_social_button.dart';
part 'ui_toggle.dart';

/// Visual style of a button.
enum UiButtonVariant {
  /// Accent fill. The main action on a screen.
  primary,

  /// Muted fill with normal text color.
  secondary,

  /// Soft accent tint.
  soft,

  /// Transparent with a 1 px border.
  outline,

  /// Transparent; tints on hover and press.
  ghost,

  /// Danger fill for destructive actions.
  danger,

  /// Accent text only, underlined on hover.
  link,
}

/// Text button with an optional icon, loading state and variants.
///
/// ```dart
/// UiButton('Save', onPressed: save)
/// UiButton('Delete', variant: UiButtonVariant.danger, icon: Icons.delete_rounded, onPressed: delete)
/// ```
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
    this.status,
  });

  /// Button text. Ellipsizes when there is no room.
  final String label;

  /// Called on tap. Null disables the button.
  final VoidCallback? onPressed;

  final UiButtonVariant variant;
  final UiSize size;

  /// Icon before the label.
  final IconData? icon;

  /// Icon after the label.
  final IconData? trailingIcon;

  /// Shows a spinner, keeps the width and blocks taps.
  final bool loading;

  /// Fills the available width.
  final bool expand;

  /// Recolors the variant with a status tone (e.g. `UiStatus.success`).
  /// Ignored by [UiButtonVariant.danger].
  final UiStatus? status;

  @override
  Widget build(BuildContext context) {
    final isLink = variant == UiButtonVariant.link;
    return _ButtonCore(
      onPressed: onPressed,
      palette: (c, s) => _variantPalette(c, variant, status, s),
      size: size,
      loading: loading,
      expand: expand,
      flat: isLink,
      underlineOnHover: isLink,
      leading: icon == null ? null : Icon(icon),
      label: Text(label),
      trailing: trailingIcon == null ? null : Icon(trailingIcon),
    );
  }
}
