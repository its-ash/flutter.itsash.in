import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/input/field_style.dart';
import 'package:theme/src/input/ui_field_label.dart';

/// Free-form tag entry. Type and press enter or comma to add a tag; tags
/// show as removable pills. Backspace in an empty input removes the last tag.
///
/// ```dart
/// UiTagInput(label: 'Skills', tags: skills, onChanged: (t) => setState(() => skills = t))
/// ```
class UiTagInput extends StatefulWidget {
  const UiTagInput({
    super.key,
    required this.tags,
    required this.onChanged,
    this.label,
    this.hint = 'Add a tag',
    this.helper,
    this.error,
    this.validator,
    this.suggestions = const [],
    this.maxTags,
    this.caseSensitive = false,
    this.size = UiSize.md,
    this.isRequired = false,
  });

  /// Current tags.
  final List<String> tags;

  /// Called with the new list. Null disables the input.
  final ValueChanged<List<String>>? onChanged;
  final String? label;
  final String hint;
  final String? helper;
  final String? error;

  /// Validates [tags] inside a [Form].
  final FormFieldValidator<List<String>>? validator;

  /// Quick-add pills shown under the field while it is focused.
  final List<String> suggestions;

  /// Maximum number of tags. Shows a `n / max` counter.
  final int? maxTags;

  /// When false, `Flutter` and `flutter` count as the same tag.
  final bool caseSensitive;
  final UiSize size;
  final bool isRequired;

  @override
  State<UiTagInput> createState() => _UiTagInputState();
}

