part of 'ui_selection.dart';

/// Single radio button with an optional label and description. Selected
/// when [value] equals [groupValue]. Prefer [UiRadioGroup] for a list.
///
/// ```dart
/// UiRadio('a', groupValue: pick, label: 'Option A', onChanged: (v) => setState(() => pick = v))
/// ```
class UiRadio<T> extends StatelessWidget {
  const UiRadio(this.value, {super.key, required this.groupValue, this.onChanged, this.label, this.description});

  /// Value of this radio.
  final T value;

  /// Value currently selected in the group.
  final T? groupValue;

  /// Called with [value] when tapped. Null disables the radio.
  final ValueChanged<T>? onChanged;

  final String? label;
  final String? description;

  bool get _selected => value == groupValue;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return MergeSemantics(
      child: Semantics(
        checked: _selected,
        inMutuallyExclusiveGroup: true,
        enabled: enabled,
        child: _Pressable(
          onTap: enabled ? () => onChanged!(value) : null,
          builder: (context, state) => _LabeledRow(
            control: _RadioMark(selected: _selected, state: state),
            controlHeight: _RadioMark.size,
            enabled: enabled,
            label: label,
            description: description,
          ),
        ),
      ),
    );
  }
}

/// A list of radios built from [UiChoice] options.
///
/// ```dart
/// UiRadioGroup(value: size, options: sizes, onChanged: (v) => setState(() => size = v))
/// ```
class UiRadioGroup<T> extends StatelessWidget {
  const UiRadioGroup({
    super.key,
    required this.value,
    required this.options,
    this.onChanged,
    this.direction = Axis.vertical,
  });

  /// Selected value, or null for none.
  final T? value;
  final List<UiChoice<T>> options;

  /// Called with the picked value. Null disables the group.
  final ValueChanged<T>? onChanged;

  /// Vertical list or horizontal wrap.
  final Axis direction;

  @override
  Widget build(BuildContext context) => Semantics(
    container: true,
    child: _groupLayout(direction, [
      for (final o in options)
        UiRadio<T>(
          o.value,
          groupValue: value,
          label: o.label,
          description: o.description,
          onChanged: o.enabled ? onChanged : null,
        ),
    ]),
  );
}

class _RadioMark extends StatelessWidget {
  const _RadioMark({required this.selected, required this.state});

  static const double size = 20;

  final bool selected;
  final _Interaction state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final border = state.hovered ? c.textSubtle : c.borderStrong;
    return AnimatedScale(
      scale: state.pressed ? 0.9 : 1,
      duration: context.motion(UiMotion.fast),
      curve: UiMotion.standard,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: selected ? 1 : 0),
        duration: context.motion(UiMotion.normal),
        curve: UiMotion.standard,
        builder: (context, t, _) => Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color.lerp(c.surface, c.accent, t),
            border: Border.all(color: Color.lerp(border, c.accent, t)!, width: 1.5),
            boxShadow: _focusRing(c, state.focused),
          ),
          child: Container(
            width: 8 * t,
            height: 8 * t,
            decoration: BoxDecoration(shape: BoxShape.circle, color: c.onAccent),
          ),
        ),
      ),
    );
  }
}
