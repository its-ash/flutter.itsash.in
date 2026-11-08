# Commerce

Widgets and helpers for shop apps. Import `package:theme/theme.dart`. All widgets use the theme colors. They work in light mode and dark mode.

## Formatting

Use `UiMoney` for prices and `UiFormat` for dates and counts. Refer to [foundation.md](foundation.md#formatting).

## Price

### UiPrice
Shows a price. If `compareAt` is more than `amount`, it shows a strikethrough price and the discount percent in the sale color.

```dart
UiPrice(129, compareAt: 159)
```
Params: `amount`, `compareAt`, `size` (`UiSize`), `symbol`, `decimals`, `showDiscount` (true), `color`, `suffix` (e.g. `'/mo'`).
Screen readers read "Price 129 dollars, was 159 dollars, 19 percent off".

### UiDiscountBadge
Small label for a discount or a promotion.

```dart
UiDiscountBadge.percent(20)            // -20%
UiDiscountBadge('NEW', status: UiStatus.info)
```
Params: `label`, `status`, `color`, `size`.

### UiStockIndicator
Dot and text for stock level.

```dart
UiStockIndicator(3)   // Only 3 left
```
Params: `stock`, `lowThreshold` (5), `inStockLabel`, `outOfStockLabel`.

## Products

### UiProductCard
Grid card for a product. Use it in a 2-column grid (`childAspectRatio` about 0.62, or set `mainAxisExtent`).

```dart
UiProductCard(title: 'Air Max', price: 129, imageUrl: url, onTap: () {})
```
Params: `title`, `price`, `imageUrl`, `onTap`, `subtitle`, `compareAt`, `rating`, `reviewCount`, `badge` (default is the discount percent), `isFavorite`, `onFavoriteChanged` (shows the heart), `onAdd` (shows the "+" button), `inStock`, `outOfStockLabel`, `aspectRatio` (1), `symbol`, `heroTag`.

### UiProductTile
Horizontal product row for lists.

```dart
UiProductTile(title: 'Air Max', price: 129, imageUrl: url, onAdd: () {})
```
Params: same as `UiProductCard`, plus `imageSize` (96) and `trailing`.

### UiFeaturedProductCard
Wide card with a full image and text on the image. Use it in a horizontal carousel.

```dart
UiFeaturedProductCard(title: 'Summer drop', price: 89, imageUrl: url)
```
Params: `title`, `price`, `imageUrl`, `onTap`, `subtitle`, `compareAt`, `badge`, `isFavorite`, `onFavoriteChanged`, `onAdd`, `width` (280), `aspectRatio` (0.8), `symbol`.

### UiWishlistButton
Heart toggle with a scale animation. The active heart uses the sale color.

```dart
UiWishlistButton(isFavorite: fav, onChanged: (v) => setState(() => fav = v))
```
Params: `isFavorite`, `onChanged`, `size` (36), `filled` (surface circle behind the heart).

### UiCartIconButton
Cart icon with a count badge. Counts above 99 show "99+".

```dart
UiCartIconButton(count: 3, onPressed: openCart)
```
Params: `count`, `onPressed`, `icon`, `variant`, `size`.

## Cart

### UiQuantityStepper
Pill with minus, quantity, and plus. The value stays between `min` and `max`. If the value is at `min` and `onRemove` is set, a delete icon replaces minus.

```dart
UiQuantityStepper(value: qty, onChanged: (v) => setState(() => qty = v))
```
Params: `value`, `onChanged`, `min` (1), `max` (99), `step` (1), `onRemove`, `size`.

### UiAddToCartButton
Full-width button. During the async action it shows a spinner. Then it shows "Added" with a check for 1.5 s.

```dart
UiAddToCartButton(onPressed: () => cart.add(item))
```
Params: `onPressed` (`Future<void> Function()?`), `label`, `successLabel`, `icon`, `loading`, `expand` (true), `size`, `variant`, `successDuration`.
If `onPressed` throws, the button goes back to idle and the error continues.

### UiCartItem
Cart row with image, title, variant text, line price, and quantity stepper. Swipe left to remove.

```dart
UiCartItem(
  title: 'Air Max', price: 129, quantity: 2, variant: 'Size 42 · Black',
  onQuantityChanged: (q) {}, onRemove: () {},
)
```
Params: `title`, `price` (unit price), `quantity`, `onQuantityChanged`, `imageUrl`, `variant`, `compareAt`, `onRemove`, `confirmRemove` (`Future<bool> Function()?`), `onTap`, `id` (key for swipe), `min`, `max`, `symbol`, `removeLabel`.

### UiOrderSummary
Card with cost lines and the total. Shipping 0 shows "Free". Discount shows as a negative value in the success color. If you do not give `total`, the widget calculates it.

```dart
UiOrderSummary(subtotal: 258, shipping: 0, discount: 20, tax: 12, onCheckout: pay)
```
Params: `subtotal`, `shipping`, `discount`, `tax`, `total`, `extras` (`List<(String, num)>`), `itemCount`, `checkoutLabel`, `onCheckout`, `loading`, `symbol`, `title`, `freeLabel`.

### UiCouponField
Text field and Apply button for a promo code. `onApply` returns null on success or an error message.

```dart
UiCouponField(onApply: (code) async => code == 'SAVE10' ? null : 'Code not valid')
```
Params: `onApply`, `onRemove`, `appliedCode`, `hint`, `applyLabel`, `appliedText`, `emptyError`, `failedError`.

### UiFreeShippingProgress
Text and progress bar to the free shipping limit.

```dart
UiFreeShippingProgress(subtotal: 38, threshold: 50)
```
Params: `subtotal`, `threshold`, `symbol`, `unlockedText`.

### UiStickyBuyBar
Bottom bar with the price and buy buttons. It uses the safe area.

```dart
Scaffold(bottomNavigationBar: UiStickyBuyBar(price: 129, onAddToCart: add, onBuyNow: buy))
```
Params: `price`, `compareAt`, `onAddToCart` (async), `onBuyNow`, `addLabel`, `buyLabel`, `priceLabel`, `symbol`, `buyLoading`, `leading`.

## Catalog

### UiCategoryChip
Round icon or image with a label below. Use in a horizontal list.

```dart
UiCategoryChip('Shoes', icon: Icons.ice_skating_outlined, selected: true, onTap: () {})
```
Params: `label`, `icon`, `imageUrl`, `selected`, `onTap`, `size` (64).

### UiCategoryTile
Rounded card with an image background and a label on it.

```dart
UiCategoryTile('Women', imageUrl: url, subtitle: '120 items', onTap: () {})
```
Params: `label`, `imageUrl`, `icon`, `subtitle`, `onTap`, `aspectRatio` (1.2), `height`.

### UiPromoBanner
Banner with a gradient or image background, a tag, a title, a subtitle, and a call-to-action pill.

```dart
UiPromoBanner(eyebrow: 'Limited', title: 'Up to 50% off', ctaLabel: 'Shop now', onTap: () {})
```
Params: `title`, `subtitle`, `eyebrow`, `ctaLabel`, `onTap`, `imageUrl`, `trailingImageUrl`, `gradient`, `minHeight` (168).

### UiFlashSale
Section header with a live countdown to `endsAt`. The timer stops when the widget is removed.

```dart
UiFlashSale(endsAt: DateTime.now().add(const Duration(hours: 3)), onSeeAll: () {})
```
Params: `endsAt`, `title`, `endedText`, `onSeeAll`, `seeAllLabel`, `onEnded`, `icon`.

### UiSortFilterBar
Row with the result count, a Sort button, and a Filter button with an active-count badge.

```dart
UiSortFilterBar(resultCount: 248, filterCount: 2, onSort: sort, onFilter: filter)
```
Params: `onSort`, `onFilter`, `sortLabel`, `filterLabel`, `filterCount`, `resultCount`, `resultLabel`, `isGrid`, `onViewChanged`.

### UiPriceRangeFilter
Range slider with money labels.

```dart
UiPriceRangeFilter(min: 0, max: 500, values: range, divisions: 50, onChanged: (v) => setState(() => range = v))
```
Params: `min`, `max`, `values`, `onChanged`, `onChangeEnd`, `divisions`, `symbol`, `title`.

### UiSizeSelector
Size boxes. Sizes in `unavailable` show a line through them and you cannot select them.

```dart
UiSizeSelector(options: ['S', 'M', 'L'], selected: 'M', unavailable: {'L'}, onChanged: pick)
```
Params: `options`, `selected`, `onChanged`, `unavailable`, `label`, `guideLabel`, `onGuide`.

### UiColorSelector
Color swatches with names. The selected swatch has a ring and a check.

```dart
UiColorSelector(
  options: const [UiColorOption(Color(0xFF111111), 'Black'), UiColorOption(Color(0xFFFFFFFF), 'White')],
  selected: 'Black', onChanged: pick,
)
```
Params: `options` (`UiColorOption(color, name)`), `selected` (name), `onChanged`, `unavailable`, `label`, `size` (36).

## Checkout

### UiCheckoutSteps
Horizontal steps: Cart, Address, Payment, Review.

```dart
UiCheckoutSteps(current: 1)
```
Params: `current`, `steps`, `onStepTap` (only for completed steps).

### UiAddressCard
Address card with a radio state and an edit action.

```dart
UiAddressCard(name: 'Ana Silva', lines: ['12 Main St', 'Lisbon 1000'], selected: true, onTap: () {})
```
Params: `name`, `lines`, `label` ('Home'), `phone`, `selected`, `onTap`, `onEdit`, `isDefault`, `defaultLabel`, `icon`.

### UiPaymentMethodTile
Payment option with a brand mark and a masked number.

```dart
UiPaymentMethodTile(brand: UiPaymentBrand.visa, number: '4242424242424242', selected: true, onTap: () {})
```
Params: `brand`, `title`, `number` (shows `•••• 4242`), `subtitle`, `selected`, `onTap`, `trailing`.
`UiPaymentBrand`: `visa`, `mastercard`, `amex`, `paypal`, `upi`, `applePay`, `googlePay`, `cod`, `card`. `UiPaymentBrandMark(brand)` shows the mark only.

### UiDeliveryEstimate
Truck icon with the delivery date and a shipping note.

```dart
UiDeliveryEstimate(date: DateTime(2026, 3, 14), freeShipping: true)
```
Params: `date`, `until`, `text`, `freeShipping`, `note`, `location`, `onChangeLocation`, `prefix`, `freeLabel`, `changeLabel`.

### UiTrustBadges
Row of small icons with labels. The default items are secure payment, easy returns, fast delivery, and genuine products.

```dart
const UiTrustBadges()
```
Params: `items` (`UiTrustItem(icon, label)`).

## Orders and reviews

### UiOrderCard
Order summary card with status, item images, item count, and total.

```dart
UiOrderCard(orderId: 'A1042', total: 258, status: UiOrderStatus.shipped, imageUrls: urls)
```
Params: `orderId`, `total`, `status` (`UiOrderStatus`), `statusLabel`, `date`, `imageUrls`, `itemCount`, `onTap`, `symbol`.
`UiOrderStatus`: `pending`, `processing`, `shipped`, `delivered`, `cancelled`, `returned`.

### UiOrderTracker
Vertical order steps. The current step has a highlight. In the cancelled state, a red Cancelled step comes after the last reached step.

```dart
UiOrderTracker(current: 2, times: [ordered, packed, shipped])
```
Params: `current`, `steps` (`UiTrackStep(title, subtitle:, time:, icon:)`), `times`, `cancelled`, `cancelledLabel`, `cancelledNote`, `cancelledTime`.

### UiReviewTile
One customer review.

```dart
UiReviewTile(name: 'Mia', rating: 4.5, text: 'Great fit.', date: d, verified: true)
```
Params: `name`, `rating`, `text`, `title`, `date`, `avatarUrl`, `photos`, `onPhotoTap`, `helpfulCount`, `onHelpful`, `verified`, `verifiedLabel`, `maxLines`.

### UiRatingSummary
Average rating, stars, total, and bars for 5 to 1 stars.

```dart
UiRatingSummary(average: 4.6, distribution: [820, 210, 60, 20, 12])
```
Params: `average`, `distribution` (index 0 is 5 stars), `total`, `reviewsLabel`.
