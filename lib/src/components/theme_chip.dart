import 'package:flutter/material.dart';

import 'package:theme/src/typography/app_typography.dart';
import 'package:theme/src/shadows/app_shadow_theme.dart';

class ThemeChip extends StatelessWidget {
  const ThemeChip({
    super.key,
    required this.label,
    this.avatar,
    this.onDeleted,
    this.selected,
    this.onSelected,
  });

  final String label;
  final Widget? avatar;
  final VoidCallback? onDeleted;
  final bool? selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final shadows = Theme.of(context).extension<AppShadowTheme>() ?? const AppShadowTheme();
    final displayLabel =
        shadows.textTransform == ThemeTextTransform.uppercase ? label.toUpperCase() : label;
    if (selected != null && onSelected != null) {
      return ChoiceChip(
        label: Text(displayLabel),
        avatar: avatar,
        selected: selected!,
        onSelected: onSelected,
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      );
    }
    return Chip(
      label: Text(displayLabel),
      avatar: avatar,
      onDeleted: onDeleted,
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class ThemeChipButton extends StatelessWidget {
  const ThemeChipButton(this.label, this.onTap, {super.key, this.selected = false});

  final String label;
  final VoidCallback? onTap;
  final bool selected;

  double _buttonRadius(BuildContext context) {
    final shape = Theme.of(context).filledButtonTheme.style?.shape?.resolve({});
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 24;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final shadows = Theme.of(context).extension<AppShadowTheme>() ?? const AppShadowTheme();
    final displayLabel =
        shadows.textTransform == ThemeTextTransform.uppercase ? label.toUpperCase() : label;
    final borderColor = selected ? colorScheme.primary : Theme.of(context).dividerColor;
    final radius = BorderRadius.circular(_buttonRadius(context));
    return Material(
      type: MaterialType.transparency,
      shape: RoundedRectangleBorder(borderRadius: radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? colorScheme.primary : colorScheme.surface,
            borderRadius: radius,
            border: Border.all(
              color: shadows.borderWidth > 0 ? (shadows.borderColor ?? borderColor) : borderColor,
              width: shadows.borderWidth > 0 ? shadows.borderWidth : 1,
            ),
          ),
          child: Text(
            displayLabel,
            style: AppTypography.labelLarge.copyWith(
              color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
