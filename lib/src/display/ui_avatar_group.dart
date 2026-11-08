import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_avatar.dart';

class UiAvatarGroup extends StatelessWidget {
  const UiAvatarGroup({
    super.key,
    this.images = const [],
    this.names = const [],
    this.size = 36,
    this.max = 4,
    this.total,
    this.overlap = 0.3,
    this.onTap,
  });

  final List<String?> images;
  final List<String> names;
  final double size;
  final int max;
  final int? total;
  final double overlap;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final count = math.max(images.length, names.length);
    final all = math.max(total ?? count, count);
    if (all == 0) return const SizedBox.shrink();
    final shown = math.min(count, math.max(1, max));
    final extra = all - shown;
    final step = size * (1 - overlap.clamp(0.0, 0.9));
    final tiles = shown + (extra > 0 ? 1 : 0);
    const border = 2.0;
    final d = size + border * 2;

    Widget ring(Widget child) => Container(
          width: d,
          height: d,
          padding: const EdgeInsets.all(border),
          decoration: BoxDecoration(color: cs.surface, shape: BoxShape.circle),
          child: child,
        );

    final group = SizedBox(
      width: d + step * (tiles - 1),
      height: d,
      child: Stack(
        children: [
          for (var i = 0; i < shown; i++)
            PositionedDirectional(
              start: step * i,
              child: ring(
                UiAvatar(
                  size: size,
                  imageUrl: i < images.length ? images[i] : null,
                  name: i < names.length ? names[i] : null,
                ),
              ),
            ),
          if (extra > 0)
            PositionedDirectional(
              start: step * shown,
              child: ring(
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: cs.surfaceContainerHighest, shape: BoxShape.circle),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Text(
                        '+${extra > 999 ? '999' : extra}',
                        style: context.text.labelMedium?.copyWith(fontSize: size * 0.32, fontWeight: FontWeight.w700, color: cs.onSurfaceVariant),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return Semantics(
      label: '$all people',
      button: onTap != null,
      child: ExcludeSemantics(child: onTap == null ? group : GestureDetector(onTap: onTap, child: group)),
    );
  }
}
