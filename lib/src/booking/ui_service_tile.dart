import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';
import 'package:theme/src/card/ui_card.dart';
import 'package:theme/src/image/ui_image.dart';
import 'package:theme/src/display/ui_rating_stars.dart';

class UiServiceTile extends StatelessWidget {
  const UiServiceTile({
    super.key,
    required this.name,
    this.image,
    this.subtitle,
    this.duration,
    this.price,
    this.rating,
    this.reviews,
    this.onBook,
    this.onTap,
    this.bookLabel = 'Book',
    this.selected = false,
  });

  final String name;
  final String? image;
  final String? subtitle;
  final Duration? duration;
  final String? price;
  final double? rating;
  final int? reviews;
  final VoidCallback? onBook;
  final VoidCallback? onTap;
  final String bookLabel;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final d = duration;
    final r = rating;
    final meta = context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600);

    return UiCard(
      onTap: onTap,
      selected: selected,
      padding: const EdgeInsets.all(UiSpace.md),
      child: Row(
        children: [
          UiImage(image, width: 84, height: 84, radius: context.tokens.md, placeholderIcon: Icons.spa_rounded),
          const UiGap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                const UiGap.xs(),
                Wrap(
                  spacing: UiSpace.md,
                  runSpacing: UiSpace.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (d != null)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule_rounded, size: 14, color: cs.onSurfaceVariant),
                          const SizedBox(width: UiSpace.xs),
                          Text(UiFormat.minutes(d), style: meta),
                        ],
                      ),
                    if (r != null && r.isFinite) UiRatingStars(r, size: 14, showValue: true, count: reviews, max: 5),
                  ],
                ),
                if (price != null || onBook != null) ...[
                  const UiGap.sm(),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          price ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: cs.primary),
                        ),
                      ),
                      if (onBook != null) UiButton(bookLabel, size: UiSize.sm, onPressed: onBook),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
