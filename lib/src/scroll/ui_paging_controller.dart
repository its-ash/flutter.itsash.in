import 'dart:collection';

import 'package:flutter/foundation.dart';

typedef UiPageFetcher<T> = Future<List<T>> Function(int page, int pageSize);

class UiPagingController<T> extends ChangeNotifier {
  UiPagingController({required this.fetch, this.pageSize = 20, this.firstPage = 1}) : assert(pageSize > 0);

  final UiPageFetcher<T> fetch;
  final int pageSize;
  final int firstPage;

  final List<T> _items = [];
  late final UnmodifiableListView<T> _view = UnmodifiableListView(_items);
  late int _next = firstPage;
  bool _loading = false;
  bool _refreshing = false;
  bool _hasMore = true;
  bool _disposed = false;
  Object? _error;
  int _gen = 0;

  List<T> get items => _view;
  int get length => _items.length;
  bool get isEmpty => _items.isEmpty;
  bool get isLoading => _loading;
  bool get isRefreshing => _refreshing;
  bool get hasMore => _hasMore;
  bool get hasError => _error != null;
  Object? get error => _error;
  int get nextPage => _next;
  bool get isInitial => _items.isEmpty && !_loading && _error == null && _hasMore && _next == firstPage;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<void> loadMore() async {
    if (_loading || !_hasMore || _error != null || _disposed) return;
    final gen = _gen;
    _loading = true;
    _notify();
    try {
      final page = await fetch(_next, pageSize);
      if (gen != _gen || _disposed) return;
      _items.addAll(page);
      _next++;
      _hasMore = page.length >= pageSize;
    } catch (e) {
      if (gen != _gen || _disposed) return;
      _error = e;
    } finally {
      if (gen == _gen && !_disposed) {
        _loading = false;
        _notify();
      }
    }
  }

  Future<void> retry() {
    _error = null;
    return loadMore();
  }

  Future<void> refresh() async {
    if (_disposed) return;
    final gen = ++_gen;
    _loading = true;
    _refreshing = true;
    _error = null;
    _notify();
    try {
      final page = await fetch(firstPage, pageSize);
      if (gen != _gen || _disposed) return;
      _items
        ..clear()
        ..addAll(page);
      _next = firstPage + 1;
      _hasMore = page.length >= pageSize;
    } catch (e) {
      if (gen != _gen || _disposed) return;
      _error = e;
    } finally {
      if (gen == _gen && !_disposed) {
        _loading = false;
        _refreshing = false;
        _notify();
      }
    }
  }

  void reset() {
    _gen++;
    _items.clear();
    _next = firstPage;
    _hasMore = true;
    _error = null;
    _loading = false;
    _refreshing = false;
    _notify();
  }

  void update(void Function(List<T> items) edit) {
    edit(_items);
    _notify();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
