import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theme/src/chart/chart.dart';
import 'package:theme/src/foundation/foundation.dart';

Widget _app(Widget child, {ThemeMode mode = ThemeMode.light, double width = 400}) => MaterialApp(
  theme: UiTheme.light(),
  darkTheme: UiTheme.dark(),
  themeMode: mode,
  home: Scaffold(
    body: Align(
      alignment: Alignment.topCenter,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

const _modes = [ThemeMode.light, ThemeMode.dark];
const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];

List<Widget> _allCharts(List<num> values) => [
  UiSparkline(values),
  UiLineChart(
    series: [
      UiChartSeries('A', values),
      UiChartSeries('B', [for (final v in values) v * 2]),
    ],
    labels: [for (var i = 0; i < values.length; i++) 'L$i'],
  ),
  UiBarChart(bars: [for (var i = 0; i < values.length; i++) UiBarData('B$i', values[i])], showValues: true),
  UiBarChart(
    series: [UiChartSeries('X', values), UiChartSeries('Y', values)],
    labels: [for (var i = 0; i < values.length; i++) 'G$i'],
    horizontal: true,
    showValues: true,
  ),
  UiDonutChart(segments: [for (var i = 0; i < values.length; i++) UiChartSegment('S$i', values[i])]),
  UiHeatmap(values: {DateTime(2026, 3, 2): values.isEmpty ? 0 : values.first.toInt()}, end: DateTime(2026, 3, 18)),
  const UiGauge(value: 0),
];

void main() {
  for (final mode in _modes) {
    for (final entry in {
      'normal': <num>[3, 8, 5, 12, 9, 15, 11],
      'empty': <num>[],
      'all zero': <num>[0, 0, 0, 0],
      'negative': <num>[-4, 6, -2, 9],
      'single': <num>[7],
    }.entries) {
      testWidgets('every chart renders with ${entry.key} data ($mode)', (tester) async {
        for (final width in [320.0, 600.0]) {
          await tester.pumpWidget(
            _app(
              SingleChildScrollView(child: Column(children: _allCharts(entry.value))),
              mode: mode,
              width: width,
            ),
          );
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
        }
      });
    }
  }

  testWidgets('charts animate on data change', (tester) async {
    Widget build(List<num> v) => _app(
      SingleChildScrollView(
        child: Column(
          children: [
            UiSparkline(v),
            UiLineChart(series: [UiChartSeries('A', v)]),
            UiBarChart(bars: [for (final x in v) UiBarData('$x', x)]),
            UiDonutChart(segments: [for (final x in v) UiChartSegment('$x', x)], showLegend: false),
          ],
        ),
      ),
    );
    await tester.pumpWidget(build([1, 2, 3]));
    await tester.pumpAndSettle();
    await tester.pumpWidget(build([3, 1, 2]));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
    await tester.pumpWidget(build([5, 1]));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  group('UiLineChart', () {
    for (final mode in _modes) {
      testWidgets('touch shows a tooltip with every series ($mode)', (tester) async {
        await tester.pumpWidget(
          _app(
            UiLineChart(
              series: const [
                UiChartSeries('Visits', [12, 18, 15, 24, 30]),
                UiChartSeries('Signups', [2, 4, 3, 6, 9]),
              ],
              labels: _days,
            ),
            mode: mode,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Visits'), findsOneWidget); // legend only
        expect(find.text('Wed'), findsNothing);
        final rect = tester.getRect(find.byType(CustomPaint).last);
        await tester.tapAt(Offset(rect.right - 8, rect.center.dy));
        await tester.pump();
        expect(find.text('Fri'), findsOneWidget);
        expect(find.text('Visits'), findsNWidgets(2)); // legend + tooltip
        expect(find.text('30'), findsOneWidget);
        expect(find.text('9'), findsOneWidget);
        // Tapping the same point again hides it.
        await tester.tapAt(Offset(rect.right - 8, rect.center.dy));
        await tester.pump();
        expect(find.text('Fri'), findsNothing);
      });
    }

    testWidgets('custom y format', (tester) async {
      await tester.pumpWidget(
        _app(
          UiLineChart(
            series: const [
              UiChartSeries('Revenue', [1200, 1800]),
            ],
            yFormat: (v) => '\$$v',
          ),
        ),
      );
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byType(CustomPaint).last);
      await tester.tapAt(Offset(rect.right - 4, rect.center.dy));
      await tester.pump();
      expect(find.text('\$1800.0'), findsOneWidget);
    });
  });

  group('UiBarChart', () {
    testWidgets('tap shows the bar value', (tester) async {
      await tester.pumpWidget(
        _app(UiBarChart(bars: const [UiBarData('Jan', 12), UiBarData('Feb', 18), UiBarData('Mar', 9)])),
      );
      await tester.pumpAndSettle();
      final rect = tester.getRect(find.byType(CustomPaint).last);
      await tester.tapAt(Offset(rect.right - 20, rect.center.dy));
      await tester.pump();
      expect(find.text('Mar'), findsOneWidget);
      expect(find.text('9'), findsOneWidget);
    });
  });

  group('UiDonutChart', () {
    for (final mode in _modes) {
      testWidgets('tap selects a segment ($mode)', (tester) async {
        final selected = <int?>[];
        await tester.pumpWidget(
          _app(
            UiDonutChart(
              segments: const [UiChartSegment('Rent', 50), UiChartSegment('Food', 30), UiChartSegment('Fun', 20)],
              onSelect: selected.add,
            ),
            mode: mode,
            width: 320,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Total'), findsOneWidget);
        expect(find.text('100'), findsOneWidget);
        final rect = tester.getRect(
          find.descendant(of: find.byType(UiDonutChart), matching: find.byType(CustomPaint)).first,
        );
        // Top of the ring belongs to the first segment.
        await tester.tapAt(Offset(rect.center.dx + 4, rect.top + 14));
        await tester.pumpAndSettle();
        expect(selected, [0]);
        expect(find.text('Rent'), findsNWidgets(2)); // center + legend
        expect(find.text('50'), findsOneWidget);
        // Tap again clears.
        await tester.tapAt(Offset(rect.center.dx + 4, rect.top + 14));
        await tester.pumpAndSettle();
        expect(selected, [0, null]);
        expect(find.text('Total'), findsOneWidget);
      });
    }
  });

  group('UiHeatmap', () {
    for (final mode in _modes) {
      testWidgets('tap returns the date ($mode)', (tester) async {
        final taps = <DateTime>[];
        await tester.pumpWidget(
          _app(
            UiHeatmap(
              values: {DateTime(2026, 2, 22, 15): 4, DateTime(2026, 3, 1): 2},
              weeks: 4,
              end: DateTime(2026, 3, 18),
              onTap: taps.add,
            ),
            mode: mode,
          ),
        );
        await tester.pumpAndSettle();
        final grid = tester.getRect(
          find.descendant(of: find.byType(UiHeatmap), matching: find.byType(CustomPaint)).first,
        );
        // Top-left cell: Sunday Feb 22 (en_US weeks start on Sunday).
        final cellTop = grid.top + grid.height - (7 * 14 + 6 * 3);
        await tester.tapAt(Offset(grid.left + 18 + 7, cellTop + 7));
        await tester.pump();
        expect(taps, [DateTime(2026, 2, 22)]);
        expect(find.text('4'), findsOneWidget);
        expect(find.text('Less'), findsOneWidget);
      });
    }

    testWidgets('future days are not tappable and 320 px fits', (tester) async {
      final taps = <DateTime>[];
      await tester.pumpWidget(
        _app(UiHeatmap(values: const {}, weeks: 52, end: DateTime(2026, 3, 18), onTap: taps.add), width: 320),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final grid = tester.getRect(
        find.descendant(of: find.byType(UiHeatmap), matching: find.byType(CustomPaint)).first,
      );
      // Bottom-right cell is Saturday Mar 21, after the end date.
      await tester.tapAt(grid.bottomRight - const Offset(3, 3));
      await tester.pump();
      expect(taps, isEmpty);
    });
  });

  group('UiGauge', () {
    for (final mode in _modes) {
      testWidgets('shows percentage and label ($mode)', (tester) async {
        await tester.pumpWidget(
          _app(
            const UiGauge(value: 0.72, label: 'Storage used', status: UiStatus.warning),
            mode: mode,
            width: 320,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('72%'), findsOneWidget);
        expect(find.text('Storage used'), findsOneWidget);
      });
    }

    testWidgets('clamps out of range values', (tester) async {
      await tester.pumpWidget(_app(const UiGauge(value: 3)));
      await tester.pumpAndSettle();
      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('UiChartLegend', () {
    testWidgets('renders items with values', (tester) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => UiChartLegend([
              UiLegendItem('Revenue', color: context.colors.chartColor(0), value: '12k'),
              UiLegendItem(
                'A very long legend label that should ellipsize nicely',
                color: context.colors.chartColor(1),
              ),
            ]),
          ),
          width: 320,
        ),
      );
      expect(find.text('Revenue'), findsOneWidget);
      expect(find.text('12k'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('UiSparkline', () {
    testWidgets('works inside a Row without a width', (tester) async {
      await tester.pumpWidget(
        _app(
          const Row(
            children: [
              UiSparkline([1, 3, 2, 5]),
              Text('trend'),
            ],
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.getSize(find.byType(UiSparkline)).width, 96);
      expect(tester.takeException(), isNull);
    });
  });
}
