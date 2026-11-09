import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

List<Widget> _withGaps(List<Widget> children, Widget gap) => [
  for (var i = 0; i < children.length; i++) ...[if (i > 0) gap, children[i]],
];

/// `Column` that puts [gap] space between its children.
///
/// ```dart
/// UiColumn(gap: UiSpace.lg, children: [title, body, actions]);
/// ```
class UiColumn extends StatelessWidget {
  const UiColumn({
    super.key,
    required this.children,
    this.gap = UiSpace.md,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<Widget> children;
  final double gap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) => Column(
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    mainAxisSize: mainAxisSize,
    children: _withGaps(children, SizedBox(height: gap)),
  );
}

/// `Row` that puts [gap] space between its children.
///
/// ```dart
/// UiRow(gap: UiSpace.sm, children: [icon, Expanded(child: label)]);
/// ```
class UiRow extends StatelessWidget {
  const UiRow({
    super.key,
    required this.children,
    this.gap = UiSpace.sm,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.mainAxisSize = MainAxisSize.max,
  });

  final List<Widget> children;
  final double gap;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: mainAxisAlignment,
    crossAxisAlignment: crossAxisAlignment,
    mainAxisSize: mainAxisSize,
    children: _withGaps(children, SizedBox(width: gap)),
  );
}
