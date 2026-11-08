import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';

class UiWaterTracker extends StatelessWidget {
  const UiWaterTracker({
    super.key,
    required this.count,
    this.target = 8,
    this.onChanged,
    this.title = 'Water',
    this.perCup = 250,
    this.unit = 'ml',
    this.color,
  });

  static const maxCups = 24;

  final int count;
  final int target;
  final ValueChanged<int>? onChanged;
  final String title;
  final int perCup;
  final String unit;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final accent = color ?? context.palette.info;
    final tgt = target.clamp(1, maxCups);
    final n = count.clamp(0, maxCups);
    final cups = n >= tgt ? (n + 1).clamp(1, maxCups) : tgt;
    final cup = perCup < 0 ? 0 : perCup;

    void tap(int i) {
      final next = i + 1 == n ? i : i + 1;
      HapticFeedback.selectionClick();
      onChanged?.call(next.clamp(0, maxCups));
    }

    return UiCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop_rounded, color: accent),
              const UiGap.sm(),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: UiFormat.number(n * cup),
                      style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: accent),
                    ),
                    TextSpan(
                      text: ' / ${UiFormat.number(tgt * cup)} $unit',
                      style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const UiGap.md(),
          Wrap(
            spacing: UiSpace.sm,
            runSpacing: UiSpace.sm,
            children: [
              for (var i = 0; i < cups; i++)
                Semantics(
                  button: onChanged != null,
                  checked: i < n,
                  label: 'Cup ${i + 1}',
                  child: InkWell(
                    onTap: onChanged == null ? null : () => tap(i),
                    borderRadius: context.tokens.sm,
                    child: AnimatedContainer(
                      duration: UiDuration.normal,
                      curve: UiCurve.standard,
                      width: 36,
                      height: 44,
                      decoration: BoxDecoration(
                        color: i < n ? accent.withValues(alpha: 0.16) : cs.surfaceContainerHighest.withValues(alpha: 0.6),
                        borderRadius: context.tokens.sm,
                      ),
                      child: Icon(
                        i < n ? Icons.local_drink_rounded : Icons.local_drink_outlined,
                        color: i < n ? accent : cs.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 22,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const UiGap.sm(),
          Text(
            n >= tgt ? 'Goal reached' : '${tgt - n} more to go',
            style: context.text.bodySmall?.copyWith(
              color: n >= tgt ? context.palette.success : cs.onSurfaceVariant,
              fontWeight: n >= tgt ? FontWeight.w700 : null,
            ),
          ),
        ],
      ),
    );
  }
}
