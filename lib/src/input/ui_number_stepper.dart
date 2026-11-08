import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiNumberStepper extends StatelessWidget {
  const UiNumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 99,
    this.step = 1,
    this.size = UiSize.md,
    this.label,
    this.format,
    this.onRemove,
  });

  final int value;
  final ValueChanged<int>? onChanged;
  final int min;
  final int max;
  final int step;
  final UiSize size;
  final String? label;
  final String Function(int)? format;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final lo = min <= max ? min : max;
    final hi = min <= max ? max : min;
    final s = step > 0 ? step : 1;
    final v = value.clamp(lo, hi);
    final cb = onChanged;
    final canDec = cb != null && v > lo;
    final canInc = cb != null && v < hi;
    final remove = onRemove != null && v <= lo;
    void dec() => cb?.call((v - s).clamp(lo, hi));
    void inc() => cb?.call((v + s).clamp(lo, hi));
    final (h, btn, icon, fs, minW) = switch (size) {
      UiSize.sm => (36.0, 32.0, 16.0, 14.0, 28.0),
      UiSize.md => (44.0, 38.0, 20.0, 16.0, 36.0),
      UiSize.lg => (52.0, 46.0, 22.0, 18.0, 44.0),
    };
    final text = format?.call(v) ?? '$v';

    Widget b(IconData ic, bool on, VoidCallback fn, String tip, [Color? fg]) => SizedBox.square(
          dimension: btn,
          child: IconButton(
            tooltip: tip,
            onPressed: on ? fn : null,
            padding: EdgeInsets.zero,
            iconSize: icon,
            style: IconButton.styleFrom(
              shape: const CircleBorder(),
              backgroundColor: on ? cs.surface : Colors.transparent,
              foregroundColor: fg ?? cs.onSurface,
              disabledForegroundColor: cs.onSurface.withValues(alpha: 0.3),
            ),
            icon: Icon(ic),
          ),
        );

    return Semantics(
      container: true,
      label: label ?? 'Quantity',
      value: text,
      increasedValue: canInc ? (format?.call((v + s).clamp(lo, hi)) ?? '${(v + s).clamp(lo, hi)}') : null,
      decreasedValue: canDec ? (format?.call((v - s).clamp(lo, hi)) ?? '${(v - s).clamp(lo, hi)}') : null,
      onIncrease: canInc ? inc : null,
      onDecrease: canDec ? dec : null,
      child: Container(
        height: h,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: context.tokens.full),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            remove ? b(Icons.delete_outline_rounded, true, onRemove!, 'Remove', cs.error) : b(Icons.remove_rounded, canDec, dec, 'Decrease'),
            ConstrainedBox(
              constraints: BoxConstraints(minWidth: minW),
              child: ExcludeSemantics(
                child: AnimatedSwitcher(
                  duration: UiDuration.fast,
                  transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
                  child: Text(
                    text,
                    key: ValueKey(v),
                    textAlign: TextAlign.center,
                    style: context.text.titleMedium?.copyWith(
                      fontSize: fs,
                      fontWeight: FontWeight.w700,
                      color: cb == null ? cs.onSurface.withValues(alpha: 0.38) : cs.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ),
            ),
            b(Icons.add_rounded, canInc, inc, 'Increase'),
          ],
        ),
      ),
    );
  }
}
