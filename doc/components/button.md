# Buttons & actions

Buttons, icon buttons, FABs, button bars, segmented controls, toggles, and copy, social and hold-to-confirm buttons. A null callback disables any of them.

### UiButtonVariant

Visual style shared by every button, after the Ash Theme "button" component: `primary` (solid: Primary fill, bold label), `secondary` (dim: Overlay fill, regular label), `soft` (Primary tint), `outline` (ghost: 1 px gray outline, regular label), `ghost` (transparent, Overlay fill on hover), `danger` (solid danger fill), `link` (Primary text, underlined on hover). Buttons are 28 / 36 / 44 high for `sm` / `md` / `lg` (36 with 32 px side padding is the design's default), radius 8. Hover and keyboard focus draw a 4 px stroke inside the button (Primary 50% on solid, gray on dim and ghost). Disabled buttons use a gray-2 fill with gray-4 text.

### UiButton

Text button with optional icons, a loading state and a press animation.

```dart
UiButton('Save', onPressed: save)
UiButton('Delete', variant: UiButtonVariant.danger, icon: Icons.delete_rounded, onPressed: delete)
```

- `label` (positional): button text. Ellipsizes when there is no room.
- `onPressed`: tap callback. Null disables the button.
- `variant`: `UiButtonVariant.primary`.
- `size`: `UiSize.md`.
- `icon`, `trailingIcon`: icons before and after the label. Default null.
- `loading`: `false`. Shows a spinner, keeps the width and blocks taps.
- `expand`: `false`. Fills the available width.
- `status`: null. Recolors the variant with a status tone (e.g. `UiStatus.success`).

### UiIconButton

Square or round icon-only button with a tooltip and an optional badge.

```dart
UiIconButton(Icons.notifications_rounded, tooltip: 'Inbox', badge: 3, onPressed: open)
```

- `icon` (positional).
- `tooltip` (required): tooltip and screen-reader label.
- `onPressed`: null disables.
- `variant`: `UiButtonVariant.ghost`.
- `size`: `UiSize.md`. The button is a 28 / 36 / 44 square (sm / md / lg), round with `circular: true`.
- `badge`: null. Count in a small pill. Zero hides it; over 99 shows `99+`.
- `dot`: `false`. Small dot on the corner.
- `circular`: `false`.
- `loading`: `false`.
- `status`: null.

### UiFab

Floating action button with a shadow. Icon only, or extended with a label. Works as `Scaffold.floatingActionButton`.

```dart
floatingActionButton: UiFab(Icons.add_rounded, label: 'New', onPressed: create)
```

- `icon` (positional).
- `onPressed`: null disables.
- `label`: null. Set it to make an extended FAB.
- `tooltip`: null. Set it for icon-only FABs.
- `variant`: `UiButtonVariant.primary`.
- Height is `UiFab.height` (56). Always a pill.

### UiButtonBar

Lays out actions in a row with gaps. When they do not fit, stacks them full width with the last (primary) action on top. Use it for dialog and sheet footers.

```dart
UiButtonBar([
  UiButton('Cancel', variant: UiButtonVariant.outline, onPressed: close),
  UiButton('Save', onPressed: save),
])
```

- `children` (positional): put the primary action last.
- `spacing`: `UiSpace.sm`, used in both layouts.
- `alignment`: `MainAxisAlignment.end` (row layout).
- `expand`: `false`. Gives every button the same width and fills the row.
- `primaryFirstWhenStacked`: `true`.

### UiSegment

One option of a `UiSegmentedControl` or `UiToggleGroup`.

```dart
UiSegment('week', label: 'Week', icon: Icons.view_week_rounded)
```

- `value` (positional).
- `label`, `icon`: at least one is required.
- `tooltip`: for icon-only options.

### UiSegmentedControl

Segmented control: a gray-2 pill track (2 px inset) with a Primary pill that slides to the selected segment. The selected label is bold and white, the others regular gray. 32 high for `md` (28 for `sm`, 40 for `lg`).

```dart
UiSegmentedControl([UiSegment('day', label: 'Day'), UiSegment('week', label: 'Week')],
    value: range, onChanged: (v) => setState(() => range = v))
```

- `segments` (positional).
- `value` (required): selected value. No match shows no pill.
- `onChanged`: null disables.
- `size`: `UiSize.md`.
- `expand`: `false`. Fills the width. Otherwise each segment is as wide as the widest.

### UiToggleButton

A pill control (Figma "control") that stays on or off: 24 / 28 / 36 high, dim (Overlay fill) when off, solid Primary with a bold label when on.

```dart
UiToggleButton('Bold', selected: bold, onChanged: (v) => setState(() => bold = v))
UiToggleButton.icon(Icons.format_bold_rounded, tooltip: 'Bold', selected: bold, onChanged: setBold)
```

- `label` (positional) or `icon` (positional, in `.icon`).
- `selected` (required).
- `onChanged`: called with the new value. Null disables.
- `icon`: null (leading icon for the label variant).
- `tooltip` (required for `.icon`).
- `size`: `UiSize.md`.
- `expand`: `false`.

### UiToggleGroup

A row of toggle buttons with single or multi selection. Wraps to new lines when narrow.

```dart
UiToggleGroup([UiSegment('s', label: 'S'), UiSegment('m', label: 'M')],
    selected: {size}, onChanged: (s) => setState(() => size = s.first))
```

- `items` (positional): list of `UiSegment`.
- `selected` (required): `Set<T>` of selected values.
- `onChanged`: called with the new set. Null disables.
- `multiple`: `false`.
- `allowEmpty`: defaults to `multiple`. Lets the user clear the last item.
- `size`: `UiSize.md`.
- `expand`: `false`. One row with equal widths instead of wrapping.

### UiCopyButton

Copies text to the clipboard. The icon morphs to a check for 1.5 s.

```dart
UiCopyButton(apiKey)
UiCopyButton(link, label: 'Copy link', variant: UiButtonVariant.outline)
```

- `text` (positional): text to copy.
- `label`: null makes an icon-only button.
- `onCopied`: null.
- `tooltip`: `'Copy'`.
- `copiedLabel`: `'Copied'`.
- `variant`: `UiButtonVariant.ghost`.
- `size`: `UiSize.md`.

### UiSocialButton

"Continue with X" sign-in button. Outline style, full width. No brand assets are bundled; pass your own logo.

```dart
UiSocialButton('Google', leading: Image.asset('assets/google.png', width: 18), onPressed: signIn)
```

- `provider` (positional): used in `Continue with <provider>`.
- `onPressed`: null disables.
- `leading`: logo widget. Wins over `icon`.
- `icon`: null.
- `label`: null. Overrides the default text.
- `size`: `UiSize.md`.
- `expand`: `true`.
- `loading`: `false`.

### UiHoldButton

Press and hold to confirm. A fill sweeps across the button; releasing early cancels. For destructive or important actions.

```dart
UiHoldButton('Hold to delete', icon: Icons.delete_rounded, onConfirmed: delete)
```

- `label` (positional).
- `onConfirmed`: called when the hold completes. Null disables.
- `duration`: 1500 ms.
- `icon`: null. Turns into a check when confirmed.
- `variant`: `UiButtonVariant.danger`.
- `size`: `UiSize.md`.
- `expand`: `false`.
