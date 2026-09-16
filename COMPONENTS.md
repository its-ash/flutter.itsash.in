# theme — Component Reference

This file documents every public widget/API exported by the `theme` Flutter package (see `lib/theme.dart`). It exists so an LLM (or a developer) consuming this package can discover what's available and how to configure it without reading source.

Package import: `import 'package:theme/theme.dart';`

## Setup

Wrap your app with the theme. Do this once, at the `MaterialApp` root.

```dart
MaterialApp(
  theme: AppTheme.lightTheme(),
  darkTheme: AppTheme.darkTheme(),
  themeMode: ThemeMode.system,
)
```

`AppTheme.lightTheme({ColorScheme? colorScheme, TextTheme? textTheme, AppShadowTheme shadows})` and `AppTheme.darkTheme(...)` take the same optional overrides — pass a custom `ColorScheme` to rebrand without touching any component. Every widget below automatically picks up colors/typography from the nearest `Theme.of(context)`, so no per-widget theme wiring is needed.

Widgets are named `ThemeX` (e.g. `ThemeButton`) to avoid clashing with Flutter's own `Text`, `Card`, `Button`, etc. Everything is a `StatelessWidget` unless noted; static-method classes (`Notify`, `ThemeSnackBar`, `ThemeDialog`, `ThemeBottomSheet`, `ThemeDatePicker`, `ThemeTimePicker`, `ThemeBanner`) are called directly without instantiation.

---

## Index

