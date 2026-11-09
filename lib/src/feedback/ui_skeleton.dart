import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Drives one shimmer animation for every [UiSkeleton] below it.
///
/// Skeletons without a [UiShimmer] ancestor create their own. Wrap a whole
/// placeholder screen in one [UiShimmer] so all parts move in sync. The
/// shimmer stops when the user asks for reduced motion.
class UiShimmer extends StatefulWidget {
  const UiShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<UiShimmer> createState() => _UiShimmerState();
}

class _UiShimmerState extends State<UiShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1500),
  );
  bool _animate = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _animate = !(MediaQuery.maybeDisableAnimationsOf(context) ?? false);
    if (_animate) {
      if (!_controller.isAnimating) _controller.repeat();
    } else {
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
    return _ShimmerScope(animation: _controller, animate: _animate, child: widget.child);
  }
}

class _ShimmerScope extends InheritedWidget {
  const _ShimmerScope({required this.animation, required this.animate, required super.child});

  final Animation<double> animation;
  final bool animate;

  static _ShimmerScope? maybeOf(BuildContext context) => context.dependOnInheritedWidgetOfExactType<_ShimmerScope>();

  @override
  bool updateShouldNotify(_ShimmerScope old) => old.animation != animation || old.animate != animate;
}

enum _SkeletonKind { box, text, circle }

/// Placeholder shape shown while content loads.
///
/// ```dart
/// UiSkeleton.text(lines: 2)
/// UiSkeleton.circle(size: 48)
/// UiSkeleton.box(height: 160)
/// ```
class UiSkeleton extends StatelessWidget {
  /// A single bar, like one line of text.
  const UiSkeleton({super.key, this.width, this.height = 14, this.radius = UiRadius.xs})
    : _kind = _SkeletonKind.box,
      lines = 1;

  /// A block, like an image or card. Fills the width by default.
  const UiSkeleton.box({super.key, this.width, this.height = 120, this.radius = UiRadius.md})
    : _kind = _SkeletonKind.box,
      lines = 1;

  /// A paragraph of [lines] bars; the last one is shorter.
  const UiSkeleton.text({super.key, this.lines = 3, this.height = 12})
    : _kind = _SkeletonKind.text,
      width = null,
      radius = UiRadius.xs;

  /// A circle, like an avatar.
  const UiSkeleton.circle({super.key, double size = 40})
    : _kind = _SkeletonKind.circle,
      width = size,
      height = size,
      radius = UiRadius.full,
      lines = 1;

  final _SkeletonKind _kind;

  /// Width. Null fills the available width.
  final double? width;

  /// Height of the shape, or of each line for [UiSkeleton.text].
  final double height;
  final double radius;
  final int lines;

  @override
  Widget build(BuildContext context) {
    final Widget content = switch (_kind) {
      _SkeletonKind.box => _Bone(width: width ?? double.infinity, height: height, radius: radius),
      _SkeletonKind.circle => _Bone(width: height, height: height, circle: true),
      _SkeletonKind.text => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < lines; i++) ...[
            if (i > 0) const SizedBox(height: UiSpace.sm),
            FractionallySizedBox(
              widthFactor: lines > 1 && i == lines - 1 ? 0.6 : 1,
              child: _Bone(width: double.infinity, height: height, radius: radius),
            ),
          ],
        ],
      ),
    };
    final hasScope = _ShimmerScope.maybeOf(context) != null;
    return hasScope ? content : UiShimmer(child: content);
  }
}

class _Bone extends StatelessWidget {
  const _Bone({required this.width, required this.height, this.radius = UiRadius.xs, this.circle = false});

  final double width;
  final double height;
  final double radius;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final scope = _ShimmerScope.maybeOf(context);
    BoxDecoration deco(Gradient? gradient) => BoxDecoration(
      color: gradient == null ? c.shimmerBase : null,
      gradient: gradient,
      shape: circle ? BoxShape.circle : BoxShape.rectangle,
      borderRadius: circle ? null : UiRadius.all(radius),
    );

    Widget child;
    if (scope == null || !scope.animate) {
      child = DecoratedBox(decoration: deco(null));
    } else {
      child = AnimatedBuilder(
        animation: scope.animation,
        builder: (context, _) {
          final x = -2 + 4 * scope.animation.value;
          return DecoratedBox(
            decoration: deco(
              LinearGradient(
                begin: Alignment(x - 1, -0.3),
                end: Alignment(x + 1, 0.3),
                colors: [c.shimmerBase, c.shimmerHighlight, c.shimmerBase],
              ),
            ),
          );
        },
      );
    }
    return SizedBox(width: width, height: height, child: child);
  }
}

/// Placeholder for a list: rows with an avatar circle and text lines.
///
/// ```dart
/// if (loading) const UiSkeletonList(count: 6)
/// ```
class UiSkeletonList extends StatelessWidget {
  const UiSkeletonList({
    super.key,
    this.count = 4,
    this.avatar = true,
    this.lines = 2,
    this.padding = const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
  });

  /// Number of rows.
  final int count;

  /// Shows a leading circle on each row.
  final bool avatar;

  /// Text lines per row, including the title line.
  final int lines;

  /// Padding of each row.
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Loading',
      child: ExcludeSemantics(
        child: UiShimmer(
          child: ClipRect(
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < count; i++)
                    Padding(
                      padding: padding,
                      child: Row(
                        children: [
                          if (avatar) ...[const UiSkeleton.circle(size: 40), const SizedBox(width: UiSpace.md)],
                          Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const FractionallySizedBox(widthFactor: 0.5, child: UiSkeleton(height: 14)),
                                if (lines > 1) ...[
                                  const SizedBox(height: UiSpace.sm),
                                  UiSkeleton.text(lines: lines - 1, height: 10),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
