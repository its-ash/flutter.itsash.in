import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_avatar.dart';
import 'package:theme/src/button/ui_button.dart';
import 'package:theme/src/card/ui_card.dart';
import 'package:theme/src/display/ui_tag.dart';

enum UiBookingStatus {
  upcoming('Upcoming', UiStatus.info),
  confirmed('Confirmed', UiStatus.success),
  pending('Pending', UiStatus.warning),
  completed('Completed', UiStatus.neutral),
  cancelled('Cancelled', UiStatus.danger);

  const UiBookingStatus(this.label, this.status);

  final String label;
  final UiStatus status;
}

class UiBookingCard extends StatelessWidget {
  const UiBookingCard({
    super.key,
    required this.title,
    this.start,
    this.duration,
    this.provider,
    this.providerRole,
    this.providerImage,
    this.location,
    this.status = UiBookingStatus.upcoming,
    this.onTap,
    this.onReschedule,
    this.onCancel,
    this.rescheduleLabel = 'Reschedule',
    this.cancelLabel = 'Cancel',
    this.use24h = false,
  });

  final String title;
  final DateTime? start;
  final Duration? duration;
  final String? provider;
  final String? providerRole;
  final String? providerImage;
  final String? location;
  final UiBookingStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onReschedule;
  final VoidCallback? onCancel;
  final String rescheduleLabel;
  final String cancelLabel;
  final bool use24h;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final s = start;
    final d = duration;
    final active = status != UiBookingStatus.cancelled && status != UiBookingStatus.completed;
    final time = s == null
        ? null
        : '${UiFormat.time(s, h24: use24h)}'
            '${d == null || d <= Duration.zero ? '' : ' – ${UiFormat.time(s.add(d), h24: use24h)}'}';

    Widget info(IconData icon, String text) => Row(
          children: [
            Icon(icon, size: 18, color: cs.primary),
            const UiGap.sm(),
            Expanded(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        );

    return UiCard(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              const UiGap.sm(),
              UiTag(status.label, status: status.status, size: UiSize.sm),
            ],
          ),
          if (provider != null) ...[
            const UiGap.md(),
            Row(
              children: [
                UiAvatar(name: provider, imageUrl: providerImage, size: 36),
                const UiGap.sm(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (providerRole != null)
                        Text(
                          providerRole!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (s != null || location != null) ...[
            const UiGap.md(),
            Container(
              padding: const EdgeInsets.all(UiSpace.md),
              decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: context.tokens.md),
              child: Column(
                children: [
                  if (s != null)
                    Row(
                      children: [
                        Expanded(child: info(Icons.calendar_today_rounded, UiFormat.day(s))),
                        if (time != null) Expanded(child: info(Icons.schedule_rounded, time)),
                      ],
                    ),
                  if (s != null && location != null) const UiGap.sm(),
                  if (location != null) info(Icons.place_rounded, location!),
                ],
              ),
            ),
          ],
          if (active && (onReschedule != null || onCancel != null)) ...[
            const UiGap.md(),
            Row(
              children: [
                if (onCancel != null)
                  Expanded(child: UiButton.outline(cancelLabel, size: UiSize.sm, onPressed: onCancel)),
                if (onCancel != null && onReschedule != null) const UiGap.sm(),
                if (onReschedule != null)
                  Expanded(child: UiButton.tonal(rescheduleLabel, size: UiSize.sm, onPressed: onReschedule)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
