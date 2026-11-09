import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/navigation/navigation.dart';

Widget _app(Widget home, {ThemeMode mode = ThemeMode.light}) =>
    MaterialApp(theme: UiTheme.light(), darkTheme: UiTheme.dark(), themeMode: mode, home: home);

void _size(WidgetTester tester, double width, [double height = 800]) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

const _items = [
  UiNavItem(Icons.home_outlined, 'Home', selectedIcon: Icons.home),
  UiNavItem(Icons.search, 'Search'),
  UiNavItem(Icons.inbox_outlined, 'Inbox', badge: 3),
  UiNavItem(Icons.person_outline, 'Profile', dot: true),
];

class _Counter extends StatefulWidget {
  const _Counter(this.name);
  final String name;
  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int count = 0;
  @override
  Widget build(BuildContext context) =>
      TextButton(onPressed: () => setState(() => count++), child: Text('${widget.name} $count'));
}

class _ShellHarness extends StatefulWidget {
  const _ShellHarness({this.floating = false, this.onChanged});
  final bool floating;
  final ValueChanged<int>? onChanged;
  @override
  State<_ShellHarness> createState() => _ShellHarnessState();
}

class _ShellHarnessState extends State<_ShellHarness> {
  int index = 0;
  @override
  Widget build(BuildContext context) => UiShell(
    items: _items,
    index: index,
    floatingNav: widget.floating,
    header: const Text('Acme'),
    appBar: const UiAppBar(title: 'Shell'),
    onChanged: (i) {
      widget.onChanged?.call(i);
      setState(() => index = i);
    },
    pages: const [_Counter('A'), _Counter('B'), _Counter('C'), _Counter('D')],
  );
}

