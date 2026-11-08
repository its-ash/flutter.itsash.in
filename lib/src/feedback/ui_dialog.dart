import 'package:flutter/material.dart';

import 'package:theme/src/feedback/ui_status_icon.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';

abstract final class UiDialog {
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
    IconData? icon,
  }) async {
    final res = await showDialog<bool>(
      context: context,
      builder: (c) => _UiDialogView(
        title: title,
        message: message,
        icon: icon,
        status: destructive ? UiStatus.danger : UiStatus.info,
        actions: [
          UiButton.outline(cancelLabel, expand: true, onPressed: () => Navigator.pop(c, false)),
          destructive
              ? UiButton.danger(confirmLabel, expand: true, onPressed: () => Navigator.pop(c, true))
              : UiButton(confirmLabel, expand: true, onPressed: () => Navigator.pop(c, true)),
        ],
      ),
    );
    return res ?? false;
  }

  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? message,
    String buttonLabel = 'OK',
    UiStatus? status,
    IconData? icon,
  }) =>
      showDialog<void>(
        context: context,
        builder: (c) => _UiDialogView(
          title: title,
          message: message,
          icon: icon ?? status?.icon,
          status: status ?? UiStatus.info,
          actions: [UiButton(buttonLabel, expand: true, onPressed: () => Navigator.pop(c))],
        ),
      );

  static Future<void> success(
    BuildContext context, {
    String title = 'Success',
    String? message,
    String buttonLabel = 'Done',
  }) =>
      showDialog<void>(
        context: context,
        builder: (c) => _UiDialogView(
          title: title,
          message: message,
          hero: true,
          icon: Icons.check_rounded,
          status: UiStatus.success,
          actions: [UiButton(buttonLabel, expand: true, onPressed: () => Navigator.pop(c))],
        ),
      );

  static Future<String?> input(
    BuildContext context, {
    required String title,
    String? message,
    String? hint,
    String? initialValue,
    String confirmLabel = 'Save',
    String cancelLabel = 'Cancel',
    String? Function(String value)? validator,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscure = false,
  }) =>
      showDialog<String>(
        context: context,
        builder: (_) => _InputDialog(
          title: title,
          message: message,
          hint: hint,
          initialValue: initialValue,
          confirmLabel: confirmLabel,
          cancelLabel: cancelLabel,
          validator: validator,
          keyboardType: keyboardType,
          maxLength: maxLength,
          obscure: obscure,
        ),
      );

  static Future<T?> show<T>(
    BuildContext context, {
    required String title,
    String? message,
    IconData? icon,
    UiStatus status = UiStatus.info,
    Widget? child,
    List<Widget> actions = const [],
    bool dismissible = true,
  }) =>
      showDialog<T>(
        context: context,
        barrierDismissible: dismissible,
        builder: (_) => _UiDialogView(title: title, message: message, icon: icon, status: status, actions: actions, child: child),
      );
}

class _UiDialogView extends StatelessWidget {
  const _UiDialogView({
    required this.title,
    required this.message,
    required this.icon,
    required this.status,
    required this.actions,
    this.child,
    this.hero = false,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final UiStatus status;
  final List<Widget> actions;
  final Widget? child;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final t = context.tone(status);
    final dim = hero ? 88.0 : 56.0;
    Widget? header;
    if (icon != null) {
      header = Container(
        width: dim,
        height: dim,
        decoration: BoxDecoration(color: hero ? t.color : t.container, shape: BoxShape.circle),
        child: Icon(icon, size: dim * 0.5, color: hero ? t.onColor : t.onContainer),
      );
      if (hero) {
        header = TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.4, end: 1),
          duration: const Duration(milliseconds: 600),
          curve: Curves.elasticOut,
          builder: (_, v, c) => Transform.scale(scale: v, child: c),
          child: header,
        );
      }
    }
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UiSpace.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (header != null) ...[header, const UiGap.lg()],
              Semantics(
                header: true,
                child: Text(title, textAlign: TextAlign.center, style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ),
              if (message != null && message!.isNotEmpty) ...[
                const UiGap.sm(),
                Text(message!, textAlign: TextAlign.center, style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ],
              if (child != null) ...[const UiGap.lg(), child!],
              if (actions.isNotEmpty) ...[
                const UiGap.xxl(),
                Row(
                  children: [
                    for (var i = 0; i < actions.length; i++) ...[
                      if (i > 0) const UiGap.md(),
                      Expanded(child: actions[i]),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _InputDialog extends StatefulWidget {
  const _InputDialog({
    required this.title,
    required this.message,
    required this.hint,
    required this.initialValue,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.validator,
    required this.keyboardType,
    required this.maxLength,
    required this.obscure,
  });

  final String title;
  final String? message;
  final String? hint;
  final String? initialValue;
  final String confirmLabel;
  final String cancelLabel;
  final String? Function(String value)? validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final bool obscure;

  @override
  State<_InputDialog> createState() => _InputDialogState();
}

class _InputDialogState extends State<_InputDialog> {
  late final TextEditingController _ctrl = TextEditingController(text: widget.initialValue);
  final _form = GlobalKey<FormState>();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.pop(context, _ctrl.text.trim());
  }

  @override
  Widget build(BuildContext context) => _UiDialogView(
        title: widget.title,
        message: widget.message,
        icon: null,
        status: UiStatus.info,
        actions: [
          UiButton.outline(widget.cancelLabel, expand: true, onPressed: () => Navigator.pop(context)),
          UiButton(widget.confirmLabel, expand: true, onPressed: _submit),
        ],
        child: Form(
          key: _form,
          child: TextFormField(
            controller: _ctrl,
            autofocus: true,
            obscureText: widget.obscure,
            keyboardType: widget.keyboardType,
            maxLength: widget.maxLength,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(hintText: widget.hint),
            validator: (v) => widget.validator?.call(v?.trim() ?? ''),
            onFieldSubmitted: (_) => _submit(),
          ),
        ),
      );
}
