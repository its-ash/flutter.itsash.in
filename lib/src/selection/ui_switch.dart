part of 'ui_selection.dart';

/// Switch with an animated white thumb: Primary track when on, gray-3 when
/// off. Not in the Figma kit; it uses the same tokens as the checkbox.
/// Optional label and description. The whole row is tappable.
///
/// ```dart
/// UiSwitch(wifi, label: 'Wi-Fi', onChanged: (v) => setState(() => wifi = v))
/// ```
class UiSwitch extends StatelessWidget {
  const UiSwitch(this.value, {super.key, this.onChanged, this.label, this.description});

  final bool value;

  /// Called with the new value. Null disables the switch.
  final ValueChanged<bool>? onChanged;

  final String? label;
  final String? description;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return MergeSemantics(
      child: Semantics(
        toggled: value,
        enabled: enabled,
        child: _Pressable(
          onTap: enabled ? () => onChanged!(!value) : null,
          builder: (context, state) => _LabeledRow(
            control: _SwitchTrack(value: value, state: state),
            controlHeight: _SwitchTrack.height,
            enabled: enabled,
            label: label,
            description: description,
          ),
        ),
      ),
    );
  }
}

class _SwitchTrack extends StatelessWidget {
  const _SwitchTrack({required this.value, required this.state});

  static const double width = 46;
  static const double height = 28;
  static const double _pad = 3;
  static const double _thumb = height - _pad * 2;

  final bool value;
  final _Interaction state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final thumbColor = c.isDark ? c.text : c.background;
    final off = state.hovered ? c.gray(4) : c.gray(3);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: value ? 1 : 0),
      duration: context.motion(UiMotion.normal),
      curve: UiMotion.standard,
      builder: (context, t, _) => Container(
        width: width,
        height: height,
        padding: const EdgeInsets.all(_pad),
        decoration: BoxDecoration(
          color: Color.lerp(off, c.accent, t),
          borderRadius: UiRadius.all(UiRadius.full),
          boxShadow: _focusRing(c, state.focused),
        ),
        child: Align(
          alignment: AlignmentDirectional(-1 + 2 * t, 0),
          child: AnimatedContainer(
            duration: context.motion(UiMotion.fast),
            curve: UiMotion.standard,
            width: state.pressed ? _thumb + 4 : _thumb,
            height: _thumb,
            decoration: BoxDecoration(
              color: thumbColor,
              borderRadius: UiRadius.all(UiRadius.full),
              boxShadow: context.shadowSm,
            ),
          ),
        ),
      ),
    );
  }
}
