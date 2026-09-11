import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';
import 'package:theme/src/theme_presets/app_theme_preset.dart';
import 'package:theme/src/theme_presets/app_theme_style.dart';

/// A heading/body Google Fonts pairing. [heading] is used for
/// headline/title styles, [body] for body/label styles — a deliberately
/// different pair usually reads as more "designed" than one font used
/// everywhere.
class AppFontPairing {
  const AppFontPairing(this.name, this.heading, this.body);

  final String name;
  final String heading;
  final String body;

  TextStyle headingStyle([TextStyle textStyle = const TextStyle()]) =>
      GoogleFonts.getFont(heading, textStyle: textStyle);

  TextStyle bodyStyle([TextStyle textStyle = const TextStyle()]) =>
      GoogleFonts.getFont(body, textStyle: textStyle);
}

/// A small, curated set of heading+body Google Fonts pairs that read well
/// together — a convenience "Auto" default. [AppThemeGenerator.
/// suggestFontPairing] picks one automatically based on the seed color's
/// mood; [AppFontPairings.all] is the full list for a manual picker. For
/// picking the heading and body font independently instead, see
/// [AppFontCatalog].
class AppFontPairings {
  AppFontPairings._();

  static const bold = AppFontPairing('Bold', 'Poppins', 'Inter');
  static const classic = AppFontPairing('Classic', 'Merriweather', 'Source Sans 3');
  static const geometric = AppFontPairing('Geometric', 'Space Grotesk', 'Work Sans');
  static const editorial = AppFontPairing('Editorial', 'Playfair Display', 'Lato');
  static const friendly = AppFontPairing('Friendly', 'Baloo 2', 'Nunito');
  static const technical = AppFontPairing('Technical', 'IBM Plex Sans', 'IBM Plex Sans');

  static const List<AppFontPairing> all = [bold, classic, geometric, editorial, friendly, technical];
}

/// A curated list of individually-pickable Google Fonts family names,
/// grouped by category, for a free "pick any heading font + any body font"
/// UI (as opposed to [AppFontPairings]' fixed pairs). Any valid Google
/// Fonts family name works with [AppThemeGenerator.generate] even if it
/// isn't in this list — `GoogleFonts.getFont` resolves any family by name,
/// this list just gives a picker something reasonable to show.
class AppFontCatalog {
  AppFontCatalog._();

  static const Map<String, List<String>> byCategory = {
    'Sans-serif': [
      'Inter', 'Roboto', 'Open Sans', 'Lato', 'Work Sans', 'Nunito',
      'Source Sans 3', 'IBM Plex Sans', 'Manrope', 'Rubik',
    ],
    'Display / geometric': [
      'Poppins', 'Space Grotesk', 'Montserrat', 'Outfit', 'Sora',
      'Plus Jakarta Sans', 'Urbanist',
    ],
    'Serif': [
      'Merriweather', 'Playfair Display', 'Lora', 'PT Serif',
      'Source Serif 4', 'Libre Baskerville',
    ],
    'Rounded / friendly': [
      'Baloo 2', 'Quicksand', 'Comfortaa', 'Varela Round',
    ],
    'Monospace': [
      'JetBrains Mono', 'Roboto Mono', 'IBM Plex Mono', 'Space Mono',
    ],
  };

  static List<String> get all => byCategory.values.expand((f) => f).toList();
}

/// Predefined seed-color swatches for a quick-pick palette — a spread of
/// hues at consistent saturation/lightness so every option produces a
/// clean [ColorScheme.fromSeed] result.
class AppSeedPalette {
  AppSeedPalette._();

  static const List<Color> swatches = [
    Color(0xFF6750A4), // Material purple
    Color(0xFF1976D2), // Blue
    Color(0xFF00897B), // Teal
    Color(0xFF2E7D32), // Green
    Color(0xFFEF6C00), // Orange
    Color(0xFFD81B60), // Pink
    Color(0xFFE53935), // Red
    Color(0xFF6D4C41), // Brown
    Color(0xFF546E7A), // Blue grey
    Color(0xFF3949AB), // Indigo
    Color(0xFF00ACC1), // Cyan
    Color(0xFFFFB300), // Amber
  ];
}

