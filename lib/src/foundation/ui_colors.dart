import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_status.dart';

/// Semantic color palette of the design system.
///
/// There are exactly two palettes: [UiColors.light] and [UiColors.dark].
/// An app may pass its own `accent`; every other color is fixed so all apps
/// share one look.
///
/// Read it with `context.colors` (see `UiContext`).
@immutable
class UiColors extends ThemeExtension<UiColors> {
  const UiColors({
    required this.brightness,
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.surfaceRaised,
    required this.surfaceInverse,
    required this.onSurfaceInverse,
    required this.border,
    required this.borderStrong,
    required this.text,
    required this.textMuted,
    required this.textSubtle,
    required this.textDisabled,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.onAccentSoft,
    required this.success,
    required this.onSuccess,
    required this.successSoft,
    required this.onSuccessSoft,
    required this.warning,
    required this.onWarning,
    required this.warningSoft,
    required this.onWarningSoft,
    required this.danger,
    required this.onDanger,
    required this.dangerSoft,
    required this.onDangerSoft,
    required this.info,
    required this.onInfo,
    required this.infoSoft,
    required this.onInfoSoft,
    required this.scrim,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.chart,
  });

  /// Default accent ("Primary", coral). See `DESIGN.md`.
  static const Color defaultAccentLight = Color(0xFFFF7E70);

  /// Dark-mode default accent: the same coral, a touch lighter so it keeps
  /// contrast on the dark background.
  static const Color defaultAccentDark = Color(0xFFFF8F83);

  /// Light "Overlay" fill: a violet-gray at 10%. Translucent, so it reads the
  /// same on the background, a card or a dialog (#F0EFF7 on white).
  static const Color overlay = Color(0x1A6B5FB0);

  /// Dark "Overlay" fill: a lavender white at 10%.
  static const Color overlayDark = Color(0x1AC9C2FF);

  /// Violet-tinted gray scale, steps 1..9 (light mode). 1 is the background,
  /// 9 the foreground.
  static const List<Color> grayLight = [
    Color(0xFFFFFFFF), Color(0xFFF7F6FB), Color(0xFFECEBF2), Color(0xFFD9D7E3), Color(0xFFB3B0C2), //
    Color(0xFF8C899E), Color(0xFF5E5B70), Color(0xFF2E2C3A), Color(0xFF121216),
  ];

  /// Gray scale steps 1..9 in dark mode.
  static const List<Color> grayDark = [
    Color(0xFF0E0E12), Color(0xFF18171F), Color(0xFF26252F), Color(0xFF383646), Color(0xFF5A5770), //
    Color(0xFF8C899E), Color(0xFFB9B6C8), Color(0xFFE4E2EE), Color(0xFFF7F6FB),
  ];

  /// The light palette. Pass [accent] to use a custom brand color.
  factory UiColors.light({Color? accent}) {
    const g = grayLight;
    final a = accent ?? defaultAccentLight;
    return UiColors(
      brightness: Brightness.light,
      background: g[0],
      surface: g[1],
      surfaceMuted: overlay,
      surfaceRaised: g[0],
      surfaceInverse: const Color(0xFF161616),
      onSurfaceInverse: g[0],
      border: g[2],
      borderStrong: g[3],
      text: g[8],
      textMuted: g[6],
      textSubtle: g[5],
      textDisabled: g[4],
      accent: a,
      onAccent: _on(a),
      accentSoft: a.withValues(alpha: 0.12),
      onAccentSoft: _shade(a, maxLightness: 0.45),
      success: const Color(0xFF17B26A),
      onSuccess: Colors.white,
      successSoft: const Color(0x1F17B26A),
      onSuccessSoft: const Color(0xFF067647),
      warning: const Color(0xFFF2B705),
      onWarning: g[8],
      warningSoft: const Color(0x2EF2B705),
      onWarningSoft: const Color(0xFF8A6500),
      danger: const Color(0xFFE5484D),
      onDanger: Colors.white,
      dangerSoft: const Color(0x17E5484D),
      onDangerSoft: const Color(0xFFD12F35),
      info: const Color(0xFF3B82F6),
      onInfo: Colors.white,
      infoSoft: const Color(0x1A3B82F6),
      onInfoSoft: const Color(0xFF1D5BC6),
      scrim: const Color(0x66121216),
      shimmerBase: g[1],
      shimmerHighlight: g[0],
      chart: [
        a,
        const Color(0xFF2BC9A0),
        const Color(0xFFF5A524),
        const Color(0xFFE5484D),
        const Color(0xFF3B82F6),
        const Color(0xFFD65DB1),
        const Color(0xFF8BC34A),
        const Color(0xFF5E5B70),
      ],
    );
  }

