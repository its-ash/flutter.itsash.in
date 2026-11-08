import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/commerce/ui_price.dart';
import 'package:theme/src/input/ui_number_stepper.dart';
import 'package:theme/src/foundation/ui_money.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';
import 'package:theme/src/card/ui_card.dart';
import 'package:theme/src/image/ui_image.dart';

class UiQuantityStepper extends StatelessWidget {
  const UiQuantityStepper({
    super.key,
    required this.value,
    this.onChanged,
    this.min = 1,
    this.max = 99,
    this.step = 1,
    this.onRemove,
    this.size = UiSize.md,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final int min;
  final int max;
  final int step;
  final VoidCallback? onRemove;
  final UiSize size;

  @override
  Widget build(BuildContext context) =>
      UiNumberStepper(value: value, onChanged: onChanged, min: min, max: max, step: step, size: size, onRemove: onRemove);
}

enum _AddState { idle, busy, done }

class UiAddToCartButton extends StatefulWidget {
  const UiAddToCartButton({
    super.key,
    this.onPressed,
    this.label = 'Add to cart',
    this.successLabel = 'Added',
    this.icon = Icons.add_shopping_cart_rounded,
    this.loading = false,
    this.expand = true,
    this.size = UiSize.md,
    this.variant = UiButtonVariant.primary,
    this.successDuration = const Duration(milliseconds: 1500),
  });

  final Future<void> Function()? onPressed;
  final String label;
  final String successLabel;
  final IconData? icon;
  final bool loading;
  final bool expand;
  final UiSize size;
  final UiButtonVariant variant;
  final Duration successDuration;

  @override
  State<UiAddToCartButton> createState() => _UiAddToCartButtonState();
}

class _UiAddToCartButtonState extends State<UiAddToCartButton> {
  var _state = _AddState.idle;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _press() async {
    final fn = widget.onPressed;
    if (fn == null || _state != _AddState.idle || widget.loading) return;
    _timer?.cancel();
    setState(() => _state = _AddState.busy);
    try {
      await fn();
    } catch (_) {
      if (mounted) setState(() => _state = _AddState.idle);
      rethrow;
    }
    if (!mounted) return;
    setState(() => _state = _AddState.done);
    _timer = Timer(widget.successDuration, () {
      if (mounted) setState(() => _state = _AddState.idle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final done = _state == _AddState.done;
    return Semantics(
      liveRegion: done,
      child: AnimatedSwitcher(
        duration: UiDuration.normal,
        switchInCurve: UiCurve.standard,
        child: UiButton(
          done ? widget.successLabel : widget.label,
          key: ValueKey(done),
          variant: done ? UiButtonVariant.success : widget.variant,
          size: widget.size,
          icon: done ? Icons.check_rounded : widget.icon,
          loading: widget.loading || _state == _AddState.busy,
          expand: widget.expand,
          onPressed: widget.onPressed == null ? null : _press,
        ),
      ),
    );
  }
}

class UiCartItem extends StatelessWidget {
  const UiCartItem({
    super.key,
    required this.title,
    required this.price,
    this.quantity = 1,
    this.onQuantityChanged,
    this.imageUrl,
    this.variant,
    this.compareAt,
    this.onRemove,
    this.confirmRemove,
    this.onTap,
    this.id,
    this.min = 1,
    this.max = 99,
    this.symbol,
    this.removeLabel = 'Remove',
  });

  final String title;
  final num price;
  final int quantity;
  final ValueChanged<int>? onQuantityChanged;
  final String? imageUrl;
  final String? variant;
  final num? compareAt;
  final VoidCallback? onRemove;
  final Future<bool> Function()? confirmRemove;
  final VoidCallback? onTap;
  final Object? id;
  final int min;
  final int max;
  final String? symbol;
  final String removeLabel;

  Future<bool> _confirm() async => confirmRemove == null || await confirmRemove!();

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final t = context.tokens;
    final q = quantity.clamp(min, max < min ? min : max);
    final unit = math.max(0.0, UiMoney.safe(price));
    final was = compareAt == null ? null : UiMoney.safe(compareAt) * q;

    final card = UiCard(
      onTap: onTap,
      padding: const EdgeInsets.all(UiSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiImage(imageUrl, width: 84, height: 84, radius: t.md, semanticLabel: title),
          const UiGap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                if (variant != null && variant!.trim().isNotEmpty) ...[
                  const UiGap(UiSpace.xxs),
                  Text(
                    variant!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                const UiGap.sm(),
                Row(
                  children: [
                    Expanded(
                      child: UiPrice(unit * q, compareAt: was, size: UiSize.sm, symbol: symbol, showDiscount: false),
                    ),
                    UiQuantityStepper(
                      value: q,
                      min: min,
                      max: max,
                      size: UiSize.sm,
                      onChanged: onQuantityChanged,
                      onRemove: onRemove == null
                          ? null
                          : () async {
                              if (await _confirm()) onRemove!();
                            },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onRemove == null) return card;
    return Dismissible(
      key: ValueKey(id ?? 'cart-$title-${variant ?? ''}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirm(),
      onDismissed: (_) => onRemove!(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.xxl),
        decoration: BoxDecoration(color: cs.errorContainer, borderRadius: t.lg),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(removeLabel, style: context.text.labelLarge?.copyWith(color: cs.onErrorContainer, fontWeight: FontWeight.w700)),
            const UiGap.sm(),
            Icon(Icons.delete_outline_rounded, color: cs.onErrorContainer),
          ],
        ),
      ),
      child: card,
    );
  }
}

class UiOrderSummary extends StatelessWidget {
  const UiOrderSummary({
    super.key,
    required this.subtotal,
    this.shipping,
    this.discount,
    this.tax,
    this.total,
    this.extras = const [],
    this.itemCount,
    this.checkoutLabel,
    this.onCheckout,
    this.loading = false,
    this.symbol,
    this.title = 'Order summary',
    this.freeLabel = 'Free',
  });

  final num subtotal;
  final num? shipping;
  final num? discount;
  final num? tax;
  final num? total;
  final List<(String, num)> extras;
  final int? itemCount;
  final String? checkoutLabel;
  final VoidCallback? onCheckout;
  final bool loading;
  final String? symbol;
  final String? title;
  final String freeLabel;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final ok = context.palette.success;
    double pos(num? v) => math.max(0.0, UiMoney.safe(v));
    final sub = pos(subtotal);
    final ship = shipping == null ? null : pos(shipping);
    final disc = discount == null ? null : UiMoney.safe(discount).abs();
    final tx = tax == null ? null : pos(tax);
    final more = extras.fold(0.0, (a, e) => a + UiMoney.safe(e.$2));
    final sum = total != null ? pos(total) : math.max(0.0, sub + (ship ?? 0) + (tx ?? 0) + more - (disc ?? 0));
    String f(num v) => UiMoney.format(v, symbol: symbol);
    final n = itemCount == null ? null : math.max(0, itemCount!);

    Widget row(String l, String v, [Color? color]) => Padding(
          padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
          child: Row(
            children: [
              Expanded(child: Text(l, style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant))),
              Text(v, style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: color ?? cs.onSurface)),
            ],
          ),
        );

    return UiCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(title!, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const UiGap.sm(),
          ],
          row(n == null ? 'Subtotal' : 'Subtotal ($n ${n == 1 ? 'item' : 'items'})', f(sub)),
          if (ship != null) row('Shipping', ship == 0 ? freeLabel : f(ship), ship == 0 ? ok : null),
          if (disc != null && disc > 0) row('Discount', '-${f(disc)}', ok),
          if (tx != null) row('Tax', f(tx)),
          for (final (l, v) in extras) row(l, f(v)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: UiSpace.sm),
            child: Divider(height: 1, color: cs.outlineVariant),
          ),
          Semantics(
            label: 'Total ${UiMoney.spoken(sum, symbol: symbol)}',
            excludeSemantics: true,
            child: Row(
              children: [
                Expanded(child: Text('Total', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700))),
                Text(f(sum), style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              ],
            ),
          ),
          if (onCheckout != null || checkoutLabel != null) ...[
            const UiGap.lg(),
            UiButton(
              checkoutLabel ?? 'Checkout',
              onPressed: onCheckout,
              loading: loading,
              expand: true,
              trailingIcon: Icons.arrow_forward_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class UiCouponField extends StatefulWidget {
  const UiCouponField({
    super.key,
    this.onApply,
    this.onRemove,
    this.appliedCode,
    this.hint = 'Promo code',
    this.applyLabel = 'Apply',
    this.appliedText = 'Code applied',
    this.emptyError = 'Enter a code',
    this.failedError = 'Could not apply code',
  });

  final Future<String?> Function(String code)? onApply;
  final VoidCallback? onRemove;
  final String? appliedCode;
  final String hint;
  final String applyLabel;
  final String appliedText;
  final String emptyError;
  final String failedError;

  @override
  State<UiCouponField> createState() => _UiCouponFieldState();
}

class _UiCouponFieldState extends State<UiCouponField> {
  final _ctrl = TextEditingController();
  late String? _applied = widget.appliedCode;
  bool _busy = false;
  String? _error;

  @override
  void didUpdateWidget(covariant UiCouponField old) {
    super.didUpdateWidget(old);
    if (old.appliedCode != widget.appliedCode) _applied = widget.appliedCode;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final fn = widget.onApply;
    if (fn == null || _busy) return;
    final code = _ctrl.text.trim().toUpperCase();
    if (code.isEmpty) {
      setState(() => _error = widget.emptyError);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
    });
    String? err;
    try {
      err = await fn(code);
    } catch (_) {
      err = widget.failedError;
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
      if (err == null) {
        _applied = code;
        _ctrl.clear();
      }
    });
  }

  void _remove() {
    setState(() {
      _applied = null;
      _error = null;
    });
    widget.onRemove?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final p = context.palette;
    final applied = _applied;
    return AnimatedSwitcher(
      duration: UiDuration.normal,
      child: applied != null
          ? Semantics(
              key: const ValueKey('applied'),
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.fromLTRB(UiSpace.md, UiSpace.sm, UiSpace.xs, UiSpace.sm),
                decoration: BoxDecoration(color: p.successContainer, borderRadius: context.tokens.md),
                child: Row(
                  children: [
                    Icon(Icons.local_offer_rounded, color: p.onSuccessContainer, size: 20),
                    const UiGap.md(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            applied,
                            style: context.text.titleSmall?.copyWith(color: p.onSuccessContainer, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                          ),
                          Text(widget.appliedText, style: context.text.bodySmall?.copyWith(color: p.onSuccessContainer)),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _remove,
                      tooltip: 'Remove code',
                      icon: Icon(Icons.close_rounded, color: p.onSuccessContainer),
                    ),
                  ],
                ),
              ),
            )
          : TextField(
              key: const ValueKey('input'),
              controller: _ctrl,
              enabled: !_busy && widget.onApply != null,
              autocorrect: false,
              enableSuggestions: false,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.done,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9_-]')),
                LengthLimitingTextInputFormatter(32),
              ],
              onSubmitted: (_) => _apply(),
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                hintText: widget.hint,
                errorText: _error,
                prefixIcon: const Icon(Icons.local_offer_outlined),
                suffixIcon: Padding(
                  padding: const EdgeInsets.only(right: UiSpace.xs),
                  child: _busy
                      ? const Padding(
                          padding: EdgeInsets.all(UiSpace.md),
                          child: SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.2)),
                        )
                      : TextButton(
                          onPressed: widget.onApply == null ? null : _apply,
                          style: TextButton.styleFrom(foregroundColor: cs.primary),
                          child: Text(widget.applyLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
                        ),
                ),
              ),
            ),
    );
  }
}

class UiFreeShippingProgress extends StatelessWidget {
  const UiFreeShippingProgress({
    super.key,
    required this.subtotal,
    required this.threshold,
    this.symbol,
    this.unlockedText = 'You get free shipping',
  });

