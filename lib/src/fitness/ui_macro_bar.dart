import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiMacro {
  const UiMacro(this.label, this.value, this.target, {this.unit = 'g', this.color});

  final String label;
  final double value;
  final double target;
  final String unit;
  final Color? color;
}

class UiMacroBar extends StatelessWidget {
  const UiMacroBar({super.key, required this.macros, this.compact = false});

  final List<UiMacro> macros;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (macros.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final defaults = [cs.primary, cs.tertiary, cs.secondary, context.palette.info, context.palette.warning];

    Widget item(int i) {
      final m = macros[i];
      final v = m.value.isFinite && m.value > 0 ? m.value : 0.0;
      final t = m.target.isFinite && m.target > 0 ? m.target : 0.0;
      final ratio = t == 0 ? 0.0 : v / t;
      final over = ratio > 1;
      final c = over ? cs.error : (m.color ?? defaults[i % defaults.length]);
      return Semantics(
        label: '${m.label} ${UiFormat.number(v, decimals: 1, trimZeros: true)} of ${UiFormat.number(t, decimals: 1, trimZeros: true)} ${m.unit}',
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      m.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (!compact)
                    Text(
                      '${UiFormat.number(v, decimals: 1, trimZeros: true)} / ${UiFormat.number(t, decimals: 1, trimZeros: true)} ${m.unit}',
                      style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                ],
              ),
              const UiGap.xs(),
              ClipRRect(
                borderRadius: context.tokens.full,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(end: ratio.clamp(0.0, 1.0)),
                  duration: UiDuration.slow,
                  curve: UiCurve.standard,
                  builder: (_, x, _) => LinearProgressIndicator(
                    value: x,
                    minHeight: 6,
                    color: c,
                    backgroundColor: c.withValues(alpha: 0.14),
                  ),
                ),
              ),
              if (compact) ...[
                const UiGap.xs(),
                Text(
                  '${UiFormat.number(v, decimals: 1, trimZeros: true)}${m.unit}',
                  style: context.text.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ],
          ),
        ),
      );
    }

    if (compact) {
      return Row(
        children: [
          for (var i = 0; i < macros.length; i++) ...[
            if (i > 0) const UiGap.md(),
            Expanded(child: item(i)),
          ],
        ],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < macros.length; i++) ...[
          if (i > 0) const UiGap.md(),
          item(i),
        ],
      ],
    );
  }
}
