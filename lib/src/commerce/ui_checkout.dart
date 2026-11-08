import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/navigation/ui_indicators.dart';
import 'package:theme/src/card/ui_card.dart';
import 'package:theme/src/display/ui_tag.dart';

class _SelectDot extends StatelessWidget {
  const _SelectDot(this.on);

  final bool on;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return AnimatedContainer(
      duration: UiDuration.fast,
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: on ? cs.primary : cs.outline, width: 2),
      ),
      child: AnimatedContainer(
        duration: UiDuration.fast,
        curve: UiCurve.standard,
        width: on ? 10 : 0,
        height: on ? 10 : 0,
        decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primary),
      ),
    );
  }
}

class UiAddressCard extends StatelessWidget {
  const UiAddressCard({
    super.key,
    required this.name,
    required this.lines,
    this.label = 'Home',
    this.phone,
    this.selected = false,
    this.onTap,
    this.onEdit,
    this.isDefault = false,
    this.defaultLabel = 'Default',
    this.icon,
  });

  final String name;
  final List<String> lines;
  final String label;
  final String? phone;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final bool isDefault;
  final String defaultLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final ic = icon ??
        switch (label.trim().toLowerCase()) {
          'home' => Icons.home_outlined,
          'work' || 'office' => Icons.work_outline_rounded,
          _ => Icons.location_on_outlined,
        };
    final addr = lines.map((l) => l.trim()).where((l) => l.isNotEmpty).join('\n');
    final muted = context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.35);
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: onTap != null,
      child: UiCard(
        variant: UiCardVariant.outlined,
        selected: selected,
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (onTap != null) ...[
              Padding(padding: const EdgeInsets.only(top: 1), child: _SelectDot(selected)),
              const UiGap.md(),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(ic, size: 18, color: cs.primary),
                      const UiGap.xs(),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ),
                      if (isDefault) ...[const UiGap.sm(), UiTag(defaultLabel, status: UiStatus.info, size: UiSize.sm)],
                    ],
                  ),
                  const UiGap.sm(),
                  Text(name, style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                  if (addr.isNotEmpty) Text(addr, style: muted),
                  if (phone != null && phone!.trim().isNotEmpty) ...[
                    const UiGap.xs(),
                    Row(
                      children: [
                        Icon(Icons.phone_outlined, size: 14, color: cs.onSurfaceVariant),
                        const UiGap.xs(),
                        Flexible(child: Text(phone!, style: muted)),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (onEdit != null)
              IconButton(
                onPressed: onEdit,
                tooltip: 'Edit address',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
          ],
        ),
      ),
    );
  }
}

enum UiPaymentBrand {
  visa('Visa', mark: 'VISA'),
  mastercard('Mastercard'),
  amex('American Express', mark: 'AMEX'),
  paypal('PayPal', mark: 'PayPal'),
  upi('UPI', mark: 'UPI'),
  applePay('Apple Pay', icon: Icons.apple),
  googlePay('Google Pay', mark: 'G Pay'),
  cod('Cash on delivery', icon: Icons.payments_outlined),
  card('Card', icon: Icons.credit_card_rounded);

  const UiPaymentBrand(this.label, {this.mark, this.icon});

  final String label;
  final String? mark;
  final IconData? icon;
}

class UiPaymentBrandMark extends StatelessWidget {
  const UiPaymentBrandMark(this.brand, {super.key});

  final UiPaymentBrand brand;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final Widget child = switch (brand) {
      UiPaymentBrand.mastercard => SizedBox(
          width: 30,
          height: 18,
          child: Stack(
            children: [
              Positioned(left: 0, child: _dot(cs.error.withValues(alpha: 0.9))),
              Positioned(right: 0, child: _dot(context.palette.warning.withValues(alpha: 0.85))),
            ],
          ),
        ),
      _ when brand.icon != null => Icon(brand.icon, size: 20, color: cs.onSurface),
      _ => Text(
          brand.mark ?? brand.label,
          maxLines: 1,
          style: context.text.labelMedium?.copyWith(
            fontWeight: FontWeight.w900,
            fontStyle: brand == UiPaymentBrand.visa ? FontStyle.italic : FontStyle.normal,
            letterSpacing: brand == UiPaymentBrand.paypal ? -0.2 : 0.4,
            color: cs.primary,
          ),
        ),
    };
    return Container(
      width: 52,
      height: 34,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLowest,
        borderRadius: context.tokens.xs,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: FittedBox(fit: BoxFit.scaleDown, child: Padding(padding: const EdgeInsets.all(UiSpace.xs), child: child)),
    );
  }

  Widget _dot(Color c) => Container(width: 18, height: 18, decoration: BoxDecoration(shape: BoxShape.circle, color: c));
}

