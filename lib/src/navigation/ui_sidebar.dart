import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/navigation/ui_nav_item.dart';

/// A titled group of items in a [UiSidebar] or [UiDrawer].
///
/// ```dart
/// UiSidebarSection(title: 'Workspace', [UiNavItem(Icons.folder_outlined, 'Projects')]);
/// ```
@immutable
class UiSidebarSection {
  const UiSidebarSection(this.items, {this.title});

  final String? title;
  final List<UiNavItem> items;
}

List<UiSidebarSection> _sectionsOf(List<UiNavItem>? items, List<UiSidebarSection>? sections) =>
    sections ?? [UiSidebarSection(items ?? const [])];

/// Desktop sidebar: header, sectioned items, footer, and an optional
/// collapse toggle that shrinks it to an icon-only strip.
///
/// The selected [index] counts items across all sections in order.
///
/// ```dart
/// UiSidebar(items: items, index: page, onChanged: (i) => setState(() => page = i), header: const Logo());
/// ```
class UiSidebar extends StatefulWidget {
  const UiSidebar({
    super.key,
    this.items,
    this.sections,
    required this.index,
    required this.onChanged,
    this.header,
    this.footer,
    this.collapsible = false,
    this.collapsed = false,
    this.onCollapsedChanged,
    this.width = 264,
    this.border = true,
  }) : assert(items != null || sections != null, 'Pass items or sections');

  /// Items without a section title. Ignored when [sections] is set.
  final List<UiNavItem>? items;
  final List<UiSidebarSection>? sections;
  final int index;

  /// Called with the tapped item index. Null disables the items.
  final ValueChanged<int>? onChanged;

  /// Shown at the top (logo, workspace switcher). Hidden when collapsed.
  final Widget? header;

  /// Shown at the bottom (account, settings). Hidden when collapsed.
  final Widget? footer;

  /// Shows a collapse / expand toggle above the footer.
  final bool collapsible;

  /// Starts collapsed. Updating it collapses or expands the sidebar.
  final bool collapsed;

  /// Called when the user toggles the collapsed state.
  final ValueChanged<bool>? onCollapsedChanged;

  /// Width when expanded.
  final double width;

  /// Draws a hairline on the trailing edge.
  final bool border;

  /// Width when collapsed.
  static const double collapsedWidth = 72;

  @override
  State<UiSidebar> createState() => _UiSidebarState();
}

class _UiSidebarState extends State<UiSidebar> {
  late bool _collapsed = widget.collapsed;

  @override
  void didUpdateWidget(UiSidebar old) {
    super.didUpdateWidget(old);
    if (widget.collapsed != old.collapsed) _collapsed = widget.collapsed;
  }

  void _toggle() {
    setState(() => _collapsed = !_collapsed);
    widget.onCollapsedChanged?.call(_collapsed);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = MaterialLocalizations.of(context);
    return AnimatedContainer(
      duration: context.motion(UiMotion.normal),
      curve: UiMotion.standard,
      width: _collapsed ? UiSidebar.collapsedWidth : widget.width,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: c.surface,
        border: widget.border ? BorderDirectional(end: BorderSide(color: c.border)) : null,
      ),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          right: false,
          child: LayoutBuilder(
            builder: (context, box) {
              final compact = box.maxWidth < 180;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (widget.header != null && !compact)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.lg, UiSpace.lg, UiSpace.sm),
                      child: widget.header,
                    )
                  else
                    const SizedBox(height: UiSpace.sm),
                  Expanded(
                    child: _SidebarList(
                      sections: _sectionsOf(widget.items, widget.sections),
                      index: widget.index,
                      onChanged: widget.onChanged,
                      compact: compact,
                    ),
                  ),
                  if (widget.collapsible)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: UiSpace.xs),
                      child: _SidebarItem(
                        item: UiNavItem(
                          _collapsed
                              ? Icons.keyboard_double_arrow_right_rounded
                              : Icons.keyboard_double_arrow_left_rounded,
                          _collapsed ? l.collapsedIconTapHint : l.expandedIconTapHint,
                        ),
                        selected: false,
                        compact: compact,
                        onTap: _toggle,
                      ),
                    ),
                  if (widget.footer != null && !compact)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.sm, UiSpace.lg, UiSpace.lg),
                      child: widget.footer,
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Modern navigation drawer: header slot, sectioned items with a soft
/// selected pill, footer slot. Closes itself after a tap.
///
/// ```dart
/// Scaffold(drawer: UiDrawer(items: items, index: page, onChanged: (i) => setState(() => page = i)));
/// ```
class UiDrawer extends StatelessWidget {
  const UiDrawer({
    super.key,
    this.items,
    this.sections,
    required this.index,
    required this.onChanged,
    this.header,
    this.footer,
    this.width = 304,
    this.closeOnTap = true,
  }) : assert(items != null || sections != null, 'Pass items or sections');

  final List<UiNavItem>? items;
  final List<UiSidebarSection>? sections;
  final int index;

  /// Called with the tapped item index. Null disables the items.
  final ValueChanged<int>? onChanged;
  final Widget? header;
  final Widget? footer;
  final double width;

