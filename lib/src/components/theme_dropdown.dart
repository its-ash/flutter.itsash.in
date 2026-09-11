import 'package:flutter/material.dart';

class ThemeDropdown<T> extends StatelessWidget {
  const ThemeDropdown({
    super.key,
    required this.items,
    this.initialSelection,
    this.onSelected,
    this.hintText,
    this.label,
    this.width,
    this.menuHeight,
  });

  final List<DropdownMenuEntry<T>> items;
  final T? initialSelection;
  final ValueChanged<T?>? onSelected;
  final String? hintText;
  final String? label;

  /// Field/menu width. Leave unset to size to content — the field then
  /// sizes to its widest entry instead of stretching to fill its parent.
  final double? width;

  /// Menu popup height. Defaults to just enough for up to ~6 compact
  /// entries (48px each) so short lists don't open an oversized menu.
  final double? menuHeight;

  double _inputRadius(BuildContext context) {
    final border = Theme.of(context).inputDecorationTheme.border;
    if (border is OutlineInputBorder) return border.borderRadius.topLeft.x;
    return 8;
  }

  @override
  Widget build(BuildContext context) {
    final resolvedMenuHeight =
        menuHeight ?? (items.length * 100.0).clamp(100.0, 280.0);
    return DropdownMenu<T>(
      inputDecorationTheme: InputDecorationTheme(
        isDense: true, // Reduces internal height/spacing
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 12, vertical: 8), // Tighter padding
        constraints: BoxConstraints.tight(const Size.fromHeight(
            40)), // Shrinks total height of the anchor box
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_inputRadius(context)),
        ),
      ),
      dropdownMenuEntries: items,
      initialSelection: initialSelection,
      onSelected: onSelected,
      hintText: hintText,
      label: label != null ? Text(label!) : null,
      width: width,
      menuHeight: resolvedMenuHeight,
      textStyle: const TextStyle(fontSize: 14),
    );
  }
}
