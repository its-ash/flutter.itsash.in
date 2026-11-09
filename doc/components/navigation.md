# Navigation and app shell

App shell, nav bars, rails, sidebars, app bars, tabs and progress indicators. Import `package:theme/theme.dart`.

### UiNavItem
One destination for `UiShell`, `UiBottomNav`, `UiNavRail`, `UiSidebar` and `UiDrawer`.

```dart
const UiNavItem(Icons.inbox_outlined, 'Inbox', selectedIcon: Icons.inbox, badge: 3);
```

- `icon` (positional): icon when not selected.
- `label` (positional): text label.
- `selectedIcon`: icon when selected. Default `icon`.
- `badge`: count badge. Null or 0 hides it. Shows "99+" above 99.
- `dot`: small dot badge. Default `false`.

### UiShell
Adaptive app shell. Bottom nav on phones, navigation rail on tablets, full sidebar on desktop (1200 px and up).

```dart
UiShell(items: items, index: tab, onChanged: (i) => setState(() => tab = i), pages: pages);
```

- `items`: list of `UiNavItem`.
- `index`: selected index.
- `onChanged`: called with the tapped index. Null disables navigation.
- `pages`: one page per item, kept alive in an `IndexedStack`. Use this or `body`.
- `body`: the current page. Use this or `pages`.
- `appBar`: shown above the content (next to the rail or sidebar on wide screens).
- `fab`: floating action button.
- `header`, `footer`: top and bottom of the desktop sidebar.
- `railHeader`, `railFooter`: top and bottom of the rail.
- `floatingNav`: floating pill bottom nav on phones. Default `false`.
- `sidebarCollapsible`: lets users collapse the sidebar. Default `false`.
- Page state survives tab switches and window resizes.

### UiBottomNav
Bottom navigation bar with an animated selected pill and badges. `floating` gives a rounded pill that floats above the content.

```dart
UiBottomNav(items: items, index: tab, onChanged: (i) => setState(() => tab = i), floating: true);
```

- `items`, `index`, `onChanged` (null disables).
- `floating`: pill style, inset from the edges, above the home indicator. Default `false`. Set `extendBody: true` on the `Scaffold` (`UiShell` does this).
- `showLabels`: labels under icons. Default `true`. Icons get tooltips when `false`.

### UiNavRail
Vertical rail for tablets, built on `NavigationRail`. Needs at least two items.

```dart
UiNavRail(items: items, index: tab, onChanged: (i) => setState(() => tab = i));
```

- `items`, `index`, `onChanged` (null disables).
- `leading`, `trailing`: widgets above and below the items.
- `extended`: labels next to icons. Default `false`.
- `showLabels`: labels under icons when not extended. Default `true`.
- `border`: hairline on the trailing edge. Default `true`.

### UiSidebar
Desktop sidebar with header, titled sections, footer, and an optional collapse toggle.

```dart
UiSidebar(sections: [UiSidebarSection(title: 'Workspace', items)], index: i, onChanged: select, header: logo);
```

- `items` or `sections` (`UiSidebarSection(items, {title})`). `index` counts items across all sections.
- `index`, `onChanged` (null disables).
- `header`, `footer`: hidden when collapsed.
- `collapsible`: shows a collapse / expand toggle. Default `false`.
- `collapsed`: start collapsed. Default `false`.
- `onCollapsedChanged`: called when the user toggles.
- `width`: expanded width. Default `264`. Collapsed width is `UiSidebar.collapsedWidth` (72).
- `border`: hairline on the trailing edge. Default `true`.

### UiDrawer
Navigation drawer with a header slot, sectioned items and a soft selected pill. Closes after a tap.

```dart
Scaffold(drawer: UiDrawer(items: items, index: page, onChanged: (i) => setState(() => page = i)));
```

- `items` or `sections`, `index`, `onChanged` (null disables).
- `header`, `footer`.
- `width`: default `304` (never wider than the screen minus 56).
- `closeOnTap`: default `true`.

### UiAppBar
Top app bar with title, subtitle, actions and an automatic back button. `large` adds an iOS-style large title.

```dart
Scaffold(appBar: UiAppBar(title: 'Settings', actions: [IconButton(onPressed: add, icon: const Icon(Icons.add))]));
```

