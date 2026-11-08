import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_image.dart';
import 'package:theme/src/foundation/ui_format.dart';

enum UiMessageStatus { sending, sent, delivered, read, failed }

class UiMessageTicks extends StatelessWidget {
  const UiMessageTicks(this.status, {super.key, this.color, this.readColor, this.size = 15});

  final UiMessageStatus status;
  final Color? color;
  final Color? readColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final c = color ?? cs.onSurfaceVariant;
    final (icon, fg, label) = switch (status) {
      UiMessageStatus.sending => (Icons.schedule_rounded, c, 'Sending'),
      UiMessageStatus.sent => (Icons.done_rounded, c, 'Sent'),
      UiMessageStatus.delivered => (Icons.done_all_rounded, c, 'Delivered'),
      UiMessageStatus.read => (Icons.done_all_rounded, readColor ?? context.palette.info, 'Read'),
      UiMessageStatus.failed => (Icons.error_outline_rounded, cs.error, 'Not sent'),
    };
    return Icon(icon, size: size, color: fg, semanticLabel: label);
  }
}

class UiChatBubble extends StatelessWidget {
  const UiChatBubble({
    super.key,
    required this.text,
    this.isMe = false,
    this.time,
    this.status,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
    this.imageUrl,
    this.reply,
    this.onTap,
    this.onLongPress,
    this.onImageTap,
    this.maxWidthFactor = 0.78,
  });

  final String text;
  final bool isMe;
  final DateTime? time;
  final UiMessageStatus? status;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final String? imageUrl;
  final ({String author, String text})? reply;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final VoidCallback? onImageTap;
  final double maxWidthFactor;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final big = Radius.circular(context.tokens.radiusLg);
    const small = Radius.circular(6);
    const tail = Radius.circular(4);
    final bg = isMe ? cs.primary : cs.surfaceContainerHigh;
    final fg = isMe ? cs.onPrimary : cs.onSurface;
    final muted = fg.withValues(alpha: 0.72);
    final r = isMe
        ? BorderRadius.only(topLeft: big, bottomLeft: big, topRight: isFirstInGroup ? big : small, bottomRight: isLastInGroup ? tail : small)
        : BorderRadius.only(topRight: big, bottomRight: big, topLeft: isFirstInGroup ? big : small, bottomLeft: isLastInGroup ? tail : small);
    final hasImg = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final body = text.trim();
    final stamp = time == null ? null : UiFormat.time(time!, h24: MediaQuery.alwaysUse24HourFormatOf(context));

    final meta = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (stamp != null) Text(stamp, style: context.text.labelSmall?.copyWith(color: muted, fontSize: 11)),
        if (isMe && status != null) ...[
          const SizedBox(width: UiSpace.xs),
          UiMessageTicks(status!, color: muted, readColor: cs.inversePrimary, size: 14),
        ],
      ],
    );

    return LayoutBuilder(
      builder: (context, c) {
        final maxW = (c.maxWidth.isFinite ? c.maxWidth : context.screen.width) * maxWidthFactor.clamp(0.4, 1.0);
        final w = hasImg ? math.min(maxW, 280.0) : maxW;
        return Padding(
          padding: EdgeInsets.only(top: isFirstInGroup ? UiSpace.sm : UiSpace.xxs),
          child: Align(
            alignment: isMe ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: w),
              child: Semantics(
                container: true,
                label: [
                  isMe ? 'You' : 'Message',
                  if (reply != null) 'replying to ${reply!.author}',
                  if (hasImg) 'photo',
                  if (body.isNotEmpty) body,
                  ?stamp,
                  if (isMe && status != null) status!.name,
                ].join(', '),
                excludeSemantics: true,
                child: Material(
                  color: bg,
                  shape: RoundedRectangleBorder(borderRadius: r),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap,
                    onLongPress: onLongPress,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (reply != null)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(UiSpace.xs, UiSpace.xs, UiSpace.xs, 0),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(UiSpace.sm, UiSpace.xs + 2, UiSpace.md, UiSpace.xs + 2),
                              decoration: BoxDecoration(
                                color: fg.withValues(alpha: 0.1),
                                borderRadius: context.tokens.sm,
                                border: BorderDirectional(start: BorderSide(color: isMe ? cs.onPrimary : cs.primary, width: 3)),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reply!.author,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: context.text.labelMedium?.copyWith(color: isMe ? cs.onPrimary : cs.primary, fontWeight: FontWeight.w700),
                                  ),
                                  Text(reply!.text, maxLines: 2, overflow: TextOverflow.ellipsis, style: context.text.bodySmall?.copyWith(color: muted)),
                                ],
                              ),
                            ),
                          ),
                        if (hasImg)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(UiSpace.xs, UiSpace.xs, UiSpace.xs, 0),
                            child: GestureDetector(
                              onTap: onImageTap,
                              child: SizedBox(
                                width: w - UiSpace.sm,
                                child: UiImage(imageUrl, aspectRatio: 4 / 3, radius: BorderRadius.circular(context.tokens.radiusLg - UiSpace.xs)),
                              ),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(UiSpace.md, UiSpace.sm, UiSpace.md, UiSpace.sm),
                          child: Wrap(
                            alignment: WrapAlignment.end,
                            crossAxisAlignment: WrapCrossAlignment.end,
                            spacing: UiSpace.sm,
                            runSpacing: UiSpace.xxs,
                            children: [
                              if (body.isNotEmpty) Text(body, style: context.text.bodyLarge?.copyWith(color: fg, height: 1.3)),
                              meta,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class UiChatDateDivider extends StatelessWidget {
  const UiChatDateDivider(this.date, {super.key, this.label});

  final DateTime date;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: UiSpace.md),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.xs),
          decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: context.tokens.full),
          child: Text(
            label ?? UiFormat.relativeDay(date),
            style: context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class UiTypingIndicator extends StatefulWidget {
  const UiTypingIndicator({super.key, this.color});

  final Color? color;

  @override
  State<UiTypingIndicator> createState() => _UiTypingIndicatorState();
}

class _UiTypingIndicatorState extends State<UiTypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final dot = widget.color ?? cs.onSurfaceVariant;
    final big = Radius.circular(context.tokens.radiusLg);
    return Semantics(
      label: 'Typing',
      liveRegion: true,
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Container(
          margin: const EdgeInsets.only(top: UiSpace.sm),
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md + 2),
          decoration: BoxDecoration(
            color: cs.surfaceContainerHigh,
            borderRadius: BorderRadius.only(topLeft: big, topRight: big, bottomRight: big, bottomLeft: const Radius.circular(4)),
          ),
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: UiSpace.xs + 1),
                  Builder(
                    builder: (context) {
                      final p = (_c.value - i * 0.18) % 1.0;
                      final v = p < 0.5 ? math.sin(p * 2 * math.pi) : 0.0;
                      return Transform.translate(
                        offset: Offset(0, -4 * v),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(color: dot.withValues(alpha: 0.45 + 0.55 * v), shape: BoxShape.circle),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
