import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/foundation.dart';

/// On-screen numeric keypad for lock screens, with an optional row of dots
/// that fill as the PIN is typed. Clears itself after [onCompleted].
///
/// ```dart
/// UiPinPad(length: 4, onCompleted: unlock, onBiometric: useFaceId)
/// ```
class UiPinPad extends StatefulWidget {
  const UiPinPad({
    super.key,
    this.length = 4,
    this.onCompleted,
    this.onChanged,
    this.showDots = true,
    this.error,
    this.onBiometric,
    this.biometricIcon = Icons.fingerprint_rounded,
    this.clearOnComplete = true,
    this.enabled = true,
  }) : assert(length > 0);

  /// Number of digits in the PIN.
  final int length;

  /// Called with the PIN once [length] digits are entered.
  final ValueChanged<String>? onCompleted;

  /// Called after every key press with the current PIN.
  final ValueChanged<String>? onChanged;

  /// Shows a row of dots above the keypad.
  final bool showDots;

  /// Error text below the dots; also tints the dots red.
  final String? error;

  /// Shows a biometric key in the bottom-left corner.
  final VoidCallback? onBiometric;
  final IconData biometricIcon;

  /// Empties the PIN after [onCompleted] is called.
  final bool clearOnComplete;
  final bool enabled;

  @override
  State<UiPinPad> createState() => _UiPinPadState();
}

class _UiPinPadState extends State<UiPinPad> {
  String _pin = '';
  Timer? _clearTimer;

  @override
  void dispose() {
    _clearTimer?.cancel();
    super.dispose();
  }

  void _press(String digit) {
    if (_pin.length >= widget.length) return;
    HapticFeedback.lightImpact();
    setState(() => _pin += digit);
    widget.onChanged?.call(_pin);
    if (_pin.length == widget.length) {
      widget.onCompleted?.call(_pin);
      if (widget.clearOnComplete) {
        // Leave the last dot visible for a moment before clearing.
        _clearTimer?.cancel();
        _clearTimer = Timer(context.motion(UiMotion.slow), () {
          if (mounted) setState(() => _pin = '');
        });
      }
    }
  }

  void _backspace() {
    if (_pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
    widget.onChanged?.call(_pin);
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent e) {
    if (!widget.enabled || e is KeyUpEvent) return KeyEventResult.ignored;
    final ch = e.character;
    if (ch != null && RegExp(r'^\d$').hasMatch(ch)) {
      _press(ch);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.backspace) {
      _backspace();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasError = widget.error != null && widget.error!.isNotEmpty;
    final enabled = widget.enabled;

    return Focus(
      onKeyEvent: _onKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
          // Figma keypad: 46 high keys, radius 6, 6 px gaps.
          const gapX = 6.0;
          const gapY = 6.0;
          final key = ((maxW - gapX * 2) / 3).clamp(64.0, 120.0);
          const letters = {
            '2': 'ABC', '3': 'DEF', '4': 'GHI', '5': 'JKL', //
            '6': 'MNO', '7': 'PQRS', '8': 'TUV', '9': 'WXYZ',
          };

          Widget digit(String d) => _PadKey(
            size: key,
            filled: true,
            onTap: enabled ? () => _press(d) : null,
            semanticLabel: d,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  d,
                  style: context.text.bodyMedium?.copyWith(
                    fontSize: 25,
                    height: 1.1,
                    color: enabled ? c.text : c.textDisabled,
                  ),
                ),
                if (letters[d] != null)
                  Text(
                    letters[d]!,
                    style: context.text.labelSmall?.copyWith(
                      height: 1,
                      letterSpacing: 1.5,
                      color: enabled ? c.text : c.textDisabled,
                    ),
                  ),
              ],
            ),
          );

          Widget row(List<Widget> keys) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < keys.length; i++) ...[if (i > 0) SizedBox(width: gapX), keys[i]],
            ],
          );

          final biometric = widget.onBiometric == null
              ? SizedBox(width: key, height: _PadKey.height)
              : _PadKey(
                  size: key,
                  onTap: enabled ? widget.onBiometric : null,
                  semanticLabel: 'Use biometrics',
                  child: Icon(widget.biometricIcon, size: 24, color: enabled ? c.accent : c.textDisabled),
                );
          final back = AnimatedOpacity(
            opacity: _pin.isEmpty ? 0.35 : 1,
            duration: context.motion(UiMotion.fast),
            child: _PadKey(
              size: key,
              onTap: enabled && _pin.isNotEmpty ? _backspace : null,
              onLongPress: enabled && _pin.isNotEmpty
                  ? () {
                      setState(() => _pin = '');
                      widget.onChanged?.call(_pin);
                    }
                  : null,
              semanticLabel: 'Delete',
              child: Icon(Icons.backspace_outlined, size: 22, color: enabled ? c.text : c.textDisabled),
            ),
          );

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.showDots) ...[
                Semantics(
                  label: 'PIN, ${_pin.length} of ${widget.length} digits entered',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < widget.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm - 1),
                          child: AnimatedContainer(
                            duration: context.motion(UiMotion.fast),
                            curve: UiMotion.bounce,
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: i < _pin.length ? (hasError ? c.danger : c.accent) : c.gray(2),
                              border: i < _pin.length ? null : Border.all(color: hasError ? c.danger : c.borderStrong),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(
                  height: UiSpace.xl + UiSpace.sm,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: context.motion(UiMotion.fast),
                      child: hasError
                          ? Text(
                              widget.error!,
                              key: ValueKey(widget.error),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall?.copyWith(color: c.danger),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
              ],
              row([digit('1'), digit('2'), digit('3')]),
              SizedBox(height: gapY),
              row([digit('4'), digit('5'), digit('6')]),
              SizedBox(height: gapY),
              row([digit('7'), digit('8'), digit('9')]),
              SizedBox(height: gapY),
              row([biometric, digit('0'), back]),
            ],
          );
        },
      ),
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({
    required this.size,
    required this.child,
    required this.semanticLabel,
    this.onTap,
    this.onLongPress,
    this.filled = false,
  });

  final double size;
  final Widget child;
  final String semanticLabel;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool filled;

  /// Key height (Figma keypad).
  static const double height = 46;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      enabled: onTap != null,
      onTap: onTap,
      child: Material(
        color: filled ? c.surfaceMuted : Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: UiRadius.all(UiRadius.sm)),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          splashColor: c.surfaceMuted,
          highlightColor: c.surfaceMuted,
          child: SizedBox(
            width: size,
            height: height,
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}
