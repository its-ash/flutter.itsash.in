import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/navigation/ui_bottom_nav.dart';
import 'package:theme/src/navigation/ui_nav_item.dart';
import 'package:theme/src/navigation/ui_nav_rail.dart';
import 'package:theme/src/navigation/ui_sidebar.dart';

/// Adaptive app shell with top-level navigation.
///
/// - compact (phones): bottom nav bar ([floatingNav] for the pill style)
/// - medium / expanded (tablets): navigation rail
/// - large (desktop): full sidebar with [header] and [footer]
///
/// Pass [pages] to keep every page alive in an `IndexedStack` (scroll
/// position and state survive tab switches), or [body] to build the current
/// page yourself. Page state also survives window resizes.
///
/// ```dart
/// UiShell(items: items, index: tab, onChanged: (i) => setState(() => tab = i), pages: pages);
/// ```
class UiShell extends StatefulWidget {
  const UiShell({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.pages,
    this.body,
    this.appBar,
    this.fab,
    this.header,
    this.footer,
    this.railHeader,
    this.railFooter,
    this.floatingNav = false,
    this.sidebarCollapsible = false,
  }) : assert((pages == null) != (body == null), 'Pass either pages or body');

  final List<UiNavItem> items;
  final int index;

  /// Called with the tapped index. Null disables the navigation.
  final ValueChanged<int>? onChanged;

  /// One page per item, kept alive in an `IndexedStack`.
  final List<Widget>? pages;

  /// The current page. Use instead of [pages].
  final Widget? body;

  /// Shown above the page content (next to the rail or sidebar on wide screens).
  final PreferredSizeWidget? appBar;

  /// Floating action button.
  final Widget? fab;

  /// Top of the desktop sidebar (logo, workspace).
  final Widget? header;

  /// Bottom of the desktop sidebar (account, settings).
  final Widget? footer;

  /// Top of the rail (small logo or FAB).
  final Widget? railHeader;

  /// Bottom of the rail.
  final Widget? railFooter;

  /// Uses the floating pill bottom nav on phones.
  final bool floatingNav;

  /// Lets users collapse the desktop sidebar.
  final bool sidebarCollapsible;

  @override
  State<UiShell> createState() => _UiShellState();
}

class _UiShellState extends State<UiShell> {
  final _contentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final pages = w.pages;
    final content = KeyedSubtree(
      key: _contentKey,
      child: pages != null
          ? IndexedStack(index: pages.isEmpty ? null : w.index.clamp(0, pages.length - 1), children: pages)
          : w.body!,
    );

    final bp = context.breakpoint;
    if (bp == UiBreakpoint.compact) {
      return Scaffold(
        appBar: w.appBar,
        body: content,
        floatingActionButton: w.fab,
        extendBody: w.floatingNav,
        bottomNavigationBar: UiBottomNav(
          items: w.items,
          index: w.index,
          onChanged: w.onChanged,
          floating: w.floatingNav,
        ),
      );
    }

    final Widget nav = bp == UiBreakpoint.large
        ? UiSidebar(
            items: w.items,
            index: w.index,
            onChanged: w.onChanged,
            header: w.header,
            footer: w.footer,
            collapsible: w.sidebarCollapsible,
          )
        : UiNavRail(
            items: w.items,
            index: w.index,
            onChanged: w.onChanged,
            leading: w.railHeader,
            trailing: w.railFooter,
          );

    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          nav,
          Expanded(
            child: MediaQuery.removePadding(
              context: context,
              removeLeft: Directionality.of(context) == TextDirection.ltr,
              removeRight: Directionality.of(context) == TextDirection.rtl,
              child: Scaffold(appBar: w.appBar, body: content, floatingActionButton: w.fab),
            ),
          ),
        ],
      ),
    );
  }
}
