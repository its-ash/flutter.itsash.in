# Data display

Widgets that show content: cards, lists, avatars, badges, tables, timelines, text helpers and formatters.

### UiCard
A rounded container with optional header, footer and press feedback.
```dart
UiCard(onTap: open, child: Text('Hello'))
```
- `child` (required)
- `padding` = `EdgeInsets.all(UiSpace.lg)`
- `onTap`, `onLongPress`: null means not tappable
- `variant` = `UiCardVariant.outlined` (`outlined`, `filled`, `elevated`, `ghost`)
- `selected` = `false`: accent border and soft ring
- `header`, `footer`: shown with a divider
- `radius` = `UiRadius.lg`, `semanticLabel`

### UiListTile
A row with a title, subtitle, leading and trailing parts. In a `UiListGroup` its divider starts under the text.
```dart
UiListTile('Wi-Fi', icon: Icons.wifi_rounded, value: 'Home', chevron: true, onTap: open)
```
- `title` (positional), `subtitle`
- `leading` widget, or `icon` + `iconStatus` = `UiStatus.accent` / `iconColor` for a `UiIconBox`
- `value`: short muted text at the end. `trailing`: any widget
- `onTap`, `onLongPress`: null means not interactive (still looks normal)
- `chevron` = `false`, `dense` = `false`, `destructive` = `false`, `selected` = `false`
- `enabled` = `true`: false greys the row out and ignores taps
- `maxSubtitleLines` = `2`

### UiIconBox
An icon in a tinted rounded square.
```dart
UiIconBox(Icons.bolt_rounded, status: UiStatus.warning)
```
- `icon` (positional)
- `status` = `UiStatus.accent`, or `color` for a custom tint
- `size` = `32`, `solid` = `false`

### UiListGroup
An iOS-style grouped list: a rounded surface with hairline dividers and captions. Good for settings screens.
```dart
UiListGroup(header: 'Account', children: [UiListTile('Profile', chevron: true, onTap: open)])
```
- `children` (required)
- `header`, `footer`: caption text
- `inset` = `true`: rounded card. False means full width with top and bottom borders only
- `dividers` = `true`

### UiAvatar
A picture, initials or icon, with an optional status dot. The tint comes from the name, so it is always the same for the same name.
```dart
UiAvatar(name: 'Ada Lovelace', image: NetworkImage(url), status: UiStatus.success)
```
- `name`: gives the initials and the tint
- `image`: shows initials while it loads and if it fails
- `icon`: used when there is no name (default person icon)
- `size` = `UiSize.md` (32 / 40 / 56), or `diameter` in px
- `status`: `success` online, `warning` away, `danger` busy, `neutral` offline
- `shape` = `UiAvatarShape.circle` (`circle`, `rounded`)
- `color`: custom tint. `semanticLabel`
- Helpers: `UiAvatar.initialsOf(name)`, `UiAvatar.sizeOf(size)`

### UiAvatarGroup
Overlapping avatars with a "+N" chip.
```dart
UiAvatarGroup(avatars: [for (final u in users) UiAvatar(name: u.name)], max: 3)
```
- `avatars` (required)
- `max` = `4`, `size` = `UiSize.md`, `overlap` = `0.3`

### UiBadge
Puts a count or a dot on the corner of a child.
```dart
UiBadge(count: unread, child: Icon(Icons.notifications_rounded))
```
- `child` (required)
- `count`: 0 or null hides it. `max` = `99` shows `99+`
- `dot` = `false`, `status` = `UiStatus.danger`
- `show` = `true`: animated hide. `offset` = `Offset.zero`
- `UiBadge.standalone(count: 3)` gives an inline badge (or a dot)

### UiCountBadge
An inline count pill, e.g. next to a menu label.
```dart
UiCountBadge(5)
```
- `count` (positional), `status` = `UiStatus.danger`, `max` = `99`, `ring` = `false`

### UiStatusPill
A soft tinted pill for a state, with an optional pulsing dot or icon.
```dart
UiStatusPill('Online', status: UiStatus.success, pulse: true)
```
- `label` (positional), `status` = `UiStatus.neutral`
- `dot` = `false`, `pulse` = `false` (pulse adds the dot), `icon`
- `size` = `UiSize.sm`

### UiTag
A small rectangular label, can be removable.
```dart
UiTag('Design', color: Colors.purple, onRemove: () => remove('Design'))
```
- `label` (positional)
- `color` (custom tint) or `status`. Neither gives a neutral outlined tag
- `icon`, `onRemove`

### UiKbd
A keyboard key chip.
```dart
UiKbd('⌘K')
```
- `keys` (positional)

### UiStatCard
A KPI card with a label, a big value and a colored change.
```dart
UiStatCard(label: 'Revenue', value: '\$12.4k', delta: 8.2, deltaLabel: 'vs last week')
```
- `label`, `value` (required)
- `delta`: shown as `+8.2%`. Its sign picks the trend. `deltaUnit` = `'%'`, `deltaLabel`
- `trend`: `UiTrend.up` / `down` / `neutral`, overrides the sign
- `invertColors` = `false`: use when down is good (costs, errors)
- `icon`, `iconStatus` = `UiStatus.accent`, `footer`, `onTap`, `variant` = `UiCardVariant.outlined`

