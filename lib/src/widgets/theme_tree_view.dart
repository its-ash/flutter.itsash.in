import 'package:flutter/material.dart';

import 'package:theme/src/typography/app_typography.dart';

class ThemeTreeNode<T> {
  ThemeTreeNode({
    required this.value,
    required this.label,
    this.children = const [],
    this.icon,
  });

  final T value;
  final Object label; // String or String Function(T)
  final List<ThemeTreeNode<T>> children;
  final IconData? icon;

  String resolveLabel() => label is String Function(T) ? (label as String Function(T))(value) : label as String;
}

class ThemeTreeView<T> extends StatefulWidget {
  const ThemeTreeView({
    super.key,
    required this.nodes,
    this.onNodeTap,
    this.indent = 20,
  });

  final List<ThemeTreeNode<T>> nodes;
  final ValueChanged<ThemeTreeNode<T>>? onNodeTap;
  final double indent;

  @override
  State<ThemeTreeView<T>> createState() => _ThemeTreeViewState<T>();
}

class _ThemeTreeViewState<T> extends State<ThemeTreeView<T>> {
  final Set<int> _expandedIds = {};

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final node in widget.nodes) ..._buildNode(context, node, 0)],
    );
  }

  List<Widget> _buildNode(BuildContext context, ThemeTreeNode<T> node, int depth) {
    final id = identityHashCode(node);
    final expanded = _expandedIds.contains(id);
    final hasChildren = node.children.isNotEmpty;
    final scheme = Theme.of(context).colorScheme;

    final row = InkWell(
      onTap: () {
        widget.onNodeTap?.call(node);
        if (hasChildren) {
          setState(() {
            expanded ? _expandedIds.remove(id) : _expandedIds.add(id);
          });
        }
      },
      child: Padding(
        padding: EdgeInsets.only(left: widget.indent * depth, top: 6, bottom: 6),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              child: hasChildren
                  ? AnimatedRotation(
                      turns: expanded ? 0.25 : 0,
                      duration: const Duration(milliseconds: 150),
                      child: Icon(Icons.chevron_right, size: 18, color: scheme.onSurface.withValues(alpha: 0.6)),
                    )
                  : null,
            ),
            if (node.icon != null) ...[
              Icon(node.icon, size: 16, color: scheme.onSurface.withValues(alpha: 0.7)),
              const SizedBox(width: 6),
            ],
            Text(node.resolveLabel(), style: AppTypography.bodyMedium),
          ],
        ),
      ),
    );

    return [
      row,
      if (hasChildren && expanded)
        for (final child in node.children) ..._buildNode(context, child, depth + 1),
    ];
  }
}
