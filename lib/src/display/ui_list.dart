import 'package:flutter/material.dart';

import 'package:theme/src/display/display_shared.dart';
import 'package:theme/src/foundation/foundation.dart';

/// An icon in a tinted rounded square, used as a list or card leading.
///
/// ```dart
/// UiIconBox(Icons.wifi_rounded, status: UiStatus.info)
/// ```
class UiIconBox extends StatelessWidget {
  const UiIconBox(
    this.icon, {
    super.key,
    this.status = UiStatus.accent,
    this.color,
    this.size = 32,
    this.solid = false,
  });

  final IconData icon;

  /// Tint of the box. Ignored when [color] is set.
  final UiStatus status;

  /// Custom tint color (e.g. a brand or category color).
  final Color? color;

  /// Width and height of the box.
  final double size;

  /// Solid fill with contrasting icon instead of a soft tint.
  final bool solid;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Color bg;
    final Color fg;
    final custom = color;
    if (custom != null) {
      bg = solid ? custom : displaySoft(colors, custom);
      fg = solid ? colors.surface : displayOnSoft(colors, custom);
    } else {
      final tone = colors.tone(status);
      bg = solid ? tone.color : tone.soft;
      fg = solid ? tone.onColor : (status == UiStatus.neutral ? colors.textMuted : tone.onSoft);
    }
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: UiRadius.all(size * 0.3)),
      child: Icon(icon, size: size * 0.56, color: fg),
    );
  }
}

/// A row with title, optional subtitle, leading and trailing widgets.
///
/// Inside a [UiListGroup] it draws iOS-style dividers that start under the text.
///
/// ```dart
/// UiListTile('Notifications', icon: Icons.notifications_rounded, chevron: true, onTap: open)
/// ```
class UiListTile extends StatelessWidget {
  const UiListTile(
    this.title, {
    super.key,
    this.subtitle,
    this.leading,
    this.icon,
    this.iconStatus = UiStatus.accent,
    this.iconColor,
    this.trailing,
    this.value,
    this.onTap,
    this.onLongPress,
    this.chevron = false,
    this.dense = false,
    this.destructive = false,
    this.selected = false,
    this.enabled = true,
    this.maxSubtitleLines = 2,
  });

  final String title;
  final String? subtitle;

  /// Any leading widget (avatar, checkbox, image). Takes precedence over [icon].
  final Widget? leading;

  /// Shortcut for a [UiIconBox] leading.
  final IconData? icon;
  final UiStatus iconStatus;
  final Color? iconColor;

  /// Any trailing widget (switch, badge, button).
  final Widget? trailing;

  /// Short muted text shown at the end, before [trailing] (e.g. "English").
  final String? value;

  /// Null means the row is not interactive (it still looks enabled).
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  /// Shows a chevron at the end, for rows that navigate.
  final bool chevron;
  final bool dense;

  /// Danger-colored title and icon (e.g. "Delete account").
  final bool destructive;

  /// Accent-tinted background.
  final bool selected;

  /// When false the row is greyed out and ignores taps.
  final bool enabled;
  final int maxSubtitleLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final divider = DisplayDividerScope.of(context);

    final titleColor = !enabled
        ? colors.textDisabled
        : destructive
        ? colors.danger
        : colors.text;
    final iconSize = dense ? 28.0 : 32.0;

    Widget? lead = leading;
    if (lead == null && icon != null) {
      lead = UiIconBox(
        icon!,
        size: iconSize,
        status: destructive ? UiStatus.danger : iconStatus,
        color: destructive ? null : iconColor,
      );
    }

    final body = Padding(
      padding: EdgeInsets.only(
        right: UiSpace.lg,
        top: dense ? UiSpace.sm : UiSpace.md,
        bottom: dense ? UiSpace.sm : UiSpace.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: (dense ? text.bodyMedium : text.bodyLarge)?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: UiSpace.xxs),
                    child: Text(
                      subtitle!,
                      maxLines: maxSubtitleLines,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(color: enabled ? colors.textMuted : colors.textDisabled),
                    ),
                  ),
              ],
            ),
          ),
          if (value != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: UiSpace.sm),
                child: Text(
                  value!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: text.bodyMedium?.copyWith(color: enabled ? colors.textMuted : colors.textDisabled),
                ),
              ),
            ),
          if (trailing != null)
            Padding(
              padding: const EdgeInsets.only(left: UiSpace.sm),
              child: trailing,
            ),
          if (chevron)
            Padding(
              padding: const EdgeInsets.only(left: UiSpace.xs),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: enabled ? colors.textSubtle : colors.textDisabled,
              ),
            ),
        ],
      ),
    );

    Widget row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: dense ? 44 : 52),
      child: Row(
        children: [
          const SizedBox(width: UiSpace.lg),
          if (lead != null)
            Padding(
              padding: const EdgeInsets.only(right: UiSpace.md),
              child: Opacity(opacity: enabled ? 1 : 0.5, child: lead),
            ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [body, if (divider) const Divider(height: 1)],
            ),
          ),
        ],
      ),
    );

    final interactive = enabled && (onTap != null || onLongPress != null);
    row = Material(
      type: selected ? MaterialType.canvas : MaterialType.transparency,
      color: selected ? colors.accentSoft : null,
      child: InkWell(onTap: interactive ? onTap : null, onLongPress: interactive ? onLongPress : null, child: row),
    );

    return Semantics(button: interactive, enabled: enabled, selected: selected, child: row);
  }
}

/// iOS-style grouped list: rows in a rounded surface with hairline dividers,
/// and optional header and footer captions. Great for settings screens.
///
/// ```dart
/// UiListGroup(header: 'Account', children: [UiListTile('Profile', chevron: true, onTap: open)])
/// ```
class UiListGroup extends StatelessWidget {
  const UiListGroup({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.inset = true,
    this.dividers = true,
  });

  final List<Widget> children;

  /// Caption above the group.
  final String? header;

  /// Caption below the group (help text).
  final String? footer;

  /// Rounded, bordered card. When false the group is full-bleed with top and
  /// bottom borders only.
  final bool inset;
  final bool dividers;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      final child = children[i];
      final divide = dividers && i < children.length - 1;
      if (child is UiListTile) {
        rows.add(DisplayDividerScope(divider: divide, child: child));
      } else {
        rows.add(DisplayDividerScope(divider: false, child: child));
        if (divide) rows.add(const Divider(height: 1, indent: UiSpace.lg));
      }
    }

    final captionPad = EdgeInsets.symmetric(horizontal: inset ? UiSpace.lg : UiSpace.page);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null)
          Padding(
            padding: captionPad.copyWith(bottom: UiSpace.sm),
            child: Text(
              header!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.labelMedium?.copyWith(color: colors.textMuted),
            ),
          ),
        Material(
          color: colors.surface,
          clipBehavior: Clip.antiAlias,
          shape: inset
              ? RoundedRectangleBorder(
                  borderRadius: UiRadius.all(UiRadius.lg),
                  side: BorderSide(color: colors.border),
                )
              : Border.symmetric(horizontal: BorderSide(color: colors.border)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
        ),
        if (footer != null)
          Padding(
            padding: captionPad.copyWith(top: UiSpace.sm),
            child: Text(footer!, style: text.bodySmall?.copyWith(color: colors.textSubtle)),
          ),
      ],
    );
  }
}
