# Feedback, overlays, loading & states

Alerts, toasts, dialogs, sheets, menus, popovers, progress, skeletons and empty/error states. Import `package:theme/theme.dart`.

### UiAlert
Inline callout box with a soft status tint.
```dart
UiAlert('Your trial ends in 3 days.', title: 'Heads up', status: UiStatus.warning)
```
- `message` (positional) — body text.
- `title` — bold first line. Default none.
- `status` — `UiStatus`. Default `info`.
- `icon` — leading icon. Default `status.icon`.
- `showIcon` — default `true`.
- `action` — widget under the message (e.g. a `TextButton`). Default none.
- `onClose` — shows a close button when set.

### UiBanner
Full-width strip for app-wide messages; slides in and out when `visible` changes.
```dart
UiBanner("You're offline", visible: offline, status: UiStatus.warning, actionLabel: 'Retry', onAction: retry)
```
- `message` (positional).
- `visible` — default `true`.
- `status` — default `info`.
- `icon` — default `status.icon`.
- `actionLabel` + `onAction` — trailing text action.
- `onDismiss` — shows a close button when set.

### UiToast
Floating notification cards on the app overlay. They slide in, stack (max 3), auto-dismiss and can be swiped away. Returns a `Future` that completes on dismiss.
```dart
UiToast.show(context, 'Saved', status: UiStatus.success);
context.showToast('Deleted', actionLabel: 'Undo', onAction: undo);
UiToast.dismissAll();
```
- `message` (positional).
- `title` — bold first line. Default none.
- `status` — default `neutral` (no icon). Other statuses show `status.icon`.
- `icon` — custom leading icon.
- `duration` — default 4 s. `null` keeps it until dismissed. Hover pauses the timer.
- `actionLabel` + `onAction` — small button; tapping it also closes the toast.
- `position` — `UiToastPosition.top` (default) or `bottom`.
- `replace` — close all other toasts first. Default `false`.
- `UiToast.maxVisible` — default `3`; older toasts close first.

### context.showSnack
`context.showToast` and `context.showSnack` come from the `UiFeedbackContext` extension on `BuildContext`.

Themed `SnackBar` helper. Hides the current snackbar first. Returns `Future<SnackBarClosedReason>`.
```dart
context.showSnack('Archived', action: 'Undo', onAction: undo, status: UiStatus.success);
```
- `message` (positional).
- `action` + `onAction` — action label and callback.
- `status` / `icon` — leading status icon. Default none.
- `duration` — default 4 s.
- `persist` — Flutter default (stays open when it has an action).

### UiDialog
Centered modal dialogs. Icon in a tinted circle, centered title and message. Buttons sit in a row when they fit, else stack full width with the main action on top.
```dart
final ok = await UiDialog.confirm(context, title: 'Delete note?', destructive: true);
final name = await UiDialog.prompt(context, title: 'Rename', initialValue: note.title);
```
`UiDialog.show<T>(context, {title, message, content, actions, icon, status, dismissible}) → Future<T?>`
- `actions` — `List<UiDialogAction<T>>`. Default none.
- `icon` — shown in a circle tinted by `status` (default `accent`). Default none.
- `content` — any widget under the message.
- `dismissible` — barrier tap and back button close it. Default `true`.

`UiDialog.confirm(context, {title, message, confirmLabel, cancelLabel, destructive, icon}) → Future<bool>`
- `confirmLabel` default `'Confirm'`, `cancelLabel` default `'Cancel'`.
- `destructive` — danger button and warning icon. Default `false`.
- Returns `false` when dismissed.

`UiDialog.alert(context, {title, message, okLabel, status, icon}) → Future<void>`
- `okLabel` default `'OK'`, `status` default `info`, icon default `status.icon`.

`UiDialog.prompt(context, {title, message, label, hint, initialValue, validator, confirmLabel, cancelLabel, keyboardType, obscureText}) → Future<String?>`
- `validator` — returns an error text or null. Runs on Save.
- `confirmLabel` default `'Save'`. Returns `null` when cancelled.

### UiDialogAction
One dialog button that closes the dialog with `value`.
```dart
const UiDialogAction('Discard', value: 'discard', destructive: true)
```
- `label` (positional), `value`, `primary` (filled, default `false`), `destructive` (default `false`), `onPressed` (extra callback).

### UiSheet
Modal bottom sheet with a header, scrollable body and sticky action footer. Moves above the keyboard.
```dart
final applied = await UiSheet.show<bool>(context, title: 'Filters', child: const FiltersForm(), actions: [applyButton]);
```
- `child` — required body. Close with `Navigator.pop(context, value)`.
- `title`, `subtitle` — header text.
- `actions` — widgets (usually buttons) pinned at the bottom. Row when ≤ 2 and they fit, else stacked.
- `scrollable` — wrap body in a scroll view. Default `true`.
- `expand` — take the full available height. Default `false` (max 90 %).
- `isDismissible` — drag, barrier and back close it. Default `true`.
- `padding` — body padding. Default `fromLTRB(24, 0, 24, 16)`.

### UiActionSheet
Bottom sheet listing actions plus Cancel. Returns the chosen value or `null`.
```dart
final v = await UiActionSheet.show<String>(context, actions: [
  const UiSheetAction('Delete', value: 'delete', icon: Icons.delete_outline_rounded, destructive: true),
]);
```
- `actions` — `List<UiSheetAction<T>>`, required.
- `title`, `message` — small centered header.
- `cancelLabel` — default `'Cancel'`. `showCancel` — default `true`.