  final num subtotal;
  final num threshold;
  final String? symbol;
  final String unlockedText;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final ok = context.palette.success;
    final sub = math.max(0.0, UiMoney.safe(subtotal));
    final th = UiMoney.safe(threshold);
    final left = th - sub;
    final done = left <= 0;
    final value = th <= 0 ? 1.0 : (sub / th).clamp(0.0, 1.0).toDouble();
    final style = context.text.bodyMedium;
    final c = done ? ok : cs.primary;
    return Semantics(
      liveRegion: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(done ? Icons.check_circle_rounded : Icons.local_shipping_outlined, size: 20, color: c),
              const UiGap.sm(),
              Expanded(
                child: done
                    ? Text(unlockedText, style: style?.copyWith(color: ok, fontWeight: FontWeight.w700))
                    : Text.rich(
                        TextSpan(
                          children: [
                            const TextSpan(text: 'Add '),
                            TextSpan(text: UiMoney.format(left, symbol: symbol), style: const TextStyle(fontWeight: FontWeight.w800)),
                            const TextSpan(text: ' more for free shipping'),
                          ],
                        ),
                        style: style,
                      ),
              ),
            ],
          ),
          const UiGap.sm(),
          TweenAnimationBuilder<double>(
            tween: Tween(end: value),
            duration: UiDuration.slow,
            curve: UiCurve.standard,
            builder: (_, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 6,
              borderRadius: context.tokens.full,
              color: c,
              backgroundColor: cs.surfaceContainerHighest,
            ),
          ),
        ],
      ),
    );
  }
}

