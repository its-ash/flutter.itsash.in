import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// One event of a [UiTimeline].
class UiTimelineItem {
  const UiTimelineItem(
    this.title, {
    this.time,
    this.description,
    this.icon,
    this.status = UiStatus.neutral,
    this.content,
  });

  final String title;

  /// Short time text on the right, e.g. "2h" or "09:41".
  final String? time;
  final String? description;

  /// Icon in a tinted circle instead of a dot.
  final IconData? icon;

  /// Color of the dot or icon.
  final UiStatus status;

  /// Extra content under the description (card, buttons, images).
  final Widget? content;
}

/// A vertical list of events joined by a line.
///
/// ```dart
/// UiTimeline(items: [UiTimelineItem('Order placed', time: '09:41', status: UiStatus.success)])
/// ```
class UiTimeline extends StatelessWidget {
  const UiTimeline({super.key, required this.items});

  final List<UiTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [for (var i = 0; i < items.length; i++) _TimelineRow(item: items[i], last: i == items.length - 1)],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.item, required this.last});

  final UiTimelineItem item;
  final bool last;

  static const double _rail = 24;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final tone = colors.tone(item.status);
    final neutral = item.status == UiStatus.neutral;
    final hasIcon = item.icon != null;

    final Widget marker = hasIcon
        ? Container(
            width: _rail,
            height: _rail,
            decoration: BoxDecoration(
              color: neutral ? colors.surfaceMuted : tone.soft,
              shape: BoxShape.circle,
              border: Border.all(color: neutral ? colors.border : tone.soft),
            ),
            child: Icon(item.icon, size: 13, color: neutral ? colors.textMuted : tone.onSoft),
          )
        : SizedBox(
            width: _rail,
            height: 20,
            child: Center(
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: neutral ? colors.borderStrong : tone.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: neutral ? colors.surfaceMuted : tone.soft,
                    width: 3,
                    strokeAlign: BorderSide.strokeAlignOutside,
                  ),
                ),
              ),
            ),
          );

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: _rail,
            child: Column(
              children: [
                marker,
                if (!last)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
                      child: Container(width: 2, color: colors.border),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: UiSpace.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: hasIcon ? 2 : 0, bottom: last ? 0 : UiSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.titleSmall?.copyWith(height: 1.4),
                        ),
                      ),
                      if (item.time != null) ...[
                        const SizedBox(width: UiSpace.sm),
                        Text(
                          item.time!,
                          maxLines: 1,
                          style: text.bodySmall?.copyWith(color: colors.textSubtle, height: 1.6),
                        ),
                      ],
                    ],
                  ),
                  if (item.description != null)
                    Padding(
                      padding: const EdgeInsets.only(top: UiSpace.xxs),
                      child: Text(item.description!, style: text.bodySmall?.copyWith(color: colors.textMuted)),
                    ),
                  if (item.content != null)
                    Padding(
                      padding: const EdgeInsets.only(top: UiSpace.sm),
                      child: item.content,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
