import 'package:flutter/material.dart';

import 'package:theme/theme.dart';
import '../showcase_tile.dart';

class NavigationSection extends StatefulWidget {
  const NavigationSection({super.key});

  @override
  State<NavigationSection> createState() => _NavigationSectionState();
}

class _NavigationSectionState extends State<NavigationSection> with SingleTickerProviderStateMixin {
  int _bottomNavIndex = 0;
  int _navBarIndex = 0;
  int _railIndex = 0;
  int _paginationPage = 4;
  late final TabController _tabController = TabController(length: 3, vsync: this);
  final _tourTargetKey = GlobalKey();

  static const _destinations = [
    ThemeNavigationDestinationItem(icon: Icons.home_outlined, selectedIcon: Icons.home, label: 'Home'),
    ThemeNavigationDestinationItem(icon: Icons.search, label: 'Search'),
    ThemeNavigationDestinationItem(icon: Icons.person_outline, selectedIcon: Icons.person, label: 'Profile'),
  ];

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      children: [
        ShowcaseTile(
          title: 'ThemeAppBar',
          child: ThemeCard(
            margin: EdgeInsets.zero,
            child: ThemeAppBar(
              title: 'Screen title',
              actions: [IconButton(icon: const Icon(Icons.more_vert), onPressed: () {})],
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeTabBar',
          child: ThemeCard(
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                ThemeTabBar(tabs: const ['One', 'Two', 'Three'], controller: _tabController),
                SizedBox(
                  height: 60,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [Center(child: Text('Tab 1')), Center(child: Text('Tab 2')), Center(child: Text('Tab 3'))],
                  ),
                ),
              ],
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeBottomNavigationBar',
          child: ThemeCard(
            margin: EdgeInsets.zero,
            child: ThemeBottomNavigationBar(
              currentIndex: _bottomNavIndex,
              onTap: (i) => setState(() => _bottomNavIndex = i),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Wishlist'),
                BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
              ],
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeNavigationBar',
          description: 'Material 3 pill-indicator bottom bar',
          child: ThemeCard(
            margin: EdgeInsets.zero,
            child: ThemeNavigationBar(
              destinations: _destinations,
              selectedIndex: _navBarIndex,
              onDestinationSelected: (i) => setState(() => _navBarIndex = i),
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeNavigationRail',
          child: SizedBox(
            height: 260,
            child: ThemeCard(
              margin: EdgeInsets.zero,
              child: ThemeNavigationRail(
                destinations: _destinations,
                selectedIndex: _railIndex,
                onDestinationSelected: (i) => setState(() => _railIndex = i),
              ),
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeBottomAppBar',
          child: ThemeCard(
            margin: EdgeInsets.zero,
            child: ThemeBottomAppBar(
              children: [
                IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
                IconButton(icon: const Icon(Icons.search), onPressed: () {}),
                IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
                IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
              ],
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeDrawer',
          child: SizedBox(
            height: 300,
            width: 280,
            child: ThemeDrawer(
              children: [
                const DrawerHeader(child: Text('Menu')),
                ListTile(leading: const Icon(Icons.home_outlined), title: const Text('Home'), onTap: () {}),
                ListTile(leading: const Icon(Icons.settings_outlined), title: const Text('Settings'), onTap: () {}),
              ],
            ),
          ),
        ),
        ShowcaseTile(
          title: 'ThemePagination',
          child: ThemePagination(
            currentPage: _paginationPage,
            totalPages: 12,
            onPageChanged: (p) => setState(() => _paginationPage = p),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeBreadcrumbs',
          child: ThemeBreadcrumbs(
            items: [
              ThemeBreadcrumbItem(label: 'Home', onTap: () {}),
              ThemeBreadcrumbItem(label: 'Settings', onTap: () {}),
              const ThemeBreadcrumbItem(label: 'Profile'),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeOnboardingTour',
          description: 'Spotlight coachmarks that advance through a list of steps',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeButton(
                key: _tourTargetKey,
                label: 'Start tour',
                onPressed: () => ThemeOnboardingTour.show(
                  context,
                  steps: [
                    ThemeOnboardingStep(
                      key: _tourTargetKey,
                      title: 'Start here',
                      description: 'This button kicks off the guided tour.',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
