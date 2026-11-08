# Inputs

Form fields and value inputs. Source: `lib/src/input/`. All inputs use theme colors. They work in light and dark mode. A null `onChanged` or `onPressed` disables the input.

Related: [dropdown.md](dropdown.md) (dropdowns, autocomplete), [selection.md](selection.md) (checkbox, switch, radio, segmented), [chip.md](chip.md), [button.md](button.md).

### UiFieldLabel
Shows a small bold label above a field.
```dart
UiFieldLabel('Notes', child: myField)
```
- `label` (String?), `child`, `isRequired` (adds `*`), `trailing` (Widget?)

### UiTextField
Filled text field with the label above it. Works inside a `Form`.
```dart
UiTextField('Name', isRequired: true)
UiTextField.email(controller: email)
UiTextField.phone()
UiTextField.number(label: 'Weight', decimal: true)
UiTextField.multiline('Bio')
UiTextField.name()
```
- `label`, `hint`, `controller`, `initialValue`, `onChanged`, `onSubmitted`, `validator`
- `prefixIcon` (IconData), `suffix` (Widget), `keyboardType`, `textInputAction`
- `maxLines` (1), `minLines`, `maxLength`, `inputFormatters`, `obscureText`
- `enabled`, `readOnly`, `autofocus`, `onTap`, `helper`, `error`, `isRequired`, `focusNode`
- Named constructors set the keyboard, autofill, input filter, and validation. Your `validator` runs after the built-in check.

### UiPasswordField
Password field with a show/hide button. It can show a strength bar.
```dart
UiPasswordField(showStrength: true, minLength: 8, newPassword: true)
```
- `label` ('Password'), `hint`, `controller`, `onChanged`, `onSubmitted`, `validator`
- `showStrength`, `minLength`, `isRequired`, `newPassword` (autofill hint), `enabled`, `textInputAction`
- `UiPasswordField.strengthOf(text)` returns `UiPasswordStrength` (`none`, `weak`, `medium`, `strong`).

### UiSearchField
Pill search field. It has a clear button and a debounced `onChanged`.
```dart
UiSearchField(onChanged: search, onFilterTap: openFilters, filterCount: 2)
```
- `hint` ('Search'), `controller`, `onChanged`, `onSubmitted`, `onClear`
- `debounce` (300 ms; zero = no delay), `onFilterTap` (shows filter button), `filterCount` (badge)
- `readOnly` + `onTap` (use as a tap target that opens a search page), `autofocus`, `enabled`

### UiOtpField
Code input with one box for each character. It moves to the next box automatically. Backspace goes back. Paste fills all boxes.
```dart
UiOtpField(onCompleted: verify, error: failed ? 'Wrong code' : null)
```
- `length` (6, clamped 4..8), `onCompleted`, `onChanged`, `controller`
- `obscure`, `numeric` (true; false = letters and digits), `error` (an empty string shows the red boxes without text), `autofocus`, `enabled`, `focusNode`

### UiSlider
Slider with a label and the value above it.
```dart
UiSlider(value: vol, onChanged: setVol, label: 'Volume', format: (v) => '${v.round()}%')
```
- `value` (clamped), `onChanged`, `onChangeEnd`, `min` (0), `max` (100), `divisions`, `label`, `format`, `showValue` (true)

### UiRangeSlider
Range slider, for example a price range. It shows Min and Max boxes.
```dart
UiRangeSlider(values: price, onChanged: setPrice, max: 1000, label: 'Price', format: (v) => '\$${v.round()}')
```
- `values` (RangeValues, clamped and ordered), `onChanged`, `onChangeEnd`, `min`, `max`, `divisions`, `label`, `format`
- `showInputs` (true; false = show the range in the header)

### UiNumberStepper
`−  value  +` in a pill. A button is disabled at its limit.
```dart
UiNumberStepper(value: qty, onChanged: setQty, min: 1, max: 10)
```
- `value` (int, clamped), `onChanged`, `min` (0), `max` (99), `step` (1), `size` (`UiSize.md`), `label` (for screen readers), `format`
- `onRemove`: at `min`, the minus button changes to a red delete button that calls `onRemove`.

### UiDateField
Read-only field. A tap opens the date picker.
```dart
UiDateField(value: dob, onChanged: setDob, label: 'Date of birth')
```
- `value` (DateTime?), `onChanged`, `label`, `hint`, `firstDate` (1900), `lastDate` (2100)
- `format` (default `UiFormat.date`, for example "12 Mar 2026"), `validator`, `isRequired`, `clearable`, `helper`, `icon`

### UiTimeField
Read-only field. A tap opens the time picker.
```dart
UiTimeField(value: time, onChanged: setTime, label: 'Start')
```
- `value` (TimeOfDay?), `onChanged`, `label`, `hint`, `format` (default "9:05 AM", or 24 h if the device uses it), `validator`, `isRequired`, `clearable`

### UiDateRangeField
Read-only field. A tap opens the date range picker.
```dart
UiDateRangeField(value: stay, onChanged: setStay, label: 'Check-in – Check-out')
```
- `value` (DateTimeRange?), `onChanged`, `label`, `hint`, `firstDate`, `lastDate`, `format`, `validator`, `isRequired`, `clearable`

The date fields use `UiFormat`. Refer to [foundation.md](foundation.md#formatting).

### UiTagInput
Type a tag, then push Enter or type a comma to add it. Tap x to remove a tag. Backspace in an empty field removes the last tag.
```dart
UiTagInput(tags: tags, onChanged: setTags, label: 'Skills', maxTags: 5)
```
- `tags`, `onChanged`, `label`, `hint` ('Add tag'), `maxTags`, `maxLength` (32), `caseSensitive` (false), `enabled`
- Tags are trimmed. Empty and duplicate tags are ignored.

### UiColorSwatchPicker
Round color swatches. The selected swatch has a ring and a check mark.
```dart
UiColorSwatchPicker(colors: [Colors.black, Colors.red], value: color, onChanged: setColor)
```
- `colors`, `value`, `onChanged`, `size` (40), `scrollable`, `labels` (names for screen readers)

### UiRatingInput
Tap or drag on the stars to set a rating.
```dart
UiRatingInput(value: stars, onChanged: setStars, allowHalf: true)
```
- `value` (clamped 0..max), `onChanged`, `max` (5), `size` (36), `allowHalf`, `spacing`

### UiFormSection
Puts fields in a column with equal space. It can show a title.
```dart
UiFormSection(title: 'Shipping', children: [UiTextField.name(), UiTextField.phone()])
```
- `children`, `title`, `subtitle`, `trailing`, `spacing` (`UiSpace.lg`), `padding`
