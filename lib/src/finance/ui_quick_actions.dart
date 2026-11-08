import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiQuickAction {
  const UiQuickAction({required this.icon, required this.label, this.onTap, this.badge});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final String? badge;
}

class UiQuickActions extends StatelessWidget {
  const UiQuickActions({
    super.key,
    required this.actions,
    this.columns,
    this.size = 56,
    this.background,
    this.foreground,
    this.labelColor,
  });

  final List<UiQuickAction> actions;
  final int? columns;
  final double size;
  final Color? background;
  final Color? foreground;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final bg = background ?? cs.primaryContainer;
    final fg = foreground ?? cs.onPrimaryContainer;
    final lc = labelColor ?? cs.onSurface;
    final dim = size.clamp(36.0, 96.0);

    Widget item(UiQuickAction a) {
      Widget circle = Material(
        color: bg,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: a.onTap,
          child: SizedBox.square(dimension: dim, child: Icon(a.icon, color: a.onTap == null ? fg.withValues(alpha: 0.4) : fg, size: dim * 0.42)),
        ),
      );
      if (a.badge != null) {
        circle = Badge(label: a.badge!.isEmpty ? null : Text(a.badge!), smallSize: 10, child: circle);
      }
      return Semantics(
        button: true,
        enabled: a.onTap != null,
        label: a.label,
        child: ExcludeSemantics(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              circle,
              const UiGap.sm(),
              Text(
                a.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.text.labelMedium?.copyWith(color: lc, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    final cols = columns;
    if (cols == null) {
      if (actions.length <= 5) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [for (final a in actions) Expanded(child: item(a))],
        );
      }
      return SizedBox(
        height: dim + 32,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: actions.length,
          separatorBuilder: (_, _) => const UiGap.lg(),
          itemBuilder: (_, i) => SizedBox(width: dim + 16, child: item(actions[i])),
        ),
      );
    }
    final n = cols.clamp(1, 8);
    return LayoutBuilder(
      builder: (_, box) {
        final w = (box.maxWidth - (n - 1) * UiSpace.sm) / n;
        return Wrap(
          spacing: UiSpace.sm,
          runSpacing: UiSpace.lg,
          children: [for (final a in actions) SizedBox(width: w, child: item(a))],
        );
      },
    );
  }
}
