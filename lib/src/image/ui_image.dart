import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiImage extends StatelessWidget {
  const UiImage(
    this.src, {
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.radius,
    this.semanticLabel,
    this.placeholderIcon = Icons.image_outlined,
  });

  final String? src;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final BoxFit fit;
  final BorderRadius? radius;
  final String? semanticLabel;
  final IconData placeholderIcon;

  bool get _isNetwork => src != null && (src!.startsWith('http://') || src!.startsWith('https://'));

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    Widget fallback([IconData? icon]) => ColoredBox(
          color: cs.surfaceContainerHighest,
          child: Center(child: Icon(icon ?? placeholderIcon, color: cs.onSurfaceVariant.withValues(alpha: 0.6))),
        );
    final s = src?.trim() ?? '';
    Widget img;
    if (s.isEmpty) {
      img = fallback();
    } else if (_isNetwork) {
      img = Image.network(
        s,
        fit: fit,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
        frameBuilder: (_, child, frame, sync) => sync
            ? child
            : AnimatedOpacity(opacity: frame == null ? 0 : 1, duration: UiDuration.normal, child: child),
        loadingBuilder: (_, child, progress) => progress == null ? child : Stack(fit: StackFit.expand, children: [fallback(), child]),
        errorBuilder: (_, _, _) => fallback(Icons.broken_image_outlined),
      );
    } else {
      img = Image.asset(
        s,
        fit: fit,
        width: width,
        height: height,
        semanticLabel: semanticLabel,
        errorBuilder: (_, _, _) => fallback(Icons.broken_image_outlined),
      );
    }
    img = SizedBox(width: width, height: height, child: img);
    if (aspectRatio != null) img = AspectRatio(aspectRatio: aspectRatio!, child: img);
    return ClipRRect(borderRadius: radius ?? BorderRadius.zero, child: img);
  }
}
