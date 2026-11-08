# Display

Widgets that show data and content. Source: `lib/src/display/`. Charts use `CustomPainter` and need no packages. All charts accept empty data, one point, and all-zero data. Images, the carousel, and the image viewer are in [image.md](image.md).

### UiTag
A small status pill.
```dart
UiTag('Delivered', status: UiStatus.success, icon: Icons.check)
```
- `label`, `status`, `icon`, `solid`, `size`, `color`.

### UiRatingStars
Shows a star rating with half stars.
```dart
UiRatingStars(4.5, count: 128, showValue: true)
```
- `rating`, `max`, `size`, `count`, `showValue`.

### UiMarquee
One line of text. If the text is wider than the space, it scrolls sideways in a loop, like a news ticker. If it fits, it stays still.
```dart
UiMarquee('Free shipping on orders over \$50. Use code SUN25.', style: context.text.titleMedium)
```
- `text`, `style`, `velocity` (40 px per second), `gap` (48 px between copies), `pause` (1 s at the start of each loop), `fadeEdges` (true)
- It stops and shows the text with `…` when the device asks for less motion.

### UiAvatarGroup
Stacked avatars with a `+N` tile.

```dart
UiAvatarGroup(names: ['Ana Lee', 'Bo Chen', 'Cy Ray'], images: [url1, null, url3], total: 24);
```
- `UiAvatarGroup({images, names, size = 36, max = 4, total, overlap = 0.3, onTap})`

### UiStatCard
Card with a label, a big value, an optional icon, a change percent, and a sparkline.

```dart
UiStatCard(label: 'Revenue', value: '\$12.4k', icon: Icons.payments_rounded, delta: 8.2, sparkline: [3, 5, 4, 7, 9]);
```
- `UiStatCard({required label, required value, icon, delta, invertDelta, caption, sparkline, status, onTap, variant})`
- Set `invertDelta: true` when a drop is good (for example, expenses).

### UiDelta
Up or down change pill with color.

```dart
const UiDelta(-3.5);
```
- `UiDelta(value, {invert, suffix = '%', solid})`

### UiKeyValue and UiKeyValueList
Label and value rows. The list can show dividers and a bold total row.

```dart
UiKeyValueList.fromMap({'Subtotal': '\$40', 'Shipping': 'Free'}, total: ('Total', '\$40'));
```
- `UiKeyValue(label, value, {icon, trailing, emphasis, valueColor, onTap, padding})`
- `UiKeyValueList(List<UiKeyValue> items, {divided, total, totalColor})`
- `UiKeyValueList.fromMap(Map<String, String> map, {divided, total, totalColor})`

### UiTimeline
Vertical steps. Completed, current, and pending steps have different styles.

```dart
UiTimeline(const [
  UiTimelineItem('Ordered', time: '09:12', done: true),
  UiTimelineItem('Shipped', subtitle: 'In transit', current: true),
  UiTimelineItem('Delivered'),
]);
```
- `UiTimeline(items, {dense})`
- `UiTimelineItem(title, {subtitle, time, done, current, icon, status, content})`

### UiSparkline
Small trend line with an optional gradient area.

```dart
UiSparkline([4, 6, 5, 9, 12], height: 40);
```
- `UiSparkline(values, {color, fill = true, height = 40, width, strokeWidth = 2, smooth = true, animate})`

### UiLineChart
Line chart with a smooth curve, grid lines, axis values, x labels, and dots.

```dart
UiLineChart([12, 18, 9, 22, 30], labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri']);
```
- `UiLineChart(values, {labels, color, height = 200, smooth, dots, grid, fill, gridLines = 4, format, emptyText, animate})`

### UiBarChart
Rounded bars that grow on first show. Tap a bar to select it and see its value. Negative values show as zero.

```dart
UiBarChart([5, 8, 3, 10], labels: ['Q1', 'Q2', 'Q3', 'Q4'], highlight: 3);
```
- `UiBarChart(values, {labels, highlight, color, height = 180, onSelect, format, showValues, emptyText, animate})`

### UiDonutChart
Donut chart with segments, a center text, and a legend.

```dart
UiDonutChart(const [UiChartSegment('Food', 420), UiChartSegment('Rent', 900)], centerText: '\$1.3k', centerLabel: 'Spent');
```
- `UiDonutChart(segments, {size = 160, thickness = 22, center, centerText, centerLabel, legend = true, animate})`
- `UiChartSegment(label, value, {color})`. Colors come from the theme when not set.

### UiProgressSegments
Stacked bar of parts, or a step bar.

```dart
UiProgressSegments(const [UiChartSegment('Used', 60), UiChartSegment('Free', 40)], legend: true);
const UiProgressSegments.steps(total: 5, done: 2);
```
- `UiProgressSegments(segments, {height = 10, legend})`
- `UiProgressSegments.steps({required total, required done, height = 6, color})`

### uiCompactNumber
Formats numbers as `1.2k`, `3M`, `4B`. Charts use it by default.

### UiDots
Page indicator. The active dot is wider.

```dart
UiDots(count: 4, index: page);
```
- `UiDots({required count, required index, color, onTap})`

### UiExpandableText
Text that collapses after `maxLines` and shows "Read more" and "Read less".

```dart
UiExpandableText(description, maxLines: 3);
```
- `UiExpandableText(text, {maxLines = 3, style, moreLabel, lessLabel})`

### UiCountdown
Countdown boxes for days, hours, minutes, and seconds. Calls `onDone` one time at zero.

```dart
UiCountdown(target: sale.endsAt, onDone: refresh);
UiCountdown(duration: const Duration(minutes: 5), size: UiSize.sm);
```
- `UiCountdown({target, duration, onDone, showDays, labels = true, size = md, status})`

### UiInfoTile
Small stat in a tonal rounded box.

```dart
UiInfoTile(icon: Icons.local_fire_department_rounded, title: 'Calories', value: '540');
```
- `UiInfoTile({required icon, required title, required value, status, onTap, horizontal})`

### UiFeatureList
List with check icons. Excluded items show a cross and a line through.

```dart
UiFeatureList(['Free delivery', '24/7 support'], excluded: ['Priority booking']);
```
- `UiFeatureList(items, {excluded, icon, color, dense})`

### UiChipList
Read-only tags. Extra tags show as `+N`.

```dart
UiChipList(['Vegan', 'Gluten free', 'Spicy'], max: 2);
```
- `UiChipList(items, {status, max, icon, size, spacing})`

### UiQuoteCard
Quote or review card with author, avatar, and rating.

```dart
UiQuoteCard('Best gym in town.', author: 'Sam K', subtitle: 'Member since 2023', rating: 5);
```
- `UiQuoteCard(quote, {author, subtitle, avatarUrl, rating})`
