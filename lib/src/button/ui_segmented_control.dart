part of 'ui_button.dart';

/// One option of a [UiSegmentedControl] or [UiToggleGroup]: a value with a
/// label, an icon, or both.
class UiSegment<T> {
  const UiSegment(this.value, {this.label, this.icon, this.tooltip})
    : assert(label != null || icon != null, 'UiSegment needs a label or an icon');

  final T value;
  final String? label;
  final IconData? icon;

  /// Tooltip for icon-only options.
  final String? tooltip;
}

/// iOS-style segmented control with a sliding pill on the selected segment.
///
/// ```dart
/// UiSegmentedControl([UiSegment('day', label: 'Day'), UiSegment('week', label: 'Week')],
///     value: range, onChanged: (v) => setState(() => range = v))
/// ```
class UiSegmentedControl<T> extends StatelessWidget {
  const UiSegmentedControl(
    this.segments, {
    super.key,
    required this.value,
    this.onChanged,
    this.size = UiSize.md,
    this.expand = false,
  });

  final List<UiSegment<T>> segments;

  /// Selected value. If no segment matches, no pill is shown.
  final T value;

  /// Called with the tapped segment's value. Null disables the control.
  final ValueChanged<T>? onChanged;

  final UiSize size;

  /// Fills the available width. Otherwise every segment is as wide as the widest label.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final n = segments.length;
    final index = segments.indexWhere((s) => s.value == value);
    const inset = UiSpace.xxs;
    final outerRadius = size == UiSize.sm ? UiRadius.sm : UiRadius.md;
    final innerRadius = outerRadius - inset;
    final enabled = onChanged != null;

    final row = Row(
      children: [
        for (var i = 0; i < n; i++)
          Expanded(
            child: _SegmentItem(
              segment: segments[i],
              selected: i == index,
              size: size,
              radius: innerRadius,
              onTap: enabled
                  ? () {
                      if (i != index) onChanged!(segments[i].value);
                    }
                  : null,
            ),
          ),
      ],
    );

    final body = Container(
      height: size.height,
      padding: const EdgeInsets.all(inset),
      decoration: BoxDecoration(
        color: c.surfaceMuted,
        borderRadius: UiRadius.all(outerRadius),
        border: Border.all(color: c.border),
      ),
      child: Stack(
        children: [
          if (index >= 0)
            Positioned.fill(
              child: AnimatedAlign(
                alignment: AlignmentDirectional(n == 1 ? 0 : -1 + 2 * index / (n - 1), 0),
                duration: context.motion(UiMotion.normal),
                curve: UiMotion.emphasized,
                child: FractionallySizedBox(
                  widthFactor: 1 / n,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: enabled ? (c.isDark ? c.surfaceRaised : c.surface) : c.surfaceMuted,
                      borderRadius: UiRadius.all(innerRadius),
                      border: Border.all(color: c.isDark ? c.borderStrong : c.border),
                      boxShadow: enabled ? context.shadowSm : null,
                    ),
                  ),
                ),
              ),
            ),
          row,
        ],
      ),
    );
    return Semantics(container: true, explicitChildNodes: true, child: expand ? body : IntrinsicWidth(child: body));
  }
}

class _SegmentItem extends StatelessWidget {
  const _SegmentItem({
    required this.segment,
    required this.selected,
    required this.size,
    required this.radius,
    required this.onTap,
  });

  final UiSegment<Object?> segment;
  final bool selected;
  final UiSize size;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final label = segment.label;
    final icon = segment.icon;
    return _Pressable(
      onTap: onTap,
      selected: selected,
      pressScale: 0.96,
      focusRadius: radius,
      tooltip: label == null ? segment.tooltip : null,
      builder: (context, states) {
        final fg = states.contains(WidgetState.disabled)
            ? c.textDisabled
            : selected || states.contains(WidgetState.hovered)
            ? c.text
            : c.textMuted;
        final style = (context.text.labelLarge ?? const TextStyle()).copyWith(
          fontSize: size.fontSize,
          color: fg,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        );
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: size.padding - UiSpace.xs),
            child: IconTheme.merge(
              data: IconThemeData(color: fg, size: size.iconSize),
              child: AnimatedDefaultTextStyle(
                style: style,
                duration: context.motion(UiMotion.fast),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) Icon(icon),
                    if (icon != null && label != null) const SizedBox(width: UiSpace.xs + UiSpace.xxs),
                    if (label != null) Flexible(child: Text(label)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