class _UiTagInputState extends State<UiTagInput> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  final _fieldKey = GlobalKey<FormFieldState<List<String>>>();

  bool get _enabled => widget.onChanged != null;
  bool get _full => widget.maxTags != null && widget.tags.length >= widget.maxTags!;

  @override
  void initState() {
    super.initState();
    _focus.addListener(_rebuild);
    _controller.addListener(_rebuild);
  }

  @override
  void dispose() {
    _focus.removeListener(_rebuild);
    _controller.removeListener(_rebuild);
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  String _key(String s) => widget.caseSensitive ? s : s.toLowerCase();

  bool _has(List<String> list, String tag) => list.any((t) => _key(t) == _key(tag));

  void _emit(List<String> next) {
    _fieldKey.currentState?.didChange(next);
    widget.onChanged?.call(next);
  }

  /// Adds every non-empty part of [parts]; returns whether anything was added.
  bool _addAll(Iterable<String> parts) {
    final next = [...widget.tags];
    for (final raw in parts) {
      final t = raw.trim();
      if (t.isEmpty || _has(next, t)) continue;
      if (widget.maxTags != null && next.length >= widget.maxTags!) break;
      next.add(t);
    }
    if (next.length == widget.tags.length) return false;
    _emit(next);
    return true;
  }

  void _remove(String tag) => _emit([...widget.tags]..remove(tag));

  void _onChanged(String v) {
    if (!v.contains(',')) return;
    final parts = v.split(',');
    final rest = parts.removeLast();
    _addAll(parts);
    _controller.value = TextEditingValue(
      text: rest,
      selection: TextSelection.collapsed(offset: rest.length),
    );
  }

  void _submit(String v) {
    _addAll([v]);
    _controller.clear();
    _focus.requestFocus();
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (e is KeyUpEvent || !_enabled) return KeyEventResult.ignored;
    if (e.logicalKey == LogicalKeyboardKey.backspace && _controller.text.isEmpty && widget.tags.isNotEmpty) {
      _remove(widget.tags.last);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final w = widget;
    final size = w.size;
    final enabled = _enabled;
    final focused = _focus.hasFocus;

    final q = _controller.text.trim().toLowerCase();
    final suggestions = !enabled || !focused || _full
        ? const <String>[]
        : w.suggestions.where((s) => !_has(w.tags, s) && (q.isEmpty || s.toLowerCase().contains(q))).take(8).toList();

    return FormField<List<String>>(
      key: _fieldKey,
      initialValue: w.tags,
      enabled: enabled,
      validator: w.validator == null ? null : (_) => w.validator!(widget.tags),
      builder: (field) {
        final err = w.error ?? field.errorText;
        final hasError = err != null;
        final input = Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: _onKey,
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            enabled: enabled,
            onChanged: _onChanged,
            onSubmitted: _submit,
            onEditingComplete: () {},
            textInputAction: TextInputAction.done,
            style: fieldTextStyle(context, size, enabled: enabled),
            decoration: InputDecoration(
              hintText: w.hint,
              hintStyle: TextStyle(color: c.textSubtle, fontSize: size.fontSize),
              filled: false,
              isDense: true,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: UiSpace.sm),
            ),
          ),
        );

        final box = GestureDetector(
          onTap: enabled && !_full ? _focus.requestFocus : null,
          child: AnimatedContainer(
            duration: context.motion(UiMotion.fast),
            curve: UiMotion.standard,
            constraints: BoxConstraints(minHeight: size.height),
            padding: EdgeInsets.symmetric(
              horizontal: w.tags.isEmpty ? size.padding - 2 : UiSpace.sm,
              vertical: w.tags.isEmpty ? 0 : UiSpace.sm,
            ),
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              color: enabled ? c.surfaceMuted : c.surfaceMuted.withValues(alpha: 0.6),
              borderRadius: UiRadius.all(UiRadius.md),
              border: Border.all(
                color: hasError
                    ? c.danger
                    : focused
                    ? c.accent
                    : Colors.transparent,
                width: focused || hasError ? 1.5 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (w.tags.isNotEmpty)
                  Wrap(
                    spacing: UiSpace.xs + 2,
                    runSpacing: UiSpace.xs + 2,
                    children: [for (final t in w.tags) _TagPill(label: t, onRemove: enabled ? () => _remove(t) : null)],
                  ),
                if (!_full)
                  Padding(
                    padding: EdgeInsetsDirectional.only(start: w.tags.isEmpty ? 0 : UiSpace.xs),
                    child: input,
                  ),
              ],
            ),
          ),
        );

        return UiFieldLabel(
          label: w.label,
          helper: w.helper,
          error: err,
          isRequired: w.isRequired,
          enabled: enabled,
          counter: w.maxTags == null ? null : '${w.tags.length} / ${w.maxTags}',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              box,
              AnimatedSize(
                duration: context.motion(UiMotion.fast),
                curve: UiMotion.standard,
                alignment: Alignment.topCenter,
                child: suggestions.isEmpty
                    ? const SizedBox(width: double.infinity)
                    : TextFieldTapRegion(
                        child: Padding(
                          padding: const EdgeInsets.only(top: UiSpace.sm),
                          child: Wrap(
                            spacing: UiSpace.xs + 2,
                            runSpacing: UiSpace.xs + 2,
                            children: [
                              for (final s in suggestions)
                                _SuggestionPill(
                                  label: s,
                                  onTap: () {
                                    _addAll([s]);
                                    _controller.clear();
                                    _focus.requestFocus();
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _TagPill extends StatelessWidget {
  const _TagPill({required this.label, this.onRemove});

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onRemove != null;
    final fg = enabled ? c.onAccentSoft : c.textDisabled;
    return Container(
      constraints: const BoxConstraints(minHeight: 28),
      padding: EdgeInsetsDirectional.only(start: UiSpace.sm + 2, end: enabled ? UiSpace.xxs : UiSpace.sm + 2),
      decoration: BoxDecoration(color: enabled ? c.accentSoft : c.surface, borderRadius: UiRadius.all(UiRadius.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium?.copyWith(color: fg),
            ),
          ),
          if (enabled)
            Semantics(
              button: true,
              label: 'Remove $label',
              excludeSemantics: true,
              child: InkResponse(
                onTap: onRemove,
                radius: 14,
                child: Padding(
                  padding: const EdgeInsets.all(UiSpace.xs + 1),
                  child: Icon(Icons.close_rounded, size: 14, color: fg),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  const _SuggestionPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: UiRadius.all(UiRadius.full),
        side: BorderSide(color: c.border),
      ),
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.xs + 2),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_rounded, size: 14, color: c.textMuted),
              const SizedBox(width: UiSpace.xs),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelMedium?.copyWith(color: c.textMuted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
