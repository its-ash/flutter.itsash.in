import 'package:flutter/material.dart';

class AppChipTheme {
  AppChipTheme._();

  static ChipThemeData theme(
    ColorScheme scheme,
    TextTheme textTheme, {
    double radius = 8,
    BorderSide? side,
  }) => ChipThemeData(
    backgroundColor: Color.alphaBlend(
      scheme.onSurface.withValues(alpha: 0.05),
      scheme.surface,
    ),
    selectedColor: scheme.primary.withValues(alpha: 0.16),
    disabledColor: scheme.onSurface.withValues(alpha: 0.12),
    deleteIconColor: scheme.onSurface.withValues(alpha: 0.6),
    checkmarkColor: scheme.primary,
    labelStyle: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
      color: scheme.onSurface,
      fontSize: 12,
    ),
    secondaryLabelStyle: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
      color: scheme.onPrimary,
      fontSize: 12,
    ),
    side: side ?? BorderSide(color: scheme.outline),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
    iconTheme: const IconThemeData(size: 16),
    avatarBoxConstraints: const BoxConstraints(maxHeight: 20, maxWidth: 20),
    deleteIconBoxConstraints: const BoxConstraints(maxHeight: 16, maxWidth: 16),
    elevation: 0,
    pressElevation: 1,
  );
}
