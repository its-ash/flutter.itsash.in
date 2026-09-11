import 'package:flutter/material.dart';

class ThemeRatingInput extends StatelessWidget {
  const ThemeRatingInput({
    super.key,
    required this.rating,
    this.onChanged,
    this.size = 24,
    this.starCount = 5,
    this.allowHalfRating = false,
    this.color = const Color(0xFFFFA726),
  });

  final double rating;
  final ValueChanged<double>? onChanged;
  final double size;
  final int starCount;
  final bool allowHalfRating;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (i) {
        final position = i + 1;
        final icon = rating >= position
            ? Icons.star
            : (allowHalfRating && rating >= position - 0.5)
                ? Icons.star_half
                : Icons.star_border;

        final star = Icon(icon, size: size, color: color);
        if (onChanged == null) return star;

        if (!allowHalfRating) {
          return GestureDetector(
            onTap: () => onChanged!(position.toDouble()),
            child: star,
          );
        }

        return GestureDetector(
          onTapUp: (details) {
            final box = context.findRenderObject();
            final local = details.localPosition;
            final isLeftHalf = box is! RenderBox || local.dx < size / 2;
            onChanged!(isLeftHalf ? position - 0.5 : position.toDouble());
          },
          child: star,
        );
      }),
    );
  }
}
