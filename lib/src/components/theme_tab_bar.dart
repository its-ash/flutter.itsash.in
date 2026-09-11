import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

class ThemeTabBar extends StatelessWidget implements PreferredSizeWidget {
  const ThemeTabBar({super.key, required this.tabs, this.controller});

  final List<String> tabs;
  final TabController? controller;

  @override
  Widget build(BuildContext context) {
    final shadows = Theme.of(context).extension<AppShadowTheme>() ?? const AppShadowTheme();
    final uppercase = shadows.textTransform == ThemeTextTransform.uppercase;
    return TabBar(
      controller: controller,
      tabs: tabs.map((t) => Tab(text: uppercase ? t.toUpperCase() : t)).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kTextTabBarHeight);
}
