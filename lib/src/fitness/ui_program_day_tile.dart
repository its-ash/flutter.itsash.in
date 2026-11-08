import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';

enum UiProgramDayState { completed, current, upcoming, locked }

class UiProgramDayTile extends StatelessWidget {
  const UiProgramDayTile({
    super.key,
    required this.day,
    required this.title,
    this.subtitle,
    this.state = UiProgramDayState.upcoming,
    this.onTap,
    this.dayLabel = 'Day',
  });

  final int day;
  final String title;
  final String? subtitle;
  final UiProgramDayState state;
  final VoidCallback? onTap;
  final String dayLabel;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final ok = context.palette;
    final locked = state == UiProgramDayState.locked;
    final n = day < 0 ? 0 : day;
    final (bg, fg, border) = switch (state) {
      UiProgramDayState.completed => (ok.success, ok.onSuccess, ok.success),
      UiProgramDayState.current => (cs.primary, cs.onPrimary, cs.primary),
      UiProgramDayState.upcoming => (Colors.transparent, cs.onSurface, cs.outlineVariant),
      UiProgramDayState.locked => (cs.surfaceContainerHighest, cs.onSurfaceVariant, Colors.transparent),
    };
    final trailing = switch (state) {
      UiProgramDayState.completed => Icon(Icons.check_circle_rounded, color: ok.success),
      UiProgramDayState.current => Icon(Icons.play_circle_fill_rounded, color: cs.primary, size: 30),
      UiProgramDayState.upcoming => Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
      UiProgramDayState.locked => Icon(Icons.lock_rounded, color: cs.onSurfaceVariant, size: 18),
    };

    return Semantics(
      label: '$dayLabel $n, $title, ${state.name}',
      button: !locked && onTap != null,
      enabled: !locked,
      child: Opacity(
        opacity: locked ? 0.6 : 1,
        child: UiCard(
          onTap: locked ? null : onTap,
          selected: state == UiProgramDayState.current,
          padding: const EdgeInsets.all(UiSpace.md),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: context.tokens.md,
                  border: Border.all(color: border, width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dayLabel.toUpperCase(),
                      style: context.text.labelSmall?.copyWith(color: fg.withValues(alpha: 0.8), fontSize: 9, letterSpacing: 0.8),
                    ),
                    Text('$n', style: context.text.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w800, height: 1.1)),
                  ],
                ),
              ),
              const UiGap.md(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ],
                ),
              ),
              const UiGap.sm(),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}
