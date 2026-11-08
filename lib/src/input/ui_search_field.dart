import 'dart:async';

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiSearchField extends StatefulWidget {
  const UiSearchField({
    super.key,
    this.hint = 'Search',
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.debounce = const Duration(milliseconds: 300),
    this.onFilterTap,
    this.filterCount = 0,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.focusNode,
  });

  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;
  final Duration debounce;
  final VoidCallback? onFilterTap;
  final int filterCount;
  final bool autofocus;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final FocusNode? focusNode;

  @override
  State<UiSearchField> createState() => _UiSearchFieldState();
}

class _UiSearchFieldState extends State<UiSearchField> {
  TextEditingController? _own;
  Timer? _timer;
  var _hasText = false;

  TextEditingController get _ctrl => widget.controller ?? (_own ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_sync);
    _hasText = _ctrl.text.isNotEmpty;
  }

  @override
  void didUpdateWidget(UiSearchField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      (old.controller ?? _own)?.removeListener(_sync);
      _ctrl.addListener(_sync);
      _sync();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.removeListener(_sync);
    _own?.dispose();
    super.dispose();
  }

  void _sync() {
    final has = _ctrl.text.isNotEmpty;
    if (has != _hasText && mounted) setState(() => _hasText = has);
  }

  void _changed(String v) {
    _timer?.cancel();
    final cb = widget.onChanged;
    if (cb == null) return;
    if (widget.debounce <= Duration.zero) return cb(v);
    _timer = Timer(widget.debounce, () {
      if (mounted) cb(v);
    });
  }

  void _clear() {
    _timer?.cancel();
    _ctrl.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final r = context.tokens.full;
    OutlineInputBorder b([Color c = Colors.transparent, double w = 1]) =>
        OutlineInputBorder(borderRadius: r, borderSide: BorderSide(color: c, width: w));
    final field = TextField(
      controller: _ctrl,
      focusNode: widget.focusNode,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      onChanged: _changed,
      onSubmitted: (v) {
        _timer?.cancel();
        widget.onSubmitted?.call(v);
      },
      textInputAction: TextInputAction.search,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        hintText: widget.hint,
        fillColor: cs.surfaceContainerHigh,
        constraints: BoxConstraints(minHeight: context.tokens.controlHeight),
        contentPadding: const EdgeInsets.symmetric(horizontal: UiSpace.xl, vertical: UiSpace.md),
        prefixIcon: const Padding(
          padding: EdgeInsetsDirectional.only(start: UiSpace.lg, end: UiSpace.sm),
          child: Icon(Icons.search_rounded, size: 22),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        suffixIcon: _hasText && widget.enabled && !widget.readOnly
            ? IconButton(
                tooltip: 'Clear',
                onPressed: _clear,
                icon: const Icon(Icons.close_rounded, size: 20),
              )
            : null,
        border: b(),
        enabledBorder: b(),
        disabledBorder: b(),
        focusedBorder: b(cs.primary, 1.6),
      ),
    );
    final onFilter = widget.onFilterTap;
    if (onFilter == null) return field;
    return Row(
      children: [
        Expanded(child: field),
        const SizedBox(width: UiSpace.sm),
        Badge(
          isLabelVisible: widget.filterCount > 0,
          label: Text('${widget.filterCount}'),
          offset: const Offset(-2, 2),
          child: IconButton.filled(
            tooltip: 'Filters',
            onPressed: widget.enabled ? onFilter : null,
            icon: const Icon(Icons.tune_rounded, size: 22),
            style: IconButton.styleFrom(
              fixedSize: Size.square(context.tokens.controlHeight),
              shape: RoundedRectangleBorder(borderRadius: r),
            ),
          ),
        ),
      ],
    );
  }
}
