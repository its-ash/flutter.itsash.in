import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'package:theme/src/foundation/tokens.dart';

enum UiWindowSize {
  compact,
  medium,
  expanded;

  static UiWindowSize of(double width) => width < UiBreakpoint.compact
      ? compact
      : width < UiBreakpoint.expanded
          ? medium
          : expanded;
}

class UiResponsive extends StatelessWidget {
  const UiResponsive({super.key, required Widget this.compact, this.medium, this.expanded}) : builder = null;

  const UiResponsive.builder({super.key, required Widget Function(BuildContext context, UiWindowSize size) this.builder})
      : compact = null,
        medium = null,
        expanded = null;

  final Widget? compact;
  final Widget? medium;
  final Widget? expanded;
  final Widget Function(BuildContext context, UiWindowSize size)? builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth.isFinite ? c.maxWidth : MediaQuery.sizeOf(context).width;
          final size = UiWindowSize.of(w);
          final b = builder;
          if (b != null) return b(context, size);
          return switch (size) {
                UiWindowSize.expanded => expanded ?? medium,
                UiWindowSize.medium => medium,
                UiWindowSize.compact => null,
              } ??
              compact ??
              const SizedBox.shrink();
        },
      );
}

int _columns(double width, double minItemWidth, double spacing, int? maxColumns) {
  if (!width.isFinite || width <= 0) return 1;
  final min = math.max(1.0, minItemWidth);
  final n = ((width + spacing) / (min + spacing)).floor();
  return n.clamp(1, math.max(1, maxColumns ?? 99));
}

class UiGridDelegate extends SliverGridDelegate {
  const UiGridDelegate({
    this.minItemWidth = 160,
    this.spacing = UiSpace.md,
    this.runSpacing,
    this.childAspectRatio = 1,
    this.mainAxisExtent,
    this.maxColumns,
  });

  final double minItemWidth;
  final double spacing;
  final double? runSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;
  final int? maxColumns;

  @override
  SliverGridLayout getLayout(SliverConstraints constraints) {
    final w = constraints.crossAxisExtent;
    final cols = _columns(w, minItemWidth, spacing, maxColumns);
    final cw = math.max(0.0, (w - spacing * (cols - 1)) / cols);
    final mh = mainAxisExtent ?? cw / math.max(0.01, childAspectRatio);
    return SliverGridRegularTileLayout(
      crossAxisCount: cols,
      mainAxisStride: mh + (runSpacing ?? spacing),
      crossAxisStride: cw + spacing,
      childMainAxisExtent: mh,
      childCrossAxisExtent: cw,
      reverseCrossAxis: axisDirectionIsReversed(constraints.crossAxisDirection),
    );
  }

  @override
  bool shouldRelayout(UiGridDelegate oldDelegate) =>
      oldDelegate.minItemWidth != minItemWidth ||
      oldDelegate.spacing != spacing ||
      oldDelegate.runSpacing != runSpacing ||
      oldDelegate.childAspectRatio != childAspectRatio ||
      oldDelegate.mainAxisExtent != mainAxisExtent ||
      oldDelegate.maxColumns != maxColumns;
}

class UiResponsiveGrid extends StatelessWidget {
  const UiResponsiveGrid({
    super.key,
    required List<Widget> this.children,
    this.minItemWidth = 160,
    this.spacing = UiSpace.md,
    this.runSpacing,
    this.childAspectRatio,
    this.maxColumns,
  })  : itemCount = 0,
        itemBuilder = null,
        mainAxisExtent = null,
        padding = null,
        controller = null,
        physics = null,
        shrinkWrap = false;

  const UiResponsiveGrid.builder({
    super.key,
    required this.itemCount,
    required IndexedWidgetBuilder this.itemBuilder,
    this.minItemWidth = 160,
    this.spacing = UiSpace.md,
    this.runSpacing,
    this.childAspectRatio,
    this.mainAxisExtent,
    this.maxColumns,
    this.padding = UiSpace.page,
    this.controller,
    this.physics,
    this.shrinkWrap = false,
  }) : children = null;

  final List<Widget>? children;
  final int itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final double minItemWidth;
  final double spacing;
  final double? runSpacing;
  final double? childAspectRatio;
  final double? mainAxisExtent;
  final int? maxColumns;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final ScrollPhysics? physics;
  final bool shrinkWrap;

