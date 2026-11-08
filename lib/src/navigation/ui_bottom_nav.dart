import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

@immutable
class UiNavItem {
  const UiNavItem({required this.icon, required this.label, this.selectedIcon, this.badge});

  final IconData icon;
  final IconData? selectedIcon;
  final String label;
  final String? badge;

  Widget iconWidget({bool selected = false, Color? color, double? size}) {
    final i = Icon(selected ? (selectedIcon ?? icon) : icon, color: color, size: size);
    final b = badge;
    return b == null ? i : Badge(label: b.isEmpty ? null : Text(b), smallSize: 8, child: i);
  }
}

class UiBottomNav extends StatelessWidget {
  const UiBottomNav({super.key, required this.items, required this.index, required this.onChanged});

  final List<UiNavItem> items;
  final int index;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    if (items.length < 2) return const SizedBox.shrink();
    return NavigationBar(
      selectedIndex: index.clamp(0, items.length - 1),
      onDestinationSelected: onChanged,
      destinations: [
        for (final it in items)
          NavigationDestination(
            icon: it.iconWidget(),
            selectedIcon: it.iconWidget(selected: true),
            label: it.label,
          ),
      ],
    );
  }
}

class UiFloatingNavBar extends StatelessWidget {
  const UiFloatingNavBar({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.margin = const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.md),
    this.maxWidth = 480,
  });

  final List<UiNavItem> items;
  final int index;
  final ValueChanged<int>? onChanged;
  final EdgeInsets margin;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final sel = index.clamp(0, items.length - 1);
    return SafeArea(
      top: false,
      minimum: margin,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: context.tokens.full,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: context.isDark ? 0.4 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: cs.surfaceContainerHigh,
              shape: RoundedRectangleBorder(
                borderRadius: context.tokens.full,
                side: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(UiSpace.sm - 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    for (var i = 0; i < items.length; i++)
                      Flexible(
                        flex: i == sel ? 2 : 1,
                        child: _FloatingItem(item: items[i], selected: i == sel, onTap: onChanged == null ? null : () => onChanged!(i)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FloatingItem extends StatelessWidget {
  const _FloatingItem({required this.item, required this.selected, required this.onTap});

  final UiNavItem item;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final fg = selected ? cs.onPrimary : cs.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: Tooltip(
        message: item.label,
        excludeFromSemantics: true,
        child: InkWell(
          onTap: onTap,
          borderRadius: context.tokens.full,
          child: AnimatedContainer(
            duration: UiDuration.normal,
            curve: UiCurve.emphasized,
            height: 48,
            padding: EdgeInsets.symmetric(horizontal: selected ? UiSpace.lg : UiSpace.md),
            decoration: BoxDecoration(color: selected ? cs.primary : Colors.transparent, borderRadius: context.tokens.full),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                item.iconWidget(selected: selected, color: fg, size: 22),
                Flexible(
                  child: AnimatedSize(
                    duration: UiDuration.normal,
                    curve: UiCurve.emphasized,
                    child: selected
                        ? Padding(
                            padding: const EdgeInsets.only(left: UiSpace.sm),
                            child: Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelLarge?.copyWith(color: fg, fontWeight: FontWeight.w700),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UiAdaptiveShell extends StatefulWidget {
  const UiAdaptiveShell({
    super.key,
    required this.destinations,
    required this.pages,
    this.initialIndex = 0,
    this.onChanged,
    this.header,
    this.floatingActionButton,
    this.appBar,
    this.floating = false,
  });

  final List<UiNavItem> destinations;
  final List<Widget> pages;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final Widget? header;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? appBar;
  final bool floating;

  @override
  State<UiAdaptiveShell> createState() => _UiAdaptiveShellState();
}

class _UiAdaptiveShellState extends State<UiAdaptiveShell> {
  late int _index = widget.initialIndex;
  final _stack = GlobalKey();

  int get _count => widget.destinations.length < widget.pages.length ? widget.destinations.length : widget.pages.length;

  void _select(int i) {
    if (i == _index) return;
    setState(() => _index = i);
    widget.onChanged?.call(i);
  }

  @override
  Widget build(BuildContext context) {
    final n = _count;
    if (n == 0) return Scaffold(appBar: widget.appBar, body: const SizedBox.shrink());
    final i = _index.clamp(0, n - 1);
    final items = widget.destinations.take(n).toList();
    final body = IndexedStack(key: _stack, index: i, children: widget.pages.take(n).toList());
    final width = MediaQuery.sizeOf(context).width;

    if (n < 2 || width < UiBreakpoint.compact) {
      return Scaffold(
        appBar: widget.appBar,
        body: body,
        extendBody: widget.floating,
        floatingActionButton: widget.floatingActionButton,
        bottomNavigationBar: n < 2
            ? null
            : widget.floating
                ? UiFloatingNavBar(items: items, index: i, onChanged: _select)
                : UiBottomNav(items: items, index: i, onChanged: _select),
      );
    }

    final extended = width >= UiBreakpoint.expanded;
    return Scaffold(
      appBar: widget.appBar,
      floatingActionButton: widget.floatingActionButton,
      body: Row(
        children: [
          NavigationRail(
            extended: extended,
            minExtendedWidth: 232,
            labelType: extended ? NavigationRailLabelType.none : NavigationRailLabelType.all,
            selectedIndex: i,
            onDestinationSelected: _select,
            leading: widget.header == null
                ? null
                : Padding(padding: const EdgeInsets.symmetric(vertical: UiSpace.sm), child: widget.header),
            groupAlignment: -1,
            destinations: [
              for (final it in items)
                NavigationRailDestination(
                  icon: it.iconWidget(),
                  selectedIcon: it.iconWidget(selected: true),
                  label: Text(it.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
            ],
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: body),
        ],
      ),
    );
  }
}
