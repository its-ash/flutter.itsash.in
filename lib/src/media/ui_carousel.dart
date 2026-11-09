import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Page indicator style of a [UiCarousel].
enum UiCarouselIndicator { none, dots }

/// Swipeable row of cards with the neighbours peeking in, optional autoplay
/// and a dots indicator.
///
/// ```dart
/// UiCarousel(itemCount: banners.length, itemBuilder: (context, i) => UiImage(banners[i]), autoPlay: true)
/// ```
class UiCarousel extends StatefulWidget {
  const UiCarousel({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.height,
    this.aspectRatio = 16 / 9,
    this.autoPlay = false,
    this.interval = const Duration(seconds: 4),
    this.viewportFraction = 0.88,
    this.indicator = UiCarouselIndicator.dots,
    this.onPageChanged,
    this.loop = false,
    this.initialPage = 0,
    this.radius = UiRadius.lg,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  /// Fixed height of the pages. When null, [aspectRatio] of a page sets it.
  final double? height;

  /// Width / height of one page. Used when [height] is null.
  final double aspectRatio;

  /// Moves to the next page every [interval]. Pauses while the user drags.
  final bool autoPlay;
  final Duration interval;

  /// Share of the width one page takes. Below 1 the neighbours peek in.
  final double viewportFraction;

  final UiCarouselIndicator indicator;

  /// Called with the real item index when the page settles.
  final ValueChanged<int>? onPageChanged;

  /// Wraps around after the last page.
  final bool loop;

  final int initialPage;

  /// Corner radius of each page.
  final double radius;

  @override
  State<UiCarousel> createState() => _UiCarouselState();
}

class _UiCarouselState extends State<UiCarousel> {
  /// Large virtual page count used for looping.
  static const int _loopSpan = 10000;

  late PageController _controller;
  Timer? _timer;
  late int _current;

  bool get _looping => widget.loop && widget.itemCount > 1;

  int _realIndex(int page) => widget.itemCount == 0 ? 0 : page % widget.itemCount;

  @override
  void initState() {
    super.initState();
    _current = widget.itemCount == 0 ? 0 : widget.initialPage.clamp(0, widget.itemCount - 1);
    _controller = _createController();
    _startTimer();
  }

  PageController _createController() {
    final start = _looping ? (_loopSpan ~/ 2) * widget.itemCount + _current : _current;
    return PageController(initialPage: start, viewportFraction: widget.viewportFraction);
  }

  @override
  void didUpdateWidget(UiCarousel old) {
    super.didUpdateWidget(old);
    if (old.viewportFraction != widget.viewportFraction ||
        old.loop != widget.loop ||
        old.itemCount != widget.itemCount) {
      _current = widget.itemCount == 0 ? 0 : _current.clamp(0, widget.itemCount - 1);
      final previous = _controller;
      _controller = _createController();
      WidgetsBinding.instance.addPostFrameCallback((_) => previous.dispose());
    }
    if (old.autoPlay != widget.autoPlay || old.interval != widget.interval || old.itemCount != widget.itemCount) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = null;
    if (!widget.autoPlay || widget.itemCount < 2) return;
    _timer = Timer.periodic(widget.interval, (_) => _next());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  void _next() {
    if (!mounted || !_controller.hasClients) return;
    final page = _controller.page?.round() ?? _controller.initialPage;
    final duration = context.motion(UiMotion.slow * 1.6);
    if (!_looping && page >= widget.itemCount - 1) {
      _go(0, duration * 1.4, UiMotion.standard);
    } else {
      _go(page + 1, duration, Curves.easeInOutCubic);
    }
  }

  void _go(int page, Duration duration, Curve curve) {
    if (!_controller.hasClients) return;
    if (duration == Duration.zero) {
      _controller.jumpToPage(page);
    } else {
      _controller.animateToPage(page, duration: duration, curve: curve);
    }
  }

  void _onPageChanged(int page) {
    final index = _realIndex(page);
    if (index == _current) return;
    setState(() => _current = index);
    widget.onPageChanged?.call(index);
  }

  bool _onScroll(ScrollNotification n) {
    if (n.depth != 0) return false;
    if (n is ScrollStartNotification && n.dragDetails != null) _stopTimer();
    if (n is ScrollEndNotification && widget.autoPlay && _timer == null) _startTimer();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.itemCount == 0) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.hasBoundedWidth ? c.maxWidth : MediaQuery.sizeOf(context).width;
        final pageWidth = width * widget.viewportFraction - UiSpace.sm;
        final height = widget.height ?? math.max(1.0, pageWidth / widget.aspectRatio);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: height,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _looping ? _loopSpan * widget.itemCount : widget.itemCount,
                  onPageChanged: _onPageChanged,
                  padEnds: true,
                  itemBuilder: (context, page) => _page(context, page),
                ),
              ),
            ),
            if (widget.indicator == UiCarouselIndicator.dots && widget.itemCount > 1) ...[
              const SizedBox(height: UiSpace.md),
              _UiCarouselDots(
                count: widget.itemCount,
                current: _current,
                onTap: (i) {
                  final page = _controller.page?.round() ?? _controller.initialPage;
                  final target = page - _realIndex(page) + i;
                  _go(target, context.motion(UiMotion.slow), UiMotion.standard);
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _page(BuildContext context, int page) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
      child: ClipRRect(borderRadius: UiRadius.all(widget.radius), child: widget.itemBuilder(context, _realIndex(page))),
    );
    if (widget.viewportFraction >= 1) return child;
    return AnimatedBuilder(
      animation: _controller,
      child: child,
      builder: (context, child) {
        var delta = 0.0;
        if (_controller.hasClients && _controller.position.haveDimensions) {
          delta = ((_controller.page ?? page.toDouble()) - page).abs().clamp(0.0, 1.0);
        } else {
          delta = page == _controller.initialPage ? 0 : 1;
        }
        final scale = 1 - 0.06 * Curves.easeOut.transform(delta);
        return Transform.scale(scale: scale, child: child);
      },
    );
  }
}

class _UiCarouselDots extends StatelessWidget {
  const _UiCarouselDots({required this.count, required this.current, required this.onTap});

  final int count;
  final int current;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = context.motion(UiMotion.normal);
    return Semantics(
      label: 'Page ${current + 1} of $count',
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < count; i++)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onTap(i),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: UiSpace.xs),
                  child: AnimatedContainer(
                    duration: duration,
                    curve: UiMotion.standard,
                    width: i == current ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == current ? colors.accent : colors.borderStrong,
                      borderRadius: UiRadius.all(UiRadius.full),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
