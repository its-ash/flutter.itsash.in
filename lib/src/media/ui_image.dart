import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/media/ui_shimmer.dart';
import 'package:theme/src/scroll/ui_lazy_builder.dart';

/// Image with a shimmer placeholder, fade-in and an error fallback.
///
/// `http(s)://` sources load from the network, anything else from assets.
/// The image is decoded at its display size to save memory.
///
/// ```dart
/// UiImage('https://example.com/photo.jpg', height: 200, radius: UiRadius.lg)
/// ```
class UiImage extends StatelessWidget {
  const UiImage(
    String this.src, {
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.placeholder,
    this.errorWidget,
    this.semanticLabel,
    this.lazy = false,
  }) : image = null;

  /// Shows any [ImageProvider] (memory, file, custom cache...).
  const UiImage.provider(
    ImageProvider this.image, {
    super.key,
    this.width,
    this.height,
    this.aspectRatio,
    this.fit = BoxFit.cover,
    this.radius = 0,
    this.placeholder,
    this.errorWidget,
    this.semanticLabel,
    this.lazy = false,
  }) : src = null;

  /// URL or asset path. Null when built with [UiImage.provider].
  final String? src;

  /// Image provider. Null when built from a [src] string.
  final ImageProvider? image;

  final double? width;
  final double? height;

  /// Width / height ratio. Used when only one dimension is known.
  final double? aspectRatio;

  final BoxFit fit;

  /// Corner radius. Zero means square corners.
  final double radius;

  /// Shown while loading. Defaults to a shimmer.
  final Widget? placeholder;

  /// Shown when loading fails. Defaults to an image icon on `surfaceMuted`.
  final Widget? errorWidget;

  /// Accessibility label. Without it the image is treated as decorative.
  final String? semanticLabel;

  /// When true the image only starts loading once it is near the viewport.
  final bool lazy;

  /// Resolves a `String` (URL or asset path) or an [ImageProvider] to an
  /// [ImageProvider].
  static ImageProvider resolve(Object source) {
    if (source is ImageProvider) return source;
    if (source is String) {
      final s = source.trim();
      if (s.startsWith('http://') || s.startsWith('https://')) return NetworkImage(s);
      return AssetImage(s);
    }
    throw ArgumentError.value(source, 'source', 'Expected a String or an ImageProvider');
  }

  @override
  Widget build(BuildContext context) {
    final provider = image ?? resolve(src!);
    Widget content = LayoutBuilder(builder: (context, c) => _buildImage(context, provider, c));
    if (lazy) {
      final image = content;
      content = UiLazyBuilder(
        placeholder: placeholder ?? const UiShimmerBox(),
        placeholderHeight: height ?? 200,
        builder: (_) => image,
      );
    }
    if (radius > 0) content = ClipRRect(borderRadius: UiRadius.all(radius), child: content);
    if (aspectRatio != null && (width == null || height == null)) {
      content = AspectRatio(aspectRatio: aspectRatio!, child: content);
    }
    if (width != null || height != null) content = SizedBox(width: width, height: height, child: content);
    return Semantics(image: semanticLabel != null, label: semanticLabel, excludeSemantics: true, child: content);
  }

  Widget _buildImage(BuildContext context, ImageProvider provider, BoxConstraints c) {
    final w = c.hasBoundedWidth ? c.maxWidth : null;
    final h = c.hasBoundedHeight ? c.maxHeight : null;
    final fallbackSize = Size(w ?? h ?? 64, h ?? (w != null ? w * 0.75 : 64));
    final duration = context.motion(UiMotion.slow);

    return Image(
      image: _sized(context, provider, w, h),
      width: w,
      height: h,
      fit: fit,
      gaplessPlayback: true,
      excludeFromSemantics: true,
      frameBuilder: (context, child, frame, sync) {
        if (sync) return child;
        final loaded = frame != null;
        return Stack(
          alignment: Alignment.center,
          children: [
            if (!loaded) SizedBox.fromSize(size: fallbackSize, child: placeholder ?? const UiShimmerBox()),
            AnimatedOpacity(
              key: const ValueKey('image'),
              opacity: loaded ? 1 : 0,
              duration: duration,
              curve: UiMotion.standard,
              child: child,
            ),
          ],
        );
      },
      errorBuilder: (context, error, stack) =>
          SizedBox.fromSize(size: fallbackSize, child: errorWidget ?? const _UiImageError()),
    );
  }

  /// Decodes at display size × device pixel ratio.
  ImageProvider _sized(BuildContext context, ImageProvider provider, double? w, double? h) {
    if (provider is ResizeImage) return provider;
    final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1;
    // Rounded up to 64 px steps so small layout changes reuse the cached decode.
    int? px(double? v) => v == null || !v.isFinite || v <= 0 ? null : ((v * dpr) / 64).ceil() * 64;
    if (fit == BoxFit.cover || fit == BoxFit.fitWidth || fit == BoxFit.fitHeight) {
      // Cover needs the short side of the image to fill the box. The aspect is
      // unknown before decoding, so decode the width at the box's longest side.
      final longest = [
        w,
        h,
      ].whereType<double>().where((v) => v.isFinite).fold<double?>(null, (a, b) => a == null || b > a ? b : a);
      final target = px(longest);
      if (target == null) return provider;
      return ResizeImage(provider, width: target, allowUpscaling: false);
    }
    final tw = px(w);
    final th = px(h);
    if (tw == null && th == null) return provider;
    return ResizeImage(
      provider,
      width: tw,
      height: th,
      policy: tw != null && th != null ? ResizeImagePolicy.fit : ResizeImagePolicy.exact,
      allowUpscaling: false,
    );
  }
}

class _UiImageError extends StatelessWidget {
  const _UiImageError();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ColoredBox(
      color: colors.surfaceMuted,
      child: LayoutBuilder(
        builder: (context, c) {
          final side = c.biggest.shortestSide;
          final size = (side.isFinite ? side * 0.3 : 24.0).clamp(16.0, 40.0);
          return Center(
            child: Icon(Icons.image_not_supported_outlined, size: size, color: colors.textSubtle),
          );
        },
      ),
    );
  }
}
