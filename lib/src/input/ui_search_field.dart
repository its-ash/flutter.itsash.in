import 'dart:async';

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/input/field_style.dart';

/// Pill-shaped search input with a search icon, a clear button when it has
/// text, optional debounce, and an optional filter button.
///
/// ```dart
/// UiSearchField(onChanged: search, debounce: const Duration(milliseconds: 300))
/// ```
class UiSearchField extends StatefulWidget {
  const UiSearchField({
    super.key,
    this.hint = 'Search',
    this.onChanged,
    this.onSubmitted,
    this.onClear,
    this.controller,
    this.focusNode,
    this.debounce,
    this.onFilter,
    this.filterActive = false,
    this.filterIcon = Icons.tune_rounded,
    this.autofocus = false,
    this.enabled = true,
    this.size = UiSize.md,
  });

  final String hint;

  /// Called with the text. With [debounce], only after typing pauses.
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Called after the clear button empties the field.
  final VoidCallback? onClear;

  /// Optional external controller. Not disposed by this widget.
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Waits this long after the last keystroke before calling [onChanged].
  final Duration? debounce;

  /// Shows a filter button at the end when set.
  final VoidCallback? onFilter;

  /// Highlights the filter button (some filters are applied).
  final bool filterActive;
  final IconData filterIcon;
  final bool autofocus;
  final bool enabled;
  final UiSize size;

  @override
  State<UiSearchField> createState() => _UiSearchFieldState();
}

class _UiSearchFieldState extends State<UiSearchField> {
  TextEditingController? _ownController;
  Timer? _timer;

  TextEditingController get _controller => widget.controller ?? (_ownController ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _hadText = _controller.text.isNotEmpty;
    _controller.addListener(_onText);
  }

  @override
  void didUpdateWidget(UiSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_onText);
      _controller.addListener(_onText);
      _hadText = _controller.text.isNotEmpty;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.removeListener(_onText);
    _ownController?.dispose();
    super.dispose();
  }

  bool _hadText = false;

  void _onText() {
    final has = _controller.text.isNotEmpty;
    if (has != _hadText) setState(() => _hadText = has);
  }

  void _changed(String v) {
    final cb = widget.onChanged;
    if (cb == null) return;
    final d = widget.debounce;
    if (d == null || d == Duration.zero) {
      cb(v);
      return;
    }
    _timer?.cancel();
    _timer = Timer(d, () => cb(_controller.text));
  }

  void _clear() {
    _timer?.cancel();
    _controller.clear();
    widget.onChanged?.call('');
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final w = widget;
    final hasText = _controller.text.isNotEmpty;
    final suffix = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedSwitcher(
          duration: context.motion(UiMotion.fast),
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: ScaleTransition(scale: a, child: child),
          ),
          child: hasText && w.enabled
              ? FieldIconButton(
                  key: const ValueKey('clear'),
                  icon: Icons.close_rounded,
                  tooltip: 'Clear',
                  size: w.size.iconSize,
                  onPressed: _clear,
                )
              : const SizedBox.shrink(key: ValueKey('none')),
        ),
        if (w.onFilter != null) ...[
          Container(width: 1, height: w.size.iconSize, color: c.border),
          Stack(
            clipBehavior: Clip.none,
            children: [
              FieldIconButton(
                icon: w.filterIcon,
                tooltip: 'Filters',
                size: w.size.iconSize,
                color: w.filterActive ? c.accent : null,
                onPressed: w.enabled ? w.onFilter : null,
              ),
              if (w.filterActive)
                PositionedDirectional(
                  top: 9,
                  end: 9,
                  child: Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: c.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.surfaceMuted, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
    return TextField(
      controller: _controller,
      focusNode: w.focusNode,
      autofocus: w.autofocus,
      enabled: w.enabled,
      onChanged: _changed,
      onSubmitted: w.onSubmitted,
      textInputAction: TextInputAction.search,
      textAlignVertical: TextAlignVertical.center,
      style: fieldTextStyle(context, w.size, enabled: w.enabled),
      decoration: fieldDecoration(
        context,
        hint: w.hint,
        prefixIcon: Icons.search_rounded,
        suffix: suffix,
        size: w.size,
        enabled: w.enabled,
        radius: UiRadius.full,
      ),
    );
  }
}
