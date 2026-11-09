import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Look of [UiTabs].
enum UiTabsVariant {
  /// Text tabs with an animated accent line under the selected one.
  underline,

  /// Accent-filled pill that slides inside a muted rounded track.
  pill,

  /// iOS-style segmented control: equal segments, raised thumb.
  segment,
}

/// One tab with an optional icon and count. Plain strings work too.
///
/// ```dart
/// const UiTab('Inbox', icon: Icons.inbox_outlined, count: 4);
/// ```
@immutable
class UiTab {
  const UiTab(this.label, {this.icon, this.count});

  final String label;
  final IconData? icon;

  /// Small count shown after the label. Null hides it.
  final int? count;
}

UiTab _toTab(Object t) => t is UiTab ? t : UiTab(t.toString());

/// Tab bar in three styles: [UiTabsVariant.underline], [UiTabsVariant.pill]
/// and [UiTabsVariant.segment].
///
/// Each entry of [tabs] is a `String` or a [UiTab]. Drive it with [index] and
/// [onChanged], with a `TabController`, or from a `DefaultTabController`.
/// Without any of these it is disabled.
///
/// ```dart
/// UiTabs(tabs: const ['Day', 'Week', 'Month'], index: i, onChanged: (v) => setState(() => i = v));
/// ```
class UiTabs extends StatefulWidget {
  const UiTabs({
    super.key,
    required this.tabs,
    this.index,
    this.controller,
    this.onChanged,
    this.variant = UiTabsVariant.underline,
    this.scrollable = false,
  });

  /// `String` or [UiTab] entries.
  final List<Object> tabs;

  /// Selected index when no [controller] is used.
  final int? index;

  /// External controller. Not disposed by this widget.
  final TabController? controller;

  /// Called when a tab is tapped.
  final ValueChanged<int>? onChanged;
  final UiTabsVariant variant;

  /// Lets tabs keep their natural width and scroll. Ignored for [UiTabsVariant.segment].
  final bool scrollable;

  @override
  State<UiTabs> createState() => _UiTabsState();
}

class _UiTabsState extends State<UiTabs> with TickerProviderStateMixin {
  TabController? _own;

  TabController _resolve(TabController? external) {
    if (external != null) {
      _dropOwn();
      return external;
    }
    final length = widget.tabs.length;
    final own = _own;
    if (own != null && own.length == length) return own;
    _dropOwn();
    return _own = TabController(
      length: length,
      vsync: this,
      initialIndex: (widget.index ?? 0).clamp(0, length == 0 ? 0 : length - 1),
    );
  }

