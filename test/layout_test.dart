import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/display/display.dart';
import 'package:theme/src/layout/layout.dart';

Widget _app(Widget home, {ThemeMode mode = ThemeMode.light}) =>
    MaterialApp(theme: UiTheme.light(), darkTheme: UiTheme.dark(), themeMode: mode, home: home);

void _size(WidgetTester tester, double width, [double height = 800]) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

const _modes = [ThemeMode.light, ThemeMode.dark];

void main() {
  group('UiScaffold', () {
    testWidgets('centers body with max width on wide screens', (tester) async {
      _size(tester, 1400);
      const key = Key('body');
      await tester.pumpWidget(
        _app(
          const UiScaffold(
            maxWidth: 720,
            padding: EdgeInsets.zero,
            body: SizedBox(key: key, height: 50),
          ),
        ),
      );
      expect(tester.getSize(find.byKey(key)).width, 720);
      expect(tester.getTopLeft(find.byKey(key)).dx, (1400 - 720) / 2);
    });

    testWidgets('default page padding and scrolling at 320 px', (tester) async {
      _size(tester, 320, 600);
      for (final mode in _modes) {
        await tester.pumpWidget(
          _app(
            mode: mode,
            UiScaffold(
              scrollable: true,
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (var i = 0; i < 40; i++) Text('Row $i')],
              ),
            ),
          ),
        );
        expect(tester.getTopLeft(find.text('Row 0')).dx, UiSpace.page);
        await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -2000));
        await tester.pumpAndSettle();
        expect(find.text('Row 39'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('tap outside closes the keyboard', (tester) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      await tester.pumpWidget(
        _app(
          UiScaffold(
            body: Column(
              children: [
                TextField(focusNode: focus),
                const SizedBox(height: 300),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      expect(focus.hasFocus, isTrue);
      await tester.tapAt(const Offset(200, 400));
      await tester.pump();
      expect(focus.hasFocus, isFalse);
    });

    testWidgets('with bottom bar', (tester) async {
      var saved = 0;
      await tester.pumpWidget(
        _app(
          UiScaffold(
            body: const Text('Form'),
            bottomBar: UiBottomBar(
              children: [
                OutlinedButton(onPressed: () {}, child: const Text('Cancel')),
                FilledButton(onPressed: () => saved++, child: const Text('Save')),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.text('Save'));
      expect(saved, 1);
      final cancel = tester.getSize(find.widgetWithText(OutlinedButton, 'Cancel')).width;
      final save = tester.getSize(find.widgetWithText(FilledButton, 'Save')).width;
      expect(cancel, save);
    });
  });

  group('UiBottomBar', () {
    testWidgets('sits above the keyboard and safe area', (tester) async {
      for (final mode in _modes) {
        await tester.pumpWidget(
          _app(
            mode: mode,
            MediaQuery(
              data: const MediaQueryData(
                size: Size(800, 600),
                padding: EdgeInsets.only(bottom: 30),
                viewInsets: EdgeInsets.only(bottom: 250),
              ),
              child: Scaffold(
                bottomNavigationBar: UiBottomBar(
                  child: FilledButton(onPressed: () {}, child: const Text('Checkout')),
                ),
              ),
            ),
          ),
        );
        final bottom = tester.getBottomLeft(find.byType(FilledButton)).dy;
        expect(bottom, lessThanOrEqualTo(600 - 250));
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('UiContent', () {
    testWidgets('limits width and pads', (tester) async {
      _size(tester, 1400);
      const key = Key('c');
      await tester.pumpWidget(
        _app(
          const Scaffold(
            body: UiContent(maxWidth: 600, child: SizedBox(key: key, height: 10)),
          ),
        ),
      );
      // 600 minus 32 px padding on each side (large screens).
      expect(tester.getSize(find.byKey(key)).width, 600 - 2 * UiSpace.xxl);
    });
  });

  group('UiSection', () {
    testWidgets('header, subtitle and action tap', (tester) async {
      _size(tester, 320);
      for (final mode in _modes) {
        var taps = 0;
        await tester.pumpWidget(
          _app(
            mode: mode,
            Scaffold(
              body: UiSection(
                title: 'Recent orders with a very long title that must ellipsize',
                subtitle: 'Last 30 days',
                actionLabel: 'See all',
                onAction: () => taps++,
                child: const Text('Content'),
              ),
            ),
          ),
        );
        expect(find.text('Last 30 days'), findsOneWidget);
        expect(find.text('Content'), findsOneWidget);
        await tester.tap(find.text('See all'));
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('custom action widget', (tester) async {
      await tester.pumpWidget(_app(const Scaffold(body: UiSectionHeader('Team', action: Icon(Icons.add)))));
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });

  group('UiDivider', () {
    testWidgets('plain, labeled and vertical', (tester) async {
      _size(tester, 320);
      for (final mode in _modes) {
        await tester.pumpWidget(
          _app(
            mode: mode,
            const Scaffold(
              body: Column(
                children: [
                  UiDivider(),
                  UiDivider(label: 'or'),
                  UiDivider(label: 'A very long divider label that will not fit on a small phone screen at all'),
                  SizedBox(
                    height: 40,
                    child: Row(children: [Text('A'), UiDivider(vertical: true, space: 16), Text('B')]),
                  ),
                ],
              ),
            ),
          ),
        );
        expect(find.text('or'), findsOneWidget);
        expect(find.byType(VerticalDivider), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('UiColumn and UiRow', () {
    testWidgets('insert gaps between children', (tester) async {
      const a = Key('a');
      const b = Key('b');
      const c = Key('c');
      const d = Key('d');
      await tester.pumpWidget(
        _app(
          const Scaffold(
            body: UiColumn(
              gap: 10,
              children: [
                UiRow(
                  gap: 6,
                  children: [
                    SizedBox(key: a, width: 20, height: 20),
                    SizedBox(key: b, width: 20, height: 20),
                  ],
                ),
                SizedBox(key: c, width: 20, height: 20),
                SizedBox(key: d, width: 20, height: 20),
              ],
            ),
          ),
        ),
      );
      expect(tester.getTopLeft(find.byKey(b)).dx - tester.getTopLeft(find.byKey(a)).dx, 26);
      expect(tester.getTopLeft(find.byKey(c)).dy - tester.getTopLeft(find.byKey(a)).dy, 30);
      expect(tester.getTopLeft(find.byKey(d)).dy - tester.getTopLeft(find.byKey(c)).dy, 30);
    });
  });

  group('UiResponsiveGrid', () {
    test('column count', () {
      expect(UiResponsiveGrid.columnsFor(320, minItemWidth: 140), 2);
      expect(UiResponsiveGrid.columnsFor(100, minItemWidth: 140), 1);
      expect(UiResponsiveGrid.columnsFor(1000, minItemWidth: 140), 6);
      expect(UiResponsiveGrid.columnsFor(1000, minItemWidth: 140, maxColumns: 4), 4);
      expect(UiResponsiveGrid.columnsFor(double.infinity), 1);
    });

    Future<void> pumpGrid(WidgetTester tester, double width, {ThemeMode mode = ThemeMode.light}) async {
      _size(tester, width);
      await tester.pumpWidget(
        _app(
          mode: mode,
          Scaffold(
            body: SingleChildScrollView(
              child: UiResponsiveGrid(
                minItemWidth: 140,
                equalHeight: true,
                children: [
                  for (var i = 0; i < 7; i++)
                    Container(
                      key: ValueKey(i),
                      height: 40.0 + i * 5,
                      color: Colors.transparent,
                      child: Text('Item $i with long text that wraps', maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('2 columns at 320 px, no overflow', (tester) async {
      for (final mode in _modes) {
        await pumpGrid(tester, 320, mode: mode);
        final y0 = tester.getTopLeft(find.byKey(const ValueKey(0))).dy;
        expect(tester.getTopLeft(find.byKey(const ValueKey(1))).dy, y0);
        expect(tester.getTopLeft(find.byKey(const ValueKey(2))).dy, greaterThan(y0));
        expect(tester.getSize(find.byKey(const ValueKey(0))).width, (320 - UiSpace.md) / 2);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('more columns when wide', (tester) async {
      await pumpGrid(tester, 1000);
      final y0 = tester.getTopLeft(find.byKey(const ValueKey(0))).dy;
      expect(tester.getTopLeft(find.byKey(const ValueKey(5))).dy, y0);
      expect(tester.getTopLeft(find.byKey(const ValueKey(6))).dy, greaterThan(y0));
    });
  });

  group('UiResponsiveLayout', () {
    testWidgets('picks by breakpoint with fallback', (tester) async {
      const layout = UiResponsiveLayout(compact: Text('phone'), expanded: Text('tablet'));
      _size(tester, 400);
      await tester.pumpWidget(_app(const Scaffold(body: layout)));
      expect(find.text('phone'), findsOneWidget);
      _size(tester, 700);
      await tester.pumpAndSettle();
      expect(find.text('phone'), findsOneWidget);
      _size(tester, 1000);
      await tester.pumpAndSettle();
      expect(find.text('tablet'), findsOneWidget);
      _size(tester, 1400);
      await tester.pumpAndSettle();
      expect(find.text('tablet'), findsOneWidget);
    });

    testWidgets('builder with local width', (tester) async {
      _size(tester, 1400);
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: SizedBox(
              width: 300,
              child: UiResponsiveLayout.builder(local: true, builder: (context, bp) => Text(bp.name)),
            ),
          ),
        ),
      );
      expect(find.text('compact'), findsOneWidget);
    });
  });

  group('UiSplitView', () {
    Widget split({Widget? secondary, VoidCallback? onClose}) => Scaffold(
      body: UiSplitView(
        primary: const Text('List'),
        secondary: secondary,
        placeholder: const Text('Pick one'),
        onCloseSecondary: onClose,
      ),
    );

    testWidgets('side by side when wide', (tester) async {
      _size(tester, 1200);
      for (final mode in _modes) {
        await tester.pumpWidget(_app(mode: mode, split()));
        expect(find.text('List'), findsOneWidget);
        expect(find.text('Pick one'), findsOneWidget);
        await tester.pumpWidget(_app(mode: mode, split(secondary: const Text('Detail'))));
        expect(find.text('List'), findsOneWidget);
        expect(find.text('Detail'), findsOneWidget);
      }
    });

    testWidgets('single pane when compact', (tester) async {
      _size(tester, 400);
      var closed = 0;
      await tester.pumpWidget(_app(split(onClose: () => closed++)));
      expect(find.text('List'), findsOneWidget);
      expect(find.text('Pick one'), findsNothing);

      await tester.pumpWidget(_app(split(secondary: const Text('Detail'), onClose: () => closed++)));
      expect(find.text('Detail'), findsOneWidget);
      expect(find.text('List'), findsNothing);

      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(closed, 1);
    });
  });

  group('UiSurface', () {
    testWidgets('renders tones and handles taps', (tester) async {
      for (final mode in _modes) {
        var taps = 0;
        await tester.pumpWidget(
          _app(
            mode: mode,
            Scaffold(
              body: Column(
                children: [
                  UiSurface(onTap: () => taps++, child: const Text('Tap me')),
                  for (final s in UiStatus.values) UiSurface(tone: s, child: Text(s.name)),
                  Builder(
                    builder: (context) => UiSurface(shadow: context.shadowMd, child: const Text('Raised')),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.tap(find.text('Tap me'));
        expect(taps, 1);
        expect(find.text('success'), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });

  group('Lazy slivers', () {
    testWidgets('UiScaffold.slivers builds only the grid and group rows on screen', (tester) async {
      _size(tester, 400);
      for (final mode in _modes) {
        var gridBuilds = 0;
        var rowBuilds = 0;
        await tester.pumpWidget(
          _app(
            UiScaffold.slivers(
              key: ValueKey(mode), // fresh scroll position per mode
              appBar: AppBar(title: const Text('Lazy')),
              gap: UiSpace.lg,
              maxWidth: 720,
              slivers: [
                const SliverToBoxAdapter(child: Text('Top')),
                UiSliverResponsiveGrid(
                  minItemWidth: 76,
                  itemCount: 1000,
                  itemBuilder: (context, i) {
                    gridBuilds++;
                    return SizedBox(height: 80, child: Text('Cell $i'));
                  },
                ),
                UiSliverListGroup(
                  header: 'Rows',
                  footer: 'End',
                  itemCount: 500,
                  itemBuilder: (context, i) {
                    rowBuilds++;
                    return UiListTile('Row $i');
                  },
                ),
              ],
            ),
            mode: mode,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Top'), findsOneWidget);
        expect(find.text('Cell 0'), findsOneWidget);
        // 400 - 2 * 16 padding = 368 wide: 4 columns of at least 76.
        expect(find.text('Cell 3'), findsOneWidget);
        expect(find.text('Cell 999'), findsNothing);
        expect(gridBuilds, lessThan(100));
        // An off-screen sliver still lays out its first row to measure itself.
        expect(rowBuilds, lessThanOrEqualTo(1));

        final position = tester.state<ScrollableState>(find.byType(Scrollable).first).position;
        for (var step = 0; step < 100 && find.text('Row 0').evaluate().isEmpty; step++) {
          position.jumpTo(position.pixels + 1000);
          await tester.pump();
        }
        expect(find.text('Row 0'), findsOneWidget);
        expect(find.text('Rows'), findsOneWidget);
        expect(rowBuilds, lessThan(100));
        expect(find.text('Row 499'), findsNothing);
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('UiSliverResponsiveGrid uses the same columns as UiResponsiveGrid', (tester) async {
      _size(tester, 400);
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: CustomScrollView(
              slivers: [
                UiSliverResponsiveGrid(
                  minItemWidth: 160,
                  spacing: 16,
                  itemCount: 3,
                  itemBuilder: (context, i) => SizedBox(height: 50, child: Text('G$i')),
                ),
              ],
            ),
          ),
        ),
      );
      // 400 wide, 160 min, 16 gap: 2 columns; item 2 starts a second row.
      expect(UiResponsiveGrid.columnsFor(400, minItemWidth: 160, spacing: 16), 2);
      expect(tester.getTopLeft(find.text('G1')).dy, tester.getTopLeft(find.text('G0')).dy);
      expect(tester.getTopLeft(find.text('G2')).dy, greaterThan(tester.getTopLeft(find.text('G0')).dy));
      expect(tester.getSize(find.text('G0').first).width, lessThanOrEqualTo(192));
    });

    testWidgets('UiSliverListGroup with no rows and with non-tile rows', (tester) async {
      await tester.pumpWidget(
        _app(
          Scaffold(
            body: CustomScrollView(
              slivers: [
                const UiSliverListGroup(header: 'Empty', itemCount: 0, itemBuilder: _never),
                UiSliverListGroup(inset: false, itemCount: 2, itemBuilder: (context, i) => Text('Plain $i')),
              ],
            ),
          ),
        ),
      );
      expect(find.text('Empty'), findsOneWidget);
      expect(find.text('Plain 1'), findsOneWidget);
      expect(find.byType(Divider), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

Widget _never(BuildContext context, int i) => throw StateError('built row $i');
