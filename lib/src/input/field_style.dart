// Internal helpers shared by the input group. Not exported from the barrel.
import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Height of a field of [size]: 40 / 48 / 56, same as buttons.
double fieldHeight(UiSize size) => switch (size) {
  UiSize.sm => 40,
  UiSize.md => 48,
  UiSize.lg => 56,
};

/// Corner radius of a field. With an error the bottom corners are square so
/// the danger caption strip of `UiFieldLabel` joins the field.
BorderRadius fieldRadius({bool hasError = false, double radius = UiRadius.md}) =>
    hasError ? BorderRadius.vertical(top: Radius.circular(radius)) : UiRadius.all(radius);

/// Wrapper kept for every field. Fields are outline-only (see
/// [fieldDecoration]): no hover ring and no tinted focus glow, the focused
/// state is just the 1.5 px Primary outline drawn by the field itself.
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
  @override
  Widget build(BuildContext context) => widget.child;
}

/// Fill inside every field: the page color (white in light mode, near-black
/// in dark mode), never a tint.
Color fieldFill(UiColors c) => c.background;

/// Outline of a field for its state.
BorderSide fieldBorder(UiColors c, {bool focused = false, bool hasError = false, bool enabled = true}) {
  if (hasError) return BorderSide(color: c.danger, width: focused ? 1.5 : 1);
  if (!enabled) return BorderSide(color: c.border);
  if (focused) return BorderSide(color: c.accent, width: 1.5);
  return BorderSide(color: c.borderStrong);
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
  OutlineInputBorder border(BorderSide side) => OutlineInputBorder(borderRadius: shape, borderSide: side);
  // Single-line fields center the text in [height]; multiline ones pad it.
  final vertical = multiline ? UiSpace.md : ((height - 22) / 2).floorToDouble();
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: enabled ? c.textSubtle : c.textDisabled, fontSize: size.fontSize),
    hintMaxLines: multiline ? null : 1,
    filled: true,
    fillColor: fieldFill(c),
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
    border: border(fieldBorder(c, hasError: hasError)),
    enabledBorder: border(fieldBorder(c, hasError: hasError)),
    disabledBorder: border(fieldBorder(c, enabled: false)),
    focusedBorder: border(fieldBorder(c, focused: true, hasError: hasError)),
    errorBorder: border(fieldBorder(c, hasError: true)),
    focusedErrorBorder: border(fieldBorder(c, focused: true, hasError: true)),
  );
}

/// Text style for the typed value of a field of [size].
TextStyle fieldTextStyle(BuildContext context, UiSize size, {bool enabled = true}) {
  final c = context.colors;
  return (context.text.bodyMedium ?? const TextStyle()).copyWith(
    fontSize: size.fontSize,
    height: 22 / 15,
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
    final side = fieldBorder(c, focused: _focused, hasError: widget.hasError, enabled: enabled);
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
          decoration: BoxDecoration(color: fieldFill(c), borderRadius: radius, border: Border.fromBorderSide(side)),
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
