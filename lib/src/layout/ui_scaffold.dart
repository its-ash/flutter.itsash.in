import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';

class UiMaxWidth extends StatelessWidget {
  const UiMaxWidth({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          if (!w.isFinite || maxWidth <= 0 || w <= maxWidth) return child;
          return Padding(padding: EdgeInsets.symmetric(horizontal: (w - maxWidth) / 2), child: child);
        },
      );
}

class UiBackButton extends StatelessWidget {
  const UiBackButton({super.key, this.onPressed, this.icon});

  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final close = route is PageRoute && route.fullscreenDialog;
    final l10n = MaterialLocalizations.of(context);
    return UiIconButton(
      icon ?? (close ? Icons.close_rounded : Icons.arrow_back_rounded),
      size: UiSize.sm,
      tooltip: close ? l10n.closeButtonTooltip : l10n.backButtonTooltip,
      onPressed: onPressed ?? () => Navigator.maybePop(context),
    );
  }
}

class UiAppBar extends StatelessWidget implements PreferredSizeWidget {
  const UiAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.actions = const [],
    this.leading,
    this.centerTitle,
    this.showBack,
    this.onBack,
    this.bottom,
    this.backgroundColor,
  });

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;
  final bool? centerTitle;
  final bool? showBack;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;
  final Color? backgroundColor;

  double get _toolbar => subtitle == null ? kToolbarHeight : kToolbarHeight + 8;

  @override
  Size get preferredSize => Size.fromHeight(_toolbar + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final canPop = showBack ?? (ModalRoute.of(context)?.impliesAppBarDismissal ?? false);
    final lead = leading ?? (canPop ? Center(child: UiBackButton(onPressed: onBack)) : null);
    final center = centerTitle ?? false;
    final t = titleWidget ??
        (title == null
            ? null
            : subtitle == null
                ? Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                    children: [
                      Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ));
    return AppBar(
      title: t,
      leading: lead,
      leadingWidth: lead == null ? null : 60,
      automaticallyImplyLeading: showBack != false && lead == null,
      centerTitle: center,
      toolbarHeight: _toolbar,
      backgroundColor: backgroundColor,
      actions: actions,
      actionsPadding: actions.isEmpty ? null : const EdgeInsetsDirectional.only(end: UiSpace.sm),
      bottom: bottom,
    );
  }
}

class UiStickyBottomBar extends StatelessWidget {
  const UiStickyBottomBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.md, UiSpace.lg, UiSpace.md),
    this.showDivider = true,
    this.maxWidth = 720,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool showDivider;
  final double maxWidth;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? cs.surface,
        border: showDivider ? Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.6))) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: UiMaxWidth(maxWidth: maxWidth, child: Padding(padding: padding, child: child)),
      ),
    );
  }
}

class UiScaffold extends StatelessWidget {
  const UiScaffold({
    super.key,
    required this.body,
    this.title,
    this.subtitle,
    this.actions = const [],
    this.appBar,
    this.scrollable = true,
    this.padding = UiSpace.page,
    this.onRefresh,
    this.floatingActionButton,
    this.bottomBar,
    this.bottomNavigationBar,
    this.drawer,
    this.showBack,
    this.large = false,
    this.backgroundColor,
    this.maxWidth = 720,
    this.extendBody = false,
  });

  final Widget body;
  final String? title;
  final String? subtitle;
  final List<Widget> actions;
  final PreferredSizeWidget? appBar;
  final bool scrollable;
  final EdgeInsetsGeometry padding;
  final Future<void> Function()? onRefresh;
  final Widget? floatingActionButton;
  final Widget? bottomBar;
  final Widget? bottomNavigationBar;
  final Widget? drawer;
  final bool? showBack;
  final bool large;
  final Color? backgroundColor;
  final double maxWidth;
  final bool extendBody;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack ?? (ModalRoute.of(context)?.impliesAppBarDismissal ?? false);
    final hasBar = appBar != null || title != null || actions.isNotEmpty || canPop;
    final hasBottom = bottomBar != null || bottomNavigationBar != null;
    final inset = hasBottom ? 0.0 : MediaQuery.paddingOf(context).bottom;
    final scrollPad = padding.add(EdgeInsets.only(top: UiSpace.sm, bottom: UiSpace.xxl + inset));
    final content = UiMaxWidth(maxWidth: maxWidth, child: body);
    final physics = onRefresh == null ? null : const AlwaysScrollableScrollPhysics();

    Widget refreshable(Widget w) => onRefresh == null ? w : RefreshIndicator(onRefresh: onRefresh!, child: w);

    final Widget main;
    if (large && appBar == null) {
      final bar = SliverAppBar.large(
        title: Text(title ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
        leading: canPop ? Center(child: UiBackButton()) : null,
        leadingWidth: canPop ? 60 : null,
        automaticallyImplyLeading: showBack != false && !canPop,
        actions: actions,
        actionsPadding: actions.isEmpty ? null : const EdgeInsetsDirectional.only(end: UiSpace.sm),
        backgroundColor: backgroundColor,
      );
      main = scrollable
          ? refreshable(
              CustomScrollView(
                physics: physics,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                slivers: [bar, SliverPadding(padding: scrollPad, sliver: SliverToBoxAdapter(child: content))],
              ),
            )
          : NestedScrollView(
              headerSliverBuilder: (_, _) => [bar],
              body: refreshable(SafeArea(top: false, bottom: !hasBottom, child: Padding(padding: padding, child: content))),
            );
    } else {
      main = scrollable
          ? refreshable(
              SingleChildScrollView(
                physics: physics,
                padding: scrollPad,
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: content,
              ),
            )
          : refreshable(SafeArea(top: !hasBar, bottom: !hasBottom, child: Padding(padding: padding, child: content)));
    }

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        extendBody: extendBody,
        drawer: drawer,
        appBar: large && appBar == null
            ? null
            : appBar ??
                (hasBar
                    ? UiAppBar(title: title, subtitle: subtitle, actions: actions, showBack: showBack, backgroundColor: backgroundColor)
                    : null),
        body: large || hasBar || !scrollable ? main : SafeArea(bottom: false, child: main),
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar ?? (bottomBar == null ? null : UiStickyBottomBar(maxWidth: maxWidth, child: bottomBar!)),
      ),
    );
  }
}
