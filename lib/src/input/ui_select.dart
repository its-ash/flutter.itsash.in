import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/input/field_style.dart';
import 'package:theme/src/input/ui_field_label.dart';

/// One choice of a [UiSelect] or [UiMultiSelect].
@immutable
class UiOption<T> {
  const UiOption(this.value, this.label, {this.subtitle, this.icon, this.enabled = true});

  final T value;
  final String label;

  /// Second line under the label.
  final String? subtitle;

  /// Leading icon.
  final IconData? icon;
  final bool enabled;
}

/// Field-looking dropdown. Opens a bottom sheet on phones and an anchored
/// menu on wider screens, with a check on the selected option.
///
/// ```dart
/// UiSelect(label: 'Country', value: country, options: countries, onChanged: (v) => setState(() => country = v))
/// ```
class UiSelect<T> extends StatelessWidget {
  const UiSelect({
    super.key,
    required this.options,
    required this.onChanged,
    this.value,
    this.label,
    this.hint = 'Select',
    this.searchable = false,
    this.searchHint = 'Search',
    this.helper,
    this.error,
    this.validator,
    this.prefixIcon,
    this.size = UiSize.md,
    this.isRequired = false,
    this.sheetTitle,
  });

  final List<UiOption<T>> options;

  /// Called with the picked value. Null disables the field.
  final ValueChanged<T>? onChanged;

  /// Currently selected value, or null for none.
  final T? value;
  final String? label;
  final String hint;

  /// Adds a filter field above the options.
  final bool searchable;
  final String searchHint;
  final String? helper;
  final String? error;

  /// Validates [value] inside a [Form].
  final FormFieldValidator<T>? validator;

  /// Icon shown when the selected option has none.
  final IconData? prefixIcon;
  final UiSize size;
  final bool isRequired;

  /// Title of the bottom sheet. Defaults to [label].
  final String? sheetTitle;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    UiOption<T>? selected;
    for (final o in options) {
      if (o.value == value) selected = o;
    }
    return FormField<T>(
      initialValue: value,
      enabled: enabled,
      validator: validator == null ? null : (_) => validator!(value),
      builder: (field) => UiFieldLabel(
        label: label,
        helper: helper,
        error: error ?? field.errorText,
        isRequired: isRequired,
        enabled: enabled,
        child: Builder(
          builder: (anchor) => FieldBox(
            size: size,
            hasError: (error ?? field.errorText) != null,
            prefixIcon: selected?.icon ?? prefixIcon,
            semanticLabel: label,
            onTap: !enabled
                ? null
                : () async {
                    final result = await _showOptionsPicker<T>(
                      anchor,
                      options: options,
                      selected: {?value},
                      searchable: searchable,
                      searchHint: searchHint,
                      title: sheetTitle ?? label,
                    );
                    if (result == null || result.isEmpty) return;
                    field.didChange(result.first);
                    onChanged?.call(result.first);
                  },
            trailing: [_Chevron(enabled: enabled, size: size)],
            child: FieldValueText(value: selected?.label, hint: hint, enabled: enabled),
          ),
        ),
      ),
    );
  }
}

/// Like [UiSelect] but picks several values. The field shows them as small
/// removable chips, and the sheet has a "Done" button.
///
/// ```dart
/// UiMultiSelect(label: 'Tags', values: tags, options: all, onChanged: (v) => setState(() => tags = v))
/// ```
class UiMultiSelect<T> extends StatelessWidget {
  const UiMultiSelect({
    super.key,
    required this.options,
    required this.values,
    required this.onChanged,
    this.label,
    this.hint = 'Select',
    this.searchable = false,
    this.searchHint = 'Search',
    this.helper,
    this.error,
    this.validator,
    this.prefixIcon,
    this.size = UiSize.md,
    this.isRequired = false,
    this.sheetTitle,
    this.doneLabel = 'Done',
    this.maxChips = 3,
  });

  final List<UiOption<T>> options;

  /// Currently selected values.
  final List<T> values;

  /// Called with the new selection, in option order. Null disables the field.
  final ValueChanged<List<T>>? onChanged;
  final String? label;
  final String hint;
  final bool searchable;
  final String searchHint;
  final String? helper;
  final String? error;

