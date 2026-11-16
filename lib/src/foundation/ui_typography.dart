import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale of the design system.
///
/// Ash Theme type ramp (mobile sizes): two weights, regular 400 and bold 600,
/// no letter spacing. The design uses SF Pro / Segoe UI, which cannot ship
/// on Android, so the default font is Inter, the closest open match.
///
/// | Style | Design style | Size / line |
/// |---|---|---|
/// | displayLarge | display / 50 | 50 / 60 |
/// | displayMedium | display / 37 | 37 / 44 |
/// | displaySmall, headlineLarge | H1 | 29 / 36 |
/// | headlineMedium | H2 | 24 / 32 |
/// | headlineSmall | H3 | 21 / 24 |
/// | titleLarge | H4 | 19 / 22 |
/// | titleMedium | H6 | 17 / 22 |
/// | titleSmall, labelLarge | body/normal bold | 14 / 20 |
/// | bodyLarge | medium | 16 / 22 |
/// | bodyMedium | body/normal regular | 14 / 20 |
/// | bodySmall, labelMedium | body/small | 12 / 16 |
/// | labelSmall | body/x_small | 10 / 14 |
///
/// The default font is Inter (from `google_fonts`). Pass a `fontFamily` to
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
    const regular = FontWeight.w400;

    final base = TextTheme(
      displayLarge: s(50, 60, bold),
      displayMedium: s(37, 44, bold),
      displaySmall: s(29, 36, bold),
      headlineLarge: s(29, 36, bold),
      headlineMedium: s(24, 32, bold),
      headlineSmall: s(21, 24, bold),
      titleLarge: s(19, 22, bold),
      titleMedium: s(17, 22, bold),
      titleSmall: s(14, 20, bold),
      bodyLarge: s(16, 22, regular),
      bodyMedium: s(14, 20, regular),
      bodySmall: s(12, 16, regular, color: muted),
      labelLarge: s(14, 20, bold),
      labelMedium: s(12, 16, bold),
      labelSmall: s(10, 14, bold),
    );
    if (fontFamily != null || !useGoogleFonts) return base;
    return GoogleFonts.interTextTheme(base);
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
