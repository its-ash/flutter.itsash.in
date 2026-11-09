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
class UiScaffold extends StatelessWidget {
  const UiScaffold({
    super.key,
    required this.body,
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
  });

  final Widget body;
  final PreferredSizeWidget? appBar;

  /// Sticky bottom area, such as `UiBottomBar` or a nav bar.
  final Widget? bottomBar;
  final Widget? fab;
  final Widget? drawer;
  final Widget? endDrawer;

  /// Space around [body]. Defaults to page padding on the sides, 16 on top
  /// and 24 at the bottom. Use `EdgeInsets.zero` for edge-to-edge content.
  final EdgeInsetsGeometry? padding;

  /// Wraps the body in a scroll view.
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
    Widget content = Padding(padding: padding ?? EdgeInsets.fromLTRB(h, UiSpace.lg, h, UiSpace.xl), child: body);
    content = SizedBox(width: double.infinity, height: scrollable ? null : double.infinity, child: content);
    if (maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: content,
      );
    }
    content = Align(alignment: Alignment.topCenter, child: content);

    if (scrollable) {
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
}