void main() {
  group('UiShell', () {
    testWidgets('switches bottom nav, rail and sidebar by width', (tester) async {
      for (final mode in ThemeMode.values.skip(1)) {
        _size(tester, 390);
        await tester.pumpWidget(_app(const _ShellHarness(), mode: mode));
        expect(find.byType(UiBottomNav), findsOneWidget);
        expect(find.byType(UiNavRail), findsNothing);

        _size(tester, 700);
        await tester.pumpAndSettle();
        expect(find.byType(UiNavRail), findsOneWidget);
        expect(find.byType(UiBottomNav), findsNothing);

        _size(tester, 1000);
        await tester.pumpAndSettle();
        expect(find.byType(UiNavRail), findsOneWidget);

        _size(tester, 1400);
        await tester.pumpAndSettle();
        expect(find.byType(UiSidebar), findsOneWidget);
        expect(find.text('Acme'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('onChanged fires and IndexedStack keeps page state', (tester) async {
      _size(tester, 390);
      final taps = <int>[];
      await tester.pumpWidget(_app(_ShellHarness(onChanged: taps.add)));
      await tester.tap(find.text('A 0'));
      await tester.pump();
      expect(find.text('A 1'), findsOneWidget);

      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(taps, [1]);
      expect(find.text('B 0'), findsOneWidget);

      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(find.text('A 1'), findsOneWidget);

      // State survives a resize from bottom nav to sidebar.
      _size(tester, 1400);
      await tester.pumpAndSettle();
      expect(find.text('A 1'), findsOneWidget);
      await tester.tap(find.text('Inbox'));
      await tester.pumpAndSettle();
      expect(taps, [1, 0, 2]);
    });

    testWidgets('floating nav fits 320 px', (tester) async {
      _size(tester, 320, 640);
      await tester.pumpWidget(_app(const _ShellHarness(floating: true)));
      expect(find.byType(UiBottomNav), findsOneWidget);
      expect(tester.takeException(), isNull);
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
      expect(scaffold.extendBody, isTrue);
    });
  });

  group('UiBottomNav', () {
    testWidgets('renders badges and taps', (tester) async {
      for (final floating in [false, true]) {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          int? tapped;
          await tester.pumpWidget(
            _app(
              mode: mode,
              Scaffold(
                bottomNavigationBar: UiBottomNav(
                  items: _items,
                  index: 0,
                  floating: floating,
                  onChanged: (i) => tapped = i,
                ),
              ),
            ),
          );
          expect(find.text('3'), findsOneWidget);
          expect(find.byType(Badge), findsNWidgets(2));
          await tester.tap(find.text('Profile'));
          expect(tapped, 3);
        }
      }
    });

    testWidgets('null onChanged disables taps', (tester) async {
      await tester.pumpWidget(
        _app(const Scaffold(bottomNavigationBar: UiBottomNav(items: _items, index: 0, onChanged: null))),
      );
      await tester.tap(find.text('Search'));
      expect(tester.takeException(), isNull);
    });

    test('badge text caps at 99+', () {
      expect(const UiNavItem(Icons.abc, 'x', badge: 120).badgeText, '99+');
      expect(const UiNavItem(Icons.abc, 'x').hasBadge, isFalse);
    });
  });

  group('UiNavRail and UiSidebar', () {
    testWidgets('rail taps', (tester) async {
      _size(tester, 800);
      int? tapped;
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Row(
              children: [UiNavRail(items: _items, index: 0, onChanged: (i) => tapped = i)],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Inbox'));
      expect(tapped, 2);
    });

    testWidgets('sidebar sections, badges and collapse', (tester) async {
      _size(tester, 1400);
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        int? tapped;
        bool? collapsed;
        await tester.pumpWidget(
          _app(
            mode: mode,
            Scaffold(
              body: Row(
                children: [
                  UiSidebar(
                    key: ValueKey(mode),
                    sections: const [
                      UiSidebarSection(title: 'Main', [
                        UiNavItem(Icons.home, 'Home'),
                        UiNavItem(Icons.inbox, 'Inbox', badge: 7),
                      ]),
                      UiSidebarSection(title: 'Other', [UiNavItem(Icons.settings, 'Settings')]),
                    ],
                    index: 0,
                    onChanged: (i) => tapped = i,
                    header: const Text('Logo'),
                    footer: const Text('Account'),
                    collapsible: true,
                    onCollapsedChanged: (v) => collapsed = v,
                  ),
                ],
              ),
            ),
          ),
        );
        expect(find.text('Main'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        await tester.tap(find.text('Settings'));
        expect(tapped, 2);

        await tester.tap(find.text('Collapse'));
        await tester.pumpAndSettle();
        expect(collapsed, isTrue);
        expect(find.text('Settings'), findsNothing);
        expect(find.text('Logo'), findsNothing);
        expect(tester.getSize(find.byType(UiSidebar)).width, UiSidebar.collapsedWidth);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('UiDrawer', () {
    testWidgets('selects and closes', (tester) async {
      final key = GlobalKey<ScaffoldState>();
      int? tapped;
      await tester.pumpWidget(
        _app(
          Scaffold(
            key: key,
            drawer: UiDrawer(items: _items, index: 0, onChanged: (i) => tapped = i, header: const Text('Header')),
          ),
        ),
      );
      key.currentState!.openDrawer();
      await tester.pumpAndSettle();
      expect(find.text('Header'), findsOneWidget);
      await tester.tap(find.text('Search'));
      await tester.pumpAndSettle();
      expect(tapped, 1);
      expect(key.currentState!.isDrawerOpen, isFalse);
    });
  });

  group('UiAppBar', () {
    testWidgets('back button pops', (tester) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const Scaffold(
                      appBar: UiAppBar(title: 'Detail', subtitle: 'Sub'),
                    ),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(find.text('Detail'), findsOneWidget);
      expect(find.text('Sub'), findsOneWidget);
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Detail'), findsNothing);
      expect(find.text('Open'), findsOneWidget);
    });

    testWidgets('no back button on root, large title, both modes', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          _app(
            mode: mode,
            Scaffold(
              appBar: UiAppBar(
                title: 'Library',
                large: true,
                actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.add), tooltip: 'Add')],
              ),
            ),
          ),
        );
        expect(find.byTooltip('Back'), findsNothing);
        expect(find.text('Library'), findsOneWidget);
        expect(tester.getSize(find.byType(AppBar)).height, greaterThanOrEqualTo(112));
      }
    });

    testWidgets('large-title sliver collapses on scroll', (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: CustomScrollView(
              slivers: [
                const UiSliverAppBar(title: 'Inbox'),
                SliverList.builder(itemCount: 60, itemBuilder: (_, i) => SizedBox(height: 56, child: Text('Item $i'))),
              ],
            ),
          ),
        ),
      );
      final before = tester.getTopLeft(find.text('Item 0')).dy;
      expect(before, greaterThan(100));
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Inbox'), findsWidgets);
      expect(find.text('Item 0'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('UiTabs', () {
    for (final variant in UiTabsVariant.values) {
      testWidgets('$variant switches tabs', (tester) async {
        for (final mode in [ThemeMode.light, ThemeMode.dark]) {
          _size(tester, 320);
          var index = 0;
          await tester.pumpWidget(
            _app(
              mode: mode,
              Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) => UiTabs(
                    tabs: const [
                      'One',
                      UiTab('Two', count: 5),
                      UiTab('Three', icon: Icons.star),
                    ],
                    index: index,
                    variant: variant,
                    onChanged: (i) => setState(() => index = i),
                  ),
                ),
              ),
            ),
          );
          expect(find.text('5'), findsOneWidget);
          await tester.tap(find.text('Two'));
          await tester.pumpAndSettle();
          expect(index, 1);
          await tester.tap(find.text('Three'));
          await tester.pumpAndSettle();
          expect(index, 2);
          expect(tester.takeException(), isNull);
        }
      });
    }

    testWidgets('scrollable tabs and disabled state', (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Column(
              children: [
                UiTabs(tabs: [for (var i = 0; i < 12; i++) 'Tab $i'], scrollable: true, onChanged: (_) {}),
                const UiTabs(tabs: ['A', 'B']),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Tab 0'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('UiTabView switches pages', (tester) async {
      final changes = <int>[];
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: UiTabView(
              tabs: const ['Posts', 'Likes'],
              variant: UiTabsVariant.pill,
              onChanged: changes.add,
              children: const [
                Center(child: Text('Posts page')),
                Center(child: Text('Likes page')),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Posts page'), findsOneWidget);
      await tester.tap(find.text('Likes'));
      await tester.pumpAndSettle();
      expect(find.text('Likes page'), findsOneWidget);
      expect(changes, [1]);
    });
  });

  group('UiBreadcrumbs', () {
    const path = ['Home', 'Projects', 'Design system', 'Components', 'Navigation'];

    testWidgets('shows all items when wide', (tester) async {
      _size(tester, 1200);
      int? tapped;
      await tester.pumpWidget(_app(Scaffold(body: UiBreadcrumbs(path, onTap: (i) => tapped = i))));
      for (final p in path) {
        expect(find.text(p), findsOneWidget);
      }
      expect(find.text('…'), findsNothing);
      await tester.tap(find.text('Projects'));
      expect(tapped, 1);
    });

    testWidgets('collapses middle items when narrow', (tester) async {
      _size(tester, 320);
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        int? tapped;
        await tester.pumpWidget(
          _app(
            mode: mode,
            Scaffold(body: UiBreadcrumbs(path, onTap: (i) => tapped = i)),
          ),
        );
        expect(find.text('…'), findsOneWidget);
        expect(find.text('Navigation'), findsOneWidget);
        expect(find.text('Projects'), findsNothing);
        expect(tester.takeException(), isNull);

        await tester.tap(find.text('…'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Projects').last);
        await tester.pumpAndSettle();
        expect(tapped, 1);
      }
    });
  });

  group('UiSteps', () {
    testWidgets('horizontal and vertical', (tester) async {
      _size(tester, 320);
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        int? tapped;
        await tester.pumpWidget(
          _app(
            mode: mode,
            Scaffold(
              body: ListView(
                children: [
                  UiSteps(steps: const ['Cart', 'Address', 'Payment', 'Done'], current: 2, onTap: (i) => tapped = i),
                  const UiSteps(
                    direction: Axis.vertical,
                    current: 1,
                    steps: [
                      UiStep('Order placed', description: 'We got your order'),
                      UiStep('Shipped', description: 'On the way'),
                      UiStep('Delivered'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        expect(find.byIcon(Icons.check_rounded), findsNWidgets(3));
        expect(find.text('3'), findsNWidgets(2));
        expect(find.text('On the way'), findsOneWidget);
        await tester.tap(find.text('Address'));
        expect(tapped, 1);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('UiPagination', () {
    test('page math', () {
      expect(UiPagination.pages(1, 20), [1, 2, 3, 4, 5, null, 20]);
      expect(UiPagination.pages(5, 20), [1, null, 4, 5, 6, null, 20]);
      expect(UiPagination.pages(10, 20), [1, null, 9, 10, 11, null, 20]);
      expect(UiPagination.pages(20, 20), [1, null, 16, 17, 18, 19, 20]);
      expect(UiPagination.pages(3, 5), [1, 2, 3, 4, 5]);
      expect(UiPagination.pages(1, 1), [1]);
      expect(UiPagination.pages(1, 0), isEmpty);
      expect(UiPagination.pages(10, 20, siblings: 0), [1, null, 10, null, 20]);
      expect(UiPagination.pages(99, 20).last, 20);
    });

    testWidgets('taps and arrows', (tester) async {
      _size(tester, 800);
      final pages = <int>[];
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: Center(child: UiPagination(page: 1, pageCount: 20, onChanged: pages.add)),
          ),
        ),
      );
      expect(find.text('…'), findsOneWidget);
      await tester.tap(find.text('4'));
      await tester.tap(find.byTooltip('Next page'));
      await tester.tap(find.byTooltip('Previous page'));
      expect(pages, [4, 2]);
    });

    testWidgets('adapts to narrow widths', (tester) async {
      _size(tester, 320);
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await tester.pumpWidget(
          _app(
            mode: mode,
            Scaffold(
              body: Column(
                children: [
                  UiPagination(page: 10, pageCount: 20, onChanged: (_) {}),
                  SizedBox(width: 200, child: UiPagination(page: 10, pageCount: 20, onChanged: (_) {})),
                ],
              ),
            ),
          ),
        );
        expect(find.text('10 / 20'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('UiPageDots', () {
    testWidgets('active dot stretches and taps', (tester) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        int? tapped;
        var index = 0;
        await tester.pumpWidget(
          _app(
            mode: mode,
            Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) => UiPageDots(
                    count: 4,
                    index: index,
                    onTap: (i) => setState(() {
                      tapped = i;
                      index = i;
                    }),
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final dots = find.descendant(of: find.byType(UiPageDots), matching: find.byType(AnimatedContainer));
        expect(dots, findsNWidgets(4));
        // Sizes include the 4 px margin on each side.
        expect(tester.getSize(dots.at(0)).width, 32);
        await tester.tap(dots.at(2));
        await tester.pumpAndSettle();
        expect(tapped, 2);
        expect(tester.getSize(dots.at(2)).width, 32);
        expect(tester.getSize(dots.at(0)).width, 16);
      }
    });
  });
}
