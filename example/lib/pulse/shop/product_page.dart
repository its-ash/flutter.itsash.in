import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';
import 'cart_page.dart';

/// Product details: gallery, price, options, reviews, related items, and a buy bar.
class PulseProductPage extends StatefulWidget {
  const PulseProductPage({super.key, required this.product});

  final Product product;

  @override
  State<PulseProductPage> createState() => _PulseProductPageState();
}

class _PulseProductPageState extends State<PulseProductPage> {
  static const _sizes = ['XS', 'S', 'M', 'L', 'XL'];

  String _size = 'M';
  String _color = 'Graphite';
  int _qty = 1;

  Product get p => widget.product;

  List<String> get _gallery => [p.image, PulseAssets.content('run'), PulseAssets.content('trip')];

  bool get _hasSizes => p.category == 'Shoes' || p.category == 'Clothing';

  List<UiColorOption> _colors(BuildContext context) => [
        UiColorOption(context.colors.inverseSurface, 'Graphite'),
        UiColorOption(context.colors.surfaceContainerHighest, 'Stone'),
        UiColorOption(context.colors.primary, 'Pulse'),
        UiColorOption(context.palette.sale, 'Ember'),
      ];

  String get _variant => [if (_hasSizes) 'Size $_size', _color].join(' · ');

