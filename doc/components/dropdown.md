# Dropdowns

Pick one or many items from a list. Source: `lib/src/dropdown/`. A null `onChanged` disables the field. All fields work inside a `Form`.

Use `UiDropdown` for short, fixed lists. Use `UiSearchableDropdown` or `UiMultiSelectDropdown` for long lists or for lists that come from a server. Use `UiAutocomplete` when the user types free text and picks a suggestion.

### UiDropdown<T>
Select one item from a menu.
```dart
UiDropdown<String>(items: sizes, value: size, onChanged: (v) => setState(() => size = v), label: 'Size')
```
- `items` (List<T>, duplicates removed), `value`, `onChanged`, `label`, `hint` ('Select')
- `itemLabel` (default `toString`), `itemIcon`, `prefixIcon`, `validator`, `isRequired`, `helper`
- A `value` that is not in `items` shows as empty.

### UiSearchableDropdown<T>
A field that opens a bottom sheet with a search box and a list. Tap a row to pick it.
```dart
// Local list: filters on the device
UiSearchableDropdown<Country>(
  label: 'Country',
  items: countries,
  value: country,
  itemLabel: (c) => c.name,
  itemSubtitle: (c) => c.region,
  onChanged: (c) => setState(() => country = c),
)

// Server search: debounced, stale replies are dropped
UiSearchableDropdown<User>(
  label: 'Assignee',
  onSearch: (q) => api.searchUsers(q),
  minChars: 2,
  value: user,
  itemLabel: (u) => u.name,
  onChanged: setUser,
)
```
- `items` (used when `onSearch` is null), `onSearch` (`Future<List<T>> Function(String query)`), `value`, `onChanged`
- `itemLabel`, `itemSubtitle`, `itemIcon`
- `label`, `hint` ('Select'), `searchHint` ('Search'), `sheetTitle` (default `label`), `prefixIcon`, `helper`
- `validator`, `isRequired`, `clearable` (shows an x button)
- `debounce` (350 ms, only for `onSearch`), `minChars` (0), `emptyText` ('No results')
- The sheet shows a loader, an error with **Try again**, and an empty state.

### UiMultiSelectDropdown<T>
Same sheet as `UiSearchableDropdown`, with checkboxes and a **Done** button. The field shows the picked items as chips. Tap x on a chip to remove it.
```dart
UiMultiSelectDropdown<String>(
  label: 'Skills',
  items: skills,
  values: picked,
  max: 5,
  onChanged: (v) => setState(() => picked = v),
)
```
- `items`, `onSearch`, `values` (List<T>), `onChanged` (gets the list in pick order)
- `max` (rows turn off when the limit is reached), `maxVisibleChips` (3; extra items show as `+N`)
- `itemLabel`, `itemSubtitle`, `itemIcon`, `label`, `hint`, `searchHint`, `sheetTitle`, `prefixIcon`, `helper`
- `validator`, `isRequired` ("Select at least one …"), `debounce`, `minChars`, `emptyText`
- **Clear** in the sheet removes all picks. The x in the field clears the value.

### UiAutocomplete<T extends Object>
A text field. Suggestions show in a menu under the field as the user types.
```dart
UiAutocomplete<City>(
  label: 'City',
  onSearch: (q) => api.cities(q),
  itemLabel: (c) => c.name,
  onSelected: (c) => setState(() => city = c),
)
```
- `items` (local list) or `onSearch` (async), `onSelected`, `itemLabel`, `itemSubtitle`, `itemIcon`
- `label`, `hint` ('Search'), `prefixIcon` (search icon), `helper`, `controller`, `focusNode`, `enabled`
- `debounce` (300 ms), `minChars` (1), `maxOptionsHeight` (280), `emptyText` ('No matches')
- A small spinner shows in the field while `onSearch` runs. Arrow keys and Enter work on desktop.