/// Generates a complete, coherent [AppThemePreset] pair (light + dark) from
/// a single seed color, optionally paired with a font pairing.
///
/// Colors: [ColorScheme.fromSeed] (Material 3's own tonal-palette
/// algorithm — the same one Android 12+ Material You uses) derives every
/// other role (secondary, tertiary, containers, surfaces, etc.) from one
/// seed so the result is always internally coherent and contrast-safe.
///
/// Fonts: pass an explicit [AppFontPairing], or omit it to have
/// [suggestFontPairing] pick one automatically based on the seed color's
/// HSL mood (saturation/lightness) — bold saturated colors lean toward a
/// geometric/bold pairing, muted or pastel colors toward classic/editorial.
class AppThemeGenerator {
  AppThemeGenerator._();

  /// Picks a font pairing to match the seed color's mood. Loud, saturated
  /// colors read as bold/geometric; soft, muted, or pastel colors read as
  /// classic/editorial/friendly.
  static AppFontPairing suggestFontPairing(Color seed) {
    final hsl = HSLColor.fromColor(seed);
    final sat = hsl.saturation;
    final light = hsl.lightness;

    if (sat > 0.75 && light < 0.55) return AppFontPairings.bold;
    if (sat > 0.55 && hsl.hue >= 180 && hsl.hue < 300) return AppFontPairings.technical;
    if (sat < 0.35) return AppFontPairings.classic;
    if (light > 0.7) return AppFontPairings.friendly;
    if (hsl.hue < 40 || hsl.hue > 320) return AppFontPairings.editorial;
    return AppFontPairings.geometric;
  }

