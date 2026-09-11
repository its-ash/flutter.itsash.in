import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:theme/src/typography/app_typography.dart';
import 'package:theme/src/shadows/app_shadow_theme.dart';
import 'package:theme/src/components/chip_theme.dart';
import 'package:theme/src/components/misc_theme.dart';

export 'package:theme/src/shadows/app_shadow_theme.dart' show ThemeTextTransform;

/// A complete theme preset: colors, typography, shadows, and shape.
///
/// Pass one to [AppThemePreset.fromPreset] (or use the named constructors
/// like [AppThemePreset.flat]) to generate a fully-themed [ThemeData] in
/// one line. Switching presets at runtime replaces every shadow, color,
/// and radius in the app.
class AppThemePreset {
  const AppThemePreset({
    required this.id,
    required this.name,
    required this.brightness,
    required this.colorScheme,
    required this.shadows,
    this.textTheme,
    this.cardRadius = 16,
    this.cardElevation = 0,
    this.cardMargin = 8,
    this.cardColor,
    this.buttonRadius = 12,
    this.buttonElevation = 0,
    this.inputRadius = 12,
    this.inputFilled = true,
    this.inputBorderWidth = 1,
    this.dialogRadius = 16,
    this.dialogElevation = 0,
    this.fontFamily,
    this.splashFactory,
    this.useMaterial3 = true,
    this.cardBlur = 0,
    this.cardBorderColor,
    this.cardBorderWidth = 0,
    this.borderColor,
    this.borderWidth = 0,
    this.forceFlat = false,
    this.textTransform = ThemeTextTransform.none,
    this.letterSpacingBoost = 0,
  });

  final String id;
  final String name;
  final Brightness brightness;
  final ColorScheme colorScheme;
  final AppShadowTheme shadows;
  final TextTheme? textTheme;
  final double cardRadius;
  final double cardElevation;
  final double cardMargin;
  final Color? cardColor;
  final double buttonRadius;
  final double buttonElevation;
  final double inputRadius;
  final bool inputFilled;
  final double inputBorderWidth;
  final double dialogRadius;
  final double dialogElevation;
  final String? fontFamily;
  final InteractiveInkFeatureFactory? splashFactory;
  final bool useMaterial3;

  /// Backdrop blur sigma applied behind surfaces (cards, dialogs) that
  /// declare a translucent [ColorScheme.surface]. `0` disables blur — the
  /// glassmorphism preset is the only style that sets this today.
  final double cardBlur;

  /// Card edge stroke (the "glass rim" in glassmorphism). `cardBorderWidth
  /// == 0` draws no border, matching prior behavior.
  final Color? cardBorderColor;
  final double cardBorderWidth;

  /// Shared stroke color/width for every other surface-like component
  /// (buttons, chips, inputs, dialogs, menus, dropdowns, badges/pills,
  /// snackbars, tabs, nav bars, switches/checkboxes/radio, sliders,
  /// avatars, tooltips, data tables, list tiles, segmented buttons,
  /// progress indicators). `borderWidth == 0` draws no border. A widget may
  /// apply its own multiplier on top of this shared pair when it needs a
  /// different scale than the rest (e.g. a thinner border on a small badge
  /// than on a full button).
  final Color? borderColor;
  final double borderWidth;

  /// When `true`, every component renders fully flat: no backdrop blur, no
  /// decorative translucency or gradient. Overrides [cardBlur]. Purely
  /// functional/animated effects (e.g. `ThemeShimmer`'s loading sweep)
  /// stay enabled regardless, since they aren't decorative.
  final bool forceFlat;

  /// Case transform applied to headings and control labels (buttons,
  /// chips, tabs, badges). See [ThemeTextTransform].
  final ThemeTextTransform textTransform;

  /// Extra letter-spacing (in logical pixels) added on top of each text
  /// style's own spacing — lets a preset track headings/labels out
  /// further without redefining the whole type scale. `0` leaves spacing
  /// untouched.
  final double letterSpacingBoost;

