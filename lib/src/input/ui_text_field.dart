import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/input/ui_field_label.dart';

enum _Kind { text, email, phone, number, multiline, name }

final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

class UiTextField extends StatelessWidget {
  const UiTextField(
    this.label, {
    super.key,
    this.hint,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.onTap,
    this.helper,
    this.error,
    this.inputFormatters,
    this.maxLength,
    this.obscureText = false,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.focusNode,
    this.isRequired = false,
  })  : _kind = _Kind.text,
        decimal = false;

  const UiTextField.email({
    super.key,
    this.label = 'Email',
    this.hint = 'name@example.com',
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon = Icons.mail_outline_rounded,
    this.suffix,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.autofocus = false,
    this.helper,
    this.error,
    this.focusNode,
    this.isRequired = false,
  })  : _kind = _Kind.email,
        keyboardType = TextInputType.emailAddress,
        maxLines = 1,
        minLines = null,
        readOnly = false,
        onTap = null,
        inputFormatters = null,
        maxLength = null,
        obscureText = false,
        autofillHints = const [AutofillHints.email],
        textCapitalization = TextCapitalization.none,
        decimal = false;

  const UiTextField.phone({
    super.key,
    this.label = 'Phone',
    this.hint,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon = Icons.phone_outlined,
    this.suffix,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.autofocus = false,
    this.helper,
    this.error,
    this.focusNode,
    this.isRequired = false,
    this.maxLength,
  })  : _kind = _Kind.phone,
        keyboardType = TextInputType.phone,
        maxLines = 1,
        minLines = null,
        readOnly = false,
        onTap = null,
        inputFormatters = null,
        obscureText = false,
        autofillHints = const [AutofillHints.telephoneNumber],
        textCapitalization = TextCapitalization.none,
        decimal = false;

  const UiTextField.number({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon,
    this.suffix,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.autofocus = false,
    this.helper,
    this.error,
    this.focusNode,
    this.isRequired = false,
    this.maxLength,
    this.decimal = false,
  })  : _kind = _Kind.number,
        keyboardType = null,
        maxLines = 1,
        minLines = null,
        readOnly = false,
        onTap = null,
        inputFormatters = null,
        obscureText = false,
        autofillHints = null,
        textCapitalization = TextCapitalization.none;

  const UiTextField.multiline(
    this.label, {
    super.key,
    this.hint,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.autofocus = false,
    this.helper,
    this.error,
    this.focusNode,
    this.isRequired = false,
    this.maxLength,
    this.maxLines = 6,
    this.minLines = 3,
  })  : _kind = _Kind.multiline,
        onSubmitted = null,
        prefixIcon = null,
        suffix = null,
        keyboardType = TextInputType.multiline,
        textInputAction = TextInputAction.newline,
        readOnly = false,
        onTap = null,
        inputFormatters = null,
        obscureText = false,
        autofillHints = null,
        textCapitalization = TextCapitalization.sentences,
        decimal = false;

  const UiTextField.name({
    super.key,
    this.label = 'Full name',
    this.hint,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.prefixIcon = Icons.person_outline_rounded,
    this.suffix,
    this.textInputAction = TextInputAction.next,
    this.enabled = true,
    this.autofocus = false,
    this.helper,
    this.error,
    this.focusNode,
    this.isRequired = false,
    this.maxLength,
  })  : _kind = _Kind.name,
        keyboardType = TextInputType.name,
        maxLines = 1,
        minLines = null,
        readOnly = false,
        onTap = null,
        inputFormatters = null,
        obscureText = false,
        autofillHints = const [AutofillHints.name],
        textCapitalization = TextCapitalization.words,
        decimal = false;

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final VoidCallback? onTap;
  final String? helper;
  final String? error;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final bool obscureText;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;
  final FocusNode? focusNode;
  final bool isRequired;
  final bool decimal;
  final _Kind _kind;

  String? _validate(String? raw) {
    final v = raw?.trim() ?? '';
    if (v.isEmpty) return isRequired ? '${label?.trim().isNotEmpty == true ? label!.trim() : 'This field'} is required' : validator?.call(raw);
    final err = switch (_kind) {
      _Kind.email when !_emailRe.hasMatch(v) => 'Enter a valid email',
      _Kind.phone when !_validPhone(v) => 'Enter a valid phone number',
      _Kind.number when num.tryParse(v) == null => 'Enter a valid number',
      _Kind.name when v.length < 2 => 'Enter a valid name',
      _ => null,
    };
    return err ?? validator?.call(raw);
  }

  static bool _validPhone(String v) {
    final d = v.replaceAll(RegExp(r'\D'), '').length;
    return d >= 7 && d <= 15;
  }

  @override
  Widget build(BuildContext context) {
    final fmt = [
      ...?inputFormatters,
      ...switch (_kind) {
        _Kind.phone => [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s()]'))],
        _Kind.number => [FilteringTextInputFormatter.allow(decimal ? RegExp(r'^-?\d*\.?\d*') : RegExp(r'^-?\d*'))],
        _Kind.email => [FilteringTextInputFormatter.deny(RegExp(r'\s'))],
        _ => const <TextInputFormatter>[],
      },
    ];
    final lines = obscureText ? 1 : (maxLines == null ? null : (maxLines! < 1 ? 1 : maxLines));
    final minL = minLines == null || minLines! < 1 ? null : (lines != null && minLines! > lines ? lines : minLines);
    return UiFieldLabel(
      label,
      isRequired: isRequired,
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        focusNode: focusNode,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        validator: _validate,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        keyboardType: _kind == _Kind.number ? TextInputType.numberWithOptions(decimal: decimal, signed: true) : keyboardType,
        textInputAction: textInputAction,
        maxLines: lines,
        minLines: minL,
        enabled: enabled,
        readOnly: readOnly,
        autofocus: autofocus,
        onTap: onTap,
        inputFormatters: fmt.isEmpty ? null : fmt,
        maxLength: maxLength != null && maxLength! > 0 ? maxLength : null,
        obscureText: obscureText,
        autofillHints: enabled && !readOnly ? autofillHints : null,
        textCapitalization: textCapitalization,
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        decoration: InputDecoration(
          hintText: hint,
          helperText: helper,
          errorText: error,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
          suffixIcon: suffix,
          alignLabelWithHint: true,
        ),
      ),
    );
  }
}
