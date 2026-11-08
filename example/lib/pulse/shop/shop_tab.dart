import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';
import 'product_page.dart';

enum _Sort {
  featured('Featured'),
  priceLow('Price: low to high'),
  priceHigh('Price: high to low'),
  rating('Top rated');

  const _Sort(this.label);
  final String label;
}

/// Shop tab: search, categories, sort, a promo header, and an infinite product grid.
/// The shell already gives the Scaffold and the app bar.
class PulseShopTab extends StatefulWidget {
  const PulseShopTab({super.key});

  @override
  State<PulseShopTab> createState() => _PulseShopTabState();
}

class _PulseShopTabState extends State<PulseShopTab> {
  static const _pageSize = 6;

  String _category = 'All';
  _Sort _sort = _Sort.featured;
  final _scroll = ScrollController();
  final _search = TextEditingController();
  late final DateTime _saleEnds = DateTime.now().add(const Duration(hours: 5, minutes: 20));

  late final _products = UiPagingController<Product>(pageSize: _pageSize, fetch: _fetch);

  Future<List<Product>> _fetch(int page, int size) async {
    final data = PulseScope.read(context).data;
    if (_sort == _Sort.featured) return data.fetchProducts(page, size, category: _category);
    // The fake API has no sort, so load the whole category once, sort it, then cut the page.
    final all = [...await data.fetchProducts(1, 1000, category: _category)];
    switch (_sort) {
      case _Sort.priceLow:
        all.sort((a, b) => a.price.compareTo(b.price));
      case _Sort.priceHigh:
        all.sort((a, b) => b.price.compareTo(a.price));
      case _Sort.rating:
        all.sort((a, b) => b.rating.compareTo(a.rating));
      case _Sort.featured:
        break;
    }
    final start = (page - 1) * size;
    if (start >= all.length) return const [];
    return all.sublist(start, (start + size).clamp(0, all.length));
  }

  @override
  void dispose() {
    _products.dispose();
    _scroll.dispose();
    _search.dispose();
    super.dispose();
  }

  void _setCategory(String c) {
    if (c == _category) return;
    setState(() => _category = c);
    _products.refresh();
  }

  void _setSort(_Sort? s) {
    if (s == null || s == _sort) return;
    setState(() => _sort = s);
    _products.refresh();
  }

  void _open(Product p) => pulsePush(context, PulseProductPage(product: p));

  void _add(Product p) {
    PulseScope.read(context).addToCart(p);
    context.showToast('${p.title} added to cart', status: UiStatus.success, icon: Icons.shopping_bag_rounded);
  }

  int _columns(double width) => width >= 1100
      ? 4
      : width >= 720
          ? 3
          : 2;

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    return LayoutBuilder(
      builder: (context, box) {
        final cols = _columns(box.maxWidth);
        const spacing = UiSpace.md;
        final cardWidth = (box.maxWidth - UiSpace.lg * 2 - spacing * (cols - 1)) / cols;
        return UiScrollToTop(
          controller: _scroll,
          child: UiInfiniteGrid<Product>(
            controller: _products,
            scrollController: _scroll,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: spacing,
              crossAxisSpacing: spacing,
              mainAxisExtent: cardWidth + 150,
            ),
            padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.lg),
            header: _header(store),
            emptyBuilder: (_) => UiEmptyState(
              title: 'No products here',
              message: 'Try another category.',
              icon: Icons.search_off_rounded,
              compact: true,
              actionLabel: 'Show all',
              onAction: () => _setCategory('All'),
            ),
            endBuilder: (_) => Padding(
              padding: const EdgeInsets.all(UiSpace.xl),
              child: Center(
                child: Text(
                  'You have seen all products',
                  style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                ),
              ),
            ),
            itemBuilder: (context, p, _) => UiProductCard(
              title: p.title,
              subtitle: p.brand,
              price: p.price,
              compareAt: p.compareAt,
              rating: p.rating,
              reviewCount: p.reviews,
              imageUrl: p.image,
              heroTag: 'pulse-product-${p.id}',
              inStock: p.stock > 0,
              isFavorite: store.isWished(p),
              onFavoriteChanged: (_) => PulseScope.read(context).toggleWish(p),
              onAdd: p.stock > 0 ? () => _add(p) : null,
              onTap: () => _open(p),
            ),
          ),
        );
      },
    );
  }

  Widget _header(PulseStore store) {
    final categories = store.data.categories;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.md, UiSpace.lg, UiSpace.md),
          child: UiAutocomplete<Product>(
            controller: _search,
            hint: 'Search shoes, bags, watches...',
            onSearch: store.data.searchProducts,
            itemLabel: (p) => p.title,
            itemSubtitle: (p) => '${p.brand} · ${money(p.price)}',
            emptyText: 'No products match',
            onSelected: (p) {
              _search.clear();
              FocusScope.of(context).unfocus();
              _open(p);
            },
          ),
        ),
        Padding(
          padding: UiSpace.page,
          child: UiPromoBanner(
            eyebrow: 'Member week',
            title: 'Up to 30% off gear',
            subtitle: 'Shoes, bags and audio. Free shipping over \$50.',
            ctaLabel: 'Shop sale',
            trailingImageUrl: store.data.products.first.image,
            onTap: () => _setSort(_Sort.priceLow),
          ),
        ),
        const UiGap.lg(),
        Padding(
          padding: UiSpace.page,
          child: UiFlashSale(
            endsAt: _saleEnds,
            title: 'Flash sale',
            onSeeAll: () => _setCategory('All'),
          ),
        ),
        const UiGap.md(),
        UiChipGroup(
          scrollable: true,
          padding: UiSpace.page,
          children: [
            for (final c in categories)
              UiChip(
                c,
                selected: c == _category,
                count: c == 'All' ? null : store.data.products.where((p) => p.category == c).length,
                onTap: () => _setCategory(c),
              ),
          ],
        ),
        const UiGap.md(),
        Padding(
          padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.md),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _category == 'All' ? 'All products' : _category,
                  style: context.text.titleMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const UiGap.md(),
              SizedBox(
                width: 210,
                child: UiDropdown<_Sort>(
                  items: _Sort.values,
                  value: _sort,
                  itemLabel: (s) => s.label,
                  prefixIcon: Icons.sort_rounded,
                  onChanged: _setSort,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
