import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';
import 'checkout_page.dart';
import 'product_page.dart';

/// The applied promo code. Shared by the cart and checkout pages (the store has no coupon field).
final pulseCoupon = ValueNotifier<String?>(null);

/// Order totals for the current cart. Used by the cart and the checkout review step.
class PulseTotals {
  PulseTotals(PulseStore store, String? coupon)
      : subtotal = store.subtotal,
        items = store.cartCount,
        discount = coupon == null ? 0 : store.subtotal * 0.1 {
    shipping = subtotal >= freeShippingAt || subtotal == 0 ? 0 : 9.9;
    tax = (subtotal - discount) * 0.08;
  }

  static const freeShippingAt = 150.0;

  final double subtotal;
  final int items;
  final double discount;
  late final double shipping;
  late final double tax;

  double get total => subtotal - discount + shipping + tax;
}

class PulseCartPage extends StatelessWidget {
  const PulseCartPage({super.key});

  Future<String?> _apply(String code) async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (code.trim().toUpperCase() != 'SAVE10') return 'This code is not valid. Try SAVE10.';
    pulseCoupon.value = 'SAVE10';
    return null;
  }

  Future<bool> _confirmRemove(BuildContext context, Product p) => UiDialog.confirm(
        context,
        title: 'Remove item?',
        message: 'Remove ${p.title} from your cart?',
        confirmLabel: 'Remove',
        destructive: true,
      );

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    final cart = store.cart.entries.toList();
    return Scaffold(
      appBar: UiAppBar(
        title: 'Cart',
        subtitle: cart.isEmpty ? null : '${store.cartCount} items',
        actions: [
          if (cart.isNotEmpty)
            UiButton.ghost(
              'Clear',
              size: UiSize.sm,
              onPressed: () {
                PulseScope.read(context).clearCart();
                context.showToast('Cart cleared');
              },
            ),
          const UiGap.sm(),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: UiEmptyState(
                title: 'Your cart is empty',
                message: 'Find something you like in the shop.',
                icon: Icons.shopping_bag_outlined,
                actionLabel: 'Back to shop',
                onAction: () => Navigator.of(context).pop(),
              ),
            )
          : ValueListenableBuilder<String?>(
              valueListenable: pulseCoupon,
              builder: (context, coupon, _) {
                final t = PulseTotals(store, coupon);
                return UiMaxWidth(
                  child: ListView(
                    padding: const EdgeInsets.all(UiSpace.lg),
                    children: [
                      UiFreeShippingProgress(subtotal: t.subtotal, threshold: PulseTotals.freeShippingAt),
                      const UiGap.lg(),
                      for (final e in cart) ...[
                        UiCartItem(
                          id: e.key.id,
                          title: e.key.title,
                          variant: '${e.key.brand} · ${e.key.category}',
                          price: e.key.price,
                          compareAt: e.key.compareAt,
                          quantity: e.value,
                          max: e.key.stock.clamp(1, 99),
                          imageUrl: e.key.image,
                          onTap: () => pulsePush(context, PulseProductPage(product: e.key)),
                          onQuantityChanged: (q) => PulseScope.read(context).setQty(e.key, q),
                          confirmRemove: () => _confirmRemove(context, e.key),
                          onRemove: () {
                            PulseScope.read(context).setQty(e.key, 0);
                            context.showToast('${e.key.title} removed');
                          },
                        ),
                        const UiGap.sm(),
                      ],
                      const UiGap.md(),
                      UiCouponField(
                        hint: 'Promo code (try SAVE10)',
                        appliedCode: coupon,
                        onApply: _apply,
                        onRemove: () => pulseCoupon.value = null,
                      ),
                      const UiGap.lg(),
                      UiOrderSummary(
                        subtotal: t.subtotal,
                        shipping: t.shipping,
                        discount: t.discount > 0 ? t.discount : null,
                        tax: t.tax,
                        total: t.total,
                        itemCount: t.items,
                        checkoutLabel: 'Checkout',
                        onCheckout: () => pulsePush(context, const PulseCheckoutPage()),
                      ),
                      if (store.savings > 0) ...[
                        const UiGap.md(),
                        Text(
                          'You save ${money(store.savings)} on sale items.',
                          textAlign: TextAlign.center,
                          style: context.text.bodyMedium?.copyWith(color: context.palette.success),
                        ),
                      ],
                      const UiGap.lg(),
                      const UiTrustBadges(),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
