import 'package:flutter/material.dart';

import 'package:theme/theme.dart';

class ThemeSectionHeader extends StatelessWidget {
  const ThemeSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel = 'See all',
    this.onAction,
  });

  final String title;
  final String? subtitle;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final shadows = Theme.of(context).extension<AppShadowTheme>() ?? const AppShadowTheme();
    final displayTitle =
        shadows.textTransform == ThemeTextTransform.uppercase ? title.toUpperCase() : title;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(displayTitle, style: AppTypography.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onAction != null)
          TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class ThemeBannerCarousel extends StatelessWidget {
  const ThemeBannerCarousel({super.key, required this.banners, this.onTap});

  final List<ThemeBannerCarouselItem> banners;
  final ValueChanged<int>? onTap;

  double _cardRadius(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 20;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        itemCount: banners.length,
        padEnds: true,
        itemBuilder: (context, index) {
          final banner = banners[index];
          return GestureDetector(
            onTap: () => onTap?.call(index),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: banner.colors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(_cardRadius(context)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    banner.title,
                    style: AppTypography.headlineSmall.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    banner.subtitle,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(_cardRadius(context)),
                    ),
                    child: Text(
                      banner.ctaLabel,
                      style: AppTypography.labelLarge.copyWith(
                        color: banner.colors.first,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class ThemeBannerCarouselItem {
  const ThemeBannerCarouselItem({
    required this.title,
    required this.subtitle,
    required this.ctaLabel,
    required this.colors,
  });

  final String title;
  final String subtitle;
  final String ctaLabel;
  final List<Color> colors;
}
