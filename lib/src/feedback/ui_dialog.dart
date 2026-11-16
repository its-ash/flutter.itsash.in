import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// One button of a [UiDialog]. Tapping it closes the dialog with [value].
class UiDialogAction<T> {
  const UiDialogAction(this.label, {this.value, this.primary = false, this.destructive = false, this.onPressed});

  final String label;

  /// Returned from [UiDialog.show] when tapped.
  final T? value;

  /// Filled style. Use for the main action.
  final bool primary;

  /// Danger color, for delete-like actions.
  final bool destructive;

  /// Extra callback run before the dialog closes.
  final VoidCallback? onPressed;
}

/// Centered modal dialogs: custom, confirm, alert and prompt.
///
/// ```dart
/// final ok = await UiDialog.confirm(context, title: 'Delete note?', destructive: true);
/// ```
abstract final class UiDialog {
  /// Shows a dialog with an optional tinted icon, title, message, custom
  /// [content] and [actions]. Returns the tapped action's value, or null when
  /// dismissed.
  static Future<T?> show<T>(
    BuildContext context, {
    String? title,
    String? message,
    Widget? content,
    List<UiDialogAction<T>> actions = const [],
    IconData? icon,
    UiStatus status = UiStatus.accent,
    bool dismissible = true,
  }) {
    return _present<T>(
      context,
      dismissible: dismissible,
      builder: (ctx) => _DialogFrame(
        icon: icon,
        status: status,
        closable: dismissible,
        title: title,
        message: message,
        content: content,
        buttons: [
          for (final a in actions)
            _DialogButton(
              label: a.label,
              primary: a.primary,
              destructive: a.destructive,
              onPressed: () {
                a.onPressed?.call();
                Navigator.of(ctx).pop(a.value);
              },
            ),
        ],
      ),
    );
  }

  /// Asks a yes/no question. Returns true only when confirmed.
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    String? message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool destructive = false,
    IconData? icon,
  }) async {
    final result = await show<bool>(
      context,
      title: title,
      message: message,
      icon: icon ?? (destructive ? Icons.warning_amber_rounded : null),
      status: destructive ? UiStatus.danger : UiStatus.accent,
      actions: [
        UiDialogAction(cancelLabel, value: false),
        UiDialogAction(confirmLabel, value: true, primary: true, destructive: destructive),
      ],
    );
    return result ?? false;
  }

  /// Shows a message with a single OK button.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    String? message,
    String okLabel = 'OK',
    UiStatus status = UiStatus.info,
    IconData? icon,
  }) {
    return show<void>(
      context,
      title: title,
      message: message,
      status: status,
      icon: icon ?? status.icon,
      actions: [UiDialogAction(okLabel, primary: true)],
    );
  }

  /// Asks for one line of text. Returns the text, or null when cancelled.
  ///
  /// [validator] returns an error message, or null when the value is valid.
  static Future<String?> prompt(
    BuildContext context, {
    required String title,
    String? message,
    String? label,
    String? hint,
    String? initialValue,
    String? Function(String value)? validator,
    String confirmLabel = 'Save',
    String cancelLabel = 'Cancel',
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return _present<String>(
      context,
      dismissible: true,
      builder: (ctx) => _PromptDialog(
        title: title,
        message: message,
        label: label,
        hint: hint,
        initialValue: initialValue,
        validator: validator,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        keyboardType: keyboardType,
        obscureText: obscureText,
      ),
    );
  }

  static Future<T?> _present<T>(BuildContext context, {required bool dismissible, required WidgetBuilder builder}) {
    final navigator = Navigator.of(context, rootNavigator: true);
    final themes = InheritedTheme.capture(from: context, to: navigator.context);
    return showGeneralDialog<T>(
      context: context,
      useRootNavigator: true,
      barrierDismissible: dismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: context.colors.scrim,
      transitionDuration: context.motion(UiMotion.normal),
      pageBuilder: (ctx, _, _) => themes.wrap(
        PopScope(
          canPop: dismissible,
          child: Builder(builder: builder),
        ),
      ),
      transitionBuilder: (ctx, animation, _, child) {
        final curved = animation.drive(CurveTween(curve: UiMotion.emphasized));
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(scale: Tween<double>(begin: 0.96, end: 1).animate(curved), child: child),
        );
      },
    );
  }
}

/// Icon in a soft tinted circle, shared by dialogs.
class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.status});

  final IconData icon;
  final UiStatus status;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = c.tone(status);
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: tone.soft, shape: BoxShape.circle),
      child: Icon(icon, size: 20, color: status == UiStatus.neutral ? c.textMuted : tone.color),
    );
  }
}

