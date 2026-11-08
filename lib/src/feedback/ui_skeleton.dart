import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiShimmer extends StatefulWidget {
  const UiShimmer({super.key, required this.child, this.enabled = true, this.label = 'Loading'});

  final Widget child;
  final bool enabled;
  final String label;

  @override
  State<UiShimmer> createState() => _UiShimmerState();
}

class _UiShimmerState extends State<UiShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  bool _nested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _nested = _ShimmerScope.active(context);
    _sync();
  }

  @override
  void didUpdateWidget(UiShimmer old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    final run = widget.enabled && !_nested;
    if (run && !_c.isAnimating) {
      _c.repeat();
    } else if (!run && _c.isAnimating) {
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_nested) return widget.child;
    final p = context.palette;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final child = _ShimmerScope(child: ExcludeSemantics(child: widget.child));
    if (!widget.enabled || reduce) return Semantics(label: widget.label, child: child);
    return Semantics(
      label: widget.label,
      child: AnimatedBuilder(
        animation: _c,
        child: child,
        builder: (_, c) => ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (b) => LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [p.shimmerBase, p.shimmerHighlight, p.shimmerBase],
            stops: const [0.35, 0.5, 0.65],
            transform: _Slide(_c.value),
          ).createShader(b),
          child: c,
        ),
      ),
    );
  }
}

class _Slide extends GradientTransform {
  const _Slide(this.t);

  final double t;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) => Matrix4.translationValues(bounds.width * (t * 2 - 1), 0, 0);
}

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required super.child});

  static bool active(BuildContext context) => context.getInheritedWidgetOfExactType<_ShimmerScope>() != null;

  @override
  bool updateShouldNotify(_ShimmerScope old) => false;
}

class UiSkeleton extends StatelessWidget {
  const UiSkeleton.box({super.key, this.width, this.height = 80, this.radius}) : circle = false;

  const UiSkeleton.line({super.key, this.width, this.height = 12}) : radius = null, circle = false;

  const UiSkeleton.circle({super.key, double size = 44}) : width = size, height = size, radius = null, circle = true;

  final double? width;
  final double height;
  final BorderRadius? radius;
  final bool circle;

  static Widget listTile({Key? key, bool avatar = true, int lines = 2, bool trailing = false}) => UiShimmer(
        key: key,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
          child: Row(
            children: [
              if (avatar) ...[const UiSkeleton.circle(), const UiGap.md()],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < lines.clamp(1, 4); i++) ...[
                      if (i > 0) const UiGap.sm(),
                      FractionallySizedBox(widthFactor: i == 0 ? 0.6 : 0.9, child: UiSkeleton.line(height: i == 0 ? 14 : 10)),
                    ],
                  ],
                ),
              ),
              if (trailing) ...[const UiGap.md(), const UiSkeleton.box(width: 48, height: 24)],
            ],
          ),
        ),
      );

  static Widget card({Key? key, double imageHeight = 140, int lines = 2}) => UiShimmer(
        key: key,
        child: Builder(
          builder: (c) => Container(
            padding: const EdgeInsets.all(UiSpace.md),
            decoration: BoxDecoration(
              borderRadius: c.tokens.lg,
              border: Border.all(color: c.colors.outlineVariant.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (imageHeight > 0) ...[UiSkeleton.box(height: imageHeight), const UiGap.md()],
                const FractionallySizedBox(widthFactor: 0.7, child: UiSkeleton.line(height: 16)),
                for (var i = 1; i < lines.clamp(1, 4); i++) ...[
                  const UiGap.sm(),
                  const FractionallySizedBox(widthFactor: 0.45, child: UiSkeleton.line()),
                ],
              ],
            ),
          ),
        ),
      );

  static Widget list({Key? key, int count = 5, bool avatar = true}) => UiShimmer(
        key: key,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [for (var i = 0; i < count.clamp(0, 50); i++) listTile(avatar: avatar)],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width ?? double.infinity,
      height: height < 0 ? 0 : height,
      decoration: BoxDecoration(
        color: context.palette.shimmerBase,
        shape: circle ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: circle ? null : radius ?? (height <= 16 ? context.tokens.full : context.tokens.md),
      ),
    );
    return _ShimmerScope.active(context) ? box : UiShimmer(child: box);
  }
}
