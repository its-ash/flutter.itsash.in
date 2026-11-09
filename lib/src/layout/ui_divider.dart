import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Hairline divider, horizontal or [vertical], with an optional centered
/// [label] such as "or".
///
/// ```dart
/// const UiDivider(label: 'or');
/// ```
class UiDivider extends StatelessWidget {
  const UiDivider({
    super.key,
    this.label,
    this.vertical = false,
    this.indent = 0,
    this.endIndent,
    this.space = 1,
    this.color,
  });

  /// Text in the middle of a horizontal divider.
  final String? label;
  final bool vertical;

  /// Empty space before the line.
  final double indent;

  /// Empty space after the line. Defaults to [indent].
  final double? endIndent;

  /// Total height (or width when [vertical]) the divider takes.
  final double space;

  /// Line color. Defaults to `colors.border`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final line = color ?? c.border;
    final end = endIndent ?? indent;
    if (vertical) {
      return VerticalDivider(width: space, thickness: 1, indent: indent, endIndent: end, color: line);
    }
    if (label == null) {
      return Divider(height: space, thickness: 1, indent: indent, endIndent: end, color: line);
    }
    return Padding(
      padding: EdgeInsetsDirectional.only(start: indent, end: end),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: space),
        child: LayoutBuilder(
          builder: (context, box) => Row(
            children: [
              Expanded(child: Divider(height: 1, thickness: 1, color: line)),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: box.maxWidth.isFinite ? box.maxWidth * 0.7 : double.infinity),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
                  child: Text(
                    label!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall!.copyWith(color: c.textSubtle),
                  ),
                ),
              ),
              Expanded(child: Divider(height: 1, thickness: 1, color: line)),
            ],
          ),
        ),
      ),
    );
  }
}
