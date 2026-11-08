import 'dart:async';

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/navigation/ui_indicators.dart';
import 'package:theme/src/image/ui_image.dart';

class UiCarousel extends StatefulWidget {
  const UiCarousel({
    super.key,
    required this.children,
    this.height = 180,
    this.viewportFraction = 0.9,
    this.autoplay = false,
    this.interval = const Duration(seconds: 4),
    this.dots = true,
    this.radius,
    this.onChanged,
    this.initialIndex = 0,
  }) : onTap = null;

  UiCarousel.images(
    List<String> urls, {
    super.key,
    this.height = 180,
    this.viewportFraction = 0.9,
    this.autoplay = false,
    this.interval = const Duration(seconds: 4),
    this.dots = true,
    this.radius,
    this.onChanged,
    this.onTap,
    this.initialIndex = 0,
  }) : children = [for (final u in urls) UiImage(u, width: double.infinity, height: double.infinity)];

  final List<Widget> children;
  final double height;
  final double viewportFraction;
  final bool autoplay;
  final Duration interval;
  final bool dots;
  final BorderRadius? radius;
  final ValueChanged<int>? onChanged;
  final ValueChanged<int>? onTap;
  final int initialIndex;

  @override
  State<UiCarousel> createState() => _UiCarouselState();
}

class _UiCarouselState extends State<UiCarousel> {
  late int _i = widget.children.isEmpty ? 0 : widget.initialIndex.clamp(0, widget.children.length - 1);
  late PageController _ctrl = _make();
  Timer? _timer;

  PageController _make() => PageController(viewportFraction: widget.viewportFraction.clamp(0.3, 1.0), initialPage: _i);

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(UiCarousel old) {
    super.didUpdateWidget(old);
    if (widget.children.isNotEmpty && _i >= widget.children.length) _i = widget.children.length - 1;
    if (old.viewportFraction != widget.viewportFraction) {
      final prev = _ctrl;
      _ctrl = _make();
      WidgetsBinding.instance.addPostFrameCallback((_) => prev.dispose());
    }
    if (old.autoplay != widget.autoplay || old.interval != widget.interval || old.children.length != widget.children.length) _start();
  }

  void _start() {
    _timer?.cancel();
    _timer = null;
    final ms = widget.interval.inMilliseconds;
    if (!widget.autoplay || widget.children.length < 2 || ms < 500) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || !_ctrl.hasClients) return;
      final n = widget.children.length;
      if (n < 2) return;
      _ctrl.animateToPage((_i + 1) % n, duration: UiDuration.slow, curve: UiCurve.emphasized);
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final n = widget.children.length;
    if (n == 0) return SizedBox(height: widget.height);
    final r = widget.radius ?? context.tokens.lg;
    final gap = widget.viewportFraction < 1 ? UiSpace.xs + 2 : 0.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: widget.height,
          child: Listener(
            onPointerDown: (_) => _stop(),
            onPointerUp: (_) => _start(),
            onPointerCancel: (_) => _start(),
            child: PageView.builder(
              controller: _ctrl,
              itemCount: n,
              onPageChanged: (i) {
                setState(() => _i = i);
                widget.onChanged?.call(i);
              },
              itemBuilder: (_, i) {
                final tile = ClipRRect(borderRadius: r, child: widget.children[i]);
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: gap),
                  child: widget.onTap == null
                      ? tile
                      : Semantics(
                          button: true,
                          label: 'Image ${i + 1} of $n',
                          child: GestureDetector(onTap: () => widget.onTap!(i), child: tile),
                        ),
                );
              },
            ),
          ),
        ),
        if (widget.dots && n > 1) ...[
          const UiGap.md(),
          UiPageDots(count: n, index: _i, controller: _ctrl, size: 6, activeWidth: 18),
        ],
      ],
    );
  }
}
