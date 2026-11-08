import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';

enum UiStreakDay { done, today, missed, upcoming }

class UiWeekStreak extends StatelessWidget {
  const UiWeekStreak({
    super.key,
    required this.days,
    this.streak,
    this.labels = const ['M', 'T', 'W', 'T', 'F', 'S', 'S'],
    this.title = 'This week',
    this.streakLabel = 'day streak',
    this.onTap,
  });

  final List<UiStreakDay> days;
  final int? streak;
  final List<String> labels;
  final String? title;
  final String streakLabel;
  final VoidCallback? onTap;

  List<UiStreakDay> get _week => [
        for (var i = 0; i < 7; i++) i < days.length ? days[i] : UiStreakDay.upcoming,
      ];

  static int computeStreak(List<UiStreakDay> days) {
    var i = days.lastIndexWhere((d) => d != UiStreakDay.upcoming);
    if (i >= 0 && days[i] == UiStreakDay.today) i--;
    var n = 0;
    for (; i >= 0 && days[i] == UiStreakDay.done; i--) {
      n++;
    }
    return n;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final week = _week;
    final count = streak == null || streak! < 0 ? computeStreak(week) : streak!;
    final flame = count > 0 ? context.palette.warning : cs.onSurfaceVariant;

    return UiCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (title != null)
                Expanded(
                  child: Text(
                    title!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                )
              else
                const Spacer(),
              Semantics(
                label: '$count $streakLabel',
                child: ExcludeSemantics(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.local_fire_department_rounded, color: flame, size: 22),
                      const SizedBox(width: UiSpace.xs),
                      Text('$count', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: flame)),
                      const SizedBox(width: UiSpace.xs),
                      Text(streakLabel, style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const UiGap.lg(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                _Day(label: i < labels.length ? labels[i] : '', state: week[i]),
            ],
          ),
        ],
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({required this.label, required this.state});

  final String label;
  final UiStreakDay state;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final (bg, fg, border, icon) = switch (state) {
      UiStreakDay.done => (cs.primary, cs.onPrimary, cs.primary, Icons.check_rounded),
      UiStreakDay.today => (Colors.transparent, cs.primary, cs.primary, null),
      UiStreakDay.missed => (cs.errorContainer.withValues(alpha: 0.5), cs.error, Colors.transparent, Icons.close_rounded),
      UiStreakDay.upcoming => (cs.surfaceContainerHighest, cs.onSurfaceVariant, Colors.transparent, null),
    };
    return Semantics(
      label: '$label ${state.name}',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: context.text.labelSmall?.copyWith(
                color: state == UiStreakDay.today ? cs.primary : cs.onSurfaceVariant,
                fontWeight: state == UiStreakDay.today ? FontWeight.w800 : FontWeight.w600,
              ),
            ),
            const UiGap.xs(),
            AnimatedContainer(
              duration: UiDuration.normal,
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 2),
              ),
              child: icon == null
                  ? (state == UiStreakDay.today
                      ? Center(
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
                          ),
                        )
                      : null)
                  : Icon(icon, size: 18, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}