  void _dropOwn() {
    final old = _own;
    if (old == null) return;
    _own = null;
    // Dispose after the frame so the old TabBar can detach first.
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  @override
  void didUpdateWidget(UiTabs old) {
    super.didUpdateWidget(old);
    final own = _own;
    final index = widget.index;
    if (own != null && index != null && index != own.index && index >= 0 && index < own.length) {
      own.animateTo(index);
    }
  }

  @override
  void dispose() {
    _own?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final external = widget.controller ?? DefaultTabController.maybeOf(context);
    final enabled = external != null || widget.onChanged != null;
    final controller = _resolve(external);
    final tabs = widget.tabs.map(_toTab).toList();
    final variant = widget.variant;
    final scrollable = widget.scrollable && variant != UiTabsVariant.segment;
    final label = context.text.labelLarge!;
    final onTap = widget.onChanged;

    final double tabHeight = variant == UiTabsVariant.underline ? 44 : 36;
    final children = [
      for (final t in tabs)
        Tab(
          height: tabHeight,
          child: _TabLabel(tab: t),
        ),
    ];
    final align = scrollable ? TabAlignment.start : TabAlignment.fill;

    Widget bar;
    switch (variant) {
      case UiTabsVariant.underline:
        bar = TabBar(
          controller: controller,
          tabs: children,
          onTap: onTap,
          isScrollable: scrollable,
          tabAlignment: align,
          indicator: UnderlineTabIndicator(
            borderSide: BorderSide(color: enabled ? c.accent : c.textDisabled, width: 2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
          indicatorSize: TabBarIndicatorSize.label,
          indicatorAnimation: TabIndicatorAnimation.elastic,
          labelColor: enabled ? c.text : c.textDisabled,
          unselectedLabelColor: enabled ? c.textMuted : c.textDisabled,
          labelStyle: label,
          unselectedLabelStyle: label.copyWith(fontWeight: FontWeight.w500),
          dividerColor: c.border,
          dividerHeight: 1,
          labelPadding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
          splashBorderRadius: UiRadius.all(UiRadius.sm),
        );
      case UiTabsVariant.pill:
      case UiTabsVariant.segment:
        final pill = variant == UiTabsVariant.pill;
        final outer = pill ? UiRadius.full : UiRadius.md;
        final inner = pill ? UiRadius.full : UiRadius.md - UiSpace.xs;
        final Color thumb;
        final Color selectedText;
        if (!enabled) {
          thumb = c.border;
          selectedText = c.textDisabled;
        } else if (pill) {
          thumb = c.accent;
          selectedText = c.onAccent;
        } else {
          thumb = c.isDark ? c.border : c.surface;
          selectedText = c.text;
        }
        bar = DecoratedBox(
          decoration: BoxDecoration(color: c.surfaceMuted, borderRadius: UiRadius.all(outer)),
          child: Padding(
            padding: const EdgeInsets.all(UiSpace.xs),
            child: TabBar(
              controller: controller,
              tabs: children,
              onTap: onTap,
              isScrollable: scrollable,
              tabAlignment: align,
              indicator: BoxDecoration(
                color: thumb,
                borderRadius: UiRadius.all(inner),
                boxShadow: pill || !enabled ? null : context.shadowSm,
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: selectedText,
              unselectedLabelColor: enabled ? c.textMuted : c.textDisabled,
              labelStyle: label,
              unselectedLabelStyle: label.copyWith(fontWeight: FontWeight.w500),
              dividerHeight: 0,
              dividerColor: c.border.withValues(alpha: 0),
              labelPadding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
              splashFactory: NoSplash.splashFactory,
              splashBorderRadius: UiRadius.all(inner),
            ),
          ),
        );
    }
    return IgnorePointer(ignoring: !enabled, child: bar);
  }
}

class _TabLabel extends StatelessWidget {
  const _TabLabel({required this.tab});

  final UiTab tab;

  @override
  Widget build(BuildContext context) {
    final count = tab.count;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (tab.icon != null) ...[Icon(tab.icon, size: 18), const SizedBox(width: 6)],
        Flexible(child: Text(tab.label, maxLines: 1, overflow: TextOverflow.ellipsis)),
        if (count != null) ...[const SizedBox(width: 6), _TabCount(count: count)],
      ],
    );
  }
}

class _TabCount extends StatelessWidget {
  const _TabCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final color = DefaultTextStyle.of(context).style.color ?? context.colors.textMuted;
    return Container(
      constraints: const BoxConstraints(minWidth: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.14), borderRadius: UiRadius.all(UiRadius.full)),
      child: Text(
        count > 999 ? '999+' : '$count',
        textAlign: TextAlign.center,
        style: context.text.labelSmall!.copyWith(color: color, letterSpacing: 0),
      ),
    );
  }
}

/// [UiTabs] above a swipeable `TabBarView`. Needs a bounded height.
///
/// ```dart
/// UiTabView(tabs: const ['Posts', 'Likes'], children: const [Posts(), Likes()]);
/// ```
class UiTabView extends StatefulWidget {
  const UiTabView({
    super.key,
    required this.tabs,
    required this.children,
    this.variant = UiTabsVariant.underline,
    this.scrollable = false,
    this.initialIndex = 0,
    this.onChanged,
    this.tabsPadding = EdgeInsets.zero,
  }) : assert(tabs.length == children.length, 'tabs and children must have the same length');

  /// `String` or [UiTab] entries.
  final List<Object> tabs;
  final List<Widget> children;
  final UiTabsVariant variant;
  final bool scrollable;
  final int initialIndex;

  /// Called when the selected tab changes (tap or swipe).
  final ValueChanged<int>? onChanged;

  /// Space around the tab bar.
  final EdgeInsetsGeometry tabsPadding;

  @override
  State<UiTabView> createState() => _UiTabViewState();
}

class _UiTabViewState extends State<UiTabView> with TickerProviderStateMixin {
  late TabController _controller;
  late int _last;

  @override
  void initState() {
    super.initState();
    _controller = _create(widget.initialIndex);
    _last = _controller.index;
  }

  TabController _create(int index) {
    final length = widget.tabs.length;
    return TabController(length: length, vsync: this, initialIndex: index.clamp(0, length == 0 ? 0 : length - 1))
      ..addListener(_onTick);
  }

  void _onTick() {
    final i = _controller.index;
    if (i == _last) return;
    _last = i;
    widget.onChanged?.call(i);
  }

  @override
  void didUpdateWidget(UiTabView old) {
    super.didUpdateWidget(old);
    if (widget.tabs.length != _controller.length) {
      final previous = _controller..removeListener(_onTick);
      _controller = _create(previous.index);
      _last = _controller.index;
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onTick)
      ..dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: widget.tabsPadding,
          child: UiTabs(
            tabs: widget.tabs,
            controller: _controller,
            variant: widget.variant,
            scrollable: widget.scrollable,
          ),
        ),
        Expanded(
          child: TabBarView(controller: _controller, children: widget.children),
        ),
      ],
    );
  }
}
