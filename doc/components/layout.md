# Layout and App Shell

## Quick start
Use `UiApp` in place of `MaterialApp`. It applies the light and dark theme for one brand.

```dart
void main() => runApp(const UiApp(title: 'Shop', brand: UiBrand.commerce, home: HomePage()));
```

To change the brand or the theme mode at runtime, give a `UiThemeController`:

```dart
final theme = UiThemeController(brand: UiBrand.fitness);

UiApp(title: 'Gym', controller: theme, home: const HomePage());
```

### UiThemeController
A `ValueNotifier<({ThemeMode mode, UiBrand brand})>`. It drives `UiApp`, `UiThemeModeSwitch`, and `UiBrandPicker`.

```dart
theme.setMode(ThemeMode.dark);
theme.toggleMode();
theme.setBrand(UiBrand.finance);
```
- `UiThemeController({ThemeMode mode = ThemeMode.system, UiBrand brand = UiBrand.neutral})`
- Getters: `mode`, `brand`. Methods: `setMode`, `toggleMode([Brightness? current])`, `setBrand`.
- `UiThemeScope.maybeOf(context)` gives the controller of the nearest `UiApp`.

### UiApp
Wraps `MaterialApp`. Default `debugShowCheckedModeBanner` is `false`.

```dart
UiApp(title: 'Shop', brand: UiBrand.commerce, home: const HomePage());
UiApp.router(routerConfig: router, brand: UiBrand.travel);
```
- `brand` (default `UiBrand.neutral`), `themeMode` (default `ThemeMode.system`), `controller`.
- Forwards: `home`, `routes`, `initialRoute`, `onGenerateRoute`, `onUnknownRoute`, `navigatorKey`, `navigatorObservers`, `scaffoldMessengerKey`, `locale`, `supportedLocales`, `localizationsDelegates`, `builder`.
- `UiApp.messengerKey` and `UiApp.messenger`: global access to the `ScaffoldMessengerState`.
- `UiApp.themeFor(brand, brightness)`: cached `ThemeData`.

### UiThemeModeSwitch
Compact segmented control for light, system, and dark mode.

```dart
const UiThemeModeSwitch();
```
- `controller` (default: the controller of `UiApp`), `showLabels` (default `false`).

### UiBrandPicker
Horizontal row of brand swatches. A tap sets the brand.

```dart
const UiBrandPicker();
```
- `controller`, `brands` (default `UiBrand.values`), `size` (40), `showLabels` (true), `padding` (`UiSpace.page`).

### UiScaffold
Page shell. It adds an app bar, page padding, scroll, a back button, and max-width centering.

```dart
UiScaffold(title: 'Cart', body: Column(children: items), bottomBar: UiButton('Checkout', expand: true, onPressed: pay));
```
- `body` (required), `title`, `subtitle`, `actions`, `appBar` (custom bar).
- `scrollable` (true): wraps `body` in a scroll view. Set `false` when `body` is a list.
- `padding` (`UiSpace.page`), `maxWidth` (720), `backgroundColor`.
- `onRefresh`: adds pull-to-refresh.
- `large`: uses a collapsing `SliverAppBar.large` title.
- `bottomBar`: sticky bottom content in a `UiStickyBottomBar`. `bottomNavigationBar`: raw bottom widget.
- `floatingActionButton`, `drawer`, `extendBody`, `showBack` (default: automatic).
- A tap outside a field closes the keyboard.

### UiAppBar
App bar with a tonal circle back button.

```dart
UiAppBar(title: 'Orders', subtitle: '12 active', actions: [UiIconButton(Icons.search_rounded, onPressed: search)]);
```
- `title`, `titleWidget`, `subtitle`, `actions`, `leading`, `centerTitle`, `showBack`, `onBack`, `bottom`, `backgroundColor`.

### UiBackButton
Tonal circle back button. It shows a close icon on full-screen dialogs.

```dart
const UiBackButton();
```
- `onPressed` (default `Navigator.maybePop`), `icon`.

### UiStickyBottomBar
Bottom container for call-to-action buttons. It has a top divider, a soft shadow, and safe-area padding.

```dart
UiStickyBottomBar(child: UiButton('Book now', expand: true, onPressed: book));
```
- `child`, `padding`, `showDivider` (true), `maxWidth` (720), `color`.

### UiMaxWidth
Centers a child and limits its width on wide screens.

```dart
UiMaxWidth(maxWidth: 560, child: form);
```
- `child`, `maxWidth` (720).

### UiSection
Section with a title, an optional subtitle, and an optional "See all" action.

```dart
UiSection(title: 'Popular', onSeeAll: openAll, child: products);
```
- `child`, `title`, `subtitle`, `onSeeAll`, `actionLabel` ('See all'), `trailing`, `headerPadding`, `spacing` (12), `margin` (bottom 24).

