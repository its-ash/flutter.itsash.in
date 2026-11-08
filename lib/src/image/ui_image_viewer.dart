import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_image.dart';

class UiImageViewer extends StatefulWidget {
  const UiImageViewer(this.urls, {super.key, this.initialIndex = 0});

  final List<String> urls;
  final int initialIndex;

  static Future<void> open(BuildContext context, List<String> urls, {int initialIndex = 0}) {
    final list = [for (final u in urls) if (u.trim().isNotEmpty) u];
    if (list.isEmpty) return Future.value();
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: UiDuration.normal,
        reverseTransitionDuration: UiDuration.normal,
        pageBuilder: (_, _, _) => UiImageViewer(list, initialIndex: initialIndex),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
  }

  @override
  State<UiImageViewer> createState() => _UiImageViewerState();
}

class _UiImageViewerState extends State<UiImageViewer> {
  late int _i = widget.urls.isEmpty ? 0 : widget.initialIndex.clamp(0, widget.urls.length - 1);
  late final PageController _ctrl = PageController(initialPage: _i);
  bool _zoomed = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.urls.length;
    final close = MaterialLocalizations.of(context).closeButtonTooltip;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: n == 0
                ? const SizedBox.shrink()
                : PageView.builder(
                    controller: _ctrl,
                    itemCount: n,
                    physics: _zoomed ? const NeverScrollableScrollPhysics() : const PageScrollPhysics(),
                    onPageChanged: (i) => setState(() {
                      _i = i;
                      _zoomed = false;
                    }),
                    itemBuilder: (_, i) => _ZoomImage(
                      widget.urls[i],
                      label: 'Image ${i + 1} of $n',
                      onZoom: (z) {
                        if (z != _zoomed && mounted) setState(() => _zoomed = z);
                      },
                    ),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(UiSpace.sm),
              child: Row(
                children: [
                  IconButton(
                    tooltip: close,
                    onPressed: () => Navigator.maybePop(context),
                    style: IconButton.styleFrom(backgroundColor: Colors.black54, foregroundColor: Colors.white),
                    icon: const Icon(Icons.close_rounded),
                  ),
                  const Spacer(),
                  if (n > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.xs + 2),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: context.tokens.full),
                      child: Text(
                        '${_i + 1} / $n',
                        style: context.text.labelLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomImage extends StatefulWidget {
  const _ZoomImage(this.url, {required this.label, required this.onZoom});

  final String url;
  final String label;
  final ValueChanged<bool> onZoom;

  @override
  State<_ZoomImage> createState() => _ZoomImageState();
}

class _ZoomImageState extends State<_ZoomImage> with SingleTickerProviderStateMixin {
  final _tc = TransformationController();
  late final AnimationController _anim = AnimationController(vsync: this, duration: UiDuration.normal)..addListener(_tick);
  Animation<Matrix4>? _tween;
  Offset _tap = Offset.zero;

  void _tick() {
    final t = _tween;
    if (t != null) _tc.value = t.value;
  }

  void _report() => widget.onZoom(_tc.value.getMaxScaleOnAxis() > 1.01);

  void _animateTo(Matrix4 m) {
    _tween = Matrix4Tween(begin: _tc.value, end: m).animate(CurvedAnimation(parent: _anim, curve: UiCurve.standard));
    _anim.forward(from: 0).then((_) {
      if (mounted) _report();
    });
  }

  void _toggle() {
    if (_tc.value.getMaxScaleOnAxis() > 1.01) {
      _animateTo(Matrix4.identity());
    } else {
      const s = 2.5;
      _animateTo(Matrix4.diagonal3Values(s, s, 1)..setTranslationRaw(-_tap.dx * (s - 1), -_tap.dy * (s - 1), 0));
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    _tc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
        image: true,
        label: widget.label,
        child: GestureDetector(
          onDoubleTapDown: (d) => _tap = d.localPosition,
          onDoubleTap: _toggle,
          child: InteractiveViewer(
            transformationController: _tc,
            minScale: 1,
            maxScale: 5,
            onInteractionStart: (_) => _anim.stop(),
            onInteractionEnd: (_) => _report(),
            child: SizedBox.expand(
              child: LayoutBuilder(
                builder: (_, box) => Center(
                  child: UiImage(
                    widget.url,
                    fit: BoxFit.contain,
                    width: box.maxWidth,
                    height: box.maxHeight,
                    placeholderIcon: Icons.image_outlined,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}

class UiImageGrid extends StatelessWidget {
  const UiImageGrid(
    this.urls, {
    super.key,
    this.max = 4,
    this.spacing = 4,
    this.radius,
    this.height = 220,
    this.aspectRatio,
    this.onTap,
    this.onDoubleTap,
  });

  final List<String> urls;
  final int max;
  final double spacing;
  final BorderRadius? radius;
  final double height;
  final double? aspectRatio;
  final ValueChanged<int>? onTap;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    final list = [for (final u in urls) if (u.trim().isNotEmpty) u];
    if (list.isEmpty) return const SizedBox.shrink();
    final r = radius ?? context.tokens.md;
    final cap = max.clamp(1, 4);
    final shown = math.min(list.length, cap);
    final extra = list.length - shown;

    Widget tile(int i) {
      final last = i == shown - 1 && extra > 0;
      return Expanded(
        child: Semantics(
          button: true,
          label: last ? 'Image ${i + 1}, $extra more' : 'Image ${i + 1} of ${list.length}',
          child: GestureDetector(
            onTap: () => onTap != null ? onTap!(i) : UiImageViewer.open(context, list, initialIndex: i),
            onDoubleTap: onDoubleTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                UiImage(list[i], width: double.infinity, height: double.infinity),
                if (last)
                  ColoredBox(
                    color: Colors.black.withValues(alpha: 0.5),
                    child: Center(
                      child: Text(
                        '+$extra',
                        style: context.text.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    final gap = SizedBox(width: spacing, height: spacing);
    final body = switch (shown) {
      1 => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [tile(0)]),
      2 => Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [tile(0), gap, tile(1)]),
      3 => Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            tile(0),
            gap,
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [tile(1), gap, tile(2)])),
          ],
        ),
      _ => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [tile(0), gap, tile(1)])),
            gap,
            Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [tile(2), gap, tile(3)])),
          ],
        ),
    };
    final clip = ClipRRect(borderRadius: r, child: body);
    final ar = aspectRatio;
    return ar != null && ar.isFinite && ar > 0 ? AspectRatio(aspectRatio: ar, child: clip) : SizedBox(height: height, child: clip);
  }
}
