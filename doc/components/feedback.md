# Feedback

Widgets and helpers that tell the user about status, progress, and results. All colors come from the theme. Light and dark mode work.

### Toast
Shows a card at the top of the screen. It closes after 3 seconds. Tap or swipe it to close it. A new toast replaces the old toast.

```dart
context.showToast('Saved', status: UiStatus.success);
```
- `context.showToast(String message, {UiStatus status, String? title, IconData? icon, Duration duration = 3s, VoidCallback? onTap})`
- `UiToast.show(context, message, ...)`, `UiToast.dismiss()`

### Snack
Shows a floating snackbar. It hides the current snackbar first.

```dart
context.showSnack('Item removed', actionLabel: 'Undo', onAction: restore);
```
- `context.showSnack(String message, {String? actionLabel, VoidCallback? onAction, Duration duration = 4s})`

### UiDialog
Static helpers that open rounded dialogs and return a `Future`.

```dart
final ok = await UiDialog.confirm(context, title: 'Delete item?', confirmLabel: 'Delete', destructive: true);
final name = await UiDialog.input(context, title: 'Rename', validator: (v) => v.isEmpty ? 'Required' : null);
await UiDialog.success(context, message: 'Payment complete');
```
- `confirm(context, {required title, message, confirmLabel, cancelLabel, destructive, icon})` → `Future<bool>`
- `alert(context, {required title, message, buttonLabel, status, icon})` → `Future<void>`
- `input(context, {required title, message, hint, initialValue, confirmLabel, cancelLabel, validator, keyboardType, maxLength, obscure})` → `Future<String?>`
- `success(context, {title, message, buttonLabel})` → `Future<void>`
- `show<T>(context, {required title, message, icon, status, child, actions, dismissible})` → `Future<T?>`

### UiSheet
Opens a modal bottom sheet. The sheet scrolls, stays above the keyboard, and is not taller than 90% of the screen.

```dart
await UiSheet.show(context, title: 'Filters', child: const FilterForm());
final i = await UiSheet.actions(context, actions: const [
  UiSheetAction('Share', icon: Icons.share_rounded),
  UiSheetAction('Delete', icon: Icons.delete_rounded, destructive: true),
]);
final size = await UiSheet.select(context, options: ['S', 'M', 'L'], selected: 'M');
```
- `show<T>(context, {required child, title, scrollable, dismissible, padding})` → `Future<T?>`
- `actions(context, {required actions, title})` → `Future<int?>` (index of the action)
- `select<T>(context, {required options, label, selected, title, icon})` → `Future<T?>`
- `UiSheetAction(label, {icon, subtitle, destructive, enabled})`

### UiBanner
Inline status message with an optional action and close button.

```dart
UiBanner('Your card expires soon.', status: UiStatus.warning, actionLabel: 'Update', onAction: edit);
```
- `UiBanner(message, {status = info, title, icon, actionLabel, onAction, onClose})`

### UiEmptyState
Shows an icon or illustration, a title, a message, and an optional button.

```dart
UiEmptyState(title: 'No orders yet', message: 'Your orders show here.', actionLabel: 'Shop now', onAction: shop);
```
- `UiEmptyState({required title, message, icon, illustration, actionLabel, onAction, compact, status})`

### UiErrorState
Empty state with default error text and a retry button.

```dart
UiErrorState(onRetry: reload);
```
- `UiErrorState({onRetry, title, message, retryLabel, icon, compact})`

### UiLoader
Centered spinner with an optional message. `UiLoader.overlay` blocks the UI while a `Future` runs and returns its result.

```dart
const UiLoader(message: 'Loading');
final user = await UiLoader.overlay(context, api.save(), message: 'Saving');
```
- `UiLoader({message, size = 32, color})`
- `UiLoader.overlay<T>(context, Future<T> future, {message})` → `Future<T>`

### UiShimmer and UiSkeleton
Loading placeholders with a shimmer animation. One `UiShimmer` runs one animation for all skeletons below it.

```dart
UiSkeleton.list(count: 4);
UiShimmer(child: Column(children: [UiSkeleton.box(height: 160), UiSkeleton.line(width: 120)]));
```
- `UiShimmer({required child, enabled = true, label = 'Loading'})`
- `UiSkeleton.box({width, height = 80, radius})`, `.line({width, height = 12})`, `.circle({size = 44})`
- `UiSkeleton.listTile({avatar, lines, trailing})`, `UiSkeleton.card({imageHeight, lines})`, `UiSkeleton.list({count, avatar})`

### UiProgressBar
Rounded linear progress. The value is clamped to 0..1. It animates on change.

```dart
UiProgressBar(0.62, label: 'Storage', showPercent: true);
```
- `UiProgressBar(value, {label, trailing, showPercent, status, color, height = 8, animate})`

### UiProgressRing
Circular progress with a center percent, label, or child.

```dart
UiProgressRing(0.75, label: 'Goal', status: UiStatus.success);
```
- `UiProgressRing(value, {size = 72, stroke = 8, child, label, showPercent = true, status, color, animate})`

### UiStatusDot
Small status dot. It can pulse.

```dart
const UiStatusDot(label: 'Online', pulse: true);
```
- `UiStatusDot({status = success, size = 10, pulse, label, color})`

### UiBadge
Puts a count or a dot on any widget. Counts above `max` show as `99+`.

```dart
UiBadge(count: 120, child: Icon(Icons.notifications_rounded));
```
- `UiBadge({required child, count, dot, max = 99, status = danger, show, offset})`

### UiTooltip
Themed tooltip.

```dart
UiTooltip('Copy link', child: Icon(Icons.link_rounded));
```
- `UiTooltip(message, {required child, tap = false})`

### UiStatusIcon
Gives the default icon for a status.

```dart
Icon(UiStatus.warning.icon);
```