- [Buttons & actions](#buttons--actions)
- [Cards & surfaces](#cards--surfaces)
- [Notifications & feedback](#notifications--feedback)
- [Navigation](#navigation)
- [Navigation & wayfinding](#navigation--wayfinding)
- [Inputs & selection](#inputs--selection)
- [Lists & data](#lists--data)
- [Pickers & menus](#pickers--menus)
- [Layout & misc](#layout--misc)
- [Typography](#typography)
- [E-commerce / app widgets](#e-commerce--app-widgets)
- [State & status widgets](#state--status-widgets)
- [Form helpers](#form-helpers)
- [Media & content widgets](#media--content-widgets)
- [App shell & status pages](#app-shell--status-pages)
- [Pickers](#pickers)
- [Commerce & access widgets](#commerce--access-widgets)
- [Third-party dependencies](#third-party-dependencies)

---

## Buttons & actions

### `ThemeButton`
Standard button with 4 visual variants, optional icon, optional semantic status color.

```dart
ThemeButton({
  required String label,
  VoidCallback? onPressed,
  ThemeButtonVariant variant = ThemeButtonVariant.filled, // elevated | filled | outlined | text
  IconData? icon,
  ThemeButtonStatus? status, // success | error | warning | info — overrides the theme's primary color
})
```
```dart
ThemeButton(label: 'Checkout', onPressed: () {}, variant: ThemeButtonVariant.filled, icon: Icons.arrow_forward)
ThemeButton(label: 'Delete', onPressed: () {}, status: ThemeButtonStatus.error)
```
`status` reuses the same palette as `Notify`/`ThemeStatusPill` (`success` = green, `warning` = orange, `error` = `colorScheme.error`, `info` = `colorScheme.primary`) across all 4 variants — e.g. a `filled` status button fills with the status color, an `outlined` one uses it for the border/text instead of the border/fill being solid black or theme-primary. The stamped shadow on a status button is tinted with a darkened version of the status color (so a green button gets a green-tinted shadow, not the theme's default pink/blue), while embossed two-tone styles like Claymorphism preserve their white top-light and only tint the bottom shadow.

### `ThemeIconButton`
```dart
ThemeIconButton({required IconData icon, VoidCallback? onPressed, String? tooltip})
```

### `ThemeTapButton`
Bare tap surface with ripple — for building custom-shaped tappable widgets (chips, cards, tiles) that need `InkWell` behavior without a specific button look.
```dart
ThemeTapButton({
  Widget? child,
  VoidCallback? onTap,
  ShapeBorder shape = const RoundedRectangleBorder(),
  Size? size,
  BoxDecoration? decoration,
  Duration duration = const Duration(milliseconds: 150),
})
```

### `ThemeFab`
Floating action button; becomes extended (pill + label) automatically when `label` is given.
```dart
ThemeFab({required IconData icon, VoidCallback? onPressed, String? label})
```

### `ThemeSegmentedButton<T>`
Thin wrapper over Flutter's `SegmentedButton`.
```dart
ThemeSegmentedButton<T>({
  required List<ButtonSegment<T>> segments,
  required Set<T> selected,
  required ValueChanged<Set<T>> onSelectionChanged,
})
```

### `ThemeToggleButtons`
```dart
ThemeToggleButtons({
  required List<Widget> children,
  required List<bool> isSelected,
  required ValueChanged<int> onPressed,
})
```

---

## Cards & surfaces

### `ThemeCard`
Elevated container with theme-aware shadow and rounded corners. Pass `selected: true` for a selection border that always shares this card's own resolved radius (via `selectedColor`/`selectedBorderWidth`) — draw selection this way rather than wrapping `ThemeCard` in your own bordered `Container`, which can drift out of sync if the radius changes (e.g. via a theme preset).
```dart
ThemeCard({
  required Widget child,
  Color? color,
  double borderRadius = 16,
  Clip clipBehavior = Clip.antiAlias,
  EdgeInsetsGeometry margin = const EdgeInsets.all(8),
  bool selected = false,
  Color? selectedColor,       // defaults to colorScheme.primary
  double selectedBorderWidth = 2,
})
```

### `ThemeDivider` / `ThemeVerticalDivider`
```dart
ThemeDivider({double? height, double? indent, double? endIndent})
ThemeVerticalDivider({double? width, double? indent, double? endIndent})
```

### `ThemeTooltip`
```dart
ThemeTooltip({required String message, required Widget child})
```

---

## Notifications & feedback

### `Notify` — the notification system
The single entry point for user-facing feedback. Shows a themed, floating `SnackBar` with an icon and color matched to the message type.

```dart
Notify.show(context, String message, {
  NotifyType type = NotifyType.info, // success | error | warning | info
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
})

// Shorthands
Notify.success(context, String message, {Duration? duration})
Notify.error(context, String message, {Duration? duration})
Notify.warning(context, String message, {Duration? duration})
Notify.info(context, String message, {Duration? duration})
```
```dart
Notify.success(context, 'Order placed successfully');
Notify.error(context, 'Payment failed, please try again');
```
Colors: success = green, error = `colorScheme.error`, warning = orange, info = `colorScheme.inverseSurface`. Requires a `Scaffold`/`ScaffoldMessenger` ancestor (standard Flutter requirement for SnackBars).

### `ThemeToast`
Like `Notify` but does not require a `Scaffold`/`ScaffoldMessenger` — inserts an `OverlayEntry` via `Overlay.of(context)` instead, so it works anywhere in the widget tree. Auto-dismisses after `duration`; repeated calls stack instead of overlapping.
```dart
ThemeToast.show(context, String message, {
  ThemeToastType type = ThemeToastType.info, // success | error | warning | info
  Duration duration = const Duration(seconds: 3),
})

// Shorthands
ThemeToast.success(context, String message, {Duration? duration})
ThemeToast.error(context, String message, {Duration? duration})
ThemeToast.warning(context, String message, {Duration? duration})
ThemeToast.info(context, String message, {Duration? duration})
```
```dart
ThemeToast.success(context, 'Saved');
```

### `ThemeSnackBar`
Lower-level, unstyled snackbar (no type/color/icon) — use `Notify` instead unless you need a bare message.
```dart
ThemeSnackBar.show(BuildContext context, String message, {SnackBarAction? action})
```

### `ThemeBanner`
Persistent top-of-screen banner (Material `MaterialBanner`) for messages that need an explicit dismiss action, unlike a snackbar which auto-dismisses.
```dart
ThemeBanner.show(BuildContext context, {required String message, required List<Widget> actions})
ThemeBanner.hide(BuildContext context)
```

### `ThemeDialog`
```dart
ThemeDialog.show<T>(BuildContext context, {
  String? title,
  String? content,
  List<Widget>? actions,
  bool barrierDismissible = true,
}) // returns Future<T?>
```

### `ThemeBottomSheet`
```dart
ThemeBottomSheet.show<T>(BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) // returns Future<T?>
```

### `ThemeProgressIndicator`
```dart
ThemeProgressIndicator({
  ThemeProgressIndicatorType type = ThemeProgressIndicatorType.circular, // linear | circular
  double? value, // null = indeterminate
})
```

### `ThemeBadge`
Small label/dot overlay on a child widget (e.g. unread count on a bell icon).
```dart
ThemeBadge({required Widget child, String? label, bool isVisible = true})
```

---

## Navigation

### `ThemeAppBar`
```dart
ThemeAppBar({String? title, List<Widget>? actions, Widget? leading, bool? centerTitle})
```

### `ThemeBottomAppBar`
```dart
ThemeBottomAppBar({required List<Widget> children}) // laid out via spaceAround Row
```

### `ThemeBottomNavigationBar`
```dart
ThemeBottomNavigationBar({
  required List<BottomNavigationBarItem> items,
  required int currentIndex,
  required ValueChanged<int> onTap,
})
```

### `ThemeNavigationBar` + `ThemeNavigationDestinationItem`
Material 3 navigation bar (bottom, pill-indicator style).
```dart
ThemeNavigationDestinationItem({required IconData icon, IconData? selectedIcon, required String label})

ThemeNavigationBar({
  required List<ThemeNavigationDestinationItem> destinations,
  required int selectedIndex,
  required ValueChanged<int> onDestinationSelected,
})
```

### `ThemeNavigationRail`
Same `ThemeNavigationDestinationItem` list, for side-rail nav (tablet/desktop layouts).
```dart
ThemeNavigationRail({
  required List<ThemeNavigationDestinationItem> destinations,
  required int selectedIndex,
  required ValueChanged<int> onDestinationSelected,
  bool extended = false,
})
```

### `ThemeDrawer`
```dart
ThemeDrawer({required List<Widget> children})
```

### `ThemeTabBar`
Implements `PreferredSizeWidget` — use directly as a `Scaffold.appBar.bottom` or in a `TabBar` slot.
```dart
ThemeTabBar({required List<String> tabs, TabController? controller})
```

---

## Navigation & wayfinding

### `ThemePagination`
Page-number control with prev/next arrows, current page highlighted with `colorScheme.primary`, ellipsis for large page counts (e.g. `1 2 3 … 8 9 10`).
```dart
ThemePagination({
  required int currentPage,
  required int totalPages,
  required ValueChanged<int> onPageChanged,
  int maxVisiblePages = 7,
  double? borderRadius,
})
```
```dart
ThemePagination(currentPage: _page, totalPages: 42, onPageChanged: (p) => setState(() => _page = p))
```

### `ThemeBreadcrumbs`
Horizontal trail of tappable labels separated by a chevron (or custom icon); the last item is non-tappable and styled as the current location.
```dart
ThemeBreadcrumbItem({required String label, VoidCallback? onTap})

ThemeBreadcrumbs({
  required List<ThemeBreadcrumbItem> items,
  IconData separatorIcon = Icons.chevron_right,
})
```
```dart
ThemeBreadcrumbs(items: [
  ThemeBreadcrumbItem(label: 'Home', onTap: () {}),
  ThemeBreadcrumbItem(label: 'Settings', onTap: () {}),
  const ThemeBreadcrumbItem(label: 'Profile'),
])
```

### `ThemeOnboardingTour`
Spotlight/coachmark overlay: dims the screen and cuts a highlight around each step's target widget (located via its `GlobalKey`), with a tooltip-style card and Next/Skip/Done actions advancing through the steps. Self-contained — call the static method, no return value.
```dart
ThemeOnboardingStep({required GlobalKey key, required String title, required String description})

ThemeOnboardingTour.show(BuildContext context, {required List<ThemeOnboardingStep> steps})
```
```dart
ThemeOnboardingTour.show(context, steps: [
  ThemeOnboardingStep(key: _fabKey, title: 'Add an item', description: 'Tap here to create a new entry.'),
]);
```

---

## Inputs & selection

### `ThemeTextField`
```dart
ThemeTextField({
  TextEditingController? controller,
  String? hintText,
  String? labelText,
  String? errorText,
  bool obscureText = false,
  TextInputType? keyboardType,
  IconData? prefixIcon,
  IconData? suffixIcon,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
  bool enabled = true,
  int? maxLines = 1,
})
```

### `ThemeSearchBar`
```dart
ThemeSearchBar({
  TextEditingController? controller,
  String hintText = 'Search...',
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
  VoidCallback? onFilterTap, // shows a trailing tune/filter icon button
})
```

### `ThemeFilterChipRow`
Horizontal scrolling row of single-select filter chips.
```dart
ThemeFilterChipRow({
  required List<String> chips,
  required int selectedIndex,
  required ValueChanged<int> onSelected,
})
```

### `ThemeChip` / `ThemeChipButton`
```dart
// Chip or ChoiceChip depending on whether selected/onSelected are provided
ThemeChip({
  required String label,
  Widget? avatar,
  VoidCallback? onDeleted,   // -> renders as deletable Chip
  bool? selected,            // -> with onSelected, renders as ChoiceChip
  ValueChanged<bool>? onSelected,
})

// Custom pill-shaped tap target, used internally by ThemeFilterChipRow
ThemeChipButton(String label, VoidCallback? onTap, {bool selected = false})
```

### `ThemeCheckbox`
```dart
ThemeCheckbox({required bool value, ValueChanged<bool?>? onChanged})
```

### `ThemeRadio<T>`
```dart
ThemeRadio<T>({required T value, required T? groupValue, ValueChanged<T?>? onChanged})
```

### `ThemeSwitch`
```dart
ThemeSwitch({required bool value, ValueChanged<bool>? onChanged})
```

### `ThemeSlider`
```dart
ThemeSlider({
  required double value,
  ValueChanged<double>? onChanged,
  double min = 0,
  double max = 1,
  int? divisions,
})
```

### `ThemeDropdown<T>`
Compact by default (dense field, 14px text, tight content padding). Menu popup height auto-sizes to the item count (44px/row, capped at 280px) unless you pass `menuHeight`; pass `width` to constrain the field/menu width — otherwise it sizes to the widest entry. Global entry-row padding also comes from the theme's `MenuButtonThemeData` (compact density, shrink-wrapped tap target), so `ThemePopupMenu` and other menu-based widgets are compact too.
```dart
ThemeDropdown<T>({
  required List<DropdownMenuEntry<T>> items,
  T? initialSelection,
  ValueChanged<T?>? onSelected,
  String? hintText,
  String? label,
  double? width,
  double? menuHeight,
})
```

---

## Lists & data

### `ThemeListTile`
```dart
ThemeListTile({
  Widget? leading,
  required String title,
  String? subtitle,
  Widget? trailing,
  VoidCallback? onTap,
  bool selected = false,
})
```

### `ThemeExpansionTile`
```dart
ThemeExpansionTile({
  required String title,
  required List<Widget> children,
  Widget? leading,
  bool initiallyExpanded = false,
})
```

### `ThemeDataTable`
Bordered, rounded container around Material's `DataTable`, with automatic zebra-striping on odd rows (skipped for any `DataRow` that sets its own `color`).
```dart
ThemeDataTable({required List<DataColumn> columns, required List<DataRow> rows})
```

### `ThemeTreeView<T>`
Nested expandable tree list over generic node data — indent per depth, animated expand/collapse chevron, optional leading icon per node.
```dart
ThemeTreeNode<T>({
  required T value,
  required String label,
  List<ThemeTreeNode<T>> children = const [],
  IconData? icon,
})

ThemeTreeView<T>({
  required List<ThemeTreeNode<T>> nodes,
  ValueChanged<ThemeTreeNode<T>>? onNodeTap,
  double indent = 20,
})
```
```dart
ThemeTreeView<String>(nodes: [
  ThemeTreeNode(value: 'src', label: 'src', icon: Icons.folder_outlined, children: [
    ThemeTreeNode(value: 'main.dart', label: 'main.dart', icon: Icons.description_outlined),
  ]),
])
```

### `ThemeTimeline`
Vertical timeline: a connector line + dot per entry, with title/subtitle/timestamp and semantic dot coloring (success/error/warning/info, same palette as `ThemeStatusPill`).
```dart
ThemeTimelineEntry({
  required String title,
  String? description,
  String? timestamp,
  Color? dotColor,   // overrides the status-derived color
  ThemeStatus? status,
})

ThemeTimeline({required List<ThemeTimelineEntry> entries})
```
```dart
ThemeTimeline(entries: [
  ThemeTimelineEntry(title: 'Order placed', timestamp: '9:02 AM', status: ThemeStatus.success),
  ThemeTimelineEntry(title: 'Payment failed', timestamp: '9:05 AM', status: ThemeStatus.error),
])
```

### `ThemeScrollbar`
```dart
ThemeScrollbar({required Widget child, ScrollController? controller, bool thumbVisibility = true})
```

### `ThemeCarousel`
Wraps Material's `CarouselView` in a fixed-height `SizedBox` (`height`, default 180) — `CarouselView` has no intrinsic height and disappears inside unbounded-height ancestors (e.g. a `ListView`) without one.
```dart
ThemeCarousel({required List<Widget> children, double itemExtent = 300, double height = 180})
```

---

## Pickers & menus

### `ThemeDatePicker`
```dart
ThemeDatePicker.show(BuildContext context, {
  required DateTime firstDate,
  required DateTime lastDate,
  DateTime? initialDate,
}) // returns Future<DateTime?>
```

### `ThemeTimePicker`
```dart
ThemeTimePicker.show(BuildContext context, {TimeOfDay? initialTime}) // returns Future<TimeOfDay?>
```

### `ThemePopupMenu<T>`
```dart
ThemePopupMenu<T>({
  required List<PopupMenuEntry<T>> items,
  ValueChanged<T>? onSelected,
  Widget? icon,
})
```

### `ThemeContextMenu<T>`
Right-click (secondary-tap) context menu wrapping a child, built on `showMenu` so it matches `ThemePopupMenu`'s styling; also triggers on long-press as a touch-device fallback.
```dart
ThemeContextMenu<T>({
  required Widget child,
  required List<PopupMenuEntry<T>> items,
  ValueChanged<T>? onSelected,
})
```
```dart
ThemeContextMenu<String>(
  items: const [PopupMenuItem(value: 'copy', child: Text('Copy')), PopupMenuItem(value: 'delete', child: Text('Delete'))],
  onSelected: (v) => print(v),
  child: const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('Right-click me'))),
)
```

---

## Layout & misc

### `ThemeSectionHeader`
Title + optional subtitle + optional trailing "See all" action — the standard section header for list/grid sections on a home screen.
```dart
ThemeSectionHeader({
  required String title,
  String? subtitle,
  String actionLabel = 'See all',
  VoidCallback? onAction, // omit to hide the action button entirely
})
```

### `ThemeBannerCarousel` + `ThemeBannerCarouselItem`
Full-bleed swipeable promo/hero banners with gradient background and CTA pill.
```dart
ThemeBannerCarouselItem({
  required String title,
  required String subtitle,
  required String ctaLabel,
  required List<Color> colors, // gradient stops
})

ThemeBannerCarousel({
  required List<ThemeBannerCarouselItem> banners,
  ValueChanged<int>? onTap, // index of tapped banner
})
```

### `ThemeSplitPanel`
Two-pane layout with a draggable divider that resizes both panes live.
```dart
ThemeSplitPanel({
  required Widget first,
  required Widget second,
  Axis axis = Axis.horizontal,
  double initialRatio = 0.5,
  double minRatio = 0.15,
  double maxRatio = 0.85,
  ValueChanged<double>? onRatioChanged,
  double dividerThickness = 8,
})
```
```dart
ThemeSplitPanel(first: const FileTree(), second: const Editor(), initialRatio: 0.3)
```

### `ThemeMasonryGrid`
Staggered/Pinterest-style grid — items of varying height flow into N columns, each new item going to the shortest column.
```dart
ThemeMasonryGrid({
  required List<Widget> children,
  int crossAxisCount = 2,
  double spacing = 8,
})
```
```dart
ThemeMasonryGrid(crossAxisCount: 3, children: [for (final photo in photos) PhotoCard(photo)])
```

---

## Typography

### `ThemeText`
Direct font/size/weight control when you need something outside the standard `TextTheme` scale.
```dart
ThemeText(
  String text,
  ThemeFont font,       // ThemeFont.inter | ThemeFont.lato
  ThemeFontSize size,    // ThemeFontSize.size10 ... size56 (10,12,14,16,18,20,22,24,28,32,36,40,48,56)
  {
    FontWeight weight = FontWeight.w400,
    Color? color,
    double? letterSpacing,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }
)
```
```dart
ThemeText('Featured', ThemeFont.inter, ThemeFontSize.size20, weight: FontWeight.w700)
```

### `AppTypography`
Static `TextStyle` getters matching the app's type scale — prefer these (or plain `Theme.of(context).textTheme`) over `ThemeText` for standard body/heading text: `headlineLarge`, `headlineMedium`, `headlineSmall`, `titleLarge`, `titleMedium`, `bodyLarge`, `bodyMedium`, `labelLarge`.
```dart
Text('Section title', style: AppTypography.titleLarge)
```

---

## E-commerce / app widgets

Higher-level, opinionated widgets for common product/commerce/profile screens. These compose the primitives above.

### `AddToCartButton`
Configurable add-to-cart CTA with loading and "already in cart" states built in.
```dart
AddToCartButton({
  required VoidCallback? onPressed,
  String label = 'Add to Cart',
  IconData icon = Icons.shopping_cart_outlined,
  AddToCartVariant variant = AddToCartVariant.filled, // filled | outlined | icon
  bool isLoading = false,   // shows a spinner, disables tap
  bool isInCart = false,    // swaps label/icon to a checkmark + inCartLabel
  String inCartLabel = 'Added',
  bool expand = false,      // stretch to fill available width (ignored for `icon` variant)
})
```
```dart
AddToCartButton(onPressed: () => Notify.success(context, 'Added to cart'), variant: AddToCartVariant.outlined)
```

### `PriceTag`
Price display with automatic strikethrough original price when on sale.
```dart
PriceTag({
  required double price,
  double? originalPrice,          // shown struck-through if greater than price
  PriceTagSize size = PriceTagSize.medium, // small | medium | large
  String currencySymbol = '\$',
})
```

### `RatingStars`
Star rating display (not interactive — for showing an average rating, not collecting one).
```dart
RatingStars({
  required double rating,     // rounded to nearest star for fill
  double size = 16,
  bool showNumber = true,     // append e.g. "4.5" after the stars
  Color color = const Color(0xFFFFA726),
  int starCount = 5,
})
```

### `ProfileAvatar`
User avatar with image/initials/icon fallback chain, optional tap and edit badge.
```dart
ProfileAvatar({
  String? imageUrl,           // network image if provided
  String? initials,           // else initials text if provided
  IconData icon = Icons.person, // else this icon as final fallback
  double radius = 20,
  Color? backgroundColor,     // defaults to colorScheme.primaryContainer
  VoidCallback? onTap,        // wraps in InkWell when provided
  bool showEditBadge = false, // small pencil badge, bottom-right
})
```
```dart
ProfileAvatar(radius: 40, initials: 'AR', showEditBadge: true, onTap: () => _editProfile())
```

### `ThemeRatingInput`
Interactive tappable star rating (contrast with the display-only `RatingStars` above) — tap a star to set the rating, or tap its left/right half when `allowHalfRating` is on.
```dart
ThemeRatingInput({
  required double rating,
  ValueChanged<double>? onChanged, // null = read-only
  double size = 24,
  int starCount = 5,
  bool allowHalfRating = false,
  Color color = const Color(0xFFFFA726),
})
```
```dart
ThemeRatingInput(rating: _rating, onChanged: (r) => setState(() => _rating = r), allowHalfRating: true)
```

### `ThemeAvatarGroup`
Overlapping/stacked circular avatars (built on `ProfileAvatar`) with a "+N more" overflow indicator once the list exceeds `maxVisible`.
```dart
ThemeAvatarData({String? imageUrl, String? initials, Color? backgroundColor})

ThemeAvatarGroup({
  required List<ThemeAvatarData> avatars,
  int maxVisible = 4,
  double radius = 18,
})
```
```dart
ThemeAvatarGroup(avatars: [
  const ThemeAvatarData(initials: 'AR'),
  const ThemeAvatarData(initials: 'BK'),
  const ThemeAvatarData(initials: 'CJ'),
], maxVisible: 2)
```

---

## State & status widgets

Common list/screen states (empty, error, loading) and status indicators — near-universal needs across any app screen.

### `ThemeEmptyState`
Icon + title + optional subtitle + optional CTA, centered — for empty lists/search results.
```dart
ThemeEmptyState({
  required String title,
  String? subtitle,
  IconData icon = Icons.inbox_outlined,
  String? actionLabel,
  VoidCallback? onAction, // only shown if both actionLabel and onAction are set
})
```
```dart
ThemeEmptyState(
  title: 'No orders yet',
  subtitle: 'Your past orders will show up here.',
  icon: Icons.receipt_long_outlined,
  actionLabel: 'Start shopping',
  onAction: () => Navigator.pushNamed(context, '/shop'),
)
```

### `ThemeErrorState`
Same layout as `ThemeEmptyState`, styled for failures — error-colored icon, retry action.
```dart
ThemeErrorState({
  String title = 'Something went wrong',
  String? subtitle,
  IconData icon = Icons.error_outline,
  String retryLabel = 'Retry',
  VoidCallback? onRetry, // retry button only shown if set
})
```

### `ThemeShimmer` / `ThemeShimmerList`
Animated skeleton-loading placeholder (sweeping gradient). `ThemeShimmerList` is a preset vertical list of shimmer rows for list-loading states.
```dart
ThemeShimmer({double? width, double height = 16, double? borderRadius}) // borderRadius defaults to the active theme's card radius
ThemeShimmerList({int itemCount = 6, double itemHeight = 64, double spacing = 12})
```
```dart
isLoading ? const ThemeShimmerList() : ListView(children: items)
```

### `ThemeStatusPill`
Small colored status/label pill (order status, tags, etc.) — semantic color by `ThemeStatus`.
```dart
ThemeStatusPill({
  required String label,
  ThemeStatus status = ThemeStatus.neutral, // success | error | warning | info | neutral
  IconData? icon,
})
```
```dart
ThemeStatusPill(label: 'Delivered', status: ThemeStatus.success, icon: Icons.check_circle_outline)
```

### `ThemeConfirmDialog`
Confirm/cancel dialog helper — resolves `true` only when the user taps confirm (never on dismiss/cancel).
```dart
ThemeConfirmDialog.show(BuildContext context, {
  required String title,
  String? content,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false, // renders confirm label in colorScheme.error
  bool barrierDismissible = true,
}) // returns Future<bool>
```
```dart
if (await ThemeConfirmDialog.show(context, title: 'Delete address?', isDestructive: true)) {
  await deleteAddress(id);
}
```

### `ThemeCountdownTimer`
Self-ticking `mm:ss` (or `hh:mm:ss` past one hour) countdown text, e.g. for OTP resend / flash-sale timers.
```dart
ThemeCountdownTimer({
  required Duration duration,
  VoidCallback? onFinished,
  TextStyle? style, // defaults to AppTypography.titleMedium
})
```

---

## Form helpers

### `ThemeStatCard`
Metric tile: label, value, optional leading icon, optional up/down/neutral trend line — for dashboards/profile summaries.
```dart
ThemeStatCard({
  required String label,
  required String value,
  IconData? icon,
  ThemeStatTrend? trend, // up | down | neutral
  String? trendLabel,    // e.g. '+12% this week' — shown only if trend is also set
})
```

### `ThemeStepper`
Horizontal numbered step indicator (checkoout flows, onboarding, multi-step forms) — no interaction, purely a progress display driven by `currentStep`.
```dart
ThemeStepper({required List<String> steps, required int currentStep})
```
```dart
ThemeStepper(steps: ['Cart', 'Address', 'Payment', 'Done'], currentStep: 1)
```

### `ThemeOtpField`
Auto-advancing row of single-digit boxes for OTP/verification codes.
```dart
ThemeOtpField({
  int length = 6,
  ValueChanged<String>? onChanged,   // fires on every digit entered/removed
  ValueChanged<String>? onCompleted, // fires once when all boxes are filled
  bool autofocus = true,
})
```

### `ThemePasswordField`
`TextField` with a lock icon and a built-in show/hide toggle — `ThemeTextField`'s `suffixIcon` is static, so this exists as a ready-made stateful password input.
```dart
ThemePasswordField({
  TextEditingController? controller,
  String? hintText,
  String? labelText = 'Password',
  String? errorText,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
  bool enabled = true,
})
```

### `ThemeTagInput`
Free-form chip/token input — pressing Enter or comma converts the current text into a themed `ThemeChip`, each individually removable.
```dart
ThemeTagInput({
  List<String> initialTags = const [],
  ValueChanged<List<String>>? onChanged,
  int? maxTags,
  String? hintText,
})
```
```dart
ThemeTagInput(initialTags: const ['flutter', 'dart'], onChanged: (tags) => print(tags), maxTags: 5)
```

### `ThemeLabeledField`
Generic label (+ optional required `*` marker) + field + helper text wrapper, for building form rows around any input widget (not just `ThemeTextField`).
```dart
ThemeLabeledField({
  required String label,
  required Widget child,
  String? helperText,
  bool required = false,
})
```
```dart
ThemeLabeledField(
  label: 'Shipping address',
  required: true,
  helperText: 'We deliver to this address by default.',
  child: ThemeTextField(hintText: '123 Main St'),
)
```

---

## Media & content widgets

Pulls in real third-party packages (`video_player`, `file_picker`, `markdown_widget`) rather than stubs — see [Third-party dependencies](#third-party-dependencies) below for what each one adds to a consuming app.

### `ThemeImageViewer`
Full-screen pinch-to-zoom image viewer (`InteractiveViewer` + black background). Tap to dismiss.
```dart
ThemeImageViewer({required Object src, Object? heroTag, double minScale = 1, double maxScale = 4})
ThemeImageViewer.show(BuildContext context, {required Object src, Object? heroTag}) // pushes it as a route
```
`src` accepts the same types as `ThemeLazyImage` (`String` URL/asset path, or `Uint8List`).

### `ThemeGallery`
Grid of thumbnails (via `ThemeLazyImage`) that opens a swipeable, zoomable full-screen pager on tap, with a Hero transition and a "n / total" counter.
```dart
ThemeGallery({required List<Object> sources, int crossAxisCount = 3, double spacing = 4, double borderRadius = 8})
```

### `ThemeVideoPlayer`
Wraps `video_player` with themed play/pause + scrubber controls that fade in/out on tap.
```dart
ThemeVideoPlayer({
  required String source,
  ThemeVideoSourceType sourceType = ThemeVideoSourceType.network, // network | asset | file
  bool autoPlay = false,
  bool looping = false,
  bool showControls = true,
  double? aspectRatio,   // defaults to the video's native aspect ratio once loaded
  double? borderRadius,  // defaults to the active theme's card radius
})
```
`sourceType: .file` uses `dart:io`'s `File` — don't use it on web builds.

### `ThemeMarkdown`
Renders markdown via `markdown_widget`, pre-wired to the current `Theme` (picks light/dark config from `Theme.of(context).brightness`, paragraph/link colors from `colorScheme`).
```dart
ThemeMarkdown({
  required String data,
  bool selectable = true,
  bool shrinkWrap = true,
  ScrollPhysics? physics,
  EdgeInsetsGeometry? padding,
})
```

### `ThemeCodeBlock`
Monospace code display with an optional language label and copy-to-clipboard button. No syntax highlighting (no highlighter dependency) — use `ThemeMarkdown` with fenced code blocks if you need that.
```dart
ThemeCodeBlock({required String code, String? language, bool showCopyButton = true, double? borderRadius}) // borderRadius defaults to the active theme's card radius
```

### `ThemeExpandableText`
Text that truncates past `trimLines` with a "Show more" / "Show less" toggle — only shows the toggle if the text actually overflows.
```dart
ThemeExpandableText(
  String text, {
  int trimLines = 3,
  TextStyle? style,
  String expandLabel = 'Show more',
  String collapseLabel = 'Show less',
})
```

---

## App shell & status pages

### `ThemeSplashScreen`
Centered logo/app-name/tagline + optional spinner, for a launch screen.
```dart
ThemeSplashScreen({
  Widget? logo,
  String? appName,
  String? tagline,
  bool showProgress = true,
  Color? backgroundColor,
})
```

### `ThemeErrorPage`
Full-screen 404 / 403 / 500 page via named constructors — each pre-fills a sensible icon, title, subtitle, and action label (all overridable).
```dart
ThemeErrorPage.notFound({String? title, String? subtitle, String? actionLabel, VoidCallback? onAction})
ThemeErrorPage.forbidden({String? title, String? subtitle, String? actionLabel, VoidCallback? onAction})
ThemeErrorPage.serverError({String? title, String? subtitle, String? actionLabel, VoidCallback? onAction})
```
```dart
ThemeErrorPage.notFound(onAction: () => Navigator.of(context).pushReplacementNamed('/'))
```

### `ThemeAppDialog`
Generic dialog shell for arbitrary widget content — `ThemeDialog` only takes a `String? content`; use this when the body needs real widgets (a form, a list, custom layout).
```dart
ThemeAppDialog.show<T>(BuildContext context, {
  String? title,
  required Widget content,
  List<Widget>? actions,
  bool barrierDismissible = true,
  double? maxWidth, // defaults to 480
}) // returns Future<T?>
```

---

## Pickers

### `ThemeIconPicker`
Grid of `IconData` to choose from, with a selected-state outline.
```dart
ThemeIconPicker({required List<IconData> icons, IconData? selected, ValueChanged<IconData>? onSelected, int crossAxisCount = 6, double iconSize = 22})
ThemeIconPicker.show(BuildContext context, {required List<IconData> icons, IconData? selected}) // returns Future<IconData?>, opens as a bottom sheet
```

### `ThemeEmojiPicker`
Grid-based emoji picker. Bring your own emoji list (this package doesn't bundle an emoji dataset) — group them by category upstream and render one picker per category/tab if needed.
```dart
ThemeEmojiPicker({required List<String> emojis, ValueChanged<String>? onSelected, int crossAxisCount = 8, double emojiSize = 24})
ThemeEmojiPicker.show(BuildContext context, {required List<String> emojis}) // returns Future<String?>, opens as a bottom sheet
```

### `ThemeColorPicker`
Row/wrap of color swatches with a checkmark on the selected one (auto-contrasted black/white check).
```dart
ThemeColorPicker({required List<Color> colors, Color? selected, ValueChanged<Color>? onSelected, double swatchSize = 36, double spacing = 10})
```

### `ThemeHuePicker`
Free-form color picker: a saturation/value square plus a hue strip, built from `Container`/`GestureDetector`/`CustomPaint` — no extra package. Use this when the user needs to pick any color, not just one from a fixed list (`ThemeColorPicker` above).
```dart
ThemeHuePicker({
  required Color color,
  required ValueChanged<Color> onChanged,
  double squareSize = 200,
  double stripWidth = 28,
})
```

### `ThemeFileUploader`
Dashed drop-zone-style picker button (wraps `file_picker`) with a picked-files list (name + remove button) below it.
```dart
ThemeFileUploader({
  ValueChanged<List<PlatformFile>>? onFilesPicked,
  bool allowMultiple = false,
  FileType type = FileType.any, // from file_picker
  List<String>? allowedExtensions,
  String label = 'Choose file',
  String hint = 'or drag and drop',
})
```

---

## Commerce & access widgets

### `ThemeDiscountBadge`
Small "-N%" pill, e.g. on a product card.
```dart
ThemeDiscountBadge({required int percentOff, Color? color}) // color defaults to colorScheme.error
```

### `ThemeWishlistButton`
Animated heart toggle (outline ↔ filled) with a scale transition.
```dart
ThemeWishlistButton({required bool isWishlisted, ValueChanged<bool>? onChanged, double size = 24, Color? filledColor})
```

### `ThemePermissionSelector`
List of togglable permissions/roles/feature-flags, each a switch row with optional icon and description.
```dart
ThemePermission({required String id, required String label, String? description, IconData? icon})

ThemePermissionSelector({
  required List<ThemePermission> permissions,
  required Set<String> selectedIds,
  ValueChanged<Set<String>>? onChanged,
})
```

---

## Third-party dependencies

Beyond `google_fonts`, this package depends on `video_player` (`ThemeVideoPlayer`), `file_picker` (`ThemeFileUploader`), and `markdown_widget` (`ThemeMarkdown`). These pull in native platform code (iOS/Android/desktop plugin implementations) — every consuming app inherits that footprint even if it never uses those three widgets, since Dart/Flutter has no per-widget tree-shaking of native plugin registration. If binary size or platform-permission surface matters for your app, keep this in mind when upgrading the package.

---

## Colors & shadows (advanced / theming internals)

- `AppColors` — static light/dark palette constants and `lightColorScheme` / `darkColorScheme` getters. Pass a derived `ColorScheme` into `AppTheme.lightTheme(colorScheme: ...)` to rebrand. Defines full container roles (`primaryContainer`/`onPrimaryContainer`, `secondaryContainer`/`onSecondaryContainer`, `errorContainer`/`onErrorContainer`, `surfaceContainer(Low/High)`, `inverseSurface`/`onInverseSurface`) — not just the base `primary`/`secondary`/`surface`/`error` — so any widget that reads a container role from `ColorScheme` gets a color coherent with your brand instead of Flutter's unrelated hardcoded defaults.
- `AppShadowTheme` — a `ThemeExtension` holding named `BoxShadow` values (`shadowOne`, `cardShadow`, etc.), retrieved via `Theme.of(context).extension<AppShadowTheme>()`. `ThemeCard` uses this automatically. `AppShadowTheme()` (default) is tuned for light backgrounds; `AppShadowTheme.dark()` uses higher-opacity, larger-blur shadows so elevation stays visible against near-black surfaces — `AppTheme.darkTheme()` uses `AppShadowTheme.dark()` by default. Cards, menus, and dropdowns also lift onto a `surfaceContainer`-toned background in dark mode so elevation reads from surface tint as well as shadow, matching Material 3 dark-theme conventions. Also carries `cardBlur` (backdrop blur sigma, `0` = off) and `cardBorderColor`/`cardBorderWidth` (edge stroke, `cardBorderWidth == 0` = no border) — set via the owning `AppThemePreset` and consumed by `ThemeCard`. The `glassmorphism` preset is the only style that sets a nonzero `cardBlur` today, giving it a real frosted-glass backdrop (previously it only used translucent colors with no actual blur). `AppShadowTheme.hueShifted(double hueDelta)` returns a copy with every non-neutral shadow color rotated by `hueDelta` degrees, preserving each shadow's own saturation/lightness/alpha — used by `AppThemeGenerator.generate` to follow a picked seed color for styles with colorful shadows, without needing bespoke logic per style.
- The `*_theme.dart` files under `lib/src/components/` (`button_theme.dart`, `card_theme.dart`, `app_bar_theme.dart`, etc.) are internal `ThemeData` factory builders consumed by `AppTheme` — you should not need to call them directly; override via `AppTheme.lightTheme(colorScheme:, textTheme:, shadows:)` instead.

---

## Conventions for adding a new component

- Public, reusable widgets live in `lib/src/widgets/`; theme-plumbing widgets (that just wrap a Material widget to inherit app theming, like `ThemeButton`) live in `lib/src/components/`.
- Export every new public file from `lib/theme.dart`.
- Name widgets `ThemeX` for theme-plumbing wrappers, or a plain descriptive name (e.g. `AddToCartButton`, `ProfileAvatar`) for higher-level opinionated components.
- Prefer configurable enums/params with sensible defaults over hardcoded behavior, so callers can override without forking the widget.
- Update this file when adding, renaming, or changing the public API of a widget.

---

## New widgets

### `ThemeLazyImage`
Fade-in image with placeholder and error fallback. Accepts a network URL string, an asset path string, or `Uint8List` bytes. Respects `cacheWidth`/`cacheHeight` via `ResizeImage` for memory efficiency. If both `width` and `height` are omitted, it sizes to the decoded image's own intrinsic pixel size instead of filling its parent — useful inside a `FittedBox`/`ConstrainedBox` combo (see `ThemeImageViewer`/`ThemeGallery`'s zoom viewers) where you want it measured at its natural aspect ratio rather than stretched.
```dart
ThemeLazyImage({
  required Object src, // String (http/asset) or Uint8List
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? placeholder,
  Widget? errorWidget,
  double? borderRadius, // defaults to the active theme's card radius
  int? cacheWidth,
  int? cacheHeight,
  Duration fadeDuration = const Duration(milliseconds: 300),
})
```

### `ThemeSpinner`
Six custom-painted spinner types: `ripple`, `wave`, `dots`, `pulse`, `bars`, `dualRing`.
```dart
ThemeSpinner({
  ThemeSpinnerType type = ThemeSpinnerType.ripple,
  double size = 36,
  Color? color,
  double strokeWidth = 3,
  Duration duration = const Duration(milliseconds: 1000),
})
```

### `ThemeSkeleton` / `ThemeSkeletonLoader`
Loading skeletons built on `ThemeShimmer`. `ThemeSkeletonType`: `textLine`, `circleAvatar`, `card`, `listTile`, `gridTile`, `banner`, `paragraph`.
```dart
ThemeSkeleton({ThemeSkeletonType type, double? width, double? height, double? borderRadius}) // borderRadius defaults to the active theme's card radius (circleAvatar/listTile leading avatar stay circular regardless)
ThemeSkeletonLoader({ThemeSkeletonType type = ThemeSkeletonType.listTile, int count = 6, double spacing = 12})
```

### `ThemeSearchableDropdown<T>`
Dropdown that searches directly inline — the collapsed field becomes the search input when focused, filtering the overlay list as you type (no separate search field inside the dropdown). Generic over item type `T`; `itemLabel` extracts display text.
```dart
ThemeSearchableDropdown<T>({
  required List<T> items,
  String? label,
  String? hint,
  T? value,
  ValueChanged<T?>? onChanged,
  String Function(T) itemLabel, // default: toString()
  Widget Function(T)? itemLeading,
  double maxHeight = 320,
  bool enabled = true,
})
```

### `ThemeOtpInput`
OTP input with configurable box shape (`circle`/`rectangle`), paste support, and obscure mode.
```dart
ThemeOtpInput({
  int length = 6,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onCompleted,
  bool autofocus = true,
  BoxShape boxShape = BoxShape.circle,
  double boxSize = 52,
  double spacing = 10,
  bool obscure = false,
  TextInputType keyboardType = TextInputType.number,
})
```

### `ThemeAppPasswordField`
Password field with show/hide toggle and optional 4-segment strength indicator (`weak`/`fair`/`good`/`strong`).
```dart
ThemeAppPasswordField({
  TextEditingController? controller,
  String? hintText,
  String labelText = 'Password',
  String? errorText,
  ValueChanged<String>? onChanged,
  ValueChanged<String>? onSubmitted,
  bool enabled = true,
  bool showStrengthIndicator = false,
})
```

### `ThemeAccordion` / `ThemeAccordionList` / `ThemeAccordionItem`
Animated expand/collapse section with rotation indicator. `ThemeAccordionList` renders multiple items.
```dart
ThemeAccordion({
  required Widget title,
  required List<Widget> children,
  Widget? leading,
  Widget? trailing,
  bool initiallyExpanded = false,
  IconData? expandIcon,
})
ThemeAccordionItem({required Widget title, required List<Widget> children, Widget? leading, Widget? trailing})
ThemeAccordionList({required List<ThemeAccordionItem> items, int? initiallyExpandedIndex})
```

### `ThemePullToRefresh`
Themed `RefreshIndicator` wrapper.
```dart
ThemePullToRefresh({
  required Widget child,
  Future<void> Function()? onRefresh,
  double displacement = 40,
  ThemeSpinnerType refreshIndicatorType = ThemeSpinnerType.ripple,
})
```

### `ThemeDraggableList<T>`
Reorderable list with drag handle, proxy elevation, and custom leading/trailing builders.
```dart
ThemeDraggableList<T>({
  required List<T> items,
  required Widget Function(BuildContext, T, int) itemBuilder,
  ValueChanged<List<T>>? onReorder,
  Widget Function(BuildContext, T, int)? leading,
  Widget Function(BuildContext, T, int)? trailing,
  double spacing = 8,
})
```

### `ThemeAppDataTable`
Sortable, striped, paginated data table with optional checkbox selection. Uses `ThemeDataColumn` for column config.
```dart
ThemeAppDataTable({
  required List<ThemeDataColumn> columns,
  required List<List<Widget>> rows,
  ValueChanged<int>? onRowTap,
  void Function(int columnIndex, bool ascending)? onSort,
  bool stripeRows = true,
  bool showCheckboxColumn = false,
  ValueChanged<Set<int>>? onSelectionChanged,
  int? pageSize,
  Widget? header,
})
ThemeDataColumn({required Widget label, bool numeric = false, bool sortable = false})
```

### `ThemeAppConfirmDialog`
Confirm dialog with optional leading icon; `isDestructive` colors the confirm button with `colorScheme.error`.
```dart
ThemeAppConfirmDialog.show(BuildContext context, {
  required String title,
  String? content,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool isDestructive = false,
  bool barrierDismissible = true,
  IconData? icon,
}) // returns Future<bool>
```

### `ThemeNotificationCard`
In-app notification card with typed color/icon (`info`/`success`/`warning`/`error`/`default_`), timestamp, actions, and dismiss button.
```dart
ThemeNotificationCard({
  required String title,
  String? message,
  ThemeNotificationType type = ThemeNotificationType.default_,
  Widget? leading,
  List<Widget> actions = const [],
  VoidCallback? onDismiss,
  String? timestamp,
  EdgeInsetsGeometry margin = const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
})
```

### `ThemePushNotification`
OS-style push notification card. Styles: `basic`, `bigText`, `bigImage`, `inbox`, `media`, `progress`.
```dart
ThemePushNotification({
  required String title,
  String? body,
  ThemePushNotificationStyle style = ThemePushNotificationStyle.basic,
  ImageProvider? imageProvider,
  List<String> lines = const [],
  double? progress,
  String? timestamp,
  String appName = 'App',
  Widget appIcon = const Icon(Icons.notifications, size: 14),
  VoidCallback? onTap,
})
```

### `ThemeCommandPalette` / `ThemeCommand`
VS Code / Spotlight-style command palette dialog with fuzzy search, keyboard selection, shortcuts, and tags.
```dart
ThemeCommandPalette.show(BuildContext context, {
  List<ThemeCommand> commands = const [],
  String placeholder = 'Search commands...',
}) // returns Future<ThemeCommand?>

ThemeCommand({
  required String id,
  required String label,
  String? description,
  IconData? icon,
  String? shortcut,
  List<String>? tags,
  VoidCallback? run,
})
```

### `ThemeStyleSwitcher`
Visual horizontal-scroll grid of theme-style preview cards. Each card is painted from the style's own `ColorScheme` and `AppShadowTheme`, so the user sees a faithful miniature of the theme before selecting it. Tap a card to switch the entire app theme live.
```dart
ThemeStyleSwitcher({
  List<AppThemeStyle>? styles, // defaults to AppThemeStyle.all
  String selectedId = 'material',
  ValueChanged<String>? onSelected,
  Brightness brightness = Brightness.light, // which variant to preview
  double cardWidth = 140,
  double cardHeight = 96,
  double spacing = 12,
  bool showLabels = true,
})
```
```dart
ThemeStyleSwitcher(
  selectedId: controller.value.styleId,
  onSelected: controller.setStyle,
)
```

---

## Theme presets

`AppThemePreset` bundles a complete theme (color scheme, shadows, shape radii, typography) into one switchable object. Call `.toThemeData()` to get a `ThemeData` you can pass to `MaterialApp`.

### Usage
```dart
MaterialApp(
  theme: LightPresets.neumorphism.toThemeData(),
  darkTheme: DarkPresets.darkHighContrast.toThemeData(),
  themeMode: ThemeMode.system,
)
```
Switching a preset overwrites every shadow, color, and radius in one call — no per-widget rewiring.

### `LightPresets` (18 presets)
`default`, `flat`, `material`, `neumorphism`, `glassmorphism`, `brutalism`, `maximalism`, `skeuomorphism`, `skeuominimalism`, `retro8bit`, `cyberpunk`, `claymorphism`, `bauhaus`, `organic`, `typographic`, `minimalismMono`, `papercut`, `skeuomorphismClassic`.

`LightPresets.all` — full `List<AppThemePreset>`.
`LightPresets.byId(String id)` — lookup by preset `id`.

### `DarkPresets`
`default`, `darkHighContrast` (`id: 'dark-highcontrast'`).

`DarkPresets.all` / `DarkPresets.byId(String id)`.

### `AppThemePreset` fields
```dart
AppThemePreset({
  required String id,
  required String name,
  required Brightness brightness,
  required ColorScheme colorScheme,
  required AppShadowTheme shadows,
  TextTheme? textTheme,
  double cardRadius = 16,
  double buttonRadius = 12,
  double inputRadius = 16,
  double dialogRadius = 16,
  bool useMaterial3 = true,
  double cardBlur = 0,        // backdrop blur sigma for glass-style surfaces
  Color? cardBorderColor,     // card edge stroke (e.g. glassmorphism's rim)
  double cardBorderWidth = 0, // 0 draws no border
  Color? borderColor,         // shared stroke color for every other surface (buttons, chips, inputs, dialogs, menus, badges, tabs, nav, avatars, tooltips, tables...)
  double borderWidth = 0,     // 0 draws no border; widgets may apply their own multiplier for scale (e.g. a thinner border on a small badge)
  bool forceFlat = false,     // true = no backdrop blur/decorative translucency/gradient anywhere, package-wide
  ThemeTextTransform textTransform = ThemeTextTransform.none, // none | uppercase — applied to headings and control labels (buttons/chips/tabs/badges), not body text
  double letterSpacingBoost = 0, // extra tracking added on top of each text style's own letterSpacing
})
```
`cardBlur`/`cardBorderColor`/`cardBorderWidth` flow into `AppShadowTheme` (see below) and are read by `ThemeCard`, which wraps its content in `BackdropFilter` when `cardBlur > 0` and draws a stroked edge when `cardBorderWidth > 0`.

`borderColor`/`borderWidth`/`forceFlat`/`textTransform` also round-trip through the `AppShadowTheme` extension (so they're readable via `Theme.of(context).extension<AppShadowTheme>()` from any widget, the same way `cardBlur` is) and are additionally wired directly into `toThemeData()`'s button/card/dialog/dropdown/chip/segmented-button/FAB/input sub-themes as a `BorderSide`. Every widget that draws its own ad-hoc decoration (badges, pills, avatars, tooltips, toasts, data tables, notification cards) reads `borderWidth`/`borderColor`/`forceFlat`/`textTransform` from that same `AppShadowTheme` extension and renders accordingly — components stay theme-agnostic and never special-case a preset by id. Defaults (`borderWidth = 0`, `forceFlat = false`, `textTransform = ThemeTextTransform.none`) preserve prior behavior for every preset that doesn't opt in. The `brutalism`, `retro-8bit`, `bauhaus`, `typographic`, `minimalism-mono`, `cyberpunk`, `maximalism`, `flat`, and `papercut` styles are the ones that currently set these to push their own genre further (e.g. Brutalism: thick black borders everywhere, uppercase tracked labels, forced flat surfaces).

`AppThemePreset.copyWith({...})` returns a copy with only the given fields replaced — used by `AppThemeGenerator.generate(baseStyle:)` to recolor a preset without touching its radii/shadows/elevation.

---

## Theme generator

Beyond the 20 hand-designed styles, `AppThemeGenerator` builds a complete, coherent `AppThemeStyle` from a single seed color — pick one color, everything else (secondary/tertiary colors, containers, surfaces, a matching dark variant, and a font pairing) is derived automatically.

- **Colors**: uses `ColorScheme.fromSeed` — Flutter's own Material 3 tonal-palette algorithm (the same one Android 12+ Material You uses) — for every role *except* `primary`/`onPrimary`, which are pinned to the exact color you picked (`fromSeed` normally snaps `primary` to the nearest tonal-palette value, which can visibly differ from the raw seed; buttons/accents should be exactly what was picked, so that one role bypasses the snap while everything else still derives from the tonal algorithm for a coherent, contrast-safe palette).
- **Shadows**: any style with colorful (non-neutral) shadows — Maximalism's pink/yellow/blue stack, Cyberpunk's magenta/cyan, etc. — has them hue-shifted by the same delta the seed color moved from the base style's own primary (`AppShadowTheme.hueShifted`). A multi-color shadow stack keeps its relative hue spread (still reads as multi-tone) instead of staying hardcoded to the original style's palette or collapsing onto one flat color. Neutral shadows (blacks/whites/greys, low saturation) are left untouched.
- **Fonts**: either pick a heading font and a body font independently from `AppFontCatalog` (any valid Google Fonts family name works, not just ones in the catalog), or pick one of `AppFontPairings`' curated heading+body pairs (`bold`, `classic`, `geometric`, `editorial`, `friendly`, `technical`), or omit both and let `AppThemeGenerator.suggestFontPairing` auto-pick a pairing from the seed color's HSL mood (saturated/dark → bold or technical, muted → classic, light/pastel → friendly, warm hues → editorial).
- **Style**: pass `baseStyle` to layer color/font/shadow-tint on top of any existing `AppThemeStyle` (a built-in preset, or another generated one) — color, font, and base style are fully independent, so any combination works together.

### `AppThemeGenerator`
```dart
AppThemeGenerator.generate({
  required Color seed,
  String? headingFont,         // any Google Fonts family name; wins over fontPairing's heading
  String? bodyFont,            // any Google Fonts family name; wins over fontPairing's body
  AppFontPairing? fontPairing, // used for any font slot headingFont/bodyFont didn't cover
  AppThemeStyle? baseStyle,    // null = a plain rounded-corner default shape
  String id = 'generated',
  String name = 'Custom',
}) // -> AppThemeStyle

AppThemeGenerator.suggestFontPairing(Color seed) // -> AppFontPairing
```
Pass `baseStyle` to recolor/refont an existing style in place — every non-color, non-font aspect of it (radii, shadows, borders, elevation, blur) carries over unchanged, so picking a new seed color or font on top of e.g. Brutalism only changes that, keeping its square corners and thick borders instead of silently swapping in a different visual style. `ThemeController` in the example app does this by passing `AppThemeStyle.byId(value.styleId)` as `baseStyle`, and re-applies the same color/font when the style itself is switched — so theme, color, and font are three independent choices that combine freely.
```dart
final style = AppThemeGenerator.generate(
  seed: Color(0xFF00897B),
  headingFont: 'Space Grotesk',
  bodyFont: 'Work Sans',
  baseStyle: AppThemeStyle.byId('brutalism'),
);
MaterialApp(
  theme: style.themeData(Brightness.light),
  darkTheme: style.themeData(Brightness.dark),
);
```

### `AppFontPairing` / `AppFontPairings`
```dart
class AppFontPairing {
  final String name;   // e.g. 'Editorial'
  final String heading; // Google Fonts family for headline/title styles
  final String body;    // Google Fonts family for body/label styles
}

AppFontPairings.all // List<AppFontPairing>: bold, classic, geometric, editorial, friendly, technical
```

### `AppFontCatalog`
A curated list of individually-pickable Google Fonts family names, grouped by category, for a free "any heading font + any body font" picker — as opposed to `AppFontPairings`' fixed pairs. Any valid Google Fonts family name works with `AppThemeGenerator.generate` even if it isn't in this list; the catalog just gives a picker UI something reasonable to show.
```dart
AppFontCatalog.byCategory // Map<String, List<String>>: 'Sans-serif', 'Display / geometric', 'Serif', 'Rounded / friendly', 'Monospace'
AppFontCatalog.all        // List<String> — every font across all categories
```

### `AppSeedPalette`
A spread of 12 predefined seed-color swatches (purple, blue, teal, green, orange, pink, red, brown, blue-grey, indigo, cyan, amber) for a quick-pick palette — each one produces a clean `ColorScheme.fromSeed` result.
```dart
AppSeedPalette.swatches // List<Color>
```

### `ThemeCustomizer`
The end-to-end picker UI: a predefined-palette grid (`ThemeColorPicker` + `AppSeedPalette`), a free-form `ThemeHuePicker`, font-pairing chips (Auto + each `AppFontPairings` entry), and independent heading/body font dropdowns (`AppFontCatalog`) — all feeding `AppThemeGenerator` live via a `ThemeCustomizerResult`.
```dart
ThemeCustomizer({
  required Color seedColor,
  required ValueChanged<ThemeCustomizerResult> onChanged,
  AppFontPairing? pairing,   // currently-selected curated pairing, if any
  String? headingFont,       // currently-selected independent heading font, if any
  String? bodyFont,          // currently-selected independent body font, if any
  bool showHuePicker = true,
})

class ThemeCustomizerResult {
  final Color seedColor;
  final AppFontPairing? pairing;
  final String? headingFont; // set (independently of bodyFont) wins over pairing.heading
  final String? bodyFont;    // set (independently of headingFont) wins over pairing.body
}
```
```dart
ThemeCustomizer(
  seedColor: _seed,
  pairing: _pairing,
  headingFont: _heading,
  bodyFont: _body,
  onChanged: (r) => setState(() {
    _seed = r.seedColor;
    _pairing = r.pairing;
    _heading = r.headingFont;
    _body = r.bodyFont;
    _style = AppThemeGenerator.generate(
      seed: r.seedColor,
      fontPairing: r.pairing,
      headingFont: r.headingFont,
      bodyFont: r.bodyFont,
      baseStyle: _currentStyle, // keep whatever style is already selected
    );
  }),
)
```

---

## Theme styles (light + dark pairs)

`AppThemeStyle` pairs a light and dark `AppThemePreset` under a single named style. Each of the 20 styles below exposes `.themeData(Brightness)` so you can pass both a `theme` and `darkTheme` from one selection — switching a style overwrites every shadow, color, and radius for both modes at once.

### Usage
```dart
final style = AppThemeStyle.byId('neumorphism');

MaterialApp(
  theme: style.themeData(Brightness.light),
  darkTheme: style.themeData(Brightness.dark),
  themeMode: ThemeMode.system,
)
```

### Available styles (`AppThemeStyle.all`)
| id | name |
|---|---|
| `light` | Light |
| `dark` | Dark |
| `flat` | Flat |
| `material` | Material |
| `neumorphism` | Neumorphism |
| `glassmorphism` | Glassmorphism |
| `brutalism` | Brutalism |
| `maximalism` | Maximalism |
| `skeuomorphism` | Skeuomorphism |
| `skeuominimalism` | Skeuominimalism |
| `dark-highcontrast` | Dark High Contrast |
| `retro-8bit` | Retro 8-bit |
| `cyberpunk` | Cyberpunk |
| `claymorphism` | Claymorphism |
| `bauhaus` | Bauhaus |
| `organic` | Organic |
| `typographic` | Typographic |
| `minimalism-mono` | Minimalism Mono |
| `papercut` | Papercut |
| `skeuomorphism-classic` | Skeuomorphism Classic |

### `AppThemeStyle` API
```dart
AppThemeStyle({
  required String id,
  required String name,
  required AppThemePreset lightPreset,
  required AppThemePreset darkPreset,
})

// pick the preset for a brightness
AppThemePreset preset(Brightness brightness)
// build ThemeData for a brightness
ThemeData themeData(Brightness brightness)

AppThemeStyle.all          // List<AppThemeStyle> (20)
AppThemeStyle.byId(String) // lookup by id, falls back to 'material'
```

### Static constants
Each style is also available as a named constant: `AppThemeStyle.light`, `.dark`, `.flat`, `.material`, `.neumorphism`, `.glassmorphism`, `.brutalism`, `.maximalism`, `.skeuomorphism`, `.skeuominimalism`, `.darkHighContrast`, `.retro8bit`, `.cyberpunk`, `.claymorphism`, `.bauhaus`, `.organic`, `.typographic`, `.minimalismMono`, `.papercut`, `.skeuomorphismClassic`.
