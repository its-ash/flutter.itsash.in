part of 'ui_selection.dart';

/// Look of an unselected [UiChip]. Selected chips are always solid Primary
/// with a bold label (Figma "control", style=solid).
enum UiChipVariant {
  /// Transparent with a 1 px outline (Figma "ghost" control).
  outline,

  /// Tinted fill from the chip's status, no border (Figma "dim" control for
  /// the neutral status).
  soft,

  /// Solid fill from the chip's status.
  filled,
}

/// Pill chip for tags, filters and choices: 32 / 40 / 48 high (sm / md / lg).
/// Unselected chips are a soft Overlay fill; selected ones solid Primary.
///
/// With [onTap] it is a toggle or action; with [onDeleted] it shows a remove
/// button. With neither it is a static label. Set [enabled] to false to grey
/// it out.
///
/// ```dart
/// UiChip('Design', selected: on, onTap: () => setState(() => on = !on))
/// UiChip('flutter', onDeleted: () => remove('flutter'))
/// ```
class UiChip extends StatelessWidget {
  const UiChip(
    this.label, {
    super.key,
    this.icon,
    this.avatar,
    this.selected = false,
    this.onTap,
    this.onDeleted,
    this.status = UiStatus.neutral,
    this.size = UiSize.md,
    this.variant = UiChipVariant.soft,
    this.enabled = true,
    this.showCheck = false,
  });

  final String label;

  /// Leading icon.
  final IconData? icon;

  /// Leading widget, such as a small avatar image. Clipped to a circle.
  final Widget? avatar;

  /// Selected chips use the accent tint and border.
  final bool selected;

  final VoidCallback? onTap;

  /// Shows a remove button that calls this.
  final VoidCallback? onDeleted;

  /// Color of the unselected chip (used by [UiChipVariant.soft] and [UiChipVariant.filled]).
  final UiStatus status;
  final UiSize size;
  final UiChipVariant variant;

  /// False greys the chip out and blocks taps.
  final bool enabled;

  /// Shows a check mark when [selected] and there is no [icon] or [avatar].
  final bool showCheck;

  double get _height => switch (size) {
    UiSize.sm => 32,
    UiSize.md => 40,
    UiSize.lg => 48,
  };

  double get _hPad => switch (size) {
    UiSize.sm => 14,
    UiSize.md => 18,
    UiSize.lg => 22,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = c.tone(status);
    final neutral = status == UiStatus.neutral;
    final iconSize = size == UiSize.sm ? 14.0 : 18.0;
    final tap = enabled ? onTap : null;
    const clear = Colors.transparent;

    return _Pressable(
      onTap: tap,
      builder: (context, state) {
        final highlight = state.hovered || state.pressed;
        final (Color bg, Color fg, Color border) = switch ((selected, variant)) {
          (true, _) => (c.accent, c.onAccent, clear),
          (false, UiChipVariant.outline) => (
            highlight ? c.surfaceMuted : clear,
            neutral ? (highlight ? c.text : c.gray(7)) : tone.onSoft,
            neutral ? (highlight ? c.textSubtle : c.borderStrong) : tone.color,
          ),
          (false, UiChipVariant.soft) => (tone.soft, neutral ? c.text : tone.onSoft, clear),
          (false, UiChipVariant.filled) => (tone.color, tone.onColor, clear),
        };
        // The design's hover stroke: 4 px, inside the pill.
        final ring = !highlight
            ? null
            : selected
            ? c.accent.withValues(alpha: 0.5)
            : variant == UiChipVariant.outline
            ? null
            : c.gray(5).withValues(alpha: 0.4);
        final duration = context.motion(UiMotion.fast);

        Widget? leading;
        if (avatar != null) {
          leading = SizedBox.square(
            dimension: _height - 4,
            child: ClipOval(child: avatar),
          );
        } else if (icon != null) {
          leading = Icon(icon, size: iconSize, color: fg);
        }

        final content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading, const SizedBox(width: UiSpace.xs)],
            if (leading == null && showCheck)
              AnimatedSize(
                duration: duration,
                curve: UiMotion.standard,
                child: selected
                    ? Padding(
                        padding: const EdgeInsetsDirectional.only(end: UiSpace.xs),
                        child: Icon(Icons.check_rounded, size: iconSize, color: fg),
                      )
                    : const SizedBox(height: 0),
              ),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.text.labelLarge?.copyWith(
                  color: fg,
                  fontSize: size.fontSize,
                  height: 1.3,
                  fontWeight: selected ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
            ),
            if (onDeleted != null) ...[
              const SizedBox(width: UiSpace.xxs),
              Semantics(
                button: true,
                label: 'Remove $label',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: enabled ? onDeleted : null,
                  child: Padding(
                    padding: const EdgeInsets.all(UiSpace.xxs),
                    child: Icon(Icons.close_rounded, size: iconSize, color: fg.withValues(alpha: 0.7)),
                  ),
                ),
              ),
            ],
          ],
        );

        return Semantics(
          button: tap != null,
          selected: selected,
          enabled: enabled,
          child: Opacity(
            opacity: enabled ? 1 : _kDisabledOpacity,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: AnimatedContainer(
                duration: duration,
                curve: UiMotion.standard,
                height: _height,
                padding: EdgeInsetsDirectional.only(
                  start: leading is SizedBox ? UiSpace.xxs : _hPad,
                  end: onDeleted != null ? UiSpace.xs : _hPad,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: UiRadius.all(UiRadius.full),
                  border: Border.all(color: border),
                  boxShadow: _focusRing(c, state.focused),
                ),
                foregroundDecoration: ring == null
                    ? null
                    : BoxDecoration(
                        borderRadius: UiRadius.all(UiRadius.full),
                        border: Border.all(color: ring, width: 4),
                      ),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Lays out chips in a wrapping block, or in one horizontally scrolling row.
///
/// ```dart
/// UiChipGroup(children: [for (final t in tags) UiChip(t)])
/// ```
class UiChipGroup extends StatelessWidget {
  const UiChipGroup({
    super.key,
    required this.children,
    this.scrollable = false,
    this.spacing = UiSpace.sm,
    this.runSpacing = UiSpace.sm,
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> children;

  /// One scrolling row instead of wrapping lines.
  final bool scrollable;

  /// Gap between chips.
  final double spacing;

  /// Gap between wrapped lines.
  final double runSpacing;

  /// Padding around the chips (inside the scroll view when [scrollable]).
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (!scrollable) {
      return Padding(
        padding: padding,
        child: Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: children,
        ),
      );
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(width: spacing), children[i]],
        ],
      ),
    );
  }
}

