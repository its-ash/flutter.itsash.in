import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/input/ui_field_label.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiTagInput extends StatefulWidget {
  const UiTagInput({
    super.key,
    this.tags = const [],
    this.onChanged,
    this.label,
    this.hint = 'Add tag',
    this.maxTags,
    this.maxLength = 32,
    this.caseSensitive = false,
    this.enabled = true,
  });

  final List<String> tags;
  final ValueChanged<List<String>>? onChanged;
  final String? label;
  final String hint;
  final int? maxTags;
  final int maxLength;
  final bool caseSensitive;
  final bool enabled;

  @override
  State<UiTagInput> createState() => _UiTagInputState();
}

class _UiTagInputState extends State<UiTagInput> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  late List<String> _tags = _clean(widget.tags);

  bool get _full => widget.maxTags != null && _tags.length >= widget.maxTags!;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    _focus.onKeyEvent = _onKey;
  }

  @override
  void didUpdateWidget(UiTagInput old) {
    super.didUpdateWidget(old);
    if (!listEquals(old.tags, widget.tags)) _tags = _clean(widget.tags);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  String _key(String s) => widget.caseSensitive ? s : s.toLowerCase();

  List<String> _clean(List<String> src) {
    final seen = <String>{};
    final out = <String>[];
    for (final t in src) {
      final v = t.trim();
      if (v.isEmpty || !seen.add(_key(v))) continue;
      if (widget.maxTags != null && out.length >= widget.maxTags!) break;
      out.add(v);
    }
    return out;
  }

  void _commit(List<String> next) {
    setState(() => _tags = next);
    widget.onChanged?.call(List.unmodifiable(next));
  }

  void _add(Iterable<String> raw) {
    final next = _clean([..._tags, ...raw.map((s) => widget.maxLength > 0 && s.trim().length > widget.maxLength ? s.trim().substring(0, widget.maxLength) : s)]);
    if (!listEquals(next, _tags)) _commit(next);
  }

  void _remove(int i) {
    if (i < 0 || i >= _tags.length) return;
    _commit([..._tags]..removeAt(i));
  }

  void _onChanged(String v) {
    if (!v.contains(',')) return;
    final parts = v.split(',');
    _add(parts.take(parts.length - 1));
    final rest = parts.last;
    _ctrl.value = TextEditingValue(text: rest, selection: TextSelection.collapsed(offset: rest.length));
  }

  void _submit(String v) {
    _add([v]);
    _ctrl.clear();
    if (!_full) _focus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent || e.logicalKey != LogicalKeyboardKey.backspace) return KeyEventResult.ignored;
    if (_ctrl.text.isNotEmpty || _tags.isEmpty) return KeyEventResult.ignored;
    _remove(_tags.length - 1);
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final enabled = widget.enabled;
    final focused = _focus.hasFocus;
    final r = context.tokens.md;
    return UiFieldLabel(
      widget.label,
      trailing: widget.maxTags == null
          ? null
          : Text(
              '${_tags.length}/${widget.maxTags}',
              style: context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
      child: GestureDetector(
        onTap: enabled && !_full ? _focus.requestFocus : null,
        child: AnimatedContainer(
          duration: UiDuration.fast,
          width: double.infinity,
          alignment: AlignmentDirectional.centerStart,
          constraints: BoxConstraints(minHeight: context.tokens.controlHeight),
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.sm),
          decoration: BoxDecoration(
            color: enabled
                ? cs.surfaceContainerHighest.withValues(alpha: context.isDark ? 0.6 : 0.7)
                : cs.onSurface.withValues(alpha: 0.04),
            borderRadius: r,
            border: Border.all(color: focused ? cs.primary : Colors.transparent, width: 1.6),
          ),
          child: Wrap(
            spacing: UiSpace.xs + 2,
            runSpacing: UiSpace.xs + 2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final (i, t) in _tags.indexed)
                InputChip(
                  label: Text(t),
                  onDeleted: enabled ? () => _remove(i) : null,
                  deleteIcon: const Icon(Icons.close_rounded, size: 16),
                  deleteButtonTooltipMessage: 'Remove $t',
                  backgroundColor: cs.surface,
                  labelStyle: context.text.labelLarge?.copyWith(color: cs.onSurface),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
                ),
              if (!_full)
                ConstrainedBox(
                  constraints: const BoxConstraints(minWidth: 96, maxWidth: 240),
                  child: IntrinsicWidth(
                    child: TextField(
                      controller: _ctrl,
                      focusNode: _focus,
                      enabled: enabled,
                      onChanged: _onChanged,
                      onSubmitted: _submit,
                      textInputAction: TextInputAction.done,
                      onEditingComplete: () {},
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        isDense: true,
                        filled: false,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: UiSpace.xs, vertical: UiSpace.sm),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
