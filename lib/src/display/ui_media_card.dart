import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Picture tile with a caption below: a softly tinted, rounded image box with
/// an optional corner [badge], then a [title] and a [subtitle] (the Nova
/// product grid item). Use it for galleries, catalogs, exercises, presets.
///
/// ```dart
/// UiMediaCard(
///   image: Image.asset('assets/hoodie.png'),
///   title: 'Hoodie',
///   subtitle: '\$80',
///   tint: context.colors.chart[4],
///   badge: '23%',
///   onTap: open,
/// )
/// ```
class UiMediaCard extends StatelessWidget {
  const UiMediaCard({
    super.key,
    required this.title,
    this.image,
    this.subtitle,
    this.tint,
    this.badge,
    this.aspectRatio = 0.85,
    this.onTap,
    this.trailing,
  });

  /// Shown in the box, centered. Fill it yourself (e.g. `fit: BoxFit.cover`)
  /// for an edge-to-edge photo.
  final Widget? image;

  final String title;

  /// Second line, emphasized (a price, a count, a duration).
  final String? subtitle;

  /// Base color of the box. It is used at 12% over the page, so any color
  /// (even a saturated one) gives a soft pastel. Null uses the Overlay fill.
  final Color? tint;

  /// Short text in a yellow pill on the top start corner ("23%", "New").
  final String? badge;

  /// Width / height of the image box.
  final double aspectRatio;

  final VoidCallback? onTap;

  /// Widget on the end side of the caption, such as a favorite button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = UiRadius.all(UiRadius.lg);
    final fill = tint == null ? c.surfaceMuted : tint!.withValues(alpha: c.isDark ? 0.2 : 0.12);
    final box = AspectRatio(
      aspectRatio: aspectRatio,
      child: Material(
        color: Color.alphaBlend(fill, c.background),
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (image != null)
                Padding(
                  padding: const EdgeInsets.all(UiSpace.md),
                  child: Center(child: image),
                ),
              if (badge != null)
                PositionedDirectional(
                  top: UiSpace.md,
                  start: UiSpace.md,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: 3),
                    decoration: BoxDecoration(color: c.warning, borderRadius: UiRadius.all(UiRadius.full)),
                    child: Text(badge!, maxLines: 1, style: context.text.labelMedium?.copyWith(color: c.onWarning)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    final caption = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodyLarge),
              if (subtitle != null)
                Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleMedium),
            ],
          ),
        ),
        ?trailing,
      ],
    );
    return Semantics(
      container: true,
      button: onTap != null,
      label: subtitle == null ? title : '$title, $subtitle',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          box,
          const SizedBox(height: UiSpace.md),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
            child: caption,
          ),
        ],
      ),
    );
  }
}
