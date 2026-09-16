import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

class AppDropdownTheme {
  AppDropdownTheme._();

  static const double menuElevation = 8;
  static const double radius = 16;

  static TextStyle textStyle(ColorScheme scheme) =>
      TextStyle(color: scheme.onSurface, fontSize: 14);

  static InputDecorationTheme inputDecorationTheme(ColorScheme scheme) =>
      InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radius),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        filled: true,
        fillColor: Colors.transparent,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      );

  static MenuStyle menuStyle(Color backgroundColor, AppShadowTheme shadows) {
    return MenuStyle(
      backgroundColor: WidgetStatePropertyAll(backgroundColor),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      ),
      elevation: const WidgetStatePropertyAll<double>(menuElevation),
      shadowColor: WidgetStatePropertyAll(shadows.shadowOne.color),
    );
  }

  static DropdownMenuThemeData theme(ColorScheme scheme, AppShadowTheme shadows) =>
      DropdownMenuThemeData(
        textStyle: textStyle(scheme),
        inputDecorationTheme: inputDecorationTheme(scheme),
        menuStyle: menuStyle(
          scheme.brightness == Brightness.dark ? scheme.surfaceContainerHigh : scheme.surface,
          shadows,
        ),
      );
}
