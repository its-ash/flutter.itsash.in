import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class ThemeLazyImage extends StatefulWidget {
  const ThemeLazyImage({
    super.key,
    required this.src,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.cacheWidth,
    this.cacheHeight,
    this.fadeDuration = const Duration(milliseconds: 300),
  });

  final Object src;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  /// Corner radius for the image and its placeholder/error states.
  /// Defaults to the active theme's card radius (`Theme.of(context)
  /// .cardTheme.shape`) so images go square in brutalism/maximalism-style
  /// presets along with everything else — pass an explicit value to opt out.
  final double? borderRadius;
  final int? cacheWidth;
  final int? cacheHeight;
  final Duration fadeDuration;

  @override
  State<ThemeLazyImage> createState() => _ThemeLazyImageState();
}

class _ThemeLazyImageState extends State<ThemeLazyImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade = AnimationController(
    vsync: this,
    duration: widget.fadeDuration,
  );
  bool _errored = false;
  bool _loaded = false;

  @override
  void dispose() {
    _fade.dispose();
    super.dispose();
  }

  ImageProvider _provider() {
    final s = widget.src;
    final base = switch (s) {
      String() when s.startsWith('http') => NetworkImage(s),
      String() => AssetImage(s) as ImageProvider,
      _ => MemoryImage(s as Uint8List),
    };
    // ResizeImage asserts at least one dimension is set — only wrap when the
    // caller actually opted into cache-size downscaling.
    if (widget.cacheWidth == null && widget.cacheHeight == null) return base;
    return ResizeImage(base, width: widget.cacheWidth, height: widget.cacheHeight);
  }

  double _radius(BuildContext context) {
    if (widget.borderRadius != null) return widget.borderRadius!;
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = _radius(context);
    final placeholder = widget.placeholder ??
        Container(
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(radius),
          ),
        );

    if (_errored) {
      return widget.errorWidget ??
          ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              width: widget.width,
              height: widget.height,
              color: scheme.surfaceContainerHigh,
              child: Icon(Icons.broken_image_outlined, color: scheme.outline),
            ),
          );
    }

    final image = Image(
      image: _provider(),
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        // `child` (the actual RawImage) must always stay in the tree —
        // swapping it out for an unrelated widget while frame == null tears
        // down its element and breaks the decode-listener lifecycle, so
        // only ever change how it's wrapped, never whether it's present.
        if (wasSynchronouslyLoaded || frame != null) {
          if (!_loaded) {
            _loaded = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _fade.forward();
            });
          }
          return FadeTransition(opacity: _fade, child: child);
        }
        // Still decoding the first frame. With an explicit width/height we
        // can overlay a properly-sized placeholder; without one there's
        // nothing to size it to, so just hide the (zero-sized) child until
        // its natural size is known.
        return widget.width == null && widget.height == null
            ? Visibility(visible: false, maintainState: true, maintainAnimation: true, maintainSize: true, child: child)
            : Stack(fit: StackFit.passthrough, children: [placeholder, Opacity(opacity: 0, child: child)]);
      },
      errorBuilder: (_, __, ___) {
        if (!_errored) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _errored = true);
          });
        }
        return const SizedBox.shrink();
      },
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: widget.width == null && widget.height == null
          ? image
          : SizedBox(width: widget.width, height: widget.height, child: image),
    );
  }
}