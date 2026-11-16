import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale of the design system.
///
/// Nova type ramp (see `DESIGN.md`): Outfit, a geometric sans, in three
/// weights (regular 400, medium 500, semibold 600), no letter spacing.
/// Headings are semibold, titles and labels medium, body text regular.
///
/// | Style | Use | Size / line | Weight |
/// |---|---|---|---|
/// | displayLarge | hero numbers | 48 / 56 | 600 |
/// | displayMedium | big totals | 40 / 48 | 600 |
/// | displaySmall | screen title ("CART") | 32 / 40 | 600 |
/// | headlineLarge | H1 | 28 / 36 | 600 |
/// | headlineMedium | H2, product name | 24 / 32 | 600 |
/// | headlineSmall | H3, price | 22 / 28 | 600 |
/// | titleLarge | app bar, card title | 20 / 26 | 500 |
/// | titleMedium | section title, list title | 17 / 24 | 500 |
/// | titleSmall | small title | 15 / 20 | 500 |
/// | bodyLarge | lead text | 17 / 24 | 400 |
/// | bodyMedium | body | 15 / 22 | 400 |
/// | bodySmall | caption (muted) | 13 / 18 | 400 |
/// | labelLarge | buttons, chips | 15 / 20 | 500 |
/// | labelMedium | small buttons, tags | 13 / 16 | 500 |
/// | labelSmall | badges | 11 / 14 | 500 |
///
/// The default font is Outfit (from `google_fonts`). Pass a `fontFamily` to
/// `UiTheme.light` / `UiTheme.dark` to use a bundled font instead, or set
/// [UiTypography.useGoogleFonts] to `false` (tests, offline builds) to fall
/// back to the platform font.
abstract final class UiTypography {
  /// When false, no font is fetched from Google Fonts.
  static bool useGoogleFonts = true;

  /// Builds the [TextTheme] for one palette.
  static TextTheme textTheme({required Color text, required Color muted, String? fontFamily}) {
    TextStyle s(double size, double line, FontWeight w, {Color? color}) => TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      fontWeight: w,
      height: line / size,
      letterSpacing: 0,
      color: color ?? text,
    );
    const bold = FontWeight.w600;
    const medium = FontWeight.w500;
    const regular = FontWeight.w400;

    final base = TextTheme(
      displayLarge: s(48, 56, bold),
      displayMedium: s(40, 48, bold),
      displaySmall: s(32, 40, bold),
      headlineLarge: s(28, 36, bold),
      headlineMedium: s(24, 32, bold),
      headlineSmall: s(22, 28, bold),
      titleLarge: s(20, 26, medium),
      titleMedium: s(17, 24, medium),
      titleSmall: s(15, 20, medium),
      bodyLarge: s(17, 24, regular),
      bodyMedium: s(15, 22, regular),
      bodySmall: s(13, 18, regular, color: muted),
      labelLarge: s(15, 20, medium),
      labelMedium: s(13, 16, medium),
      labelSmall: s(11, 14, medium),
    );
    if (fontFamily != null || !useGoogleFonts) return base;
    return GoogleFonts.outfitTextTheme(base);
  }

  /// Monospaced style for codes, OTPs, IDs and tabular numbers.
  static TextStyle mono({double fontSize = 14, FontWeight fontWeight = FontWeight.w500, Color? color}) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFamily: 'monospace',
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return useGoogleFonts ? GoogleFonts.jetBrainsMono(textStyle: style) : style;
  }
}
