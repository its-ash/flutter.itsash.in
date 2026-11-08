import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_avatar.dart';

@immutable
class UiStory {
  const UiStory({required this.name, this.imageUrl, this.seen = false, this.live = false});

  final String name;
  final String? imageUrl;
  final bool seen;
  final bool live;
}

class UiStoryAvatar extends StatelessWidget {
  const UiStoryAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.seen = false,
    this.live = false,
    this.add = false,
    this.label,
    this.size = 64,
    this.showLabel = true,
    this.onTap,
  });

  final String name;
  final String? imageUrl;
  final bool seen;
  final bool live;
  final bool add;
  final String? label;
  final double size;
  final bool showLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final ring = add && !live ? null : (seen && !live ? BoxDecoration(shape: BoxShape.circle, color: cs.outlineVariant) : BoxDecoration(shape: BoxShape.circle, gradient: context.palette.gradient));
    final w = size + 10;
    Widget avatar = Container(
      width: w,
      height: w,
      padding: EdgeInsets.all(seen ? 1.5 : 2.5),
      decoration: ring,
      child: Container(
        padding: EdgeInsets.all(seen ? 3 : 2),
        decoration: BoxDecoration(shape: BoxShape.circle, color: cs.surface),
        child: UiAvatar(name: name, imageUrl: imageUrl, size: size),
      ),
    );
    if (add || live) {
      avatar = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          avatar,
          if (live)
            Positioned(
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: context.palette.sale,
                  borderRadius: context.tokens.xs,
                  border: Border.all(color: cs.surface, width: 2),
                ),
                child: Text('LIVE', style: context.text.labelSmall?.copyWith(color: cs.onError, fontWeight: FontWeight.w800, fontSize: 9)),
              ),
            )
          else
            PositionedDirectional(
              end: 2,
              bottom: 2,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(color: cs.primary, shape: BoxShape.circle, border: Border.all(color: cs.surface, width: 2)),
                child: Icon(Icons.add_rounded, size: 14, color: cs.onPrimary),
              ),
            ),
        ],
      );
    }
    final text = label ?? name;
    return Semantics(
      button: onTap != null,
      label: add ? text : '$text story${live ? ', live' : (seen ? ', seen' : ', new')}',
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.tokens.md,
        child: SizedBox(
          width: w + 4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              avatar,
              if (showLabel) ...[
                const SizedBox(height: UiSpace.xs + 2),
                Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.text.labelSmall?.copyWith(
                    color: seen ? cs.onSurfaceVariant : cs.onSurface,
                    fontWeight: seen ? FontWeight.w500 : FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class UiStoryBar extends StatelessWidget {
  const UiStoryBar({
    super.key,
    required this.stories,
    this.onTap,
    this.onAdd,
    this.myName = 'You',
    this.myAvatarUrl,
    this.addLabel = 'Your story',
    this.size = 64,
    this.padding = UiSpace.page,
  });

  final List<UiStory> stories;
  final ValueChanged<int>? onTap;
  final VoidCallback? onAdd;
  final String myName;
  final String? myAvatarUrl;
  final String addLabel;
  final double size;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final lead = onAdd != null ? 1 : 0;
    final scale = MediaQuery.textScalerOf(context).scale(12) / 12;
    return SizedBox(
      height: size + 10 + UiSpace.xs + 2 + 20 * scale.clamp(1.0, 2.0),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: padding,
        itemCount: stories.length + lead,
        separatorBuilder: (_, _) => const SizedBox(width: UiSpace.sm),
        itemBuilder: (context, i) {
          if (lead == 1 && i == 0) {
            return UiStoryAvatar(name: myName, imageUrl: myAvatarUrl, add: true, label: addLabel, size: size, onTap: onAdd);
          }
          final s = stories[i - lead];
          final idx = i - lead;
          return UiStoryAvatar(
            name: s.name,
            imageUrl: s.imageUrl,
            seen: s.seen,
            live: s.live,
            size: size,
            onTap: onTap == null ? null : () => onTap!(idx),
          );
        },
      ),
    );
  }
}
