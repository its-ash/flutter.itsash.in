import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

class _Post {
  const _Post(this.id, this.author);
  final int id;
  final Person author;
}

/// Fake API: 5 pages with a delay. Page 3 fails once so the retry row shows.
class _FakeApi {
  bool _failedOnce = false;

  Future<List<_Post>> posts(int page, int size) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (page == 3 && !_failedOnce) {
      _failedOnce = true;
      throw Exception('Network timeout (fake). Tap retry.');
    }
    if (page > 5) return const [];
    final count = page == 5 ? size ~/ 2 : size;
    return [for (var i = 0; i < count; i++) _Post((page - 1) * size + i + 1, people[(page + i) % people.length])];
  }
}

class ScrollPage extends StatefulWidget {
  const ScrollPage({super.key});

  @override
  State<ScrollPage> createState() => _ScrollPageState();
}

class _ScrollPageState extends State<ScrollPage> {
  final _api = _FakeApi();
  late final _list = UiPagingController<_Post>(fetch: _api.posts, pageSize: 10);
  late final _grid = UiPagingController<_Post>(fetch: _api.posts, pageSize: 12);
  final _scroll = ScrollController();
  final _refreshScroll = ScrollController();
  int _view = 0;
  int _refreshes = 0;

  @override
  void dispose() {
    _list.dispose();
    _grid.dispose();
    _scroll.dispose();
    _refreshScroll.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) setState(() => _refreshes++);
  }

  @override
  Widget build(BuildContext context) {
    final views = [
      UiScrollToTop(
        controller: _scroll,
        threshold: 400,
        label: 'Top',
        child: UiInfiniteList<_Post>(
          controller: _list,
          scrollController: _scroll,
          separatorBuilder: (context, i) => const UiDivider(indent: 72),
          itemBuilder: (context, post, i) => UiListTile(
            'Post #${post.id}',
            subtitle: 'by ${post.author.name}',
            leading: UiAvatar(name: post.author.name, image: AssetImage(post.author.avatar)),
            trailing: UiIconButton(
              Icons.delete_outline_rounded,
              tooltip: 'Remove',
              size: UiSize.sm,
              onPressed: () => _list.updateItems((items) => items.where((p) => p.id != post.id).toList()),
            ),
          ),
        ),
      ),
      UiInfiniteGrid<_Post>(
        controller: _grid,
        maxCrossAxisExtent: 160,
        padding: const EdgeInsets.all(UiSpace.md),
        itemBuilder: (context, post, i) => Stack(
          fit: StackFit.expand,
          children: [
            UiImage(productImages[post.id % productImages.length], radius: UiRadius.md),
            Positioned(
              left: UiSpace.sm,
              bottom: UiSpace.sm,
              child: UiStatusPill('#${post.id}', status: UiStatus.neutral),
            ),
          ],
        ),
      ),
      UiRefresh(
        onRefresh: _refresh,
        child: ListView(
          controller: _refreshScroll,
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            UiListTile('Pull down to refresh', subtitle: 'Refreshed $_refreshes times', icon: Icons.refresh_rounded),
            for (var i = 0; i < 8; i++)
              UiLazyBuilder(
                placeholderHeight: 120,
                placeholder: const Padding(padding: EdgeInsets.all(UiSpace.md), child: UiSkeleton.box(height: 96)),
                builder: (context) => Padding(
                  padding: const EdgeInsets.all(UiSpace.md),
                  child: UiCard(child: Text('Lazy block ${i + 1}: built when near the viewport')),
                ),
              ),
          ],
        ),
      ),
    ];
    return GalleryPage(
      children: [
        Demo(
          'Paging, refresh and lazy building',
          subtitle: 'Fake pages load with a 0.9 s delay. Page 3 fails once.',
          child: UiColumn(
            children: [
              ListenableBuilder(
                listenable: _list,
                builder: (context, _) => Text(
                  'List: ${_list.length} posts · '
                  '${_list.loading
                      ? 'loading…'
                      : _list.hasMore
                      ? 'scroll for more'
                      : 'all pages loaded'}',
                  style: context.text.bodySmall,
                ),
              ),
              UiSegmentedControl<int>(
                const [
                  UiSegment(0, label: 'List', icon: Icons.view_list_rounded),
                  UiSegment(1, label: 'Grid', icon: Icons.grid_view_rounded),
                  UiSegment(2, label: 'Refresh', icon: Icons.refresh_rounded),
                ],
                value: _view,
                expand: true,
                onChanged: (v) => setState(() => _view = v),
              ),
              UiRow(
                children: [
                  UiButton('Refresh', size: UiSize.sm, variant: UiButtonVariant.soft, onPressed: () => _list.refresh()),
                  UiButton(
                    'Reset',
                    size: UiSize.sm,
                    variant: UiButtonVariant.ghost,
                    onPressed: () {
                      _list.reset();
                      _grid.reset();
                    },
                  ),
                ],
              ),
              SizedBox(
                height: 460,
                child: UiSurface(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: UiRadius.all(UiRadius.lg),
                    child: IndexedStack(index: _view, children: views),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