class UiStickyBuyBar extends StatelessWidget {
  const UiStickyBuyBar({
    super.key,
    required this.price,
    this.compareAt,
    this.onAddToCart,
    this.onBuyNow,
    this.addLabel = 'Add to cart',
    this.buyLabel = 'Buy now',
    this.priceLabel,
    this.symbol,
    this.buyLoading = false,
    this.leading,
  });

  final num price;
  final num? compareAt;
  final Future<void> Function()? onAddToCart;
  final VoidCallback? onBuyNow;
  final String addLabel;
  final String buyLabel;
  final String? priceLabel;
  final String? symbol;
  final bool buyLoading;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final showBuy = onBuyNow != null;
    final showAdd = onAddToCart != null || !showBuy;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: context.isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.md, UiSpace.lg, UiSpace.md),
          child: Row(
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: context.screen.width * 0.34),
                child: leading ??
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (priceLabel != null)
                          Text(priceLabel!, style: context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                        UiPrice(price, compareAt: compareAt, symbol: symbol, showDiscount: false),
                      ],
                    ),
              ),
              const UiGap.lg(),
              if (showAdd)
                Expanded(
                  child: UiAddToCartButton(
                    onPressed: onAddToCart,
                    label: addLabel,
                    icon: showBuy ? null : Icons.add_shopping_cart_rounded,
                    variant: showBuy ? UiButtonVariant.tonal : UiButtonVariant.primary,
                  ),
                ),
              if (showAdd && showBuy) const UiGap.sm(),
              if (showBuy) Expanded(child: UiButton(buyLabel, onPressed: onBuyNow, loading: buyLoading, expand: true)),
            ],
          ),
        ),
      ),
    );
  }
}
