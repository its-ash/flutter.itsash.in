import 'package:flutter/material.dart';

import 'package:theme/src/feedback/ui_skeleton.dart';
import 'package:theme/src/feedback/ui_states.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/scroll/ui_paging_controller.dart';

typedef UiItemBuilder<T> = Widget Function(BuildContext context, T item, int index);
typedef UiPagingErrorBuilder = Widget Function(BuildContext context, Object error, VoidCallback retry);

class UiInfiniteList<T> extends StatelessWidget {
  const UiInfiniteList({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.separatorBuilder,
    this.header,
    this.padding,
    this.scrollController,
    this.physics,
    this.shrinkWrap = false,
    this.prefetch = 3,
    this.pullToRefresh = true,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.endBuilder,
  });

  final UiPagingController<T> controller;
  final UiItemBuilder<T> itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final Widget? header;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final int prefetch;
  final bool pullToRefresh;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final UiPagingErrorBuilder? errorBuilder;
  final WidgetBuilder? endBuilder;

  @override
  Widget build(BuildContext context) => _PagedView<T>(
        controller: controller,
        header: header,
        padding: padding,
        scrollController: scrollController,
        physics: physics,
        shrinkWrap: shrinkWrap,
        prefetch: prefetch,
        pullToRefresh: pullToRefresh,
        loadingBuilder: loadingBuilder ?? (_) => UiSkeleton.list(count: 6),
        emptyBuilder: emptyBuilder,
        errorBuilder: errorBuilder,
        endBuilder: endBuilder,
        sliver: (count, item) => separatorBuilder == null
            ? SliverList.builder(itemCount: count, itemBuilder: (c, i) => item(c, i, itemBuilder))
            : SliverList.separated(
                itemCount: count,
                itemBuilder: (c, i) => item(c, i, itemBuilder),
                separatorBuilder: separatorBuilder!,
              ),
      );
}

class UiInfiniteGrid<T> extends StatelessWidget {
  const UiInfiniteGrid({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.gridDelegate,
    this.crossAxisCount = 2,
    this.childAspectRatio = 0.75,
    this.spacing = UiSpace.md,
    this.header,
    this.padding = const EdgeInsets.all(UiSpace.lg),
    this.scrollController,
    this.physics,
    this.shrinkWrap = false,
    this.prefetch = 4,
    this.pullToRefresh = true,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.endBuilder,
  });

  final UiPagingController<T> controller;
  final UiItemBuilder<T> itemBuilder;
  final SliverGridDelegate? gridDelegate;
  final int crossAxisCount;
  final double childAspectRatio;
  final double spacing;
  final Widget? header;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final int prefetch;
  final bool pullToRefresh;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final UiPagingErrorBuilder? errorBuilder;
  final WidgetBuilder? endBuilder;

  @override
  Widget build(BuildContext context) {
    final delegate = gridDelegate ??
        SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount < 1 ? 1 : crossAxisCount,
          childAspectRatio: childAspectRatio,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
        );
    return _PagedView<T>(
      controller: controller,
      header: header,
      padding: padding,
      scrollController: scrollController,
      physics: physics,
      shrinkWrap: shrinkWrap,
      prefetch: prefetch,
      pullToRefresh: pullToRefresh,
      loadingBuilder: loadingBuilder ??
          (_) => GridView.builder(
                padding: padding,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: delegate,
                itemCount: 6,
                itemBuilder: (_, _) => UiSkeleton.card(imageHeight: 0, lines: 3),
              ),
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      endBuilder: endBuilder,
      sliver: (count, item) => SliverGrid.builder(
        gridDelegate: delegate,
        itemCount: count,
        itemBuilder: (c, i) => item(c, i, itemBuilder),
      ),
    );
  }
}

typedef _ItemFn<T> = Widget Function(BuildContext context, int index, UiItemBuilder<T> builder);

