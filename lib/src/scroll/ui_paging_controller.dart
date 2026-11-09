import 'dart:async';
import 'dart:collection';

import 'package:flutter/foundation.dart';

/// Loads a list page by page. Give it to [UiInfiniteList] or [UiInfiniteGrid].
///
/// Widgets that receive the controller never dispose it; call [dispose]
/// yourself (usually in your `State.dispose`).
///
/// ```dart
/// final paging = UiPagingController<Post>(fetch: (page, size) => api.posts(page: page, limit: size));
/// ```
class UiPagingController<T> extends ChangeNotifier {
  UiPagingController({required this.fetch, this.pageSize = 20, this.firstPage = 1}) : _nextPage = firstPage;

  /// Returns the items of [page]. A result shorter than [pageSize] marks the
  /// last page.
  final Future<List<T>> Function(int page, int pageSize) fetch;

  final int pageSize;

  /// Number of the first page (usually 0 or 1).
  final int firstPage;

  final List<T> _items = [];
  int _nextPage;
  bool _loading = false;
  bool _hasMore = true;
  Object? _error;
  int _generation = 0;
  bool _disposed = false;
  Future<void>? _refreshing;
  bool _refreshFailed = false;

  /// Loaded items, in order.
  late final List<T> items = UnmodifiableListView(_items);

  int get length => _items.length;

  /// True while a page (or a refresh) is loading.
  bool get loading => _loading;

  /// True while [refresh] runs.
  bool get refreshing => _refreshing != null;

  /// Error of the last failed load, or null.
  Object? get error => _error;

  /// False once a page returned fewer than [pageSize] items.
  bool get hasMore => _hasMore;

  /// True when loading finished and there are no items at all.
  bool get isEmpty => _items.isEmpty && !_hasMore && !_loading && _error == null;

  /// True while nothing has loaded yet (first page pending).
  bool get isFirstLoad => _items.isEmpty && _hasMore && _error == null;

  /// Number of the next page [loadMore] will fetch.
  int get nextPage => _nextPage;

  /// Fetches the next page. Does nothing while a load is running or when
  /// there are no more pages.
  Future<void> loadMore() async {
    if (_loading || !_hasMore || _disposed) return;
    final generation = _generation;
    final page = _nextPage;
    _loading = true;
    _error = null;
    _refreshFailed = false;
    _notify();
    try {
      final result = await fetch(page, pageSize);
      if (generation != _generation || _disposed) return;
      _items.addAll(result);
      _nextPage = page + 1;
      _hasMore = result.length >= pageSize;
    } catch (e) {
      if (generation != _generation || _disposed) return;
      _error = e;
    }
    _loading = false;
    _notify();
  }

  /// Runs the failed load (page or refresh) again.
  Future<void> retry() => _refreshFailed ? refresh() : loadMore();

  /// Reloads from the first page. Current items stay visible until the new
  /// first page arrives. Calls while a refresh runs share that refresh.
  Future<void> refresh() {
    if (_disposed) return Future.value();
    return _refreshing ??= _refresh().whenComplete(() => _refreshing = null);
  }

  Future<void> _refresh() async {
    final generation = ++_generation;
    _loading = true;
    _error = null;
    _refreshFailed = false;
    _notify();
    try {
      final result = await fetch(firstPage, pageSize);
      if (generation != _generation || _disposed) return;
      _items
        ..clear()
        ..addAll(result);
      _nextPage = firstPage + 1;
      _hasMore = result.length >= pageSize;
    } catch (e) {
      if (generation != _generation || _disposed) return;
      _error = e;
      _refreshFailed = true;
    }
    _loading = false;
    _notify();
  }

  /// Clears everything. The next [loadMore] starts at [firstPage].
  void reset() {
    _generation++;
    _items.clear();
    _nextPage = firstPage;
    _hasMore = true;
    _loading = false;
    _error = null;
    _refreshFailed = false;
    _notify();
  }

  /// Replaces the loaded items (e.g. after a local edit or delete).
  void updateItems(List<T> Function(List<T> items) update) {
    final next = update(List.of(_items));
    _items
      ..clear()
      ..addAll(next);
    _notify();
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
