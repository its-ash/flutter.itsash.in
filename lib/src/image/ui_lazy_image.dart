import 'package:flutter/material.dart';

import 'package:theme/src/feedback/ui_skeleton.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/scroll/ui_scroll_helpers.dart';

class UiLazyImage extends StatelessWidget {
  const UiLazyImage(
    this.src, {
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.radius,
    this.semanticLabel,
    this.placeholder,
    this.errorWidget,
    this.lazy = true,
    this.margin = 300,
    this.fadeDuration = UiDuration.normal,
    this.placeholderIcon = Icons.broken_image_outlined,
    this.headers,
  });

  final String? src;
  final double? width;
  final double? height;
  final double? aspectRatio;
  final BoxFit fit;
  final BorderRadius? radius;
  final String? semanticLabel;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool lazy;
  final double margin;
  final Duration fadeDuration;
  final IconData placeholderIcon;
  final Map<String, String>? headers;

  static bool _isNetwork(String s) => s.startsWith('http://') || s.startsWith('https://');

  Widget _shimmer() => placeholder ?? const UiSkeleton.box(height: double.infinity, radius: BorderRadius.zero);

  Widget _image(BuildContext context, BoxConstraints box) {
    final cs = context.colors;
    final s = src?.trim() ?? '';
    final fallback = errorWidget ??
        ColoredBox(
          color: cs.surfaceContainerHighest,
          child: Center(child: Icon(placeholderIcon, color: cs.onSurfaceVariant.withValues(alpha: 0.6))),
        );
    if (s.isEmpty) return fallback;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final w = width ?? (box.hasBoundedWidth ? box.maxWidth : null);
    final cacheW = w != null && w.isFinite && w > 0 ? (w * dpr).round() : null;
    final ImageProvider base = _isNetwork(s) ? NetworkImage(s, headers: headers) : AssetImage(s);
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Image(
      image: ResizeImage.resizeIfNeeded(cacheW, null, base),
      fit: fit,
      width: width,
      height: height,
      semanticLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
      gaplessPlayback: true,
      frameBuilder: (_, child, frame, sync) {
        if (sync) return child;
        return Stack(
          fit: StackFit.passthrough,
          children: [
            Positioned.fill(child: ColoredBox(color: cs.surfaceContainerHighest)),
            if (frame == null) Positioned.fill(child: _shimmer()),
            AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: reduce ? Duration.zero : fadeDuration,
              curve: UiCurve.standard,
              child: child,
            ),
          ],
        );
      },
      errorBuilder: (_, _, _) => fallback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = LayoutBuilder(builder: _image);
    Widget core = image;
    if (lazy) {
      core = UiLazyBuilder(
        margin: margin,
        placeholder: LayoutBuilder(
          builder: (_, c) => SizedBox(
            width: c.hasBoundedWidth ? c.maxWidth : width ?? 0,
            height: c.hasBoundedHeight ? c.maxHeight : height ?? 200,
            child: _shimmer(),
          ),
        ),
        builder: (_) => image,
      );
    }
    final ar = aspectRatio;
    Widget out = SizedBox(width: width, height: height, child: core);
    if (ar != null && ar.isFinite && ar > 0) out = AspectRatio(aspectRatio: ar, child: out);
    return ClipRRect(borderRadius: radius ?? BorderRadius.zero, child: out);
  }
}