  /// Validates [values] inside a [Form].
  final FormFieldValidator<List<T>>? validator;
  final IconData? prefixIcon;
  final UiSize size;
  final bool isRequired;
  final String? sheetTitle;
  final String doneLabel;

  /// Chips shown in the field before collapsing the rest into `+n`.
  final int maxChips;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onChanged != null;
    final selected = [
      for (final o in options)
        if (values.contains(o.value)) o,
    ];
    final shown = selected.take(maxChips).toList();
    final extra = selected.length - shown.length;

    return FormField<List<T>>(
      initialValue: values,
      enabled: enabled,
      validator: validator == null ? null : (_) => validator!(values),
      builder: (field) {
        void emit(List<T> next) {
          field.didChange(next);
          onChanged?.call(next);
        }

        return UiFieldLabel(
          label: label,
          helper: helper,
          error: error ?? field.errorText,
          isRequired: isRequired,
          enabled: enabled,
          child: Builder(
            builder: (anchor) => FieldBox(
              size: size,
              hasError: (error ?? field.errorText) != null,
              prefixIcon: prefixIcon,
              semanticLabel: label,
              padding: EdgeInsetsDirectional.only(
                start: selected.isEmpty ? size.padding - 2 : UiSpace.sm,
                end: UiSpace.xs,
                top: UiSpace.xs + 2,
                bottom: UiSpace.xs + 2,
              ),
              onTap: !enabled
                  ? null
                  : () async {
                      final result = await _showOptionsPicker<T>(
                        anchor,
                        options: options,
                        selected: values.toSet(),
                        multiple: true,
                        searchable: searchable,
                        searchHint: searchHint,
                        title: sheetTitle ?? label,
                        doneLabel: doneLabel,
                      );
                      if (result == null) return;
                      emit([
                        for (final o in options)
                          if (result.contains(o.value)) o.value,
                      ]);
                    },
              trailing: [_Chevron(enabled: enabled, size: size)],
              child: selected.isEmpty
                  ? FieldValueText(hint: hint, enabled: enabled)
                  : Wrap(
                      spacing: UiSpace.xs + 2,
                      runSpacing: UiSpace.xs + 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final o in shown)
                          _MiniChip(
                            label: o.label,
                            onRemove: enabled ? () => emit([...values]..remove(o.value)) : null,
                          ),
                        if (extra > 0)
                          Text(
                            '+$extra',
                            style: context.text.labelMedium?.copyWith(color: enabled ? c.textMuted : c.textDisabled),
                          ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _Chevron extends StatelessWidget {
  const _Chevron({required this.enabled, required this.size});

  final bool enabled;
  final UiSize size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: UiSpace.xs, end: UiSpace.sm),
      child: Icon(Icons.unfold_more_rounded, size: size.iconSize, color: enabled ? c.textSubtle : c.textDisabled),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label, this.onRemove});

  final String label;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onRemove != null;
    final fg = enabled ? c.onAccentSoft : c.textDisabled;
    return Container(
      constraints: const BoxConstraints(minHeight: 26),
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
              child: InkResponse(
                onTap: onRemove,
                radius: 14,
                child: Padding(
                  padding: const EdgeInsets.all(UiSpace.xs),
                  child: Icon(Icons.close_rounded, size: 14, color: fg),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Opens the option list for [anchor]: a bottom sheet on compact screens,
/// otherwise a menu anchored under the field. Resolves to the picked values,
/// or null when dismissed.
Future<Set<T>?> _showOptionsPicker<T>(
  BuildContext anchor, {
  required List<UiOption<T>> options,
  required Set<T> selected,
  bool multiple = false,
  bool searchable = false,
  String searchHint = 'Search',
  String? title,
  String doneLabel = 'Done',
}) {
  if (anchor.isCompact) {
    return showModalBottomSheet<Set<T>>(
      context: anchor,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) => _OptionsPanel<T>(
        options: options,
        selected: selected,
        multiple: multiple,
        searchable: searchable,
        searchHint: searchHint,
        title: title,
        doneLabel: doneLabel,
        sheet: true,
      ),
    );
  }
  final box = anchor.findRenderObject()! as RenderBox;
  final navigator = Navigator.of(anchor);
  final overlayBox = navigator.overlay!.context.findRenderObject()! as RenderBox;
  final rect = box.localToGlobal(Offset.zero, ancestor: overlayBox) & box.size;
  return navigator.push(
    _AnchoredRoute<Set<T>>(
      anchor: rect,
      capturedThemes: InheritedTheme.capture(from: anchor, to: navigator.context),
      barrierLabel: MaterialLocalizations.of(anchor).modalBarrierDismissLabel,
      child: _OptionsPanel<T>(
        options: options,
        selected: selected,
        multiple: multiple,
        searchable: searchable,
        searchHint: searchHint,
        title: null,
        doneLabel: doneLabel,
        sheet: false,
      ),
    ),
  );
}

class _AnchoredRoute<R> extends PopupRoute<R> {
  _AnchoredRoute({required this.anchor, required this.child, required this.capturedThemes, this.barrierLabel});

  final Rect anchor;
  final Widget child;
  final CapturedThemes capturedThemes;

  @override
  final String? barrierLabel;

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  Duration get transitionDuration => UiMotion.fast;

  @override
  Duration get reverseTransitionDuration => UiMotion.fast;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    final mq = MediaQuery.of(context);
    return capturedThemes.wrap(
      CustomSingleChildLayout(
        delegate: _AnchorLayout(anchor: anchor, padding: mq.padding + mq.viewInsets),
        child: child,
      ),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.maybeDisableAnimationsOf(context) ?? false) return child;
    final curved = CurvedAnimation(parent: animation, curve: UiMotion.standard);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween(begin: 0.97, end: 1.0).animate(curved),
        alignment: Alignment.topCenter,
        child: child,
      ),
    );
  }
}

class _AnchorLayout extends SingleChildLayoutDelegate {
  _AnchorLayout({required this.anchor, required this.padding});

  final Rect anchor;
  final EdgeInsets padding;
  static const double _gap = 6;
  static const double _margin = 8;

  double _below(Size size) => size.height - padding.bottom - anchor.bottom - _gap - _margin;
  double _above() => anchor.top - padding.top - _gap - _margin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final size = constraints.biggest;
    final width = math.min(math.max(anchor.width, 280.0), size.width - _margin * 2);
    final room = math.max(_below(size), _above());
    final height = math.max(120.0, math.min(400.0, room));
    return BoxConstraints(minWidth: width, maxWidth: width, maxHeight: height);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    var x = anchor.left;
    x = x.clamp(_margin, math.max(_margin, size.width - childSize.width - _margin));
    final fitsBelow = _below(size) >= childSize.height || _below(size) >= _above();
    final y = fitsBelow ? anchor.bottom + _gap : anchor.top - _gap - childSize.height;
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_AnchorLayout old) => old.anchor != anchor || old.padding != padding;
}

class _OptionsPanel<T> extends StatefulWidget {
  const _OptionsPanel({
    required this.options,
    required this.selected,
    required this.multiple,
    required this.searchable,
    required this.searchHint,
    required this.title,
    required this.doneLabel,
    required this.sheet,
  });

  final List<UiOption<T>> options;
  final Set<T> selected;
  final bool multiple;
  final bool searchable;
  final String searchHint;
  final String? title;
  final String doneLabel;
  final bool sheet;

  @override
  State<_OptionsPanel<T>> createState() => _OptionsPanelState<T>();
}

class _OptionsPanelState<T> extends State<_OptionsPanel<T>> {
  final _search = TextEditingController();
  late final Set<T> _selected = {...widget.selected};
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<UiOption<T>> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return widget.options;
    return widget.options
        .where((o) => o.label.toLowerCase().contains(q) || (o.subtitle?.toLowerCase().contains(q) ?? false))
        .toList();
  }

  void _tap(UiOption<T> o) {
    if (!widget.multiple) {
      Navigator.of(context).pop(<T>{o.value});
      return;
    }
    setState(() => _selected.contains(o.value) ? _selected.remove(o.value) : _selected.add(o.value));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final visible = _visible;
    final mq = MediaQuery.of(context);

    final list = visible.isEmpty
        ? Padding(
            padding: const EdgeInsets.all(UiSpace.xl),
            child: Text(
              'No results',
              textAlign: TextAlign.center,
              style: context.text.bodyMedium?.copyWith(color: c.textSubtle),
            ),
          )
        : ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: widget.sheet ? UiSpace.sm : UiSpace.xs, vertical: UiSpace.xs),
            itemCount: visible.length,
            itemBuilder: (context, i) {
              final o = visible[i];
              return _OptionRow<T>(
                option: o,
                selected: _selected.contains(o.value),
                multiple: widget.multiple,
                onTap: o.enabled ? () => _tap(o) : null,
              );
            },
          );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.sheet && widget.title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(UiSpace.page, 0, UiSpace.page, UiSpace.md),
            child: Text(widget.title!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleMedium),
          ),
        if (widget.searchable)
          Padding(
            padding: widget.sheet
                ? const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.sm)
                : const EdgeInsets.fromLTRB(UiSpace.sm, UiSpace.sm, UiSpace.sm, UiSpace.xs),
            child: TextField(
              controller: _search,
              autofocus: !widget.sheet,
              onChanged: (v) => setState(() => _query = v),
              textAlignVertical: TextAlignVertical.center,
              style: fieldTextStyle(context, UiSize.md),
              decoration: fieldDecoration(
                context,
                hint: widget.searchHint,
                prefixIcon: Icons.search_rounded,
                size: widget.sheet ? UiSize.md : UiSize.sm,
                radius: widget.sheet ? UiRadius.full : UiRadius.sm,
              ),
            ),
          ),
        Flexible(child: list),
        if (widget.multiple)
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: c.border)),
            ),
            padding: EdgeInsets.fromLTRB(
              UiSpace.lg,
              UiSpace.md,
              UiSpace.lg,
              UiSpace.md + (widget.sheet ? mq.padding.bottom : 0),
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: _selected.isEmpty ? null : () => setState(_selected.clear),
                  child: const Text('Clear'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(_selected),
                  child: Text(_selected.isEmpty ? widget.doneLabel : '${widget.doneLabel} (${_selected.length})'),
                ),
              ],
            ),
          ),
      ],
    );

    if (widget.sheet) {
      return Padding(
        padding: EdgeInsets.only(bottom: mq.viewInsets.bottom + (widget.multiple ? 0 : UiSpace.md)),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: mq.size.height * 0.75),
          child: content,
        ),
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
        child: content,
      ),
    );
  }
}

