import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_avatar.dart';
import 'package:theme/src/button/ui_button.dart';
import 'package:theme/src/image/ui_image.dart';
import 'package:theme/src/social/ui_post_card.dart';
import 'package:theme/src/foundation/ui_format.dart';

class UiFollowButton extends StatefulWidget {
  const UiFollowButton({
    super.key,
    this.following = false,
    this.onChanged,
    this.followLabel = 'Follow',
    this.followingLabel = 'Following',
    this.size = UiSize.sm,
  });

  final bool following;
  final Future<void> Function(bool following)? onChanged;
  final String followLabel;
  final String followingLabel;
  final UiSize size;

  @override
  State<UiFollowButton> createState() => _UiFollowButtonState();
}

class _UiFollowButtonState extends State<UiFollowButton> {
  late bool _on = widget.following;
  bool _busy = false;

  @override
  void didUpdateWidget(UiFollowButton old) {
    super.didUpdateWidget(old);
    if (old.following != widget.following) _on = widget.following;
  }

  Future<void> _tap() async {
    final fn = widget.onChanged;
    if (_busy || fn == null) return;
    final next = !_on;
    setState(() => _busy = true);
    try {
      await fn(next);
      if (mounted) setState(() => _on = next);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final (h, fs) = switch (widget.size) {
      UiSize.sm => (36.0, 13.0),
      UiSize.md => (44.0, 14.0),
      UiSize.lg => (52.0, 15.0),
    };
    final bg = _on ? cs.surfaceContainerHigh : cs.primary;
    final fg = _on ? cs.onSurface : cs.onPrimary;
    final label = _on ? widget.followingLabel : widget.followLabel;
    return Semantics(
      button: true,
      toggled: _on,
      enabled: widget.onChanged != null && !_busy,
      label: label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: UiDuration.normal,
        curve: UiCurve.standard,
        height: h,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: context.tokens.full,
          border: Border.all(color: _on ? cs.outlineVariant : bg),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: widget.onChanged == null ? null : _tap,
            borderRadius: context.tokens.full,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: h * 0.45),
              child: AnimatedSize(
                duration: UiDuration.normal,
                curve: UiCurve.standard,
                child: AnimatedSwitcher(
                  duration: UiDuration.fast,
                  child: Row(
                    key: ValueKey((_on, _busy)),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_busy)
                        SizedBox.square(dimension: fs + 2, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
                      else
                        Icon(_on ? Icons.check_rounded : Icons.person_add_alt_1_rounded, size: fs + 4, color: fg),
                      const SizedBox(width: UiSpace.xs + 2),
                      Text(label, style: context.text.labelLarge?.copyWith(color: fg, fontSize: fs, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UiProfileHeader extends StatelessWidget {
  const UiProfileHeader({
    super.key,
    required this.name,
    this.handle,
    this.avatarUrl,
    this.coverUrl,
    this.bio,
    this.verified = false,
    this.posts,
    this.followers,
    this.following,
    this.action,
    this.onMessage,
    this.onAvatarTap,
    this.onPostsTap,
    this.onFollowersTap,
    this.onFollowingTap,
    this.coverHeight = 140,
    this.avatarSize = 92,
  });

  final String name;
  final String? handle;
  final String? avatarUrl;
  final String? coverUrl;
  final String? bio;
  final bool verified;
  final int? posts;
  final int? followers;
  final int? following;
  final Widget? action;
  final VoidCallback? onMessage;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onPostsTap;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final double coverHeight;
  final double avatarSize;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final hasCover = coverUrl?.trim().isNotEmpty ?? false;
    final h = handle?.trim().replaceFirst(RegExp('^@'), '') ?? '';
    final about = bio?.trim() ?? '';
    final stats = [
      if (posts != null) ('Posts', posts!, onPostsTap),
      if (followers != null) ('Followers', followers!, onFollowersTap),
      if (following != null) ('Following', following!, onFollowingTap),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: coverHeight + avatarSize / 2,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: coverHeight,
                child: hasCover
                    ? UiImage(coverUrl, semanticLabel: 'Cover photo')
                    : DecoratedBox(decoration: BoxDecoration(gradient: context.palette.gradient)),
              ),
              PositionedDirectional(
                start: UiSpace.lg,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(color: cs.surface, shape: BoxShape.circle),
                  child: UiAvatar(name: name, imageUrl: avatarUrl, size: avatarSize, onTap: onAvatarTap),
                ),
              ),
              PositionedDirectional(
                end: UiSpace.lg,
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onMessage != null) ...[
                      UiIconButton(Icons.chat_bubble_outline_rounded, onPressed: onMessage, tooltip: 'Message', size: UiSize.sm, variant: UiIconButtonVariant.outline),
                      const SizedBox(width: UiSpace.sm),
                    ],
                    ?action,
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.md, UiSpace.lg, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  if (verified) ...[const SizedBox(width: UiSpace.xs + 2), const UiVerifiedBadge(size: 20)],
                ],
              ),
              if (h.isNotEmpty) Text('@$h', style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              if (about.isNotEmpty) ...[
                const SizedBox(height: UiSpace.sm),
                Text(about, style: context.text.bodyMedium?.copyWith(height: 1.4)),
              ],
              if (stats.isNotEmpty) ...[
                const SizedBox(height: UiSpace.md),
                Wrap(
                  spacing: UiSpace.xs,
                  children: [
                    for (final (label, value, onTap) in stats)
                      Semantics(
                        button: onTap != null,
                        label: '$value $label',
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: onTap,
                          borderRadius: context.tokens.sm,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs, vertical: UiSpace.xs),
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: UiFormat.count(value),
                                    style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface),
                                  ),
                                  TextSpan(text: ' $label', style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
