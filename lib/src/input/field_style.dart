// Internal helpers shared by the input group. Not exported from the barrel.
import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Builds the [InputDecoration] used by every text input of the group.
///
/// Errors are shown by `UiFieldLabel`, so this only switches the border to
/// the danger color; it never renders error text itself.
InputDecoration fieldDecoration(
  BuildContext context, {
  String? hint,
  IconData? prefixIcon,
  Widget? suffix,
  UiSize size = UiSize.md,
  bool hasError = false,
  bool enabled = true,
  double radius = UiRadius.md,
  bool multiline = false,
}) {
  final c = context.colors;
  OutlineInputBorder border(Color color, [double width = 1]) => OutlineInputBorder(
    borderRadius: UiRadius.all(radius),
    borderSide: BorderSide(color: color, width: width),
  );
  final vertical = multiline ? UiSpace.md : 0.0;
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: c.textSubtle, fontSize: size.fontSize),
    hintMaxLines: multiline ? null : 1,
    filled: true,
    fillColor: enabled ? c.surfaceMuted : c.surfaceMuted.withValues(alpha: 0.6),
    isDense: true,
    constraints: BoxConstraints(minHeight: size.height),
    contentPadding: EdgeInsets.symmetric(horizontal: size.padding - 2, vertical: vertical),
    prefixIcon: prefixIcon == null
        ? null
        : Padding(
            padding: EdgeInsetsDirectional.only(start: size.padding - 4, end: UiSpace.sm),
            child: Icon(prefixIcon, size: size.iconSize),
          ),
    prefixIconConstraints: BoxConstraints(minHeight: size.height, minWidth: size.iconSize),
    prefixIconColor: enabled ? c.textSubtle : c.textDisabled,
    suffixIcon: suffix == null
        ? null
        : Padding(
            padding: const EdgeInsetsDirectional.only(end: UiSpace.xs),
            child: IconTheme.merge(
              data: IconThemeData(size: size.iconSize + 2, color: enabled ? c.textMuted : c.textDisabled),
              child: suffix,
            ),
          ),
    suffixIconConstraints: BoxConstraints(minHeight: size.height - 8, minWidth: UiSpace.sm),
    counterText: '',
    border: border(hasError ? c.danger : Colors.transparent),
    enabledBorder: border(hasError ? c.danger : Colors.transparent),
    disabledBorder: border(Colors.transparent),
    focusedBorder: border(hasError ? c.danger : c.accent, 1.5),
    errorBorder: border(c.danger),
    focusedErrorBorder: border(c.danger, 1.5),
  );
}

/// Text style for the typed value of a field of [size].
TextStyle fieldTextStyle(BuildContext context, UiSize size, {bool enabled = true}) {
  final c = context.colors;
  return (context.text.bodyMedium ?? const TextStyle()).copyWith(
    fontSize: size.fontSize,
    height: 1.4,
    color: enabled ? c.text : c.textDisabled,
  );
}

/// Small round icon button used inside fields (clear, toggle, filter).
class FieldIconButton extends StatelessWidget {
  const FieldIconButton({super.key, required this.icon, required this.tooltip, this.onPressed, this.color, this.size});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? color;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: size ?? 18),
      color: color ?? c.textMuted,
      disabledColor: c.textDisabled,
      style: IconButton.styleFrom(
        minimumSize: const Size(40, 40),
        padding: EdgeInsets.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
      ),
    );
  }
}

/// A field-looking tappable box: the trigger of select, date and similar
/// pickers. Shows a focus ring, error border and disabled look.
class FieldBox extends StatefulWidget {
  const FieldBox({
    super.key,
    required this.child,
    this.onTap,
    this.prefixIcon,
    this.trailing = const [],
    this.size = UiSize.md,
    this.hasError = false,
    this.semanticLabel,
    this.padding,
    this.focusNode,
  });

  final Widget child;
  final VoidCallback? onTap;
  final IconData? prefixIcon;
  final List<Widget> trailing;
  final UiSize size;
  final bool hasError;
  final String? semanticLabel;
  final EdgeInsetsGeometry? padding;
  final FocusNode? focusNode;

  @override
  State<FieldBox> createState() => _FieldBoxState();
}

class _FieldBoxState extends State<FieldBox> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = widget.onTap != null;
    final borderColor = widget.hasError
        ? c.danger
        : _focused
        ? c.accent
        : Colors.transparent;
    final radius = UiRadius.all(UiRadius.md);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: AnimatedContainer(
        duration: context.motion(UiMotion.fast),
        curve: UiMotion.standard,
        constraints: BoxConstraints(minHeight: widget.size.height),
        decoration: BoxDecoration(
          color: enabled ? c.surfaceMuted : c.surfaceMuted.withValues(alpha: 0.6),
          borderRadius: radius,
          border: Border.all(color: borderColor, width: _focused || widget.hasError ? 1.5 : 1),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            focusNode: widget.focusNode,
            onTap: widget.onTap,
            onFocusChange: (f) => setState(() => _focused = f),
            borderRadius: radius,
            child: Padding(
              padding:
                  widget.padding ??
                  EdgeInsetsDirectional.only(start: widget.size.padding - 2, end: UiSpace.xs, top: 4, bottom: 4),
              child: Row(
                children: [
                  if (widget.prefixIcon != null) ...[
                    Icon(widget.prefixIcon, size: widget.size.iconSize, color: enabled ? c.textSubtle : c.textDisabled),
                    const SizedBox(width: UiSpace.sm),
                  ],
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: fieldTextStyle(context, widget.size, enabled: enabled),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: widget.child,
                    ),
                  ),
                  ...widget.trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Text inside a [FieldBox]: the value, or the [hint] in a subtle color.
class FieldValueText extends StatelessWidget {
  const FieldValueText({super.key, this.value, this.hint, this.enabled = true});

  final String? value;
  final String? hint;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final empty = value == null || value!.isEmpty;
    return Text(
      empty ? (hint ?? '') : value!,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: !enabled
            ? c.textDisabled
            : empty
            ? c.textSubtle
            : c.text,
      ),
    );
  }
}
