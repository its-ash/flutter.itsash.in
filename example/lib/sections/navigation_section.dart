import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../demos/demo_route.dart';
import '../widgets/demo_block.dart';

const navItems = [
  UiNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
  UiNavItem(icon: Icons.search_rounded, label: 'Search'),
  UiNavItem(icon: Icons.favorite_border_rounded, selectedIcon: Icons.favorite_rounded, label: 'Saved', badge: ''),
  UiNavItem(icon: Icons.shopping_bag_outlined, selectedIcon: Icons.shopping_bag_rounded, label: 'Cart', badge: '3'),
  UiNavItem(icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded, label: 'Profile'),
];

class NavigationSection extends StatefulWidget {
  const NavigationSection({super.key});

  @override
  State<NavigationSection> createState() => _NavigationSectionState();
}

class _NavigationSectionState extends State<NavigationSection> {
  final _pages = PageController();
  int _tab = 0;
  int _bottom = 0;
  int _floating = 1;
  int _step = 1;
  int _drawer = 0;
  int _page = 0;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  Widget _pane(BuildContext context, String label, IconData icon) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [Icon(icon, size: 40, color: context.colors.primary), const UiGap.sm(), Text(label)],
        ),
      );

  Widget _frame(BuildContext context, double height, Widget child) => ClipRRect(
        borderRadius: context.tokens.lg,
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: Border.all(color: context.colors.outlineVariant),
            borderRadius: context.tokens.lg,
          ),
          child: SizedBox(height: height, child: child),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final pages = [
      for (final n in navItems) _pane(context, n.label, n.selectedIcon ?? n.icon),
    ];
    return SectionPage(
      children: [
        DemoBlock(
          'UiTabView',
          child: UiTabView(
            height: 160,
            barPadding: EdgeInsets.zero,
            tabs: const ['All', 'Shoes', 'Bags', 'Watches', 'Hats'],
            icons: const [Icons.apps_rounded, Icons.ice_skating_rounded, Icons.work_rounded, Icons.watch_rounded, Icons.face_rounded],
            children: [
              _pane(context, 'All', Icons.apps_rounded),
              _pane(context, 'Shoes', Icons.ice_skating_rounded),
              _pane(context, 'Bags', Icons.work_rounded),
              _pane(context, 'Watches', Icons.watch_rounded),
              _pane(context, 'Hats', Icons.face_rounded),
            ],
          ),
        ),
        DemoBlock(
          'UiTabBar',
          subtitle: 'Selected: ${const ['Day', 'Week', 'Month'][_tab]}',
          child: UiTabBar(tabs: const ['Day', 'Week', 'Month'], selectedIndex: _tab, onChanged: (v) => setState(() => _tab = v)),
        ),
        DemoBlock(
          'UiBottomNav',
          child: _frame(
            context,
            80,
            Align(
              alignment: Alignment.bottomCenter,
              child: UiBottomNav(items: navItems, index: _bottom, onChanged: (v) => setState(() => _bottom = v)),
            ),
          ),
        ),
        DemoBlock(
          'UiFloatingNavBar',
          child: _frame(
            context,
            180,
            Scaffold(
              extendBody: true,
              body: UiImage(pic('beach', 900, 400)),
              bottomNavigationBar: UiFloatingNavBar(
                items: navItems.take(4).toList(),
                index: _floating,
                onChanged: (v) => setState(() => _floating = v),
              ),
            ),
          ),
        ),
        DemoBlock(
          'UiAdaptiveShell',
          subtitle: 'Bottom bar, rail, or extended rail by width',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _frame(context, 440, UiAdaptiveShell(destinations: navItems, pages: pages)),
              const UiGap.sm(),
              Align(
                alignment: Alignment.centerLeft,
                child: UiButton.tonal(
                  'Open full screen',
                  icon: Icons.fullscreen_rounded,
                  onPressed: () => pushPage(context, AdaptiveShellPage(pages: pages)),
                ),
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiStepIndicator',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiStepIndicator(
                steps: const ['Cart', 'Address', 'Pay', 'Done'],
                current: _step,
                onTap: (v) => setState(() => _step = v),
              ),
              const UiGap.md(),
              Row(
                children: [
                  UiButton.outline('Back', size: UiSize.sm, onPressed: _step > 0 ? () => setState(() => _step--) : null),
                  const UiGap.sm(),
                  UiButton('Next', size: UiSize.sm, onPressed: _step < 4 ? () => setState(() => _step++) : null),
                ],
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiPageDots',
          child: Column(
            children: [
              SizedBox(
                height: 160,
                child: PageView(
                  controller: _pages,
                  onPageChanged: (v) => setState(() => _page = v),
                  children: [
                    for (var i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
                        child: UiImage(pic('dots$i', 800, 400), radius: context.tokens.lg),
                      ),
                  ],
                ),
              ),
              const UiGap.md(),
              UiPageDots(count: 4, controller: _pages),
              const UiGap.sm(),
              UiPageDots(count: 4, index: _page, size: 6, activeWidth: 16),
            ],
          ),
        ),
        DemoBlock(
          'UiBreadcrumbs',
          child: UiBreadcrumbs(
            items: const ['Home', 'Shoes', 'Running', 'Trail'],
            onTap: (i) => toast(context, 'Go to level $i'),
          ),
        ),
        DemoBlock(
          'UiDrawer',
          child: _frame(
            context,
            420,
            Align(
              alignment: Alignment.centerLeft,
              child: UiDrawer(
                name: 'Asha Rao',
                email: 'asha@mail.com',
                avatarUrl: pic('asha', 200, 200),
                items: navItems,
                selectedIndex: _drawer,
                onSelected: (v) => setState(() => _drawer = v),
                footer: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.xxl),
                  child: UiButton.ghost('Sign out', icon: Icons.logout_rounded, onPressed: () => toast(context, 'Signed out')),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AdaptiveShellPage extends StatelessWidget {
  const AdaptiveShellPage({super.key, required this.pages});

  final List<Widget> pages;

  @override
  Widget build(BuildContext context) => UiAdaptiveShell(
        destinations: navItems,
        pages: pages,
        floating: true,
        appBar: const UiAppBar(title: 'Adaptive shell'),
        header: const UiAvatar(name: 'Asha Rao'),
        floatingActionButton: FloatingActionButton(onPressed: () => toast(context, 'New'), child: const Icon(Icons.add_rounded)),
      );
}
