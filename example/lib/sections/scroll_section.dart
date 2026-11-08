import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

class ScrollSection extends StatefulWidget {
  const ScrollSection({super.key});

  @override
  State<ScrollSection> createState() => _ScrollSectionState();
}

class _ScrollSectionState extends State<ScrollSection> {
  var _failOnce = true;

  late final _list = UiPagingController<int>(
    pageSize: 15,
    fetch: (page, size) async {
      await Future<void>.delayed(const Duration(milliseconds: 800));
      if (page == 3 && _failOnce) {
        _failOnce = false;
        throw Exception('Network error');
      }
      if (page > 5) return [];
      return [for (var i = 0; i < size; i++) (page - 1) * size + i + 1];
    },
  );

  late final _grid = UiPagingController<int>(
    pageSize: 12,
    fetch: (page, size) async {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      return page > 4 ? [] : [for (var i = 0; i < size; i++) (page - 1) * size + i];
    },
  );

  late final _empty = UiPagingController<int>(fetch: (_, _) async => []);
  final _scroll = ScrollController();

  @override
  void dispose() {
    _list.dispose();
    _grid.dispose();
    _empty.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Widget _box(Widget child, [double h = 420]) => ClipRRect(
        borderRadius: context.tokens.lg,
        child: Container(
          height: h,
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.outlineVariant),
            borderRadius: context.tokens.lg,
          ),
          child: child,
        ),
      );

  @override
  Widget build(BuildContext context) => SectionPage(
        children: [
          DemoBlock(
            'UiInfiniteList',
            subtitle: 'Loads 15 per page. Page 3 fails once, so you can try Retry. Pull down to refresh.',
            child: _box(
              UiScrollToTop(
                controller: _scroll,
                threshold: 300,
                child: UiInfiniteList<int>(
                  controller: _list,
                  scrollController: _scroll,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  endBuilder: (_) => const Padding(
                    padding: EdgeInsets.all(UiSpace.lg),
                    child: Center(child: Text('You reached the end')),
                  ),
                  itemBuilder: (_, n, _) => UiListTile(
                    leading: UiAvatar(name: 'User $n', imageUrl: pic('u$n', 120, 120), size: 40),
                    title: 'Item $n',
                    subtitle: 'Loaded on page ${(n - 1) ~/ 15 + 1}',
                  ),
                ),
              ),
            ),
          ),
          DemoBlock(
            'UiInfiniteGrid + UiLazyImage',
            subtitle: 'Images load only when they scroll into view, with a shimmer and fade',
            child: _box(
              UiInfiniteGrid<int>(
                controller: _grid,
                crossAxisCount: 3,
                childAspectRatio: 1,
                spacing: UiSpace.sm,
                padding: const EdgeInsets.all(UiSpace.sm),
                itemBuilder: (_, n, _) => UiLazyImage(pic('grid$n', 300, 300), radius: context.tokens.md),
              ),
            ),
          ),
          DemoBlock(
            'Empty state',
            child: _box(
              UiInfiniteList<int>(
                controller: _empty,
                itemBuilder: (_, n, _) => Text('$n'),
                emptyBuilder: (_) => const UiEmptyState(title: 'No orders yet', icon: Icons.receipt_long_outlined, compact: true),
              ),
              220,
            ),
          ),
          DemoBlock(
            'UiLazyBuilder',
            subtitle: 'Builds each card only when it gets near the screen',
            child: Column(
              children: [
                for (var i = 0; i < 4; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: UiSpace.sm),
                    child: UiLazyBuilder(
                      placeholderHeight: 72,
                      placeholder: UiSkeleton.listTile(),
                      builder: (_) => UiListTile(icon: Icons.bolt_rounded, title: 'Lazy card ${i + 1}', subtitle: 'Built when visible'),
                    ),
                  ),
              ],
            ),
          ),
          DemoBlock(
            'UiMarquee',
            subtitle: 'Long text scrolls. Short text stays still.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UiMarquee(
                  'Breaking: summer sale ends tonight. Free shipping on orders over \$50. Use code SUN25 at checkout.',
                  style: context.text.titleMedium,
                ),
                const UiGap.md(),
                const UiMarquee('Short text fits'),
              ],
            ),
          ),
        ],
      );
}
