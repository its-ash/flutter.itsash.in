import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/media/ui_shimmer.dart';
import 'package:theme/src/scroll/ui_paging_controller.dart';
import 'package:theme/src/scroll/ui_refresh.dart';

/// Builds one loaded item.
typedef UiPagedItemBuilder<T> = Widget Function(BuildContext context, T item, int index);

/// Builds an error view. Call [retry] to load again.
typedef UiPagedErrorBuilder = Widget Function(BuildContext context, Object error, VoidCallback retry);

/// List that loads the next page of a [UiPagingController] as you near the
/// end. Has pull-to-refresh, a skeleton for the first page, and empty, error
/// and loading rows.
///
/// ```dart
/// UiInfiniteList<Post>(controller: paging, itemBuilder: (context, post, i) => PostTile(post))
/// ```
class UiInfiniteList<T> extends StatelessWidget {
  const UiInfiniteList({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.separatorBuilder,
    this.empty,
    this.padding,
    this.loadingBuilder,
    this.errorBuilder,
    this.end,
    this.scrollController,
    this.refreshable = true,
    this.skeletonCount = 6,
    this.physics,
  });

  /// Paging state. Not disposed by this widget.
  final UiPagingController<T> controller;
  final UiPagedItemBuilder<T> itemBuilder;

  /// Optional divider between items.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Shown when the first page is empty. Defaults to "Nothing here yet".
  final Widget? empty;

  final EdgeInsetsGeometry? padding;

  /// Builds one skeleton item for the first-page loading state. Defaults to a
  /// shimmer row.
  final WidgetBuilder? loadingBuilder;

  /// Builds the error view (full page when nothing loaded, a row otherwise).
  final UiPagedErrorBuilder? errorBuilder;

  /// Shown after the last item once every page is loaded.
  final Widget? end;

  final ScrollController? scrollController;

  /// Adds pull-to-refresh (calls `controller.refresh`).
  final bool refreshable;

  /// Number of skeleton items on first load.
  final int skeletonCount;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return _UiPagedView<T>(
      controller: controller,
      empty: empty,
      padding: padding,
      errorBuilder: errorBuilder,
      end: end,
      scrollController: scrollController,
      refreshable: refreshable,
      physics: physics,
      skeleton: (context) => SliverList.separated(
        itemCount: skeletonCount,
        itemBuilder: (context, i) => loadingBuilder?.call(context) ?? const _UiSkeletonRow(),
        separatorBuilder: (context, i) => separatorBuilder?.call(context, i) ?? const SizedBox.shrink(),
      ),
      items: (context, items, onBuild) {
        Widget item(BuildContext context, int i) {
          onBuild(i);
          return itemBuilder(context, items[i], i);
        }

        final sep = separatorBuilder;
        return sep == null
            ? SliverList.builder(itemCount: items.length, itemBuilder: item)
            : SliverList.separated(itemCount: items.length, itemBuilder: item, separatorBuilder: sep);
      },
    );
  }
}

/// Grid version of [UiInfiniteList]. Set [crossAxisCount] or
/// [maxCrossAxisExtent] (default 200).
///
/// ```dart
/// UiInfiniteGrid<Photo>(controller: paging, crossAxisCount: 3, itemBuilder: (context, p, i) => UiImage(p.url))
/// ```
class UiInfiniteGrid<T> extends StatelessWidget {
  const UiInfiniteGrid({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.crossAxisCount,
    this.maxCrossAxisExtent,
    this.childAspectRatio = 1,
    this.mainAxisSpacing = UiSpace.md,
    this.crossAxisSpacing = UiSpace.md,
    this.empty,
    this.padding,
    this.loadingBuilder,
    this.errorBuilder,
    this.end,
    this.scrollController,
    this.refreshable = true,
    this.skeletonCount = 9,
    this.physics,
  });

