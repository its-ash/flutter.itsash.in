import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiOtpField extends StatefulWidget {
  const UiOtpField({
    super.key,
    this.length = 6,
    this.onCompleted,
    this.onChanged,
    this.controller,
    this.obscure = false,
    this.numeric = true,
    this.error,
    this.autofocus = false,
    this.enabled = true,
    this.focusNode,
  });

  final int length;
  final ValueChanged<String>? onCompleted;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final bool obscure;
  final bool numeric;
  final String? error;
  final bool autofocus;
  final bool enabled;
  final FocusNode? focusNode;

  @override
  State<UiOtpField> createState() => _UiOtpFieldState();
}

class _UiOtpFieldState extends State<UiOtpField> {
  TextEditingController? _own;
  FocusNode? _ownFocus;
  String? _done;

  TextEditingController get _ctrl => widget.controller ?? (_own ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());
  int get _len => widget.length.clamp(4, 8);

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onText);
    _focus.addListener(_onFocus);
  }

  @override
  void didUpdateWidget(UiOtpField old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      (old.controller ?? _own)?.removeListener(_onText);
      _ctrl.addListener(_onText);
    }
    if (old.focusNode != widget.focusNode) {
      (old.focusNode ?? _ownFocus)?.removeListener(_onFocus);
      _focus.addListener(_onFocus);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onText);
    _focus.removeListener(_onFocus);
    _own?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (mounted) setState(() {});
  }

  void _onText() {
    if (!mounted) return;
    setState(() {});
    final v = _ctrl.text;
    if (v.length == _len) {
      if (_done != v) {
        _done = v;
        widget.onCompleted?.call(v);
      }
    } else {
      _done = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final len = _len;
    final text = _ctrl.text;
    final hasError = widget.error != null;
    final focused = _focus.hasFocus;
    final input = TextField(
      controller: _ctrl,
      focusNode: _focus,
      enabled: widget.enabled,
      autofocus: widget.autofocus,
      maxLength: len,
      maxLines: null,
      expands: true,
      textAlignVertical: TextAlignVertical.center,
      showCursor: false,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: widget.numeric ? TextInputType.number : TextInputType.visiblePassword,
      textCapitalization: TextCapitalization.characters,
      autofillHints: const [AutofillHints.oneTimeCode],
      inputFormatters: [
        FilteringTextInputFormatter.allow(widget.numeric ? RegExp('[0-9]') : RegExp('[A-Za-z0-9]')),
        LengthLimitingTextInputFormatter(len),
      ],
      onChanged: widget.onChanged,
      style: const TextStyle(color: Colors.transparent, fontSize: 1),
      cursorColor: Colors.transparent,
      decoration: const InputDecoration(
        counterText: '',
        filled: false,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        isCollapsed: true,
      ),
    );

    return Semantics(
      label: 'Verification code, $len characters',
      value: widget.obscure ? null : text,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          LayoutBuilder(
            builder: (context, c) {
              const gap = UiSpace.sm;
              final maxW = c.hasBoundedWidth ? c.maxWidth : len * 56.0;
              final w = math.min(56.0, (maxW - gap * (len - 1)) / len).clamp(28.0, 56.0);
              final h = math.max(w * 1.15, 48.0);
              return Stack(
                alignment: Alignment.center,
                children: [
                  ExcludeSemantics(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (var i = 0; i < len; i++) ...[
                          if (i > 0) const SizedBox(width: gap),
                          _Box(
                            char: i < text.length ? (widget.obscure ? '•' : text[i]) : null,
                            active: focused && (i == text.length || (i == len - 1 && text.length == len)),
                            error: hasError,
                            enabled: widget.enabled,
                            width: w,
                            height: h,
                          ),
                        ],
                      ],
                    ),
                  ),
                  Positioned.fill(
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        textSelectionTheme: const TextSelectionThemeData(
                          selectionColor: Colors.transparent,
                          selectionHandleColor: Colors.transparent,
                          cursorColor: Colors.transparent,
                        ),
                      ),
                      child: Opacity(opacity: 0.01, child: input),
                    ),
                  ),
                ],
              );
            },
          ),
          AnimatedSize(
            duration: UiDuration.fast,
            child: hasError && widget.error!.isNotEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: UiSpace.sm),
                    child: Text(
                      widget.error!,
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall?.copyWith(color: cs.error, fontWeight: FontWeight.w500),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({
    required this.char,
    required this.active,
    required this.error,
    required this.enabled,
    required this.width,
    required this.height,
  });

  final String? char;
  final bool active;
  final bool error;
  final bool enabled;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final border = error
        ? cs.error
        : active
            ? cs.primary
            : char != null
                ? cs.outlineVariant
                : Colors.transparent;
    final fill = error
        ? cs.errorContainer.withValues(alpha: 0.35)
        : cs.surfaceContainerHighest.withValues(alpha: context.isDark ? 0.6 : 0.7);
    return AnimatedContainer(
      duration: UiDuration.fast,
      curve: UiCurve.standard,
      width: width,
      height: height,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: enabled ? fill : cs.onSurface.withValues(alpha: 0.06),
        borderRadius: context.tokens.md,
        border: Border.all(color: border, width: active || error ? 1.6 : 1),
      ),
      child: AnimatedSwitcher(
        duration: UiDuration.fast,
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
        child: char != null
            ? Text(
                char!,
                key: ValueKey(char),
                style: context.text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: enabled ? cs.onSurface : cs.onSurface.withValues(alpha: 0.38),
                ),
              )
            : active
                ? Container(
                    key: const ValueKey('caret'),
                    width: 2,
                    height: height * 0.4,
                    decoration: BoxDecoration(color: cs.primary, borderRadius: context.tokens.full),
                  )
                : const SizedBox.shrink(),
      ),
    );
  }
}
