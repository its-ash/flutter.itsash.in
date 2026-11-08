import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiTimelineItem {
  const UiTimelineItem(
    this.title, {
    this.subtitle,
    this.time,
    this.done = false,
    this.current = false,
    this.icon,
    this.status,
    this.content,
  });

  final String title;
  final String? subtitle;
  final String? time;
  final bool done;
  final bool current;
  final IconData? icon;
  final UiStatus? status;
  final Widget? content;
}

class UiTimeline extends StatelessWidget {
  const UiTimeline(this.items, {super.key, this.dense = false});

  final List<UiTimelineItem> items;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final dot = dense ? 20.0 : 28.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, it) in items.indexed)
          Builder(
            builder: (c) {
              final last = i == items.length - 1;
              final accent = it.status == null ? cs.primary : c.tone(it.status!).color;
              final onAccent = it.status == null ? cs.onPrimary : c.tone(it.status!).onColor;
              final active = it.done || it.current;
              final lineColor = it.done ? accent : cs.outlineVariant;
              final marker = Container(
                width: dot,
                height: dot,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: it.done ? accent : (it.current ? accent.withValues(alpha: 0.15) : cs.surface),
                  border: Border.all(color: active ? accent : cs.outlineVariant, width: 2),
                ),
                child: it.done || it.icon != null
                    ? Icon(it.icon ?? Icons.check_rounded, size: dot * 0.55, color: it.done ? onAccent : (it.current ? accent : cs.onSurfaceVariant))
                    : it.current
                        ? Center(child: Container(width: dot * 0.35, height: dot * 0.35, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)))
                        : null,
              );
              return Semantics(
                container: true,
                child: Semantics(
                  label: it.done ? 'Completed' : (it.current ? 'Current' : 'Pending'),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          width: dot,
                          child: Column(
                            children: [
                              marker,
                              if (!last)
                                Expanded(
                                  child: Container(
                                    width: 2,
                                    margin: const EdgeInsets.symmetric(vertical: UiSpace.xs),
                                    decoration: BoxDecoration(color: lineColor, borderRadius: c.tokens.full),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const UiGap.md(),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(top: dense ? 0 : 3, bottom: last ? 0 : (dense ? UiSpace.md : UiSpace.xl)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        it.title,
                                        style: (dense ? c.text.bodyMedium : c.text.titleSmall)?.copyWith(
                                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                          color: active ? cs.onSurface : cs.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                    if (it.time != null) ...[
                                      const UiGap.sm(),
                                      Text(it.time!, style: c.text.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                                    ],
                                  ],
                                ),
                                if (it.subtitle != null) ...[
                                  const SizedBox(height: UiSpace.xxs),
                                  Text(it.subtitle!, style: c.text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                                ],
                                if (it.content != null) ...[const UiGap.sm(), it.content!],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
