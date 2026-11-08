import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/ui_money.dart';
import 'package:theme/src/commerce/ui_price.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';
import 'package:theme/src/card/ui_card.dart';
import 'package:theme/src/image/ui_image.dart';

class UiWishlistButton extends StatefulWidget {
  const UiWishlistButton({super.key, this.isFavorite = false, this.onChanged, this.size = 36, this.filled = true});

  final bool isFavorite;
  final ValueChanged<bool>? onChanged;
  final double size;
  final bool filled;

  @override
  State<UiWishlistButton> createState() => _UiWishlistButtonState();
}

class _UiWishlistButtonState extends State<UiWishlistButton> with SingleTickerProviderStateMixin {
  late bool _on = widget.isFavorite;
  late final _ctrl = AnimationController(vsync: this, duration: UiDuration.slow);
  late final _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween<double>(begin: 1, end: 1.35).chain(CurveTween(curve: Curves.easeOut)), weight: 35),
    TweenSequenceItem(tween: Tween<double>(begin: 1.35, end: 1).chain(CurveTween(curve: Curves.elasticOut)), weight: 65),
  ]).animate(_ctrl);

  @override
  void didUpdateWidget(covariant UiWishlistButton old) {
    super.didUpdateWidget(old);
    if (old.isFavorite != widget.isFavorite) _on = widget.isFavorite;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _on = !_on);
    if (_on) _ctrl.forward(from: 0);
    widget.onChanged?.call(_on);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final label = _on ? 'Remove from wishlist' : 'Add to wishlist';
    final enabled = widget.onChanged != null;
    return Semantics(
      button: true,
      toggled: _on,
      enabled: enabled,
      label: label,
      onTap: enabled ? _toggle : null,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: Material(
          color: widget.filled ? cs.surface.withValues(alpha: 0.92) : Colors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? _toggle : null,
            child: SizedBox.square(
              dimension: widget.size,
              child: Center(
                child: ScaleTransition(
                  scale: _scale,
                  child: AnimatedSwitcher(
                    duration: UiDuration.fast,
                    transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                    child: Icon(
                      _on ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      key: ValueKey(_on),
                      size: widget.size * 0.55,
                      color: _on ? context.palette.sale : cs.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UiCartIconButton extends StatelessWidget {
  const UiCartIconButton({
    super.key,
    this.count = 0,
    this.onPressed,
    this.icon = Icons.shopping_bag_outlined,
    this.variant = UiIconButtonVariant.tonal,
    this.size = UiSize.md,
  });

  final int count;
  final VoidCallback? onPressed;
  final IconData icon;
  final UiIconButtonVariant variant;
  final UiSize size;

  @override
  Widget build(BuildContext context) {
    final n = count < 0 ? 0 : count;
    return UiIconButton(
      icon,
      onPressed: onPressed,
      tooltip: n == 0 ? 'Cart' : 'Cart, $n ${n == 1 ? 'item' : 'items'}',
      variant: variant,
      size: size,
      badge: n == 0 ? null : (n > 99 ? '99+' : '$n'),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton(this.onPressed, this.title, {this.size = 34});

  final VoidCallback onPressed;
  final String title;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Semantics(
      button: true,
      label: 'Add $title to cart',
      onTap: onPressed,
      excludeSemantics: true,
      child: Tooltip(
        message: 'Add to cart',
        child: Material(
          color: cs.primary,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: SizedBox.square(dimension: size, child: Icon(Icons.add_rounded, size: size * 0.6, color: cs.onPrimary)),
          ),
        ),
      ),
    );
  }
}

class _StockPill extends StatelessWidget {
  const _StockPill(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.xs + 2),
      decoration: BoxDecoration(color: cs.inverseSurface, borderRadius: context.tokens.full),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.text.labelMedium?.copyWith(color: cs.onInverseSurface, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _MiniRating extends StatelessWidget {
  const _MiniRating(this.rating, this.count);

  final double rating;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final v = rating.isFinite ? rating.clamp(0.0, 5.0).toDouble() : 0.0;
    final n = count == null || count! < 0 ? null : count!;
    final style = context.text.labelMedium;
    return Semantics(
      label: 'Rated ${v.toStringAsFixed(1)} of 5${n == null ? '' : ', $n reviews'}',
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 15, color: context.palette.rating),
          const UiGap(3),
          Text(v.toStringAsFixed(1), style: style?.copyWith(fontWeight: FontWeight.w700)),
          if (n != null) ...[
            const UiGap(3),
            Text('(${UiFormat.compact(n)})', style: style?.copyWith(color: context.colors.onSurfaceVariant)),
          ],
        ],
      ),
    );
  }
}

class UiProductCard extends StatelessWidget {
  const UiProductCard({
    super.key,
    required this.title,
    required this.price,
    this.imageUrl,
    this.onTap,
    this.subtitle,
    this.compareAt,
    this.rating,
    this.reviewCount,
    this.badge,
    this.isFavorite = false,
    this.onFavoriteChanged,
    this.onAdd,
    this.inStock = true,
    this.outOfStockLabel = 'Out of stock',
    this.aspectRatio = 1,
    this.symbol,
    this.heroTag,
  });

  final String title;
  final num price;
  final String? imageUrl;
  final VoidCallback? onTap;
  final String? subtitle;
  final num? compareAt;
  final double? rating;
  final int? reviewCount;
  final String? badge;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteChanged;
  final VoidCallback? onAdd;
  final bool inStock;
  final String outOfStockLabel;
  final double aspectRatio;
  final String? symbol;
  final Object? heroTag;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final pct = UiMoney.discountPercent(price, compareAt);
    final tag = badge ?? (pct == null ? null : '-$pct%');
    final ar = aspectRatio.isFinite && aspectRatio > 0 ? aspectRatio : 1.0;
    Widget img = UiImage(imageUrl, aspectRatio: ar, radius: context.tokens.md, semanticLabel: title);
    if (heroTag != null) img = Hero(tag: heroTag!, child: img);

    return UiCard(
      onTap: onTap,
      padding: const EdgeInsets.all(UiSpace.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Stack(
            children: [
              AnimatedOpacity(opacity: inStock ? 1 : 0.45, duration: UiDuration.normal, child: img),
              if (!inStock) Positioned.fill(child: Center(child: _StockPill(outOfStockLabel))),
              if (tag != null) Positioned(top: UiSpace.sm, left: UiSpace.sm, child: UiDiscountBadge(tag)),
              if (onFavoriteChanged != null)
                Positioned(
                  top: UiSpace.xs,
                  right: UiSpace.xs,
                  child: UiWishlistButton(isFavorite: isFavorite, onChanged: onFavoriteChanged, size: 34),
                ),
            ],
          ),
          const UiGap.sm(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.3),
                  ),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600, height: 1.25),
                ),
                if (rating != null) ...[const UiGap.xs(), _MiniRating(rating!, reviewCount)],
                const UiGap.sm(),
                Row(
                  children: [
                    Expanded(
                      child: UiPrice(
                        price,
                        compareAt: compareAt,
                        size: UiSize.sm,
                        symbol: symbol,
                        showDiscount: false,
                        color: inStock ? null : cs.onSurfaceVariant,
                      ),
                    ),
                    if (onAdd != null && inStock) ...[const UiGap.xs(), _AddButton(onAdd!, title)],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UiProductTile extends StatelessWidget {
  const UiProductTile({
    super.key,
    required this.title,
    required this.price,
    this.imageUrl,
    this.onTap,
    this.subtitle,
    this.compareAt,
    this.rating,
    this.reviewCount,
    this.badge,
    this.isFavorite = false,
    this.onFavoriteChanged,
    this.onAdd,
    this.inStock = true,
    this.outOfStockLabel = 'Out of stock',
    this.imageSize = 96,
    this.symbol,
    this.trailing,
  });

  final String title;
  final num price;
  final String? imageUrl;
  final VoidCallback? onTap;
  final String? subtitle;
  final num? compareAt;
  final double? rating;
  final int? reviewCount;
  final String? badge;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteChanged;
  final VoidCallback? onAdd;
  final bool inStock;
  final String outOfStockLabel;
  final double imageSize;
  final String? symbol;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final pct = UiMoney.discountPercent(price, compareAt);
    final tag = badge ?? (pct == null ? null : '-$pct%');
    final d = imageSize.isFinite && imageSize > 0 ? imageSize : 96.0;
    return UiCard(
      onTap: onTap,
      padding: const EdgeInsets.all(UiSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Opacity(
                opacity: inStock ? 1 : 0.45,
                child: UiImage(imageUrl, width: d, height: d, radius: context.tokens.md, semanticLabel: title),
              ),
              if (tag != null) Positioned(top: UiSpace.xs, left: UiSpace.xs, child: UiDiscountBadge(tag)),
            ],
          ),
          const UiGap.md(),
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: d),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      if (rating != null) ...[const UiGap.xs(), _MiniRating(rating!, reviewCount)],
                    ],
                  ),
                  const UiGap.sm(),
                  Row(
                    children: [
                      Expanded(
                        child: inStock
                            ? UiPrice(price, compareAt: compareAt, size: UiSize.sm, symbol: symbol)
                            : Text(
                                outOfStockLabel,
                                style: context.text.labelLarge?.copyWith(color: cs.error, fontWeight: FontWeight.w700),
                              ),
                      ),
                      if (onAdd != null && inStock) _AddButton(onAdd!, title, size: 32),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (trailing != null || onFavoriteChanged != null) ...[
            const UiGap.xs(),
            trailing ?? UiWishlistButton(isFavorite: isFavorite, onChanged: onFavoriteChanged, size: 32, filled: false),
          ],
        ],
      ),
    );
  }
}

class UiFeaturedProductCard extends StatelessWidget {
  const UiFeaturedProductCard({
    super.key,
    required this.title,
    required this.price,
    this.imageUrl,
    this.onTap,
    this.subtitle,
    this.compareAt,
    this.badge,
    this.isFavorite = false,
    this.onFavoriteChanged,
    this.onAdd,
    this.width = 280,
    this.aspectRatio = 0.8,
    this.symbol,
  });

  final String title;
  final num price;
  final String? imageUrl;
  final VoidCallback? onTap;
  final String? subtitle;
  final num? compareAt;
  final String? badge;
  final bool isFavorite;
  final ValueChanged<bool>? onFavoriteChanged;
  final VoidCallback? onAdd;
  final double width;
  final double aspectRatio;
  final String? symbol;

  @override
  Widget build(BuildContext context) {
    final pct = UiMoney.discountPercent(price, compareAt);
    final tag = badge ?? (pct == null ? null : '-$pct%');
    final ar = aspectRatio.isFinite && aspectRatio > 0 ? aspectRatio : 0.8;
    const fg = Colors.white;
    final now = UiMoney.format(price < 0 ? 0 : price, symbol: symbol);
    final was = pct == null ? null : UiMoney.format(compareAt, symbol: symbol);

    return SizedBox(
      width: width.isFinite && width > 0 ? width : 280,
      child: AspectRatio(
        aspectRatio: ar,
        child: ClipRRect(
          borderRadius: context.tokens.xl,
          child: Stack(
            fit: StackFit.expand,
            children: [
              UiImage(imageUrl, semanticLabel: title),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.45, 1],
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
              Material(type: MaterialType.transparency, child: InkWell(onTap: onTap)),
              if (tag != null) Positioned(top: UiSpace.md, left: UiSpace.md, child: UiDiscountBadge(tag, size: UiSize.md)),
              if (onFavoriteChanged != null)
                Positioned(
                  top: UiSpace.sm,
                  right: UiSpace.sm,
                  child: UiWishlistButton(isFavorite: isFavorite, onChanged: onFavoriteChanged),
                ),
              Positioned(
                left: UiSpace.lg,
                right: UiSpace.lg,
                bottom: UiSpace.lg,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (subtitle != null)
                            Text(
                              subtitle!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.labelMedium?.copyWith(color: fg.withValues(alpha: 0.8)),
                            ),
                          Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleLarge?.copyWith(color: fg, fontWeight: FontWeight.w800, height: 1.15),
                          ),
                          const UiGap.xs(),
                          Semantics(
                            label: 'Price ${UiMoney.spoken(price < 0 ? 0 : price, symbol: symbol)}'
                                '${was == null ? '' : ', was ${UiMoney.spoken(compareAt, symbol: symbol)}'}',
                            excludeSemantics: true,
                            child: Wrap(
                              spacing: UiSpace.sm,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(now, style: context.text.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w800)),
                                if (was != null)
                                  Text(
                                    was,
                                    style: context.text.labelMedium?.copyWith(
                                      color: fg.withValues(alpha: 0.7),
                                      decoration: TextDecoration.lineThrough,
                                      decorationColor: fg.withValues(alpha: 0.7),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onAdd != null) ...[const UiGap.md(), _AddButton(onAdd!, title, size: 44)],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