- `title`: text title. `titleWidget` replaces it.
- `subtitle`: second line under the title.
- `leading`: replaces the back button.
- `actions`: trailing widgets.
- `back`: show a back button. Default `null` = show when the route can pop. Full-screen dialogs get a close icon.
- `onBack`: back action. Default `Navigator.maybePop`.
- `bottom`: widget under the toolbar (such as tabs in a `PreferredSize`).
- `centerTitle`: default start-aligned.
- `large`: large title under the toolbar. Default `false`.
- `border`: hairline under the bar. Default `false`.
- `backgroundColor`: default `colors.background`.

### UiSliverAppBar
Sliver app bar for `CustomScrollView`. The large title shrinks into the toolbar on scroll.

```dart
CustomScrollView(slivers: [const UiSliverAppBar(title: 'Inbox'), SliverList.list(children: rows)]);
```

- `title` (required), `leading`, `actions`, `back`, `onBack`, `bottom`, `backgroundColor`.
- `large`: collapsing large title. Default `true`. `false` gives a plain toolbar.
- `pinned`: toolbar stays visible. Default `true`.
- `floating`: bar comes back on scroll up. Default `false`.

### UiTabs
Tab bar in three styles: underline, pill (accent pill slides in a muted track), segment (iOS segmented control).

```dart
UiTabs(tabs: const ['Day', 'Week', 'Month'], index: i, onChanged: (v) => setState(() => i = v));
```

- `tabs`: `String` or `UiTab(label, {icon, count})` entries.
- `index`: selected index when no controller is used.
- `controller`: external `TabController` (not disposed). A `DefaultTabController` above also works.
- `onChanged`: called on tap. Without `onChanged` or a controller the tabs are disabled.
- `variant`: `UiTabsVariant.underline` (default), `.pill`, `.segment`.
- `scrollable`: tabs keep natural width and scroll. Default `false`. Ignored for `segment`.

### UiTabView
`UiTabs` above a swipeable `TabBarView`. Needs a bounded height.

```dart
UiTabView(tabs: const ['Posts', 'Likes'], children: const [PostsPage(), LikesPage()]);
```

- `tabs`, `children`: same length.
- `variant`, `scrollable`: as in `UiTabs`.
- `initialIndex`: default `0`.
- `onChanged`: called on tap or swipe.
- `tabsPadding`: space around the tab bar. Default `EdgeInsets.zero`.

### UiBreadcrumbs
Page path like "Home › Projects › Theme". Middle items collapse into "…" (a menu) when space is short.

```dart
UiBreadcrumbs(const ['Home', 'Projects', 'Theme'], onTap: (i) => goTo(i));
```

- `items` (positional): labels. The last one is the current page.
- `onTap`: called with the tapped index. Null makes the path read-only.

### UiSteps
Step indicator with numbered circles, checks on done steps and connecting lines.

```dart
UiSteps(steps: const ['Cart', 'Address', 'Pay'], current: 1);
```

- `steps`: `String` or `UiStep(title, {description, icon})` entries.
- `current`: active step index. Steps before it are done. Use `steps.length` for all done.
- `direction`: `Axis.horizontal` (default) or `Axis.vertical` (shows descriptions as a list).
- `onTap`: called with the tapped step. Null makes steps not tappable.

### UiPagination
Compact page switcher: "‹ 1 … 4 5 6 … 20 ›". Shows fewer numbers on narrow widths and "5 / 20" on very narrow ones.

```dart
UiPagination(page: page, pageCount: 20, onChanged: (p) => setState(() => page = p));
```

- `page`: current page, starting at 1.
- `pageCount`: number of pages.
- `onChanged`: called with the new page. Null disables.
- `siblings`: pages shown on each side of the current one. Default `1`.
- `UiPagination.pages(page, pageCount)` returns the visible numbers, with `null` for "…".

### UiPageDots
Dot indicator for carousels and onboarding. The active dot stretches into a pill.

```dart
UiPageDots(count: 4, index: page, onTap: (i) => controller.jumpToPage(i));
```

- `count`, `index`.
- `onTap`: called with the tapped dot. Null makes dots not tappable.
- `size`: dot diameter. Default `8`.
- `activeWidth`: active dot width. Default `24`.
