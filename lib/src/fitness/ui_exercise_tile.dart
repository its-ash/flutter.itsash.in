import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';
import 'package:theme/src/image/ui_image.dart';

class UiExerciseTile extends StatelessWidget {
  const UiExerciseTile({
    super.key,
    required this.name,
    this.image,
    this.sets,
    this.reps,
    this.weight,
    this.unit = 'kg',
    this.detail,
    this.done,
    this.onDoneChanged,
    this.onTap,
    this.trailing,
  });

  final String name;
  final String? image;
  final int? sets;
  final int? reps;
  final double? weight;
  final String unit;
  final String? detail;
  final bool? done;
  final ValueChanged<bool>? onDoneChanged;
  final VoidCallback? onTap;
  final Widget? trailing;

  String? get _summary {
    if (detail != null) return detail;
    final s = sets != null && sets! > 0 ? sets : null;
    final r = reps != null && reps! > 0 ? reps : null;
    final w = weight != null && weight!.isFinite && weight! > 0 ? weight : null;
    final vol = switch ((s, r)) {
      (final int a, final int b) => '$a × $b',
      (final int a, null) => '$a sets',
      (null, final int b) => '$b reps',
      _ => null,
    };
    final load = w == null ? null : '${UiFormat.number(w, decimals: 2, trimZeros: true)} $unit';
    final parts = [?vol, ?load];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final isDone = done ?? false;
    final sub = _summary;
    return UiCard(
      onTap: onTap,
      padding: const EdgeInsets.all(UiSpace.md),
      child: Row(
        children: [
          UiImage(
            image,
            width: 56,
            height: 56,
            radius: context.tokens.md,
            placeholderIcon: Icons.fitness_center_rounded,
          ),
          const UiGap.md(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDone ? cs.onSurfaceVariant : cs.onSurface,
                  ),
                ),
                if (sub != null) ...[
                  const UiGap.xs(),
                  Text(
                    sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const UiGap.sm(), trailing!],
          if (done != null) ...[
            const UiGap.sm(),
            _DoneCheck(done: isDone, onChanged: onDoneChanged),
          ],
        ],
      ),
    );
  }
}

class _DoneCheck extends StatelessWidget {
  const _DoneCheck({required this.done, this.onChanged});

  final bool done;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final ok = context.palette.success;
    return Semantics(
      checked: done,
      button: onChanged != null,
      label: 'Done',
      child: InkResponse(
        onTap: onChanged == null ? null : () => onChanged!(!done),
        radius: 22,
        child: AnimatedContainer(
          duration: UiDuration.fast,
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done ? ok : Colors.transparent,
            border: Border.all(color: done ? ok : cs.outline, width: 2),
          ),
          child: done ? Icon(Icons.check_rounded, size: 18, color: context.palette.onSuccess) : null,
        ),
      ),
    );
  }
}
