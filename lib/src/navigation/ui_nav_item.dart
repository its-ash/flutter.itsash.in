import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// One destination of a bottom nav, rail, sidebar or drawer.
///
/// ```dart
/// const UiNavItem(Icons.inbox_outlined, 'Inbox', selectedIcon: Icons.inbox, badge: 3);
/// ```
@immutable
class UiNavItem {
  const UiNavItem(this.icon, this.label, {this.selectedIcon, this.badge, this.dot = false});

  final IconData icon;
  final String label;

  /// Icon shown when selected. Defaults to [icon].
  final IconData? selectedIcon;

  /// Count shown in a badge. Null or zero hides it. Values above 99 show "99+".
  final int? badge;

  /// Shows a small dot badge (when [badge] is not set).
  final bool dot;

  /// True when a count or dot badge is shown.
  bool get hasBadge => (badge ?? 0) > 0 || dot;

  /// The badge count as text ("99+" above 99). Empty when there is no count.
  String get badgeText {
    final count = badge ?? 0;
    if (count <= 0) return '';
    return count > 99 ? '99+' : '$count';
  }

  /// The icon for the [selected] state. Adds the badge unless [showBadge] is false.
  /// A null [color] uses the surrounding `IconTheme`.
  Widget buildIcon(BuildContext context, {required bool selected, Color? color, double? size, bool showBadge = true}) {
    final icon = Icon(selected ? (selectedIcon ?? this.icon) : this.icon, color: color, size: size);
    if (!showBadge || !hasBadge) return icon;
    final c = context.colors;
    final text = badgeText;
    return Badge(
      label: text.isEmpty ? null : Text(text),
      backgroundColor: c.danger,
      textColor: c.onDanger,
      smallSize: 8,
      child: icon,
    );
  }
}
