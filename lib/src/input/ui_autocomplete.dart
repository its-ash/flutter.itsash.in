import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/input/field_style.dart';
import 'package:theme/src/input/ui_field_label.dart';

/// Text field with a suggestions list under it. Suggestions come from a
/// fixed [options] list (filtered as you type) or an async [search]
/// function (debounced, with a loading row). The matched text is bold.
///
/// ```dart
/// UiAutocomplete<String>(label: 'City', options: cities, onSelected: pick)
/// ```
class UiAutocomplete<T extends Object> extends StatefulWidget {
  const UiAutocomplete({
    super.key,
    this.options = const [],
    this.search,
    this.displayString,
    this.subtitle,
    this.onSelected,
    this.onChanged,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.validator,
    this.controller,
    this.focusNode,
    this.prefixIcon = Icons.search_rounded,
    this.debounce = const Duration(milliseconds: 250),
    this.minChars = 1,
    this.maxResults = 8,
    this.emptyText = 'No matches',
    this.enabled = true,
    this.size = UiSize.md,
  });

  /// Fixed list of suggestions, filtered by "contains" (ignoring case).
  final List<T> options;

  /// Async source of suggestions. Takes precedence over [options].
  final Future<List<T>> Function(String query)? search;

  /// Text shown for an item. Defaults to `toString()`.
  final String Function(T item)? displayString;

  /// Optional second line for an item.
  final String? Function(T item)? subtitle;

  /// Called when a suggestion is picked.
  final ValueChanged<T>? onSelected;

  /// Called with the typed text.
  final ValueChanged<String>? onChanged;
  final String? label;
  final String? hint;
  final String? helper;
  final String? error;

  /// Validates the typed text inside a [Form].
  final FormFieldValidator<String>? validator;

  /// Optional external controller. Not disposed by this widget.
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final IconData? prefixIcon;

  /// Wait after typing before calling [search].
  final Duration debounce;

  /// Characters needed before suggestions show.
  final int minChars;
  final int maxResults;

  /// Row shown when nothing matches. Null hides the list instead.
  final String? emptyText;
  final bool enabled;
  final UiSize size;

  @override
  State<UiAutocomplete<T>> createState() => _UiAutocompleteState<T>();
}

