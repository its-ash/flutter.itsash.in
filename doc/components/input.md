# Text inputs & form fields

Labelled text inputs, pickers and keypads. Every field shows its label above the input and its helper or error text below. Fields with a `validator` work inside a `Form`.

### UiFieldLabel
Frames any control with a label row above and a helper/error line below.
```dart
UiFieldLabel(label: 'Email', isRequired: true, trailing: forgotLink, error: err, child: myInput)
```
- `child` (required): the control.
- `label`: text above. Default `null` (no label row).
- `isRequired`: adds a red `*`. Default `false`.
- `trailing`: widget at the end of the label row. Default `null`.
- `helper`: text below. Default `null`.
- `error`: replaces `helper` in the danger color. Default `null`.
- `counter`: small text at the end of the helper row, e.g. `3 / 20`. Default `null`.
- `enabled`: disabled label color when false. Default `true`.

### UiTextField
Text input with the label above (not floating). A `FormField<String>`.
```dart
UiTextField(label: 'Email', hint: 'you@example.com', validator: UiValidators.email())
```
- `label`, `hint`, `helper`, `error`: texts. Default `null`.
- `controller` (not disposed) or `initialValue`. Default `null`.
- `onChanged`, `onSubmitted`, `onTap`: callbacks. Default `null`.
- `validator`, `onSaved`, `autovalidateMode`: form hooks. Default `null`.
- `prefixIcon` (`IconData`), `suffix` (`Widget`). Default `null`.
- `keyboardType`, `textInputAction`, `inputFormatters`, `autofillHints`. Default `null`.
- `textCapitalization`. Default `none`.
- `obscure`. Default `false`.
- `maxLines` `1`, `minLines` `null`.
- `maxLength`: limits input and shows a `n / max` counter. Default `null`.
- `readOnly` `false`, `enabled` `true`, `autofocus` `false`, `focusNode` `null`.
- `size`: `UiSize`. Default `md`.
- `isRequired` `false`, `labelTrailing` `null`.

### UiTextArea
Multi-line `UiTextField` that grows between `minLines` and `maxLines`.
```dart
UiTextArea(label: 'Bio', maxLength: 200)
```
- Same params as `UiTextField` minus the single-line ones.
- `minLines` `3`, `maxLines` `6`, `textCapitalization` `sentences`.

### UiPasswordField
Password input with a show/hide button and an optional strength meter.
```dart
UiPasswordField(showStrength: true, validator: UiValidators.minLength(8))
```
- `label`: default `'Password'`. `hint`, `helper`, `error` default `null`.
- `showStrength`: four-step bar (`UiPasswordStrength`: weak, fair, good, strong). Default `false`.
- `controller`, `onChanged`, `onSubmitted`, `validator`, `autovalidateMode`, `focusNode`, `textInputAction`. Default `null`.
- `prefixIcon`: default lock icon. `autofillHints`: default `[password]`.
- `enabled` `true`, `autofocus` `false`, `size` `md`, `isRequired` `false`, `labelTrailing` `null`.
- `UiPasswordStrength.of(text)` scores any string (null when empty).

### UiSearchField
Pill-shaped search input with a clear button and optional debounce and filter button.
```dart
UiSearchField(onChanged: search, debounce: const Duration(milliseconds: 300), onFilter: openFilters)
```
- `hint`: default `'Search'`.
- `onChanged`, `onSubmitted`, `onClear`. Default `null`.
- `debounce`: delay before `onChanged`. Default `null` (immediate).
- `onFilter`: shows a filter button. Default `null`.
- `filterActive`: accent dot on the filter button. Default `false`.
- `filterIcon`: default `Icons.tune_rounded`.
- `controller`, `focusNode`. Default `null`.
- `autofocus` `false`, `enabled` `true`, `size` `md`.

### UiStepper
Compact "− value +" control for `int` or `double`. Hold a button to repeat. Null `onChanged` disables it.
```dart
UiStepper(value: qty, min: 1, max: 10, onChanged: (v) => setState(() => qty = v))
```
- `value`, `onChanged` (required).
- `min`, `max`: bounds. Default `null`.
- `step`: default `1`.
- `decimals`: digits for doubles. Default: from `step`.
- `editable`: type the value in the middle. Default `false`.
- `expand`: fill the width. Default `false`.
- `format`: custom display text. Default `null`.
- `size` `md`, `semanticLabel` `null`.

### UiNumberField
Labelled full-width stepper whose value can also be typed (clamped to the bounds).
```dart
UiNumberField(label: 'Guests', value: guests, min: 1, max: 12, onChanged: (v) => setState(() => guests = v))
```
- Same as `UiStepper`, plus `label`, `helper`, `error`, `isRequired`.
- `editable`: default `true`.

### UiOtpField
One-time code as separate boxes. Auto-advances, backspace goes back, pasting fills every box.
```dart
UiOtpField(onCompleted: verify)
```
- `length`: default `6`.
- `onCompleted`: called once all boxes are filled. `onChanged`. Default `null`.
- `obscure`: dots instead of digits. Default `false`.
- `digitsOnly`: when false, accepts letters (upper-cased). Default `true`.
- `error`: red borders plus text. `label`, `helper`. Default `null`.
- `controller`, `focusNode`. Default `null`.
- `autofocus` `false`, `enabled` `true`.

