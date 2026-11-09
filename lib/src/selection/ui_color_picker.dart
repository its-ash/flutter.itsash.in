part of 'ui_selection.dart';

/// Row or grid of color swatches. The selected swatch gets a ring and a
/// check mark.
///
/// ```dart
/// UiColorPicker(value: color, colors: context.colors.chart, onChanged: (c) => setState(() => color = c))
/// ```
class UiColorPicker extends StatelessWidget {
  const UiColorPicker({
    super.key,
    required this.value,
    required this.colors,
    this.onChanged,
    this.size = UiSize.md,
    this.labels,
    this.spacing = UiSpace.xs,
  });

  /// Selected color, or null for none.
  final Color? value;

  /// Swatches to show, in order.
  final List<Color> colors;

  /// Called with the tapped color. Null disables the picker.
  final ValueChanged<Color>? onChanged;
  final UiSize size;

  /// Screen reader names for the swatches, in the same order as [colors].
  final List<String>? labels;

  /// Gap between swatches.
  final double spacing;

  double get _dot => switch (size) {
    UiSize.sm => 26,
    UiSize.md => 32,
    UiSize.lg => 40,
  };

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return Opacity(
      opacity: enabled ? 1 : _kDisabledOpacity,
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (var i = 0; i < colors.length; i++)
            _Swatch(
              color: colors[i],
              diameter: _dot,
              selected: value != null && colors[i].toARGB32() == value!.toARGB32(),
              label: labels != null && i < labels!.length ? labels![i] : 'Color ${i + 1}',
              onTap: enabled ? () => onChanged!(colors[i]) : null,
            ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.color,
    required this.diameter,
    required this.selected,
    required this.label,
    required this.onTap,
  });

  final Color color;
  final double diameter;
  final bool selected;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Pick a check color that reads on the swatch: the near-white or the
    // near-black color of the current palette.
    final light = c.isDark ? c.text : c.surface;
    final dark = c.isDark ? c.background : c.text;
    final mark = ThemeData.estimateBrightnessForColor(color) == Brightness.dark ? light : dark;
    final duration = context.motion(UiMotion.normal);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: _Pressable(
        onTap: onTap,
        builder: (context, state) => AnimatedContainer(
          duration: duration,
          curve: UiMotion.standard,
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: selected ? color : c.border.withValues(alpha: 0), width: 2),
            boxShadow: _focusRing(c, state.focused),
          ),
          child: AnimatedScale(
            scale: state.pressed ? 0.9 : (state.hovered && !selected ? 1.06 : 1),
            duration: context.motion(UiMotion.fast),
            curve: UiMotion.standard,
            child: Container(
              width: diameter,
              height: diameter,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: c.text.withValues(alpha: 0.08)),
              ),
              child: AnimatedScale(
                scale: selected ? 1 : 0,
                duration: duration,
                curve: UiMotion.bounce,
                child: Icon(Icons.check_rounded, size: diameter * 0.5, color: mark),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
