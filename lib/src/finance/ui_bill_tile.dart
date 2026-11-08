import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/ui_money.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';
import 'package:theme/src/card/ui_card.dart';
import 'package:theme/src/display/ui_tag.dart';

class UiBillTile extends StatelessWidget {
  const UiBillTile({
    super.key,
    required this.title,
    required this.amount,
    required this.due,
    this.icon = Icons.receipt_rounded,
    this.color,
    this.paid = false,
    this.symbol,
    this.payLabel = 'Pay',
    this.onPay,
    this.onTap,
    this.now,
  });

  final String title;
  final double amount;
  final DateTime due;
  final IconData icon;
  final Color? color;
  final bool paid;
  final String? symbol;
  final String payLabel;
  final VoidCallback? onPay;
  final VoidCallback? onTap;
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final accent = color ?? cs.primary;
    final days = UiFormat.daysUntil(due, now: now);
    final (text, status) = paid
        ? ('Paid', UiStatus.success)
        : switch (days) {
            < 0 => ('Overdue', UiStatus.danger),
            0 => ('Due today', UiStatus.warning),
            1 => ('Due tomorrow', UiStatus.warning),
            <= 3 => ('Due in $days days', UiStatus.warning),
            _ => ('Due ${UiFormat.relativeDay(due, now: now)}', UiStatus.neutral),
          };

    return UiCard(
      onTap: onTap,
      padding: const EdgeInsets.all(UiSpace.md),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), borderRadius: context.tokens.md),
            child: Icon(icon, color: accent),
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
                const UiGap.xs(),
                Row(
                  children: [
                    Text(
                      UiMoney.format(amount.abs(), symbol: symbol),
                      style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const UiGap.sm(),
                    Flexible(child: UiTag(text, status: status, size: UiSize.sm)),
                  ],
                ),
              ],
            ),
          ),
          if (!paid && onPay != null) ...[
            const UiGap.sm(),
            UiButton(payLabel, size: UiSize.sm, onPressed: onPay),
          ],
        ],
      ),
    );
  }
}