  static int columnsFor(double width, {double minItemWidth = 160, double spacing = UiSpace.md, int? maxColumns}) =>
      _columns(width, minItemWidth, spacing, maxColumns);

  @override
  Widget build(BuildContext context) {
    final b = itemBuilder;
    if (b != null) {
      return GridView.builder(
        controller: controller,
        physics: physics,
        shrinkWrap: shrinkWrap,
        padding: padding,
        itemCount: math.max(0, itemCount),
        itemBuilder: b,
        gridDelegate: UiGridDelegate(
          minItemWidth: minItemWidth,
          spacing: spacing,
          runSpacing: runSpacing,
          childAspectRatio: childAspectRatio ?? 0.75,
          mainAxisExtent: mainAxisExtent,
          maxColumns: maxColumns,
        ),
      );
    }
    final items = children ?? const <Widget>[];
    if (items.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth.isFinite ? c.maxWidth : minItemWidth;
        final cols = _columns(w, minItemWidth, spacing, maxColumns);
        final cw = math.max(0.0, (w - spacing * (cols - 1)) / cols - 0.01);
        final ratio = childAspectRatio;
        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing ?? spacing,
          children: [
            for (final child in items)
              SizedBox(width: cw, height: ratio == null || ratio <= 0 ? null : cw / ratio, child: child),
          ],
        );
      },
    );
  }
}

class UiSliverGrid extends StatelessWidget {
  const UiSliverGrid({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.minItemWidth = 160,
    this.spacing = UiSpace.md,
    this.runSpacing,
    this.childAspectRatio = 0.75,
    this.mainAxisExtent,
    this.maxColumns,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double minItemWidth;
  final double spacing;
  final double? runSpacing;
  final double childAspectRatio;
  final double? mainAxisExtent;
  final int? maxColumns;

  @override
  Widget build(BuildContext context) => SliverGrid(
        delegate: SliverChildBuilderDelegate(itemBuilder, childCount: math.max(0, itemCount)),
        gridDelegate: UiGridDelegate(
          minItemWidth: minItemWidth,
          spacing: spacing,
          runSpacing: runSpacing,
          childAspectRatio: childAspectRatio,
          mainAxisExtent: mainAxisExtent,
          maxColumns: maxColumns,
        ),
      );
}

class UiHorizontalList extends StatelessWidget {
  const UiHorizontalList({
    super.key,
    required List<Widget> this.children,
    this.spacing = UiSpace.md,
    this.padding = UiSpace.page,
    this.itemExtent,
    this.height,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.controller,
  })  : itemCount = 0,
        itemBuilder = null;

  const UiHorizontalList.builder({
    super.key,
    required this.itemCount,
    required IndexedWidgetBuilder this.itemBuilder,
    required double this.height,
    this.spacing = UiSpace.md,
    this.padding = UiSpace.page,
    this.itemExtent,
    this.controller,
  })  : children = null,
        crossAxisAlignment = CrossAxisAlignment.start;

  final List<Widget>? children;
  final int itemCount;
  final IndexedWidgetBuilder? itemBuilder;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final double? itemExtent;
  final double? height;
  final CrossAxisAlignment crossAxisAlignment;
  final ScrollController? controller;

  Widget _sized(Widget w) => itemExtent == null ? w : SizedBox(width: itemExtent, child: w);

  @override
  Widget build(BuildContext context) {
    final b = itemBuilder;
    if (b != null) {
      if (itemCount <= 0) return const SizedBox.shrink();
      return SizedBox(
        height: height,
        child: ListView.separated(
          controller: controller,
          scrollDirection: Axis.horizontal,
          padding: padding,
          itemCount: itemCount,
          separatorBuilder: (_, _) => SizedBox(width: spacing),
          itemBuilder: (context, i) => _sized(b(context, i)),
        ),
      );
    }
    final items = children ?? const <Widget>[];
    if (items.isEmpty) return const SizedBox.shrink();
    final list = SingleChildScrollView(
      controller: controller,
      scrollDirection: Axis.horizontal,
      padding: padding,
      child: Row(
        crossAxisAlignment: crossAxisAlignment,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) SizedBox(width: spacing),
            _sized(items[i]),
          ],
        ],
      ),
    );
    return height == null ? list : SizedBox(height: height, child: list);
  }
}