  /// Returns a copy with the given fields replaced — everything else
  /// (radii, shadows, elevation, blur, borders) stays as-is. Used to
  /// recolor a preset (e.g. from [AppThemeGenerator]) without losing the
  /// visual style (Brutalism's square corners, Maximalism's thick borders,
  /// etc.) that made it that preset in the first place.
  AppThemePreset copyWith({
    String? id,
    String? name,
    Brightness? brightness,
    ColorScheme? colorScheme,
    AppShadowTheme? shadows,
    TextTheme? textTheme,
    double? cardRadius,
    double? cardElevation,
    double? cardMargin,
    Color? cardColor,
    double? buttonRadius,
    double? buttonElevation,
    double? inputRadius,
    bool? inputFilled,
    double? inputBorderWidth,
    double? dialogRadius,
    double? dialogElevation,
    String? fontFamily,
    InteractiveInkFeatureFactory? splashFactory,
    bool? useMaterial3,
    double? cardBlur,
    Color? cardBorderColor,
    double? cardBorderWidth,
    Color? borderColor,
    double? borderWidth,
    bool? forceFlat,
    ThemeTextTransform? textTransform,
    double? letterSpacingBoost,
  }) {
    return AppThemePreset(
      id: id ?? this.id,
      name: name ?? this.name,
      brightness: brightness ?? this.brightness,
      colorScheme: colorScheme ?? this.colorScheme,
      shadows: shadows ?? this.shadows,
      textTheme: textTheme ?? this.textTheme,
      cardRadius: cardRadius ?? this.cardRadius,
      cardElevation: cardElevation ?? this.cardElevation,
      cardMargin: cardMargin ?? this.cardMargin,
      cardColor: cardColor ?? this.cardColor,
      buttonRadius: buttonRadius ?? this.buttonRadius,
      buttonElevation: buttonElevation ?? this.buttonElevation,
      inputRadius: inputRadius ?? this.inputRadius,
      inputFilled: inputFilled ?? this.inputFilled,
      inputBorderWidth: inputBorderWidth ?? this.inputBorderWidth,
      dialogRadius: dialogRadius ?? this.dialogRadius,
      dialogElevation: dialogElevation ?? this.dialogElevation,
      fontFamily: fontFamily ?? this.fontFamily,
      splashFactory: splashFactory ?? this.splashFactory,
      useMaterial3: useMaterial3 ?? this.useMaterial3,
      cardBlur: cardBlur ?? this.cardBlur,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      forceFlat: forceFlat ?? this.forceFlat,
      textTransform: textTransform ?? this.textTransform,
      letterSpacingBoost: letterSpacingBoost ?? this.letterSpacingBoost,
    );
  }

  static const _page = PageTransitionsTheme(builders: {
    TargetPlatform.android: ZoomPageTransitionsBuilder(),
    TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
    TargetPlatform.linux: ZoomPageTransitionsBuilder(),
    TargetPlatform.windows: ZoomPageTransitionsBuilder(),
    TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
  });

  /// Applies [letterSpacingBoost] on top of a style's own letter spacing.
  /// Case transform ([textTransform]) is applied at render time by the
  /// widget that owns the string (`AppTypography`/`ThemeText`/labels),
  /// since `TextStyle` itself carries no case-transform primitive.
  TextStyle _trackOut(TextStyle style) => letterSpacingBoost == 0
      ? style
      : style.copyWith(letterSpacing: (style.letterSpacing ?? 0) + letterSpacingBoost);

  TextTheme _applyTracking(TextTheme tt) => letterSpacingBoost == 0
      ? tt
      : tt.copyWith(
          displayLarge: tt.displayLarge == null ? null : _trackOut(tt.displayLarge!),
          displayMedium: tt.displayMedium == null ? null : _trackOut(tt.displayMedium!),
          displaySmall: tt.displaySmall == null ? null : _trackOut(tt.displaySmall!),
          headlineLarge: tt.headlineLarge == null ? null : _trackOut(tt.headlineLarge!),
          headlineMedium: tt.headlineMedium == null ? null : _trackOut(tt.headlineMedium!),
          headlineSmall: tt.headlineSmall == null ? null : _trackOut(tt.headlineSmall!),
          titleLarge: tt.titleLarge == null ? null : _trackOut(tt.titleLarge!),
          titleMedium: tt.titleMedium == null ? null : _trackOut(tt.titleMedium!),
          titleSmall: tt.titleSmall == null ? null : _trackOut(tt.titleSmall!),
          labelLarge: tt.labelLarge == null ? null : _trackOut(tt.labelLarge!),
          labelMedium: tt.labelMedium == null ? null : _trackOut(tt.labelMedium!),
          labelSmall: tt.labelSmall == null ? null : _trackOut(tt.labelSmall!),
        );

  /// Effective backdrop blur sigma — always `0` under [forceFlat].
  double get effectiveCardBlur => forceFlat ? 0 : cardBlur;

  BorderSide? get _borderSide =>
      borderWidth > 0 ? BorderSide(color: borderColor ?? colorScheme.outline, width: borderWidth) : null;