class _DialogFrame extends StatelessWidget {
  const _DialogFrame({
    this.icon,
    this.status = UiStatus.accent,
    this.title,
    this.message,
    this.content,
    this.buttons = const [],
    this.closable = false,
  });

  final IconData? icon;
  final UiStatus status;
  final String? title;
  final String? message;
  final Widget? content;
  final List<Widget> buttons;

  /// Shows the round close control in the top row.
  final bool closable;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    // Figma "dialog": gray-2 surface, radius 12, level 3 shadow, 24 padding,
    // left-aligned H3 title and gray-6 description, stacked full-width buttons.
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      shadowColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: c.surfaceRaised,
            borderRadius: UiRadius.all(UiRadius.lg),
            boxShadow: context.shadowLg,
          ),
          child: Padding(
            padding: const EdgeInsets.all(UiSpace.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (closable)
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: _CloseControl(onTap: () => Navigator.of(context).maybePop()),
                  ),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (icon != null) ...[
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: _IconBadge(icon: icon!, status: status),
                          ),
                          const SizedBox(height: UiSpace.lg),
                        ],
                        if (title != null) Semantics(header: true, child: Text(title!, style: t.headlineSmall)),
                        if (message != null) ...[
                          if (title != null) const SizedBox(height: UiSpace.md),
                          Text(message!, style: t.bodyMedium?.copyWith(color: c.textMuted)),
                        ],
                        if (content != null) ...[
                          if (title != null || message != null) const SizedBox(height: UiSpace.lg),
                          content!,
                        ],
                      ],
                    ),
                  ),
                ),
                if (buttons.isNotEmpty) ...[const SizedBox(height: UiSpace.xl), _DialogButtons(buttons: buttons)],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The 24 px round Overlay close control of the dialog's top row.
class _CloseControl extends StatelessWidget {
  const _CloseControl({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: MaterialLocalizations.of(context).closeButtonTooltip,
      excludeSemantics: true,
      child: Material(
        color: c.surfaceMuted,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(dimension: 24, child: Icon(Icons.close_rounded, size: 16, color: c.textMuted)),
        ),
      ),
    );
  }
}

/// Stacks the buttons full width with the main action (the last one) on top.
class _DialogButtons extends StatelessWidget {
  const _DialogButtons({required this.buttons});

  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    final stacked = buttons.reversed.toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < stacked.length; i++) ...[if (i > 0) const SizedBox(height: UiSpace.lg), stacked[i]],
      ],
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({required this.label, required this.onPressed, this.primary = false, this.destructive = false});

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Text(label, maxLines: 1, overflow: TextOverflow.ellipsis);
    if (primary) {
      return FilledButton(
        onPressed: onPressed,
        style: destructive ? FilledButton.styleFrom(backgroundColor: c.danger, foregroundColor: c.onDanger) : null,
        child: text,
      );
    }
    // "Dim" button: Overlay fill, regular label.
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: c.surfaceMuted,
        foregroundColor: destructive ? c.danger : c.gray(7),
        textStyle: context.text.bodyMedium,
      ),
      child: text,
    );
  }
}

class _PromptDialog extends StatefulWidget {
  const _PromptDialog({
    required this.title,
    required this.message,
    required this.label,
    required this.hint,
    required this.initialValue,
    required this.validator,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.keyboardType,
    required this.obscureText,
  });

  final String title;
  final String? message;
  final String? label;
  final String? hint;
  final String? initialValue;
  final String? Function(String value)? validator;
  final String confirmLabel;
  final String cancelLabel;
  final TextInputType? keyboardType;
  final bool obscureText;

  @override
  State<_PromptDialog> createState() => _PromptDialogState();
}

class _PromptDialogState extends State<_PromptDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initialValue);
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? true) Navigator.of(context).pop(_controller.text);
  }

  @override
  Widget build(BuildContext context) {
    final validator = widget.validator;
    return _DialogFrame(
      title: widget.title,
      message: widget.message,
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: widget.keyboardType,
          obscureText: widget.obscureText,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(labelText: widget.label, hintText: widget.hint),
          validator: validator == null ? null : (v) => validator(v ?? ''),
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      buttons: [
        _DialogButton(label: widget.cancelLabel, onPressed: () => Navigator.of(context).pop()),
        _DialogButton(label: widget.confirmLabel, primary: true, onPressed: _submit),
      ],
    );
  }
}
