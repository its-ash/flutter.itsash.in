import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../demos/demo_route.dart';
import '../demos/shop_demo.dart';
import '../pulse/pulse_app.dart';
import '../widgets/demo_block.dart';

class AppDemosSection extends StatelessWidget {
  const AppDemosSection({super.key});

  @override
  Widget build(BuildContext context) => SectionPage(
        children: [
          DemoBlock(
            'Full app demos',
            subtitle: 'Small apps built only from theme widgets',
            child: Column(
              children: [
                UiListTile(
                  icon: Icons.favorite_rounded,
                  title: 'Pulse',
                  subtitle: 'Full app: onboarding, sign in, home, shop, fitness, wallet, social, profile',
                  onTap: () => pushPage(context, const PulseDemo(), fullscreen: true),
                ),
                UiListTile(
                  icon: Icons.storefront_rounded,
                  title: 'Shop',
                  subtitle: 'Catalog, product, cart and checkout',
                  onTap: () => pushPage(context, const ShopDemo()),
                ),
              ],
            ),
          ),
        ],
      );
}
