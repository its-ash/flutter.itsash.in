import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

typedef Product = ({String id, String title, String brand, double price, double? compareAt, double rating, int reviews});

const shopProducts = <Product>[
  (id: 'p1', title: 'Air Runner 2', brand: 'Stride', price: 129, compareAt: 159, rating: 4.6, reviews: 214),
  (id: 'p2', title: 'Canvas Tote', brand: 'Field', price: 39, compareAt: null, rating: 4.2, reviews: 88),
  (id: 'p3', title: 'Trail Shell Jacket', brand: 'Summit', price: 189, compareAt: 240, rating: 4.8, reviews: 512),
  (id: 'p4', title: 'Pulse Watch', brand: 'Tempo', price: 249, compareAt: null, rating: 4.4, reviews: 1290),
  (id: 'p5', title: 'Linen Shirt', brand: 'Coast', price: 59, compareAt: 79, rating: 4.3, reviews: 64),
  (id: 'p6', title: 'Studio Headphones', brand: 'Wave', price: 179, compareAt: 199, rating: 4.7, reviews: 903),
  (id: 'p7', title: 'Wool Beanie', brand: 'Field', price: 24, compareAt: null, rating: 4.1, reviews: 31),
  (id: 'p8', title: 'Day Pack 22L', brand: 'Summit', price: 89, compareAt: 110, rating: 4.5, reviews: 377),
];

const _categories = [
  ('All', Icons.apps_rounded),
  ('Shoes', Icons.ice_skating_outlined),
  ('Bags', Icons.work_outline_rounded),
  ('Watches', Icons.watch_outlined),
  ('Audio', Icons.headphones_rounded),
  ('Outdoor', Icons.terrain_rounded),
];

class ShopDemo extends StatefulWidget {
  const ShopDemo({super.key});

  @override
  State<ShopDemo> createState() => _ShopDemoState();
}

class _ShopDemoState extends State<ShopDemo> {
  final _cart = <String, int>{'p1': 1, 'p3': 1};
  final _favs = <String>{'p6'};
  int _category = 0;
  int _tab = 0;

  int get _count => _cart.values.fold(0, (a, b) => a + b);

  void _add(Product p) {
    setState(() => _cart.update(p.id, (q) => q + 1, ifAbsent: () => 1));
    context.showToast('${p.title} added to cart', status: UiStatus.success, icon: Icons.shopping_bag_rounded);
  }

  Future<void> _openCart() => UiSheet.show<void>(
        context,
        title: 'Your cart',
        child: StatefulBuilder(
          builder: (c, setSheet) => ShopCart(
            cart: _cart,
            onChanged: (id, q) {
              setState(() => q <= 0 ? _cart.remove(id) : _cart[id] = q);
              setSheet(() {});
            },
            onCheckout: () {
              Navigator.pop(c);
              UiDialog.success(context, title: 'Order placed', message: 'We sent the receipt to your email.');
              setState(_cart.clear);
            },
          ),
        ),
      );

  Widget _card(Product p, int i) => UiProductCard(
        title: p.title,
        subtitle: p.brand,
        price: p.price,
        compareAt: p.compareAt,
        rating: p.rating,
        reviewCount: p.reviews,
        imageUrl: pic('shop${p.id}'),
        isFavorite: _favs.contains(p.id),
        onFavoriteChanged: (v) => setState(() => v ? _favs.add(p.id) : _favs.remove(p.id)),
        onAdd: () => _add(p),
        onTap: () => _add(p),
      );

