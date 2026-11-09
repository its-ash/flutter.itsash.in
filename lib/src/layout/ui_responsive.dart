import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Grid that picks its column count from the available width, so items are
/// never narrower than [minItemWidth] and nothing overflows. Not lazy: use it
/// for dozens of items, not thousands.
///
/// ```dart
/// UiResponsiveGrid(minItemWidth: 160, children: [for (final p in products) ProductCard(p)]);
/// ```
class UiResponsiveGrid extends StatelessWidget {
  const UiResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 160,
    this.spacing = UiSpace.md,
    this.runSpacing,
    this.maxColumns,
    this.equalHeight = false,
  });

  final List<Widget> children;

  /// Smallest width of one item. Always at least one column.
  final double minItemWidth;

  /// Space between columns.
  final double spacing;

  /// Space between rows. Defaults to [spacing].
  final double? runSpacing;

  /// Upper limit of columns.
  final int? maxColumns;

  /// Stretches items in a row to the tallest one.
  final bool equalHeight;

  /// Column count for [width].
  static int columnsFor(double width, {double minItemWidth = 160, double spacing = UiSpace.md, int? maxColumns}) {
    if (!width.isFinite || width <= 0) return 1;
    final cols = math.max(1, ((width + spacing) / (minItemWidth + spacing)).floor());
    return maxColumns == null ? cols : math.min(cols, math.max(1, maxColumns));
  }

  @override
  Widget build(BuildContext context) {
    final run = runSpacing ?? spacing;
    return LayoutBuilder(
      builder: (context, box) {
        if (!box.maxWidth.isFinite) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: run), children[i]],
            ],
          );
        }
        final cols = columnsFor(box.maxWidth, minItemWidth: minItemWidth, spacing: spacing, maxColumns: maxColumns);
        final rows = (children.length / cols).ceil();
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var r = 0; r < rows; r++) ...[if (r > 0) SizedBox(height: run), _row(r, cols)],
          ],
        );
      },
    );
  }

  Widget _row(int r, int cols) {
    final row = Row(
      crossAxisAlignment: equalHeight ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < cols; c++) ...[
          if (c > 0) SizedBox(width: spacing),
          Expanded(child: r * cols + c < children.length ? children[r * cols + c] : const SizedBox.shrink()),
        ],
      ],
    );
    return equalHeight ? IntrinsicHeight(child: row) : row;
  }
}

/// Shows a different widget per window size class. Larger classes fall back
/// to the next smaller one that is set.
///
/// By default it uses the screen width. Set [local] to use the width given by
/// the parent instead (for panels and cards).
///
/// ```dart
/// UiResponsiveLayout(compact: const PhoneHome(), expanded: const TabletHome());
/// ```
class UiResponsiveLayout extends StatelessWidget {
  const UiResponsiveLayout({
    super.key,
    required Widget this.compact,
    this.medium,
    this.expanded,
    this.large,
    this.local = false,
  }) : builder = null;

  /// Builds from the current [UiBreakpoint].
  ///
  /// ```dart
  /// UiResponsiveLayout.builder(builder: (context, bp) => Text(bp.name));
  /// ```
  const UiResponsiveLayout.builder({
    super.key,
    required Widget Function(BuildContext, UiBreakpoint) this.builder,
    this.local = false,
  }) : compact = null,
       medium = null,
       expanded = null,
       large = null;

  final Widget? compact;
  final Widget? medium;
  final Widget? expanded;
  final Widget? large;
  final Widget Function(BuildContext context, UiBreakpoint breakpoint)? builder;

  /// Uses the parent's width instead of the screen width.
  final bool local;

  Widget _pick(BuildContext context, UiBreakpoint bp) {
    final build = builder;
    if (build != null) return build(context, bp);
    return switch (bp) {
      UiBreakpoint.compact => compact,
      UiBreakpoint.medium => medium ?? compact,
      UiBreakpoint.expanded => expanded ?? medium ?? compact,
      UiBreakpoint.large => large ?? expanded ?? medium ?? compact,
    }!;
  }

  @override
  Widget build(BuildContext context) {
    if (!local) return _pick(context, context.breakpoint);
    return LayoutBuilder(builder: (context, box) => _pick(context, UiBreakpoint.of(box.maxWidth)));
  }
}
