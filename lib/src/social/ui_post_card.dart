import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/display/ui_expandable_text.dart';
import 'package:theme/src/image/ui_image_viewer.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/image/ui_avatar.dart';
import 'package:theme/src/card/ui_card.dart';

class UiVerifiedBadge extends StatelessWidget {
  const UiVerifiedBadge({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) =>
      Icon(Icons.verified_rounded, size: size, color: context.colors.primary, semanticLabel: 'Verified');
}

class UiLikeButton extends StatefulWidget {
  const UiLikeButton({
    super.key,
    this.liked = false,
    this.count,
    this.onChanged,
    this.size = 22,
  });

  final bool liked;
  final int? count;
  final ValueChanged<bool>? onChanged;
  final double size;

  @override
  State<UiLikeButton> createState() => _UiLikeButtonState();
}

class _UiLikeButtonState extends State<UiLikeButton> {
  late bool _liked = widget.liked;
  late int? _count = widget.count;

  @override
  void didUpdateWidget(UiLikeButton old) {
    super.didUpdateWidget(old);
    if (old.liked != widget.liked) _liked = widget.liked;
    if (old.count != widget.count) _count = widget.count;
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    setState(() {
      _liked = !_liked;
      if (_count != null) _count = (_count! + (_liked ? 1 : -1)).clamp(0, 1 << 52);
    });
    widget.onChanged?.call(_liked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final on = context.palette.sale;
    final c = _count;
    return _ActionChip(
      onTap: widget.onChanged == null ? null : _toggle,
      label: c == null ? null : UiFormat.count(c),
      color: _liked ? on : cs.onSurfaceVariant,
      semantics: _liked ? 'Unlike' : 'Like',
      toggled: _liked,
      icon: AnimatedSwitcher(
        duration: UiDuration.normal,
        transitionBuilder: (child, a) => ScaleTransition(
          scale: CurvedAnimation(parent: a, curve: Curves.elasticOut, reverseCurve: Curves.easeIn),
          child: child,
        ),
        child: Icon(
          _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(_liked),
          size: widget.size,
          color: _liked ? on : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.icon, required this.semantics, this.label, this.onTap, this.color, this.toggled});

  final Widget icon;
  final String semantics;
  final String? label;
  final VoidCallback? onTap;
  final Color? color;
  final bool? toggled;

  @override
  Widget build(BuildContext context) {
    final fg = color ?? context.colors.onSurfaceVariant;
    return Semantics(
      button: true,
      toggled: toggled,
      label: label == null ? semantics : '$semantics, $label',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.tokens.full,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 40, minWidth: 40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconTheme.merge(data: IconThemeData(color: fg, size: 22), child: icon),
                if (label != null) ...[
                  const SizedBox(width: UiSpace.xs + 2),
                  AnimatedSwitcher(
                    duration: UiDuration.fast,
                    child: Text(
                      label!,
                      key: ValueKey(label),
                      style: context.text.labelLarge?.copyWith(color: fg, fontWeight: FontWeight.w600),
                    ),
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

class UiPostCard extends StatefulWidget {
  const UiPostCard({
    super.key,
    required this.author,
    this.handle,
    this.avatarUrl,
    this.verified = false,
    this.time,
    this.text,
    this.images = const [],
    this.likes = 0,
    this.comments = 0,
    this.shares,
    this.liked = false,
    this.bookmarked = false,
    this.maxLines = 4,
    this.onLikeChanged,
    this.onBookmarkChanged,
    this.onComment,
    this.onShare,
    this.onMore,
    this.onAuthorTap,
    this.onImageTap,
    this.onTap,
  });

  final String author;
  final String? handle;
  final String? avatarUrl;
  final bool verified;
  final DateTime? time;
  final String? text;
  final List<String> images;
  final int likes;
  final int comments;
  final int? shares;
  final bool liked;
  final bool bookmarked;
  final int maxLines;
  final ValueChanged<bool>? onLikeChanged;
  final ValueChanged<bool>? onBookmarkChanged;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final VoidCallback? onMore;
  final VoidCallback? onAuthorTap;
  final ValueChanged<int>? onImageTap;
  final VoidCallback? onTap;

  @override
  State<UiPostCard> createState() => _UiPostCardState();
}

class _UiPostCardState extends State<UiPostCard> {
  late bool _liked = widget.liked;
  late int _likes = widget.likes;
  late bool _saved = widget.bookmarked;

  @override
  void didUpdateWidget(UiPostCard old) {
    super.didUpdateWidget(old);
    if (old.liked != widget.liked) _liked = widget.liked;
    if (old.likes != widget.likes) _likes = widget.likes;
    if (old.bookmarked != widget.bookmarked) _saved = widget.bookmarked;
  }

  void _setLiked(bool v) {
    if (v == _liked) return;
    setState(() {
      _liked = v;
      _likes = (_likes + (v ? 1 : -1)).clamp(0, 1 << 52);
    });
    widget.onLikeChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final sub = [
      if (widget.handle?.trim().isNotEmpty ?? false) '@${widget.handle!.trim().replaceFirst(RegExp('^@'), '')}',
      if (widget.time != null) UiFormat.relative(widget.time!),
    ].join(' · ');
    final body = widget.text?.trim() ?? '';
    final imgs = widget.images.where((e) => e.trim().isNotEmpty).toList();

    return UiCard(
      padding: EdgeInsets.zero,
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.md, UiSpace.xs, 0),
            child: Row(
              children: [
                UiAvatar(name: widget.author, imageUrl: widget.avatarUrl, size: 42, onTap: widget.onAuthorTap),
                const SizedBox(width: UiSpace.md),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onAuthorTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            if (widget.verified) ...[const SizedBox(width: UiSpace.xs), const UiVerifiedBadge()],
                          ],
                        ),
                        if (sub.isNotEmpty)
                          Text(
                            sub,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ),
                if (widget.onMore != null)
                  IconButton(
                    onPressed: widget.onMore,
                    tooltip: 'More',
                    icon: const Icon(Icons.more_horiz_rounded),
                    color: cs.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          if (body.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.md, UiSpace.lg, 0),
              child: UiExpandableText(
                body,
                key: ValueKey(body),
                maxLines: widget.maxLines.clamp(1, 40),
                style: context.text.bodyMedium?.copyWith(height: 1.4, color: cs.onSurface),
                moreLabel: 'more',
                lessLabel: 'less',
              ),
            ),
          if (imgs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(UiSpace.md, UiSpace.md, UiSpace.md, 0),
              child: UiImageGrid(
                imgs,
                aspectRatio: imgs.length == 1 ? 4 / 3 : 1.25,
                onTap: widget.onImageTap,
                onDoubleTap: () => _setLiked(true),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(UiSpace.sm, UiSpace.xs, UiSpace.sm, UiSpace.xs),
            child: Row(
              children: [
                UiLikeButton(liked: _liked, count: _likes, onChanged: _setLiked),
                _ActionChip(
                  icon: const Icon(Icons.chat_bubble_outline_rounded),
                  semantics: 'Comments',
                  label: UiFormat.count(widget.comments),
                  onTap: widget.onComment,
                ),
                if (widget.onShare != null || widget.shares != null)
                  _ActionChip(
                    icon: const Icon(Icons.share_outlined),
                    semantics: 'Share',
                    label: widget.shares == null ? null : UiFormat.count(widget.shares!),
                    onTap: widget.onShare,
                  ),
                const Spacer(),
                if (widget.onBookmarkChanged != null)
                  _ActionChip(
                    icon: Icon(_saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded),
                    semantics: _saved ? 'Remove bookmark' : 'Bookmark',
                    toggled: _saved,
                    color: _saved ? cs.primary : null,
                    onTap: () {
                      setState(() => _saved = !_saved);
                      widget.onBookmarkChanged!(_saved);
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class UiCommentTile extends StatelessWidget {
  const UiCommentTile({
    super.key,
    required this.name,
    required this.text,
    this.avatarUrl,
    this.time,
    this.verified = false,
    this.likes,
    this.liked = false,
    this.level = 0,
    this.onLikeChanged,
    this.onReply,
    this.onAuthorTap,
    this.onLongPress,
  });

  final String name;
  final String text;
  final String? avatarUrl;
  final DateTime? time;
  final bool verified;
  final int? likes;
  final bool liked;
  final int level;
  final ValueChanged<bool>? onLikeChanged;
  final VoidCallback? onReply;
  final VoidCallback? onAuthorTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final lv = level.clamp(0, 4);
    final muted = context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600);
    return Padding(
      padding: EdgeInsetsDirectional.only(start: UiSpace.lg + lv * 40.0, end: UiSpace.sm, top: UiSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiAvatar(name: name, imageUrl: avatarUrl, size: lv == 0 ? 36 : 28, onTap: onAuthorTap),
          const SizedBox(width: UiSpace.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onLongPress: onLongPress,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(UiSpace.md, UiSpace.sm, UiSpace.md, UiSpace.sm),
                    decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: context.tokens.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: onAuthorTap,
                                child: Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ),
                            ),
                            if (verified) ...[const SizedBox(width: UiSpace.xs), const UiVerifiedBadge(size: 14)],
                          ],
                        ),
                        const SizedBox(height: UiSpace.xxs),
                        Text(text.trim(), style: context.text.bodyMedium?.copyWith(height: 1.35)),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    const SizedBox(width: UiSpace.md),
                    if (time != null) Text(UiFormat.relative(time!), style: muted),
                    if (onReply != null)
                      TextButton(
                        onPressed: onReply,
                        style: TextButton.styleFrom(
                          minimumSize: const Size(44, 36),
                          padding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
                          foregroundColor: cs.onSurfaceVariant,
                          textStyle: muted,
                        ),
                        child: const Text('Reply'),
                      ),
                    const Spacer(),
                    if (onLikeChanged != null || likes != null)
                      UiLikeButton(liked: liked, count: likes, onChanged: onLikeChanged, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
