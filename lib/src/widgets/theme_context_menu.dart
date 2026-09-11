import 'package:flutter/material.dart';

class ThemeContextMenu<T> extends StatelessWidget {
  const ThemeContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.onSelected,
  });

  final Widget child;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T>? onSelected;

  Future<void> _show(BuildContext context, Offset globalPosition) async {
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final result = await showMenu<T>(
      context: context,
      position: RelativeRect.fromRect(
        globalPosition & const Size(1, 1),
        Offset.zero & overlay.size,
      ),
      items: items,
    );
    if (result != null) onSelected?.call(result);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onSecondaryTapDown: (details) => _show(context, details.globalPosition),
      onLongPress: () {
        final box = context.findRenderObject() as RenderBox?;
        if (box == null) return;
        final center = box.localToGlobal(box.size.center(Offset.zero));
        _show(context, center);
      },
      child: child,
    );
  }
}
