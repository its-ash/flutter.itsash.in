import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiStepIndicator extends StatelessWidget {
  const UiStepIndicator({
    super.key,
    required this.steps,
    required this.current,
    this.onTap,
    this.showLabels = true,
    this.size = 32,
  });

  final List<String> steps;
  final int current;
  final ValueChanged<int>? onTap;
  final bool showLabels;
  final double size;

  @override
  Widget build(BuildContext context) {
    final n = steps.length;
    if (n == 0) return const SizedBox.shrink();
    final cs = context.colors;
    final cur = current.clamp(0, n);
    Widget line(bool visible, bool done) => Expanded(
          child: AnimatedContainer(
            duration: UiDuration.normal,
            height: 3,
            decoration: BoxDecoration(
              color: !visible ? Colors.transparent : (done ? cs.primary : cs.outlineVariant),
              borderRadius: context.tokens.full,
            ),
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < n; i++)
          Expanded(
            child: Semantics(
              label: 'Step ${i + 1} of $n${steps[i].isEmpty ? '' : ', ${steps[i]}'}',
              selected: i == cur,
              button: onTap != null,
              excludeSemantics: true,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onTap == null ? null : () => onTap!(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        line(i > 0, i <= cur),
                        AnimatedContainer(
                          duration: UiDuration.normal,
                          curve: UiCurve.standard,
                          width: size,
                          height: size,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i <= cur ? cs.primary : cs.surfaceContainerHighest,
                            border: Border.all(
                              color: i == cur ? cs.primaryContainer : Colors.transparent,
                              width: 3,
                              strokeAlign: BorderSide.strokeAlignOutside,
                            ),
                          ),
                          child: i < cur
                              ? Icon(Icons.check_rounded, size: size * 0.55, color: cs.onPrimary)
                              : Text(
                                  '${i + 1}',
                                  style: context.text.labelLarge?.copyWith(
                                    color: i == cur ? cs.onPrimary : cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                        ),
                        line(i < n - 1, i < cur),
                      ],
                    ),
                    if (showLabels && steps[i].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: UiSpace.sm, left: UiSpace.xs, right: UiSpace.xs),
                        child: Text(
                          steps[i],
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelMedium?.copyWith(
                            color: i <= cur ? cs.onSurface : cs.onSurfaceVariant,
                            fontWeight: i == cur ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class UiPageDots extends StatelessWidget {
  const UiPageDots({
    super.key,
    required this.count,
    this.index = 0,
    this.controller,
    this.onTap,
    this.size = 8,
    this.activeWidth = 24,
    this.color,
  });

  final int count;
  final int index;
  final PageController? controller;
  final ValueChanged<int>? onTap;
  final double size;
  final double activeWidth;
  final Color? color;

  double _page(PageController c) {
    if (c.hasClients && c.positions.length == 1 && c.position.hasContentDimensions) {
      return c.page ?? c.initialPage.toDouble();
    }
    return c.initialPage.toDouble();
  }

  static double _t(double page, int i) => (1 - (page - i).abs()).clamp(0.0, 1.0);

  void _tap(int i) {
    final c = controller;
    if (onTap != null) {
      onTap!(i);
    } else if (c != null && c.hasClients) {
      c.animateToPage(i, duration: UiDuration.slow, curve: UiCurve.standard);
    }
  }

  Widget _dots(BuildContext context, double page) {
    final cs = context.colors;
    final tappable = onTap != null || controller != null;
    final cur = page.round().clamp(0, count - 1);
    return Semantics(
      label: 'Page ${cur + 1} of $count',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: tappable ? () => _tap(i) : null,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: size * 0.4, vertical: size),
                child: Container(
                  width: size + (activeWidth - size) * _t(page, i),
                  height: size,
                  decoration: BoxDecoration(
                    color: Color.lerp(cs.outlineVariant, color ?? cs.primary, _t(page, i)),
                    borderRadius: context.tokens.full,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final c = controller;
    if (c != null) {
      return AnimatedBuilder(animation: c, builder: (context, _) => _dots(context, _page(c)));
    }
    return TweenAnimationBuilder<double>(
      tween: Tween(end: index.clamp(0, count - 1).toDouble()),
      duration: UiDuration.normal,
      curve: UiCurve.standard,
      builder: (context, v, _) => _dots(context, v),
    );
  }
}

class UiBreadcrumbs extends StatelessWidget {
  const UiBreadcrumbs({super.key, required this.items, this.onTap, this.separator = Icons.chevron_right_rounded});

  final List<String> items;
  final ValueChanged<int>? onTap;
  final IconData separator;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final last = items.length - 1;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      reverse: true,
      child: Row(
        children: [
          for (var i = 0; i <= last; i++) ...[
            if (i > 0) Icon(separator, size: 18, color: cs.onSurfaceVariant),
            if (i == last || onTap == null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs, vertical: UiSpace.xs),
                child: Text(
                  items[i],
                  style: context.text.labelLarge?.copyWith(
                    color: i == last ? cs.onSurface : cs.onSurfaceVariant,
                    fontWeight: i == last ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              )
            else
              Semantics(
                link: true,
                child: InkWell(
                  onTap: () => onTap!(i),
                  borderRadius: context.tokens.sm,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs, vertical: UiSpace.xs),
                    child: Text(
                      items[i],
                      style: context.text.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
