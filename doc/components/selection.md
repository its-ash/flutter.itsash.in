# Selection

Checkbox, switch, radio, and segmented controls. Source: `lib/src/selection/`. A null `onChanged` disables the control.

### UiCheckboxTile
Rounded row with a checkbox. Tap anywhere on the row to toggle.
```dart
UiCheckboxTile('Accept terms', value: ok, onChanged: (v) => setState(() => ok = v))
```
- `title`, `value`, `onChanged`, `subtitle`, `leading` (IconData)

### UiSwitchTile
Rounded row with a switch. Tap anywhere on the row to toggle.
```dart
UiSwitchTile('Notifications', value: on, onChanged: (v) => setState(() => on = v))
```
- `title`, `value`, `onChanged`, `subtitle`, `leading`

### UiRadioGroup<T>
Select one option from a list of rows or chips.
```dart
UiRadioGroup<Plan>(options: Plan.values, value: plan, onChanged: setPlan, labelBuilder: (p) => p.name)
```
- `options`, `value`, `onChanged`, `labelBuilder`, `subtitleBuilder`, `iconBuilder`
- `layout` (`UiRadioLayout.list` or `.chips`), `label`, `spacing`

### UiCheckboxGroup<T>
Select many options from a list of checkbox rows.
```dart
UiCheckboxGroup<String>(options: goals, values: picked, onChanged: setPicked, max: 3)
```
- `options`, `values`, `onChanged` (gets the list in option order), `labelBuilder`, `subtitleBuilder`, `iconBuilder`, `label`, `max`, `spacing`

### UiSegmented<T>
Pill segmented control. A thumb slides to the selected segment.
```dart
UiSegmented<String>(options: ['Day', 'Week', 'Month'], value: range, onChanged: setRange)
```
- `options`, `value`, `onChanged`, `labelBuilder`, `iconBuilder`, `size` (`UiSize.sm`/`md`/`lg`)
