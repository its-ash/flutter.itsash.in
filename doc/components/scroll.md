# Scroll & lazy loading

Paged lists and grids, pull-to-refresh, a back-to-top button and lazy building.

### UiPagingController

Loads a list page by page. It guards against concurrent loads. Widgets that receive it never dispose it, so call `dispose()` yourself.

```dart
final paging = UiPagingController<Post>(fetch: (page, size) => api.posts(page: page, limit: size));
```

- `fetch(page, pageSize)`: returns one page. A page shorter than `pageSize` is the last one. Required.
- `pageSize`: default `20`.
- `firstPage`: default `1`.
- State: `items`, `length`, `loading`, `refreshing`, `error`, `hasMore`, `isEmpty`, `isFirstLoad`, `nextPage`.
- Actions: `loadMore()`, `retry()`, `refresh()` (keeps items until the new first page arrives), `reset()`, `updateItems(fn)`.

### UiInfiniteList

List that loads the next page as you near the end. Shows a skeleton on first load, an empty state, a loading row, and an error row with retry. Pull-to-refresh is built in.

```dart
UiInfiniteList<Post>(controller: paging, itemBuilder: (context, post, i) => PostTile(post))
```

- `controller`, `itemBuilder(context, item, index)` (`UiPagedItemBuilder<T>`): required.
- `separatorBuilder`: default: none.
- `empty`: shown when there are no items. Default: "Nothing here yet".
- `padding`: default: none.
- `loadingBuilder`: one skeleton item. Default: shimmer row.
- `errorBuilder(context, error, retry)` (`UiPagedErrorBuilder`): default: full-page error, or an error row under loaded items.
- `end`: shown after the last page. Default: small gap.
- `scrollController`, `physics`: default: none.
- `refreshable`: pull-to-refresh. Default `true`.
- `skeletonCount`: default `6`.

### UiInfiniteGrid

Grid version of `UiInfiniteList`.

```dart
UiInfiniteGrid<Photo>(controller: paging, crossAxisCount: 3, itemBuilder: (context, p, i) => UiImage(p.url))
```

- Same as `UiInfiniteList`, without `separatorBuilder`.
- `crossAxisCount` or `maxCrossAxisExtent` (default `200`).
- `childAspectRatio`: default `1`.
- `mainAxisSpacing`, `crossAxisSpacing`: default `UiSpace.md`.
- `skeletonCount`: default `9`.

### UiRefresh

Pull-to-refresh in the theme colors. The child must be scrollable.

```dart
UiRefresh(onRefresh: reload, child: ListView(children: rows))
```

- `onRefresh`, `child`: required.
- `displacement`: default `40`.
- `edgeOffset`: default `0`.

### UiScrollToTop

Floating "back to top" button that appears after the user scrolls past a threshold.

```dart
UiScrollToTop(controller: scroll, child: ListView(controller: scroll, children: rows))
```

- `controller`: the scrollable's controller. Required. Not disposed here.
- `child`: required.
- `threshold`: offset in pixels. Default `600`.
- `label`: optional text next to the arrow. Default: icon only.
- `alignment`: default `Alignment.bottomRight`.

### UiLazyBuilder

Builds its child only once it comes near the viewport. Outside a scrollable it builds right away.

```dart
UiLazyBuilder(builder: (context) => const ExpensiveChart(), placeholderHeight: 240)
```

- `builder`: required.
- `placeholderHeight`: default `200`.
- `margin`: distance outside the viewport that starts the build. Default `300`.
- `placeholder`: widget shown before building. Default: empty box.
