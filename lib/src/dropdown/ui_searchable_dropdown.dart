import 'dart:async';

import 'package:flutter/material.dart';

import 'package:theme/src/button/ui_button.dart';
import 'package:theme/src/chip/ui_chip.dart';
import 'package:theme/src/feedback/ui_states.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/input/ui_field_label.dart';
import 'package:theme/src/input/ui_search_field.dart';

typedef UiSearchCallback<T> = Future<List<T>> Function(String query);

String _str<T>(T v, String Function(T)? f) => f?.call(v) ?? v.toString();

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.items,
    required this.onSearch,
    required this.itemLabel,
    required this.itemSubtitle,
    required this.itemIcon,
    required this.selected,
    required this.multi,
    required this.title,
    required this.searchHint,
    required this.debounce,
    required this.max,
    required this.emptyText,
    required this.minChars,
  });

  final List<T> items;
  final UiSearchCallback<T>? onSearch;
  final String Function(T)? itemLabel;
  final String? Function(T)? itemSubtitle;
  final IconData? Function(T)? itemIcon;
  final List<T> selected;
  final bool multi;
  final String? title;
  final String searchHint;
  final Duration debounce;
  final int? max;
  final String emptyText;
  final int minChars;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  late final List<T> _sel = [...widget.selected];
  List<T> _results = const [];
  String _query = '';
  bool _loading = false;
  Object? _error;
  int _req = 0;

  @override
  void initState() {
    super.initState();
    _run('');
  }

  Future<void> _run(String q) async {
    _query = q.trim();
    final search = widget.onSearch;
    if (search == null) {
      final lq = _query.toLowerCase();
      setState(() => _results = lq.isEmpty
          ? widget.items
          : [for (final i in widget.items) if (_str(i, widget.itemLabel).toLowerCase().contains(lq)) i]);
      return;
    }
    if (_query.length < widget.minChars) {
      setState(() {
        _req++;
        _results = const [];
        _loading = false;
        _error = null;
      });
      return;
    }
    final id = ++_req;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await search(_query);
      if (!mounted || id != _req) return;
      setState(() {
        _results = r;
        _loading = false;
      });
    } catch (e) {
      if (!mounted || id != _req) return;
      setState(() {
        _error = e;
        _loading = false;
      });
    }
  }

  void _toggle(T item) {
    setState(() {
      if (_sel.contains(item)) {
        _sel.remove(item);
      } else if (widget.max == null || _sel.length < widget.max!) {
        _sel.add(item);
      }
    });
  }

  Widget _body(BuildContext context) {
    if (_error != null) return UiErrorState(compact: true, onRetry: () => _run(_query));
    if (_loading && _results.isEmpty) return const UiLoader();
    if (widget.onSearch != null && _query.length < widget.minChars) {
      return UiEmptyState(
        compact: true,
        icon: Icons.search_rounded,
        title: 'Type to search',
        message: widget.minChars > 1 ? 'Enter at least ${widget.minChars} characters' : null,
      );
    }
    if (_results.isEmpty) return UiEmptyState(compact: true, icon: Icons.search_off_rounded, title: widget.emptyText);
    final cs = context.colors;
    final full = widget.max != null && _sel.length >= widget.max!;
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: UiSpace.lg),
      itemCount: _results.length,
      itemBuilder: (context, i) {
        final o = _results[i];
        final on = _sel.contains(o);
        final sub = widget.itemSubtitle?.call(o);
        final ic = widget.itemIcon?.call(o);
        final title = Text(_str(o, widget.itemLabel), maxLines: 1, overflow: TextOverflow.ellipsis);
        final subtitle = sub == null ? null : Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis);
        if (widget.multi) {
          return CheckboxListTile(
            value: on,
            onChanged: !on && full ? null : (_) => _toggle(o),
            title: title,
            subtitle: subtitle,
            secondary: ic == null ? null : Icon(ic),
            controlAffinity: ListTileControlAffinity.trailing,
          );
        }
        return ListTile(
          leading: ic == null ? null : Icon(ic, color: on ? cs.primary : null),
          title: title,
          subtitle: subtitle,
          selected: on,
          trailing: on ? Icon(Icons.check_rounded, color: cs.primary) : null,
          onTap: () => Navigator.pop(context, <T>[o]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.title?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.sm, UiSpace.sm),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  t.isEmpty ? (widget.multi ? 'Select items' : 'Select') : t,
                  style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              if (widget.multi && _sel.isNotEmpty) TextButton(onPressed: () => setState(_sel.clear), child: const Text('Clear')),
              IconButton(
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg),
          child: UiSearchField(
            hint: widget.searchHint,
            autofocus: true,
            debounce: widget.onSearch == null ? Duration.zero : widget.debounce,
            onChanged: _run,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: UiSpace.sm),
          child: SizedBox(
            height: 2,
            child: _loading && _results.isNotEmpty ? const LinearProgressIndicator(minHeight: 2) : null,
          ),
        ),
        const SizedBox(height: UiSpace.xs),
        Expanded(child: _body(context)),
        if (widget.multi)
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.sm, UiSpace.lg, UiSpace.lg),
              child: UiButton(
                _sel.isEmpty ? 'Done' : 'Done (${_sel.length}${widget.max != null ? '/${widget.max}' : ''})',
                expand: true,
                onPressed: () => Navigator.pop(context, List<T>.of(_sel)),
              ),
            ),
          ),
      ],
    );
  }
}

