import 'package:flutter/material.dart';

import 'package:theme/theme.dart';
import '../showcase_tile.dart';

class LayoutSection extends StatelessWidget {
  const LayoutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      children: [
        ShowcaseTile(
          title: 'ThemeSectionHeader',
          child: ThemeSectionHeader(
            title: 'Featured',
            subtitle: 'Hand-picked for you',
            onAction: () {},
          ),
        ),
        ShowcaseTile(
          title: 'ThemeBannerCarousel',
          child: ThemeBannerCarousel(
            onTap: (_) {},
            banners: const [
              ThemeBannerCarouselItem(
                title: 'Summer sale',
                subtitle: 'Up to 40% off',
                ctaLabel: 'Shop now',
                colors: [Color(0xFF1976D2), Color(0xFF42A5F5)],
              ),
              ThemeBannerCarouselItem(
                title: 'New arrivals',
                subtitle: 'Fresh drops weekly',
                ctaLabel: 'Explore',
                colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
              ),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeSplitPanel',
          description: 'Drag the divider to resize',
          child: SizedBox(
            height: 160,
            child: ThemeSplitPanel(
              first: ColoredBox(color: Theme.of(context).colorScheme.primaryContainer),
              second: ColoredBox(color: Theme.of(context).colorScheme.secondaryContainer),
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeMasonryGrid',
          child: ThemeMasonryGrid(
            crossAxisCount: 3,
            children: [
              for (final h in const [60.0, 100.0, 80.0, 120.0, 70.0, 90.0])
                Container(
                  height: h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
