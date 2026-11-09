import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/input/field_style.dart';
import 'package:theme/src/input/ui_field_label.dart';

/// Single-line (or multi-line) text input with its label above the field,
/// helper or error text below, and an optional character counter.
///
/// It is a [FormField], so [validator] works inside a [Form].
///
/// ```dart
/// UiTextField(label: 'Email', hint: 'you@example.com', validator: UiValidators.email())
/// ```
class UiTextField extends FormField<String> {
  UiTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.controller,
    String? initialValue,
    this.onChanged,
    this.onSubmitted,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.obscure = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.readOnly = false,
    super.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.inputFormatters,
    this.size = UiSize.md,
    this.onTap,
    this.autofillHints,
    this.isRequired = false,
    this.labelTrailing,
  }) : assert(initialValue == null || controller == null, 'Pass either initialValue or controller'),
       super(initialValue: controller?.text ?? initialValue ?? '', builder: _build);

  /// Text above the field.
  final String? label;

  /// Placeholder inside the empty field.
  final String? hint;

  /// Text below the field.
  final String? helper;

  /// Error text below the field. Overrides the [validator] message.
  final String? error;

  /// Optional external controller. Not disposed by this widget.
  final TextEditingController? controller;

  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Icon at the start of the field.
  final IconData? prefixIcon;

  /// Widget at the end of the field, e.g. an icon button.
  final Widget? suffix;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;

  /// Hides the text (passwords).
  final bool obscure;

  /// Maximum visible lines. `null` grows without limit.
  final int? maxLines;
  final int? minLines;

  /// Maximum characters. Shows a `n / max` counter below the field.
  final int? maxLength;

  final bool readOnly;
  final bool autofocus;
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final UiSize size;
  final GestureTapCallback? onTap;
  final Iterable<String>? autofillHints;

  /// Adds a `*` after the label.
  final bool isRequired;

  /// Widget at the end of the label row, e.g. a "Forgot?" link.
  final Widget? labelTrailing;

  static Widget _build(FormFieldState<String> field) => (field as _UiTextFieldState)._buildField();

  @override
  FormFieldState<String> createState() => _UiTextFieldState();
}

class _UiTextFieldState extends FormFieldState<String> {
  TextEditingController? _ownController;

  @override
  UiTextField get widget => super.widget as UiTextField;

  TextEditingController get _controller => widget.controller ?? _ownController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) _ownController = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(UiTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller == oldWidget.controller) return;
    (oldWidget.controller ?? _ownController)?.removeListener(_onControllerChanged);
    if (oldWidget.controller != null && widget.controller == null) {
      _ownController = TextEditingController(text: oldWidget.controller!.text);
    }
    if (widget.controller != null) {
      setValue(widget.controller!.text);
      if (oldWidget.controller == null) {
        _ownController?.dispose();
        _ownController = null;
      }
    }
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _ownController?.dispose();
    super.dispose();
  }

  @override
  void didChange(String? value) {
    super.didChange(value);
    if (_controller.text != value) _controller.text = value ?? '';
  }

  @override
  void reset() {
    _controller.text = widget.initialValue ?? '';
    super.reset();
  }

  void _onControllerChanged() {
    if (_controller.text != value) didChange(_controller.text);
  }

  Widget _buildField() {
    final w = widget;
    final err = w.error ?? errorText;
    final hasError = err != null && err.isNotEmpty;
    final multiline = w.maxLines == null || w.maxLines! > 1;
    return UiFieldLabel(
      label: w.label,
      isRequired: w.isRequired,
      trailing: w.labelTrailing,
      helper: w.helper,
      error: err,
      enabled: w.enabled,
      counter: w.maxLength == null ? null : '${value?.characters.length ?? 0} / ${w.maxLength}',
      child: TextField(
        controller: _controller,
        focusNode: w.focusNode,
        decoration: fieldDecoration(
          context,
          hint: w.hint,
          prefixIcon: w.prefixIcon,
          suffix: w.suffix,
          size: w.size,
          hasError: hasError,
          enabled: w.enabled,
          multiline: multiline,
        ),
        style: fieldTextStyle(context, w.size, enabled: w.enabled),
        keyboardType: w.keyboardType ?? (multiline ? TextInputType.multiline : null),
        textInputAction: w.textInputAction,
        textCapitalization: w.textCapitalization,
        textAlignVertical: multiline ? TextAlignVertical.top : TextAlignVertical.center,
        obscureText: w.obscure,
        obscuringCharacter: '•',
        maxLines: w.obscure ? 1 : w.maxLines,
        minLines: w.obscure ? null : w.minLines,
        readOnly: w.readOnly,
        enabled: w.enabled,
        autofocus: w.autofocus,
        inputFormatters: [
          ...?w.inputFormatters,
          if (w.maxLength != null) LengthLimitingTextInputFormatter(w.maxLength),
        ],
        onChanged: w.onChanged,
        onSubmitted: w.onSubmitted,
        onTap: w.onTap,
        autofillHints: w.enabled ? w.autofillHints : null,
      ),
    );
  }
}

/// Multi-line text input with a growing height and an optional counter.
///
/// ```dart
/// UiTextArea(label: 'Bio', maxLength: 200)
/// ```
class UiTextArea extends UiTextField {
  UiTextArea({
    super.key,
    super.label,
    super.hint,
    super.helper,
    super.error,
    super.controller,
    super.initialValue,
    super.onChanged,
    super.validator,
    super.onSaved,
    super.autovalidateMode,
    super.maxLength,
    super.readOnly,
    super.enabled,
    super.autofocus,
    super.focusNode,
    super.inputFormatters,
    super.size,
    super.isRequired,
    super.labelTrailing,
    super.textCapitalization = TextCapitalization.sentences,
    super.minLines = 3,
    super.maxLines = 6,
  }) : super(keyboardType: TextInputType.multiline, textInputAction: TextInputAction.newline);
}