class _PagedView<T> extends StatefulWidget {
  const _PagedView({
    required this.controller,
    required this.sliver,
    required this.header,
    required this.padding,
    required this.scrollController,
    required this.physics,
    required this.shrinkWrap,
    required this.prefetch,
    required this.pullToRefresh,
    required this.loadingBuilder,
    required this.emptyBuilder,
    required this.errorBuilder,
    required this.endBuilder,
  });

  final UiPagingController<T> controller;
  final Widget Function(int count, _ItemFn<T> item) sliver;
  final Widget? header;
  final EdgeInsetsGeometry? padding;
  final ScrollController? scrollController;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final int prefetch;
  final bool pullToRefresh;
  final WidgetBuilder loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final UiPagingErrorBuilder? errorBuilder;
  final WidgetBuilder? endBuilder;

  @override
  State<_PagedView<T>> createState() => _PagedViewState<T>();
}

class _PagedViewState<T> extends State<_PagedView<T>> {
  bool _scheduled = false;

  UiPagingController<T> get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_changed);
    _kickoff();
  }

  @override
  void didUpdateWidget(_PagedView<T> old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_changed);
      _c.addListener(_changed);
      _kickoff();
    }
  }

  @override
  void dispose() {
    _c.removeListener(_changed);
    super.dispose();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  void _kickoff() {
    if (_c.isInitial) _schedule();
  }

  void _schedule() {
    if (_scheduled || !_c.hasMore || _c.isLoading || _c.hasError) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (mounted) _c.loadMore();
    });
  }

  Widget _item(BuildContext context, int i, UiItemBuilder<T> builder) {
    if (i >= _c.length - (widget.prefetch < 1 ? 1 : widget.prefetch)) _schedule();
    return builder(context, _c.items[i], i);
  }

  Widget _footer(BuildContext context) {
    if (_c.hasError) {
      final cs = context.colors;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 18, color: cs.error),
            const UiGap.sm(),
            Flexible(child: Text('Could not load more', style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant))),
            const UiGap.sm(),
            TextButton(onPressed: _c.retry, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_c.isLoading && !_c.isRefreshing) {
      return const Padding(
        padding: EdgeInsets.all(UiSpace.lg),
        child: Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.4))),
      );
    }
    if (!_c.hasMore) return widget.endBuilder?.call(context) ?? const SizedBox(height: UiSpace.lg);
    return const SizedBox.shrink();
  }

  Widget _wrapRefresh(Widget child) =>
      widget.pullToRefresh ? RefreshIndicator(onRefresh: _c.refresh, child: child) : child;

  ScrollPhysics? get _physics =>
      widget.pullToRefresh ? AlwaysScrollableScrollPhysics(parent: widget.physics) : widget.physics;

  Widget _fill(Widget child, {bool fill = true}) => _wrapRefresh(
        CustomScrollView(
          controller: widget.scrollController,
          physics: _physics,
          shrinkWrap: widget.shrinkWrap,
          slivers: [
            if (widget.header != null) SliverToBoxAdapter(child: widget.header),
            fill ? SliverFillRemaining(hasScrollBody: false, child: child) : SliverToBoxAdapter(child: child),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    if (_c.isEmpty) {
      if (_c.hasError && !_c.isLoading) {
        return _fill(widget.errorBuilder?.call(context, _c.error!, _c.retry) ?? UiErrorState(onRetry: _c.retry));
      }
      if (_c.isLoading || _c.hasMore) {
        return _fill(widget.loadingBuilder(context), fill: false);
      }
      return _fill(widget.emptyBuilder?.call(context) ?? const UiEmptyState(title: 'Nothing here yet'));
    }
    final body = widget.sliver(_c.length, _item);
    return _wrapRefresh(
      CustomScrollView(
        controller: widget.scrollController,
        physics: _physics,
        shrinkWrap: widget.shrinkWrap,
        slivers: [
          if (widget.header != null) SliverToBoxAdapter(child: widget.header),
          widget.padding == null ? body : SliverPadding(padding: widget.padding!, sliver: body),
          SliverToBoxAdapter(child: _footer(context)),
        ],
      ),
    );
  }
}