Future<List<T>?> _openPicker<T>(BuildContext context, _PickerSheet<T> sheet) => showModalBottomSheet<List<T>>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: SizedBox(height: MediaQuery.sizeOf(ctx).height * 0.75, child: sheet),
      ),
    );

class _Trigger extends StatelessWidget {
  const _Trigger({
    required this.label,
    required this.hint,
    required this.helper,
    required this.error,
    required this.prefixIcon,
    required this.isRequired,
    required this.isEmpty,
    required this.enabled,
    required this.onTap,
    required this.onClear,
    required this.child,
  });

  final String? label;
  final String hint;
  final String? helper;
  final String? error;
  final IconData? prefixIcon;
  final bool isRequired;
  final bool isEmpty;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final r = context.tokens.md;
    return UiFieldLabel(
      label,
      isRequired: isRequired,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: label ?? hint,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: r,
          child: InputDecorator(
            isEmpty: isEmpty,
            decoration: InputDecoration(
              enabled: enabled,
              hintText: hint,
              helperText: helper,
              errorText: error,
              prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
              suffixIcon: onClear != null && !isEmpty && enabled
                  ? IconButton(tooltip: 'Clear', onPressed: onClear, icon: const Icon(Icons.close_rounded, size: 20))
                  : const Icon(Icons.keyboard_arrow_down_rounded),
              contentPadding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md + 2),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class UiSearchableDropdown<T> extends StatelessWidget {
  const UiSearchableDropdown({
    super.key,
    this.items = const [],
    this.onSearch,
    required this.value,
    required this.onChanged,
    this.itemLabel,
    this.itemSubtitle,
    this.itemIcon,
    this.label,
    this.hint = 'Select',
    this.searchHint = 'Search',
    this.sheetTitle,
    this.prefixIcon,
    this.helper,
    this.validator,
    this.isRequired = false,
    this.clearable = false,
    this.debounce = const Duration(milliseconds: 350),
    this.minChars = 0,
    this.emptyText = 'No results',
  });

  final List<T> items;
  final UiSearchCallback<T>? onSearch;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String Function(T)? itemLabel;
  final String? Function(T)? itemSubtitle;
  final IconData? Function(T)? itemIcon;
  final String? label;
  final String hint;
  final String searchHint;
  final String? sheetTitle;
  final IconData? prefixIcon;
  final String? helper;
  final FormFieldValidator<T>? validator;
  final bool isRequired;
  final bool clearable;
  final Duration debounce;
  final int minChars;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final cb = onChanged;
    final v = value;
    return FormField<T>(
      initialValue: v,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) => isRequired && v == null
          ? '${label?.trim().isNotEmpty == true ? label!.trim() : 'A value'} is required'
          : validator?.call(v),
      builder: (field) => _Trigger(
        label: label,
        hint: hint,
        helper: helper,
        error: field.errorText,
        prefixIcon: prefixIcon,
        isRequired: isRequired,
        isEmpty: v == null,
        enabled: cb != null,
        onClear: clearable && cb != null
            ? () {
                field.didChange(null);
                cb(null);
              }
            : null,
        onTap: () async {
          final picked = await _openPicker<T>(
            context,
            _PickerSheet<T>(
              items: items,
              onSearch: onSearch,
              itemLabel: itemLabel,
              itemSubtitle: itemSubtitle,
              itemIcon: itemIcon,
              selected: [?v],
              multi: false,
              title: sheetTitle ?? label,
              searchHint: searchHint,
              debounce: debounce,
              max: null,
              emptyText: emptyText,
              minChars: minChars,
            ),
          );
          if (picked == null || picked.isEmpty || !context.mounted) return;
          field.didChange(picked.first);
          cb?.call(picked.first);
        },
        child: Text(v == null ? '' : _str(v, itemLabel), maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}

class UiMultiSelectDropdown<T> extends StatelessWidget {
  const UiMultiSelectDropdown({
    super.key,
    this.items = const [],
    this.onSearch,
    required this.values,
    required this.onChanged,
    this.itemLabel,
    this.itemSubtitle,
    this.itemIcon,
    this.label,
    this.hint = 'Select',
    this.searchHint = 'Search',
    this.sheetTitle,
    this.prefixIcon,
    this.helper,
    this.validator,
    this.isRequired = false,
    this.max,
    this.maxVisibleChips = 3,
    this.debounce = const Duration(milliseconds: 350),
    this.minChars = 0,
    this.emptyText = 'No results',
  });

  final List<T> items;
  final UiSearchCallback<T>? onSearch;
  final List<T> values;
  final ValueChanged<List<T>>? onChanged;
  final String Function(T)? itemLabel;
  final String? Function(T)? itemSubtitle;
  final IconData? Function(T)? itemIcon;
  final String? label;
  final String hint;
  final String searchHint;
  final String? sheetTitle;
  final IconData? prefixIcon;
  final String? helper;
  final FormFieldValidator<List<T>>? validator;
  final bool isRequired;
  final int? max;
  final int maxVisibleChips;
  final Duration debounce;
  final int minChars;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    final cb = onChanged;
    final vals = values;
    final shown = maxVisibleChips < 1 ? vals.length : maxVisibleChips;
    return FormField<List<T>>(
      initialValue: vals,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: (_) => isRequired && vals.isEmpty
          ? 'Select at least one ${label?.trim().isNotEmpty == true ? label!.trim().toLowerCase() : 'item'}'
          : validator?.call(vals),
      builder: (field) {
        void set(List<T> next) {
          field.didChange(next);
          cb?.call(next);
        }

        return _Trigger(
          label: label,
          hint: hint,
          helper: helper,
          error: field.errorText,
          prefixIcon: prefixIcon,
          isRequired: isRequired,
          isEmpty: vals.isEmpty,
          enabled: cb != null,
          onClear: cb == null ? null : () => set(const []),
          onTap: () async {
            final picked = await _openPicker<T>(
              context,
              _PickerSheet<T>(
                items: items,
                onSearch: onSearch,
                itemLabel: itemLabel,
                itemSubtitle: itemSubtitle,
                itemIcon: itemIcon,
                selected: vals,
                multi: true,
                title: sheetTitle ?? label,
                searchHint: searchHint,
                debounce: debounce,
                max: max,
                emptyText: emptyText,
                minChars: minChars,
              ),
            );
            if (picked == null || !context.mounted) return;
            set(picked);
          },
          child: vals.isEmpty
              ? const SizedBox.shrink()
              : Wrap(
                  spacing: UiSpace.xs + 2,
                  runSpacing: UiSpace.xs + 2,
                  children: [
                    for (final o in vals.take(shown))
                      UiChip(
                        _str(o, itemLabel),
                        size: UiSize.sm,
                        onDeleted: cb == null ? null : () => set([for (final x in vals) if (x != o) x]),
                      ),
                    if (vals.length > shown) UiChip('+${vals.length - shown}', size: UiSize.sm, variant: UiChipVariant.outline),
                  ],
                ),
        );
      },
    );
  }
}

class UiAutocomplete<T extends Object> extends StatefulWidget {
  const UiAutocomplete({
    super.key,
    this.items = const [],
    this.onSearch,
    this.onSelected,
    this.itemLabel,
    this.itemSubtitle,
    this.itemIcon,
    this.label,
    this.hint = 'Search',
    this.prefixIcon = Icons.search_rounded,
    this.helper,
    this.controller,
    this.focusNode,
    this.debounce = const Duration(milliseconds: 300),
    this.minChars = 1,
    this.maxOptionsHeight = 280,
    this.emptyText = 'No matches',
    this.enabled = true,
  });

  final List<T> items;
  final UiSearchCallback<T>? onSearch;
  final ValueChanged<T>? onSelected;
  final String Function(T)? itemLabel;
  final String? Function(T)? itemSubtitle;
  final IconData? Function(T)? itemIcon;
  final String? label;
  final String hint;
  final IconData? prefixIcon;
  final String? helper;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final Duration debounce;
  final int minChars;
  final double maxOptionsHeight;
  final String emptyText;
  final bool enabled;

  @override
  State<UiAutocomplete<T>> createState() => _UiAutocompleteState<T>();
}

class _UiAutocompleteState<T extends Object> extends State<UiAutocomplete<T>> {
  TextEditingController? _ownCtrl;
  FocusNode? _ownFocus;
  Timer? _timer;
  Completer<Iterable<T>>? _pending;
  bool _loading = false;

  TextEditingController get _ctrl => widget.controller ?? (_ownCtrl ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void dispose() {
    _timer?.cancel();
    final p = _pending;
    if (p != null && !p.isCompleted) p.complete(const []);
    _ownCtrl?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _setLoading(bool v) {
    if (mounted && _loading != v) setState(() => _loading = v);
  }

  Future<Iterable<T>> _options(TextEditingValue tv) {
    final q = tv.text.trim();
    _timer?.cancel();
    final prev = _pending;
    _pending = null;
    if (prev != null && !prev.isCompleted) prev.complete(const []);
    if (q.length < widget.minChars) {
      _setLoading(false);
      return Future.value(const []);
    }
    final search = widget.onSearch;
    if (search == null) {
      final lq = q.toLowerCase();
      return Future.value([for (final i in widget.items) if (_str(i, widget.itemLabel).toLowerCase().contains(lq)) i]);
    }
    final c = Completer<Iterable<T>>();
    _pending = c;
    _timer = Timer(widget.debounce, () async {
      _setLoading(true);
      try {
        final r = await search(q);
        if (!c.isCompleted) c.complete(r);
      } catch (_) {
        if (!c.isCompleted) c.complete(const []);
      } finally {
        if (identical(_pending, c)) _setLoading(false);
      }
    });
    return c.future;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return UiFieldLabel(
      widget.label,
      child: RawAutocomplete<T>(
        textEditingController: _ctrl,
        focusNode: _focus,
        displayStringForOption: (o) => _str(o, widget.itemLabel),
        optionsBuilder: _options,
        onSelected: (o) {
          widget.onSelected?.call(o);
          _focus.unfocus();
        },
        fieldViewBuilder: (context, ctrl, focus, onSubmit) => TextField(
          controller: ctrl,
          focusNode: focus,
          enabled: widget.enabled,
          onSubmitted: (_) => onSubmit(),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: widget.hint,
            helperText: widget.helper,
            prefixIcon: widget.prefixIcon == null ? null : Icon(widget.prefixIcon, size: 20),
            suffixIcon: _loading
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                : ListenableBuilder(
                    listenable: ctrl,
                    builder: (_, _) => ctrl.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(tooltip: 'Clear', onPressed: ctrl.clear, icon: const Icon(Icons.close_rounded, size: 20)),
                  ),
          ),
        ),
        optionsViewBuilder: (context, onSelect, options) {
          final list = options.toList();
          return Align(
            alignment: AlignmentDirectional.topStart,
            child: Padding(
              padding: const EdgeInsets.only(top: UiSpace.xs),
              child: Material(
                elevation: 6,
                color: cs.surfaceContainer,
                borderRadius: context.tokens.md,
                clipBehavior: Clip.antiAlias,
                child: LayoutBuilder(
                  builder: (context, box) => ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: widget.maxOptionsHeight, maxWidth: box.maxWidth),
                    child: list.isEmpty
                        ? ListTile(dense: true, title: Text(widget.emptyText, style: TextStyle(color: cs.onSurfaceVariant)))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
                            shrinkWrap: true,
                            itemCount: list.length,
                            itemBuilder: (context, i) {
                              final o = list[i];
                              final hl = AutocompleteHighlightedOption.of(context) == i;
                              final sub = widget.itemSubtitle?.call(o);
                              final ic = widget.itemIcon?.call(o);
                              return ListTile(
                                dense: true,
                                selected: hl,
                                selectedTileColor: cs.primary.withValues(alpha: 0.08),
                                leading: ic == null ? null : Icon(ic, size: 20),
                                title: Text(_str(o, widget.itemLabel), maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: sub == null ? null : Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis),
                                onTap: () => onSelect(o),
                              );
                            },
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
