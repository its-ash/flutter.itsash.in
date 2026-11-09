import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/navigation/ui_nav_item.dart';

/// Vertical navigation rail for tablets and small laptops.
///
/// Built on Material's `NavigationRail`, with a surface background, a right
/// hairline and badge support. Needs at least two [items].
///
/// ```dart
/// UiNavRail(items: items, index: tab, onChanged: (i) => setState(() => tab = i));
/// ```
class UiNavRail extends StatelessWidget {
  const UiNavRail({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.leading,
    this.trailing,
    this.extended = false,
    this.showLabels = true,
    this.border = true,
  });

  final List<UiNavItem> items;
  final int index;

  /// Called with the tapped index. Null disables the rail.
  final ValueChanged<int>? onChanged;

  /// Shown above the items (logo, FAB).
  final Widget? leading;

  /// Shown below the items.
  final Widget? trailing;

  /// Shows labels next to the icons in a wider rail.
  final bool extended;

  /// Shows labels under the icons when not [extended].
  final bool showLabels;

  /// Draws a hairline on the trailing edge.
  final bool border;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rail = NavigationRail(
      selectedIndex: items.isEmpty ? null : index.clamp(0, items.length - 1),
      onDestinationSelected: onChanged,
      extended: extended,
      labelType: extended
          ? NavigationRailLabelType.none
          : showLabels
          ? NavigationRailLabelType.all
          : NavigationRailLabelType.none,
      leading: leading,
      trailing: trailing,
      groupAlignment: -1,
      minWidth: 80,
      minExtendedWidth: 240,
      backgroundColor: c.surface,
      destinations: [
        for (final item in items)
          NavigationRailDestination(
            icon: item.buildIcon(context, selected: false),
            selectedIcon: item.buildIcon(context, selected: true),
            label: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis),
            disabled: onChanged == null,
          ),
      ],
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: border ? BorderDirectional(end: BorderSide(color: c.border)) : null,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.only(end: border ? 1 : 0),
        child: SafeArea(right: false, child: rail),
      ),
    );
  }
}
