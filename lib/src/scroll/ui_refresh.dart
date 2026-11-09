import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Pull-to-refresh in the theme colors. [child] must be scrollable.
///
/// ```dart
/// UiRefresh(onRefresh: reload, child: ListView(children: rows))
/// ```
class UiRefresh extends StatelessWidget {
  const UiRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.displacement = 40,
    this.edgeOffset = 0,
  });

  /// Runs on pull. The spinner shows until the future completes.
  final Future<void> Function() onRefresh;
  final Widget child;

  /// Distance the spinner settles at from the top edge.
  final double displacement;

  /// Extra offset from the top, e.g. under a pinned header.
  final double edgeOffset;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: colors.accent,
      backgroundColor: colors.surfaceRaised,
      strokeWidth: 2.5,
      elevation: 1,
      displacement: displacement,
      edgeOffset: edgeOffset,
      child: child,
    );
  }
}
