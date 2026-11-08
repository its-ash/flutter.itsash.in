# Chips

Small pills for tags, filters, and actions. Source: `lib/src/chip/`.

### UiChip
One chip. It can be a plain label, a button (`onTap`), a removable tag (`onDeleted`), or a selected filter (`selected`).
```dart
UiChip('Paid', status: UiStatus.success, icon: Icons.check_circle_rounded)
UiChip('Ana Lee', avatar: UiAvatar(name: 'Ana Lee', size: 26), onTap: openProfile)
UiChip('Inbox', icon: Icons.inbox_rounded, count: 12, variant: UiChipVariant.outline)
UiChip('Flutter', onDeleted: () => remove('Flutter'))
UiChip('Unread', selected: filter == 'Unread', onTap: () => setFilter('Unread'))
```
- `label`, `variant` (`UiChipVariant.filled`, `tonal` (default), `outline`, `soft`, `elevated`)
- `status` (`UiStatus`, uses its colors), `color` (custom color; text color is picked for contrast)
- `icon` or `avatar` (a widget clipped to a circle), `count` (badge; shows `99+` above 99)
- `selected` (draws as `filled`), `onTap`, `onDeleted` (adds an x button), `deleteTooltip` (default "Remove {label}")
- `size` (`UiSize.sm` 28, `md` 34, `lg` 40), `enabled` (false = 50% opacity, no taps)

### UiChipGroup
Lays out chips in rows that wrap, or in one row that scrolls.
```dart
UiChipGroup(scrollable: true, children: [for (final f in filters) UiChip(f, selected: f == current, onTap: () => pick(f))])
```
- `children`, `scrollable` (false = wrap), `spacing` (8), `runSpacing` (8), `padding`

### UiChoiceChips<T>
Pill chips. You can select one chip.
```dart
UiChoiceChips<String>(options: ['All', 'Men', 'Women'], value: tab, onChanged: setTab, scrollable: true)
```
- `options`, `value`, `onChanged`, `labelBuilder`, `iconBuilder`, `scrollable` (false = wrap)

### UiFilterChips<T>
Pill chips. You can select many chips.
```dart
UiFilterChips<String>(options: brands, selected: picked, onChanged: setPicked)
```
- `options`, `selected`, `onChanged`, `labelBuilder`, `iconBuilder`, `scrollable`, `showCheckmark` (true), `max`
