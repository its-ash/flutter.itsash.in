import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

const double _toolbarHeight = 60;

/// Back (or close, for full-screen dialogs) button. Null when there is
/// nothing to go back to and [back] is not forced.
Widget? _backButton(BuildContext context, {bool? back, VoidCallback? onBack}) {
  final route = ModalRoute.of(context);
  final show = back ?? (route?.impliesAppBarDismissal ?? false);
  if (!show) return null;
  final close = route is PageRoute && route.fullscreenDialog;
  final l = MaterialLocalizations.of(context);
  return IconButton(
    icon: Icon(close ? Icons.close_rounded : Icons.arrow_back_rounded),
    tooltip: close ? l.closeButtonTooltip : l.backButtonTooltip,
    onPressed: onBack ?? () => Navigator.maybePop(context),
  );
}

List<Widget>? _withEndGap(List<Widget>? actions) =>
    actions == null || actions.isEmpty ? actions : [...actions, const SizedBox(width: UiSpace.sm)];

/// Top app bar with title, optional subtitle, actions and an automatic back
/// button. [large] adds an iOS-style large title under the toolbar.
///
/// ```dart
/// Scaffold(appBar: UiAppBar(title: 'Settings', actions: [IconButton(...)]));
/// ```
class UiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UiAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.leading,
    this.actions,
    this.back,
    this.onBack,
    this.bottom,
    this.centerTitle,
    this.large = false,
    this.border = false,
    this.backgroundColor,
  });

  final String? title;

  /// Custom title widget. Used instead of [title].
  final Widget? titleWidget;

  /// Second line under the title.
  final String? subtitle;

  /// Replaces the automatic back button.
  final Widget? leading;
  final List<Widget>? actions;

  /// Shows a back button. Null shows it when the route can be popped.
  final bool? back;

  /// Called by the back button. Defaults to `Navigator.maybePop`.
  final VoidCallback? onBack;

  /// Widget under the toolbar, such as `UiTabs` wrapped in `PreferredSize`.
  final PreferredSizeWidget? bottom;

  /// Centers the title. Defaults to the platform style (start-aligned).
  final bool? centerTitle;

  /// Large title under the toolbar.
  final bool large;

  /// Hairline under the bar.
  final bool border;
  final Color? backgroundColor;

  double get _largeHeight => subtitle == null ? 52 : 72;

  @override
  Size get preferredSize =>
      Size.fromHeight(_toolbarHeight + (large ? _largeHeight : 0) + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final lead = leading ?? _backButton(context, back: back, onBack: onBack);
    final text = titleWidget ?? (title == null ? null : Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis));

    Widget? toolbarTitle;
    PreferredSizeWidget? bottomWidget = bottom;
    if (large) {
      final bottomHeight = bottom?.preferredSize.height ?? 0;
      bottomWidget = PreferredSize(
        preferredSize: Size.fromHeight(_largeHeight + bottomHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: _largeHeight,
              alignment: AlignmentDirectional.bottomStart,
              padding: const EdgeInsetsDirectional.fromSTEB(UiSpace.page, 0, UiSpace.page, UiSpace.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (text != null)
                    DefaultTextStyle.merge(
                      style: t.headlineMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: text,
                    ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.bodyMedium!.copyWith(color: c.textMuted),
                    ),
                ],
              ),
            ),
            ?bottom,
          ],
        ),
      );
    } else if (subtitle != null) {
      final centered = centerTitle ?? false;
      toolbarTitle = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          if (text != null) DefaultTextStyle.merge(style: t.titleMedium, child: text),
          Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.bodySmall),
        ],
      );
    } else {
      toolbarTitle = text;
    }

    return AppBar(
      leading: lead,
      automaticallyImplyLeading: back != false,
      title: toolbarTitle,
      centerTitle: centerTitle,
      actions: _withEndGap(actions),
      toolbarHeight: _toolbarHeight,
      titleSpacing: lead == null ? UiSpace.page : UiSpace.xs,
      bottom: bottomWidget,
      backgroundColor: backgroundColor,
      shape: border ? Border(bottom: BorderSide(color: c.border)) : null,
    );
  }
}

/// Sliver app bar for `CustomScrollView`. By default it shows an iOS-style
/// large title that shrinks into the toolbar as the content scrolls.
///
/// ```dart
/// CustomScrollView(slivers: [const UiSliverAppBar(title: 'Inbox'), SliverList(...)]);
/// ```
class UiSliverAppBar extends StatelessWidget {
  const UiSliverAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.back,
    this.onBack,
    this.bottom,
    this.large = true,
    this.pinned = true,
    this.floating = false,
    this.backgroundColor,
  });

  final String title;
  final Widget? leading;
  final List<Widget>? actions;

  /// Shows a back button. Null shows it when the route can be popped.
  final bool? back;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;

  /// Large collapsing title. False gives a plain toolbar.
  final bool large;

  /// Keeps the toolbar visible when scrolled.
  final bool pinned;

  /// Shows the bar again as soon as the user scrolls up.
  final bool floating;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final lead = leading ?? _backButton(context, back: back, onBack: onBack);
    final text = Text(title, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (large) {
      return SliverAppBar.large(
        leading: lead,
        automaticallyImplyLeading: back != false,
        title: text,
        actions: _withEndGap(actions),
        bottom: bottom,
        pinned: pinned,
        floating: floating,
        toolbarHeight: _toolbarHeight,
        expandedHeight: 124 + (bottom?.preferredSize.height ?? 0),
        backgroundColor: backgroundColor,
      );
    }
    return SliverAppBar(
      leading: lead,
      automaticallyImplyLeading: back != false,
      title: text,
      actions: _withEndGap(actions),
      bottom: bottom,
      pinned: pinned,
      floating: floating,
      toolbarHeight: _toolbarHeight,
      backgroundColor: backgroundColor,
    );
  }
}
