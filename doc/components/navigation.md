# Navigation

### UiNavItem
Data for one destination. All navigation bars use it.

```dart
const UiNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home', badge: '3');
```
- `icon`, `label` (required), `selectedIcon`, `badge` (`''` shows a dot).

### UiTabView
Filled pill tabs with their pages. It makes its own tab controller.

```dart
UiTabView(tabs: const ['All', 'Shoes', 'Bags'], children: const [AllPage(), ShoesPage(), BagsPage()]);
```
- `tabs`, `children` (required, same length).
- `icons`, `initialIndex` (0), `onChanged`, `scrollable` (default: true for more than 4 tabs), `barPadding` (`UiSpace.page`), `spacing` (12), `physics`.
- `height`: fixed page height. Without it, the view fills the parent height.

### UiTabBar
Only the pill tab bar: a rounded track with a filled pill indicator.

```dart
UiTabBar(tabs: const ['Day', 'Week', 'Month'], selectedIndex: i, onChanged: (v) => setState(() => i = v));
```
- `tabs` (required), `icons`, `controller`, `selectedIndex` (0), `onChanged`, `scrollable`, `height` (46).
- Controller order: `controller`, then `DefaultTabController`, then an internal controller.

### UiBottomNav
Material 3 bottom navigation bar with a pill indicator and badges.

```dart
UiBottomNav(items: items, index: i, onChanged: (v) => setState(() => i = v));
```
- `items` (2 or more), `index`, `onChanged`.

### UiFloatingNavBar
Floating pill bottom bar. The selected item grows and shows its label.

```dart
Scaffold(extendBody: true, body: page, bottomNavigationBar: UiFloatingNavBar(items: items, index: i, onChanged: select));
```
- `items`, `index`, `onChanged` (required), `margin`, `maxWidth` (480).
- Set `extendBody: true` on the `Scaffold` so content shows behind the bar.

### UiAdaptiveShell
App shell that changes with the width. Compact: bottom bar. Medium: navigation rail. Expanded: extended rail. Page state stays.

```dart
UiAdaptiveShell(destinations: items, pages: const [HomePage(), SearchPage(), ProfilePage()]);
```
- `destinations`, `pages` (required, same length).
- `initialIndex` (0), `onChanged`, `header` (top of rail), `floatingActionButton`, `appBar`, `floating` (use `UiFloatingNavBar` on compact).

### UiStepIndicator
Horizontal steps with numbered circles, check marks, and connecting lines.

```dart
UiStepIndicator(steps: const ['Cart', 'Address', 'Pay'], current: 1);
```
- `steps`, `current` (required; `steps.length` means all done), `onTap`, `showLabels` (true), `size` (32).

### UiPageDots
Page indicator. The active dot stretches into a pill.

```dart
UiPageDots(count: 3, controller: pageController);
UiPageDots(count: 3, index: page);
```
- `count` (required), `index`, `controller` (follows the scroll), `onTap` (default: go to that page), `size` (8), `activeWidth` (24).

### UiBreadcrumbs
Path of labels. A tap on an earlier label calls `onTap`.

```dart
UiBreadcrumbs(items: const ['Home', 'Shoes', 'Running'], onTap: goTo);
```
- `items` (required), `onTap`, `separator` (chevron).

### UiDrawer
Navigation drawer with a user header and selectable items. A tap closes the drawer.

```dart
UiDrawer(name: 'Asha Rao', email: 'asha@mail.com', items: items, selectedIndex: i, onSelected: select);
```
- `items` (required), `selectedIndex`, `onSelected`, `name`, `email`, `avatarUrl`, `header` (replaces the user header), `footer`.
