import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/finance/ui_amount.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';
import 'package:theme/src/image/ui_image.dart';
import 'package:theme/src/display/ui_tag.dart';

enum UiTransactionStatus {
  completed('Completed', UiStatus.success),
  pending('Pending', UiStatus.warning),
  failed('Failed', UiStatus.danger);

  const UiTransactionStatus(this.label, this.status);

  final String label;
  final UiStatus status;
}

class UiTransactionTile extends StatelessWidget {
  const UiTransactionTile({
    super.key,
    required this.title,
    required this.amount,
    this.subtitle,
    this.date,
    this.icon = Icons.receipt_long_rounded,
    this.imageUrl,
    this.color,
    this.status = UiTransactionStatus.completed,
    this.symbol,
    this.onTap,
  });

  final String title;
  final double amount;
  final String? subtitle;
  final DateTime? date;
  final IconData icon;
  final String? imageUrl;
  final Color? color;
  final UiTransactionStatus status;
  final String? symbol;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final accent = color ?? cs.primary;
    final sub = subtitle ?? (date == null ? null : UiFormat.dateTime(date!, weekday: true));
    final img = imageUrl?.trim() ?? '';

    return InkWell(
      onTap: onTap,
      borderRadius: context.tokens.md,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: UiSpace.sm, horizontal: UiSpace.xs),
        child: Row(
          children: [
            img.isNotEmpty
                ? UiImage(img, width: 44, height: 44, radius: context.tokens.full, placeholderIcon: icon)
                : Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), shape: BoxShape.circle),
                    child: Icon(icon, color: accent, size: 22),
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
                    style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  if (sub != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      sub,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ],
              ),
            ),
            const UiGap.sm(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                UiAmount(
                  amount,
                  symbol: symbol,
                  strike: status == UiTransactionStatus.failed,
                  colored: status != UiTransactionStatus.failed,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: status == UiTransactionStatus.failed ? cs.onSurfaceVariant : cs.onSurface,
                  ),
                ),
                if (status != UiTransactionStatus.completed) ...[
                  const UiGap.xs(),
                  UiTag(status.label, status: status.status, size: UiSize.sm),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class UiTransactionGroup extends StatelessWidget {
  const UiTransactionGroup({
    super.key,
    required this.children,
    this.title,
    this.date,
    this.trailing,
    this.card = true,
  });

  final List<Widget> children;
  final String? title;
  final DateTime? date;
  final String? trailing;
  final bool card;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final head = title ?? (date == null ? null : UiFormat.relativeDay(date!));
    final list = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0 && card) Divider(height: 1, indent: 60, color: cs.outlineVariant.withValues(alpha: 0.5)),
          children[i],
        ],
      ],
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (head != null || trailing != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(UiSpace.xs, UiSpace.sm, UiSpace.xs, UiSpace.sm),
            child: Row(
              children: [
                Expanded(
                  child: Semantics(
                    header: true,
                    child: Text(
                      head ?? '',
                      style: context.text.labelLarge?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                if (trailing != null)
                  Text(trailing!, style: context.text.labelLarge?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        card ? UiCard(padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: UiSpace.xs), child: list) : list,
      ],
    );
  }
}
