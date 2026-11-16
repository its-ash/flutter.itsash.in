import 'package:flutter/material.dart';

import 'package:theme/src/display/display_shared.dart';
import 'package:theme/src/display/ui_key_value.dart';
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
      decoration: BoxDecoration(color: bg, borderRadius: UiRadius.all(size >= 32 ? UiRadius.md : UiRadius.sm)),
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

    // Figma "menu item list": regular 14 title, 12 gray-5 captions, gray-5
    // value and 16 px chevron; solid Primary row when selected.
    final titleColor = !enabled
        ? colors.textDisabled
        : selected
        ? colors.onAccent
        : destructive
        ? colors.danger
        : colors.text;
    final mutedColor = !enabled
        ? colors.textDisabled
        : selected
        ? colors.onAccent.withValues(alpha: 0.8)
        : colors.textSubtle;
    final iconSize = dense ? 24.0 : 28.0;

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
      padding: EdgeInsets.only(right: UiSpace.page, top: dense ? 6 : UiSpace.sm, bottom: dense ? 6 : UiSpace.sm),
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
                  style: text.bodyMedium?.copyWith(color: titleColor),
                ),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: UiSpace.xxs),
                    child: Text(
                      subtitle!,
                      maxLines: maxSubtitleLines,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodySmall?.copyWith(color: mutedColor),
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
                  style: text.bodyMedium?.copyWith(color: mutedColor),
                ),
              ),
            ),
          // Flexible: a wide trailing control (a button with a long label)
          // shrinks and ellipsizes instead of overflowing on narrow phones.
          if (trailing != null)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(left: UiSpace.sm),
                child: trailing,
              ),
            ),
          if (chevron)
            Padding(
              padding: const EdgeInsets.only(left: UiSpace.sm),
              child: Icon(Icons.chevron_right_rounded, size: 16, color: mutedColor),
            ),
        ],
      ),
    );

    Widget row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: dense ? 36 : 44),
      child: Row(
        children: [
          const SizedBox(width: UiSpace.page),
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
      color: selected ? colors.accent : null,
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
    final rows = [
      for (var i = 0; i < children.length; i++) ..._groupRow(children[i], divide: dividers && i < children.length - 1),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) _GroupHeader(header!),
        Material(
          color: inset ? colors.surface : Colors.transparent,
          clipBehavior: Clip.antiAlias,
          shape: inset
              ? RoundedRectangleBorder(borderRadius: UiRadius.all(UiRadius.lg))
              : Border.symmetric(horizontal: BorderSide(color: colors.border)),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
        ),
        if (footer != null) _GroupFooter(footer!, style: text.bodySmall?.copyWith(color: colors.textSubtle)),
      ],
    );
  }
}

/// Lazy [UiListGroup] for long lists, as a sliver: only the rows near the
/// screen are built. Same look: header, rounded surface, dividers, footer.
///
/// Put it in a `CustomScrollView` or `UiScaffold.slivers`.
///
/// ```dart
/// UiSliverListGroup(header: 'Apps', itemCount: apps.length, itemBuilder: (context, i) => UiListTile(apps[i].name))
/// ```
class UiSliverListGroup extends StatelessWidget {
  const UiSliverListGroup({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.header,
    this.footer,
    this.inset = true,
    this.dividers = true,
  });

  final int itemCount;

  /// Builds row `index`. Called only when it comes near the screen.
  final IndexedWidgetBuilder itemBuilder;

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
    final last = itemCount - 1;
    final radius = Radius.circular(UiRadius.lg);
    final side = BorderSide(color: colors.border);

    Widget row(BuildContext context, int i) {
      final first = i == 0;
      final end = i == last;
      return Material(
        color: inset ? colors.surface : Colors.transparent,
        clipBehavior: first || end ? Clip.antiAlias : Clip.none,
        shape: inset
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  top: first ? radius : Radius.zero,
                  bottom: end ? radius : Radius.zero,
                ),
              )
            : Border(top: first ? side : BorderSide.none, bottom: end ? side : BorderSide.none),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _groupRow(itemBuilder(context, i), divide: dividers && !end),
        ),
      );
    }

    return SliverMainAxisGroup(
      slivers: [
        if (header != null) SliverToBoxAdapter(child: _GroupHeader(header!)),
        SliverList.builder(itemCount: itemCount, itemBuilder: row),
        if (footer != null)
          SliverToBoxAdapter(
            child: _GroupFooter(footer!, style: context.text.bodySmall?.copyWith(color: colors.textSubtle)),
          ),
      ],
    );
  }
}

/// One row of a list group, plus its divider when it needs one.
List<Widget> _groupRow(Widget child, {required bool divide}) {
  if (child is UiListTile) return [DisplayDividerScope(divider: divide, child: child)];
  // Key-value rows have no horizontal padding of their own: inset them
  // like a UiListTile so the text does not touch the card edge.
  final padded = child is UiKeyValue || child is UiKeyValueList
      ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.page),
          child: child,
        )
      : child;
  return [
    DisplayDividerScope(divider: false, child: padded),
    if (divide) const Divider(height: 1, indent: UiSpace.page),
  ];
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(UiSpace.page, 0, UiSpace.page, UiSpace.sm),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.text.labelLarge?.copyWith(color: context.colors.text),
      ),
    );
  }
}

class _GroupFooter extends StatelessWidget {
  const _GroupFooter(this.text, {this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(UiSpace.page, UiSpace.sm, UiSpace.page, 0),
      child: Text(text, style: style),
    );
  }
}
