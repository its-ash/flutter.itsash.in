import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiKeyValue extends StatelessWidget {
  const UiKeyValue(
    this.label,
    this.value, {
    super.key,
    this.icon,
    this.trailing,
    this.emphasis = false,
    this.valueColor,
    this.onTap,
    this.padding = const EdgeInsets.symmetric(vertical: UiSpace.sm),
  });

  final String label;
  final String value;
  final IconData? icon;
  final Widget? trailing;
  final bool emphasis;
  final Color? valueColor;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final ls = emphasis
        ? context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)
        : context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant);
    final vs = emphasis
        ? context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800, color: valueColor)
        : context.text.bodyMedium?.copyWith(fontWeight: FontWeight.w600, color: valueColor ?? cs.onSurface);
    final row = Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[Icon(icon, size: 18, color: cs.onSurfaceVariant), const UiGap.sm()],
          Expanded(child: Text(label, style: ls)),
          const UiGap.md(),
          Flexible(child: Text(value, textAlign: TextAlign.end, style: vs)),
          if (trailing != null) ...[const UiGap.xs(), trailing!],
        ],
      ),
    );
    return MergeSemantics(
      child: onTap == null ? row : InkWell(onTap: onTap, borderRadius: context.tokens.xs, child: row),
    );
  }
}

class UiKeyValueList extends StatelessWidget {
  const UiKeyValueList(this.items, {super.key, this.divided = false, this.total, this.totalColor});

  UiKeyValueList.fromMap(Map<String, String> map, {super.key, this.divided = false, this.total, this.totalColor})
      : items = [for (final e in map.entries) UiKeyValue(e.key, e.value)];

  final List<UiKeyValue> items;
  final bool divided;
  final (String, String)? total;
  final Color? totalColor;

  @override
  Widget build(BuildContext context) {
    final div = Divider(height: 1, thickness: 1, color: context.colors.outlineVariant.withValues(alpha: 0.6));
    final t = total;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, it) in items.indexed) ...[
          if (divided && i > 0) div,
          it,
        ],
        if (t != null) ...[
          const UiGap.xs(),
          div,
          const UiGap.xs(),
          UiKeyValue(t.$1, t.$2, emphasis: true, valueColor: totalColor),
        ],
      ],
    );
  }
}
