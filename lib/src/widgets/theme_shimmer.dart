import 'package:flutter/material.dart';

class ThemeShimmer extends StatefulWidget {
  const ThemeShimmer({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  final double? width;
  final double height;

  /// Corner radius for the shimmer block. Defaults to the active theme's
  /// card radius (`Theme.of(context).cardTheme.shape`) — pass an explicit
  /// value to opt out.
  final double? borderRadius;

  @override
  State<ThemeShimmer> createState() => _ThemeShimmerState();
}

class _ThemeShimmerState extends State<ThemeShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _radius(BuildContext context) {
    if (widget.borderRadius != null) return widget.borderRadius!;
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final base = scheme.onSurface.withValues(alpha: 0.08);
    final highlight = scheme.onSurface.withValues(alpha: 0.16);

    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius(context)),
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1 + _controller.value * 3, 0),
                  end: Alignment(_controller.value * 3, 0),
                  colors: [base, highlight, base],
                  stops: const [0.35, 0.5, 0.65],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class ThemeShimmerList extends StatelessWidget {
  const ThemeShimmerList({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 64,
    this.spacing = 12,
  });

  final int itemCount;
  final double itemHeight;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: itemCount,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (_, __) => ThemeShimmer(width: double.infinity, height: itemHeight),
    );
  }
}
