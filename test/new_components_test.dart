import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/theme.dart';

Widget _app(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('UiChip', () {
    testWidgets('renders every variant and size, taps and deletes', (t) async {
      var taps = 0;
      var deleted = 0;
      await t.pumpWidget(_app(UiChipGroup(children: [
        for (final v in UiChipVariant.values)
          for (final s in UiSize.values) UiChip('${v.name}-${s.name}', variant: v, size: s),
        UiChip('tap', onTap: () => taps++, count: 120),
        UiChip('del', onDeleted: () => deleted++, status: UiStatus.success),
      ])));
      expect(find.text('filled-md'), findsOneWidget);
      expect(find.text('99+'), findsOneWidget);
      await t.tap(find.text('tap'));
      await t.tap(find.byIcon(Icons.close_rounded));
      expect((taps, deleted), (1, 1));
      expect(t.takeException(), isNull);
    });

    testWidgets('scrollable group does not overflow', (t) async {
      await t.pumpWidget(_app(SizedBox(width: 200, child: UiChipGroup(scrollable: true, children: [for (var i = 0; i < 20; i++) UiChip('Chip $i')]))));
      expect(t.takeException(), isNull);
    });
  });

  group('UiSearchableDropdown', () {
    testWidgets('filters locally and returns the picked item', (t) async {
      String? value;
      await t.pumpWidget(_app(StatefulBuilder(
        builder: (c, set) => UiSearchableDropdown<String>(
          label: 'Fruit',
          items: const ['Apple', 'Banana', 'Cherry'],
          value: value,
          onChanged: (v) => set(() => value = v),
        ),
      )));
      await t.tap(find.text('Select'));
      await t.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);
      await t.enterText(find.byType(TextField), 'che');
      await t.pumpAndSettle();
      expect(find.text('Banana'), findsNothing);
      await t.tap(find.text('Cherry'));
      await t.pumpAndSettle();
      expect(value, 'Cherry');
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('async search debounces, drops stale results, shows errors', (t) async {
      final calls = <String>[];
      await t.pumpWidget(_app(UiSearchableDropdown<String>(
        value: null,
        onChanged: (_) {},
        minChars: 2,
        debounce: const Duration(milliseconds: 300),
        onSearch: (q) async {
          calls.add(q);
          await Future<void>.delayed(const Duration(milliseconds: 100));
          if (q == 'err') throw Exception('boom');
          return ['$q-1', '$q-2'];
        },
      )));
      await t.tap(find.text('Select'));
      await t.pumpAndSettle();
      expect(find.text('Type to search'), findsOneWidget);
      await t.enterText(find.byType(TextField), 'ab');
      await t.pump(const Duration(milliseconds: 100));
      await t.enterText(find.byType(TextField), 'abc');
      await t.pump(const Duration(milliseconds: 300));
      await t.pump(const Duration(milliseconds: 150));
      await t.pumpAndSettle();
      expect(calls, ['abc']);
      expect(find.text('abc-1'), findsOneWidget);
      await t.enterText(find.byType(TextField), 'err');
      await t.pump(const Duration(milliseconds: 450));
      await t.pumpAndSettle();
      expect(find.text('Try again'), findsOneWidget);
    });
  });

  testWidgets('UiMultiSelectDropdown respects max and shows chips', (t) async {
    var values = <String>[];
    await t.pumpWidget(_app(StatefulBuilder(
      builder: (c, set) => UiMultiSelectDropdown<String>(
        items: const ['A', 'B', 'C', 'D'],
        values: values,
        max: 2,
        maxVisibleChips: 1,
        onChanged: (v) => set(() => values = v),
      ),
    )));
    await t.tap(find.text('Select'));
    await t.pumpAndSettle();
    await t.tap(find.text('A'));
    await t.tap(find.text('C'));
    await t.pump();
    await t.tap(find.text('D'));
    await t.pump();
    await t.tap(find.textContaining('Done (2/2)'));
    await t.pumpAndSettle();
    expect(values, ['A', 'C']);
    expect(find.text('+1'), findsOneWidget);
    await t.tap(find.byTooltip('Remove A'));
    await t.pump();
    expect(values, ['C']);
  });

  testWidgets('UiAutocomplete shows async options and selects', (t) async {
    String? picked;
    await t.pumpWidget(_app(UiAutocomplete<String>(
      onSearch: (q) async => ['${q}x', '${q}y'],
      onSelected: (v) => picked = v,
    )));
    await t.enterText(find.byType(TextField), 'q');
    await t.pump(const Duration(milliseconds: 350));
    await t.pumpAndSettle();
    expect(find.text('qx'), findsOneWidget);
    await t.tap(find.text('qy'));
    await t.pumpAndSettle();
    expect(picked, 'qy');
  });

  group('UiInfiniteList', () {
    testWidgets('loads pages, stops at the end, retries errors', (t) async {
      var fail = true;
      final c = UiPagingController<int>(
        pageSize: 10,
        fetch: (page, size) async {
          await Future<void>.delayed(const Duration(milliseconds: 10));
          if (page == 2 && fail) {
            fail = false;
            throw Exception('x');
          }
          return page > 3 ? [] : [for (var i = 0; i < size; i++) (page - 1) * size + i];
        },
      );
      await t.pumpWidget(_app(UiInfiniteList<int>(
        controller: c,
        itemBuilder: (_, n, _) => SizedBox(height: 50, child: Text('row $n')),
        endBuilder: (_) => const Text('END'),
      )));
      await t.pump();
      await t.pump(const Duration(milliseconds: 20));
      await t.pumpAndSettle();
      expect(find.text('row 0'), findsOneWidget);
      expect(c.hasError, isTrue);
      await t.dragUntilVisible(find.text('Retry'), find.byType(CustomScrollView), const Offset(0, -300));
      await t.tap(find.text('Retry'));
      for (var i = 0; i < 10; i++) {
        await t.pump(const Duration(milliseconds: 20));
        await t.drag(find.byType(CustomScrollView), const Offset(0, -2000));
      }
      await t.pumpAndSettle();
      expect(c.length, 30);
      expect(c.hasMore, isFalse);
      expect(find.text('END'), findsOneWidget);
      c.dispose();
    });

    testWidgets('shows empty state and refreshes', (t) async {
      var n = 0;
      final c = UiPagingController<int>(fetch: (_, _) async => n++ == 0 ? [] : [1, 2]);
      await t.pumpWidget(_app(UiInfiniteList<int>(controller: c, itemBuilder: (_, v, _) => Text('v$v'))));
      await t.pumpAndSettle();
      expect(find.text('Nothing here yet'), findsOneWidget);
      await c.refresh();
      await t.pumpAndSettle();
      expect(find.text('v2'), findsOneWidget);
      c.dispose();
    });

    testWidgets('grid renders its loading skeleton then items', (t) async {
      final done = Completer<List<int>>();
      final c = UiPagingController<int>(pageSize: 4, fetch: (_, _) => done.future);
      await t.pumpWidget(_app(UiInfiniteGrid<int>(controller: c, itemBuilder: (_, v, _) => Text('g$v'))));
      await t.pump();
      expect(t.takeException(), isNull);
      done.complete([1, 2]);
      await t.pumpAndSettle();
      expect(find.text('g2'), findsOneWidget);
      c.dispose();
    });
  });

  testWidgets('UiLazyBuilder builds only near the viewport', (t) async {
    final built = <int>{};
    await t.pumpWidget(_app(ListView(
      children: [
        for (var i = 0; i < 20; i++)
          UiLazyBuilder(
            margin: 0,
            placeholderHeight: 100,
            builder: (_) {
              built.add(i);
              return SizedBox(height: 100, child: Text('lazy $i'));
            },
          ),
      ],
    )));
    await t.pump();
    expect(built.contains(0), isTrue);
    expect(built.contains(15), isFalse);
    await t.scrollUntilVisible(find.text('lazy 15'), 300);
    expect(built.contains(15), isTrue);
  });

  testWidgets('UiScrollToTop appears after scrolling and returns to top', (t) async {
    final sc = ScrollController();
    await t.pumpWidget(_app(UiScrollToTop(
      controller: sc,
      threshold: 200,
      child: ListView.builder(controller: sc, itemCount: 100, itemBuilder: (_, i) => SizedBox(height: 50, child: Text('$i'))),
    )));
    final btn = find.byTooltip('Back to top');
    expect(t.widget<IgnorePointer>(find.ancestor(of: btn, matching: find.byType(IgnorePointer)).first).ignoring, isTrue);
    sc.jumpTo(1000);
    await t.pumpAndSettle();
    await t.tap(btn);
    await t.pumpAndSettle();
    expect(sc.offset, 0);
    sc.dispose();
  });

  testWidgets('UiMarquee scrolls long text and keeps short text still', (t) async {
    await t.pumpWidget(_app(const SizedBox(
      width: 120,
      child: Column(children: [
        UiMarquee('A very long line of text that cannot fit in the box'),
        UiMarquee('Hi'),
      ]),
    )));
    await t.pump();
    await t.pump(const Duration(seconds: 3));
    expect(find.text('A very long line of text that cannot fit in the box'), findsNWidgets(2));
    expect(find.text('Hi'), findsOneWidget);
    expect(t.takeException(), isNull);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('UiLazyImage and UiVideoThumbnail lay out without errors', (t) async {
    await t.pumpWidget(_app(Column(children: [
      const SizedBox(width: 100, child: UiLazyImage('', aspectRatio: 1)),
      SizedBox(width: 300, child: UiVideoThumbnail(image: null, title: 'Clip', duration: const Duration(seconds: 75), onTap: () {})),
    ])));
    await t.pump();
    expect(find.text('01:15'), findsOneWidget);
    expect(t.takeException(), isNull);
  });
}
