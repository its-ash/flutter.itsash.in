import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/ui_money.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_avatar.dart';
import 'package:theme/src/card/ui_card.dart';
import 'package:theme/src/image/ui_image.dart';
import 'package:theme/src/display/ui_rating_stars.dart';
import 'package:theme/src/display/ui_tag.dart';

enum UiOrderStatus {
  pending('Pending', UiStatus.warning),
  processing('Processing', UiStatus.info),
  shipped('Shipped', UiStatus.info),
  delivered('Delivered', UiStatus.success),
  cancelled('Cancelled', UiStatus.danger),
  returned('Returned', UiStatus.neutral);

  const UiOrderStatus(this.label, this.tone);

  final String label;
  final UiStatus tone;
}

class UiOrderCard extends StatelessWidget {
  const UiOrderCard({
    super.key,
    required this.orderId,
    required this.total,
    this.status = UiOrderStatus.processing,
    this.statusLabel,
    this.date,
    this.imageUrls = const [],
    this.itemCount,
    this.onTap,
    this.symbol,
  });

  final String orderId;
  final num total;
  final UiOrderStatus status;
  final String? statusLabel;
  final DateTime? date;
  final List<String> imageUrls;
  final int? itemCount;
  final VoidCallback? onTap;
  final String? symbol;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final n = math.max(0, itemCount ?? imageUrls.length);
    final shown = imageUrls.take(3).toList();
    final extra = math.max(n, imageUrls.length) - shown.length;
    const d = 44.0;
    const step = 32.0;
    final slots = shown.length + (extra > 0 ? 1 : 0);
    final ring = Border.all(color: cs.surfaceContainerLow, width: 2);
    final r = context.tokens.sm;

    final thumbs = shown.isEmpty
        ? Container(
            width: d,
            height: d,
            decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: r),
            child: Icon(Icons.shopping_bag_outlined, color: cs.onSurfaceVariant, size: 20),
          )
        : SizedBox(
            width: d + step * (slots - 1),
            height: d,
            child: Stack(
              children: [
                for (final (i, url) in shown.indexed)
                  Positioned(
                    left: i * step,
                    child: Container(
                      decoration: BoxDecoration(borderRadius: r, border: ring),
                      child: UiImage(url, width: d - 4, height: d - 4, radius: r),
                    ),
                  ),
                if (extra > 0)
                  Positioned(
                    left: shown.length * step,
                    child: Container(
                      width: d,
                      height: d,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: cs.secondaryContainer, borderRadius: r, border: ring),
                      child: Text(
                        '+$extra',
                        style: context.text.labelMedium?.copyWith(color: cs.onSecondaryContainer, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
              ],
            ),
          );

    return UiCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Order #$orderId',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    if (date != null)
                      Text(UiFormat.date(date!), style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              UiTag(statusLabel ?? status.label, status: status.tone, size: UiSize.sm),
            ],
          ),
          const UiGap.md(),
          Row(
            children: [
              ExcludeSemantics(child: thumbs),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$n ${n == 1 ? 'item' : 'items'}', style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                  Semantics(
                    label: 'Total ${UiMoney.spoken(math.max(0, UiMoney.safe(total)), symbol: symbol)}',
                    excludeSemantics: true,
                    child: Text(
                      UiMoney.format(math.max(0, UiMoney.safe(total)), symbol: symbol),
                      style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
              if (onTap != null) ...[const UiGap.xs(), Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant)],
            ],
          ),
        ],
      ),
    );
  }
}

class UiTrackStep {
  const UiTrackStep(this.title, {this.subtitle, this.time, this.icon});

  final String title;
  final String? subtitle;
  final DateTime? time;
  final IconData? icon;
}

enum _Phase { done, current, upcoming, cancelled }

class UiOrderTracker extends StatelessWidget {
  const UiOrderTracker({
    super.key,
    this.current = 0,
    this.steps = defaults,
    this.times = const [],
    this.cancelled = false,
    this.cancelledLabel = 'Cancelled',
    this.cancelledNote,
    this.cancelledTime,
  });

