# Selection

Controls for picking values: checkboxes, switches, radios, settings tiles, choice cards, chips, sliders, rating and colors. A null `onChanged` / `onTap` disables a control.

### UiChoice

One option for groups, cards and chips.

```dart
const UiChoice('pro', 'Pro', description: 'For teams', icon: Icons.bolt_rounded, trailing: r'$12/mo')
```

- `value` (positional): value passed to `onChanged`.
- `label` (positional): main text.
- `description`: second line. Default `null`.
- `icon`: shown by cards and chips. Default `null`.
- `trailing`: end-side text such as a price (cards only). Default `null`.
- `enabled`: default `true`.

### UiCheckbox

Rounded-square checkbox with an animated check. The label and description sit on the right, and the whole row is tappable.

```dart
UiCheckbox(agree, label: 'I agree', onChanged: (v) => setState(() => agree = v!))
```

- `value` (positional, `bool?`): `null` shows a dash (needs `tristate`).
- `onChanged`: `ValueChanged<bool?>?`. Default `null` (disabled).
- `label`, `description`: default `null`.
- `tristate`: taps go false → true → null → false. Default `false`.
- `UiCheckbox.next(value, tristate:)`: static helper that returns the next value.

### UiCheckboxGroup

Checkboxes that edit a `Set<T>`.

```dart
UiCheckboxGroup(values: picked, options: opts, onChanged: (s) => setState(() => picked = s))
```

- `values` (required): checked values.
- `options` (required): `List<UiChoice<T>>`.
- `onChanged`: `ValueChanged<Set<T>>?`. Default `null`.
- `direction`: `Axis.vertical` (column) or `Axis.horizontal` (wrap). Default `Axis.vertical`.

### UiSwitch

iOS-style switch with an animated thumb and an accent track. Optional label on the right.

```dart
UiSwitch(wifi, label: 'Wi-Fi', onChanged: (v) => setState(() => wifi = v))
```

- `value` (positional, `bool`).
- `onChanged`: `ValueChanged<bool>?`. Default `null`.
- `label`, `description`: default `null`.

### UiRadio

One radio circle. It is selected when `value == groupValue`.

```dart
UiRadio('a', groupValue: pick, label: 'Option A', onChanged: (v) => setState(() => pick = v))
```

- `value` (positional), `groupValue` (required).
- `onChanged`: `ValueChanged<T>?`. Default `null`.
- `label`, `description`: default `null`.

### UiRadioGroup

A list of radios built from options.

```dart
UiRadioGroup(value: size, options: sizes, onChanged: (v) => setState(() => size = v))
```

- `value` (required, `T?`), `options` (required).
- `onChanged`: default `null`.
- `direction`: default `Axis.vertical`.

### UiSwitchTile, UiCheckboxTile, UiRadioTile

Settings rows. Each has an optional icon in a tinted square, a title, a subtitle, and the control on the end side. The whole row is tappable.

```dart
UiSwitchTile('Notifications', value: on, icon: Icons.notifications_rounded, onChanged: (v) => setState(() => on = v))
UiCheckboxTile('Remember me', value: remember, onChanged: (v) => setState(() => remember = v!))
UiRadioTile('Dark', value: ThemeMode.dark, groupValue: mode, onChanged: (v) => setState(() => mode = v))
```

- `title` (positional).
- `value` (required). `UiRadioTile` also needs `groupValue`.
- `onChanged`: default `null` (disabled).
- `subtitle`, `icon`: default `null`.
- `status`: tint of the icon square. Default `UiStatus.accent`.
- `tristate` (`UiCheckboxTile` only): default `false`.

### UiChoiceCards

Selectable cards with an icon, title, description and trailing text (such as a price). A selected card gets an accent border, a soft accent tint and a check badge. Use it for plan pickers and onboarding questions.

```dart
UiChoiceCards(options: plans, value: plan, onChanged: (v) => setState(() => plan = v))
UiChoiceCards.multi(options: goals, values: picked, onChanged: (s) => setState(() => picked = s))
```