### UiKeyValue
A description row with the label on the left and the value on the right.
```dart
UiKeyValue('Order ID', 'A-10294', copyable: true, mono: true)
```
- `label`, `value` (positional)
- `copyable` = `false`, `mono` = `false`, `stacked` = `false` (label above value), `maxLines` = `2`
- `UiKeyValue.custom('Owner', child: UiAvatar(name: 'Ada'))` for a widget value

### UiKeyValueList
A list of `UiKeyValue` rows.
```dart
UiKeyValueList([UiKeyValue('Status', 'Paid'), UiKeyValue('Total', '\$42.00')])
```
- `entries` (positional), `dividers` = `true`
- `UiKeyValueList.map({'Status': 'Paid'})`

### UiTable
A bordered data table with sortable headers, row taps and striped rows. It scrolls sideways when it is wider than the screen.
```dart
UiTable<User>(columns: [UiTableColumn('Name', text: (u) => u.name, sortBy: (u) => u.name)], rows: users)
```
- `columns`, `rows` (required)
- `onRowTap(row)`, `striped` = `false`, `dense` = `false`, `emptyMessage` = `'No data'`
- `initialSortColumn`, `initialSortAscending` = `true`, `onSort(column, ascending)`
- `UiTableColumn<T>(label, {text, builder, sortBy, width, numeric = false, mono = false})`. Pass `text: (row) => String` or `builder: (context, row) => Widget`. Columns fit their content unless `width` is set

### UiTimeline
A vertical list of events joined by a line.
```dart
UiTimeline(items: [UiTimelineItem('Order placed', time: '09:41', status: UiStatus.success)])
```
- `items` (required)
- `UiTimelineItem(title, {time, description, icon, status = UiStatus.neutral, content})`

### UiAccordion
Sections that expand and collapse, with a rotating chevron.
```dart
UiAccordion(items: [UiAccordionItem('Shipping', Text('2–4 business days'))])
```
- `items` (required)
- `multiple` = `false`: when false, opening one section closes the others
- `onChanged(index, expanded)`
- `UiAccordionItem(title, child, {subtitle, icon, initiallyExpanded = false})`

### UiExpandableText
Long text cut to a few lines, with "Read more / Show less". The toggle shows only when the text is too long.
```dart
UiExpandableText(post.body, maxLines: 3)
```
- `text` (positional), `maxLines` = `3`, `style`
- `moreLabel` = `'Read more'`, `lessLabel` = `'Show less'`, `initiallyExpanded` = `false`

### UiHighlightText
Text with every match of a search term highlighted. Case does not matter.
```dart
UiHighlightText(contact.name, query)
```
- `text`, `query` (positional), `style`, `maxLines`, `overflow`
- `UiHighlightText.matches(text, query)` returns the match ranges

### UiCodeText
Inline monospace code or ID on a muted chip.
```dart
UiCodeText('A1B2-C3D4', copyable: true)
```
- `code` (positional), `copyable` = `false`, `fontSize` = `13`

### UiCodeBlock
A block of monospace code with an optional title bar and copy button.
```dart
UiCodeBlock('flutter pub add theme', title: 'Terminal')
```
- `code` (positional), `title`, `copyable` = `true`
- `wrap` = `false`: long lines scroll sideways. `fontSize` = `13`

### UiFileTile
A file row with a type icon, name, size and optional progress. Good for downloaders, file transfer, recovery and scanner apps.
```dart
UiFileTile(name: 'movie.mkv', size: bytes, progress: 0.4, onTap: open)
```
- `name` (required): the extension picks the icon and tint (`UiFileKind`)
- `size` in bytes, shown as KB / MB / GB. With `progress` it reads `512 MB of 1 GB`
- `subtitle`, `progress` (0..1, null hides the bar)
- `status`: colors the bar and meta text (e.g. `danger` for failed)
- `icon`, `leading` (e.g. a thumbnail), `trailing`, `onTap`, `onLongPress`, `selected` = `false`
- `UiFileKind.fromName(name)`: `image`, `video`, `audio`, `pdf`, `archive`, `document`, `code`, `apk`, `generic`

### UiCountdown
A ring that drains smoothly and turns warning, then danger, near the end. Good for OTP codes and timers.
```dart
UiCountdown(period: Duration(seconds: 30), remaining: left, repeat: true, onComplete: refresh)
```
- `period` (required): the ring is full at this value
- `remaining` (default `period`) or `endsAt` (wall-clock end). Keep `endsAt` in state; a new value computed in `build` restarts the countdown on every rebuild
- `size` = `UiSize.md` (32 / 44 / 72), or `diameter`
- `onComplete`, `repeat` = `false` (starts a new period each time)
- `label`: inside the ring when large, beside it otherwise
- `showText` = `true`, `warningBelow` = `0.34`, `dangerBelow` = `0.17`

### UiFormat
Small formatters that don't need `intl`.
```dart
UiFormat.bytes(1536); // 1.5 KB
```
- `bytes(int, {decimals = 1})`: `512 B`, `1.5 KB`, `3.4 GB`
- `compact(num, {decimals = 1})`: `999`, `1.2k`, `3.4M`
- `relativeTime(DateTime, {now})`: `just now`, `5m`, `3h`, `2d`, `Mar 5`, `Mar 5, 2024`, `in 5m`
- `duration(Duration)`: `4:09`, `1:05:09`
