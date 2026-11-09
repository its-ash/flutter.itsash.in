part of 'ui_selection.dart';

/// Grid of selectable cards (icon, title, description, trailing text such as
/// a price). For plan pickers and onboarding questions.
///
/// Single choice by default; use [UiChoiceCards.multi] to pick many.
///
/// ```dart
/// UiChoiceCards(options: plans, value: plan, onChanged: (v) => setState(() => plan = v))
/// UiChoiceCards.multi(options: goals, values: picked, onChanged: (s) => setState(() => picked = s))
/// ```
class UiChoiceCards<T> extends StatelessWidget {
  /// Single choice: one card is selected at a time.
  const UiChoiceCards({
    super.key,
    required this.options,
    required T? value,
    ValueChanged<T>? onChanged,
    this.columns,
    this.spacing = UiSpace.md,
  }) : multi = false,
       _value = value,
       _values = null,
       _onSingle = onChanged,
       _onMulti = null;

  /// Multiple choice: tapping a card adds or removes it from [values].
  const UiChoiceCards.multi({
    super.key,
    required this.options,
    required Set<T> values,
    ValueChanged<Set<T>>? onChanged,
    this.columns,
    this.spacing = UiSpace.md,
  }) : multi = true,
       _value = null,
       _values = values,
       _onSingle = null,
       _onMulti = onChanged;

  final List<UiChoice<T>> options;

  /// Cards per row. Null picks 1 on phones, 2 on tablets, 3 on desktop.
  /// Columns shrink so a card is never narrower than 140 px.
  final int? columns;

  /// Gap between cards.
  final double spacing;

  /// True when built with [UiChoiceCards.multi].
  final bool multi;

  final T? _value;
  final Set<T>? _values;
  final ValueChanged<T>? _onSingle;
  final ValueChanged<Set<T>>? _onMulti;

  bool get _enabled => multi ? _onMulti != null : _onSingle != null;

  bool _isSelected(T v) => multi ? _values!.contains(v) : _value == v;

  void _tap(T v) {
    if (!multi) return _onSingle!(v);
    final next = {..._values!};
    if (!next.remove(v)) next.add(v);
    _onMulti!(next);
  }

  @override
  Widget build(BuildContext context) {
    final int wanted = columns ?? context.responsive<int>(compact: 1, medium: 2, expanded: 3);
    return LayoutBuilder(
      builder: (context, constraints) {
        var cols = wanted < 1 ? 1 : wanted;
        if (constraints.hasBoundedWidth) {
          final fit = ((constraints.maxWidth + spacing) / (140 + spacing)).floor();
          if (fit < cols) cols = fit < 1 ? 1 : fit;
        }
        final rows = <Widget>[];
        for (var i = 0; i < options.length; i += cols) {
          final cells = <Widget>[];
          for (var j = 0; j < cols; j++) {
            if (j > 0) cells.add(SizedBox(width: spacing));
            final index = i + j;
            cells.add(Expanded(child: index < options.length ? _card(options[index]) : const SizedBox.shrink()));
          }
          if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
          rows.add(
            IntrinsicHeight(
              child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
            ),
          );
        }
        return Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
      },
    );
  }

  Widget _card(UiChoice<T> o) => _ChoiceCard(
    choice: o,
    selected: _isSelected(o.value),
    multi: multi,
    onTap: _enabled && o.enabled ? () => _tap(o.value) : null,
  );
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({required this.choice, required this.selected, required this.multi, required this.onTap});

  final UiChoice<Object?> choice;
  final bool selected;
  final bool multi;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onTap != null;
    final duration = context.motion(UiMotion.normal);
    return MergeSemantics(
      child: Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: !multi,
        enabled: enabled,
        child: Opacity(
          opacity: enabled ? 1 : _kDisabledOpacity,
          child: _Pressable(
            onTap: onTap,
            builder: (context, state) => AnimatedScale(
              scale: state.pressed ? 0.98 : 1,
              duration: context.motion(UiMotion.fast),
              curve: UiMotion.standard,
              child: AnimatedContainer(
                duration: duration,
                curve: UiMotion.standard,
                padding: const EdgeInsets.all(UiSpace.lg),
                decoration: BoxDecoration(
                  color: selected
                      ? c.accentSoft
                      : state.hovered
                      ? c.surfaceMuted
                      : c.surface,
                  borderRadius: UiRadius.all(UiRadius.lg),
                  border: Border.all(
                    color: selected
                        ? c.accent
                        : state.hovered
                        ? c.borderStrong
                        : c.border,
                  ),
                  boxShadow: _focusRing(c, state.focused),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (choice.icon != null) ...[
                      AnimatedContainer(
                        duration: duration,
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selected ? c.accent : c.surfaceMuted,
                          borderRadius: UiRadius.all(UiRadius.md),
                        ),
                        child: Icon(choice.icon, size: 20, color: selected ? c.onAccent : c.textMuted),
                      ),
                      const SizedBox(width: UiSpace.md),
                    ],
                    Expanded(child: _texts(context, c)),
                    const SizedBox(width: UiSpace.md),
                    _CardBadge(selected: selected, multi: multi),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _texts(BuildContext context, UiColors c) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              choice.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.text.titleSmall?.copyWith(color: selected ? c.onAccentSoft : c.text),
            ),
          ),
          if (choice.trailing != null) ...[
            const SizedBox(width: UiSpace.sm),
            Text(choice.trailing!, style: context.text.titleSmall?.copyWith(color: selected ? c.onAccentSoft : c.text)),
          ],
        ],
      ),
      if (choice.description != null) ...[
        const SizedBox(height: UiSpace.xxs),
        Text(
          choice.description!,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: context.text.bodySmall?.copyWith(color: c.textMuted),
        ),
      ],
    ],
  );
}

/// Check badge in the corner of a choice card: a circle for single choice,
/// a rounded square for multi choice.
class _CardBadge extends StatelessWidget {
  const _CardBadge({required this.selected, required this.multi});

  final bool selected;
  final bool multi;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final duration = context.motion(UiMotion.normal);
    return AnimatedContainer(
      duration: duration,
      curve: UiMotion.standard,
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: selected ? c.accent : c.surface,
        borderRadius: UiRadius.all(multi ? UiRadius.xs : UiRadius.full),
        border: Border.all(color: selected ? c.accent : c.borderStrong, width: 1.5),
      ),
      child: AnimatedScale(
        scale: selected ? 1 : 0,
        duration: duration,
        curve: UiMotion.bounce,
        child: Icon(Icons.check_rounded, size: 14, color: c.onAccent),
      ),
    );
  }
}