  ThemeData toThemeData() {
    final scheme = colorScheme;
    final isDark = brightness == Brightness.dark;
    final baseTextTheme = textTheme ??
        (isDark ? AppTypography.darkTextTheme : AppTypography.lightTextTheme);
    final fontApplied = fontFamily != null
        ? baseTextTheme.apply(fontFamily: fontFamily)
        : baseTextTheme;
    final tt = _applyTracking(fontApplied);
    final borderSide = _borderSide;
    return ThemeData(
      useMaterial3: useMaterial3,
      colorScheme: scheme,
      textTheme: tt,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      pageTransitionsTheme: _page,
      splashFactory: splashFactory ?? InkRipple.splashFactory,
      applyElevationOverlayColor: isDark,
      materialTapTargetSize: MaterialTapTargetSize.padded,

      primaryColor: scheme.primary,
      primaryColorLight: Color.lerp(scheme.primary, Colors.white, 0.3),
      primaryColorDark: Color.lerp(scheme.primary, Colors.black, 0.3),
      canvasColor: scheme.surface,
      cardColor: scheme.surface,
      scaffoldBackgroundColor: scheme.surface,
      shadowColor: shadows.shadowOne.color,
      dividerColor: scheme.outline,
      disabledColor: scheme.onSurface.withValues(alpha: 0.38),
      focusColor: scheme.onSurface.withValues(alpha: 0.1),
      highlightColor: scheme.onSurface.withValues(alpha: 0.1),
      hoverColor: scheme.onSurface.withValues(alpha: 0.08),
      splashColor: scheme.onSurface.withValues(alpha: 0.1),
      hintColor: scheme.onSurface.withValues(alpha: 0.6),
      unselectedWidgetColor: scheme.onSurface.withValues(alpha: 0.6),
      secondaryHeaderColor: Color.alphaBlend(scheme.secondary.withValues(alpha: 0.12), scheme.surface),

      iconTheme: IconThemeData(color: scheme.onSurface),
      primaryIconTheme: IconThemeData(color: scheme.onPrimary),
      primaryTextTheme: tt.apply(bodyColor: scheme.onPrimary, displayColor: scheme.onPrimary),
      typography: Typography.material2021(colorScheme: scheme),

      cardTheme: CardThemeData(
        color: cardColor ?? scheme.surface,
        elevation: cardElevation,
        margin: EdgeInsets.all(cardMargin),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: borderSide ?? BorderSide.none,
        ),
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
            side: borderSide ?? BorderSide.none,
          ),
          elevation: buttonElevation,
          textStyle: textTransform == ThemeTextTransform.uppercase
              ? const TextStyle(letterSpacing: 0.5)
              : null,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
            side: borderSide ?? BorderSide.none,
          ),
          elevation: buttonElevation,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          side: borderSide ?? BorderSide(color: scheme.outline, width: 1),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
        ),
      ),
      inputDecorationTheme: _inputDecorationTheme(scheme, borderSide),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: TextStyle(color: scheme.onSurface, fontSize: 14),
        inputDecorationTheme: _inputDecorationTheme(scheme, borderSide),
        menuStyle: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(
            brightness == Brightness.dark ? scheme.surfaceContainerHigh : scheme.surface,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(inputRadius),
              side: borderSide ?? BorderSide.none,
            ),
          ),
          elevation: const WidgetStatePropertyAll(8),
          shadowColor: WidgetStatePropertyAll(shadows.shadowOne.color),
        ),
      ),
      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(scheme.onSurface),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
          minimumSize: const WidgetStatePropertyAll(Size(64, 40)),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(dialogRadius),
          side: borderSide ?? BorderSide.none,
        ),
        backgroundColor: scheme.surface,
        elevation: dialogElevation,
      ),
      chipTheme: AppChipTheme.theme(scheme, tt, radius: buttonRadius, side: borderSide),
      segmentedButtonTheme: AppMiscTheme.segmentedButtonTheme(
        scheme,
        radius: buttonRadius,
        side: borderSide,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: buttonElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(buttonRadius),
          side: borderSide ?? BorderSide.none,
        ),
      ),
      // Switch's track and Radio's ring are hardcoded shapes in Flutter
      // itself (stadium / circle respectively — neither ThemeData exposes a
      // shape override), so only color/border follow the theme here; a
      // square-track switch or square radio isn't achievable without
      // replacing the widgets with custom-painted ones.
      switchTheme: SwitchThemeData(
        trackOutlineColor: borderSide != null
            ? WidgetStatePropertyAll(borderSide.color)
            : null,
        trackOutlineWidth: borderSide != null
            ? WidgetStatePropertyAll(borderSide.width)
            : null,
      ),
      radioTheme: RadioThemeData(side: borderSide),
      extensions: [
        shadows.copyWith(
          cardBlur: cardBlur,
          cardBorderColor: cardBorderColor,
          cardBorderWidth: cardBorderWidth,
          borderColor: borderColor,
          borderWidth: borderWidth,
          forceFlat: forceFlat,
          textTransform: textTransform,
        ),
      ],
    );
  }

  InputDecorationTheme _inputDecorationTheme(ColorScheme scheme, BorderSide? sharedBorder) {
    final width = sharedBorder?.width ?? inputBorderWidth;
    final color = sharedBorder?.color ?? scheme.outline;
    return InputDecorationTheme(
      filled: inputFilled,
      fillColor: scheme.surfaceContainerLow,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide(color: color, width: width),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide(color: color, width: width),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputRadius),
        borderSide: BorderSide(color: sharedBorder?.color ?? scheme.primary, width: width + 0.5),
      ),
    );
  }
}