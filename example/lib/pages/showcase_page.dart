import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

/// Three real screens (shop, product, cart) built only from theme widgets,
/// so the whole design can be judged in context. Mirrors DESIGN.md.
class ShowcasePage extends StatelessWidget {
  const ShowcasePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const GalleryPage(
      children: [
        Demo(
          'Shop',
          subtitle: 'UiPromoCard · UiChoiceChips · UiMediaCard · UiPromoBanner',
          child: _Phone(_ShopScreen()),
        ),
        Demo(
          'Product',
          subtitle: 'UiIconButton · UiPageDots · UiRating · UiColorPicker · UiOptionTiles · UiButton lg',
          child: _Phone(_ProductScreen()),
        ),
        Demo('Cart', subtitle: 'UiCard · UiStepper · soft danger buttons · totals', child: _Phone(_CartScreen())),
      ],
    );
  }
}

/// Rounded frame that stands in for a phone screen.
class _Phone extends StatelessWidget {
  const _Phone(this.child);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: BoxDecoration(
            color: c.background,
            borderRadius: UiRadius.all(UiRadius.xl),
            border: Border.all(color: c.border, width: 6),
            boxShadow: context.shadowMd,
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ),
    );
  }
}

class _ShopScreen extends StatefulWidget {
  const _ShopScreen();

