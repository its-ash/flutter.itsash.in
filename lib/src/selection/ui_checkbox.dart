part of 'ui_selection.dart';

/// Rounded-square checkbox with an animated check mark, plus an optional
/// label and description. The whole row is tappable.
///
/// ```dart
/// UiCheckbox(agree, label: 'I agree', onChanged: (v) => setState(() => agree = v!))
/// ```
class UiCheckbox extends StatelessWidget {
  const UiCheckbox(this.value, {super.key, this.onChanged, this.label, this.description, this.tristate = false})
    : assert(tristate || value != null, 'value can only be null when tristate is true');

  /// Checked state. `null` shows a dash (only with [tristate]).
  final bool? value;

  /// Called with the next value. Null disables the checkbox.
  final ValueChanged<bool?>? onChanged;

  final String? label;
  final String? description;

  /// When true, taps cycle false → true → null → false.
  final bool tristate;

  /// The value after one tap.
  static bool? next(bool? value, {bool tristate = false}) => switch (value) {
    false => true,
    true => tristate ? null : false,
    null => false,
  };

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return MergeSemantics(
      child: Semantics(
        checked: value == true,
        mixed: tristate && value == null,
        enabled: enabled,
        child: _Pressable(
          onTap: enabled ? () => onChanged!(next(value, tristate: tristate)) : null,
          builder: (context, state) => _LabeledRow(
            control: _CheckboxMark(value: value, state: state),
            controlHeight: _CheckboxMark.size,
            enabled: enabled,
            label: label,
            description: description,
          ),
        ),
      ),
    );
  }
}

/// A group of checkboxes that edits a `Set` of values.
///
/// ```dart
/// UiCheckboxGroup(values: picked, options: opts, onChanged: (s) => setState(() => picked = s))
/// ```
class UiCheckboxGroup<T> extends StatelessWidget {
  const UiCheckboxGroup({
    super.key,
    required this.values,
    required this.options,
    this.onChanged,
    this.direction = Axis.vertical,
  });

  /// Currently checked values.
  final Set<T> values;
  final List<UiChoice<T>> options;

  /// Called with a new set. Null disables the group.
  final ValueChanged<Set<T>>? onChanged;

  /// Vertical list or horizontal wrap.
  final Axis direction;

  @override
  Widget build(BuildContext context) {
    final children = [
      for (final o in options)
        UiCheckbox(
          values.contains(o.value),
          label: o.label,
          description: o.description,
          onChanged: onChanged == null || !o.enabled
              ? null
              : (v) {
                  final next = {...values};
                  v == true ? next.add(o.value) : next.remove(o.value);
                  onChanged!(next);
                },
        ),
    ];
    return _groupLayout(direction, children);
  }
}

/// Lays out group items in a column or a wrap.
Widget _groupLayout(Axis direction, List<Widget> children) => direction == Axis.vertical
    ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: children)
    : Wrap(spacing: UiSpace.lg, crossAxisAlignment: WrapCrossAlignment.center, children: children);

class _CheckboxMark extends StatelessWidget {
  const _CheckboxMark({required this.value, required this.state});

  static const double size = 20;

  final bool? value;
  final _Interaction state;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedScale(
      scale: state.pressed ? 0.9 : 1,
      duration: context.motion(UiMotion.fast),
      curve: UiMotion.standard,
      child: DecoratedBox(
        decoration: BoxDecoration(borderRadius: UiRadius.all(UiRadius.xs), boxShadow: _focusRing(c, state.focused)),
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: value == false ? 0 : 1),
          duration: context.motion(UiMotion.normal),
          curve: UiMotion.standard,
          builder: (context, t, _) => CustomPaint(
            size: const Size.square(size),
            painter: _CheckPainter(
              t: t,
              dash: value == null,
              background: c.surface,
              border: state.hovered ? c.textSubtle : c.borderStrong,
              fill: c.accent,
              mark: c.onAccent,
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter({
    required this.t,
    required this.dash,
    required this.background,
    required this.border,
    required this.fill,
    required this.mark,
  });

  final double t;
  final bool dash;
  final Color background;
  final Color border;
  final Color fill;
  final Color mark;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(UiRadius.xs));
    canvas.drawRRect(rrect, Paint()..color = Color.lerp(background, fill, t)!);
    canvas.drawRRect(
      rrect.deflate(0.75),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Color.lerp(border, fill, t)!,
    );
    if (t <= 0) return;
    final pen = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = mark;
    final w = size.width;
    final h = size.height;
    if (dash) {
      final half = 0.22 * w * t;
      canvas.drawLine(Offset(w / 2 - half, h / 2), Offset(w / 2 + half, h / 2), pen);
      return;
    }
    final path = Path()
      ..moveTo(0.27 * w, 0.52 * h)
      ..lineTo(0.43 * w, 0.67 * h)
      ..lineTo(0.74 * w, 0.35 * h);
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * t), pen);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter old) =>
      old.t != t ||
      old.dash != dash ||
      old.background != background ||
      old.border != border ||
      old.fill != fill ||
      old.mark != mark;
}
