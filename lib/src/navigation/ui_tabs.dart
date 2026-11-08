import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiTabBar extends StatefulWidget {
  const UiTabBar({
    super.key,
    required this.tabs,
    this.icons,
    this.controller,
    this.selectedIndex = 0,
    this.onChanged,
    this.scrollable,
    this.height = 46,
  });

  final List<String> tabs;
  final List<IconData>? icons;
  final TabController? controller;
  final int selectedIndex;
  final ValueChanged<int>? onChanged;
  final bool? scrollable;
  final double height;

  @override
  State<UiTabBar> createState() => _UiTabBarState();
}

class _UiTabBarState extends State<UiTabBar> with TickerProviderStateMixin {
  TabController? _own;
  TabController? _listened;
  int _last = -1;

  TabController? get _external => widget.controller ?? DefaultTabController.maybeOf(context);

  TabController? get _active => _external ?? _own;

  void _sync() {
    final ext = _external;
    if (ext != null) {
      _retire();
    } else {
      final n = widget.tabs.length;
      final i = n == 0 ? 0 : widget.selectedIndex.clamp(0, n - 1);
      final own = _own;
      if (own == null || own.length != n) {
        _retire();
        _own = TabController(length: n, initialIndex: i, vsync: this);
      } else if (own.index != i && !own.indexIsChanging) {
        own.animateTo(i);
      }
    }
    _listen(_active);
  }

  void _retire() {
    final old = _own;
    _own = null;
    if (old != null) WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  void _listen(TabController? c) {
    if (identical(c, _listened)) return;
    _listened?.removeListener(_onTab);
    _listened = c;
    _last = c?.index ?? -1;
    c?.addListener(_onTab);
  }

  void _onTab() {
    final c = _listened;
    if (c == null || c.indexIsChanging || c.index == _last) return;
    _last = c.index;
    widget.onChanged?.call(c.index);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(UiTabBar old) {
    super.didUpdateWidget(old);
    _sync();
  }

  @override
  void dispose() {
    _listened?.removeListener(_onTab);
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _active;
    final n = widget.tabs.length;
    if (c == null || n == 0 || c.length != n) return SizedBox(height: widget.height);
    final cs = context.colors;
    final icons = widget.icons;
    final scroll = widget.scrollable ?? n > 4;
    final label = context.text.labelLarge?.copyWith(fontSize: 14);
    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(UiSpace.xs),
      decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: context.tokens.full),
      child: TabBar(
        controller: c,
        isScrollable: scroll,
        tabAlignment: scroll ? TabAlignment.start : TabAlignment.fill,
        padding: EdgeInsets.zero,
        indicator: BoxDecoration(color: cs.primary, borderRadius: context.tokens.full),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        dividerColor: Colors.transparent,
        labelColor: cs.onPrimary,
        unselectedLabelColor: cs.onSurfaceVariant,
        labelStyle: label?.copyWith(fontWeight: FontWeight.w700),
        unselectedLabelStyle: label?.copyWith(fontWeight: FontWeight.w500),
        labelPadding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
        splashBorderRadius: context.tokens.full,
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        tabs: [
          for (var i = 0; i < n; i++)
            Tab(
              height: widget.height - UiSpace.xs * 2,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icons != null && i < icons.length) ...[Icon(icons[i], size: 18), const UiGap.xs()],
                  Flexible(child: Text(widget.tabs[i], maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class UiTabView extends StatelessWidget {
  const UiTabView({
    super.key,
    required this.tabs,
    required this.children,
    this.icons,
    this.initialIndex = 0,
    this.onChanged,
    this.scrollable,
    this.barPadding = UiSpace.page,
    this.spacing = UiSpace.md,
    this.height,
    this.physics,
  });

  final List<String> tabs;
  final List<Widget> children;
  final List<IconData>? icons;
  final int initialIndex;
  final ValueChanged<int>? onChanged;
  final bool? scrollable;
  final EdgeInsetsGeometry barPadding;
  final double spacing;
  final double? height;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    final n = math.min(tabs.length, children.length);
    if (n == 0) return const SizedBox.shrink();
    final view = TabBarView(physics: physics, children: children.take(n).toList());
    return DefaultTabController(
      length: n,
      initialIndex: initialIndex.clamp(0, n - 1),
      child: Column(
        mainAxisSize: height == null ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: barPadding,
            child: UiTabBar(
              tabs: tabs.take(n).toList(),
              icons: icons,
              scrollable: scrollable,
              onChanged: onChanged,
            ),
          ),
          SizedBox(height: spacing),
          if (height == null) Expanded(child: view) else SizedBox(height: height, child: view),
        ],
      ),
    );
  }
}