  /// The dark palette. Pass [accent] to use a custom brand color; it is
  /// lightened when needed so it stays readable on dark surfaces.
  factory UiColors.dark({Color? accent}) {
    const g = grayDark;
    final a = accent == null ? defaultAccentDark : _tint(accent, minLightness: 0.6);
    return UiColors(
      brightness: Brightness.dark,
      background: g[0],
      surface: g[1],
      surfaceMuted: overlayDark,
      surfaceRaised: const Color(0xFF201F29),
      surfaceInverse: g[8],
      onSurfaceInverse: g[0],
      border: g[2],
      borderStrong: g[3],
      text: g[8],
      textMuted: g[6],
      textSubtle: g[5],
      textDisabled: g[4],
      accent: a,
      onAccent: _on(a),
      accentSoft: a.withValues(alpha: 0.2),
      onAccentSoft: _tint(a, minLightness: 0.8),
      success: const Color(0xFF3CCB8A),
      onSuccess: g[0],
      successSoft: const Color(0x333CCB8A),
      onSuccessSoft: const Color(0xFF75E0AE),
      warning: const Color(0xFFF5C330),
      onWarning: g[0],
      warningSoft: const Color(0x33F5C330),
      onWarningSoft: const Color(0xFFF8D574),
      danger: const Color(0xFFF0656A),
      onDanger: g[0],
      dangerSoft: const Color(0x33F0656A),
      onDangerSoft: const Color(0xFFF79A9D),
      info: const Color(0xFF60A0FA),
      onInfo: g[0],
      infoSoft: const Color(0x3360A0FA),
      onInfoSoft: const Color(0xFF9CC4FC),
      scrim: const Color(0x99000000),
      shimmerBase: g[1],
      shimmerHighlight: g[2],
      chart: [
        a,
        const Color(0xFF4FD8B4),
        const Color(0xFFF7B955),
        const Color(0xFFF0656A),
        const Color(0xFF60A0FA),
        const Color(0xFFE283C8),
        const Color(0xFFA5D46F),
        const Color(0xFFB9B6C8),
      ],
    );
  }

  final Brightness brightness;

  /// App canvas behind everything (scaffold background).
  final Color background;

  /// Cards, sheets, app bars, list groups.
  final Color surface;

  /// Subtle fills: inputs, hovered rows, tracks, "dim" buttons and controls.
  /// Translucent (the design's Overlay), so it works on any surface. Use
  /// `Color.alphaBlend(surfaceMuted, surface)` where an opaque color is needed.
  final Color surfaceMuted;

  /// Floating layers: menus, popovers, dialogs.
  final Color surfaceRaised;

  /// Tooltips and snackbars.
  final Color surfaceInverse;
  final Color onSurfaceInverse;

  /// Hairline borders and dividers (translucent Overlay).
  final Color border;

  /// Borders of interactive controls (checkbox, outline button).
  final Color borderStrong;

  /// Primary text and icons.
  final Color text;

  /// Secondary text: subtitles, descriptions.
  final Color textMuted;

  /// Tertiary text: hints, captions, placeholders.
  final Color textSubtle;

  /// Text and icons of disabled controls.
  final Color textDisabled;

  final Color accent;
  final Color onAccent;

  /// Tinted accent background (selected rows, soft buttons, active nav pill).
  final Color accentSoft;

  /// Text and icons on [accentSoft].
  final Color onAccentSoft;

  final Color success;
  final Color onSuccess;
  final Color successSoft;
  final Color onSuccessSoft;
  final Color warning;
  final Color onWarning;
  final Color warningSoft;
  final Color onWarningSoft;
  final Color danger;
  final Color onDanger;
  final Color dangerSoft;
  final Color onDangerSoft;
  final Color info;
  final Color onInfo;
  final Color infoSoft;
  final Color onInfoSoft;

  /// Modal barrier color.
  final Color scrim;
  final Color shimmerBase;
  final Color shimmerHighlight;

  /// Eight distinct series colors for charts. Index with `chart[i % chart.length]`.
  final List<Color> chart;

  bool get isDark => brightness == Brightness.dark;

  /// Step [step] (1..9) of the design's gray scale for this mode: 1 is the
  /// background, 9 the foreground. Use it for the few spots the semantic
  /// colors do not cover (tracks, keys, rest bars).
  Color gray(int step) => (isDark ? grayDark : grayLight)[(step - 1).clamp(0, 8)];

  /// Opaque version of [surfaceMuted] on [surface].
  Color get surfaceMutedSolid => Color.alphaBlend(surfaceMuted, surface);

