import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Internal shimmer block used as a loading placeholder by media, scroll and
/// chart widgets. Not exported from the package.
class UiShimmerBox extends StatefulWidget {
  const UiShimmerBox({super.key, this.width, this.height, this.radius = 0});

  final double? width;
  final double? height;
  final double radius;

  @override
  State<UiShimmerBox> createState() => _UiShimmerBoxState();
}

class _UiShimmerBoxState extends State<UiShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animate = context.motion(UiMotion.normal) > Duration.zero;
    if (animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: widget.radius > 0 ? UiRadius.all(widget.radius) : null,
          gradient: LinearGradient(
            colors: [colors.shimmerBase, colors.shimmerHighlight, colors.shimmerBase],
            stops: const [0.3, 0.5, 0.7],
            transform: _SlideGradient(_controller.value),
          ),
        ),
      ),
    );
  }
}

class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.t);

  final double t;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * (t * 2 - 1), 0, 0);
}