class UiPaymentMethodTile extends StatelessWidget {
  const UiPaymentMethodTile({
    super.key,
    required this.brand,
    this.title,
    this.number,
    this.subtitle,
    this.selected = false,
    this.onTap,
    this.trailing,
  });

  final UiPaymentBrand brand;
  final String? title;
  final String? number;
  final String? subtitle;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? trailing;

  static String last4(String? n) {
    final d = (n ?? '').replaceAll(RegExp(r'\D'), '');
    return d.substring(math.max(0, d.length - 4));
  }

  static String mask(String? n) {
    final l = last4(n);
    return l.isEmpty ? '' : '•••• $l';
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final l4 = last4(number);
    final sub = [if (l4.isNotEmpty) '•••• $l4', ?subtitle].where((s) => s.trim().isNotEmpty).join(' · ');
    final name = title ?? brand.label;
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: onTap != null,
      label: [name, if (l4.isNotEmpty) 'ending in $l4', ?subtitle].join(', '),
      excludeSemantics: trailing == null,
      button: onTap != null,
      onTap: trailing == null ? onTap : null,
      child: UiCard(
        variant: UiCardVariant.outlined,
        selected: selected,
        onTap: onTap,
        padding: const EdgeInsets.all(UiSpace.md),
        child: Row(
          children: [
            UiPaymentBrandMark(brand),
            const UiGap.md(),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (sub.isNotEmpty)
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.3),
                    ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else if (onTap != null)
              _SelectDot(selected),
          ],
        ),
      ),
    );
  }
}

class UiCheckoutSteps extends StatelessWidget {
  const UiCheckoutSteps({super.key, this.current = 0, this.steps = const ['Cart', 'Address', 'Payment', 'Review'], this.onStepTap});

  final int current;
  final List<String> steps;
  final ValueChanged<int>? onStepTap;

  @override
  Widget build(BuildContext context) => UiStepIndicator(
        steps: steps,
        current: current,
        size: 28,
        onTap: onStepTap == null
            ? null
            : (i) {
                if (i < current) onStepTap!(i);
              },
      );
}

class UiDeliveryEstimate extends StatelessWidget {
  const UiDeliveryEstimate({
    super.key,
    this.date,
    this.until,
    this.text,
    this.freeShipping = false,
    this.note,
    this.location,
    this.onChangeLocation,
    this.prefix = 'Delivery by',
    this.freeLabel = 'Free delivery',
    this.changeLabel = 'Change',
  });

  final DateTime? date;
  final DateTime? until;
  final String? text;
  final bool freeShipping;
  final String? note;
  final String? location;
  final VoidCallback? onChangeLocation;
  final String prefix;
  final String freeLabel;
  final String changeLabel;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final d = date;
    final u = until;
    final main = text ??
        (d == null
            ? null
            : u != null && u.isAfter(d)
                ? '$prefix ${UiFormat.day(d)} – ${UiFormat.day(u)}'
                : '$prefix ${UiFormat.day(d)}');
    final extra = note ?? (freeShipping ? freeLabel : null);
    return Container(
      padding: const EdgeInsets.all(UiSpace.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: context.tokens.md,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(shape: BoxShape.circle, color: cs.primaryContainer),
            child: Icon(Icons.local_shipping_outlined, size: 20, color: cs.onPrimaryContainer),
          ),
          const UiGap.md(),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (location != null)
                  Text(
                    'Deliver to $location',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                if (main != null) Text(main, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                if (extra != null)
                  Text(extra, style: context.text.bodySmall?.copyWith(color: context.palette.success, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          if (onChangeLocation != null)
            TextButton(
              onPressed: onChangeLocation,
              style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
              child: Text(changeLabel),
            ),
        ],
      ),
    );
  }
}

class UiTrustItem {
  const UiTrustItem(this.icon, this.label);

  final IconData icon;
  final String label;
}

class UiTrustBadges extends StatelessWidget {
  const UiTrustBadges({super.key, this.items = defaults});

  static const defaults = [
    UiTrustItem(Icons.lock_outline_rounded, 'Secure payment'),
    UiTrustItem(Icons.autorenew_rounded, 'Easy returns'),
    UiTrustItem(Icons.local_shipping_outlined, 'Fast delivery'),
    UiTrustItem(Icons.verified_outlined, 'Genuine products'),
  ];

  final List<UiTrustItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final it in items)
          Expanded(
            child: Semantics(
              label: it.label,
              excludeSemantics: true,
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: cs.secondaryContainer),
                    child: Icon(it.icon, size: 20, color: cs.onSecondaryContainer),
                  ),
                  const UiGap.xs(),
                  Text(
                    it.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant, height: 1.2),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
