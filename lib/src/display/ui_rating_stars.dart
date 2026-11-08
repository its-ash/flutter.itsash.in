import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiRatingStars extends StatelessWidget {
  const UiRatingStars(
    this.rating, {
    super.key,
    this.max = 5,
    this.size = 16,
    this.count,
    this.showValue = false,
  });

  final double rating;
  final int max;
  final double size;
  final int? count;
  final bool showValue;

  @override
  Widget build(BuildContext context) {
    final v = rating.isFinite ? rating.clamp(0, max.toDouble()) : 0.0;
    final c = context.palette.rating;
    final muted = context.colors.outlineVariant;
    final style = context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant);
    return Semantics(
      label: 'Rated ${v.toStringAsFixed(1)} of $max',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= max; i++)
            Icon(
              v >= i
                  ? Icons.star_rounded
                  : v >= i - 0.5
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: size,
              color: v >= i - 0.5 ? c : muted,
            ),
          if (showValue) ...[
            const SizedBox(width: UiSpace.xs),
            Text(v.toStringAsFixed(1), style: style?.copyWith(fontWeight: FontWeight.w700, color: context.colors.onSurface)),
          ],
          if (count != null) ...[
            const SizedBox(width: UiSpace.xs),
            Text('($count)', style: style),
          ],
        ],
      ),
    );
  }
}
