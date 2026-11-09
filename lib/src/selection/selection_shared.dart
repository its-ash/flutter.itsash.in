part of 'ui_selection.dart';

/// Opacity of a disabled control.
const double _kDisabledOpacity = 0.45;

/// Line height of a `bodyMedium` label (14 * 1.5).
const double _kLabelLineHeight = 21;

/// Interaction state of a [_Pressable].
@immutable
class _Interaction {
  const _Interaction({this.hovered = false, this.focused = false, this.pressed = false});

  final bool hovered;
  final bool focused;
  final bool pressed;
}

/// Tappable, focusable, hoverable region. Enter/space activate it.
/// A null [onTap] disables it.
class _Pressable extends StatefulWidget {
  const _Pressable({required this.onTap, required this.builder});

  final VoidCallback? onTap;
  final Widget Function(BuildContext context, _Interaction state) builder;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _hovered = false;
  bool _focused = false;
  bool _pressed = false;

  void _set(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return FocusableActionDetector(
      enabled: enabled,
      mouseCursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      onShowFocusHighlight: (v) => _set(() => _focused = v),
      onShowHoverHighlight: (v) => _set(() => _hovered = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            widget.onTap?.call();
            return null;
          },
        ),
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: enabled ? (_) => _set(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => _set(() => _pressed = false) : null,
        onTapCancel: enabled ? () => _set(() => _pressed = false) : null,
        child: widget.builder(
          context,
          _Interaction(hovered: enabled && _hovered, focused: enabled && _focused, pressed: enabled && _pressed),
        ),
      ),
    );
  }
}

/// Soft accent ring shown around a focused control.
List<BoxShadow>? _focusRing(UiColors c, bool focused) =>
    focused ? [BoxShadow(color: c.accent.withValues(alpha: 0.35), spreadRadius: 3)] : null;

/// A control with an optional label and description to its right.
/// Always at least 40 x 40 so it is easy to tap.
class _LabeledRow extends StatelessWidget {
  const _LabeledRow({
    required this.control,
    required this.controlHeight,
    required this.enabled,
    this.label,
    this.description,
  });

  final Widget control;
  final double controlHeight;
  final bool enabled;
  final String? label;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasText = label != null || description != null;
    final dimmedControl = Opacity(opacity: enabled ? 1 : _kDisabledOpacity, child: control);
    if (!hasText) {
      return ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        child: Align(widthFactor: 1, heightFactor: 1, child: dimmedControl),
      );
    }
    final textTop = controlHeight > _kLabelLineHeight ? (controlHeight - _kLabelLineHeight) / 2 : 0.0;
    final controlTop = controlHeight < _kLabelLineHeight ? (_kLabelLineHeight - controlHeight) / 2 : 0.0;
    final text = Padding(
      padding: EdgeInsets.only(top: textTop),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label != null)
            Text(
              label!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: enabled ? c.text : c.textDisabled,
              ),
            ),
          if (description != null)
            Text(
              description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: context.text.bodySmall?.copyWith(color: enabled ? c.textMuted : c.textDisabled),
            ),
        ],
      ),
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: 1,
        heightFactor: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
          child: LayoutBuilder(
            builder: (context, constraints) => Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: controlTop),
                  child: dimmedControl,
                ),
                const SizedBox(width: UiSpace.md),
                if (constraints.hasBoundedWidth) Flexible(child: text) else text,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Default number format for sliders: whole numbers without decimals.
String _formatNumber(double v) {
  if (v == v.roundToDouble()) return v.toStringAsFixed(0);
  return v.toStringAsFixed(v.abs() < 10 ? 2 : 1);
}