### UiSheetAction
One row of a `UiActionSheet`.
```dart
const UiSheetAction('Share', value: 'share', icon: Icons.ios_share_rounded)
```
- `label` (positional), `value` (required), `icon`, `subtitle`, `destructive` (default `false`), `enabled` (default `true`).

### UiMenu
Popup menu anchored to a widget or a position. Returns the picked value or `null`.
```dart
final v = await UiMenu.show(context, items: [const UiMenuItem('edit', 'Edit', icon: Icons.edit_outlined)]);
```
- `items` — `List<UiMenuItem<T>>`, required.
- `position` — global offset. Default none.
- `anchorKey` — opens below this widget. Default: below `context`'s widget.

### UiMenuItem
One menu row, or a divider.
```dart
const UiMenuItem('copy', 'Copy', icon: Icons.copy_rounded, shortcut: '⌘C')
const UiMenuItem.divider()
```
- `value`, `label` (positional), `icon`, `destructive` (default `false`), `shortcut`, `enabled` (default `true`).

### UiMenuButton
Icon button (or custom child) that opens a `UiMenu` below itself. Null `onSelected` disables it.
```dart
UiMenuButton<String>(items: const [UiMenuItem('rename', 'Rename')], onSelected: rename)
```
- `items` — required.
- `onSelected` — required; null disables.
- `child` — non-interactive custom trigger. Default an `IconButton`.
- `icon` — default `Icons.more_horiz_rounded`. `tooltip` — default `'More options'`.

### UiPopover
Floating card anchored to its child. Tap the child to toggle, tap outside to close.
```dart
UiPopover(popover: (context) => const Text('Details'), child: const Icon(Icons.info_outline))
```
- `child` — the anchor, required.
- `popover` — `WidgetBuilder` for the card content, required.
- `controller` — `UiPopoverController` with `show()`, `hide()`, `toggle()`, `isOpen`. Use it when the child is a button.
- `width` — default `280` (shrinks on narrow screens).
- `above` — open above the anchor. Default `false`.
- `alignEnd` — align right edges. Default `false`.
- `openOnTap` — default `true`.
- `padding` — default `16` all sides.

### UiTooltip
Tooltip with design defaults.
```dart
UiTooltip('Copy link', child: Icon(Icons.link_rounded))
```
- `message` (positional), `child` (required), `preferBelow`, `triggerMode`.

### UiProgressBar
Horizontal bar. `null` value is indeterminate. Value changes animate.
```dart
UiProgressBar(0.4, label: 'Uploading', showPercent: true)
const UiProgressBar(null)
```
- `value` (positional) — 0 to 1, or `null`.
- `status` — fill color. Default `accent`.
- `label` — text above, left. Default none.
- `showPercent` — percent above, right. Default `false`.
- `height` — default `6`.
- `UiProgressBar.indeterminate({status, label, height})` — same as `UiProgressBar(null)`.

### UiProgressRing
Circular progress. `null` value spins.
```dart
UiProgressRing(0.72, showPercent: true, size: 64)
```
- `value` (positional) — 0 to 1, or `null`.
- `size` — default `44`. `stroke` — default `4`.
- `status` — default `accent`.
- `center` — widget in the middle. Default none.
- `showPercent` — percent in the middle when `center` is null. Default `false`.

### UiSpinner
Small indeterminate spinner.
```dart
const UiSpinner(size: 16)
```
- `size` — default `20`. `color` — default accent. `strokeWidth` — default `size / 10`.

### UiSkeleton
Shimmer placeholder shapes. Stays still when reduced motion is on.
```dart
const UiSkeleton.text(lines: 2)
const UiSkeleton.circle(size: 48)
const UiSkeleton.box(height: 160)
```
- `UiSkeleton({width, height = 14, radius = 6})` — one bar. Null width fills.
- `UiSkeleton.box({width, height = 120, radius = 14})` — a block.
- `UiSkeleton.text({lines = 3, height = 12})` — paragraph; last line is shorter.
- `UiSkeleton.circle({size = 40})` — avatar.

### UiShimmer
Shares one shimmer animation with every skeleton below it. Skeletons without one create their own.
```dart
UiShimmer(child: Column(children: [UiSkeleton.circle(), UiSkeleton.text()]))
```
- `child` — required.

### UiSkeletonList
List placeholder: rows with an avatar circle and text lines. Never overflows.
```dart
const UiSkeletonList(count: 6)
```
- `count` — default `4`. `avatar` — default `true`.
- `lines` — text lines per row incl. title. Default `2`.
- `padding` — per row. Default `16 × 12`.

### UiEmptyState
Centered placeholder for screens with no content. Icon in a soft circle.
```dart
UiEmptyState(title: 'No notes yet', message: 'Tap + to write one.', action: newButton)
```
- `title` (required), `message`, `icon` (default `Icons.inbox_outlined`), `action`, `compact` (default `false`).

### UiErrorState
Centered error with an optional retry button.
```dart
UiErrorState(message: 'Check your connection.', onRetry: load)
```
- `title` — default `'Something went wrong'`.
- `message`, `onRetry` (shows the button), `retryLabel` (default `'Try again'`), `icon` (default `Icons.error_outline_rounded`), `compact` (default `false`).

### UiSuccessState
Centered confirmation that something finished.
```dart
UiSuccessState(title: 'Payment sent', message: 'We emailed your receipt.')
```
- `title` (required), `message`, `icon` (default `Icons.check_rounded`), `action`, `compact` (default `false`).

### UiLoadingOverlay
Dims its child, shows a spinner card and blocks input while loading.
```dart
UiLoadingOverlay(loading: saving, message: 'Saving…', child: form)
```
- `loading` (required), `child` (required), `message` (default none).
