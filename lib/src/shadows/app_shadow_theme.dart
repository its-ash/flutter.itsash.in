import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

/// Controls case transformation applied to headings and control labels
/// (buttons, chips, tabs, badges). [none] leaves text as authored;
/// [uppercase] forces `String.toUpperCase()` — the loud, stenciled look
/// Brutalism/Retro-8-bit/Bauhaus-style presets go for.
enum ThemeTextTransform { none, uppercase }

class AppShadowTheme extends ThemeExtension<AppShadowTheme> {
  const AppShadowTheme({
    this.none = const BoxShadow(
      color: Colors.transparent,
      blurRadius: 0,
      offset: Offset.zero,
    ),
    this.hairline = const BoxShadow(
      color: Color(0x0D11111A),
      blurRadius: 0,
      offset: Offset(0, 1),
    ),
    this.shadowOne = const BoxShadow(
      color: Color(0x1A11111A),
      blurRadius: 8,
      offset: Offset.zero,
    ),
    this.shadowTwo = const BoxShadow(
      color: Color(0x29000000),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
    this.shadowThree = const BoxShadow(
      color: Color(0x33000000),
      blurRadius: 12,
      offset: Offset(0, 8),
    ),
    this.cardShadows,
    this.buttonShadows,
    this.cardBlur = 0,
    this.cardBorderColor,
    this.cardBorderWidth = 0,
    this.borderColor,
    this.borderWidth = 0,
    this.forceFlat = false,
    this.textTransform = ThemeTextTransform.none,
  });

  const AppShadowTheme.dark({
    this.none = const BoxShadow(
      color: Colors.transparent,
      blurRadius: 0,
      offset: Offset.zero,
    ),
    this.hairline = const BoxShadow(
      color: Color(0x1FFFFFFF),
      blurRadius: 0,
      offset: Offset(0, 1),
    ),
    this.shadowOne = const BoxShadow(
      color: Color(0x99000000),
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
    this.shadowTwo = const BoxShadow(
      color: Color(0xB3000000),
      blurRadius: 14,
      offset: Offset(0, 6),
    ),
    this.shadowThree = const BoxShadow(
      color: Color(0xCC000000),
      blurRadius: 20,
      offset: Offset(0, 10),
    ),
    this.cardShadows,
    this.buttonShadows,
    this.cardBlur = 0,
    this.cardBorderColor,
    this.cardBorderWidth = 0,
    this.borderColor,
    this.borderWidth = 0,
    this.forceFlat = false,
    this.textTransform = ThemeTextTransform.none,
  });

  final BoxShadow none;
  final BoxShadow hairline;
  final BoxShadow shadowOne;
  final BoxShadow shadowTwo;
  final BoxShadow shadowThree;
  final List<BoxShadow>? cardShadows;
  final List<BoxShadow>? buttonShadows;

  /// Backdrop blur sigma for glass-style surfaces (e.g. glassmorphism).
  /// `0` means no blur — [ThemeCard] skips [BackdropFilter] entirely.
  final double cardBlur;

  /// Stroke color/width for the card's edge highlight (the "glass rim"
  /// in glassmorphism). `cardBorderWidth == 0` draws no border.
  final Color? cardBorderColor;
  final double cardBorderWidth;

  /// Shared stroke color/width for surface-like components other than the
  /// card (buttons, chips, inputs, dialogs, menus, dropdowns, badges/pills,
  /// snackbars/toast/banner, tabs, nav bars, switches/checkboxes/radio
  /// track, sliders, avatars, tooltips, data tables, list tiles, segmented
  /// buttons, progress indicators). `borderWidth == 0` draws no border.
  /// Components that need a different scale (e.g. a thinner border on a
  /// small badge than on a card) may apply their own multiplier on top of
  /// this shared pair instead of introducing a bespoke field.
  final Color? borderColor;
  final double borderWidth;

  /// When `true`, every component must render fully flat: no backdrop
  /// blur, no decorative translucency/gradient. Authoritative over
  /// [cardBlur] — consumers should treat effective blur as
  /// `forceFlat ? 0 : cardBlur`. Functional/animated effects (e.g.
  /// [ThemeShimmer]'s loading sweep) are not decorative and stay enabled
  /// even when this is `true`.
  final bool forceFlat;

  /// Case transform applied to headings and control labels (buttons,
  /// chips, tabs, badges). See [ThemeTextTransform].
  final ThemeTextTransform textTransform;

  /// Shadows for a card surface. Defaults to a subtle two-layer lift.
  /// Per-style presets override [cardShadows] to match the design language.
  List<BoxShadow> get cardShadow => cardShadows ?? [hairline, shadowOne];

  /// Shadows for an elevated button. Defaults to a single soft drop.
  /// Neumorphism/brutalism/claymorphism presets override [buttonShadows].
  List<BoxShadow> get buttonShadow =>
      buttonShadows ?? ([shadowOne].where((s) => s.color != Colors.transparent).toList());

  /// Shadows for a dialog / sheet — the heaviest lift.
  List<BoxShadow> get dialogShadow => [shadowTwo, shadowThree];

  /// Returns a copy with every non-neutral shadow color hue-shifted by
  /// [hueDelta] degrees — used by `AppThemeGenerator.generate` so a style
  /// with colorful shadows (Maximalism's pink/yellow/blue stack,
  /// Cyberpunk's magenta/cyan, etc.) follows a user-picked seed color
  /// instead of staying hardcoded to the style's original palette. Each
  /// shadow keeps its own saturation, lightness, and alpha, and the *same*
  /// delta is applied to every shadow — so a multi-color stack (e.g. three
  /// different hues layered for depth) keeps its relative hue spread and
  /// still reads as multi-tone, just rotated to orbit the new seed color
  /// instead of collapsing onto one flat hue. Colors close to neutral (low
  /// saturation — blacks, whites, greys) are left untouched, since shifting
  /// a neutral's hue does nothing perceptible.
  AppShadowTheme hueShifted(double hueDelta) {
    BoxShadow shift(BoxShadow shadow) {
      final hsl = HSLColor.fromColor(shadow.color);
      if (hsl.saturation < 0.12) return shadow;
      final hue = (hsl.hue + hueDelta) % 360;
      return shadow.copyWith(color: hsl.withHue(hue < 0 ? hue + 360 : hue).toColor());
    }

    return copyWith(
      hairline: shift(hairline),
      shadowOne: shift(shadowOne),
      shadowTwo: shift(shadowTwo),
      shadowThree: shift(shadowThree),
      cardShadows: cardShadows?.map(shift).toList(),
      buttonShadows: buttonShadows?.map(shift).toList(),
      cardBorderColor: cardBorderColor == null ? null : shift(BoxShadow(color: cardBorderColor!)).color,
      borderColor: borderColor == null ? null : shift(BoxShadow(color: borderColor!)).color,
    );
  }

  @override
  AppShadowTheme copyWith({
    BoxShadow? none,
    BoxShadow? hairline,
    BoxShadow? shadowOne,
    BoxShadow? shadowTwo,
    BoxShadow? shadowThree,
    List<BoxShadow>? cardShadows,
    List<BoxShadow>? buttonShadows,
    double? cardBlur,
    Color? cardBorderColor,
    double? cardBorderWidth,
    Color? borderColor,
    double? borderWidth,
    bool? forceFlat,
    ThemeTextTransform? textTransform,
  }) {
    return AppShadowTheme(
      none: none ?? this.none,
      hairline: hairline ?? this.hairline,
      shadowOne: shadowOne ?? this.shadowOne,
      shadowTwo: shadowTwo ?? this.shadowTwo,
      shadowThree: shadowThree ?? this.shadowThree,
      cardShadows: cardShadows ?? this.cardShadows,
      buttonShadows: buttonShadows ?? this.buttonShadows,
      cardBlur: cardBlur ?? this.cardBlur,
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      cardBorderWidth: cardBorderWidth ?? this.cardBorderWidth,
      borderColor: borderColor ?? this.borderColor,
      borderWidth: borderWidth ?? this.borderWidth,
      forceFlat: forceFlat ?? this.forceFlat,
      textTransform: textTransform ?? this.textTransform,
    );
  }

  @override
  AppShadowTheme lerp(ThemeExtension<AppShadowTheme>? other, double t) {
    if (other is! AppShadowTheme) return this;
    return AppShadowTheme(
      none: BoxShadow.lerp(none, other.none, t) ?? none,
      hairline: BoxShadow.lerp(hairline, other.hairline, t) ?? hairline,
      shadowOne: BoxShadow.lerp(shadowOne, other.shadowOne, t) ?? shadowOne,
      shadowTwo: BoxShadow.lerp(shadowTwo, other.shadowTwo, t) ?? shadowTwo,
      shadowThree:
          BoxShadow.lerp(shadowThree, other.shadowThree, t) ?? shadowThree,
      cardShadows: t < 0.5 ? cardShadows : other.cardShadows,
      buttonShadows: t < 0.5 ? buttonShadows : other.buttonShadows,
      cardBlur: lerpDouble(cardBlur, other.cardBlur, t) ?? cardBlur,
      cardBorderColor: Color.lerp(cardBorderColor, other.cardBorderColor, t),
      cardBorderWidth:
          lerpDouble(cardBorderWidth, other.cardBorderWidth, t) ?? cardBorderWidth,
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      borderWidth: lerpDouble(borderWidth, other.borderWidth, t) ?? borderWidth,
      forceFlat: t < 0.5 ? forceFlat : other.forceFlat,
      textTransform: t < 0.5 ? textTransform : other.textTransform,
    );
  }
}