### UiPinPad
On-screen numeric keypad with PIN dots, for lock screens. Clears after completion.
```dart
UiPinPad(length: 4, onCompleted: unlock, onBiometric: useBiometrics)
```
- `length`: default `4`.
- `onCompleted`, `onChanged`. Default `null`.
- `showDots`: default `true`.
- `error`: red dots plus text. Default `null`.
- `onBiometric`: shows a biometric key bottom-left. Default `null`.
- `biometricIcon`: default `Icons.fingerprint_rounded`.
- `clearOnComplete`: default `true`.
- `enabled`: default `true`.
- Long-press delete clears the PIN. Hardware digit and backspace keys work when focused.

### UiOption
One choice for `UiSelect` / `UiMultiSelect`.
```dart
const UiOption('fr', 'France', subtitle: 'Europe', icon: Icons.flag)
```
- `value`, `label` (positional, required).
- `subtitle`, `icon`. Default `null`.
- `enabled`: default `true`.

### UiSelect
Field-looking dropdown. Opens a bottom sheet on compact screens and an anchored menu on wider ones.
```dart
UiSelect(label: 'Country', value: country, options: countries, onChanged: (v) => setState(() => country = v))
```
- `options`, `onChanged` (required; null disables).
- `value`: default `null`.
- `label` `null`, `hint` `'Select'`, `helper` `null`, `error` `null`.
- `searchable`: adds a filter field. Default `false`. `searchHint`: `'Search'`.
- `validator`: `FormFieldValidator<T>`. Default `null`.
- `prefixIcon`: shown when the selected option has no icon. Default `null`.
- `sheetTitle`: default `label`.
- `size` `md`, `isRequired` `false`.

### UiMultiSelect
Like `UiSelect` with several values. Shows them as removable chips; the sheet has a "Done" button.
```dart
UiMultiSelect(label: 'Tags', values: tags, options: all, onChanged: (v) => setState(() => tags = v))
```
- `options`, `values`, `onChanged` (required; null disables).
- `maxChips`: chips before `+n`. Default `3`.
- `doneLabel`: default `'Done'`.
- `validator`: `FormFieldValidator<List<T>>`. Default `null`.
- Other params as `UiSelect`.

### UiAutocomplete
Text field with a suggestions list from a fixed list or an async search, with a loading row and bold match.
```dart
UiAutocomplete<String>(label: 'City', options: cities, onSelected: pick)
```
- `options`: filtered by "contains". Default `[]`.
- `search`: `Future<List<T>> Function(String)`; wins over `options`. Default `null`.
- `displayString`: default `toString()`. `subtitle`: second line. Default `null`.
- `onSelected`, `onChanged`, `validator`. Default `null`.
- `debounce`: for `search`. Default `250 ms`.
- `minChars` `1`, `maxResults` `8`, `emptyText` `'No matches'` (null hides).
- `prefixIcon`: default search icon.
- `label`, `hint`, `helper`, `error`, `controller`, `focusNode`. Default `null`.
- `enabled` `true`, `size` `md`. Arrow keys, Enter and Escape work.

### UiDateField
Read-only field that opens the date picker, with a clear button.
```dart
UiDateField(label: 'Birthday', value: date, onChanged: (d) => setState(() => date = d))
```
- `value`, `onChanged` (required; null disables). `onChanged(null)` on clear.
- `firstDate`: default 1900-01-01. `lastDate`: default 2100-12-31.
- `format`: default `UiDateFormat.date` (`Mar 5, 2026`).
- `hint`: `'Select date'`. `label`, `helper`, `error`, `validator`: `null`.
- `clearable` `true`, `size` `md`, `isRequired` `false`, `prefixIcon` calendar icon.

### UiTimeField
Read-only field that opens the time picker.
```dart
UiTimeField(label: 'Reminder', value: time, onChanged: (t) => setState(() => time = t))
```
- Same as `UiDateField` with `TimeOfDay` values.
- `format`: default `UiDateFormat.time` (follows the 24-hour setting). `hint`: `'Select time'`.

### UiDateRangeField
Read-only field that opens the date range picker.
```dart
UiDateRangeField(label: 'Trip', value: range, onChanged: (r) => setState(() => range = r))
```
- Same as `UiDateField` with `DateTimeRange` values.
- `format`: default `UiDateFormat.range` (`Mar 5 – 9, 2026`). `hint`: `'Select dates'`.

### UiDateFormat
Small formatter used by the date fields. No `intl` needed.
```dart
UiDateFormat.date(DateTime(2026, 3, 5)); // Mar 5, 2026
```
- `date(DateTime)`, `range(DateTimeRange)`, `time(BuildContext, TimeOfDay)`.

### UiTagInput
Type and press Enter or comma to add tags shown as removable pills. Backspace in an empty input removes the last one.
```dart
UiTagInput(label: 'Skills', tags: skills, onChanged: (t) => setState(() => skills = t))
```
- `tags`, `onChanged` (required; null disables).
- `suggestions`: quick-add pills while focused. Default `[]`.
- `maxTags`: limit plus `n / max` counter. Default `null`.
- `caseSensitive`: duplicates check. Default `false`.
- `hint` `'Add a tag'`. `label`, `helper`, `error`, `validator`: `null`.
- `size` `md`, `isRequired` `false`.

### UiValidators
Composable validators. All except `required` let empty values pass.
```dart
validator: UiValidators.compose([UiValidators.required(), UiValidators.email()])
```
- `required<T>({message})`: null, blank string or empty collection fails.
- `email({message})`.
- `minLength(n, {message})`, `maxLength(n, {message})`.
- `pattern(RegExp, {message})`: full match.
- `numeric({min, max, integer = false, message})`.
- `match(String? Function() other, {message})`: e.g. confirm password.
- `compose<T>([...])`: returns the first error.
