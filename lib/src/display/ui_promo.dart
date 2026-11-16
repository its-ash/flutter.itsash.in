import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Hero card for a feature, tip or offer: a soft tinted panel with a title,
/// a short message, a text link and an optional picture on the end side
/// (the Nova "Step Into Style" card).
///
/// ```dart
/// UiPromoCard(
///   title: 'Step into style',
///   message: 'New colors for every widget.',
///   actionLabel: 'Show more',
///   onAction: open,
///   image: Image.asset('assets/shoe.png'),
/// )
/// ```
class UiPromoCard extends StatelessWidget {
  const UiPromoCard({
    super.key,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
    this.image,
    this.status = UiStatus.accent,
    this.onTap,
  });

  /// Up to three lines, headline style.
  final String title;

  /// Up to three lines, muted.
  final String? message;

  /// Text link under the message, with a trailing arrow.
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Picture on the end side (an image, an icon, an illustration). Gets 40%
  /// of the width and is not clipped, so it may overflow the card a little.
  final Widget? image;

  /// Tint of the panel: the soft color of this status.
  final UiStatus status;

  /// Makes the whole card tappable.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = c.tone(status);
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, maxLines: 3, overflow: TextOverflow.ellipsis, style: context.text.headlineSmall),
        if (message != null) ...[
          const SizedBox(height: UiSpace.sm),
          Text(
            message!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodySmall?.copyWith(color: c.textMuted),
          ),
        ],
        if (actionLabel != null) ...[
          const SizedBox(height: UiSpace.md),
          _LinkAction(label: actionLabel!, color: status == UiStatus.neutral ? c.accent : tone.color, onTap: onAction),
        ],
      ],
    );
    final body = Container(
      constraints: const BoxConstraints(minHeight: 160),
      padding: const EdgeInsets.all(UiSpace.xl),
      child: Row(
        children: [
          Expanded(flex: 6, child: text),
          if (image != null) ...[const SizedBox(width: UiSpace.md), Expanded(flex: 4, child: Center(child: image))],
        ],
      ),
    );
    final radius = UiRadius.all(UiRadius.lg);
    final card = Material(
      color: Color.alphaBlend(tone.soft, c.background),
      borderRadius: radius,
      child: onTap == null ? body : InkWell(onTap: onTap, borderRadius: radius, child: body),
    );
    return Semantics(container: true, button: onTap != null, child: card);
  }
}

class _LinkAction extends StatelessWidget {
  const _LinkAction({required this.label, required this.color, this.onTap});

  final String label;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = onTap == null ? c.textDisabled : color;
    return Semantics(
      button: true,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: UiRadius.all(UiRadius.xs),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelLarge?.copyWith(color: fg),
                ),
              ),
              const SizedBox(width: UiSpace.xs),
              Icon(Icons.arrow_forward_rounded, size: 18, color: fg),
            ],
          ),
        ),
      ),
    );
  }
}

/// Dark strip that announces something short and tappable: free shipping, a
/// new feature, a running task (the Nova "Free Shipping" bar). Uses the
/// inverse surface, so it stands out in light and dark mode. Often floated
/// over the bottom of a list.
///
/// ```dart
/// UiPromoBanner(
///   title: 'Free shipping',
///   subtitle: 'On orders over \$50',
///   icon: Icons.local_shipping_rounded,
///   onTap: open,
/// )
/// ```
class UiPromoBanner extends StatelessWidget {
  const UiPromoBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.onTap,
    this.actionIcon = Icons.keyboard_double_arrow_right_rounded,
  });

  final String title;
  final String? subtitle;

  /// Icon in the leading tile (Primary on a dim tile).
  final IconData? icon;

  /// Custom leading tile content; replaces [icon].
  final Widget? leading;

  /// Tap target for the whole banner. Shows the round [actionIcon] button.
  final VoidCallback? onTap;

  /// Icon of the round button on the end side.
  final IconData actionIcon;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final fg = c.onSurfaceInverse;
    final dim = fg.withValues(alpha: 0.1);
    final hasLeading = leading != null || icon != null;
    final radius = UiRadius.all(UiRadius.lg);
    final body = Container(
      constraints: const BoxConstraints(minHeight: 72),
      padding: EdgeInsetsDirectional.only(
        start: hasLeading ? UiSpace.sm : UiSpace.xl,
        end: UiSpace.md,
        top: UiSpace.sm,
        bottom: UiSpace.sm,
      ),
      child: Row(
        children: [
          if (hasLeading) ...[
            Container(
              width: 64,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: dim, borderRadius: UiRadius.all(UiRadius.md)),
              child: leading ?? Icon(icon, size: 28, color: c.accent),
            ),
            const SizedBox(width: UiSpace.lg),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(color: fg),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(color: fg.withValues(alpha: 0.72)),
                  ),
              ],
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: UiSpace.md),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: dim, shape: BoxShape.circle),
              child: Icon(actionIcon, size: 22, color: fg),
            ),
          ],
        ],
      ),
    );
    final banner = DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: context.shadowMd),
      child: Material(
        color: c.surfaceInverse,
        borderRadius: radius,
        child: onTap == null
            ? body
            : InkWell(onTap: onTap, borderRadius: radius, splashColor: dim, highlightColor: dim, child: body),
      ),
    );
    return Semantics(container: true, button: onTap != null, label: title, child: banner);
  }
}
