import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

const _navItems = [
  UiNavItem(Icons.home_outlined, 'Home', selectedIcon: Icons.home_rounded),
  UiNavItem(Icons.search_rounded, 'Search'),
  UiNavItem(Icons.inbox_outlined, 'Inbox', selectedIcon: Icons.inbox_rounded, badge: 4),
  UiNavItem(Icons.person_outline_rounded, 'Profile', selectedIcon: Icons.person_rounded, dot: true),
];

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _nav = 0;
  bool _floating = true;
  int _tab = 0;
  int _crumb = 3;
  int _step = 1;
  int _page = 5;
  int _dot = 0;

  void _openSliverPage() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          body: CustomScrollView(
            slivers: [
              const UiSliverAppBar(title: 'Inbox'),
              SliverList.list(
                children: [
                  for (var i = 0; i < 30; i++)
                    UiListTile('Message ${i + 1}', subtitle: 'Scroll to shrink the large title', onTap: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const crumbs = ['Home', 'Projects', 'Theme', 'Components', 'Navigation'];
    return GalleryPage(
      children: [
        Demo(
          'Bottom nav',
          subtitle: 'Selected: ${_navItems[_nav].label}',
          child: UiColumn(
            children: [
              UiSwitch(_floating, label: 'Floating pill', onChanged: (v) => setState(() => _floating = v)),
              UiSurface(
                padding: EdgeInsets.zero,
                color: context.colors.background,
                child: MediaQuery.removePadding(
                  context: context,
                  removeBottom: true,
                  child: UiBottomNav(
                    items: _navItems,
                    index: _nav,
                    floating: _floating,
                    onChanged: (i) => setState(() => _nav = i),
                  ),
                ),
              ),
            ],
          ),
        ),
        Demo(
          'Rail and sidebar',
          child: SizedBox(
            height: 340,
            child: UiSurface(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: UiRadius.all(UiRadius.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    UiNavRail(items: _navItems, index: _nav, onChanged: (i) => setState(() => _nav = i)),
                    if (MediaQuery.sizeOf(context).width >= 700)
                      UiSidebar(
                        width: 220,
                        sections: const [
                          UiSidebarSection([
                            UiNavItem(Icons.home_outlined, 'Home'),
                            UiNavItem(Icons.search_rounded, 'Search'),
                          ], title: 'Main'),
                          UiSidebarSection([
                            UiNavItem(Icons.inbox_outlined, 'Inbox', badge: 4),
                            UiNavItem(Icons.person_outline_rounded, 'Profile'),
                          ], title: 'Account'),
                        ],
                        index: _nav,
                        collapsible: true,
                        onChanged: (i) => setState(() => _nav = i),
                      ),
                    Expanded(
                      child: Center(child: Text(_navItems[_nav].label, style: context.text.headlineSmall)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Demo(
          'App bars',
          child: UiColumn(
            children: [
              UiSurface(
                padding: EdgeInsets.zero,
                child: UiAppBar(
                  title: 'Settings',
                  subtitle: 'With actions',
                  back: true,
                  onBack: () => context.showToast('Back tapped'),
                  actions: [
                    UiIconButton(Icons.search_rounded, tooltip: 'Search', onPressed: () => context.showToast('Search')),
                  ],
                  backgroundColor: context.colors.surface,
                ),
              ),
              UiButton('Open sliver app bar page', variant: UiButtonVariant.outline, onPressed: _openSliverPage),
            ],
          ),
        ),
        Demo(
          'Tabs',
          child: UiColumn(
            gap: UiSpace.lg,
            children: [
              for (final v in UiTabsVariant.values)
                UiTabs(
                  tabs: const ['Day', 'Week', UiTab('Month', count: 3)],
                  index: _tab,
                  variant: v,
                  onChanged: (i) => setState(() => _tab = i),
                ),
              SizedBox(
                height: 160,
                child: UiTabView(
                  tabs: const [
                    UiTab('Posts', icon: Icons.article_outlined),
                    UiTab('Likes', icon: Icons.favorite_border),
                  ],
                  variant: UiTabsVariant.pill,
                  children: [
                    for (final t in ['Posts', 'Likes'])
                      Center(child: Text('$t: swipe sideways', style: context.text.bodyMedium)),
                  ],
                ),
              ),
            ],
          ),
        ),
        Demo(
          'Breadcrumbs',
          child: UiBreadcrumbs(
            crumbs.sublist(0, _crumb + 1),
            onTap: (i) => setState(() => _crumb = i == _crumb ? crumbs.length - 1 : i),
          ),
        ),
        Demo(
          'Steps',
          child: UiColumn(
            gap: UiSpace.lg,
            children: [
              UiSteps(
                steps: const ['Cart', 'Address', 'Pay', 'Done'],
                current: _step,
                onTap: (i) => setState(() => _step = i),
              ),
              UiSteps(
                direction: Axis.vertical,
                current: _step,
                steps: const [
                  UiStep('Cart', description: '3 items'),
                  UiStep('Address', description: 'Where should we ship?'),
                  UiStep('Pay', description: 'Card or wallet', icon: Icons.credit_card_rounded),
                  UiStep('Done'),
                ],
              ),
              UiButtonBar([
                UiButton(
                  'Back',
                  variant: UiButtonVariant.outline,
                  onPressed: _step == 0 ? null : () => setState(() => _step--),
                ),
                UiButton('Next', onPressed: _step >= 4 ? null : () => setState(() => _step++)),
              ]),
            ],
          ),
        ),
        Demo(
          'Pagination and dots',
          child: UiColumn(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UiPagination(page: _page, pageCount: 20, onChanged: (p) => setState(() => _page = p)),
              UiPageDots(count: 5, index: _dot, onTap: (i) => setState(() => _dot = i)),
            ],
          ),
        ),
      ],
    );
  }
}