  final UiPagingController<T> controller;
  final UiPagedItemBuilder<T> itemBuilder;
  final int? crossAxisCount;
  final double? maxCrossAxisExtent;
  final double childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final Widget? empty;
  final EdgeInsetsGeometry? padding;
  final WidgetBuilder? loadingBuilder;
  final UiPagedErrorBuilder? errorBuilder;
  final Widget? end;
  final ScrollController? scrollController;
  final bool refreshable;
  final int skeletonCount;
  final ScrollPhysics? physics;

  SliverGridDelegate get _delegate => crossAxisCount != null
      ? SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount!,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        )
      : SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: maxCrossAxisExtent ?? 200,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: mainAxisSpacing,
          crossAxisSpacing: crossAxisSpacing,
        );

  @override
  Widget build(BuildContext context) {
    return _UiPagedView<T>(
      controller: controller,
      empty: empty,
      padding: padding,
      errorBuilder: errorBuilder,
      end: end,
      scrollController: scrollController,
      refreshable: refreshable,
      physics: physics,
      skeleton: (context) => SliverGrid.builder(
        gridDelegate: _delegate,
        itemCount: skeletonCount,
        itemBuilder: (context, i) => loadingBuilder?.call(context) ?? const UiShimmerBox(radius: UiRadius.md),
      ),
      items: (context, items, onBuild) => SliverGrid.builder(
        gridDelegate: _delegate,
        itemCount: items.length,
        itemBuilder: (context, i) {
          onBuild(i);
          return itemBuilder(context, items[i], i);
        },
      ),
    );
  }
}

typedef _ItemsSliverBuilder<T> = Widget Function(BuildContext context, List<T> items, ValueChanged<int> onBuild);

class _UiPagedView<T> extends StatefulWidget {
  const _UiPagedView({
    super.key,
    required this.controller,
    required this.items,
    required this.skeleton,
    required this.empty,
    required this.padding,
    required this.errorBuilder,
    required this.end,
    required this.scrollController,
    required this.refreshable,
    required this.physics,
  });

  final UiPagingController<T> controller;
  final _ItemsSliverBuilder<T> items;
  final WidgetBuilder skeleton;
  final Widget? empty;
  final EdgeInsetsGeometry? padding;
  final UiPagedErrorBuilder? errorBuilder;
  final Widget? end;
  final ScrollController? scrollController;
  final bool refreshable;
  final ScrollPhysics? physics;

  @override
  State<_UiPagedView<T>> createState() => _UiPagedViewState<T>();
}

class _UiPagedViewState<T> extends State<_UiPagedView<T>> {
  /// Start loading when this many items are left below the last built one.
  static const int _prefetch = 4;

  bool _loadScheduled = false;

  UiPagingController<T> get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onChange);
    _scheduleLoad();
  }

  @override
  void didUpdateWidget(_UiPagedView<T> old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onChange);
      widget.controller.addListener(_onChange);
      _scheduleLoad();
    }
  }

  @override
  void dispose() {
    _c.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  bool get _canLoad => _c.hasMore && !_c.loading && _c.error == null;

  void _scheduleLoad() {
    if (_loadScheduled || !_canLoad) return;
    _loadScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadScheduled = false;
      if (mounted && _canLoad) _c.loadMore();
    });
  }

  void _onItemBuilt(int index) {
    if (index >= _c.length - 1 - _prefetch) _scheduleLoad();
  }

  @override
  Widget build(BuildContext context) {
    final c = _c;
    final List<Widget> slivers;
    if (c.length == 0) {
      if (c.error != null) {
        slivers = [SliverFillRemaining(hasScrollBody: false, child: _errorView(context, c.error!, full: true))];
      } else if (c.isEmpty) {
        slivers = [
          SliverFillRemaining(hasScrollBody: false, child: Center(child: widget.empty ?? const _UiEmptyState())),
        ];
      } else {
        slivers = [widget.skeleton(context)];
      }
    } else {
      slivers = [widget.items(context, c.items, _onItemBuilt), SliverToBoxAdapter(child: _footer(context))];
    }

    final padding = widget.padding;
    Widget view = CustomScrollView(
      controller: widget.scrollController,
      physics: AlwaysScrollableScrollPhysics(parent: widget.physics),
      slivers: [
        if (padding != null)
          SliverPadding(
            padding: padding,
            sliver: SliverMainAxisGroup(slivers: slivers),
          ),
        if (padding == null) ...slivers,
      ],
    );
    if (widget.refreshable) view = UiRefresh(onRefresh: c.refresh, child: view);
    return view;
  }

  Widget _footer(BuildContext context) {
    final c = _c;
    final duration = context.motion(UiMotion.normal);
    final Widget child;
    if (c.error != null) {
      child = _errorView(context, c.error!, full: false);
    } else if (c.hasMore || (c.loading && !c.refreshing)) {
      // Loading is triggered by the last items being built, not by this row:
      // slivers past the viewport still build their first child.
      child = const _UiLoadingRow();
    } else {
      child = widget.end ?? const SizedBox(height: UiSpace.lg);
    }
    return AnimatedSize(
      duration: duration,
      curve: UiMotion.standard,
      alignment: Alignment.topCenter,
      child: KeyedSubtree(key: ValueKey(child.runtimeType), child: child),
    );
  }

  Widget _errorView(BuildContext context, Object error, {required bool full}) {
    final custom = widget.errorBuilder;
    if (custom != null) return custom(context, error, _c.retry);
    return full ? _UiErrorState(onRetry: _c.retry) : _UiErrorRow(onRetry: _c.retry);
  }
}

