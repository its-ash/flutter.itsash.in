import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// One entry of a [UiMenu]: an action row or a divider.
class UiMenuItem<T> {
  const UiMenuItem(
    T this.value,
    String this.label, {
    this.icon,
    this.destructive = false,
    this.shortcut,
    this.enabled = true,
  }) : isDivider = false;

  /// A thin line between groups of items.
  const UiMenuItem.divider()
    : value = null,
      label = null,
      icon = null,
      destructive = false,
      shortcut = null,
      enabled = false,
      isDivider = true;

  /// Returned when the item is picked.
  final T? value;
  final String? label;
  final IconData? icon;

  /// Danger color, for delete-like actions.
  final bool destructive;

  /// Hint shown on the right, e.g. `⌘C`.
  final String? shortcut;
  final bool enabled;
  final bool isDivider;
}

/// Popup menus anchored to a widget or a screen position.
///
/// ```dart
/// final v = await UiMenu.show(context, items: [UiMenuItem('edit', 'Edit', icon: Icons.edit_outlined)]);
/// ```
abstract final class UiMenu {
  /// Opens a menu and returns the picked value, or null when dismissed.
  ///
  /// The menu opens at [position] (global coordinates) when given. Otherwise
  /// it opens below the widget of [anchorKey], or below [context]'s widget.
  static Future<T?> show<T>(
    BuildContext context, {
    required List<UiMenuItem<T>> items,
    Offset? position,
    GlobalKey? anchorKey,
  }) {
    final overlay = Navigator.of(context).overlay!.context.findRenderObject()! as RenderBox;
    Rect rect;
    if (position != null) {
      final local = overlay.globalToLocal(position);
      rect = Rect.fromLTWH(local.dx, local.dy, 0, 0);
    } else {
      final box = (anchorKey?.currentContext ?? context).findRenderObject()! as RenderBox;
      final topLeft = box.localToGlobal(Offset.zero, ancestor: overlay);
      rect = Rect.fromLTWH(topLeft.dx, topLeft.dy + box.size.height + UiSpace.xs, box.size.width, 0);
    }
    return showMenu<T>(
      context: context,
      position: RelativeRect.fromRect(rect, Offset.zero & overlay.size),
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 300),
      popUpAnimationStyle: AnimationStyle(duration: context.motion(UiMotion.fast)),
      items: [
        for (final item in items)
          if (item.isDivider)
            const PopupMenuDivider(height: UiSpace.md)
          else
            PopupMenuItem<T>(
              value: item.value,
              enabled: item.enabled,
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
              child: _MenuRow(item: item),
            ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item});

  final UiMenuItem<Object?> item;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final fg = !item.enabled
        ? c.textDisabled
        : item.destructive
        ? c.danger
        : c.text;
    final iconColor = !item.enabled
        ? c.textDisabled
        : item.destructive
        ? c.danger
        : c.textMuted;
    return Row(
      children: [
        if (item.icon != null) ...[Icon(item.icon, size: 18, color: iconColor), const SizedBox(width: UiSpace.md)],
        Expanded(
          child: Text(
            item.label ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: t.bodyMedium?.copyWith(color: fg),
          ),
        ),
        if (item.shortcut != null) ...[
          const SizedBox(width: UiSpace.lg),
          Text(item.shortcut!, style: t.labelMedium?.copyWith(color: c.textSubtle)),
        ],
      ],
    );
  }
}

/// Icon button (or any [child]) that opens a [UiMenu] below itself.
///
/// ```dart
/// UiMenuButton<String>(items: const [UiMenuItem('rename', 'Rename')], onSelected: rename)
/// ```
/// A null [onSelected] disables the button. Pass a non-interactive [child]
/// (text, avatar); it becomes the tap target.
class UiMenuButton<T> extends StatelessWidget {
  const UiMenuButton({
    super.key,
    required this.items,
    required this.onSelected,
    this.child,
    this.icon = Icons.more_horiz_rounded,
    this.tooltip = 'More options',
  });

  final List<UiMenuItem<T>> items;
  final ValueChanged<T>? onSelected;

  /// Custom trigger. Defaults to an [IconButton] with [icon].
  final Widget? child;
  final IconData icon;
  final String tooltip;

  Future<void> _open(BuildContext context) async {
    final v = await UiMenu.show<T>(context, items: items);
    if (v != null) onSelected?.call(v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = onSelected != null;
    return Builder(
      builder: (ctx) {
        if (child == null) {
          return IconButton(tooltip: tooltip, onPressed: enabled ? () => _open(ctx) : null, icon: Icon(icon, size: 20));
        }
        return Semantics(
          button: true,
          enabled: enabled,
          label: tooltip,
          child: InkWell(
            borderRadius: UiRadius.all(UiRadius.md),
            onTap: enabled ? () => _open(ctx) : null,
            child: Opacity(opacity: enabled ? 1 : 0.5, child: child),
          ),
        );
      },
    );
  }
}
