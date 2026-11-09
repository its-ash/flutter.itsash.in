import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type scale of the design system.
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
    TextStyle s(double size, FontWeight w, {double height = 1.3, double spacing = 0, Color? color}) => TextStyle(
          fontFamily: fontFamily,
          fontSize: size,
          fontWeight: w,
          height: height,
          letterSpacing: spacing,
          color: color ?? text,
        );

    final base = TextTheme(
      displayLarge: s(48, FontWeight.w700, height: 1.1, spacing: -1.4),
      displayMedium: s(40, FontWeight.w700, height: 1.1, spacing: -1.1),
      displaySmall: s(32, FontWeight.w700, height: 1.15, spacing: -0.8),
      headlineLarge: s(28, FontWeight.w700, height: 1.2, spacing: -0.6),
      headlineMedium: s(24, FontWeight.w700, height: 1.25, spacing: -0.4),
      headlineSmall: s(20, FontWeight.w600, height: 1.3, spacing: -0.3),
      titleLarge: s(18, FontWeight.w600, height: 1.35, spacing: -0.2),
      titleMedium: s(16, FontWeight.w600, height: 1.4, spacing: -0.1),
      titleSmall: s(14, FontWeight.w600, height: 1.4),
      bodyLarge: s(16, FontWeight.w400, height: 1.5),
      bodyMedium: s(14, FontWeight.w400, height: 1.5),
      bodySmall: s(12.5, FontWeight.w400, height: 1.45, color: muted),
      labelLarge: s(14, FontWeight.w600, height: 1.3),
      labelMedium: s(12.5, FontWeight.w600, height: 1.3),
      labelSmall: s(11, FontWeight.w600, height: 1.3, spacing: 0.4),
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