  @override
  Widget build(BuildContext context) {
    final sale = shopProducts.where((p) => p.compareAt != null).toList();
    return Scaffold(
      appBar: UiAppBar(
        titleWidget: Row(
          children: [
            UiAvatar(name: 'Ana Silva', imageUrl: pic('ana', 200, 200), size: 36),
            const UiGap.md(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Good morning', style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
                  Text('Ana Silva', maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleMedium),
                ],
              ),
            ),
          ],
        ),
        actions: [
          UiIconButton(Icons.notifications_none_rounded, badge: '', onPressed: () => context.showToast('No new alerts')),
          UiCartIconButton(count: _count, onPressed: _openCart),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: UiMaxWidth(
              maxWidth: 1100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.sm, UiSpace.lg, UiSpace.lg),
                    child: UiSearchField(hint: 'Search products', onFilterTap: () {}, filterCount: 1, readOnly: true, onTap: () {}),
                  ),
                  Padding(
                    padding: UiSpace.page,
                    child: UiPromoBanner(
                      eyebrow: 'Summer sale',
                      title: 'Up to 50% off',
                      subtitle: 'On shoes, bags and more',
                      ctaLabel: 'Shop now',
                      trailingImageUrl: pic('promoshoe', 400, 400),
                      onTap: () => setState(() => _category = 1),
                    ),
                  ),
                  const UiGap.xl(),
                  UiHorizontalList(
                    children: [
                      for (final (i, (label, icon)) in _categories.indexed)
                        UiCategoryChip(label, icon: icon, selected: _category == i, onTap: () => setState(() => _category = i)),
                    ],
                  ),
                  const UiGap.xl(),
                  Padding(
                    padding: UiSpace.page,
                    child: UiFlashSale(endsAt: ahead(hours: 2, minutes: 45), onSeeAll: () {}),
                  ),
                  const UiGap.md(),
                  UiHorizontalList.builder(
                    height: 300,
                    itemExtent: 170,
                    itemCount: sale.length,
                    itemBuilder: (c, i) => _card(sale[i], i),
                  ),
                  const UiGap.xl(),
                  const Padding(
                    padding: UiSpace.page,
                    child: UiSection(title: 'For you', margin: EdgeInsets.zero, child: SizedBox.shrink()),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.xxl),
            sliver: UiSliverGrid(
              itemCount: shopProducts.length,
              minItemWidth: 165,
              mainAxisExtent: 300,
              maxColumns: 6,
              itemBuilder: (c, i) => _card(shopProducts[i], i),
            ),
          ),
        ],
      ),
      bottomNavigationBar: UiBottomNav(
        index: _tab,
        onChanged: (v) => v == 2 ? _openCart() : setState(() => _tab = v),
        items: [
          const UiNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
          const UiNavItem(icon: Icons.favorite_border_rounded, selectedIcon: Icons.favorite_rounded, label: 'Saved'),
          UiNavItem(icon: Icons.shopping_bag_outlined, label: 'Cart', badge: _count == 0 ? null : '$_count'),
          const UiNavItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Profile'),
        ],
      ),
    );
  }
}

class ShopCart extends StatelessWidget {
  const ShopCart({super.key, required this.cart, required this.onChanged, required this.onCheckout});

  final Map<String, int> cart;
  final void Function(String id, int qty) onChanged;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final items = [for (final p in shopProducts) if (cart.containsKey(p.id)) (p, cart[p.id]!)];
    if (items.isEmpty) {
      return const UiEmptyState(title: 'Your cart is empty', message: 'Add items to see them here.', icon: Icons.shopping_bag_outlined, compact: true);
    }
    final subtotal = items.fold<double>(0, (s, e) => s + e.$1.price * e.$2);
    final saved = items.fold<double>(0, (s, e) => s + ((e.$1.compareAt ?? e.$1.price) - e.$1.price) * e.$2);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (p, q) in items) ...[
          UiCartItem(
            id: p.id,
            title: p.title,
            variant: p.brand,
            price: p.price,
            compareAt: p.compareAt,
            quantity: q,
            imageUrl: pic('shop${p.id}'),
            onQuantityChanged: (v) => onChanged(p.id, v),
            onRemove: () => onChanged(p.id, 0),
          ),
          const UiGap.sm(),
        ],
        UiFreeShippingProgress(subtotal: subtotal, threshold: 300),
        const UiGap.md(),
        UiCouponField(onApply: (code) async => code.toUpperCase() == 'SAVE10' ? null : 'Code not valid'),
        const UiGap.md(),
        UiOrderSummary(
          subtotal: subtotal,
          shipping: subtotal >= 300 ? 0 : 9.9,
          discount: saved > 0 ? saved : null,
          tax: subtotal * 0.08,
          itemCount: items.fold<int>(0, (s, e) => s + e.$2),
          onCheckout: onCheckout,
        ),
      ],
    );
  }
}
