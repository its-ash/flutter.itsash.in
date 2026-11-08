# Scroll and lazy loading

Source: `lib/src/scroll/`. Infinite lists, lazy building, and scroll helpers. No extra packages.

### UiPagingController<T>
Holds the loaded items and the paging state. Pass it to `UiInfiniteList` or `UiInfiniteGrid`. Create it in `initState` (or as a `late final` field) and dispose it in `dispose`.
```dart
late final _orders = UiPagingController<Order>(
  pageSize: 20,
  fetch: (page, size) => api.orders(page: page, limit: size),
);
```
- `fetch` (`Future<List<T>> Function(int page, int pageSize)`), `pageSize` (20), `firstPage` (1)
- When a page returns fewer than `pageSize` items, there are no more pages.
- State: `items` (read-only list), `length`, `isEmpty`, `isLoading`, `isRefreshing`, `hasMore`, `hasError`, `error`, `nextPage`
- Actions: `loadMore()`, `retry()`, `refresh()` (loads the first page again and keeps the old items on screen until it finishes), `reset()`, `update((items) => ...)` (edit the list in place, for example to remove a deleted row)
- Replies from before a `refresh()` or `reset()` are ignored.

### UiInfiniteList<T>
A list that loads the next page when the user gets near the end.
```dart
UiInfiniteList<Order>(
  controller: _orders,
  itemBuilder: (context, order, i) => OrderTile(order),
  separatorBuilder: (_, _) => const Divider(height: 1),
)
```
- `controller`, `itemBuilder` (`(context, item, index)`), `separatorBuilder`, `header` (scrolls with the list)
- `padding`, `scrollController`, `physics`, `shrinkWrap`
- `prefetch` (3): starts the next page when one of the last N items is built
- `pullToRefresh` (true): pull down to call `controller.refresh()`
- `loadingBuilder` (first page; default skeleton rows), `emptyBuilder` (default "Nothing here yet"), `errorBuilder` (`(context, error, retry)`; default `UiErrorState`), `endBuilder` (after the last page)
- If a later page fails, the list keeps its items and shows "Could not load more" with **Retry** at the bottom.
- It loads the first page by itself. It keeps loading pages until the screen is full.

### UiInfiniteGrid<T>
Same as `UiInfiniteList`, as a grid.
```dart
UiInfiniteGrid<Product>(
  controller: _products,
  crossAxisCount: 2,
  childAspectRatio: 0.7,
  itemBuilder: (context, p, i) => UiProductCard(...),
)
```
- `gridDelegate` (overrides the next three), `crossAxisCount` (2), `childAspectRatio` (0.75), `spacing` (12)
- `padding` (16 on all sides), `prefetch` (4), and all other `UiInfiniteList` parameters except `separatorBuilder`.

### UiScrollToTop
Wraps a scroll view. A small round button shows after the user scrolls past `threshold`. A tap scrolls back to the top.
```dart
UiScrollToTop(controller: _scroll, child: ListView(controller: _scroll, children: ...))
```
- `controller` (the same `ScrollController` that the scroll view uses), `child`, `threshold` (600 px)
- `icon` (up arrow), `tooltip` ('Back to top'), `padding` (16), `alignment` (bottom end)

### UiLazyBuilder
Builds its child only when it first gets near the screen. After that, the child stays built. Use it for heavy widgets in a `Column` or `SingleChildScrollView` (for example charts or maps). `ListView.builder` already builds lazily, so it does not need this.
```dart
UiLazyBuilder(placeholderHeight: 240, builder: (_) => const UiLineChart(...))
```
- `builder`, `placeholder` (default empty box), `placeholderHeight` (200), `margin` (200 px around the screen that counts as "near")
- Outside a scroll view, it builds the child right away.
