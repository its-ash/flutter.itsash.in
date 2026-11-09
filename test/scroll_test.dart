import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/scroll/scroll.dart';

Widget _app(Widget child, {ThemeMode mode = ThemeMode.light, double? width}) => MaterialApp(
  theme: UiTheme.light(),
  darkTheme: UiTheme.dark(),
  themeMode: mode,
  home: Scaffold(
    body: width == null
        ? child
        : Center(
            child: SizedBox(width: width, child: child),
          ),
  ),
);

const _modes = [ThemeMode.light, ThemeMode.dark];

/// Pages of 20 items; page 3 is the last (5 items).
Future<List<String>> _fetch(int page, int size) async {
  final count = page >= 3 ? 5 : size;
  return [for (var i = 0; i < count; i++) 'Item ${(page - 1) * size + i}'];
}

void main() {
  group('UiPagingController', () {
    test('loads pages until a short page', () async {
      final c = UiPagingController<String>(fetch: _fetch);
      addTearDown(c.dispose);
      expect(c.isFirstLoad, isTrue);
      await c.loadMore();
      expect(c.length, 20);
      expect(c.hasMore, isTrue);
      await c.loadMore();
      await c.loadMore();
      expect(c.length, 45);
      expect(c.hasMore, isFalse);
      await c.loadMore();
      expect(c.length, 45);
    });

    test('guards against concurrent loads', () async {
      var calls = 0;
      final gate = Completer<void>();
      final c = UiPagingController<int>(
        fetch: (page, size) async {
          calls++;
          await gate.future;
          return List.filled(size, page);
        },
      );
      addTearDown(c.dispose);
      final a = c.loadMore();
      final b = c.loadMore();
      expect(c.loading, isTrue);
      gate.complete();
      await Future.wait([a, b]);
      expect(calls, 1);
      expect(c.length, 20);
    });

    test('error then retry', () async {
      var fail = true;
      final c = UiPagingController<int>(
        pageSize: 2,
        fetch: (page, size) async {
          if (fail) throw StateError('offline');
          return [page, page];
        },
      );
      addTearDown(c.dispose);
      await c.loadMore();
      expect(c.error, isA<StateError>());
      expect(c.loading, isFalse);
      fail = false;
      await c.retry();
      expect(c.error, isNull);
      expect(c.items, [1, 1]);
    });

    test('refresh reloads from the first page and drops in-flight pages', () async {
      final gates = <int, Completer<void>>{};
      final c = UiPagingController<int>(
        pageSize: 1,
        firstPage: 0,
        fetch: (page, size) async {
          final g = gates[page];
          if (g != null) await g.future;
          return [page * 10];
        },
      );
      addTearDown(c.dispose);
      await c.loadMore();
      await c.loadMore();
      expect(c.items, [0, 10]);
      gates[2] = Completer<void>();
      final stale = c.loadMore();
      final refreshing = c.refresh();
      expect(identical(c.refresh(), c.refresh()), isTrue);
      await refreshing;
      gates[2]!.complete();
      await stale;
      expect(c.items, [0]);
      expect(c.nextPage, 1);
      expect(c.refreshing, isFalse);
    });

    test('empty result marks isEmpty', () async {
      final c = UiPagingController<int>(fetch: (p, s) async => []);
      addTearDown(c.dispose);
      await c.loadMore();
      expect(c.isEmpty, isTrue);
    });
  });

  group('UiInfiniteList', () {
    for (final mode in _modes) {
      testWidgets('shows skeleton, then items, loads more on scroll ($mode)', (tester) async {
        final c = UiPagingController<String>(fetch: _fetch);
        addTearDown(c.dispose);
        await tester.pumpWidget(
          _app(
            UiInfiniteList<String>(
              controller: c,
              itemBuilder: (context, item, i) => SizedBox(height: 56, child: Text(item)),
              end: const Text('The end'),
            ),
            mode: mode,
          ),
        );
        expect(find.text('Item 0'), findsNothing);
        await tester.pump();
        await tester.pump();
        expect(find.text('Item 0'), findsOneWidget);
        // The first screen may prefetch one more page, but never everything.
        expect(c.length, lessThan(45));
        expect(c.hasMore, isTrue);

        for (var i = 0; i < 12 && find.text('The end').evaluate().isEmpty; i++) {
          await tester.drag(find.byType(CustomScrollView), const Offset(0, -800));
          await tester.pump();
          await tester.pump();
        }
        expect(c.length, 45);
        expect(c.hasMore, isFalse);
        expect(find.text('The end'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('empty state', (tester) async {
      final c = UiPagingController<String>(fetch: (p, s) async => []);
      addTearDown(c.dispose);
      await tester.pumpWidget(
        _app(UiInfiniteList<String>(controller: c, itemBuilder: (context, item, i) => Text(item)), width: 320),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Nothing here yet'), findsOneWidget);
    });

    testWidgets('first page error, then retry', (tester) async {
      var fail = true;
      final c = UiPagingController<String>(
        pageSize: 3,
        fetch: (p, s) async {
          if (fail) throw StateError('offline');
          return ['a', 'b'];
        },
      );
      addTearDown(c.dispose);
      await tester.pumpWidget(
        _app(UiInfiniteList<String>(controller: c, itemBuilder: (context, item, i) => Text(item)), width: 320),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('Something went wrong'), findsOneWidget);
      fail = false;
      await tester.tap(find.text('Retry'));
      await tester.pump();
      await tester.pump();
      expect(find.text('a'), findsOneWidget);
      expect(find.text('Something went wrong'), findsNothing);
    });

    testWidgets('pull to refresh calls refresh', (tester) async {
      var fetches = 0;
      final c = UiPagingController<String>(
        pageSize: 50,
        fetch: (p, s) async {
          fetches++;
          return ['row $fetches'];
        },
      );
      addTearDown(c.dispose);
      await tester.pumpWidget(
        _app(UiInfiniteList<String>(controller: c, itemBuilder: (context, item, i) => Text(item))),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('row 1'), findsOneWidget);
      await tester.fling(find.text('row 1'), const Offset(0, 400), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(fetches, 2);
      expect(find.text('row 2'), findsOneWidget);
    });
  });

  group('UiInfiniteGrid', () {
    for (final mode in _modes) {
      testWidgets('renders items in a grid ($mode)', (tester) async {
        final c = UiPagingController<String>(fetch: _fetch);
        addTearDown(c.dispose);
        await tester.pumpWidget(
          _app(
            UiInfiniteGrid<String>(controller: c, crossAxisCount: 3, itemBuilder: (context, item, i) => Text(item)),
            mode: mode,
            width: 320,
          ),
        );
        await tester.pump();
        await tester.pump();
        expect(find.text('Item 0'), findsOneWidget);
        expect(find.text('Item 2'), findsOneWidget);
        expect(tester.getTopLeft(find.text('Item 1')).dy, tester.getTopLeft(find.text('Item 0')).dy);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('UiRefresh', () {
    testWidgets('calls onRefresh on pull', (tester) async {
      var refreshed = 0;
      await tester.pumpWidget(
        _app(
          UiRefresh(
            onRefresh: () async => refreshed++,
            child: ListView(children: const [SizedBox(height: 80, child: Text('row'))]),
          ),
        ),
      );
      await tester.fling(find.text('row'), const Offset(0, 400), 1000);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(refreshed, 1);
    });
  });

  group('UiScrollToTop', () {
    for (final mode in _modes) {
      testWidgets('appears after scrolling and scrolls up ($mode)', (tester) async {
        final scroll = ScrollController();
        addTearDown(scroll.dispose);
        await tester.pumpWidget(
          _app(
            UiScrollToTop(
              controller: scroll,
              child: ListView.builder(
                controller: scroll,
                itemCount: 200,
                itemBuilder: (context, i) => SizedBox(height: 50, child: Text('Row $i')),
              ),
            ),
            mode: mode,
            width: 320,
          ),
        );
        AnimatedOpacity fade() => tester.widget<AnimatedOpacity>(
          find.descendant(of: find.byType(UiScrollToTop), matching: find.byType(AnimatedOpacity)),
        );
        expect(fade().opacity, 0);
        scroll.jumpTo(2000);
        await tester.pumpAndSettle();
        expect(fade().opacity, 1);
        await tester.tap(find.byTooltip('Back to top'));
        await tester.pumpAndSettle();
        expect(scroll.offset, 0);
        expect(fade().opacity, 0);
      });
    }
  });

  group('UiLazyBuilder', () {
    testWidgets('builds only near the viewport', (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      var builds = 0;
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            controller: scroll,
            child: Column(
              children: [
                const SizedBox(height: 3000),
                UiLazyBuilder(
                  placeholderHeight: 100,
                  builder: (context) {
                    builds++;
                    return const SizedBox(height: 100, child: Text('Lazy'));
                  },
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Lazy'), findsNothing);
      expect(builds, 0);
      scroll.jumpTo(1000);
      await tester.pump();
      await tester.pump();
      expect(builds, 0);
      scroll.jumpTo(2500);
      await tester.pump();
      await tester.pump();
      expect(find.text('Lazy', skipOffstage: false), findsOneWidget);
      expect(builds, 1);
    });

    testWidgets('builds right away outside a scrollable', (tester) async {
      await tester.pumpWidget(_app(UiLazyBuilder(builder: (context) => const Text('Now'))));
      await tester.pump();
      expect(find.text('Now'), findsOneWidget);
    });
  });
}
