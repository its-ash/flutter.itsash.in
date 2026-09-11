import 'package:flutter/material.dart';
import 'package:theme/src/widgets/theme_shimmer.dart';

enum ThemeSkeletonType {
  textLine,
  circleAvatar,
  card,
  listTile,
  gridTile,
  banner,
  paragraph,
}

class ThemeSkeleton extends StatelessWidget {
  const ThemeSkeleton({super.key, this.type = ThemeSkeletonType.textLine, this.width, this.height, this.borderRadius});

  final ThemeSkeletonType type;
  final double? width;
  final double? height;

  /// Corner radius for the underlying shimmer block(s). Defaults to the
  /// active theme's card radius — pass an explicit value to opt out.
  /// `circleAvatar` (and the listTile leading avatar) ignore this: they're
  /// inherently circular by design, not a theme radius bug.
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case ThemeSkeletonType.textLine:
        return ThemeShimmer(width: width ?? double.infinity, height: height ?? 14, borderRadius: borderRadius);
      case ThemeSkeletonType.circleAvatar:
        return SizedBox(width: width ?? 48, height: height ?? 48, child: ThemeShimmer(borderRadius: (width ?? 48) / 2));
      case ThemeSkeletonType.card:
        return SizedBox(
          width: width ?? double.infinity,
          height: height ?? 120,
          child: ThemeShimmer(borderRadius: borderRadius),
        );
      case ThemeSkeletonType.listTile:
        return Row(children: [
          ThemeShimmer(width: 48, height: 48, borderRadius: 24),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ThemeShimmer(width: 140, height: 14, borderRadius: borderRadius),
            const SizedBox(height: 8),
            ThemeShimmer(height: 12, borderRadius: borderRadius),
          ])),
        ]);
      case ThemeSkeletonType.gridTile:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ThemeShimmer(width: width ?? double.infinity, height: height ?? 120, borderRadius: borderRadius),
          const SizedBox(height: 8),
          ThemeShimmer(width: 100, height: 12, borderRadius: borderRadius),
        ]);
      case ThemeSkeletonType.banner:
        return ThemeShimmer(width: width ?? double.infinity, height: height ?? 80, borderRadius: borderRadius);
      case ThemeSkeletonType.paragraph:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ThemeShimmer(width: width ?? double.infinity, height: 14, borderRadius: borderRadius),
          const SizedBox(height: 6),
          ThemeShimmer(width: 240, height: 14, borderRadius: borderRadius),
          const SizedBox(height: 6),
          ThemeShimmer(height: 14, borderRadius: borderRadius),
        ]);
    }
  }
}

class ThemeSkeletonLoader extends StatelessWidget {
  const ThemeSkeletonLoader({super.key, this.type = ThemeSkeletonType.listTile, this.count = 6, this.spacing = 12});

  final ThemeSkeletonType type;
  final int count;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.zero,
      itemCount: count,
      separatorBuilder: (_, __) => SizedBox(height: spacing),
      itemBuilder: (_, __) => ThemeSkeleton(type: type),
    );
  }
}