import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/input/ui_field_label.dart';

/// One-time code input drawn as separate boxes. Typing advances to the next
/// box, backspace goes back, and pasting a full code fills every box.
///
/// ```dart
/// UiOtpField(onCompleted: verify)
/// ```
class UiOtpField extends StatefulWidget {
  const UiOtpField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.obscure = false,
    this.autofocus = false,
    this.error,
    this.label,
    this.helper,
    this.controller,
    this.focusNode,
    this.digitsOnly = true,
    this.enabled = true,
  }) : assert(length > 0);

  /// Number of boxes.
  final int length;

  /// Called once every box is filled.
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;

  /// Shows dots instead of the characters.
  final bool obscure;
  final bool autofocus;

  /// Error text below the boxes; also turns their borders red.
  final String? error;
  final String? label;
  final String? helper;

  /// Optional external controller. Not disposed by this widget.
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Accept only 0-9. When false, letters are accepted too (upper-cased).
  final bool digitsOnly;
  final bool enabled;

  @override
  State<UiOtpField> createState() => _UiOtpFieldState();
}

class _UiOtpFieldState extends State<UiOtpField> {
  TextEditingController? _ownController;
  FocusNode? _ownFocus;
  String _lastCompleted = '';

  TextEditingController get _controller => widget.controller ?? (_ownController ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onText);
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(UiOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _ownController)?.removeListener(_onText);
      _controller.addListener(_onText);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      (oldWidget.focusNode ?? _ownFocus)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onText);
    _focus.removeListener(_onFocus);
    _ownController?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _onFocus() => setState(() {});

  void _onText() {
    setState(() {});
    final text = _controller.text;
    if (text.length < widget.length) {
      _lastCompleted = '';
    } else if (text.length == widget.length && text != _lastCompleted) {
      _lastCompleted = text;
      widget.onCompleted?.call(text);
    }
  }

  void _moveCaretToEnd() {
    final len = _controller.text.length;
    _controller.selection = TextSelection.collapsed(offset: len);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final text = _controller.text;
    final focused = _focus.hasFocus;
    final n = widget.length;

    return UiFieldLabel(
      label: widget.label,
      helper: widget.helper,
      error: widget.error,
      enabled: widget.enabled,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const gap = UiSpace.sm;
          final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : 52.0 * n + gap * (n - 1);
          final boxW = ((maxW - gap * (n - 1)) / n).clamp(24.0, 52.0);
          final boxH = (boxW * 1.15).clamp(44.0, 60.0);
          final rowW = boxW * n + gap * (n - 1);
          final style = UiTypography.mono(
            fontSize: (boxW * 0.45).clamp(16.0, 24.0),
            fontWeight: FontWeight.w600,
            color: widget.enabled ? c.text : c.textDisabled,
          );

          Widget box(int i) {
            final filled = i < text.length;
            final active = focused && widget.enabled && i == (text.length < n ? text.length : n - 1);
            final borderColor = hasError
                ? c.danger
                : active
                ? c.accent
                : filled
                ? c.borderStrong
                : c.border;
            return AnimatedContainer(
              duration: context.motion(UiMotion.fast),
              curve: UiMotion.standard,
              width: boxW,
              height: boxH,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: widget.enabled ? (filled ? c.surface : c.surfaceMuted) : c.surfaceMuted.withValues(alpha: 0.6),
                borderRadius: UiRadius.all(UiRadius.md),
                border: Border.all(color: borderColor, width: active || hasError ? 1.5 : 1),
              ),
              child: filled
                  ? widget.obscure
                        ? Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(color: style.color, shape: BoxShape.circle),
                          )
                        : Text(text[i], style: style)
                  : active
                  ? Container(
                      width: 2,
                      height: boxH * 0.4,
                      decoration: BoxDecoration(color: c.accent, borderRadius: UiRadius.all(1)),
                    )
                  : null,
            );
          }

          return Center(
            child: SizedBox(
              width: rowW,
              height: boxH,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: TextSelectionTheme(
                      data: const TextSelectionThemeData(
                        selectionColor: Colors.transparent,
                        cursorColor: Colors.transparent,
                      ),
                      child: TextField(
                        controller: _controller,
                        focusNode: _focus,
                        autofocus: widget.autofocus,
                        enabled: widget.enabled,
                        showCursor: false,
                        autocorrect: false,
                        enableSuggestions: false,
                        keyboardType: widget.digitsOnly ? TextInputType.number : TextInputType.text,
                        textCapitalization: TextCapitalization.characters,
                        autofillHints: widget.enabled ? const [AutofillHints.oneTimeCode] : null,
                        inputFormatters: [
                          if (widget.digitsOnly)
                            FilteringTextInputFormatter.digitsOnly
                          else ...[
                            FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                            const _UpperCaseFormatter(),
                          ],
                          LengthLimitingTextInputFormatter(n),
                        ],
                        onChanged: widget.onChanged,
                        onTap: _moveCaretToEnd,
                        style: const TextStyle(color: Colors.transparent, fontSize: 1),
                        decoration: const InputDecoration(
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ),
                  IgnorePointer(
                    child: Semantics(
                      excludeSemantics: true,
                      child: Row(
                        children: [
                          for (var i = 0; i < n; i++) ...[if (i > 0) const SizedBox(width: gap), box(i)],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
