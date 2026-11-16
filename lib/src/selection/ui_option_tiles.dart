part of 'ui_selection.dart';

/// Single-select row of rounded square tiles for short values: shoe sizes,
/// amounts, durations, quantities (the Nova "Select size" row).
///
/// Unselected tiles are a soft Overlay fill, the selected one solid Primary,
/// and disabled options show faded text. Labels should be 1 to 4 characters;
/// longer ones widen the tile.
///
/// ```dart
/// UiOptionTiles(
///   options: const [UiChoice(7, '7'), UiChoice(8, '8'), UiChoice(10, '10', enabled: false)],
///   value: size,
///   onChanged: (v) => setState(() => size = v),
/// )
/// ```
class UiOptionTiles<T> extends StatelessWidget {
  const UiOptionTiles({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.size = UiSize.md,
    this.scrollable = true,
    this.spacing = UiSpace.sm,
  });

  final List<UiChoice<T>> options;

  /// Selected value, or null for none.
  final T? value;

  /// Called with the tapped value. Null disables every tile.
  final ValueChanged<T>? onChanged;

  /// Tile size: 40 / 48 / 56 square.
  final UiSize size;

  /// One horizontally scrolling row (default) instead of wrapping lines.
  final bool scrollable;

  /// Gap between tiles.
  final double spacing;

  double get _tile => switch (size) {
    UiSize.sm => 40,
    UiSize.md => 48,
    UiSize.lg => 56,
  };

  @override
  Widget build(BuildContext context) {
    final tiles = [
      for (final o in options)
        _OptionTile(
          label: o.label,
          extent: _tile,
          fontSize: size.fontSize,
          selected: o.value == value,
          onTap: onChanged != null && o.enabled ? () => onChanged!(o.value) : null,
        ),
    ];
    if (!scrollable) return Wrap(spacing: spacing, runSpacing: spacing, children: tiles);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[if (i > 0) SizedBox(width: spacing), tiles[i]],
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.extent,
    required this.fontSize,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final double extent;
  final double fontSize;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onTap != null;
    return Semantics(
      button: true,
      selected: selected,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: _Pressable(
        onTap: onTap,
        builder: (context, state) {
          final bg = selected
              ? c.accent
              : state.hovered || state.pressed
              ? Color.alphaBlend(c.surfaceMuted, c.surfaceMuted)
              : c.surfaceMuted;
          final fg = selected
              ? c.onAccent
              : enabled
              ? c.text
              : c.textDisabled;
          return AnimatedScale(
            scale: state.pressed ? 0.94 : 1,
            duration: context.motion(UiMotion.fast),
            curve: UiMotion.standard,
            child: AnimatedContainer(
              duration: context.motion(UiMotion.fast),
              curve: UiMotion.standard,
              height: extent,
              constraints: BoxConstraints(minWidth: extent),
              padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: enabled || selected ? bg : c.surfaceMuted.withValues(alpha: c.surfaceMuted.a * 0.5),
                borderRadius: UiRadius.all(UiRadius.md),
                boxShadow: _focusRing(c, state.focused),
              ),
              child: Text(
                label,
                maxLines: 1,
                style: context.text.labelLarge?.copyWith(
                  fontSize: fontSize,
                  color: fg,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
