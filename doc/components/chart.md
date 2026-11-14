# Charts

Custom-painted charts. They animate in, animate on data change, use `colors.chartColor(i)`, and show a tooltip on touch or hover.

Value formatters (`yFormat`, `valueFormat`) are `UiChartFormatter`, i.e. `String Function(num value)`.

### UiSparkline

Tiny trend line for stat cards and table cells.

```dart
UiSparkline([4, 6, 5, 9, 12, 10, 14])
```

- `values` (positional): required.
- `color`: default: first chart color.
- `fill`: gradient under the line. Default `true`.
- `height`: default `32`.
- `width`: default: available width (96 inside a `Row`).
- `strokeWidth`: default `2`.
- `curved`: default `true`.
- `showLastDot`: default `true`.

### UiLineChart

Multi-series line or area chart with y-axis ticks and x labels. Touch shows every series at that point.

```dart
UiLineChart(series: [UiChartSeries('Visits', [12, 18, 15, 24, 30])], labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'])
```

- `series`: list of `UiChartSeries(name, values, {color})`. Required.
- `labels`: x labels. Crowded labels are thinned out. Default: none.
- `height`: plot height. Default `220`.
- `curved`: default `true`.
- `area`: gradient fill. Default `true`.
- `showGrid`: default `true`.
- `showLegend`: shown with 2+ series. Default `true`.
- `yFormat`: formats ticks and tooltip values. Default: compact numbers (1.2k).
- `tickCount`: about how many y intervals. Default `4`.
- `animateUpdates`: animate when the data changes. Set `false` for live data updated every second, so the
  line updates in place instead of redrawing from the left. It still animates in once. Default `true`.

### UiBarChart

Bar chart with rounded bars. Pass `bars` for one value per label, or `series` and `labels` for grouped bars.

```dart
UiBarChart(bars: [UiBarData('Jan', 12), UiBarData('Feb', 18), UiBarData('Mar', 9)])
UiBarChart(series: [UiChartSeries('2025', a), UiChartSeries('2026', b)], labels: months)
```

- `bars`: list of `UiBarData(label, value, {color})`.
- `series` + `labels`: grouped bars. Used when `bars` is null.
- `horizontal`: bars grow left to right. Default `false`.
- `height`: default `220` (vertical) or fits the rows (horizontal).
- `showValues`: print values on the bars. Default `false`.
- `showGrid`: default `true`.
- `showLegend`: grouped charts only. Default `true`.
- `yFormat`, `tickCount`: as in `UiLineChart`.

### UiDonutChart

Donut chart with rounded, spaced segments. Tap a segment to highlight it and show its value in the middle.

```dart
UiDonutChart(segments: [UiChartSegment('Rent', 1200), UiChartSegment('Food', 450), UiChartSegment('Fun', 200)])
```

- `segments`: list of `UiChartSegment(label, value, {color})`. Required.
- `center`: middle widget when nothing is selected. Default: total.
- `size`: diameter. Default `180`.
- `thickness`: default `18`.
- `gap`: space between segments in pixels. Default `3`.
- `showLegend`: with percentages. Default `true`.
- `valueFormat`: default: compact numbers.
- `onSelect`: called with the selected index, or null when cleared.

### UiChartLegend

Wrapping row of color dots with labels and optional values.

```dart
UiChartLegend([UiLegendItem('Revenue', color: c.chartColor(0), value: '12k')])
```

- `items` (positional): list of `UiLegendItem(label, {color, value})`.
- `alignment`: default `WrapAlignment.start`.
- `selected`: index to highlight. Default: none.

### UiHeatmap

GitHub-style contribution grid: one cell per day, one column per week, in accent opacity steps.

```dart
UiHeatmap(values: {DateTime(2026, 3, 4): 3, DateTime(2026, 3, 5): 7}, onTap: (day) => open(day))
```

- `values`: `Map<DateTime, int>`, a count per day. Same-day entries are summed. Required.
- `weeks`: default `17`.
- `end`: last day. Default: today.
- `onTap`: called with the tapped day. Future days are ignored.
- `color`: default `colors.accent`.
- `cellSize`: largest cell size. Default `14`. Cells shrink on narrow screens.
- `cellGap`: default `3`.
- `showLabels`: months and weekdays. Default `true`.
- `showLegend`: "Less … More". Default `true`.

### UiGauge

Semicircle gauge for a 0..1 value, with the percentage and a label inside.

```dart
UiGauge(value: 0.72, label: 'Storage used', status: UiStatus.warning)
```

- `value`: 0 to 1, clamped. Required.
- `label`: default: none.
- `size`: width. Default `180`.
- `status`: arc color. Default: accent.
- `thickness`: default: 10% of the size.
- `center`: replaces the percentage text.
