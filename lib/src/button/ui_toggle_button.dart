import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiToggleButton extends StatelessWidget {
  const UiToggleButton({
    super.key,
    required this.value,
    required this.onChanged,
    this.icon = Icons.favorite_border_rounded,
    this.selectedIcon = Icons.favorite_rounded,
    this.tooltip,
    this.activeColor,
    this.size = UiSize.md,
    this.filled = true,
  });

  const UiToggleButton.bookmark({
    super.key,
    required this.value,
    required this.onChanged,
    this.tooltip = 'Save',
    this.activeColor,
    this.size = UiSize.md,
    this.filled = true,
  })  : icon = Icons.bookmark_border_rounded,
        selectedIcon = Icons.bookmark_rounded;

  final bool value;
  final ValueChanged<bool>? onChanged;
  final IconData icon;
  final IconData selectedIcon;
  final String? tooltip;
  final Color? activeColor;
  final UiSize size;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final cb = onChanged;
    final (dim, iconSize) = switch (size) {
      UiSize.sm => (36.0, 18.0),
      UiSize.md => (44.0, 22.0),
      UiSize.lg => (56.0, 26.0),
    };
    final on = activeColor ?? (icon == Icons.favorite_border_rounded ? context.palette.sale : cs.primary);
    return Semantics(
      toggled: value,
      label: tooltip == null ? 'Toggle' : null,
      child: IconButton(
        tooltip: tooltip,
        isSelected: value,
        onPressed: cb == null ? null : () => cb(!value),
        style: IconButton.styleFrom(
          fixedSize: Size.square(dim),
          minimumSize: Size.square(dim),
          padding: EdgeInsets.zero,
          backgroundColor: filled ? cs.surfaceContainerHigh : Colors.transparent,
          shape: const CircleBorder(),
        ),
        icon: AnimatedSwitcher(
          duration: UiDuration.fast,
          transitionBuilder: (c, a) => ScaleTransition(
            scale: Tween(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutBack)),
            child: c,
          ),
          child: Icon(
            value ? selectedIcon : icon,
            key: ValueKey(value),
            size: iconSize,
            color: value ? on : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
