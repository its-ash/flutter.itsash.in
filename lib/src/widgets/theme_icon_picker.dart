import 'package:flutter/material.dart';

class ThemeIconPicker extends StatelessWidget {
  const ThemeIconPicker({
    super.key,
    required this.icons,
    this.selected,
    this.onSelected,
    this.crossAxisCount = 6,
    this.iconSize = 22,
  });

  final List<IconData> icons;
  final IconData? selected;
  final ValueChanged<IconData>? onSelected;
  final int crossAxisCount;
  final double iconSize;

  /// Opens the picker in a bottom sheet and resolves to the chosen icon
  /// (or `null` if dismissed without a selection).
  static Future<IconData?> show(
    BuildContext context, {
    required List<IconData> icons,
    IconData? selected,
  }) {
    return showModalBottomSheet<IconData>(
      context: context,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: ThemeIconPicker(
          icons: icons,
          selected: selected,
          onSelected: (icon) => Navigator.pop(context, icon),
        ),
      ),
    );
  }

  double _buttonRadius(BuildContext context) {
    final shape = Theme.of(context).filledButtonTheme.style?.shape?.resolve({});
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = _buttonRadius(context);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: icons.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final icon = icons[index];
        final isSelected = icon == selected;
        return InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: () => onSelected?.call(icon),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? scheme.primary.withValues(alpha: 0.15) : Colors.transparent,
              border: Border.all(color: isSelected ? scheme.primary : scheme.outline),
              borderRadius: BorderRadius.circular(radius),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: iconSize, color: isSelected ? scheme.primary : scheme.onSurface),
          ),
        );
      },
    );
  }
}
