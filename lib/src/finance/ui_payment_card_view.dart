import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

enum UiPaymentCardStyle { primary, secondary, tertiary, dark }

class UiPaymentCardView extends StatelessWidget {
  const UiPaymentCardView({
    super.key,
    required this.number,
    this.holder,
    this.expiry,
    this.brand,
    this.style = UiPaymentCardStyle.primary,
    this.gradient,
    this.masked = true,
    this.selected = false,
    this.onTap,
    this.width,
  });

  final String number;
  final String? holder;
  final String? expiry;
  final String? brand;
  final UiPaymentCardStyle style;
  final Gradient? gradient;
  final bool masked;
  final bool selected;
  final VoidCallback? onTap;
  final double? width;

  static const ratio = 1.586;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final digits = number.replaceAll(RegExp(r'\D'), '');
    final last4 = digits.length >= 4 ? digits.substring(digits.length - 4) : digits;
    final shown = digits.isEmpty
        ? '•••• •••• •••• ••••'
        : masked
            ? '•••• •••• •••• ${last4.padLeft(4, '•')}'
            : [for (var i = 0; i < digits.length; i += 4) digits.substring(i, (i + 4).clamp(0, digits.length))].join(' ');

    LinearGradient lg(Color a, Color b) => LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a, b]);
    final (g, fg) = switch (style) {
      UiPaymentCardStyle.primary => (lg(cs.primary, Color.lerp(cs.primary, cs.tertiary, 0.7)!), cs.onPrimary),
      UiPaymentCardStyle.secondary => (lg(cs.secondary, Color.lerp(cs.secondary, cs.primary, 0.6)!), cs.onSecondary),
      UiPaymentCardStyle.tertiary => (lg(cs.tertiary, Color.lerp(cs.tertiary, cs.secondary, 0.6)!), cs.onTertiary),
      UiPaymentCardStyle.dark => (
          lg(Color.lerp(Colors.black, cs.primary, 0.12)!, Color.lerp(Colors.black, cs.primary, 0.4)!),
          Colors.white,
        ),
    };
    final grad = gradient ?? g;
    final fore = gradient == null
        ? fg
        : (ThemeData.estimateBrightnessForColor(gradient!.colors.first) == Brightness.dark ? Colors.white : Colors.black);
    final muted = fore.withValues(alpha: 0.7);
    final cap = context.text.labelSmall?.copyWith(color: muted, letterSpacing: 1.2, fontSize: 9);
    final val = context.text.titleSmall?.copyWith(color: fore, fontWeight: FontWeight.w700, letterSpacing: 0.6);
    final name = brand?.trim() ?? '';

    final card = AspectRatio(
      aspectRatio: ratio,
      child: Container(
        decoration: BoxDecoration(
          gradient: grad,
          borderRadius: context.tokens.lg,
          border: selected ? Border.all(color: cs.primary, width: 2.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: context.isDark ? 0.4 : 0.16),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          borderRadius: context.tokens.lg,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  right: -60,
                  bottom: -80,
                  child: _Circle(size: 220, color: fore.withValues(alpha: 0.08)),
                ),
                Positioned(
                  right: 30,
                  top: -90,
                  child: _Circle(size: 180, color: fore.withValues(alpha: 0.06)),
                ),
                Padding(
                  padding: const EdgeInsets.all(UiSpace.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 30,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              gradient: LinearGradient(
                                colors: [fore.withValues(alpha: 0.55), fore.withValues(alpha: 0.25)],
                              ),
                            ),
                          ),
                          const UiGap.sm(),
                          Icon(Icons.contactless_rounded, color: muted, size: 22),
                          const Spacer(),
                          if (name.isNotEmpty)
                            Flexible(
                              child: Text(
                                name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.titleMedium?.copyWith(
                                  color: fore,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Spacer(),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          shown,
                          style: context.text.titleLarge?.copyWith(
                            color: fore,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('CARD HOLDER', style: cap),
                                Text(
                                  (holder?.trim().isNotEmpty ?? false) ? holder!.trim().toUpperCase() : '—',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: val,
                                ),
                              ],
                            ),
                          ),
                          if (expiry != null)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('EXPIRES', style: cap),
                                Text(expiry!, style: val),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(
      label: '${name.isEmpty ? 'Card' : '$name card'}${last4.isEmpty ? '' : ' ending $last4'}',
      button: onTap != null,
      selected: selected,
      child: ExcludeSemantics(child: width == null ? card : SizedBox(width: width, child: card)),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      );
}