  static const defaults = [
    UiTrackStep('Ordered', icon: Icons.receipt_long_outlined),
    UiTrackStep('Packed', icon: Icons.inventory_2_outlined),
    UiTrackStep('Shipped', icon: Icons.local_shipping_outlined),
    UiTrackStep('Out for delivery', icon: Icons.delivery_dining_outlined),
    UiTrackStep('Delivered', icon: Icons.home_outlined),
  ];

  final int current;
  final List<UiTrackStep> steps;
  final List<DateTime?> times;
  final bool cancelled;
  final String cancelledLabel;
  final String? cancelledNote;
  final DateTime? cancelledTime;

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final cur = current.clamp(0, steps.length - 1);
    final rows = <(UiTrackStep, DateTime?, _Phase)>[
      for (var i = 0; i < steps.length; i++)
        if (!cancelled || i <= cur)
          (
            steps[i],
            steps[i].time ?? (i < times.length ? times[i] : null),
            cancelled || i < cur ? _Phase.done : (i == cur ? _Phase.current : _Phase.upcoming),
          ),
      if (cancelled)
        (UiTrackStep(cancelledLabel, subtitle: cancelledNote, icon: Icons.close_rounded), cancelledTime, _Phase.cancelled),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, (s, t, ph)) in rows.indexed)
          Builder(
            builder: (context) {
              final last = i == rows.length - 1;
              final (bg, fg, ic) = switch (ph) {
                _Phase.done => (cs.primary, cs.onPrimary, Icons.check_rounded),
                _Phase.current => (cs.primary, cs.onPrimary, s.icon ?? Icons.radio_button_checked_rounded),
                _Phase.upcoming => (cs.surfaceContainerHigh, cs.onSurfaceVariant, s.icon ?? Icons.circle_outlined),
                _Phase.cancelled => (cs.error, cs.onError, Icons.close_rounded),
              };
              final lineColor = last
                  ? Colors.transparent
                  : rows[i + 1].$3 == _Phase.cancelled
                      ? cs.error
                      : ph == _Phase.done
                          ? cs.primary
                          : cs.outlineVariant;
              final state = switch (ph) {
                _Phase.done => 'completed',
                _Phase.current => 'current',
                _Phase.upcoming => 'pending',
                _Phase.cancelled => '',
              };
              return Semantics(
                label: [s.title, if (state.isNotEmpty) state, ?s.subtitle, if (t != null) UiFormat.dateTime(t, weekday: true)].join(', '),
                excludeSemantics: true,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        width: 32,
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: UiDuration.normal,
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: bg,
                                boxShadow: ph == _Phase.current
                                    ? [BoxShadow(color: cs.primary.withValues(alpha: 0.25), spreadRadius: 4)]
                                    : null,
                              ),
                              child: Icon(ic, size: 16, color: fg),
                            ),
                            if (!last)
                              Expanded(
                                child: Container(
                                  width: 2,
                                  margin: const EdgeInsets.symmetric(vertical: UiSpace.xs),
                                  decoration: BoxDecoration(color: lineColor, borderRadius: context.tokens.full),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const UiGap.md(),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 5, bottom: last ? 0 : UiSpace.xl),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                s.title,
                                style: context.text.titleSmall?.copyWith(
                                  fontWeight: ph == _Phase.current ? FontWeight.w800 : FontWeight.w600,
                                  color: switch (ph) {
                                    _Phase.upcoming => cs.onSurfaceVariant,
                                    _Phase.cancelled => cs.error,
                                    _ => cs.onSurface,
                                  },
                                ),
                              ),
                              if (s.subtitle != null)
                                Text(s.subtitle!, style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                              if (t != null)
                                Text(UiFormat.dateTime(t, weekday: true), style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

class UiReviewTile extends StatelessWidget {
  const UiReviewTile({
    super.key,
    required this.name,
    required this.rating,
    this.text,
    this.title,
    this.date,
    this.avatarUrl,
    this.photos = const [],
    this.onPhotoTap,
    this.helpfulCount,
    this.onHelpful,
    this.verified = false,
    this.verifiedLabel = 'Verified purchase',
    this.maxLines,
  });

  final String name;
  final double rating;
  final String? text;
  final String? title;
  final DateTime? date;
  final String? avatarUrl;
  final List<String> photos;
  final ValueChanged<int>? onPhotoTap;
  final int? helpfulCount;
  final VoidCallback? onHelpful;
  final bool verified;
  final String verifiedLabel;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final ok = context.palette.success;
    final h = helpfulCount == null ? 0 : math.max(0, helpfulCount!);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UiSpace.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              UiAvatar(name: name, imageUrl: avatarUrl, size: 40),
              const UiGap.md(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        UiRatingStars(rating, size: 14),
                        if (date != null) ...[
                          const UiGap.sm(),
                          Flexible(
                            child: Text(
                              UiFormat.relative(date!),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (verified) ...[
            const UiGap.sm(),
            Row(
              children: [
                Icon(Icons.verified_rounded, size: 14, color: ok),
                const UiGap.xs(),
                Text(verifiedLabel, style: context.text.labelSmall?.copyWith(color: ok, fontWeight: FontWeight.w600)),
              ],
            ),
          ],
          if (title != null) ...[
            const UiGap.sm(),
            Text(title!, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
          if (text != null && text!.trim().isNotEmpty) ...[
            const UiGap.xs(),
            Text(
              text!,
              maxLines: maxLines,
              overflow: maxLines == null ? null : TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(height: 1.45),
            ),
          ],
          if (photos.isNotEmpty) ...[
            const UiGap.md(),
            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, _) => const UiGap.sm(),
                itemBuilder: (context, i) => Semantics(
                  button: onPhotoTap != null,
                  label: 'Review photo ${i + 1} of ${photos.length}',
                  onTap: onPhotoTap == null ? null : () => onPhotoTap!(i),
                  excludeSemantics: true,
                  child: GestureDetector(
                    onTap: onPhotoTap == null ? null : () => onPhotoTap!(i),
                    child: UiImage(photos[i], width: 72, height: 72, radius: context.tokens.sm),
                  ),
                ),
              ),
            ),
          ],
          if (helpfulCount != null || onHelpful != null) ...[
            const UiGap.xs(),
            TextButton.icon(
              onPressed: onHelpful,
              icon: const Icon(Icons.thumb_up_outlined, size: 16),
              label: Text(h > 0 ? 'Helpful ($h)' : 'Helpful'),
              style: TextButton.styleFrom(
                foregroundColor: cs.onSurfaceVariant,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class UiRatingSummary extends StatelessWidget {
  const UiRatingSummary({
    super.key,
    required this.average,
    this.distribution = const [],
    this.total,
    this.reviewsLabel = 'reviews',
  });

  final double average;
  final List<int> distribution;
  final int? total;
  final String reviewsLabel;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final avg = average.isFinite ? average.clamp(0.0, 5.0).toDouble() : 0.0;
    final counts = List.generate(5, (i) => i < distribution.length ? math.max(0, distribution[i]) : 0);
    final sum = counts.fold(0, (a, b) => a + b);
    final tot = math.max(0, total ?? sum);
    final muted = context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant);

    return Row(
      children: [
        Semantics(
          label: 'Average rating ${avg.toStringAsFixed(1)} of 5, $tot $reviewsLabel',
          excludeSemantics: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(avg.toStringAsFixed(1), style: context.text.displaySmall?.copyWith(fontWeight: FontWeight.w800)),
              UiRatingStars(avg),
              const UiGap.xs(),
              Text('${UiFormat.number(tot)} $reviewsLabel', style: muted),
            ],
          ),
        ),
        const UiGap.xxl(),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 5; i++)
                Semantics(
                  label: '${5 - i} stars, ${counts[i]} $reviewsLabel',
                  excludeSemantics: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: UiSpace.xxs),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 12,
                          child: Text('${5 - i}', style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        Icon(Icons.star_rounded, size: 12, color: context.palette.rating),
                        const UiGap.sm(),
                        Expanded(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(end: sum == 0 ? 0 : counts[i] / sum),
                            duration: UiDuration.slow,
                            curve: UiCurve.standard,
                            builder: (_, v, _) => LinearProgressIndicator(
                              value: v,
                              minHeight: 6,
                              borderRadius: context.tokens.full,
                              color: context.palette.rating,
                              backgroundColor: cs.surfaceContainerHighest,
                            ),
                          ),
                        ),
                        const UiGap.sm(),
                        SizedBox(
                          width: 36,
                          child: Text(UiFormat.compact(counts[i]), textAlign: TextAlign.end, style: muted),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