  /// The four colors of a [UiStatus].
  UiTone tone(UiStatus status) => switch (status) {
    UiStatus.neutral => UiTone(color: text, onColor: background, soft: surfaceMuted, onSoft: text),
    UiStatus.accent => UiTone(color: accent, onColor: onAccent, soft: accentSoft, onSoft: onAccentSoft),
    UiStatus.info => UiTone(color: info, onColor: onInfo, soft: infoSoft, onSoft: onInfoSoft),
    UiStatus.success => UiTone(color: success, onColor: onSuccess, soft: successSoft, onSoft: onSuccessSoft),
    UiStatus.warning => UiTone(color: warning, onColor: onWarning, soft: warningSoft, onSoft: onWarningSoft),
    UiStatus.danger => UiTone(color: danger, onColor: onDanger, soft: dangerSoft, onSoft: onDangerSoft),
  };

  /// Series color for chart index [i]; wraps around.
  Color chartColor(int i) => chart[i % chart.length];

  static UiColors of(BuildContext context) {
    final theme = Theme.of(context);
    return theme.extension<UiColors>() ?? (theme.brightness == Brightness.dark ? UiColors.dark() : UiColors.light());
  }

  @override
  UiColors copyWith({Color? accent}) {
    if (accent == null) return this;
    return isDark ? UiColors.dark(accent: accent) : UiColors.light(accent: accent);
  }

  @override
  UiColors lerp(covariant UiColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return UiColors(
      brightness: t < 0.5 ? brightness : other.brightness,
      background: c(background, other.background),
      surface: c(surface, other.surface),
      surfaceMuted: c(surfaceMuted, other.surfaceMuted),
      surfaceRaised: c(surfaceRaised, other.surfaceRaised),
      surfaceInverse: c(surfaceInverse, other.surfaceInverse),
      onSurfaceInverse: c(onSurfaceInverse, other.onSurfaceInverse),
      border: c(border, other.border),
      borderStrong: c(borderStrong, other.borderStrong),
      text: c(text, other.text),
      textMuted: c(textMuted, other.textMuted),
      textSubtle: c(textSubtle, other.textSubtle),
      textDisabled: c(textDisabled, other.textDisabled),
      accent: c(accent, other.accent),
      onAccent: c(onAccent, other.onAccent),
      accentSoft: c(accentSoft, other.accentSoft),
      onAccentSoft: c(onAccentSoft, other.onAccentSoft),
      success: c(success, other.success),
      onSuccess: c(onSuccess, other.onSuccess),
      successSoft: c(successSoft, other.successSoft),
      onSuccessSoft: c(onSuccessSoft, other.onSuccessSoft),
      warning: c(warning, other.warning),
      onWarning: c(onWarning, other.onWarning),
      warningSoft: c(warningSoft, other.warningSoft),
      onWarningSoft: c(onWarningSoft, other.onWarningSoft),
      danger: c(danger, other.danger),
      onDanger: c(onDanger, other.onDanger),
      dangerSoft: c(dangerSoft, other.dangerSoft),
      onDangerSoft: c(onDangerSoft, other.onDangerSoft),
      info: c(info, other.info),
      onInfo: c(onInfo, other.onInfo),
      infoSoft: c(infoSoft, other.infoSoft),
      onInfoSoft: c(onInfoSoft, other.onInfoSoft),
      scrim: c(scrim, other.scrim),
      shimmerBase: c(shimmerBase, other.shimmerBase),
      shimmerHighlight: c(shimmerHighlight, other.shimmerHighlight),
      chart: [for (var i = 0; i < chart.length; i++) c(chart[i], other.chart[i % other.chart.length])],
    );
  }

  // White on mid-tone accents (coral, violet, blue); near-black only on
  // really light ones (yellow, mint).
  static Color _on(Color c) => c.computeLuminance() > 0.45 ? const Color(0xFF121216) : Colors.white;

  static Color _shade(Color c, {required double maxLightness}) {
    final hsl = HSLColor.fromColor(c);
    return hsl.lightness <= maxLightness ? c : hsl.withLightness(maxLightness).toColor();
  }

  static Color _tint(Color c, {required double minLightness}) {
    final hsl = HSLColor.fromColor(c);
    return hsl.lightness >= minLightness ? c : hsl.withLightness(minLightness).toColor();
  }
}

/// The four colors that make up one [UiStatus]: a solid [color] with
/// [onColor] content, and a tinted [soft] background with [onSoft] content.
@immutable
class UiTone {
  const UiTone({required this.color, required this.onColor, required this.soft, required this.onSoft});

  final Color color;
  final Color onColor;
  final Color soft;
  final Color onSoft;
}
