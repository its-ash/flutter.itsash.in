import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_avatar.dart';
import 'package:theme/src/image/ui_image.dart';
import 'package:theme/src/social/ui_chat_bubble.dart';
import 'package:theme/src/social/ui_post_card.dart';
import 'package:theme/src/foundation/ui_format.dart';

class UiUnreadBadge extends StatelessWidget {
  const UiUnreadBadge(this.count, {super.key, this.muted = false});

  final int count;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final cs = context.colors;
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(color: muted ? cs.outline : cs.primary, borderRadius: context.tokens.full),
      child: Text(
        count > 99 ? '99+' : '$count',
        semanticsLabel: '$count unread',
        style: context.text.labelSmall?.copyWith(color: muted ? cs.surface : cs.onPrimary, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class UiConversationTile extends StatelessWidget {
  const UiConversationTile({
    super.key,
    required this.name,
    this.message,
    this.avatarUrl,
    this.time,
    this.unread = 0,
    this.online = false,
    this.muted = false,
    this.pinned = false,
    this.typing = false,
    this.status,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  final String name;
  final String? message;
  final String? avatarUrl;
  final DateTime? time;
  final int unread;
  final bool online;
  final bool muted;
  final bool pinned;
  final bool typing;
  final UiMessageStatus? status;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final hasUnread = unread > 0;
    final muteC = cs.onSurfaceVariant;
    return Material(
      color: selected ? cs.secondaryContainer.withValues(alpha: 0.6) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md - 2),
          child: Row(
            children: [
              UiAvatar(name: name, imageUrl: avatarUrl, size: 52, status: online ? UiStatus.success : null),
              const SizedBox(width: UiSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.titleSmall?.copyWith(fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600),
                          ),
                        ),
                        if (time != null) ...[
                          const SizedBox(width: UiSpace.sm),
                          Text(
                            UiFormat.sameDay(time, DateTime.now())
                                ? UiFormat.time(time!, h24: MediaQuery.alwaysUse24HourFormatOf(context))
                                : UiFormat.relativeDay(time!),
                            style: context.text.labelSmall?.copyWith(
                              color: hasUnread && !muted ? cs.primary : muteC,
                              fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: UiSpace.xxs),
                    Row(
                      children: [
                        if (status != null && !typing) ...[UiMessageTicks(status!, size: 16), const SizedBox(width: UiSpace.xs)],
                        Expanded(
                          child: Text(
                            typing ? 'typing…' : (message?.trim() ?? ''),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyMedium?.copyWith(
                              color: typing ? cs.primary : (hasUnread ? cs.onSurface : muteC),
                              fontStyle: typing ? FontStyle.italic : null,
                              fontWeight: hasUnread ? FontWeight.w600 : null,
                            ),
                          ),
                        ),
                        if (muted) ...[const SizedBox(width: UiSpace.xs), Icon(Icons.volume_off_rounded, size: 16, color: muteC, semanticLabel: 'Muted')],
                        if (pinned) ...[const SizedBox(width: UiSpace.xs), Icon(Icons.push_pin_rounded, size: 16, color: muteC, semanticLabel: 'Pinned')],
                        if (hasUnread) ...[const SizedBox(width: UiSpace.sm), UiUnreadBadge(unread, muted: muted)],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class UiUserTile extends StatelessWidget {
  const UiUserTile({
    super.key,
    required this.name,
    this.subtitle,
    this.avatarUrl,
    this.verified = false,
    this.online = false,
    this.trailing,
    this.avatarSize = 44,
    this.onTap,
  });

  final String name;
  final String? subtitle;
  final String? avatarUrl;
  final bool verified;
  final bool online;
  final Widget? trailing;
  final double avatarSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final sub = subtitle?.trim() ?? '';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.sm),
        child: Row(
          children: [
            UiAvatar(name: name, imageUrl: avatarUrl, size: avatarSize, status: online ? UiStatus.success : null),
            const SizedBox(width: UiSpace.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (verified) ...[const SizedBox(width: UiSpace.xs), const UiVerifiedBadge(size: 15)],
                    ],
                  ),
                  if (sub.isNotEmpty)
                    Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: UiSpace.sm), trailing!],
          ],
        ),
      ),
    );
  }
}

class UiNotificationTile extends StatelessWidget {
  const UiNotificationTile({
    super.key,
    required this.actor,
    required this.action,
    this.avatarUrl,
    this.time,
    this.unread = false,
    this.icon,
    this.iconColor,
    this.thumbnailUrl,
    this.trailing,
    this.onTap,
  });

  final String actor;
  final String action;
  final String? avatarUrl;
  final DateTime? time;
  final bool unread;
  final IconData? icon;
  final Color? iconColor;
  final String? thumbnailUrl;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final base = context.text.bodyMedium?.copyWith(height: 1.35, color: cs.onSurface);
    final stamp = time == null ? null : UiFormat.relative(time!);
    final badgeC = iconColor ?? cs.primary;
    Widget avatar = UiAvatar(name: actor, imageUrl: avatarUrl, size: 46);
    if (icon != null) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          PositionedDirectional(
            end: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(color: badgeC, shape: BoxShape.circle, border: Border.all(color: cs.surface, width: 2)),
              child: Icon(icon, size: 12, color: ThemeData.estimateBrightnessForColor(badgeC) == Brightness.dark ? Colors.white : Colors.black),
            ),
          ),
        ],
      );
    }
    final thumb = thumbnailUrl?.trim() ?? '';
    return Semantics(
      label: unread ? 'Unread' : null,
      child: Material(
        color: unread ? cs.primaryContainer.withValues(alpha: context.isDark ? 0.18 : 0.32) : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(UiSpace.sm, UiSpace.md, UiSpace.lg, UiSpace.md),
            child: Row(
              children: [
                SizedBox(
                  width: UiSpace.sm,
                  child: unread
                      ? Center(child: Container(width: 6, height: 6, decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle)))
                      : null,
                ),
                const SizedBox(width: UiSpace.xs),
                avatar,
                const SizedBox(width: UiSpace.md),
                Expanded(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: actor, style: const TextStyle(fontWeight: FontWeight.w700)),
                        TextSpan(text: ' ${action.trim()}'),
                        if (stamp != null) TextSpan(text: '  $stamp', style: TextStyle(color: cs.onSurfaceVariant)),
                      ],
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: base,
                  ),
                ),
                if (trailing != null)
                  ...[const SizedBox(width: UiSpace.sm), trailing!]
                else if (thumb.isNotEmpty)
                  ...[const SizedBox(width: UiSpace.sm), UiImage(thumb, width: 46, height: 46, radius: context.tokens.sm)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
