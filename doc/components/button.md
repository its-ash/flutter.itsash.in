# Buttons

Source: `lib/src/button/`. A null `onPressed` disables the button.

### UiButton
A button with variants, sizes, an icon, and a loading state.
```dart
UiButton('Checkout', onPressed: pay, icon: Icons.lock, expand: true, loading: busy)
UiButton.outline('Cancel', onPressed: close)
```
- `label`, `onPressed`, `variant` (`primary`, `secondary`, `tonal`, `outline`, `ghost`, `danger`, `success`), `size`, `icon`, `trailingIcon`, `loading`, `expand`.
- Named: `.secondary`, `.tonal`, `.outline`, `.ghost`, `.danger`.

### UiIconButton
A round icon button. It can show a badge.
```dart
UiIconButton(Icons.shopping_bag_outlined, onPressed: openCart, badge: '3')
```
- `icon`, `onPressed`, `tooltip`, `variant` (`plain`, `filled`, `tonal`, `outline`), `size`, `badge` (empty string shows a dot), `color`.

### UiSocialButton
Full-width outlined sign-in button with the provider icon.
```dart
UiSocialButton(UiSocialProvider.google, onPressed: signInWithGoogle)
```
- `provider` (`UiSocialProvider`: google, apple, facebook, github, email, phone, x), `onPressed`
- `label` (default "Continue with Google"), `loading`, `expand` (true), `icon` (a widget that replaces the provider icon)

### UiToggleButton
Round icon button that toggles, for example a favorite heart.
```dart
UiToggleButton(value: liked, onChanged: setLiked)
UiToggleButton.bookmark(value: saved, onChanged: setSaved)
```
- `value`, `onChanged`, `icon`, `selectedIcon`, `tooltip`, `activeColor` (heart uses the sale color), `size`, `filled` (true)