  Future<void> _addToCart() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    PulseScope.read(context).addToCart(p, _qty);
    context.showToast('$_qty x ${p.title} ($_variant) added', status: UiStatus.success, icon: Icons.shopping_bag_rounded);
  }

  void _buyNow() {
    PulseScope.read(context).addToCart(p, _qty);
    pulsePush(context, const PulseCartPage());
  }

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    final people = store.data.people;
    final related = [for (final o in store.data.products) if (o.category == p.category && o != p) o];
    final more = related.isEmpty ? store.data.products.where((o) => o != p).take(6).toList() : related;
    final off = p.compareAt == null ? 0 : ((p.compareAt! - p.price) / p.compareAt! * 100).round();
    final muted = context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant);

    return Scaffold(
      appBar: UiAppBar(
        title: p.brand,
        actions: [
          UiWishlistButton(isFavorite: store.isWished(p), onChanged: (_) => PulseScope.read(context).toggleWish(p)),
          const UiGap.xs(),
          UiCartIconButton(count: store.cartCount, onPressed: () => pulsePush(context, const PulseCartPage())),
          const UiGap.sm(),
        ],
      ),
      bottomNavigationBar: UiStickyBuyBar(
        price: p.price * _qty,
        compareAt: p.compareAt == null ? null : p.compareAt! * _qty,
        onAddToCart: p.stock > 0 ? _addToCart : null,
        onBuyNow: p.stock > 0 ? _buyNow : null,
      ),
      body: UiMaxWidth(
        maxWidth: 820,
        child: ListView(
          padding: const EdgeInsets.only(bottom: UiSpace.xxl),
          children: [
            const UiGap.sm(),
            UiCarousel.images(
              _gallery,
              height: 320,
              viewportFraction: 0.92,
              onTap: (i) => UiImageViewer.open(context, _gallery, initialIndex: i),
            ),
            Padding(
              padding: UiSpace.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const UiGap.lg(),
                  Text(p.category.toUpperCase(), style: muted),
                  const UiGap.xs(),
                  Text(p.title, style: context.text.headlineSmall),
                  const UiGap.sm(),
                  Row(
                    children: [
                      UiRatingStars(p.rating, showValue: true, count: p.reviews),
                      const Spacer(),
                      UiStockIndicator(p.stock),
                    ],
                  ),
                  const UiGap.md(),
                  Row(
                    children: [
                      UiPrice(p.price, compareAt: p.compareAt, size: UiSize.lg, showDiscount: false),
                      if (off > 0) ...[const UiGap.sm(), UiDiscountBadge.percent(off)],
                    ],
                  ),
                  const UiGap.xl(),
                  if (_hasSizes) ...[
                    UiSizeSelector(
                      label: 'Size',
                      options: _sizes,
                      selected: _size,
                      unavailable: const {'XS'},
                      onChanged: (v) => setState(() => _size = v),
                      onGuide: () => context.showToast('Sizes run true to fit.', icon: Icons.straighten_rounded),
                    ),
                    const UiGap.lg(),
                  ],
                  UiColorSelector(
                    label: 'Color',
                    options: _colors(context),
                    selected: _color,
                    unavailable: const {'Ember'},
                    onChanged: (v) => setState(() => _color = v),
                  ),
                  const UiGap.lg(),
                  Row(
                    children: [
                      Text('Quantity', style: context.text.titleSmall),
                      const Spacer(),
                      UiQuantityStepper(
                        value: _qty,
                        max: p.stock.clamp(1, 10),
                        onChanged: (v) => setState(() => _qty = v),
                      ),
                    ],
                  ),
                  const UiGap.xl(),
                  Text('About this item', style: context.text.titleMedium),
                  const UiGap.sm(),
                  UiExpandableText(
                    '${p.description} Every order ships in recycled packaging. '
                    'If it is not right, send it back within 30 days for a full refund. '
                    'Care: wipe clean with a soft, damp cloth and let it dry at room temperature.',
                  ),
                  const UiGap.lg(),
                  UiDeliveryEstimate(
                    date: DateTime.now().add(const Duration(days: 3)),
                    until: DateTime.now().add(const Duration(days: 5)),
                    freeShipping: p.price >= 50,
                    location: 'Lisbon 1000',
                    onChangeLocation: () => context.showToast('Location change is not part of the demo'),
                  ),
                  const UiGap.lg(),
                  UiAccordion(
                    items: [
                      UiAccordionItem.text(
                        title: 'Details',
                        icon: Icons.info_outline_rounded,
                        body: 'Brand: ${p.brand}\nCategory: ${p.category}\nItem code: ${p.id.toUpperCase()}\n'
                            'Stock: ${p.stock} units',
                      ),
                      UiAccordionItem.text(
                        title: 'Shipping',
                        icon: Icons.local_shipping_outlined,
                        body: 'Free standard shipping on orders over ${money(50)}. Express delivery in 1 to 2 days '
                            'for ${money(9.9)}.',
                      ),
                      UiAccordionItem.text(
                        title: 'Returns',
                        icon: Icons.assignment_return_outlined,
                        body: 'Return unused items within 30 days. We send a free return label by email.',
                      ),
                    ],
                  ),
                  const UiGap.xl(),
                  Text('Reviews', style: context.text.titleMedium),
                  const UiGap.md(),
                  UiRatingSummary(
                    average: p.rating,
                    total: p.reviews,
                    distribution: _distribution(p.reviews, p.rating),
                  ),
                  const UiGap.lg(),
                  for (final (i, r) in _reviews.indexed)
                    if (i < people.length)
                      Padding(
                        padding: const EdgeInsets.only(bottom: UiSpace.md),
                        child: UiReviewTile(
                          name: people[(i + 1) % people.length].name,
                          avatarUrl: people[(i + 1) % people.length].avatar,
                          rating: r.$1,
                          title: r.$2,
                          text: r.$3,
                          date: DateTime.now().subtract(Duration(days: 3 + i * 9)),
                          verified: i != 2,
                          helpfulCount: 24 - i * 7,
                          onHelpful: () => context.showToast('Thanks for your feedback'),
                        ),
                      ),
                  const UiGap.md(),
                ],
              ),
            ),
            UiSection(
              title: 'You may also like',
              headerPadding: UiSpace.page,
              margin: EdgeInsets.zero,
              child: UiHorizontalList.builder(
                height: 290,
                itemExtent: 170,
                itemCount: more.length,
                itemBuilder: (c, i) {
                  final o = more[i];
                  return UiProductCard(
                    title: o.title,
                    subtitle: o.brand,
                    price: o.price,
                    compareAt: o.compareAt,
                    rating: o.rating,
                    imageUrl: o.image,
                    isFavorite: store.isWished(o),
                    onFavoriteChanged: (_) => PulseScope.read(context).toggleWish(o),
                    onTap: () => pulsePush(context, PulseProductPage(product: o)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _reviews = [
    (5.0, 'Love it', 'Great quality for the price. It looks even better than in the photos.'),
    (4.0, 'Good buy', 'Fits well and feels solid. Delivery took one extra day, but the support team kept me updated.'),
    (4.5, 'Would buy again', 'I use it every day. Simple design and it still looks new after a month.'),
  ];

  /// Fake star counts (index 0 is 5 stars) that match the average.
  static List<int> _distribution(int total, double avg) {
    final top = ((avg - 3) / 2).clamp(0.2, 0.9);
    final five = (total * top).round();
    final four = (total * (1 - top) * 0.6).round();
    final three = (total * (1 - top) * 0.25).round();
    final two = (total * (1 - top) * 0.1).round();
    final one = (total - five - four - three - two).clamp(0, total);
    return [five, four, three, two, one];
  }
}
