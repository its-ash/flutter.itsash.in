import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_money.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';

class UiBudgetBar extends StatelessWidget {
  const UiBudgetBar({
    super.key,
    required this.category,
    required this.spent,
    required this.limit,
    this.icon,
    this.color,
    this.symbol,
    this.warnAt = 0.8,
    this.card = true,
    this.onTap,
  });

  final String category;
  final double spent;
  final double limit;
  final IconData? icon;
  final Color? color;
  final String? symbol;
  final double warnAt;
  final bool card;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final s = spent.isFinite && spent > 0 ? spent : 0.0;
    final l = limit.isFinite && limit > 0 ? limit : 0.0;
    final ratio = l == 0 ? (s > 0 ? double.infinity : 0.0) : s / l;
    final warn = warnAt.isFinite ? warnAt.clamp(0.0, 1.0) : 0.8;
    final status = ratio > 1 ? UiStatus.danger : (ratio >= warn ? UiStatus.warning : null);
    final accent = status == null ? (color ?? cs.primary) : context.tone(status).color;
    final left = l - s;
    String money(double v) => UiMoney.format(v, symbol: symbol, trimZeros: true);
    final remaining = left >= 0 ? '${money(left)} left' : '${money(-left)} over';

    final body = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: context.tokens.sm),
                child: Icon(icon, color: accent, size: 20),
              ),
              const UiGap.md(),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    '${money(s)} of ${money(l)}',
                    style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Text(
              remaining,
              style: context.text.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: status == UiStatus.danger ? cs.error : (status == UiStatus.warning ? accent : cs.onSurface),
              ),
            ),
          ],
        ),
        const UiGap.md(),
        Semantics(
          label: '$category budget',
          value: ratio.isFinite ? '${(ratio * 100).round()}% used' : 'No limit',
          child: ClipRRect(
            borderRadius: context.tokens.full,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: ratio.isFinite ? ratio.clamp(0.0, 1.0) : 1.0),
              duration: UiDuration.slow,
              curve: UiCurve.standard,
              builder: (_, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                color: accent,
                backgroundColor: accent.withValues(alpha: 0.14),
              ),
            ),
          ),
        ),
      ],
    );

    return card ? UiCard(onTap: onTap, child: body) : InkWell(onTap: onTap, child: body);
  }
}
