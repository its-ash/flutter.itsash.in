# Cards

Source: `lib/src/card/`. Domain cards (product, workout, booking, and others) are in their kit folders and use `UiCard`.

### UiCard
A rounded surface. It can be tapped and selected.
```dart
UiCard(onTap: open, child: Text('Hello'))
UiCard(variant: UiCardVariant.gradient, child: ...)
```
- `child`, `onTap`, `onLongPress`, `variant` (`filled`, `outlined`, `elevated`, `tonal`, `gradient`), `padding`, `margin`, `color`, `radius`, `width`, `height`, `selected`.
