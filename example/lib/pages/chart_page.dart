import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  int _seed = 1;
  bool _horizontal = false;
  String? _donutPick;
  DateTime? _day;

  /// Deterministic pseudo-random values so "Shuffle" changes the data.
  List<double> _values(int n, int salt, {double base = 20, double spread = 30}) => [
    for (var i = 0; i < n; i++) base + ((i * 37 + salt * 53 + _seed * 71) % 97) / 97 * spread,
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateUtils.dateOnly(DateTime.now());
    final heat = <DateTime, int>{
      for (var i = 0; i < 120; i++)
        if ((i * 7 + _seed) % 5 != 0) today.subtract(Duration(days: i)): (i * 13 + _seed * 3) % 9,
    };
    final gauge = ((_seed * 23) % 90 + 5) / 100;
    return GalleryPage(
      children: [
        UiRow(
          children: [
            Expanded(child: Text('Tap or hover a chart for tooltips', style: context.text.bodySmall)),
            UiButton(
              'Shuffle data',
              icon: Icons.shuffle_rounded,
              variant: UiButtonVariant.soft,
              size: UiSize.sm,
              onPressed: () => setState(() => _seed++),
            ),
          ],
        ),
        Demo(
          'Sparklines',
          child: UiResponsiveGrid(
            minItemWidth: 200,
            children: [
              UiStatCard(
                label: 'Visitors',
                value: UiFormat.compact(_values(1, 9, base: 9000, spread: 6000).first),
                delta: 12.4,
                footer: UiSparkline(_values(12, 1)),
              ),
              UiStatCard(
                label: 'Errors',
                value: '${_values(1, 4, base: 10, spread: 40).first.round()}',
                delta: -3.1,
                invertColors: true,
                footer: UiSparkline(_values(12, 2), color: context.colors.danger, curved: false),
              ),
            ],
          ),
        ),
        Demo(
          'Line chart',
          child: UiLineChart(
            series: [UiChartSeries('This year', _values(12, 3)), UiChartSeries('Last year', _values(12, 4, base: 10))],
            labels: _months,
          ),
        ),
        Demo(
          'Bar chart',
          child: UiColumn(
            children: [
              UiSwitch(_horizontal, label: 'Horizontal', onChanged: (v) => setState(() => _horizontal = v)),
              UiBarChart(
                horizontal: _horizontal,
                showValues: true,
                bars: [
                  for (final (i, d) in const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'].indexed)
                    UiBarData(d, _values(5, 5)[i].roundToDouble()),
                ],
              ),
              UiBarChart(
                series: [UiChartSeries('2025', _values(6, 6)), UiChartSeries('2026', _values(6, 7))],
                labels: _months.sublist(0, 6),
                height: 180,
              ),
            ],
          ),
        ),
        Demo(
          'Donut chart',
          subtitle: _donutPick == null ? 'Tap a segment' : 'Selected: $_donutPick',
          child: Center(
            child: UiDonutChart(
              segments: [
                UiChartSegment('Rent', 1200),
                UiChartSegment('Food', _values(1, 8, base: 300, spread: 300).first.roundToDouble()),
                UiChartSegment('Travel', _values(1, 9, base: 100, spread: 400).first.roundToDouble()),
                const UiChartSegment('Fun', 200),
              ],
              onSelect: (i) => setState(() => _donutPick = i == null ? null : ['Rent', 'Food', 'Travel', 'Fun'][i]),
            ),
          ),
        ),
        Demo(
          'Heatmap',
          subtitle: _day == null ? 'Tap a day' : 'Picked ${UiFormat.relativeTime(_day!)}',
          child: UiHeatmap(values: heat, onTap: (d) => setState(() => _day = d)),
        ),
        Demo(
          'Gauge and legend',
          child: UiColumn(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UiGauge(
                value: gauge,
                label: 'Storage used',
                status: gauge > 0.8
                    ? UiStatus.danger
                    : gauge > 0.6
                    ? UiStatus.warning
                    : UiStatus.success,
              ),
              UiChartLegend([
                UiLegendItem('Photos', color: context.colors.chartColor(0), value: '12 GB'),
                UiLegendItem('Video', color: context.colors.chartColor(1), value: '30 GB'),
                UiLegendItem('Apps', color: context.colors.chartColor(2), value: '8 GB'),
              ], alignment: WrapAlignment.center),
            ],
          ),
        ),
      ],
    );
  }
}
