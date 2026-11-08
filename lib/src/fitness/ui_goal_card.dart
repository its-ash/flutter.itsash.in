import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';

class UiGoalCard extends StatelessWidget {
  const UiGoalCard({
    super.key,
    required this.title,
    required this.current,
    required this.target,
    this.unit = '',
    this.icon = Icons.flag_rounded,
    this.subtitle,
    this.color,
    this.decimals = 0,
    this.onTap,
  });

  final String title;
  final double current;
  final double target;
  final String unit;
  final IconData icon;
  final String? subtitle;
  final Color? color;
  final int decimals;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final cur = current.isFinite && current > 0 ? current : 0.0;
    final tgt = target.isFinite && target > 0 ? target : 0.0;
    final ratio = tgt == 0 ? 0.0 : cur / tgt;
    final done = tgt > 0 && ratio >= 1;
    final accent = done ? context.palette.success : (color ?? cs.primary);
    final pct = (ratio * 100).round();
    final u = unit.isEmpty ? '' : ' $unit';

    return UiCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(done ? Icons.emoji_events_rounded : icon, color: accent, size: 22),
              ),
              const UiGap.md(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                      ),
                  ],
                ),
              ),
              Text('$pct%', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: accent)),
            ],
          ),
          const UiGap.lg(),
          Semantics(
            label: '$title progress',
            value: '$pct%',
            child: ClipRRect(
              borderRadius: context.tokens.full,
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: ratio.clamp(0.0, 1.0)),
                duration: UiDuration.slow,
                curve: UiCurve.standard,
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 10,
                  color: accent,
                  backgroundColor: accent.withValues(alpha: 0.14),
                ),
              ),
            ),
          ),
          const UiGap.sm(),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: UiFormat.number(cur, decimals: decimals),
                  style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: ' / ${UiFormat.number(tgt, decimals: decimals)}$u',
                  style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
