import 'package:flutter/material.dart';

import 'package:theme/src/typography/app_typography.dart';
import 'package:theme/src/widgets/theme_status_pill.dart';

class ThemeTimelineEntry {
  const ThemeTimelineEntry({
    required this.title,
    this.description,
    this.timestamp,
    this.dotColor,
    this.status,
  });

  final String title;
  final String? description;
  final String? timestamp;
  final Color? dotColor;
  final ThemeStatus? status;
}

class ThemeTimeline extends StatelessWidget {
  const ThemeTimeline({super.key, required this.entries});

  final List<ThemeTimelineEntry> entries;

  Color _dotColor(BuildContext context, ThemeTimelineEntry entry) {
    if (entry.dotColor != null) return entry.dotColor!;
    final scheme = Theme.of(context).colorScheme;
    return switch (entry.status) {
      ThemeStatus.success => Colors.green.shade600,
      ThemeStatus.error => scheme.error,
      ThemeStatus.warning => Colors.orange.shade700,
      ThemeStatus.info => scheme.primary,
      ThemeStatus.neutral || null => scheme.onSurface.withValues(alpha: 0.4),
    };
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < entries.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: BoxDecoration(
                        color: _dotColor(context, entries[i]),
                        shape: BoxShape.circle,
                      ),
                    ),
                    if (i < entries.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          margin: const EdgeInsets.symmetric(vertical: 2),
                          color: scheme.outlineVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(entries[i].title, style: AppTypography.titleMedium),
                            ),
                            if (entries[i].timestamp != null)
                              Text(
                                entries[i].timestamp!,
                                style: AppTypography.labelLarge.copyWith(
                                  color: scheme.onSurface.withValues(alpha: 0.5),
                                ),
                              ),
                          ],
                        ),
                        if (entries[i].description != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            entries[i].description!,
                            style: AppTypography.bodyMedium.copyWith(
                              color: scheme.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
