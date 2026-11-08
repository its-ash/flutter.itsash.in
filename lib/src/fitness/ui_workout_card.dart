import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';
import 'package:theme/src/image/ui_image.dart';
import 'package:theme/src/display/ui_tag.dart';

enum UiWorkoutLevel {
  beginner('Beginner', UiStatus.success),
  intermediate('Intermediate', UiStatus.warning),
  advanced('Advanced', UiStatus.danger);

  const UiWorkoutLevel(this.label, this.status);

  final String label;
  final UiStatus status;
}

class UiWorkoutCard extends StatelessWidget {
  const UiWorkoutCard({
    super.key,
    required this.title,
    this.image,
    this.subtitle,
    this.duration,
    this.kcal,
    this.level,
    this.onTap,
    this.bookmarked = false,
    this.onBookmark,
    this.height = 200,
    this.width,
  });

  final String title;
  final String? image;
  final String? subtitle;
  final Duration? duration;
  final int? kcal;
  final UiWorkoutLevel? level;
  final VoidCallback? onTap;
  final bool bookmarked;
  final ValueChanged<bool>? onBookmark;
  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    const fg = Colors.white;
    final meta = context.text.labelMedium?.copyWith(color: fg.withValues(alpha: 0.92), fontWeight: FontWeight.w600);
    final d = duration;
    final k = kcal;

    Widget info(IconData icon, String text) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: UiSpace.xs),
            Text(text, style: meta),
          ],
        );

    return Semantics(
      button: onTap != null,
      label: title,
      child: UiCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        height: height < 120 ? 120 : height,
        width: width,
        child: Stack(
          fit: StackFit.expand,
          children: [
            UiImage(image, placeholderIcon: Icons.fitness_center_rounded),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.2, 1],
                  colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.78)],
                ),
              ),
            ),
            Padding(
              padding: UiSpace.card,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (level != null) UiTag(level!.label, status: level!.status, solid: true, size: UiSize.sm),
                      const Spacer(),
                      if (onBookmark != null)
                        Material(
                          color: Colors.black.withValues(alpha: 0.32),
                          shape: const CircleBorder(),
                          child: IconButton(
                            tooltip: bookmarked ? 'Remove bookmark' : 'Bookmark',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => onBookmark!(!bookmarked),
                            icon: Icon(bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, color: fg),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleLarge?.copyWith(color: fg, fontWeight: FontWeight.w800),
                  ),
                  if (subtitle != null) ...[
                    const UiGap.xs(),
                    Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: meta),
                  ],
                  if (d != null || k != null) ...[
                    const UiGap.sm(),
                    Wrap(
                      spacing: UiSpace.lg,
                      runSpacing: UiSpace.xs,
                      children: [
                        if (d != null) info(Icons.schedule_rounded, UiFormat.minutes(d)),
                        if (k != null) info(Icons.local_fire_department_rounded, '${UiFormat.number(k < 0 ? 0 : k)} kcal'),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
