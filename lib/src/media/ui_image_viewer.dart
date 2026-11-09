import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/media/ui_image.dart';

/// Fullscreen photo viewer: pinch or double-tap to zoom, swipe between
/// images, swipe down to close.
///
/// ```dart
/// UiImageViewer.show(context, images: urls, initialIndex: 2);
/// ```
class UiImageViewer extends StatefulWidget {
  const UiImageViewer({super.key, required this.images, this.initialIndex = 0, this.heroTag});

  /// Each entry is a URL / asset path `String` or an [ImageProvider].
  final List<Object> images;
  final int initialIndex;

  /// Hero tag of the thumbnail the viewer opens from. Applied to the image at
  /// [initialIndex].
  final Object? heroTag;

  /// Opens the viewer on top of the current route. Completes when it closes.
  static Future<void> show(
    BuildContext context, {
    required List<Object> images,
    int initialIndex = 0,
    Object? heroTag,
  }) {
    if (images.isEmpty) return Future.value();
    final duration = context.motion(UiMotion.normal);
    return Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: null,
        transitionDuration: duration,
        reverseTransitionDuration: duration,
        pageBuilder: (context, animation, secondary) =>
            UiImageViewer(images: images, initialIndex: initialIndex, heroTag: heroTag),
        transitionsBuilder: (context, animation, secondary, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: UiMotion.standard),
          child: child,
        ),
      ),
    );
  }

  @override
  State<UiImageViewer> createState() => _UiImageViewerState();
}

class _UiImageViewerState extends State<UiImageViewer> with SingleTickerProviderStateMixin {
  late final PageController _pages;
  late int _index;
  bool _zoomed = false;
  bool _chrome = true;
  double _drag = 0;
  late final AnimationController _settle = AnimationController(vsync: this);
  Animation<double>? _settleAnim;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex.clamp(0, widget.images.length - 1);
    _pages = PageController(initialPage: _index);
    _settle.addListener(() {
      final a = _settleAnim;
      if (a != null) setState(() => _drag = a.value);
    });
  }

  @override
  void dispose() {
    _pages.dispose();
    _settle.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).maybePop();

  void _onDragUpdate(DragUpdateDetails d) {
    _settle.stop();
    setState(() => _drag += d.delta.dy);
  }

  void _onDragEnd(DragEndDetails d) {
    final height = MediaQuery.sizeOf(context).height;
    if (_drag.abs() > height * 0.15 || d.velocity.pixelsPerSecond.dy.abs() > 900) {
      _close();
      return;
    }
    _settle.duration = context.motion(UiMotion.normal);
    _settleAnim = Tween(begin: _drag, end: 0.0).animate(CurvedAnimation(parent: _settle, curve: UiMotion.standard));
    if (_settle.duration == Duration.zero) {
      setState(() => _drag = 0);
    } else {
      _settle.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final progress = (_drag.abs() / (height * 0.5)).clamp(0.0, 1.0);
    final count = widget.images.length;
    final fade = context.motion(UiMotion.fast);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: ColoredBox(color: Colors.black.withValues(alpha: 1 - progress * 0.8)),
          ),
          Positioned.fill(
            child: GestureDetector(
              onVerticalDragUpdate: _zoomed ? null : _onDragUpdate,
              onVerticalDragEnd: _zoomed ? null : _onDragEnd,
              onTap: () => setState(() => _chrome = !_chrome),
              child: Transform.translate(
                offset: Offset(0, _drag),
                child: Transform.scale(
                  scale: 1 - progress * 0.15,
                  child: PageView.builder(
                    controller: _pages,
                    physics: _zoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
                    itemCount: count,
                    onPageChanged: (i) => setState(() {
                      _index = i;
                      _zoomed = false;
                    }),
                    itemBuilder: (context, i) => _UiZoomablePage(
                      image: UiImage.resolve(widget.images[i]),
                      heroTag: i == widget.initialIndex ? widget.heroTag : null,
                      onZoomChanged: (z) {
                        if (z != _zoomed) setState(() => _zoomed = z);
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !_chrome,
              child: AnimatedOpacity(
                opacity: _chrome && progress < 0.05 ? 1 : 0,
                duration: fade,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withValues(alpha: 0.5), Colors.black.withValues(alpha: 0)],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.all(UiSpace.sm),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _close,
                            tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                            icon: const Icon(Icons.close_rounded, color: Colors.white),
                            style: IconButton.styleFrom(backgroundColor: Colors.white.withValues(alpha: 0.12)),
                          ),
                          Expanded(
                            child: count > 1
                                ? Text(
                                    '${_index + 1} / $count',
                                    textAlign: TextAlign.center,
                                    style: context.text.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontFeatures: const [FontFeature.tabularFigures()],
                                    ),
                                  )
                                : const SizedBox.shrink(),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UiZoomablePage extends StatefulWidget {
  const _UiZoomablePage({required this.image, required this.onZoomChanged, this.heroTag});

  final ImageProvider image;
  final Object? heroTag;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_UiZoomablePage> createState() => _UiZoomablePageState();
}

class _UiZoomablePageState extends State<_UiZoomablePage> with SingleTickerProviderStateMixin {
  final TransformationController _transform = TransformationController();
  late final AnimationController _anim = AnimationController(vsync: this);
  Animation<Matrix4>? _zoomAnim;
  Offset _tap = Offset.zero;

  @override
  void initState() {
    super.initState();
    _anim.addListener(() {
      final a = _zoomAnim;
      if (a != null) _transform.value = a.value;
    });
    _transform.addListener(_report);
  }

  @override
  void dispose() {
    _transform.removeListener(_report);
    _transform.dispose();
    _anim.dispose();
    super.dispose();
  }

  bool _lastZoomed = false;

  void _report() {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed != _lastZoomed) {
      _lastZoomed = zoomed;
      widget.onZoomChanged(zoomed);
    }
  }

  void _toggleZoom() {
    final zoomed = _transform.value.getMaxScaleOnAxis() > 1.01;
    const scale = 2.5;
    final target = zoomed
        ? Matrix4.identity()
        : (Matrix4.identity()
            ..translateByDouble(-_tap.dx * (scale - 1), -_tap.dy * (scale - 1), 0, 1)
            ..scaleByDouble(scale, scale, 1, 1));
    final duration = context.motion(UiMotion.slow);
    if (duration == Duration.zero) {
      _transform.value = target;
      return;
    }
    _anim.duration = duration;
    _zoomAnim = Matrix4Tween(
      begin: _transform.value,
      end: target,
    ).animate(CurvedAnimation(parent: _anim, curve: UiMotion.emphasized));
    _anim.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    Widget image = Image(
      image: widget.image,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : Stack(
              alignment: Alignment.center,
              children: [
                child,
                const SizedBox.square(
                  dimension: 28,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                ),
              ],
            ),
      errorBuilder: (context, error, stack) =>
          Icon(Icons.broken_image_outlined, size: 48, color: Colors.white.withValues(alpha: 0.6)),
    );
    if (widget.heroTag != null) image = Hero(tag: widget.heroTag!, child: image);
    return GestureDetector(
      onDoubleTapDown: (d) => _tap = d.localPosition,
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1,
        maxScale: 5,
        child: SizedBox.expand(child: Center(child: image)),
      ),
    );
  }
}
