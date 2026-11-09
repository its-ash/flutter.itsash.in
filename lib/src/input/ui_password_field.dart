import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/input/field_style.dart';
import 'package:theme/src/input/ui_text_field.dart';

/// Rough strength of a password, from length and character classes.
enum UiPasswordStrength {
  weak,
  fair,
  good,
  strong;

  /// Scores [password]. Returns null for an empty string.
  static UiPasswordStrength? of(String password) {
    if (password.isEmpty) return null;
    final classes = [
      RegExp('[a-z]'),
      RegExp('[A-Z]'),
      RegExp(r'\d'),
      RegExp(r'[^A-Za-z0-9]'),
    ].where((r) => r.hasMatch(password)).length;
    final len = password.length;
    if (len < 6) return weak;
    var score = 0;
    if (len >= 8) score++;
    if (len >= 12) score++;
    if (classes >= 2) score++;
    if (classes >= 3) score++;
    if (classes == 4) score++;
    return switch (score) {
      <= 1 => weak,
      2 => fair,
      3 => good,
      _ => strong,
    };
  }

  /// Display label, e.g. `Strong`.
  String get label => switch (this) {
    weak => 'Weak',
    fair => 'Fair',
    good => 'Good',
    strong => 'Strong',
  };

  /// Status used to color the meter.
  UiStatus get status => switch (this) {
    weak => UiStatus.danger,
    fair => UiStatus.warning,
    good => UiStatus.info,
    strong => UiStatus.success,
  };
}

/// Password input with a show/hide toggle and an optional strength meter.
///
/// ```dart
/// UiPasswordField(label: 'Password', showStrength: true, validator: UiValidators.minLength(8))
/// ```
class UiPasswordField extends StatefulWidget {
  const UiPasswordField({
    super.key,
    this.label = 'Password',
    this.hint,
    this.helper,
    this.error,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.autovalidateMode,
    this.showStrength = false,
    this.enabled = true,
    this.autofocus = false,
    this.focusNode,
    this.textInputAction,
    this.size = UiSize.md,
    this.isRequired = false,
    this.labelTrailing,
    this.autofillHints = const [AutofillHints.password],
    this.prefixIcon = Icons.lock_outline_rounded,
  });

  final String? label;
  final String? hint;
  final String? helper;
  final String? error;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;

  /// Shows a four-step strength bar under the field.
  final bool showStrength;
  final bool enabled;
  final bool autofocus;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final UiSize size;
  final bool isRequired;

  /// Widget at the end of the label row, e.g. a "Forgot?" link.
  final Widget? labelTrailing;
  final Iterable<String>? autofillHints;
  final IconData? prefixIcon;

  @override
  State<UiPasswordField> createState() => _UiPasswordFieldState();
}

class _UiPasswordFieldState extends State<UiPasswordField> {
  bool _hidden = true;
  UiPasswordStrength? _strength;

  @override
  void initState() {
    super.initState();
    _strength = UiPasswordStrength.of(widget.controller?.text ?? '');
  }

  void _changed(String v) {
    if (widget.showStrength) {
      final s = UiPasswordStrength.of(v);
      if (s != _strength) setState(() => _strength = s);
    }
    widget.onChanged?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final field = UiTextField(
      label: w.label,
      hint: w.hint,
      helper: w.helper,
      error: w.error,
      controller: w.controller,
      onChanged: _changed,
      onSubmitted: w.onSubmitted,
      validator: w.validator,
      autovalidateMode: w.autovalidateMode,
      obscure: _hidden,
      enabled: w.enabled,
      autofocus: w.autofocus,
      focusNode: w.focusNode,
      textInputAction: w.textInputAction,
      keyboardType: TextInputType.visiblePassword,
      size: w.size,
      isRequired: w.isRequired,
      labelTrailing: w.labelTrailing,
      autofillHints: w.autofillHints,
      prefixIcon: w.prefixIcon,
      suffix: FieldIconButton(
        icon: _hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        tooltip: _hidden ? 'Show password' : 'Hide password',
        onPressed: w.enabled ? () => setState(() => _hidden = !_hidden) : null,
      ),
    );
    if (!w.showStrength) return field;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        field,
        const SizedBox(height: UiSpace.sm),
        _StrengthMeter(strength: _strength),
      ],
    );
  }
}

class _StrengthMeter extends StatelessWidget {
  const _StrengthMeter({required this.strength});

  final UiPasswordStrength? strength;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = strength;
    final filled = s == null ? 0 : s.index + 1;
    final color = s == null ? c.border : c.tone(s.status).color;
    return Semantics(
      label: 'Password strength: ${s?.label ?? 'none'}',
      child: Row(
        children: [
          for (var i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(width: UiSpace.xs),
            Expanded(
              child: AnimatedContainer(
                duration: context.motion(UiMotion.normal),
                curve: UiMotion.standard,
                height: 4,
                decoration: BoxDecoration(
                  color: i < filled ? color : c.border,
                  borderRadius: UiRadius.all(UiRadius.full),
                ),
              ),
            ),
          ],
          const SizedBox(width: UiSpace.md),
          SizedBox(
            width: 48,
            child: Text(
              s?.label ?? '',
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelMedium?.copyWith(color: s == null ? c.textSubtle : color),
            ),
          ),
        ],
      ),
    );
  }
}