- `options` (required).
- `value` + `onChanged: ValueChanged<T>?` (single), or `.multi` with `values` + `onChanged: ValueChanged<Set<T>>?`.
- `columns`: cards per row. Default `null`, which gives 1 on phones, 2 on tablets and 3 on desktop. Cards never get narrower than 140 px.
- `spacing`: default `UiSpace.md`.
- `multi`: read-only, `true` for `.multi`.

### UiChip

Pill chip for tags, filters and choices. With `onTap` it acts as a button or toggle. With `onDeleted` it shows a remove button. With neither, it is a static label.

```dart
UiChip('Design', selected: on, onTap: () => setState(() => on = !on))
UiChip('flutter', onDeleted: () => remove('flutter'))
```

- `label` (positional).
- `icon`: default `null`. `avatar`: a widget clipped to a circle. Default `null`.
- `selected`: accent tint, accent border and a check mark. Default `false`.
- `onTap`, `onDeleted`: default `null`.
- `status`: color of an unselected chip. Default `UiStatus.neutral`.
- `variant`: `UiChipVariant.outline` (default), `.soft` or `.filled`.
- `size`: default `UiSize.md` (heights 28 / 34 / 40).
- `enabled`: `false` greys the chip out. Default `true`.
- `showCheck`: show a check when selected and there is no icon. Default `true`.

### UiChipGroup

Lays out chips in wrapping lines, or in one horizontal scrolling row.

```dart
UiChipGroup(scrollable: true, children: [for (final t in tags) UiChip(t)])
```

- `children` (required).
- `scrollable`: default `false`.
- `spacing`, `runSpacing`: default `UiSpace.sm`.
- `padding`: default `EdgeInsets.zero`.

### UiFilterChips

Multi-select chips built from options.

```dart
UiFilterChips(options: tags, values: picked, onChanged: (s) => setState(() => picked = s))
```

- `options`, `values` (required).
- `onChanged`: `ValueChanged<Set<T>>?`. Default `null`.
- `scrollable`: default `false`. `size`: default `UiSize.md`.

### UiChoiceChips

Single-select chips built from options.

```dart
UiChoiceChips(options: sizes, value: size, onChanged: (v) => setState(() => size = v))
```

- `options`, `value` (required).
- `onChanged`: `ValueChanged<T>?`. Default `null`.
- `scrollable`: default `false`. `size`: default `UiSize.md`.

### UiSlider

Slider with a label row. The current value shows on the end side.

```dart
UiSlider(value: volume, label: 'Volume', onChanged: (v) => setState(() => volume = v))
```

- `value` (required).
- `onChanged`, `onChangeEnd`: default `null`.
- `min`: default `0`. `max`: default `1`. `divisions`: default `null`.
- `label`: default `null`. `showValue`: default `true`.
- `format`: `String Function(double)?`. Default shows a short number.

### UiRangeSlider

Two-thumb slider for a range. The label row shows "start – end".

```dart
UiRangeSlider(values: price, max: 500, label: 'Price', onChanged: (r) => setState(() => price = r))
```

- `values` (required, `RangeValues`).
- The other params match `UiSlider`.

### UiRating

Star rating. Tap or drag to set it. It is read-only when `onChanged` is null.

```dart
UiRating(value: stars, onChanged: (v) => setState(() => stars = v))
```

- `value` (required, `double`).
- `onChanged`: default `null`.
- `count`: default `5`.
- `size`: default `UiSize.md` (stars 18 / 26 / 34).
- `allowHalf`: default `false`.
- `icon`: default `Icons.star_rounded`.

### UiColorPicker

Color swatches that wrap onto new lines. The selected swatch gets a ring and a check.

```dart
UiColorPicker(value: color, colors: context.colors.chart, onChanged: (c) => setState(() => color = c))
```

- `value` (required, `Color?`), `colors` (required).
- `onChanged`: default `null`.
- `size`: default `UiSize.md` (swatches 26 / 32 / 40).
- `labels`: screen reader names. Default `'Color 1'`, `'Color 2'`, and so on.
- `spacing`: default `UiSpace.xs`.
