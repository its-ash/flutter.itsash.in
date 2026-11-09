# Layout

Page scaffolds, content width, sections, dividers, gaps, responsive grids and split views. Import `package:theme/theme.dart`.

### UiScaffold
Page scaffold with page padding, optional scrolling, optional centered max width, safe area, and tap outside to close the keyboard.

```dart
UiScaffold(appBar: const UiAppBar(title: 'Profile'), scrollable: true, maxWidth: 720, body: form);
```

- `body` (required).
- `appBar`, `bottomBar`, `fab`, `drawer`, `endDrawer`, `backgroundColor`.
- `padding`: default page padding on the sides (20 / 24 / 32 by width), 16 top, 24 bottom. `EdgeInsets.zero` for edge to edge.
- `scrollable`: wrap the body in a scroll view. Default `false`.
- `maxWidth`: center the body with this max width. Default `null` (full width).
- `safeArea`: default `true`.
- `dismissKeyboard`: tap outside closes the keyboard. Default `true`.
- `onRefresh`: pull to refresh (when `scrollable`).

### UiContent
Centers its child with a max width and page padding. The child fills the width up to the max.

```dart
UiContent(child: Text('Readable on any screen'));
```

- `child` (required).
- `maxWidth`: default `720`.
- `padding`: default horizontal page padding.
- `UiContent.pagePadding(context)`: the page padding for the current width (20, 24 or 32).

### UiSection
A section header above its content.

```dart
UiSection(title: 'Recent', actionLabel: 'See all', onAction: openAll, child: list);
```

- `child` (required).
- `title`: null shows no header.
- `subtitle`, `actionLabel`, `onAction`, `action`: as in `UiSectionHeader`.
- `padding`: space around the section. Default `EdgeInsets.zero`.
- `gap`: space between header and content. Default `UiSpace.md` (12).

### UiSectionHeader
Title row with optional subtitle and trailing action.

```dart
UiSectionHeader('Recent', actionLabel: 'See all', onAction: openAll);
```

- `title` (positional).
- `subtitle`: second line.
- `actionLabel` + `onAction`: trailing text button. Null `onAction` disables it.
- `action`: custom trailing widget. Used instead of `actionLabel`.
- `padding`: default `EdgeInsets.zero`.

### UiDivider
Hairline divider, horizontal or vertical, with an optional centered label.

```dart
const UiDivider(label: 'or');
```

- `label`: text in the middle (horizontal only).
- `vertical`: default `false`.
- `indent`: space before the line. Default `0`.
- `endIndent`: space after the line. Default `indent`.
- `space`: total height (or width when vertical). Default `1`.
- `color`: default `colors.border`.

### UiColumn
`Column` with a gap between children.

```dart
UiColumn(gap: UiSpace.lg, children: [title, body, actions]);
```

- `children` (required).
- `gap`: default `UiSpace.md` (12).
- `mainAxisAlignment` (start), `crossAxisAlignment` (start), `mainAxisSize` (max).

### UiRow
`Row` with a gap between children.

```dart
UiRow(children: [const Icon(Icons.star), Expanded(child: Text(label))]);
```

- `children` (required).
- `gap`: default `UiSpace.sm` (8).
- `mainAxisAlignment` (start), `crossAxisAlignment` (center), `mainAxisSize` (max).

### UiResponsiveGrid
Grid that picks its column count from the available width. Items are never narrower than `minItemWidth`, and nothing overflows. Not lazy.

```dart
UiResponsiveGrid(minItemWidth: 160, children: [for (final p in products) ProductCard(p)]);
```

- `children` (required).
- `minItemWidth`: default `160`. Always at least one column.
- `spacing`: space between columns. Default `UiSpace.md` (12).
- `runSpacing`: space between rows. Default `spacing`.
- `maxColumns`: upper limit. Default none.
- `equalHeight`: items in a row match the tallest. Default `false`.
- `UiResponsiveGrid.columnsFor(width, ...)`: the column count for a width.

### UiResponsiveLayout
Shows a different widget per size class (compact, medium, expanded, large). Missing classes fall back to the next smaller one.

```dart
UiResponsiveLayout(compact: const PhoneHome(), expanded: const TabletHome());
UiResponsiveLayout.builder(builder: (context, bp) => bp == UiBreakpoint.compact ? list : grid);
```

- `compact` (required), `medium`, `expanded`, `large`.
- `.builder(builder: (context, breakpoint) => ...)`: build from the breakpoint.
- `local`: use the parent's width instead of the screen width. Default `false`.

### UiSplitView
Master-detail layout. Side by side on wide widths. One pane on narrow widths: `secondary` when set, otherwise `primary`.

```dart
UiSplitView(primary: list, secondary: selected == null ? null : Details(selected), onCloseSecondary: clear);
```

- `primary` (required): the list pane. Keeps its state in both modes.
- `secondary`: the detail pane. Null means nothing is selected.
- `placeholder`: shown in the detail pane on wide widths when nothing is selected.
- `breakpoint`: smallest size class that shows both panes. Default `UiBreakpoint.expanded` (840 px). Uses the widget's own width.
- `primaryWidth`: default `360` (at most 45% of the width).
- `onCloseSecondary`: called on system back while the detail fills a narrow screen.
- `divider`: hairline between panes. Default `true`.

### UiBottomBar
Sticky bottom action area with a top hairline and surface fill. Stays above the home indicator and the keyboard.

```dart
UiScaffold(body: form, bottomBar: UiBottomBar(child: FilledButton(onPressed: save, child: const Text('Save'))));
```

- `child`: one widget, stretched to full width. Or `children`: equal-width row.
- `gap`: space between `children`. Default `UiSpace.sm` (8).
- `padding`: default 20 sides, 12 top and bottom (safe area added).
- `maxWidth`: content max width on wide screens. Default `720`.
- `border`: top hairline. Default `true`.
- `keyboardAware`: moves above the keyboard. Default `true`.

### UiSurface
Generic container: surface fill, 1 px border, rounded corners, optional shadow, status tint and tap.

```dart
UiSurface(tone: UiStatus.success, child: Text('Saved'));
```

- `child` (required).
- `padding`: default `EdgeInsets.all(16)`.
- `margin`: default none.
- `radius`: default `UiRadius.lg` (18).
- `color`: default `colors.surface` (or the tone's soft color).
- `tone`: `UiStatus` tint for fill and border.
- `border`: 1 px border. Default `true`. `borderColor` overrides the color.
- `shadow`: such as `context.shadowMd`. Default none.
- `onTap`: makes it tappable with a ripple.
- `width`, `height`: fixed size.