class _UiAutocompleteState<T extends Object> extends State<UiAutocomplete<T>> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  Timer? _timer;
  int _request = 0;
  List<T> _results = const [];
  bool _loading = false;
  bool _suppressed = false;
  int _highlight = -1;
  double _width = 0;

  TextEditingController get _controller => widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  String _display(T item) => widget.displayString?.call(item) ?? item.toString();
  String get _query => _controller.text.trim();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(UiAutocomplete<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _focus.removeListener(_onFocus);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (_focus.hasFocus) {
      _portal.show();
      if (_results.isEmpty && !_suppressed) _update();
    } else {
      _portal.hide();
    }
    setState(() {});
  }

  void _onText(String v) {
    _suppressed = false;
    if (!_portal.isShowing && _focus.hasFocus) _portal.show();
    _update();
    widget.onChanged?.call(v);
  }

  void _update() {
    final q = _query;
    _timer?.cancel();
    final req = ++_request;
    if (q.length < widget.minChars) {
      setState(() {
        _results = const [];
        _loading = false;
        _highlight = -1;
      });
      return;
    }
    final search = widget.search;
    if (search == null) {
      final lower = q.toLowerCase();
      setState(() {
        _results = widget.options
            .where((o) => _display(o).toLowerCase().contains(lower))
            .take(widget.maxResults)
            .toList();
        _highlight = _results.isEmpty ? -1 : 0;
      });
      return;
    }
    setState(() => _loading = true);
    _timer = Timer(widget.debounce, () async {
      List<T> found;
      try {
        found = await search(q);
      } catch (_) {
        found = const [];
      }
      if (!mounted || req != _request) return;
      setState(() {
        _results = found.take(widget.maxResults).toList();
        _loading = false;
        _highlight = _results.isEmpty ? -1 : 0;
      });
    });
  }

  void _select(T item) {
    final text = _display(item);
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _timer?.cancel();
    _request++;
    setState(() {
      _suppressed = true;
      _results = const [];
      _loading = false;
      _highlight = -1;
    });
    widget.onSelected?.call(item);
  }

  bool get _panelVisible =>
      !_suppressed &&
      _focus.hasFocus &&
      _query.length >= widget.minChars &&
      (_loading || _results.isNotEmpty || widget.emptyText != null);

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is KeyUpEvent || !_panelVisible || _results.isEmpty) return KeyEventResult.ignored;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowDown) {
      setState(() => _highlight = (_highlight + 1) % _results.length);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.arrowUp) {
      setState(() => _highlight = (_highlight - 1 + _results.length) % _results.length);
      return KeyEventResult.handled;
    }
    if ((k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter) && _highlight >= 0) {
      _select(_results[_highlight]);
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.escape) {
      setState(() => _suppressed = true);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget _panel(BuildContext context) {
    final c = context.colors;
    if (!_panelVisible) return const SizedBox.shrink();
    Widget body;
    if (_loading && _results.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
        child: Row(
          children: [
            SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.accent)),
            const SizedBox(width: UiSpace.md),
            Flexible(
              child: Text(
                'Searching…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.bodyMedium?.copyWith(color: c.textMuted),
              ),
            ),
          ],
        ),
      );
    } else if (_results.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
        child: Text(widget.emptyText!, style: context.text.bodyMedium?.copyWith(color: c.textSubtle)),
      );
    } else {
      body = ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(UiSpace.xs),
        itemCount: _results.length,
        itemBuilder: (context, i) {
          final item = _results[i];
          final sub = widget.subtitle?.call(item);
          final active = i == _highlight;
          return Material(
            color: active ? c.surfaceMuted : Colors.transparent,
            borderRadius: UiRadius.all(UiRadius.sm),
            child: InkWell(
              borderRadius: UiRadius.all(UiRadius.sm),
              onTap: () => _select(item),
              onHover: (h) {
                if (h && _highlight != i) setState(() => _highlight = i);
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 40),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.sm),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Highlighted(text: _display(item), query: _query),
                      if (sub != null)
                        Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.bodySmall),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: UiRadius.all(UiRadius.md), boxShadow: context.shadowMd),
      child: Material(
        color: c.surfaceRaised,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: UiRadius.all(UiRadius.md),
          side: BorderSide(color: c.border),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 280),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading && _results.isNotEmpty) LinearProgressIndicator(minHeight: 2, color: c.accent),
              Flexible(child: body),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: _controller.text,
      enabled: widget.enabled,
      validator: widget.validator == null ? null : (_) => widget.validator!(_controller.text),
      builder: (field) {
        final err = widget.error ?? field.errorText;
        return UiFieldLabel(
          label: widget.label,
          helper: widget.helper,
          error: err,
          enabled: widget.enabled,
          child: LayoutBuilder(
            builder: (context, constraints) {
              _width = constraints.maxWidth;
              return OverlayPortal(
                controller: _portal,
                overlayChildBuilder: (context) => CompositedTransformFollower(
                  link: _link,
                  showWhenUnlinked: false,
                  targetAnchor: Alignment.bottomLeft,
                  offset: const Offset(0, 6),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: TextFieldTapRegion(
                      child: SizedBox(width: _width, child: _panel(context)),
                    ),
                  ),
                ),
                child: CompositedTransformTarget(
                  link: _link,
                  child: Focus(
                    canRequestFocus: false,
                    skipTraversal: true,
                    onKeyEvent: _onKey,
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      enabled: widget.enabled,
                      onChanged: (v) {
                        field.didChange(v);
                        _onText(v);
                      },
                      textAlignVertical: TextAlignVertical.center,
                      style: fieldTextStyle(context, widget.size, enabled: widget.enabled),
                      decoration: fieldDecoration(
                        context,
                        hint: widget.hint,
                        prefixIcon: widget.prefixIcon,
                        size: widget.size,
                        hasError: err != null,
                        enabled: widget.enabled,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _Highlighted extends StatelessWidget {
  const _Highlighted({required this.text, required this.query});

  final String text;
  final String query;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final base = context.text.bodyMedium?.copyWith(color: c.textMuted);
    final i = query.isEmpty ? -1 : text.toLowerCase().indexOf(query.toLowerCase());
    if (i < 0) {
      return Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: base?.copyWith(color: c.text),
      );
    }
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: text.substring(0, i)),
          TextSpan(
            text: text.substring(i, i + query.length),
            style: TextStyle(color: c.text, fontWeight: FontWeight.w700),
          ),
          TextSpan(text: text.substring(i + query.length)),
        ],
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: base,
    );
  }
}