### UiDividerText
Horizontal divider with text in the middle.

```dart
const UiDividerText();
```
- `text` ('or').

### UiListTile
Row with a tonal icon square, a title, a subtitle, and a trailing widget. A chevron shows when `onTap` is set.

```dart
UiListTile(icon: Icons.person_rounded, title: 'Profile', onTap: openProfile);
```
- `title` (required), `subtitle`, `icon`, `iconColor`, `leading`, `trailing`, `onTap`, `onLongPress`, `destructive`, `dense`, `enabled`, `selected`, `padding`.

### UiListGroup
Grouped rounded card of tiles with inset dividers, as in iOS settings.

```dart
UiListGroup(header: 'Account', children: [tileA, tileB]);
```
- `children` (required), `header`, `footer`, `dividerIndent` (default: automatic), `margin` (bottom 20).

### UiSettingsTile
Settings rows with minimal input.

```dart
UiSettingsTile.nav(icon: Icons.lock_rounded, title: 'Privacy', onTap: openPrivacy);
UiSettingsTile.toggle(icon: Icons.notifications_rounded, title: 'Alerts', checked: on, onChanged: setOn);
UiSettingsTile.value(icon: Icons.language_rounded, title: 'Language', value: 'English', onTap: pick);
UiSettingsTile.action(icon: Icons.logout_rounded, title: 'Sign out', onTap: signOut);
```
- All: `title`, `icon`, `subtitle`, `iconColor`.
- `.nav`: `onTap`, `value`. `.toggle`: `checked`, `onChanged`. `.value`: `value`, `onTap`. `.action`: `onTap`, `destructive` (true).

### UiResponsiveGrid
Grid. The column count comes from `minItemWidth`.

```dart
UiResponsiveGrid(children: cards);
UiResponsiveGrid.builder(itemCount: items.length, itemBuilder: (c, i) => ProductCard(items[i]));
```
- `children` form: no scroll, natural item height. Set `childAspectRatio` for a fixed height.
- `.builder` form: scrolls, lazy. `childAspectRatio` (0.75) or `mainAxisExtent`, `padding` (`UiSpace.page`), `controller`, `physics`, `shrinkWrap`.
- Both: `minItemWidth` (160), `spacing` (12), `runSpacing`, `maxColumns`.
- `UiResponsiveGrid.columnsFor(width)` gives the column count.

### UiSliverGrid
Sliver form of the responsive grid, for `CustomScrollView`.

```dart
UiSliverGrid(itemCount: items.length, itemBuilder: (c, i) => ProductCard(items[i]));
```
- `itemCount`, `itemBuilder`, `minItemWidth` (160), `spacing` (12), `runSpacing`, `childAspectRatio` (0.75), `mainAxisExtent`, `maxColumns`.
- `UiGridDelegate` is the `SliverGridDelegate` that both grids use.

### UiHorizontalList
Horizontal scroller with page padding.

```dart
UiHorizontalList(children: categories);
UiHorizontalList.builder(height: 220, itemCount: items.length, itemExtent: 160, itemBuilder: (c, i) => Card(items[i]));
```
- `children` form: height comes from the tallest child.
- `.builder` form: lazy, `height` is required.
- `spacing` (12), `padding` (`UiSpace.page`), `itemExtent`, `controller`.
- Inside a `UiScaffold` with page padding, set `padding: EdgeInsets.zero` on one of the two.

### UiResponsive
Shows a different widget for compact, medium, and expanded widths.

```dart
UiResponsive(compact: const PhoneView(), expanded: const DesktopView());
UiResponsive.builder(builder: (context, size) => Text(size.name));
```
- `compact` (required), `medium`, `expanded`. Missing sizes fall back to the next smaller size.
- `UiWindowSize { compact, medium, expanded }`, `UiWindowSize.of(width)`.

### UiExpandableCard
Card with a header that opens and closes the body with animation.

```dart
UiExpandableCard(title: 'Shipping', child: Text(info));
```
- `title`, `child` (required), `subtitle`, `icon`, `initiallyExpanded`, `expanded` (controlled), `onChanged`, `variant`.

### UiAccordion
List of expandable cards. One card opens at a time, or many when `multiple` is true.

```dart
UiAccordion(items: [UiAccordionItem.text(title: 'Returns', body: '30 days.')]);
```
- `items` (required), `multiple` (false), `initialIndex`, `spacing` (8), `onChanged(Set<int>)`, `variant`.
- `UiAccordionItem({title, child, subtitle, icon})`, `UiAccordionItem.text({title, body, subtitle, icon})`.
