import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiRatingInput extends StatelessWidget {
  const UiRatingInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.max = 5,
    this.size = 36,
    this.allowHalf = false,
    this.spacing = UiSpace.xs,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final int max;
  final double size;
  final bool allowHalf;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final n = max < 1 ? 1 : max;
    final step = allowHalf ? 0.5 : 1.0;
    final v = value.isFinite ? value.clamp(0.0, n.toDouble()) : 0.0;
    final c = context.palette.rating;
    final muted = context.colors.outlineVariant;
    final cb = onChanged;
    final s = size.clamp(16.0, 72.0);
    final slot = s + spacing;

    double at(double dx) {
      final raw = (dx + spacing / 2) / slot;
      final q = allowHalf ? (raw * 2).ceil() / 2 : raw.ceilToDouble();
      return q.clamp(step, n.toDouble());
    }

    void set(double x) {
      if (cb != null && x != v) cb(x);
    }

    String fmt(double x) => x == x.roundToDouble() ? x.toInt().toString() : x.toStringAsFixed(1);

    return Semantics(
      slider: true,
      label: 'Rating',
      value: '${fmt(v)} of $n',
      increasedValue: v < n ? '${fmt((v + step).clamp(0, n.toDouble()))} of $n' : null,
      decreasedValue: v > 0 ? '${fmt((v - step).clamp(0, n.toDouble()))} of $n' : null,
      onIncrease: cb != null && v < n ? () => cb((v + step).clamp(0.0, n.toDouble())) : null,
      onDecrease: cb != null && v > 0 ? () => cb((v - step).clamp(0.0, n.toDouble())) : null,
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: cb == null ? null : (d) => set(at(d.localPosition.dx)),
          onHorizontalDragUpdate: cb == null ? null : (d) => set(at(d.localPosition.dx)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 1; i <= n; i++) ...[
                if (i > 1) SizedBox(width: spacing),
                AnimatedScale(
                  duration: UiDuration.fast,
                  curve: Curves.easeOutBack,
                  scale: v >= i - 0.5 ? 1.0 : 0.9,
                  child: Icon(
                    v >= i
                        ? Icons.star_rounded
                        : v >= i - 0.5
                            ? Icons.star_half_rounded
                            : Icons.star_outline_rounded,
                    size: s,
                    color: v >= i - 0.5 ? c : muted,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
