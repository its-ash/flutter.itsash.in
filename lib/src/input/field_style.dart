// Internal helpers shared by the input group. Not exported from the barrel.
import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Height of a field of [size] (Ash Theme "field": 36 at md).
double fieldHeight(UiSize size) => switch (size) {
  UiSize.sm => 32,
  UiSize.md => 36,
  UiSize.lg => 44,
};

/// Corner radius of a field. With an error the bottom corners are square so
/// the danger caption strip of `UiFieldLabel` joins the field.
BorderRadius fieldRadius({bool hasError = false, double radius = UiRadius.md}) =>
    hasError ? BorderRadius.vertical(top: Radius.circular(radius)) : UiRadius.all(radius);

/// Hover and focus halo around a field: a 4 px gray-3 ring on hover, a
/// Primary 50% glow while focused (the 1 px Primary border comes from the
/// field itself). Tracks focus of any descendant.
class FieldFrame extends StatefulWidget {
  const FieldFrame({
    super.key,
    required this.child,
    this.enabled = true,
    this.hasError = false,
    this.radius = UiRadius.md,
  });

  final Widget child;
  final bool enabled;
  final bool hasError;
  final double radius;

  @override
  State<FieldFrame> createState() => _FieldFrameState();
}

class _FieldFrameState extends State<FieldFrame> {
  bool _hover = false;
  bool _focus = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final List<BoxShadow> shadows;
    if (!widget.enabled) {
      shadows = const [];
    } else if (_focus) {
      final glow = widget.hasError ? c.danger : c.accent;
      shadows = [BoxShadow(color: glow.withValues(alpha: 0.5), spreadRadius: 2)];
    } else if (_hover) {
      shadows = [BoxShadow(color: c.gray(3), spreadRadius: 4)];
    } else {
      shadows = const [];
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Focus(
        canRequestFocus: false,
        skipTraversal: true,
        onFocusChange: (f) => setState(() => _focus = f),
        child: AnimatedContainer(
          duration: context.motion(UiMotion.fast),
          curve: UiMotion.standard,
          decoration: BoxDecoration(
            borderRadius: fieldRadius(hasError: widget.hasError, radius: widget.radius),
            boxShadow: shadows,
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

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
  final height = fieldHeight(size);
  final shape = fieldRadius(hasError: hasError, radius: radius);
  OutlineInputBorder border(Color color) => OutlineInputBorder(
    borderRadius: shape,
    borderSide: BorderSide(color: color),
  );
  final vertical = multiline ? UiSpace.sm : 0.0;
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: enabled ? c.textSubtle : c.textDisabled, fontSize: size.fontSize),
    hintMaxLines: multiline ? null : 1,
    filled: true,
    fillColor: c.surfaceMuted,
    hoverColor: Colors.transparent,
    isDense: true,
    constraints: BoxConstraints(minHeight: height),
    contentPadding: EdgeInsets.symmetric(horizontal: size.padding, vertical: vertical),
    prefixIcon: prefixIcon == null
        ? null
        : Padding(
            padding: EdgeInsetsDirectional.only(start: size.padding, end: UiSpace.md),
            child: Icon(prefixIcon, size: 16),
          ),
    prefixIconConstraints: BoxConstraints(minHeight: height, minWidth: 16),
    prefixIconColor: enabled ? c.textSubtle : c.textDisabled,
    suffixIcon: suffix == null
        ? null
        : Padding(
            padding: const EdgeInsetsDirectional.only(end: UiSpace.sm),
            child: IconTheme.merge(
              data: IconThemeData(size: 16, color: enabled ? c.textSubtle : c.textDisabled),
              child: suffix,
            ),
          ),
    suffixIconConstraints: BoxConstraints(minHeight: height - 8, minWidth: UiSpace.sm),
    counterText: '',
    border: border(hasError ? c.danger : Colors.transparent),
    enabledBorder: border(hasError ? c.danger : Colors.transparent),
    disabledBorder: border(Colors.transparent),
    focusedBorder: border(hasError ? c.danger : c.accent),
    errorBorder: border(c.danger),
    focusedErrorBorder: border(c.danger),
  );
}

/// Text style for the typed value of a field of [size].
TextStyle fieldTextStyle(BuildContext context, UiSize size, {bool enabled = true}) {
  final c = context.colors;
  return (context.text.bodyMedium ?? const TextStyle()).copyWith(
    fontSize: size.fontSize,
    height: 20 / 14,
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
      icon: Icon(icon, size: size ?? 16),
      color: color ?? c.textSubtle,
      disabledColor: c.textDisabled,
      style: IconButton.styleFrom(
        minimumSize: const Size(32, 32),
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
    final radius = fieldRadius(hasError: widget.hasError);
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.semanticLabel,
      child: FieldFrame(
        enabled: enabled,
        hasError: widget.hasError,
        child: AnimatedContainer(
          duration: context.motion(UiMotion.fast),
          curve: UiMotion.standard,
          constraints: BoxConstraints(minHeight: fieldHeight(widget.size)),
          decoration: BoxDecoration(
            color: c.surfaceMuted,
            borderRadius: radius,
            border: Border.all(color: borderColor),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              focusNode: widget.focusNode,
              onTap: widget.onTap,
              onFocusChange: (f) => setState(() => _focused = f),
              borderRadius: radius,
              hoverColor: Colors.transparent,
              child: Padding(
                padding:
                    widget.padding ??
                    EdgeInsetsDirectional.only(start: widget.size.padding, end: UiSpace.sm, top: 2, bottom: 2),
                child: Row(
                  children: [
                    if (widget.prefixIcon != null) ...[
                      Icon(widget.prefixIcon, size: 16, color: enabled ? c.textSubtle : c.textDisabled),
                      const SizedBox(width: UiSpace.md),
                    ],
                    Expanded(
                      child: DefaultTextStyle.merge(
                        style: fieldTextStyle(context, widget.size, enabled: enabled),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        child: widget.child,
                      ),
                    ),
                    IconTheme.merge(
                      data: IconThemeData(size: 16, color: enabled ? c.textSubtle : c.textDisabled),
                      child: Row(mainAxisSize: MainAxisSize.min, children: widget.trailing),
                    ),
                  ],
                ),
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
