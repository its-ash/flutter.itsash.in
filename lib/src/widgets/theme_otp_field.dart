import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeOtpField extends StatefulWidget {
  const ThemeOtpField({
    super.key,
    this.length = 6,
    this.onChanged,
    this.onCompleted,
    this.autofocus = true,
  });

  final int length;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  @override
  State<ThemeOtpField> createState() => _ThemeOtpFieldState();
}

class _ThemeOtpFieldState extends State<ThemeOtpField> {
  late final List<TextEditingController> _controllers =
      List.generate(widget.length, (_) => TextEditingController());
  late final List<FocusNode> _focusNodes = List.generate(widget.length, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    final code = _controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
    if (code.length == widget.length) {
      widget.onCompleted?.call(code);
    }
  }

  double _inputRadius(BuildContext context) {
    final border = Theme.of(context).inputDecorationTheme.border;
    if (border is OutlineInputBorder) return border.borderRadius.topLeft.x;
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = _inputRadius(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.length; i++) ...[
          if (i != 0) const SizedBox(width: 10),
          SizedBox(
            width: 44,
            height: 52,
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              autofocus: widget.autofocus && i == 0,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              maxLength: 1,
              style: Theme.of(context).textTheme.titleLarge,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                counterText: '',
                contentPadding: EdgeInsets.zero,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: BorderSide(color: scheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(radius),
                  borderSide: BorderSide(color: scheme.primary, width: 2),
                ),
              ),
              onChanged: (value) => _onChanged(i, value),
            ),
          ),
        ],
      ],
    );
  }
}