class _UiLoadingRow extends StatelessWidget {
  const _UiLoadingRow();

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: UiSpace.xl),
    child: Center(
      child: SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2.5, color: context.colors.accent),
      ),
    ),
  );
}

class _UiErrorRow extends StatelessWidget {
  const _UiErrorRow({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 18, color: colors.danger),
          const SizedBox(width: UiSpace.sm),
          Flexible(
            child: Text(
              "Couldn't load more",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(color: colors.textMuted),
            ),
          ),
          const SizedBox(width: UiSpace.xs),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

class _UiErrorState extends StatelessWidget {
  const _UiErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _UiStateView(
      icon: Icons.cloud_off_rounded,
      iconColor: colors.danger,
      iconBackground: colors.dangerSoft,
      title: 'Something went wrong',
      message: 'Check your connection and try again.',
      action: OutlinedButton.icon(
        onPressed: onRetry,
        icon: const Icon(Icons.refresh_rounded, size: 18),
        label: const Text('Retry'),
      ),
    );
  }
}

class _UiEmptyState extends StatelessWidget {
  const _UiEmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return _UiStateView(
      icon: Icons.inbox_outlined,
      iconColor: colors.textSubtle,
      iconBackground: colors.surfaceMuted,
      title: 'Nothing here yet',
    );
  }
}

class _UiStateView extends StatelessWidget {
  const _UiStateView({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.title,
    this.message,
    this.action,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String title;
  final String? message;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(UiSpace.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
              child: Padding(
                padding: const EdgeInsets.all(UiSpace.md + 2),
                child: Icon(icon, size: 26, color: iconColor),
              ),
            ),
            const SizedBox(height: UiSpace.lg),
            Text(title, textAlign: TextAlign.center, style: context.text.titleMedium),
            if (message != null) ...[
              const SizedBox(height: UiSpace.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: context.text.bodyMedium?.copyWith(color: colors.textMuted),
              ),
            ],
            if (action != null) ...[const SizedBox(height: UiSpace.lg), action!],
          ],
        ),
      ),
    );
  }
}

class _UiSkeletonRow extends StatelessWidget {
  const _UiSkeletonRow();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
    child: Row(
      children: [
        UiShimmerBox(width: 44, height: 44, radius: UiRadius.full),
        SizedBox(width: UiSpace.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FractionallySizedBox(widthFactor: 0.6, child: UiShimmerBox(height: 12, radius: UiRadius.xs)),
              SizedBox(height: UiSpace.sm),
              UiShimmerBox(height: 10, radius: UiRadius.xs),
            ],
          ),
        ),
      ],
    ),
  );
}
