import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

class AppMiscTheme {
  AppMiscTheme._();

  static BadgeThemeData badgeTheme(ColorScheme scheme) => BadgeThemeData(
    backgroundColor: scheme.error,
    textColor: scheme.onPrimary,
    smallSize: 6,
    largeSize: 16,
    padding: const EdgeInsets.symmetric(horizontal: 4),
  );

  static BottomSheetThemeData bottomSheetTheme(ColorScheme scheme, AppShadowTheme shadows) =>
      BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        elevation: 1,
        modalElevation: 4,
        shadowColor: shadows.shadowTwo.color,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        showDragHandle: true,
        dragHandleColor: scheme.onSurface.withValues(alpha: 0.4),
      );

  static BottomAppBarThemeData bottomAppBarTheme(ColorScheme scheme, AppShadowTheme shadows) =>
      BottomAppBarThemeData(
        color: scheme.surface,
        elevation: 3,
        shadowColor: shadows.shadowOne.color,
        height: 80,
      );

  static WidgetStateProperty<Color?> _segmentedBackground(Color active) =>
      WidgetStateProperty.resolveWith<Color?>((states) {
        return states.contains(WidgetState.selected) ? active : Colors.transparent;
      });

  static WidgetStateProperty<Color?> _segmentedForeground(Color active, Color inactive) =>
      WidgetStateProperty.resolveWith<Color?>((states) {
        return states.contains(WidgetState.selected) ? active : inactive;
      });

  static SegmentedButtonThemeData segmentedButtonTheme(
    ColorScheme scheme, {
    double radius = 12,
    BorderSide? side,
  }) => SegmentedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: _segmentedBackground(scheme.primary),
      foregroundColor: _segmentedForeground(scheme.onPrimary, scheme.onSurface),
      side: WidgetStatePropertyAll(side ?? BorderSide(color: scheme.outline)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
    ),
  );

  static TextSelectionThemeData textSelectionTheme(ColorScheme scheme) =>
      TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.3),
        selectionHandleColor: scheme.primary,
      );

  static DataTableThemeData dataTableTheme(ColorScheme scheme, TextTheme textTheme) {
    return DataTableThemeData(
      headingRowColor: WidgetStatePropertyAll(
        Color.alphaBlend(scheme.onSurface.withValues(alpha: 0.08), scheme.surface),
      ),
      dataRowColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return scheme.primary.withValues(alpha: 0.12);
        }
        return Colors.transparent;
      }),
      dataRowMinHeight: 48,
      dataRowMaxHeight: 56,
      headingTextStyle: (textTheme.labelLarge ?? const TextStyle()).copyWith(
        color: scheme.onSurface,
      ),
      dataTextStyle: (textTheme.bodyMedium ?? const TextStyle()).copyWith(
        color: scheme.onSurface,
      ),
      dividerThickness: 1,
    );
  }

  static CarouselViewThemeData carouselViewTheme(ColorScheme scheme) => CarouselViewThemeData(
    backgroundColor: scheme.surface,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  );

  static ScrollbarThemeData scrollbarTheme(ColorScheme scheme) => ScrollbarThemeData(
    thumbColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.4)),
    trackColor: WidgetStatePropertyAll(scheme.onSurface.withValues(alpha: 0.08)),
    trackBorderColor: const WidgetStatePropertyAll(Colors.transparent),
    radius: const Radius.circular(8),
    thickness: const WidgetStatePropertyAll(8),
    thumbVisibility: const WidgetStatePropertyAll(false),
  );

  static const ActionIconThemeData actionIconTheme = ActionIconThemeData(
    backButtonIconBuilder: _backButtonIconBuilder,
    closeButtonIconBuilder: _closeButtonIconBuilder,
    drawerButtonIconBuilder: _drawerButtonIconBuilder,
    endDrawerButtonIconBuilder: _drawerButtonIconBuilder,
  );

  static Widget _backButtonIconBuilder(BuildContext context) => const Icon(Icons.arrow_back);

  static Widget _closeButtonIconBuilder(BuildContext context) => const Icon(Icons.close);

  static Widget _drawerButtonIconBuilder(BuildContext context) => const Icon(Icons.menu);

  static TabBarThemeData tabBarTheme(ColorScheme scheme, TextTheme textTheme) => TabBarThemeData(
    indicatorColor: scheme.primary,
    indicatorSize: TabBarIndicatorSize.label,
    dividerColor: scheme.outline,
    labelColor: scheme.primary,
    labelStyle: textTheme.labelLarge,
    unselectedLabelColor: scheme.onSurface.withValues(alpha: 0.6),
    unselectedLabelStyle: textTheme.labelLarge,
    overlayColor: WidgetStatePropertyAll(scheme.primary.withValues(alpha: 0.08)),
  );

  static ButtonThemeData buttonTheme(ColorScheme scheme) => ButtonThemeData(
    minWidth: 64,
    height: 48,
    buttonColor: scheme.primary,
    disabledColor: scheme.onSurface.withValues(alpha: 0.12),
    highlightColor: scheme.onSurface.withValues(alpha: 0.1),
    splashColor: scheme.onSurface.withValues(alpha: 0.1),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static ToggleButtonsThemeData toggleButtonsTheme(ColorScheme scheme) =>
      ToggleButtonsThemeData(
        color: scheme.onSurface,
        selectedColor: scheme.onPrimary,
        fillColor: scheme.primary,
        disabledColor: scheme.onSurface.withValues(alpha: 0.38),
        borderColor: scheme.outline,
        selectedBorderColor: scheme.primary,
        borderRadius: BorderRadius.circular(12),
        borderWidth: 1,
      );
}
