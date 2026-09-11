import 'package:flutter/material.dart';

class ThemeDraggableList<T> extends StatefulWidget {
  const ThemeDraggableList({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.onReorder,
    this.leading,
    this.trailing,
    this.spacing = 8,
  });

  final List<T> items;
  final Widget Function(BuildContext, T, int) itemBuilder;
  final ValueChanged<List<T>>? onReorder;
  final Widget Function(BuildContext, T, int)? leading;
  final Widget Function(BuildContext, T, int)? trailing;
  final double spacing;

  @override
  State<ThemeDraggableList<T>> createState() => _ThemeDraggableListState<T>();
}

class _ThemeDraggableListState<T> extends State<ThemeDraggableList<T>> {
  late List<T> _items;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.items);
  }

  void _onReorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    widget.onReorder?.call(_items);
    setState(() {});
  }

  double _cardRadius(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = _cardRadius(context);
    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      onReorder: _onReorder,
      proxyDecorator: (child, _, __) => Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(radius),
        color: Colors.transparent,
        child: child,
      ),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        return Container(
          key: ValueKey(i),
          margin: EdgeInsets.only(bottom: widget.spacing),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.4)),
          ),
          child: Row(children: [
            if (widget.leading != null) widget.leading!(context, item, i),
            Expanded(child: widget.itemBuilder(context, item, i)),
            if (widget.trailing != null) widget.trailing!(context, item, i),
            ReorderableDragStartListener(
              index: i,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Icon(Icons.drag_indicator, color: scheme.onSurfaceVariant),
              ),
            ),
          ]),
        );
      },
    );
  }
}