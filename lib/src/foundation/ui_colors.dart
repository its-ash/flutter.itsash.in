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

  /// Default accent in both modes (Ash Theme "Primary", core/blue).
  static const Color defaultAccentLight = Color(0xFF3F88E4);

  /// Same as [defaultAccentLight]: the design keeps one primary in both modes.
  static const Color defaultAccentDark = Color(0xFF3F88E4);

  /// The neutral "Overlay" fill (#999999 at 20%). Translucent, so it reads
  /// the same on the background, a card or a dialog.
  static const Color overlay = Color(0x33999999);

  /// Gray scale of the Figma "Themes" collection, steps 1..9 (light mode).
  /// 1 is the background, 9 the foreground.
  static const List<Color> grayLight = [
    Color(0xFFFFFFFF), Color(0xFFF2F2F2), Color(0xFFE0E0E0), Color(0xFFC4C4C4), Color(0xFF999999), //
    Color(0xFF707070), Color(0xFF4D4D4D), Color(0xFF262626), Color(0xFF000000),
  ];

  /// Gray scale steps 1..9 in dark mode.
  static const List<Color> grayDark = [
    Color(0xFF000000), Color(0xFF262626), Color(0xFF3B3B3B), Color(0xFF707070), Color(0xFF999999), //
    Color(0xFFC4C4C4), Color(0xFFE0E0E0), Color(0xFFF2F2F2), Color(0xFFFFFFFF),
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
      surfaceRaised: g[1],
      surfaceInverse: g[7],
      onSurfaceInverse: g[0],
      border: overlay,
      borderStrong: g[3],
      text: g[8],
      textMuted: g[5],
      textSubtle: g[4],
      textDisabled: g[3],
      accent: a,
      onAccent: _on(a),
      accentSoft: a.withValues(alpha: 0.2),
      onAccentSoft: _shade(a, maxLightness: 0.38),
      success: const Color(0xFF0AB35A),
      onSuccess: Colors.white,
      successSoft: const Color(0x3309A854),
      onSuccessSoft: const Color(0xFF037D48),
      warning: const Color(0xFFD69400),
      onWarning: Colors.white,
      warningSoft: const Color(0x33D19000),
      onWarningSoft: const Color(0xFF9E6700),
      danger: const Color(0xFFDA3A3A),
      onDanger: Colors.white,
      dangerSoft: const Color(0x33D93535),
      onDangerSoft: const Color(0xFFA31920),
      info: const Color(0xFF25A7B6),
      onInfo: Colors.white,
      infoSoft: const Color(0x33239CAA),
      onInfoSoft: const Color(0xFF04677B),
      scrim: const Color(0x66000000),
      shimmerBase: g[1],
      shimmerHighlight: g[0],
      chart: [
        a,
        const Color(0xFF0AB35A),
        const Color(0xFFE27522),
        const Color(0xFF966BD1),
        const Color(0xFF25A7B6),
        const Color(0xFFC94AA8),
        const Color(0xFFD1A300),
        const Color(0xFFDA3A3A),
      ],
    );
  }

  /// The dark palette. Pass [accent] to use a custom brand color; it is
  /// lightened when needed so it stays readable on dark surfaces.
  factory UiColors.dark({Color? accent}) {
    const g = grayDark;
    final a = accent == null ? defaultAccentDark : _tint(accent, minLightness: 0.55);
    return UiColors(
      brightness: Brightness.dark,
      background: g[0],
      surface: g[1],
      surfaceMuted: overlay,
      surfaceRaised: g[1],
      surfaceInverse: g[7],
      onSurfaceInverse: g[0],
      border: overlay,
      borderStrong: g[3],
      text: g[8],
      textMuted: g[5],
      textSubtle: g[4],
      textDisabled: g[3],
      accent: a,
      onAccent: _on(a),
      accentSoft: a.withValues(alpha: 0.25),
      onAccentSoft: _tint(a, minLightness: 0.75),
      success: const Color(0xFF0AB35A),
      onSuccess: Colors.white,
      successSoft: const Color(0x4D09A854),
      onSuccessSoft: const Color(0xFF54C981),
      warning: const Color(0xFFD69400),
      onWarning: Colors.white,
      warningSoft: const Color(0x4DD19000),
      onWarningSoft: const Color(0xFFF3B344),
      danger: const Color(0xFFDA3A3A),
      onDanger: Colors.white,
      dangerSoft: const Color(0x4DD93535),
      onDangerSoft: const Color(0xFFEF6262),
      info: const Color(0xFF25A7B6),
      onInfo: Colors.white,
      infoSoft: const Color(0x4D239CAA),
      onInfoSoft: const Color(0xFF58C0D0),
      scrim: const Color(0x99000000),
      shimmerBase: g[1],
      shimmerHighlight: g[2],
      chart: [
        a,
        const Color(0xFF54C981),
        const Color(0xFFF18D4B),
        const Color(0xFFB28FE0),
        const Color(0xFF58C0D0),
        const Color(0xFFDE6EC6),
        const Color(0xFFEFCA43),
        const Color(0xFFEF6262),
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
    return theme.extension<UiColors>() ??
        (theme.brightness == Brightness.dark ? UiColors.dark() : UiColors.light());
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
      chart: [
        for (var i = 0; i < chart.length; i++) c(chart[i], other.chart[i % other.chart.length]),
      ],
    );
  }

  static Color _on(Color c) =>
      ThemeData.estimateBrightnessForColor(c) == Brightness.dark ? Colors.white : const Color(0xFF0C0C0F);

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
