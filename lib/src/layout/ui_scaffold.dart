import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/layout/ui_content.dart';

/// Page scaffold with sensible defaults: page padding, optional scrolling,
/// optional centered max width for wide screens, safe area, and tap outside
/// a text field to close the keyboard.
///
/// ```dart
/// UiScaffold(appBar: const UiAppBar(title: 'Profile'), scrollable: true, maxWidth: 720, body: form);
/// ```
///
/// `scrollable: true` builds the whole body at once. For long lists use
/// [UiScaffold.slivers], which builds only what is on screen.
class UiScaffold extends StatelessWidget {
  const UiScaffold({
    super.key,
    required Widget this.body,
    this.appBar,
    this.bottomBar,
    this.fab,
    this.drawer,
    this.endDrawer,
    this.padding,
    this.scrollable = false,
    this.maxWidth,
    this.safeArea = true,
    this.dismissKeyboard = true,
    this.onRefresh,
    this.backgroundColor,
  }) : slivers = null,
       gap = 0;

  /// Lazy scrolling page: the body is a `CustomScrollView` of [slivers], with
  /// the same padding, max width, safe area and pull-to-refresh. Only what is
  /// near the screen is built. Wrap plain widgets in `SliverToBoxAdapter`;
  /// use `UiSliverResponsiveGrid`, `UiSliverListGroup` or `SliverList.builder`
  /// for long content. [gap] is the space between the slivers.
  ///
  /// ```dart
  /// UiScaffold.slivers(gap: UiSpace.lg, slivers: [
  ///   SliverToBoxAdapter(child: search),
  ///   UiSliverResponsiveGrid(itemCount: items.length, itemBuilder: (context, i) => Cell(items[i])),
  /// ])
  /// ```
  const UiScaffold.slivers({
    super.key,
    required List<Widget> this.slivers,
    this.gap = 0,
    this.appBar,
    this.bottomBar,
    this.fab,
    this.drawer,
    this.endDrawer,
    this.padding,
    this.maxWidth,
    this.safeArea = true,
    this.dismissKeyboard = true,
    this.onRefresh,
    this.backgroundColor,
  }) : body = null,
       scrollable = true;

  final Widget? body;

  /// Body of [UiScaffold.slivers].
  final List<Widget>? slivers;

  /// Space between [slivers].
  final double gap;
  final PreferredSizeWidget? appBar;

  /// Sticky bottom area, such as `UiBottomBar` or a nav bar.
  final Widget? bottomBar;
  final Widget? fab;
  final Widget? drawer;
  final Widget? endDrawer;

  /// Space around [body]. Defaults to page padding on the sides, 16 on top
  /// and 24 at the bottom. Use `EdgeInsets.zero` for edge-to-edge content.
  final EdgeInsetsGeometry? padding;

  /// Wraps the body in a scroll view. Always true for [UiScaffold.slivers].
  final bool scrollable;

  /// Centers the body with this max width (e.g. 720). Null fills the width.
  final double? maxWidth;

  /// Keeps the body out of notches and system bars.
  final bool safeArea;

  /// Closes the keyboard when the user taps outside a text field.
  final bool dismissKeyboard;

  /// Adds pull-to-refresh. Only used when [scrollable] is true.
  final RefreshCallback? onRefresh;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final h = UiContent.pagePadding(context);
    final pad = padding ?? EdgeInsets.fromLTRB(h, UiSpace.lg, h, UiSpace.xl);
    Widget content;
    if (slivers != null) {
      content = _sliverBody(context, pad.resolve(Directionality.of(context)));
      if (onRefresh != null) content = RefreshIndicator(onRefresh: onRefresh!, child: content);
    } else {
      content = Padding(padding: pad, child: body);
      content = SizedBox(width: double.infinity, height: scrollable ? null : double.infinity, child: content);
      if (maxWidth != null) {
        content = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth!),
          child: content,
        );
      }
      content = Align(alignment: Alignment.topCenter, child: content);
    }

    if (scrollable && slivers == null) {
      content = SingleChildScrollView(
        physics: onRefresh == null ? null : const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: content,
      );
      if (onRefresh != null) content = RefreshIndicator(onRefresh: onRefresh!, child: content);
    }
    if (safeArea) {
      content = SafeArea(top: appBar == null, bottom: bottomBar == null, child: content);
    }
    if (dismissKeyboard) {
      content = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: content,
      );
    }

    return Scaffold(
      appBar: appBar,
      body: content,
      bottomNavigationBar: bottomBar,
      floatingActionButton: fab,
      drawer: drawer,
      endDrawer: endDrawer,
      backgroundColor: backgroundColor,
    );
  }

  Widget _sliverBody(BuildContext context, EdgeInsets pad) {
    final items = slivers!;
    final spaced = [
      for (var i = 0; i < items.length; i++) ...[
        if (i > 0 && gap > 0) SliverToBoxAdapter(child: SizedBox(height: gap)),
        items[i],
      ],
    ];
    return LayoutBuilder(
      builder: (context, box) {
        // Center the page (padding included) at maxWidth, like the box body,
        // by growing the side padding.
        var extra = 0.0;
        if (maxWidth != null && box.maxWidth.isFinite) {
          extra = ((box.maxWidth - maxWidth!) / 2).clamp(0.0, double.infinity);
        }
        return CustomScrollView(
          physics: onRefresh == null ? null : const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
            SliverPadding(
              padding: pad.copyWith(left: pad.left + extra, right: pad.right + extra),
              sliver: SliverMainAxisGroup(slivers: spaced),
            ),
          ],
        );
      },
    );
  }
}