class _OptionRow<T> extends StatelessWidget {
  const _OptionRow({required this.option, required this.selected, required this.multiple, this.onTap});

  final UiOption<T> option;
  final bool selected;
  final bool multiple;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onTap != null;
    final fg = !enabled
        ? c.textDisabled
        : selected && !multiple
        ? c.onAccentSoft
        : c.text;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected && !multiple ? c.accentSoft : Colors.transparent,
        borderRadius: UiRadius.all(UiRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: UiRadius.all(UiRadius.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 44),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.sm),
              child: Row(
                children: [
                  if (multiple) ...[_CheckBox(checked: selected, enabled: enabled), const SizedBox(width: UiSpace.md)],
                  if (option.icon != null) ...[
                    Icon(option.icon, size: 20, color: enabled ? (selected ? fg : c.textMuted) : c.textDisabled),
                    const SizedBox(width: UiSpace.md),
                  ],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodyMedium?.copyWith(color: fg, fontWeight: FontWeight.w500),
                        ),
                        if (option.subtitle != null)
                          Text(
                            option.subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodySmall?.copyWith(color: enabled ? c.textMuted : c.textDisabled),
                          ),
                      ],
                    ),
                  ),
                  if (!multiple && selected) ...[
                    const SizedBox(width: UiSpace.sm),
                    Icon(Icons.check_rounded, size: 18, color: c.accent),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckBox extends StatelessWidget {
  const _CheckBox({required this.checked, required this.enabled});

  final bool checked;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final on = enabled ? c.accent : c.textDisabled;
    return AnimatedContainer(
      duration: context.motion(UiMotion.fast),
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: checked ? on : Colors.transparent,
        borderRadius: UiRadius.all(6),
        border: Border.all(color: checked ? on : (enabled ? c.borderStrong : c.textDisabled), width: 1.5),
      ),
      child: checked ? Icon(Icons.check_rounded, size: 14, color: c.onAccent) : null,
    );
  }
}
