import 'package:flutter/material.dart';

class ThemeMasonryGrid extends StatefulWidget {
  const ThemeMasonryGrid({
    super.key,
    required this.children,
    this.crossAxisCount = 2,
    this.spacing = 8,
  });

  final List<Widget> children;
  final int crossAxisCount;
  final double spacing;

  @override
  State<ThemeMasonryGrid> createState() => _ThemeMasonryGridState();
}

class _ThemeMasonryGridState extends State<ThemeMasonryGrid> {
  final List<GlobalKey> _keys = [];
  List<int>? _columnAssignment;

  @override
  void initState() {
    super.initState();
    _syncKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndPack());
  }

  @override
  void didUpdateWidget(covariant ThemeMasonryGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _syncKeys();
      _columnAssignment = null;
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureAndPack());
    }
  }

  void _syncKeys() {
    _keys
      ..clear()
      ..addAll(List.generate(widget.children.length, (_) => GlobalKey()));
  }

  // Item heights aren't known until the first-pass layout renders each child
  // in natural order; only then can shortest-column-next packing run, so we
  // measure post-frame and reflow once.
  void _measureAndPack() {
    if (!mounted) return;
    final heights = <double>[];
    for (final key in _keys) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      heights.add(box.size.height);
    }

    final columnHeights = List<double>.filled(widget.crossAxisCount, 0);
    final assignment = List<int>.filled(heights.length, 0);
    for (var i = 0; i < heights.length; i++) {
      var shortest = 0;
      for (var c = 1; c < widget.crossAxisCount; c++) {
        if (columnHeights[c] < columnHeights[shortest]) shortest = c;
      }
      assignment[i] = shortest;
      columnHeights[shortest] += heights[i] + widget.spacing;
    }

    setState(() => _columnAssignment = assignment);
  }

  @override
  Widget build(BuildContext context) {
    if (_columnAssignment == null) {
      return Wrap(
        spacing: widget.spacing,
        runSpacing: widget.spacing,
        children: [
          for (var i = 0; i < widget.children.length; i++)
            KeyedSubtree(key: _keys[i], child: widget.children[i]),
        ],
      );
    }

    final columns = List.generate(widget.crossAxisCount, (_) => <Widget>[]);
    for (var i = 0; i < widget.children.length; i++) {
      final col = _columnAssignment![i];
      if (columns[col].isNotEmpty) columns[col].add(SizedBox(height: widget.spacing));
      columns[col].add(KeyedSubtree(key: _keys[i], child: widget.children[i]));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var c = 0; c < widget.crossAxisCount; c++) ...[
          if (c > 0) SizedBox(width: widget.spacing),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: columns[c])),
        ],
      ],
    );
  }
}
