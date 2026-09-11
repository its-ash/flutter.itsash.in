import 'package:flutter/material.dart';

import 'package:theme/theme.dart';

class ThemeController extends ValueNotifier<ThemeControllerState> {
  ThemeController()
      : super(const ThemeControllerState(
          mode: ThemeMode.light,
          styleId: 'material',
        ));

  void toggle() {
    value = value.copyWith(
      mode: value.mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
    );
  }

  void setMode(ThemeMode mode) => value = value.copyWith(mode: mode);

  /// Switches the base visual style. If the user has already picked a
  /// custom color/font via [ThemeCustomizer], that customization is kept
  /// and re-applied on top of the new style — so theme, color, and font
  /// stay independently choosable in any combination.
  void setStyle(String styleId) {
    final customization = value.customization;
    value = ThemeControllerState(
      mode: value.mode,
      styleId: styleId,
      generated: customization == null
          ? null
          : AppThemeGenerator.generate(
              seed: customization.seedColor,
              fontPairing: customization.pairing,
              headingFont: customization.headingFont,
              bodyFont: customization.bodyFont,
              baseStyle: AppThemeStyle.byId(styleId),
            ),
      customization: customization,
    );
  }

  /// Applies a generated custom theme (from [ThemeCustomizer]), overriding
  /// [styleId]'s stock colors/fonts until a preset style is picked again
  /// via [setStyle].
  ///
  /// Recolors/refonts whichever style is currently selected (`styleId`)
  /// rather than resetting to a plain default shape, so color/font/style
  /// stay fully independent — Brutalism stays square, Maximalism keeps its
  /// thick borders, etc. no matter what color or font is picked.
  void setGenerated(ThemeCustomizerResult result) {
    value = ThemeControllerState(
      mode: value.mode,
      styleId: value.styleId,
      generated: AppThemeGenerator.generate(
        seed: result.seedColor,
        fontPairing: result.pairing,
        headingFont: result.headingFont,
        bodyFont: result.bodyFont,
        baseStyle: AppThemeStyle.byId(value.styleId),
      ),
      customization: result,
    );
  }

  AppThemeStyle get style => value.generated ?? AppThemeStyle.byId(value.styleId);
}

class ThemeControllerState {
  const ThemeControllerState({
    required this.mode,
    required this.styleId,
    this.generated,
    this.customization,
  });

  final ThemeMode mode;
  final String styleId;

  /// Set when the user has customized a theme via [ThemeCustomizer] —
  /// takes precedence over [styleId] until a preset style is chosen again.
  final AppThemeStyle? generated;
  final ThemeCustomizerResult? customization;

  ThemeControllerState copyWith({ThemeMode? mode, String? styleId}) =>
      ThemeControllerState(
        mode: mode ?? this.mode,
        styleId: styleId ?? this.styleId,
        generated: generated,
        customization: customization,
      );
}