/// Multi-select filter chips built from [UiChoice] options.
///
/// ```dart
/// UiFilterChips(options: tags, values: picked, onChanged: (s) => setState(() => picked = s))
/// ```
class UiFilterChips<T> extends StatelessWidget {
  const UiFilterChips({
    super.key,
    required this.options,
    required this.values,
    this.onChanged,
    this.scrollable = false,
    this.size = UiSize.md,
  });

  final List<UiChoice<T>> options;

  /// Currently selected values.
  final Set<T> values;

  /// Called with a new set. Null disables the chips.
  final ValueChanged<Set<T>>? onChanged;

  /// One scrolling row instead of wrapping lines.
  final bool scrollable;
  final UiSize size;

  @override
  Widget build(BuildContext context) => UiChipGroup(
    scrollable: scrollable,
    children: [
      for (final o in options)
        UiChip(
          o.label,
          icon: o.icon,
          size: size,
          selected: values.contains(o.value),
          enabled: onChanged != null && o.enabled,
          onTap: () {
            final next = {...values};
            if (!next.remove(o.value)) next.add(o.value);
            onChanged?.call(next);
          },
        ),
    ],
  );
}

/// Single-select chips built from [UiChoice] options.
///
/// ```dart
/// UiChoiceChips(options: sizes, value: size, onChanged: (v) => setState(() => size = v))
/// ```
class UiChoiceChips<T> extends StatelessWidget {
  const UiChoiceChips({
    super.key,
    required this.options,
    required this.value,
    this.onChanged,
    this.scrollable = false,
    this.size = UiSize.md,
  });

  final List<UiChoice<T>> options;

  /// Selected value, or null for none.
  final T? value;

  /// Called with the tapped value. Null disables the chips.
  final ValueChanged<T>? onChanged;

  /// One scrolling row instead of wrapping lines.
  final bool scrollable;
  final UiSize size;

  @override
  Widget build(BuildContext context) => UiChipGroup(
    scrollable: scrollable,
    children: [
      for (final o in options)
        UiChip(
          o.label,
          icon: o.icon,
          size: size,
          showCheck: false,
          selected: o.value == value,
          enabled: onChanged != null && o.enabled,
          onTap: () => onChanged?.call(o.value),
        ),
    ],
  );
}
