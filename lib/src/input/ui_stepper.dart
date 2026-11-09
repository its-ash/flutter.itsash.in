import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/input/ui_field_label.dart';

/// Compact "− value +" control for numbers. Hold a button to repeat.
/// Works with `int` or `double` values. A null [onChanged] disables it.
///
/// ```dart
/// UiStepper(value: qty, min: 1, max: 10, onChanged: (v) => setState(() => qty = v))
/// ```
class UiStepper<T extends num> extends StatefulWidget {
  const UiStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.step,
    this.decimals,
    this.editable = false,
    this.expand = false,
    this.format,
    this.size = UiSize.md,
    this.semanticLabel,
  });

  final T value;

  /// Called with the new value. Null disables the control.
  final ValueChanged<T>? onChanged;
  final T? min;
  final T? max;

  /// Amount added or removed per tap. Defaults to 1.
  final T? step;

  /// Digits after the decimal point for `double` values. Defaults to the
  /// digits of [step].
  final int? decimals;

  /// Lets the user type a value in the middle.
  final bool editable;

  /// Fills the available width instead of hugging the value.
  final bool expand;

  /// Custom display text for the value (ignored while editing).
  final String Function(T value)? format;
  final UiSize size;
  final String? semanticLabel;

  @override
  State<UiStepper<T>> createState() => _UiStepperState<T>();
}

class _UiStepperState<T extends num> extends State<UiStepper<T>> {
  late T _value = widget.value;
  Timer? _repeat;
  int _ticks = 0;
  TextEditingController? _text;
  FocusNode? _focus;

  bool get _isInt => widget.value is int && (widget.step == null || widget.step is int);
  num get _step => widget.step ?? 1;
  bool get _enabled => widget.onChanged != null;
  bool get _canDec => _enabled && (widget.min == null || _value > widget.min!);
  bool get _canInc => _enabled && (widget.max == null || _value < widget.max!);

  int get _decimals {
    if (widget.decimals != null) return widget.decimals!;
    if (_isInt) return 0;
    final s = _step.toString();
    final i = s.indexOf('.');
    return i < 0 ? 0 : (s.length - i - 1).clamp(0, 6);
  }

  String _display(T v) {
    if (widget.format != null) return widget.format!(v);
    return _isInt ? v.round().toString() : v.toStringAsFixed(_decimals);
  }

  T _normalize(num v) {
    var n = v;
    if (widget.min != null && n < widget.min!) n = widget.min!;
    if (widget.max != null && n > widget.max!) n = widget.max!;
    if (_isInt) return n.round() as T;
    return double.parse(n.toStringAsFixed(_decimals)) as T;
  }

  @override
  void initState() {
    super.initState();
    if (widget.editable) _initEditing();
  }

  void _initEditing() {
    _text = TextEditingController(text: _display(_value));
    _focus = FocusNode()..addListener(_onFocus);
  }

