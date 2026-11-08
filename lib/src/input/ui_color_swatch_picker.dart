import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiColorSwatchPicker extends StatelessWidget {
  const UiColorSwatchPicker({
    super.key,
    required this.colors,
    required this.value,
    required this.onChanged,
    this.size = 40,
    this.scrollable = false,
    this.labels,
  });

  final List<Color> colors;
  final Color? value;
  final ValueChanged<Color>? onChanged;
  final double size;
  final bool scrollable;
  final List<String>? labels;

  @override
  Widget build(BuildContext context) {
    if (colors.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final d = size.clamp(24.0, 72.0);
    final cb = onChanged;
    final sel = value?.toARGB32();
    final items = [
      for (final (i, c) in colors.indexed)
        Builder(
          builder: (context) {
            final on = c.toARGB32() == sel;
            final check = ThemeData.estimateBrightnessForColor(c) == Brightness.dark ? Colors.white : Colors.black;
            final name = labels != null && i < labels!.length ? labels![i] : 'Color ${i + 1}';
            return Semantics(
              button: true,
              selected: on,
              inMutuallyExclusiveGroup: true,
              enabled: cb != null,
              label: name,
              child: GestureDetector(
                onTap: cb == null ? null : () => cb(c),
                child: AnimatedContainer(
                  duration: UiDuration.fast,
                  width: d + 8,
                  height: d + 8,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: on ? c : Colors.transparent, width: 2),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: c,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.6)),
                    ),
                    child: AnimatedScale(
                      duration: UiDuration.fast,
                      curve: UiCurve.standard,
                      scale: on ? 1 : 0,
                      child: Icon(Icons.check_rounded, size: d * 0.5, color: check),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
    ];
    return Opacity(
      opacity: cb == null ? 0.5 : 1,
      child: scrollable
          ? SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [for (final (i, w) in items.indexed) ...[if (i > 0) const SizedBox(width: UiSpace.xs), w]]),
            )
          : Wrap(spacing: UiSpace.xs, runSpacing: UiSpace.xs, children: items),
    );
  }
}
