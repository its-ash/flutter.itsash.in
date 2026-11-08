import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_avatar.dart';

class UiPinPad extends StatefulWidget {
  const UiPinPad({
    super.key,
    required this.onCompleted,
    this.length = 4,
    this.onBiometric,
    this.biometricIcon = Icons.fingerprint_rounded,
    this.errorText = 'Wrong PIN. Try again.',
    this.keySize = 72,
  });

  final Future<bool> Function(String pin) onCompleted;
  final int length;
  final VoidCallback? onBiometric;
  final IconData biometricIcon;
  final String errorText;
  final double keySize;

  @override
  State<UiPinPad> createState() => _UiPinPadState();
}

class _UiPinPadState extends State<UiPinPad> with SingleTickerProviderStateMixin {
  late final AnimationController _shake = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
  String _pin = '';
  bool _busy = false;
  bool _error = false;

  int get _len => widget.length.clamp(4, 8);

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _add(String d) async {
    if (_busy || _pin.length >= _len) return;
    HapticFeedback.selectionClick();
    setState(() {
      _pin += d;
      _error = false;
    });
    if (_pin.length < _len) return;
    setState(() => _busy = true);
    bool ok;
    try {
      ok = await widget.onCompleted(_pin);
    } catch (_) {
      ok = false;
    }
    if (!mounted) return;
    if (ok) {
      setState(() {
        _busy = false;
        _pin = '';
      });
      return;
    }
    HapticFeedback.heavyImpact();
    setState(() => _error = true);
    await _shake.forward(from: 0);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _pin = '';
    });
  }

  void _back() {
    if (_busy || _pin.isEmpty) return;
    HapticFeedback.selectionClick();
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _clear() {
    if (_busy || _pin.isEmpty) return;
    setState(() => _pin = '');
  }

  KeyEventResult _onKey(FocusNode _, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    final ch = e.character;
    if (ch != null && RegExp(r'^\d$').hasMatch(ch)) {
      _add(ch);
      return KeyEventResult.handled;
    }
    if (e.logicalKey == LogicalKeyboardKey.backspace) {
      _back();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Focus(
      autofocus: true,
      onKeyEvent: _onKey,
      child: LayoutBuilder(
        builder: (context, c) {
          const gap = UiSpace.lg;
          final k = c.maxWidth.isFinite ? math.min(widget.keySize, (c.maxWidth - gap * 2) / 3).clamp(48.0, 96.0) : widget.keySize;
          Widget key(Widget child, {String? label, VoidCallback? onTap, VoidCallback? onLong}) => SizedBox.square(
                dimension: k,
                child: onTap == null
                    ? null
                    : Semantics(
                        button: true,
                        label: label,
                        excludeSemantics: label != null,
                        child: Material(
                          color: label == null ? cs.surfaceContainerHigh : Colors.transparent,
                          shape: const CircleBorder(),
                          clipBehavior: Clip.antiAlias,
                          child: InkWell(onTap: onTap, onLongPress: onLong, child: Center(child: child)),
                        ),
                      ),
              );
          Widget digit(String d) => key(
                Text(d, style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w600, fontSize: k * 0.36)),
                onTap: () => _add(d),
              );
          Widget row(List<Widget> keys) => Row(
                mainAxisSize: MainAxisSize.min,
                children: [for (var i = 0; i < keys.length; i++) ...[if (i > 0) const SizedBox(width: gap), keys[i]]],
              );
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _shake,
                builder: (context, child) => Transform.translate(
                  offset: Offset(math.sin(_shake.value * math.pi * 6) * 12 * (1 - _shake.value), 0),
                  child: child,
                ),
                child: Semantics(
                  label: '${_pin.length} of $_len digits entered',
                  liveRegion: true,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < _len; i++)
                        AnimatedContainer(
                          duration: UiDuration.fast,
                          curve: Curves.easeOutBack,
                          margin: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
                          width: i < _pin.length ? 16 : 14,
                          height: i < _pin.length ? 16 : 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _error ? cs.error : (i < _pin.length ? cs.primary : Colors.transparent),
                            border: Border.all(color: _error ? cs.error : (i < _pin.length ? cs.primary : cs.outline), width: 2),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 40,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _error ? 1 : 0,
                    duration: UiDuration.fast,
                    child: Text(widget.errorText, style: context.text.bodyMedium?.copyWith(color: cs.error)),
                  ),
                ),
              ),
              row([digit('1'), digit('2'), digit('3')]),
              const SizedBox(height: gap),
              row([digit('4'), digit('5'), digit('6')]),
              const SizedBox(height: gap),
              row([digit('7'), digit('8'), digit('9')]),
              const SizedBox(height: gap),
              row([
                key(
                  Icon(widget.biometricIcon, size: k * 0.42, color: cs.primary),
                  label: 'Use biometrics',
                  onTap: widget.onBiometric == null || _busy ? null : widget.onBiometric,
                ),
                digit('0'),
                key(
                  Icon(Icons.backspace_outlined, size: k * 0.34, color: cs.onSurfaceVariant),
                  label: 'Delete',
                  onTap: _pin.isEmpty ? null : _back,
                  onLong: _clear,
                ),
              ]),
            ],
          );
        },
      ),
    );
  }
}

class UiLockScreen extends StatelessWidget {
  const UiLockScreen({
    super.key,
    required this.onCompleted,
    this.name,
    this.avatarUrl,
    this.greeting,
    this.subtitle = 'Enter your PIN',
    this.length = 4,
    this.onBiometric,
    this.onForgot,
    this.forgotLabel = 'Forgot PIN?',
  });

  final Future<bool> Function(String pin) onCompleted;
  final String? name;
  final String? avatarUrl;
  final String? greeting;
  final String subtitle;
  final int length;
  final VoidCallback? onBiometric;
  final VoidCallback? onForgot;
  final String forgotLabel;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final n = name?.trim() ?? '';
    final first = n.isEmpty ? '' : n.split(RegExp(r'\s+')).first;
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.xxl, vertical: UiSpace.xxl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UiAvatar(name: n.isEmpty ? null : n, imageUrl: avatarUrl, size: 72, icon: Icons.lock_rounded),
                const SizedBox(height: UiSpace.lg),
                Semantics(
                  header: true,
                  child: Text(
                    greeting ?? (first.isEmpty ? 'Welcome back' : 'Welcome back, $first'),
                    textAlign: TextAlign.center,
                    style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: UiSpace.xs),
                Text(subtitle, textAlign: TextAlign.center, style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: UiSpace.xxl),
                UiPinPad(onCompleted: onCompleted, length: length, onBiometric: onBiometric),
                if (onForgot != null) ...[
                  const SizedBox(height: UiSpace.lg),
                  TextButton(onPressed: onForgot, child: Text(forgotLabel)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
