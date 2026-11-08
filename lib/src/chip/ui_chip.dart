import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

enum UiChipVariant { filled, tonal, outline, soft, elevated }

class UiChip extends StatelessWidget {
  const UiChip(
    this.label, {
    super.key,
    this.variant = UiChipVariant.tonal,
    this.status,
    this.color,
    this.icon,
    this.avatar,
    this.count,
    this.selected = false,
    this.onTap,
    this.onDeleted,
    this.size = UiSize.md,
    this.enabled = true,
    this.deleteTooltip,
  });

  final String label;
  final UiChipVariant variant;
  final UiStatus? status;
  final Color? color;
  final IconData? icon;
  final Widget? avatar;
  final int? count;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;
  final UiSize size;
  final bool enabled;
  final String? deleteTooltip;

  static Color _on(Color c) => ThemeData.estimateBrightnessForColor(c) == Brightness.dark ? Colors.white : Colors.black;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final tone = status == null ? null : context.tone(status!);
    final accent = color ?? tone?.color ?? cs.primary;
    final onAccent = color != null ? _on(color!) : tone?.onColor ?? cs.onPrimary;
    final v = selected ? UiChipVariant.filled : variant;
    final (Color bg, Color fg, Color? border, bool shadow) = switch (v) {
      UiChipVariant.filled => (accent, onAccent, null, false),
      UiChipVariant.tonal => (
          color != null ? color!.withValues(alpha: 0.18) : tone?.container ?? cs.secondaryContainer,
          color ?? tone?.onContainer ?? cs.onSecondaryContainer,
          null,
          false,
        ),
      UiChipVariant.outline => (Colors.transparent, color ?? tone?.color ?? cs.onSurface, cs.outlineVariant, false),
      UiChipVariant.soft => (accent.withValues(alpha: context.isDark ? 0.2 : 0.1), accent, null, false),
      UiChipVariant.elevated => (cs.surfaceContainerLow, cs.onSurface, null, true),
    };
    final (h, padH, fs, iconSize) = switch (size) {
      UiSize.sm => (28.0, 10.0, 12.0, 14.0),
      UiSize.md => (34.0, 12.0, 13.0, 16.0),
      UiSize.lg => (40.0, 14.0, 14.0, 18.0),
    };
    final tap = enabled ? onTap : null;
    final del = enabled ? onDeleted : null;
    final text = context.text.labelLarge?.copyWith(color: fg, fontSize: fs, fontWeight: FontWeight.w600);

    final row = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (avatar != null) ...[
          SizedBox.square(dimension: h - 8, child: ClipOval(child: avatar)),
          const SizedBox(width: UiSpace.xs + 2),
        ] else if (icon != null) ...[
          Icon(icon, size: iconSize, color: fg),
          const SizedBox(width: UiSpace.xs + 2),
        ],
        Flexible(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: text)),
        if (count != null) ...[
          const SizedBox(width: UiSpace.xs + 2),
          Container(
            constraints: BoxConstraints(minWidth: iconSize + 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(color: fg.withValues(alpha: 0.16), borderRadius: context.tokens.full),
            child: Text(
              count! > 99 ? '99+' : '$count',
              textAlign: TextAlign.center,
              style: text?.copyWith(fontSize: fs - 2, fontWeight: FontWeight.w700),
            ),
          ),
        ],
        if (onDeleted != null) ...[
          const SizedBox(width: UiSpace.xxs),
          Tooltip(
            message: deleteTooltip ?? 'Remove $label',
            child: InkResponse(
              onTap: del,
              radius: iconSize,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: Icon(Icons.close_rounded, size: iconSize, color: fg.withValues(alpha: 0.8)),
              ),
            ),
          ),
        ],
      ],
    );

    final shape = StadiumBorder(side: border == null ? BorderSide.none : BorderSide(color: border));
    return Semantics(
      button: tap != null,
      selected: selected,
      enabled: enabled,
      label: label,
      excludeSemantics: onDeleted == null,
      child: Opacity(
        opacity: enabled ? 1 : 0.5,
        child: AnimatedContainer(
          duration: UiDuration.fast,
          height: h,
          decoration: ShapeDecoration(
            color: bg,
            shape: shape,
            shadows: shadow
                ? [BoxShadow(color: Colors.black.withValues(alpha: context.isDark ? 0.35 : 0.08), blurRadius: 10, offset: const Offset(0, 3))]
                : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            shape: shape,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: tap,
              child: Padding(
                padding: EdgeInsets.only(left: avatar != null ? 4 : padH, right: onDeleted != null ? 6 : padH),
                child: Center(widthFactor: 1, child: row),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UiChipGroup extends StatelessWidget {
  const UiChipGroup({
    super.key,
    required this.children,
    this.scrollable = false,
    this.spacing = UiSpace.sm,
    this.runSpacing = UiSpace.sm,
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> children;
  final bool scrollable;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    if (!scrollable) {
      return Padding(padding: padding, child: Wrap(spacing: spacing, runSpacing: runSpacing, children: children));
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: padding,
      clipBehavior: Clip.none,
      child: Row(children: [for (final (i, c) in children.indexed) ...[if (i > 0) SizedBox(width: spacing), c]]),
    );
  }
}
