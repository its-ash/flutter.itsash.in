import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiSegmented<T> extends StatelessWidget {
  const UiSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labelBuilder,
    this.iconBuilder,
    this.size = UiSize.md,
  });

  final List<T> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String Function(T)? labelBuilder;
  final IconData? Function(T)? iconBuilder;
  final UiSize size;

  @override
  Widget build(BuildContext context) {
    final opts = {...options}.toList();
    if (opts.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final n = opts.length;
    final idx = value == null ? -1 : opts.indexOf(value as T);
    final cb = onChanged;
    final (h, fs, iconSize) = switch (size) {
      UiSize.sm => (36.0, 13.0, 16.0),
      UiSize.md => (44.0, 14.0, 18.0),
      UiSize.lg => (52.0, 15.0, 20.0),
    };
    const pad = 4.0;
    final base = context.text.labelLarge?.copyWith(fontSize: fs, fontWeight: FontWeight.w600);
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.hasBoundedWidth ? c.maxWidth : n * 96.0;
        return Opacity(
          opacity: cb == null ? 0.5 : 1,
          child: Container(
            width: w,
            height: h,
            padding: const EdgeInsets.all(pad),
            decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: context.tokens.full),
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: UiDuration.normal,
                  curve: UiCurve.emphasized,
                  alignment: Alignment(n == 1 ? 0 : -1 + 2 * (idx < 0 ? 0 : idx) / (n - 1), 0),
                  child: AnimatedOpacity(
                    duration: UiDuration.fast,
                    opacity: idx < 0 ? 0 : 1,
                    child: FractionallySizedBox(
                      widthFactor: 1 / n,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: cs.primary,
                          borderRadius: context.tokens.full,
                          boxShadow: [BoxShadow(color: cs.shadow.withValues(alpha: 0.12), blurRadius: 8, offset: const Offset(0, 2))],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final (i, o) in opts.indexed)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == idx,
                          inMutuallyExclusiveGroup: true,
                          enabled: cb != null,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: cb == null || i == idx ? null : () => cb(o),
                            child: AnimatedDefaultTextStyle(
                              duration: UiDuration.fast,
                              style: (base ?? const TextStyle()).copyWith(color: i == idx ? cs.onPrimary : cs.onSurfaceVariant),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (iconBuilder?.call(o) case final ic?) ...[
                                        TweenAnimationBuilder<Color?>(
                                          duration: UiDuration.fast,
                                          tween: ColorTween(end: i == idx ? cs.onPrimary : cs.onSurfaceVariant),
                                          builder: (_, col, _) => Icon(ic, size: iconSize, color: col),
                                        ),
                                        const SizedBox(width: UiSpace.xs + 2),
                                      ],
                                      Flexible(
                                        child: Text(
                                          labelBuilder?.call(o) ?? o.toString(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