  @override
  State<_ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<_ShopScreen> {
  String _category = 'Men';

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final items = [
      ('Hoodie', '\$80', productImages[4], c.chart[4], null),
      ('Cargo pant', '\$80', productImages[5], c.chart[6], '23%'),
      ('Sneaker', '\$120', productImages[6], c.chart[2], null),
      ('Watch', '\$210', productImages[7], c.chart[0], 'New'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(UiSpace.page, UiSpace.xl, UiSpace.page, UiSpace.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text('NOVA', style: context.text.displaySmall)),
              UiIconButton(
                Icons.search_rounded,
                tooltip: 'Search',
                variant: UiButtonVariant.outline,
                size: UiSize.lg,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: UiSpace.xl),
          UiPromoCard(
            title: 'Step into style',
            message: 'The new theme brings soft color and round shapes.',
            actionLabel: 'Show more',
            onAction: () => context.showToast('Show more'),
            image: ClipRRect(
              borderRadius: UiRadius.all(UiRadius.md),
              child: Image.asset(productImages[6], height: 110, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: UiSpace.xl),
          UiChoiceChips<String>(
            scrollable: true,
            options: const [
              UiChoice('Men', 'Men'),
              UiChoice('Women', 'Women'),
              UiChoice('Kids', 'Kids'),
              UiChoice('New', 'New'),
              UiChoice('Sale', 'Sale'),
            ],
            value: _category,
            onChanged: (v) => setState(() => _category = v),
          ),
          const SizedBox(height: UiSpace.xl),
          SizedBox(
            height: 260,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(width: UiSpace.md),
              itemBuilder: (context, i) {
                final (name, price, image, tint, badge) = items[i];
                return SizedBox(
                  width: 150,
                  child: UiMediaCard(
                    title: name,
                    subtitle: price,
                    tint: tint,
                    badge: badge,
                    image: ClipRRect(borderRadius: UiRadius.all(UiRadius.md), child: Image.asset(image)),
                    onTap: () {},
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: UiSpace.lg),
          UiPromoBanner(
            title: 'Free shipping',
            subtitle: 'On orders over \$50',
            icon: Icons.local_shipping_rounded,
            onTap: () => context.showToast('Free shipping', status: UiStatus.success),
          ),
        ],
      ),
    );
  }
}

class _ProductScreen extends StatefulWidget {
  const _ProductScreen();

  @override
  State<_ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<_ProductScreen> {
  static const _swatches = [Color(0xFFFF7E70), Color(0xFF7261EB), Color(0xFFDBD8B3)];
  Color _color = _swatches.first;
  int? _size = 9;
  int _page = 0;
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: c.surface,
          padding: const EdgeInsets.fromLTRB(UiSpace.page, UiSpace.xl, UiSpace.page, UiSpace.xxl),
          child: Column(
            children: [
              Row(
                children: [
                  UiIconButton(
                    Icons.arrow_back_rounded,
                    tooltip: 'Back',
                    variant: UiButtonVariant.outline,
                    size: UiSize.lg,
                    onPressed: () {},
                  ),
                  const Spacer(),
                  UiIconButton(
                    _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    tooltip: 'Favorite',
                    variant: UiButtonVariant.outline,
                    status: _liked ? UiStatus.danger : null,
                    size: UiSize.lg,
                    onPressed: () => setState(() => _liked = !_liked),
                  ),
                ],
              ),
              const SizedBox(height: UiSpace.lg),
              SizedBox(
                height: 200,
                child: PageView(
                  onPageChanged: (i) => setState(() => _page = i),
                  children: [
                    for (final img in [productImages[6], productImages[3], productImages[7]])
                      Center(
                        child: ClipRRect(
                          borderRadius: UiRadius.all(UiRadius.lg),
                          child: Image.asset(img, fit: BoxFit.cover, width: 260, height: 200),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: UiSpace.lg),
              UiPageDots(count: 3, index: _page),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(UiSpace.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Air Runner 270', style: context.text.headlineMedium),
              const SizedBox(height: UiSpace.xs),
              Text('\$150', style: context.text.headlineSmall),
              const SizedBox(height: UiSpace.md),
              Row(
                children: [
                  const UiRating(value: 4.5, allowHalf: true),
                  const SizedBox(width: UiSpace.sm),
                  Text('4.7', style: context.text.bodyMedium),
                  const SizedBox(width: UiSpace.sm),
                  UiButton('147 reviews', variant: UiButtonVariant.link, size: UiSize.sm, onPressed: () {}),
                ],
              ),
              const SizedBox(height: UiSpace.lg),
              UiColorPicker(
                value: _color,
                colors: _swatches,
                labels: const ['Coral', 'Violet', 'Sand'],
                size: UiSize.lg,
                spacing: UiSpace.sm,
                onChanged: (v) => setState(() => _color = v),
              ),
              const SizedBox(height: UiSpace.lg),
              Text('Select size', style: context.text.bodyMedium?.copyWith(color: c.textMuted)),
              const SizedBox(height: UiSpace.sm),
              UiOptionTiles<int>(
                options: [for (var s = 7; s <= 13; s++) UiChoice(s, '$s', enabled: s != 10)],
                value: _size,
                onChanged: (v) => setState(() => _size = v),
              ),
              const SizedBox(height: UiSpace.xl),
              UiButton(
                'Add to bag',
                icon: Icons.shopping_bag_rounded,
                size: UiSize.lg,
                expand: true,
                onPressed: () => context.showToast('Added to bag', status: UiStatus.success),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartScreen extends StatefulWidget {
  const _CartScreen();

  @override
  State<_CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<_CartScreen> {
  final _items = [
    _CartItem('Air Runner 270', productImages[6], const Color(0xFFFF7E70), 'M', 150, 1),
    _CartItem('Cozy hoodie', productImages[4], const Color(0xFF7261EB), 'M', 80, 2),
  ];

  int get _total => _items.fold(0, (sum, i) => sum + i.price * i.qty);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(UiSpace.page, UiSpace.xl, UiSpace.page, UiSpace.page),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              UiIconButton(
                Icons.arrow_back_rounded,
                tooltip: 'Back',
                variant: UiButtonVariant.outline,
                size: UiSize.lg,
                onPressed: () {},
              ),
              const Spacer(),
              UiIconButton(
                Icons.more_horiz_rounded,
                tooltip: 'More',
                variant: UiButtonVariant.outline,
                size: UiSize.lg,
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: UiSpace.xl),
          Row(
            children: [
              Expanded(child: Text('CART', style: context.text.displaySmall)),
              UiButton(
                'Delete all',
                icon: Icons.delete_outline_rounded,
                variant: UiButtonVariant.soft,
                status: UiStatus.danger,
                size: UiSize.sm,
                onPressed: _items.isEmpty ? null : () => setState(_items.clear),
              ),
            ],
          ),
          const SizedBox(height: UiSpace.lg),
          if (_items.isEmpty)
            const UiEmptyState(icon: Icons.shopping_bag_outlined, title: 'Your bag is empty')
          else
            for (final item in _items) ...[
              UiCard(
                padding: const EdgeInsets.all(UiSpace.md),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: UiRadius.all(UiRadius.md),
                      child: Image.asset(item.image, width: 96, height: 110, fit: BoxFit.cover),
                    ),
                    const SizedBox(width: UiSpace.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleMedium,
                          ),
                          const SizedBox(height: UiSpace.xs),
                          Row(
                            children: [
                              Text('Color: ', style: context.text.bodySmall),
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
                              ),
                              const SizedBox(width: UiSpace.md),
                              Text('Size: ', style: context.text.bodySmall),
                              Text(item.size, style: context.text.labelMedium),
                            ],
                          ),
                          const SizedBox(height: UiSpace.sm),
                          Row(
                            children: [
                              Expanded(child: Text('\$${item.price}', style: context.text.headlineSmall)),
                              UiStepper<int>(
                                value: item.qty,
                                min: 1,
                                max: 9,
                                size: UiSize.sm,
                                onChanged: (v) => setState(() => item.qty = v),
                              ),
                              const SizedBox(width: UiSpace.xs),
                              UiIconButton(
                                Icons.delete_outline_rounded,
                                tooltip: 'Remove',
                                variant: UiButtonVariant.soft,
                                status: UiStatus.danger,
                                size: UiSize.sm,
                                onPressed: () => setState(() => _items.remove(item)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: UiSpace.md),
            ],
          const SizedBox(height: UiSpace.sm),
          const UiDivider(),
          const SizedBox(height: UiSpace.lg),
          Row(
            children: [
              Expanded(
                child: Text('Subtotal:', style: context.text.titleLarge?.copyWith(color: c.textMuted)),
              ),
              Text('\$$_total', style: context.text.headlineSmall),
            ],
          ),
          const SizedBox(height: UiSpace.xl),
          UiButton('Checkout', size: UiSize.lg, expand: true, onPressed: _items.isEmpty ? null : () {}),
        ],
      ),
    );
  }
}

class _CartItem {
  _CartItem(this.name, this.image, this.color, this.size, this.price, this.qty);

  final String name;
  final String image;
  final Color color;
  final String size;
  final int price;
  int qty;
}