  @override
  void didUpdateWidget(UiStepper<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.editable && _text == null) _initEditing();
    if (widget.value != _value && _repeat == null) {
      _value = widget.value;
      if (!(_focus?.hasFocus ?? false)) _text?.text = _display(_value);
    }
  }

  @override
  void dispose() {
    _repeat?.cancel();
    _text?.dispose();
    _focus?.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (!_focus!.hasFocus) _commitText();
  }

  void _commitText() {
    final parsed = num.tryParse(_text!.text.trim().replaceAll(',', '.'));
    if (parsed == null) {
      _text!.text = _display(_value);
      return;
    }
    _set(parsed);
    _text!.text = _display(_value);
  }

  bool _set(num v) {
    final next = _normalize(v);
    if (next == _value) return false;
    setState(() => _value = next);
    if (!(_focus?.hasFocus ?? false)) _text?.text = _display(next);
    widget.onChanged?.call(next);
    return true;
  }

  void _bump(int dir) {
    if (_focus?.hasFocus ?? false) _focus!.unfocus();
    if (_set(_value + _step * dir)) HapticFeedback.selectionClick();
  }

  void _startRepeat(int dir) {
    _stopRepeat();
    _ticks = 0;
    void tick() {
      _bump(dir);
      _ticks++;
      if ((dir < 0 && !_canDec) || (dir > 0 && !_canInc)) {
        _stopRepeat();
        return;
      }
      _repeat = Timer(Duration(milliseconds: _ticks < 8 ? 120 : 50), tick);
    }

    tick();
  }

  void _stopRepeat() {
    _repeat?.cancel();
    _repeat = null;
  }

  Widget _button(IconData icon, String tooltip, int dir, bool can) {
    final c = context.colors;
    final s = widget.size;
    // No tooltip: its long-press gesture would fight the repeat gesture.
    return GestureDetector(
      onLongPressStart: can ? (_) => _startRepeat(dir) : null,
      onLongPressEnd: (_) => _stopRepeat(),
      onLongPressCancel: _stopRepeat,
      child: IconButton(
        onPressed: can ? () => _bump(dir) : null,
        icon: Icon(icon, size: s.iconSize, semanticLabel: tooltip),
        color: c.text,
        disabledColor: c.textDisabled,
        style: IconButton.styleFrom(
          fixedSize: Size(s.height, s.height - 2),
          minimumSize: Size(s.height, s.height - 2),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape: RoundedRectangleBorder(borderRadius: UiRadius.all(UiRadius.md - 1)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final s = widget.size;
    final style = UiTypography.mono(
      fontSize: s.fontSize + 1,
      fontWeight: FontWeight.w600,
      color: _enabled ? c.text : c.textDisabled,
    );
    final signed = widget.min == null || widget.min! < 0;

    Widget center;
    if (widget.editable && _text != null) {
      center = TextField(
        controller: _text,
        focusNode: _focus,
        enabled: _enabled,
        textAlign: TextAlign.center,
        style: style,
        keyboardType: TextInputType.numberWithOptions(decimal: !_isInt, signed: signed),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(_isInt ? r'[-\d]' : r'[-\d.,]'))],
        onSubmitted: (_) => _commitText(),
        decoration: const InputDecoration(
          filled: false,
          isCollapsed: true,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: UiSpace.sm),
        ),
      );
    } else {
      center = AnimatedSwitcher(
        duration: context.motion(UiMotion.fast),
        transitionBuilder: (child, a) => FadeTransition(opacity: a, child: child),
        child: Text(
          _display(_value),
          key: ValueKey(_value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: style,
        ),
      );
    }

    center = Semantics(
      label: widget.semanticLabel,
      value: _display(_value),
      increasedValue: _canInc ? _display(_normalize(_value + _step)) : null,
      decreasedValue: _canDec ? _display(_normalize(_value - _step)) : null,
      onIncrease: _canInc ? () => _bump(1) : null,
      onDecrease: _canDec ? () => _bump(-1) : null,
      child: center,
    );

    return Container(
      height: s.height,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: UiRadius.all(UiRadius.md),
        border: Border.all(color: c.border),
      ),
      child: Row(
        mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          _button(Icons.remove_rounded, 'Decrease', -1, _canDec),
          if (widget.expand)
            Expanded(child: center)
          else if (widget.editable)
            SizedBox(width: 64, child: center)
          else
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 40, maxWidth: 96),
              child: IntrinsicWidth(child: center),
            ),
          _button(Icons.add_rounded, 'Increase', 1, _canInc),
        ],
      ),
    );
  }
}

/// Labelled number input: a full-width stepper whose value can also be typed.
///
/// ```dart
/// UiNumberField(label: 'Guests', value: guests, min: 1, max: 12, onChanged: (v) => setState(() => guests = v))
/// ```
class UiNumberField<T extends num> extends StatelessWidget {
  const UiNumberField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.helper,
    this.error,
    this.min,
    this.max,
    this.step,
    this.decimals,
    this.editable = true,
    this.format,
    this.size = UiSize.md,
    this.isRequired = false,
  });

  final T value;

  /// Called with the new value. Null disables the field.
  final ValueChanged<T>? onChanged;
  final String? label;
  final String? helper;
  final String? error;
  final T? min;
  final T? max;
  final T? step;
  final int? decimals;

  /// Lets the user type a value. Defaults to true.
  final bool editable;
  final String Function(T value)? format;
  final UiSize size;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return UiFieldLabel(
      label: label,
      helper: helper,
      error: error,
      isRequired: isRequired,
      enabled: onChanged != null,
      child: UiStepper<T>(
        value: value,
        onChanged: onChanged,
        min: min,
        max: max,
        step: step,
        decimals: decimals,
        editable: editable,
        format: format,
        size: size,
        expand: true,
        semanticLabel: label,
      ),
    );
  }
}
