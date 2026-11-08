import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_avatar.dart';
import 'package:theme/src/display/ui_rating_stars.dart';
import 'package:theme/src/display/ui_tag.dart';

class UiInfoTile extends StatelessWidget {
  const UiInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.status,
    this.onTap,
    this.horizontal = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final UiStatus? status;
  final VoidCallback? onTap;
  final bool horizontal;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final t = status == null ? null : context.tone(status!);
    final bg = t?.container.withValues(alpha: 0.6) ?? cs.surfaceContainerHigh;
    final accent = t?.onContainer ?? cs.primary;
    final badge = Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(color: accent.withValues(alpha: 0.14), shape: BoxShape.circle),
      child: Icon(icon, size: 18, color: accent),
    );
    final texts = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
        Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
    final body = Padding(
      padding: const EdgeInsets.all(UiSpace.md),
      child: horizontal
          ? Row(children: [badge, const UiGap.md(), Expanded(child: texts)])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [badge, const UiGap.sm(), texts]),
    );
    return MergeSemantics(
      child: Material(
        color: bg,
        borderRadius: context.tokens.md,
        clipBehavior: Clip.antiAlias,
        child: onTap == null ? body : InkWell(onTap: onTap, child: body),
      ),
    );
  }
}

class UiFeatureList extends StatelessWidget {
  const UiFeatureList(
    this.items, {
    super.key,
    this.excluded = const [],
    this.icon = Icons.check_circle_rounded,
    this.color,
    this.dense = false,
  });

  final List<String> items;
  final List<String> excluded;
  final IconData icon;
  final Color? color;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final ok = color ?? context.palette.success;
    final gap = dense ? UiSpace.xs : UiSpace.sm;
    Widget row(String s, bool on) => Padding(
          padding: EdgeInsets.symmetric(vertical: gap),
          child: MergeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(on ? icon : Icons.cancel_rounded, size: 20, color: on ? ok : cs.outline, semanticLabel: on ? 'Included' : 'Not included'),
                const UiGap.md(),
                Expanded(
                  child: Text(
                    s,
                    style: context.text.bodyMedium?.copyWith(
                      color: on ? cs.onSurface : cs.onSurfaceVariant,
                      decoration: on ? null : TextDecoration.lineThrough,
                      decorationColor: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in items) row(s, true),
        for (final s in excluded) row(s, false),
      ],
    );
  }
}

class UiChipList extends StatelessWidget {
  const UiChipList(
    this.items, {
    super.key,
    this.status = UiStatus.neutral,
    this.max,
    this.icon,
    this.size = UiSize.md,
    this.spacing = UiSpace.sm,
  });

  final List<String> items;
  final UiStatus status;
  final int? max;
  final IconData? icon;
  final UiSize size;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final list = [for (final s in items) if (s.trim().isNotEmpty) s];
    if (list.isEmpty) return const SizedBox.shrink();
    final cap = max == null || max! < 1 ? list.length : max!.clamp(1, list.length);
    final extra = list.length - cap;
    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: [
        for (final s in list.take(cap)) UiTag(s, status: status, icon: icon, size: size),
        if (extra > 0) UiTag('+$extra', size: size),
      ],
    );
  }
}

class UiQuoteCard extends StatelessWidget {
  const UiQuoteCard(
    this.quote, {
    super.key,
    this.author,
    this.subtitle,
    this.avatarUrl,
    this.rating,
  });

  final String quote;
  final String? author;
  final String? subtitle;
  final String? avatarUrl;
  final double? rating;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Container(
      padding: const EdgeInsets.all(UiSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: context.tokens.lg,
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ExcludeSemantics(child: Icon(Icons.format_quote_rounded, size: 32, color: cs.primary.withValues(alpha: 0.6))),
              const Spacer(),
              if (rating != null) UiRatingStars(rating!, size: 14),
            ],
          ),
          const UiGap.sm(),
          Text(quote, style: context.text.bodyLarge?.copyWith(height: 1.5, fontStyle: FontStyle.italic)),
          if (author != null) ...[
            const UiGap.lg(),
            Row(
              children: [
                UiAvatar(name: author, imageUrl: avatarUrl, size: 36),
                const UiGap.md(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(author!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      if (subtitle != null)
                        Text(subtitle!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