  /// Closes the drawer after an item is tapped.
  final bool closeOnTap;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    final screen = MediaQuery.sizeOf(context).width;
    return Drawer(
      width: math.min(width, math.max(0.0, screen - 56)),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadiusDirectional.horizontal(end: Radius.circular(UiRadius.xl)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (header != null)
              Padding(padding: const EdgeInsets.fromLTRB(UiSpace.xl, UiSpace.lg, UiSpace.xl, UiSpace.sm), child: header)
            else
              const SizedBox(height: UiSpace.md),
            Expanded(
              child: _SidebarList(
                sections: _sectionsOf(items, sections),
                index: index,
                compact: false,
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.sm),
                onChanged: onChanged == null
                    ? null
                    : (i) {
                        onChanged(i);
                        if (!closeOnTap) return;
                        final scaffold = Scaffold.maybeOf(context);
                        if (scaffold == null) return;
                        if (scaffold.isDrawerOpen) scaffold.closeDrawer();
                        if (scaffold.isEndDrawerOpen) scaffold.closeEndDrawer();
                      },
              ),
            ),
            if (footer != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(UiSpace.xl, UiSpace.sm, UiSpace.xl, UiSpace.lg),
                child: footer,
              ),
          ],
        ),
      ),
    );
  }
}

class _SidebarList extends StatelessWidget {
  const _SidebarList({
    required this.sections,
    required this.index,
    required this.onChanged,
    required this.compact,
    this.padding = const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: UiSpace.xs),
  });

  final List<UiSidebarSection> sections;
  final int index;
  final ValueChanged<int>? onChanged;
  final bool compact;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final onChanged = this.onChanged;
    final children = <Widget>[];
    var flat = 0;
    for (var s = 0; s < sections.length; s++) {
      final section = sections[s];
      final title = section.title;
      if (title != null) {
        if (compact) {
          if (s > 0) {
            children.add(
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.sm),
                child: Divider(height: 1, thickness: 1, color: c.border),
              ),
            );
          }
        } else {
          children.add(
            Padding(
              padding: EdgeInsets.fromLTRB(UiSpace.md, s == 0 ? UiSpace.xs : UiSpace.lg, UiSpace.md, UiSpace.xs),
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelSmall!.copyWith(color: c.textSubtle),
              ),
            ),
          );
        }
      } else if (s > 0) {
        children.add(const SizedBox(height: UiSpace.md));
      }
      for (final item in section.items) {
        final i = flat++;
        children.add(
          Padding(
            padding: const EdgeInsets.only(bottom: UiSpace.xxs),
            child: _SidebarItem(
              item: item,
              selected: i == index,
              compact: compact,
              onTap: onChanged == null ? null : () => onChanged(i),
            ),
          ),
        );
      }
    }
    return ListView(padding: padding, children: children);
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({required this.item, required this.selected, required this.compact, required this.onTap});

  final UiNavItem item;
  final bool selected;
  final bool compact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onTap != null;
    final iconColor = !enabled
        ? c.textDisabled
        : selected
        ? c.onAccentSoft
        : c.textMuted;
    final labelColor = !enabled
        ? c.textDisabled
        : selected
        ? c.onAccentSoft
        : c.text;
    final radius = UiRadius.all(UiRadius.sm);

    Widget content;
    if (compact) {
      content = Center(
        child: item.buildIcon(context, selected: selected, color: iconColor, size: 20),
      );
    } else {
      content = Row(
        children: [
          item.buildIcon(context, selected: selected, color: iconColor, size: 20, showBadge: false),
          const SizedBox(width: UiSpace.md),
          Expanded(
            child: Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium!.copyWith(
                color: labelColor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          if (item.hasBadge) ...[const SizedBox(width: UiSpace.sm), _SidebarBadge(item: item, selected: selected)],
        ],
      );
    }

    content = AnimatedContainer(
      duration: context.motion(UiMotion.fast),
      height: 40,
      padding: EdgeInsets.symmetric(horizontal: compact ? 0 : UiSpace.md),
      decoration: BoxDecoration(
        color: selected ? (enabled ? c.accentSoft : c.surfaceMuted) : c.accentSoft.withValues(alpha: 0),
        borderRadius: radius,
      ),
      child: content,
    );
    content = InkWell(onTap: onTap, borderRadius: radius, child: content);
    if (compact) content = Tooltip(message: item.label, child: content);
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      enabled: enabled,
      label: compact ? item.label : null,
      child: content,
    );
  }
}

class _SidebarBadge extends StatelessWidget {
  const _SidebarBadge({required this.item, required this.selected});

  final UiNavItem item;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = item.badgeText;
    if (text.isEmpty) {
      return Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: c.danger, shape: BoxShape.circle),
      );
    }
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: selected ? c.surface : c.surfaceMuted,
        borderRadius: UiRadius.all(UiRadius.full),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: context.text.labelSmall!.copyWith(color: selected ? c.onAccentSoft : c.textMuted, letterSpacing: 0),
      ),
    );
  }
}
