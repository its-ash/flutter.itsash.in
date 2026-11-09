part of 'ui_selection.dart';

/// Look of an unselected [UiChip]. Selected chips always use the accent tint.
enum UiChipVariant {
  /// Surface fill with a 1 px border.
  outline,

  /// Tinted fill from the chip's status, no border.
  soft,

  /// Solid fill from the chip's status.
  filled,
}

/// Pill chip for tags, filters and choices.
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
    this.variant = UiChipVariant.outline,
    this.enabled = true,
    this.showCheck = true,
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
    UiSize.sm => 28,
    UiSize.md => 34,
    UiSize.lg => 40,
  };

  double get _hPad => switch (size) {
    UiSize.sm => UiSpace.sm + 2,
    UiSize.md => UiSpace.md,
    UiSize.lg => UiSpace.lg,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = c.tone(status);
    final iconSize = size.iconSize - 2;
    final tap = enabled ? onTap : null;

    return _Pressable(
      onTap: tap,
      builder: (context, state) {
        final (Color bg, Color fg, Color border) = switch ((selected, variant)) {
          (true, UiChipVariant.filled) => (c.accent, c.onAccent, c.accent),
          (true, _) => (c.accentSoft, c.onAccentSoft, c.accent),
          (false, UiChipVariant.outline) => (
            state.hovered || state.pressed ? c.surfaceMuted : c.surface,
            status == UiStatus.neutral ? c.text : tone.onSoft,
            status == UiStatus.neutral ? (state.hovered ? c.borderStrong : c.border) : tone.color,
          ),
          (false, UiChipVariant.soft) => (tone.soft, tone.onSoft, tone.soft),
          (false, UiChipVariant.filled) => (tone.color, tone.onColor, tone.color),
        };
        final duration = context.motion(UiMotion.fast);

        Widget? leading;
        if (avatar != null) {
          leading = SizedBox.square(
            dimension: _height - 10,
            child: ClipOval(child: avatar),
          );
        } else if (icon != null) {
          leading = Icon(icon, size: iconSize, color: fg);
        }

        final content = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading, const SizedBox(width: UiSpace.xs + 2)],
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
                  fontSize: size.fontSize - 1,
                  fontWeight: FontWeight.w500,
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
                  start: leading is SizedBox ? 4 : _hPad,
                  end: onDeleted != null ? _hPad - 6 : _hPad,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: UiRadius.all(UiRadius.full),
                  border: Border.all(color: border),
                  boxShadow: _focusRing(c, state.focused),
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
