import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

Widget _layout(List<Widget> chips, bool scrollable) => scrollable
    ? SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            for (final (i, c) in chips.indexed) ...[if (i > 0) const SizedBox(width: UiSpace.sm), c],
          ],
        ),
      )
    : Wrap(spacing: UiSpace.sm, runSpacing: UiSpace.sm, children: chips);

class UiChoiceChips<T> extends StatelessWidget {
  const UiChoiceChips({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labelBuilder,
    this.iconBuilder,
    this.scrollable = false,
  });

  final List<T> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String Function(T)? labelBuilder;
  final IconData? Function(T)? iconBuilder;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final cb = onChanged;
    return _layout([
      for (final o in {...options})
        Builder(
          builder: (context) {
            final sel = o == value;
            final fg = sel ? cs.onPrimary : cs.onSurface;
            final ic = iconBuilder?.call(o);
            return ChoiceChip(
              label: Text(labelBuilder?.call(o) ?? o.toString()),
              selected: sel,
              avatar: ic == null ? null : Icon(ic, size: 18, color: fg),
              labelStyle: context.text.labelLarge?.copyWith(color: fg),
              onSelected: cb == null ? null : (_) {
                      if (!sel) cb(o);
                    },
            );
          },
        ),
    ], scrollable);
  }
}

class UiFilterChips<T> extends StatelessWidget {
  const UiFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    this.labelBuilder,
    this.iconBuilder,
    this.scrollable = false,
    this.showCheckmark = true,
    this.max,
  });

  final List<T> options;
  final List<T> selected;
  final ValueChanged<List<T>>? onChanged;
  final String Function(T)? labelBuilder;
  final IconData? Function(T)? iconBuilder;
  final bool scrollable;
  final bool showCheckmark;
  final int? max;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final cb = onChanged;
    final opts = {...options}.toList();
    final full = max != null && selected.length >= max!;
    return _layout([
      for (final o in opts)
        Builder(
          builder: (context) {
            final sel = selected.contains(o);
            final fg = sel ? cs.onPrimary : cs.onSurface;
            final ic = iconBuilder?.call(o);
            return FilterChip(
              label: Text(labelBuilder?.call(o) ?? o.toString()),
              selected: sel,
              showCheckmark: showCheckmark,
              checkmarkColor: cs.onPrimary,
              avatar: ic == null || (sel && showCheckmark) ? null : Icon(ic, size: 18, color: fg),
              labelStyle: context.text.labelLarge?.copyWith(color: fg),
              onSelected: cb == null || (full && !sel)
                  ? null
                  : (on) => cb([for (final x in opts) if (x == o ? on : selected.contains(x)) x]),
            );
          },
        ),
    ], scrollable);
  }
}
