import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

class CommerceSection extends StatefulWidget {
  const CommerceSection({super.key});

  @override
  State<CommerceSection> createState() => _CommerceSectionState();
}

class _CommerceSectionState extends State<CommerceSection> {
  final _favs = <int>{1};
  int _qty = 2;
  int _cartQty = 1;
  int _cartCount = 3;
  String? _coupon;
  RangeValues _range = const RangeValues(40, 260);
  String _size = 'M';
  String _color = 'Black';
  int _step = 1;
  int _address = 0;
  UiPaymentBrand _pay = UiPaymentBrand.visa;
  int _category = 0;
  bool _grid = true;
  bool _wish = false;
  int _helpful = 12;

  static const _products = [
    ('Air Runner', 'Running shoe', 129.0, 159.0, 4.6, 214),
    ('Canvas Tote', 'Everyday bag', 39.0, null, 4.2, 88),
    ('Trail Jacket', 'Waterproof shell', 189.0, 240.0, 4.8, 512),
    ('Smart Watch', 'GPS + heart rate', 249.0, null, 4.4, 1290),
  ];

  @override
  Widget build(BuildContext context) {
    void tap() => toast(context, 'Tapped');
    Future<void> add() => Future<void>.delayed(const Duration(milliseconds: 800));
    return SectionPage(
      children: [
        DemoBlock(
          'UiPrice',
          child: WrapRow(
            children: [
              const UiPrice(129, compareAt: 159),
              const UiPrice(39.99, size: UiSize.sm),
              const UiPrice(1299, compareAt: 1499, size: UiSize.lg, symbol: '€'),
              const UiPrice(9.99, suffix: '/mo'),
              UiPrice(49, compareAt: 79, showDiscount: false, color: context.colors.tertiary),
            ],
          ),
        ),
        DemoBlock(
          'UiDiscountBadge and UiStockIndicator',
          child: WrapRow(
            children: [
              UiDiscountBadge.percent(20),
              const UiDiscountBadge('NEW', status: UiStatus.info),
              const UiDiscountBadge('HOT', status: UiStatus.warning, size: UiSize.lg),
              const UiStockIndicator(24),
              const UiStockIndicator(3),
              const UiStockIndicator(0),
            ],
          ),
        ),
        DemoBlock(
          'UiProductCard',
          child: UiResponsiveGrid(
            minItemWidth: 160,
            childAspectRatio: 0.56,
            children: [
              for (final (i, (title, sub, price, compare, rating, reviews)) in _products.indexed)
                UiProductCard(
                  title: title,
                  subtitle: sub,
                  price: price,
                  compareAt: compare,
                  rating: rating,
                  reviewCount: reviews,
                  imageUrl: pic('product$i'),
                  isFavorite: _favs.contains(i),
                  onFavoriteChanged: (v) => setState(() => v ? _favs.add(i) : _favs.remove(i)),
                  onAdd: () => setState(() => _cartCount++),
                  inStock: i != 1,
                  onTap: tap,
                ),
            ],
          ),
        ),
        DemoBlock(
          'UiProductTile',
          child: Column(
            children: [
              for (final (i, (title, sub, price, compare, rating, reviews)) in _products.take(2).indexed)
                UiProductTile(
                  title: title,
                  subtitle: sub,
                  price: price,
                  compareAt: compare,
                  rating: rating,
                  reviewCount: reviews,
                  imageUrl: pic('product$i'),
                  onAdd: () => setState(() => _cartCount++),
                  onTap: tap,
                ),
            ],
          ),
        ),
        DemoBlock(
          'UiFeaturedProductCard',
          child: UiHorizontalList(
            padding: EdgeInsets.zero,
            children: [
              for (var i = 0; i < 3; i++)
                UiFeaturedProductCard(
                  title: ['Summer drop', 'Studio edit', 'Trail ready'][i],
                  subtitle: 'New collection',
                  price: 89.0 + i * 20,
                  compareAt: i == 0 ? 120 : null,
                  badge: i == 1 ? 'NEW' : null,
                  imageUrl: pic('featured$i', 600, 750),
                  isFavorite: i == 2,
                  onFavoriteChanged: (_) {},
                  onAdd: tap,
                  width: 240,
                ),
            ],
          ),
        ),
        DemoBlock(
          'UiWishlistButton and UiCartIconButton',
          child: WrapRow(
            children: [
              UiWishlistButton(isFavorite: _wish, onChanged: (v) => setState(() => _wish = v)),
              UiWishlistButton(isFavorite: !_wish, filled: false, onChanged: (v) => setState(() => _wish = !v)),
              UiCartIconButton(count: _cartCount, onPressed: () => setState(() => _cartCount = 0)),
              const UiCartIconButton(count: 120, onPressed: null),
            ],
          ),
        ),
        DemoBlock(
          'UiQuantityStepper',
          child: WrapRow(
            children: [
              UiQuantityStepper(value: _qty, onChanged: (v) => setState(() => _qty = v)),
              UiQuantityStepper(
                value: _cartQty,
                size: UiSize.sm,
                onChanged: (v) => setState(() => _cartQty = v),
                onRemove: () => toast(context, 'Removed'),
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiAddToCartButton',
          child: Column(
            children: [
              UiAddToCartButton(onPressed: () async {
                await add();
                if (mounted) setState(() => _cartCount++);
              }),
              const UiGap.sm(),
              UiAddToCartButton(label: 'Add to bag', expand: false, size: UiSize.sm, onPressed: add),
            ],
          ),
        ),
        DemoBlock(
          'UiCartItem',
          subtitle: 'Swipe left to remove',
          child: Column(
            children: [
              UiCartItem(
                id: 'air',
                title: 'Air Runner',
                variant: 'Size 42 · Black',
                price: 129,
                compareAt: 159,
                quantity: _qty,
                imageUrl: pic('product0'),
                onQuantityChanged: (v) => setState(() => _qty = v),
                onRemove: () => toast(context, 'Removed'),
                confirmRemove: () => UiDialog.confirm(context, title: 'Remove item?', destructive: true),
              ),
              const UiGap.sm(),
              UiCartItem(
                id: 'tote',
                title: 'Canvas Tote with a very long product name that wraps',
                variant: 'Natural',
                price: 39,
                quantity: 1,
                imageUrl: pic('product1'),
                onQuantityChanged: (_) {},
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiOrderSummary',
          child: UiOrderSummary(
            subtotal: 258,
            shipping: 0,
            discount: 20,
            tax: 12,
            itemCount: 3,
            extras: const [('Gift wrap', 4)],
            onCheckout: tap,
          ),
        ),
        DemoBlock(
          'UiCouponField',
          child: UiCouponField(
            appliedCode: _coupon,
            onApply: (code) async {
              await Future<void>.delayed(const Duration(milliseconds: 500));
              if (code.toUpperCase() != 'SAVE10') return 'Code not valid. Try SAVE10';
              if (mounted) setState(() => _coupon = code.toUpperCase());
              return null;
            },
            onRemove: () => setState(() => _coupon = null),
          ),
        ),
        const DemoBlock(
          'UiFreeShippingProgress',
          child: Column(
            children: [
              UiFreeShippingProgress(subtotal: 38, threshold: 50),
              UiGap.md(),
              UiFreeShippingProgress(subtotal: 64, threshold: 50),
            ],
          ),
        ),
        DemoBlock(
          'UiStickyBuyBar',
          child: ClipRRect(
            borderRadius: context.tokens.md,
            child: UiStickyBuyBar(price: 129, compareAt: 159, onAddToCart: add, onBuyNow: tap),
          ),
        ),
        DemoBlock(
          'UiCategoryChip',
          child: UiHorizontalList(
            padding: EdgeInsets.zero,
            children: [
              for (final (i, (label, icon)) in const [
                ('All', Icons.apps_rounded),
                ('Shoes', Icons.ice_skating_outlined),
                ('Bags', Icons.work_outline_rounded),
                ('Watches', Icons.watch_outlined),
                ('Beauty', Icons.spa_outlined),
              ].indexed)
                UiCategoryChip(label, icon: icon, selected: _category == i, onTap: () => setState(() => _category = i)),
              UiCategoryChip('Sale', imageUrl: pic('sale', 200, 200), onTap: tap),
            ],
          ),
        ),
        DemoBlock(
          'UiCategoryTile',
          child: UiResponsiveGrid(
            minItemWidth: 150,
            children: [
              UiCategoryTile('Women', imageUrl: pic('women', 600, 500), subtitle: '120 items', onTap: tap),
              UiCategoryTile('Men', imageUrl: pic('men', 600, 500), subtitle: '98 items', onTap: tap),
              UiCategoryTile('Kids', icon: Icons.child_care_rounded, subtitle: '45 items', onTap: tap),
            ],
          ),
        ),
        DemoBlock(
          'UiPromoBanner',
          child: Column(
            children: [
              UiPromoBanner(eyebrow: 'Limited', title: 'Up to 50% off', subtitle: 'Summer styles', ctaLabel: 'Shop now', onTap: tap),
              const UiGap.md(),
              UiPromoBanner(
                title: 'New arrivals',
                subtitle: 'Fresh picks every week',
                ctaLabel: 'Explore',
                imageUrl: pic('promo', 1200, 500),
                onTap: tap,
              ),
              const UiGap.md(),
              UiPromoBanner(
                eyebrow: 'Members',
                title: 'Free shipping',
                ctaLabel: 'Join',
                trailingImageUrl: pic('promoside', 400, 400),
                onTap: tap,
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiFlashSale',
          child: UiFlashSale(endsAt: ahead(hours: 3, minutes: 12), onSeeAll: tap),
        ),
        DemoBlock(
          'UiSortFilterBar',
          child: UiSortFilterBar(
            resultCount: 248,
            filterCount: 2,
            onSort: tap,
            onFilter: tap,
            isGrid: _grid,
            onViewChanged: (v) => setState(() => _grid = v),
          ),
        ),
        DemoBlock(
          'UiPriceRangeFilter',
          child: UiPriceRangeFilter(min: 0, max: 500, values: _range, divisions: 50, onChanged: (v) => setState(() => _range = v)),
        ),
        DemoBlock(
          'UiSizeSelector',
          child: UiSizeSelector(
            options: const ['XS', 'S', 'M', 'L', 'XL', 'XXL'],
            selected: _size,
            unavailable: const {'XS', 'XXL'},
            onChanged: (v) => setState(() => _size = v),
            onGuide: tap,
          ),
        ),
        DemoBlock(
          'UiColorSelector',
          child: UiColorSelector(
            options: const [
              UiColorOption(Color(0xFF111111), 'Black'),
              UiColorOption(Color(0xFFFFFFFF), 'White'),
              UiColorOption(Color(0xFF1E3A8A), 'Navy'),
              UiColorOption(Color(0xFFB91C1C), 'Red'),
              UiColorOption(Color(0xFF15803D), 'Green'),
            ],
            selected: _color,
            unavailable: const {'Green'},
            onChanged: (v) => setState(() => _color = v),
          ),
        ),
        DemoBlock(
          'UiCheckoutSteps',
          child: UiCheckoutSteps(current: _step, onStepTap: (v) => setState(() => _step = v)),
        ),
        DemoBlock(
          'UiAddressCard',
          child: Column(
            children: [
              UiAddressCard(
                name: 'Ana Silva',
                lines: const ['12 Main St, Apt 4', 'Lisbon 1000-001', 'Portugal'],
                phone: '+351 912 345 678',
                isDefault: true,
                selected: _address == 0,
                onTap: () => setState(() => _address = 0),
                onEdit: tap,
              ),
              const UiGap.sm(),
              UiAddressCard(
                name: 'Ana Silva',
                label: 'Work',
                icon: Icons.work_outline_rounded,
                lines: const ['Av. da Liberdade 200', 'Lisbon 1250-147'],
                selected: _address == 1,
                onTap: () => setState(() => _address = 1),
                onEdit: tap,
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiPaymentMethodTile',
          child: Column(
            children: [
              for (final (b, n) in const [
                (UiPaymentBrand.visa, '4242424242424242'),
                (UiPaymentBrand.mastercard, '5555555555554444'),
                (UiPaymentBrand.paypal, null),
                (UiPaymentBrand.applePay, null),
                (UiPaymentBrand.cod, null),
              ]) ...[
                UiPaymentMethodTile(brand: b, number: n, selected: _pay == b, onTap: () => setState(() => _pay = b)),
                const UiGap.sm(),
              ],
              WrapRow(children: [for (final b in UiPaymentBrand.values) UiPaymentBrandMark(b)]),
            ],
          ),
        ),
        DemoBlock(
          'UiDeliveryEstimate',
          child: Column(
            children: [
              UiDeliveryEstimate(date: ahead(days: 2), until: ahead(days: 4), freeShipping: true, location: 'Lisbon 1000', onChangeLocation: tap),
              const UiGap.sm(),
              UiDeliveryEstimate(date: ahead(days: 1), note: 'Order within 3 h'),
            ],
          ),
        ),
        const DemoBlock('UiTrustBadges', child: UiTrustBadges()),
        DemoBlock(
          'UiOrderCard',
          child: Column(
            children: [
              for (final (i, s) in UiOrderStatus.values.indexed) ...[
                UiOrderCard(
                  orderId: 'A10${42 + i}',
                  total: 58.0 + i * 40,
                  status: s,
                  date: ago(days: i * 3),
                  imageUrls: [for (var k = 0; k <= i % 4; k++) pic('order$i$k', 200, 200)],
                  itemCount: i % 4 + 1,
                  onTap: tap,
                ),
                const UiGap.sm(),
              ],
            ],
          ),
        ),
        DemoBlock(
          'UiOrderTracker',
          child: Column(
            children: [
              UiOrderTracker(current: 2, times: [ago(days: 2), ago(days: 1), ago(hours: 3)]),
              const UiGap.lg(),
              UiOrderTracker(current: 1, cancelled: true, cancelledNote: 'Refund sent to your card', cancelledTime: ago(hours: 5)),
            ],
          ),
        ),
        DemoBlock(
          'UiReviewTile',
          child: UiReviewTile(
            name: 'Mia Torres',
            title: 'Great fit',
            rating: 4.5,
            text: 'True to size and very light. I wore them for a half marathon and they felt great the whole way.',
            date: ago(days: 4),
            avatarUrl: pic('mia', 200, 200),
            photos: [pic('review1', 300, 300), pic('review2', 300, 300)],
            verified: true,
            helpfulCount: _helpful,
            onHelpful: () => setState(() => _helpful++),
          ),
        ),
        const DemoBlock('UiRatingSummary', child: UiRatingSummary(average: 4.6, distribution: [820, 210, 60, 20, 12])),
      ],
    );
  }
}
