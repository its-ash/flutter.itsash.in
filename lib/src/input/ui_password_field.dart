import 'package:flutter/material.dart';

import 'package:theme/src/input/ui_field_label.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

enum UiPasswordStrength { none, weak, medium, strong }

class UiPasswordField extends StatefulWidget {
  const UiPasswordField({
    super.key,
    this.label = 'Password',
    this.hint,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.showStrength = false,
    this.minLength,
    this.isRequired = false,
    this.enabled = true,
    this.autofocus = false,
    this.textInputAction = TextInputAction.done,
    this.newPassword = false,
    this.helper,
    this.error,
    this.focusNode,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final bool showStrength;
  final int? minLength;
  final bool isRequired;
  final bool enabled;
  final bool autofocus;
  final TextInputAction textInputAction;
  final bool newPassword;
  final String? helper;
  final String? error;
  final FocusNode? focusNode;

  static UiPasswordStrength strengthOf(String v) {
    if (v.isEmpty) return UiPasswordStrength.none;
    var s = 0;
    if (v.length >= 8) s++;
    if (v.length >= 12) s++;
    if (RegExp('[a-z]').hasMatch(v) && RegExp('[A-Z]').hasMatch(v)) s++;
    if (RegExp(r'\d').hasMatch(v)) s++;
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(v)) s++;
    return s <= 2 ? UiPasswordStrength.weak : (s == 3 ? UiPasswordStrength.medium : UiPasswordStrength.strong);
  }

  @override
  State<UiPasswordField> createState() => _UiPasswordFieldState();
}

class _UiPasswordFieldState extends State<UiPasswordField> {
  TextEditingController? _own;
  var _hidden = true;

  TextEditingController get _ctrl => widget.controller ?? (_own ??= TextEditingController());

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onText);
  }

  @override
  void didUpdateWidget(UiPasswordField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      (old.controller ?? _own)?.removeListener(_onText);
      _ctrl.addListener(_onText);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onText);
    _own?.dispose();
    super.dispose();
  }

  void _onText() {
    if (widget.showStrength && mounted) setState(() {});
  }

  String? _validate(String? raw) {
    final v = raw ?? '';
    if (v.isEmpty) return widget.isRequired ? 'Password is required' : widget.validator?.call(raw);
    final min = widget.minLength;
    if (min != null && min > 0 && v.length < min) return 'Use at least $min characters';
    return widget.validator?.call(raw);
  }

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: _ctrl,
      focusNode: widget.focusNode,
      obscureText: _hidden,
      enableSuggestions: false,
      autocorrect: false,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      onChanged: widget.onChanged,
      onFieldSubmitted: widget.onSubmitted,
      validator: _validate,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      textInputAction: widget.textInputAction,
      keyboardType: TextInputType.visiblePassword,
      autofillHints: widget.enabled ? [widget.newPassword ? AutofillHints.newPassword : AutofillHints.password] : null,
      onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
      decoration: InputDecoration(
        hintText: widget.hint ?? '••••••••',
        helperText: widget.helper,
        errorText: widget.error,
        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
        suffixIcon: IconButton(
          tooltip: _hidden ? 'Show password' : 'Hide password',
          onPressed: widget.enabled ? () => setState(() => _hidden = !_hidden) : null,
          icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined, size: 20),
        ),
      ),
    );
    return UiFieldLabel(
      widget.label,
      isRequired: widget.isRequired,
      child: widget.showStrength
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [field, _StrengthMeter(UiPasswordField.strengthOf(_ctrl.text))],
            )
          : field,
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter(this.strength);

  final UiPasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final (n, status, text) = switch (strength) {
      UiPasswordStrength.none => (0, UiStatus.neutral, ''),
      UiPasswordStrength.weak => (1, UiStatus.danger, 'Weak'),
      UiPasswordStrength.medium => (2, UiStatus.warning, 'Medium'),
      UiPasswordStrength.strong => (3, UiStatus.success, 'Strong'),
    };
    final c = context.tone(status).color;
    final track = context.colors.surfaceContainerHighest;
    return AnimatedSize(
      duration: UiDuration.normal,
      curve: UiCurve.standard,
      child: n == 0
          ? const SizedBox(width: double.infinity)
          : Semantics(
              label: 'Password strength: $text',
              child: Padding(
                padding: const EdgeInsets.only(top: UiSpace.sm),
                child: Row(
                  children: [
                    for (var i = 0; i < 3; i++) ...[
                      Expanded(
                        child: AnimatedContainer(
                          duration: UiDuration.normal,
                          height: 4,
                          decoration: BoxDecoration(color: i < n ? c : track, borderRadius: context.tokens.full),
                        ),
                      ),
                      const SizedBox(width: UiSpace.xs),
                    ],
                    const SizedBox(width: UiSpace.xs),
                    Text(text, style: context.text.labelMedium?.copyWith(color: c, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
    );
  }
}
