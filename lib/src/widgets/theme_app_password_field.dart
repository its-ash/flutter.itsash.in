import 'package:flutter/material.dart';

class ThemeAppPasswordField extends StatefulWidget {
  const ThemeAppPasswordField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText = 'Password',
    this.errorText,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.showStrengthIndicator = false,
  });

  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool showStrengthIndicator;

  @override
  State<ThemeAppPasswordField> createState() => _ThemeAppPasswordFieldState();
}

class _ThemeAppPasswordFieldState extends State<ThemeAppPasswordField> {
  bool _obscured = true;
  String _value = '';

  PasswordStrength get _strength {
    final v = _value;
    if (v.isEmpty) return PasswordStrength.none;
    var score = 0;
    if (v.length >= 8) score++;
    if (v.contains(RegExp(r'[A-Z]'))) score++;
    if (v.contains(RegExp(r'[0-9]'))) score++;
    if (v.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) score++;
    return PasswordStrength.values[score];
  }

  double _buttonRadius(BuildContext context) {
    final shape = Theme.of(context).filledButtonTheme.style?.shape?.resolve({});
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 2;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: widget.controller,
          obscureText: _obscured,
          enabled: widget.enabled,
          onChanged: (v) {
            setState(() => _value = v);
            widget.onChanged?.call(v);
          },
          onSubmitted: widget.onSubmitted,
          decoration: InputDecoration(
            hintText: widget.hintText,
            labelText: widget.labelText,
            errorText: widget.errorText,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscured ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              tooltip: _obscured ? 'Show password' : 'Hide password',
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
          ),
        ),
        if (widget.showStrengthIndicator && _value.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [
            for (var i = 0; i < 4; i++)
              Expanded(child: Container(
                height: 3,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  color: i < _strength.index ? _strengthColor(scheme) : scheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(_buttonRadius(context).clamp(0, 2)),
                ),
              )),
            const SizedBox(width: 8),
            Text(_strengthLabel, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: _strengthColor(scheme))),
          ]),
        ],
      ],
    );
  }

  String get _strengthLabel => switch (_strength) {
    PasswordStrength.none => '',
    PasswordStrength.weak => 'Weak',
    PasswordStrength.fair => 'Fair',
    PasswordStrength.good => 'Good',
    PasswordStrength.strong => 'Strong',
  };

  Color _strengthColor(ColorScheme scheme) => switch (_strength) {
    PasswordStrength.none => scheme.outline,
    PasswordStrength.weak => Colors.red,
    PasswordStrength.fair => Colors.orange,
    PasswordStrength.good => Colors.blue,
    PasswordStrength.strong => Colors.green,
  };
}

enum PasswordStrength { none, weak, fair, good, strong }