  static TextTheme _textTheme(String headingFont, String bodyFont, {required bool dark}) {
    final color = dark ? Colors.white : Colors.black87;
    final base = TextTheme(
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: color),
      headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: color),
      headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: color),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: color),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: color),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: color),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: color),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: color),
    );
    TextStyle heading(TextStyle s) => GoogleFonts.getFont(headingFont, textStyle: s);
    TextStyle body(TextStyle s) => GoogleFonts.getFont(bodyFont, textStyle: s);
    return base.copyWith(
      headlineLarge: heading(base.headlineLarge!),
      headlineMedium: heading(base.headlineMedium!),
      headlineSmall: heading(base.headlineSmall!),
      titleLarge: heading(base.titleLarge!),
      titleMedium: heading(base.titleMedium!),
      bodyLarge: body(base.bodyLarge!),
      bodyMedium: body(base.bodyMedium!),
      labelLarge: body(base.labelLarge!),
    );
  }

  /// Builds a full light+dark [AppThemeStyle] from [seed] (color) and a
  /// font choice — color, font, and the base visual style ([baseStyle]) are
  /// fully independent, so any combination of theme × color × font works.
  ///
  /// Font resolution, in priority order:
  /// 1. [headingFont]/[bodyFont] — pick any Google Fonts family name for
  ///    each independently (not limited to [AppFontCatalog] — any valid
  ///    family name works). Either can be omitted to fall back to the next
  ///    option for that slot only.
  /// 2. [fontPairing] — one of [AppFontPairings]' curated heading+body
  ///    pairs.
  /// 3. [suggestFontPairing] — auto-picked from the seed color's mood, used
  ///    for any slot not covered by 1 or 2.
  ///
  /// Pass [baseStyle] to recolor/refont an existing style (e.g. the user's
  /// currently-selected Brutalism/Maximalism/etc. preset) in place — every
  /// non-color, non-font aspect of it (radii, shadows, borders, elevation,
  /// blur) carries over unchanged, so picking a color or font doesn't also
  /// silently swap the whole visual style out from under the user. Omit it
  /// to fall back to a plain rounded-corner Material-ish shape.
  static AppThemeStyle generate({
    required Color seed,
    String? headingFont,
    String? bodyFont,
    AppFontPairing? fontPairing,
    AppThemeStyle? baseStyle,
    String id = 'generated',
    String name = 'Custom',
  }) {
    final pairing = fontPairing ?? suggestFontPairing(seed);
    final resolvedHeadingFont = headingFont ?? pairing.heading;
    final resolvedBodyFont = bodyFont ?? pairing.body;

    // ColorScheme.fromSeed snaps `primary` to the nearest Material 3 tonal
    // palette value — usually close to the seed, but not always identical.
    // The user picked this exact color for buttons/accents, so `primary`
    // (and its contrast-computed `onPrimary`) are pinned to it precisely;
    // every other role (secondary, tertiary, containers, surfaces, etc.)
    // still comes from the tonal algorithm, so the rest of the palette
    // stays coherent around the pick without contrast issues.
    final onSeed = seed.computeLuminance() > 0.5 ? Colors.black : Colors.white;
    final lightScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light)
        .copyWith(primary: seed, onPrimary: onSeed);
    final darkScheme = ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark)
        .copyWith(primary: seed, onPrimary: onSeed);

    final basePresetLight = baseStyle?.lightPreset ??
        const AppThemePreset(
          id: 'generated',
          name: 'Custom',
          brightness: Brightness.light,
          colorScheme: ColorScheme.light(),
          shadows: AppShadowTheme(),
          cardRadius: 16,
          buttonRadius: 20,
          inputRadius: 12,
          dialogRadius: 24,
        );
    final basePresetDark = baseStyle?.darkPreset ??
        const AppThemePreset(
          id: 'generated',
          name: 'Custom',
          brightness: Brightness.dark,
          colorScheme: ColorScheme.dark(),
          shadows: AppShadowTheme.dark(),
          cardRadius: 16,
          buttonRadius: 20,
          inputRadius: 12,
          dialogRadius: 24,
        );

    // Colorful shadows (Maximalism's pink/yellow/blue stack, Cyberpunk's
    // magenta/cyan, etc.) are hardcoded to the base style's own palette —
    // without this they'd stay e.g. pink no matter what seed color the
    // user actually picked. Rotate them by the same delta the seed color
    // moved from the base style's own primary, so a colorful shadow stack
    // follows the pick instead of silently ignoring it.
    final baseHue = HSLColor.fromColor(basePresetLight.colorScheme.primary).hue;
    final seedHue = HSLColor.fromColor(seed).hue;
    final hueDelta = seedHue - baseHue;

    Color? shiftColor(Color? color) {
      if (color == null) return null;
      final hsl = HSLColor.fromColor(color);
      if (hsl.saturation < 0.12) return color;
      final hue = (hsl.hue + hueDelta) % 360;
      return hsl.withHue(hue < 0 ? hue + 360 : hue).toColor();
    }

    return AppThemeStyle(
      id: id,
      name: name,
      // None of the built-in styles set `fontFamily` (they rely on
      // `textTheme` alone), so there's nothing to clear here today — but
      // if a future base style did, `toThemeData()` would still `.apply`
      // it on top of `textTheme` below and silently override this pairing.
      //
      // `cardBorderColor` is retinted here (not just on the AppShadowTheme
      // extension) because `AppThemePreset.toThemeData()` always rebuilds
      // the extension from the preset's own cardBorderColor field at
      // render time, which would otherwise overwrite any hue shift already
      // applied to the shadows extension.
      lightPreset: basePresetLight.copyWith(
        id: id,
        name: name,
        colorScheme: lightScheme,
        shadows: basePresetLight.shadows.hueShifted(hueDelta),
        cardBorderColor: shiftColor(basePresetLight.cardBorderColor),
        textTheme: _textTheme(resolvedHeadingFont, resolvedBodyFont, dark: false),
      ),
      darkPreset: basePresetDark.copyWith(
        id: id,
        name: name,
        colorScheme: darkScheme,
        shadows: basePresetDark.shadows.hueShifted(hueDelta),
        cardBorderColor: shiftColor(basePresetDark.cardBorderColor),
        textTheme: _textTheme(resolvedHeadingFont, resolvedBodyFont, dark: true),
      ),
    );
  }
}
