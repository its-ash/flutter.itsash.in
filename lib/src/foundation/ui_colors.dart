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

  /// Default accent for light mode (indigo 600).
  static const Color defaultAccentLight = Color(0xFF4F46E5);

  /// Default accent for dark mode (indigo 400).
  static const Color defaultAccentDark = Color(0xFF818CF8);

  /// The light palette. Pass [accent] to use a custom brand color.
  factory UiColors.light({Color? accent}) {
    const surface = Color(0xFFFFFFFF);
    final a = accent ?? defaultAccentLight;
    return UiColors(
      brightness: Brightness.light,
      background: const Color(0xFFF6F6F8),
      surface: surface,
      surfaceMuted: const Color(0xFFF0F0F3),
      surfaceRaised: surface,
      surfaceInverse: const Color(0xFF18181B),
      onSurfaceInverse: const Color(0xFFFAFAFA),
      border: const Color(0xFFE4E4E9),
      borderStrong: const Color(0xFFCFCFD6),
      text: const Color(0xFF111114),
      textMuted: const Color(0xFF55555F),
      textSubtle: const Color(0xFF8E8E99),
      textDisabled: const Color(0xFFB8B8C1),
      accent: a,
      onAccent: _on(a),
      accentSoft: Color.alphaBlend(a.withValues(alpha: 0.10), surface),
      onAccentSoft: _shade(a, maxLightness: 0.38),
      success: const Color(0xFF16A34A),
      onSuccess: Colors.white,
      successSoft: const Color(0xFFE8F7EE),
      onSuccessSoft: const Color(0xFF166534),
      warning: const Color(0xFFD97706),
      onWarning: Colors.white,
      warningSoft: const Color(0xFFFEF4E2),
      onWarningSoft: const Color(0xFF92400E),
      danger: const Color(0xFFDC2626),
      onDanger: Colors.white,
      dangerSoft: const Color(0xFFFDECEC),
      onDangerSoft: const Color(0xFF991B1B),
      info: const Color(0xFF2563EB),
      onInfo: Colors.white,
      infoSoft: const Color(0xFFE9F0FE),
      onInfoSoft: const Color(0xFF1E40AF),
      scrim: const Color(0x66000000),
      shimmerBase: const Color(0xFFEDEDF1),
      shimmerHighlight: const Color(0xFFF8F8FA),
      chart: [
        a,
        const Color(0xFF0EA5E9),
        const Color(0xFF10B981),
        const Color(0xFFF59E0B),
        const Color(0xFFEF4444),
        const Color(0xFF8B5CF6),
        const Color(0xFFEC4899),
        const Color(0xFF14B8A6),
      ],
    );
  }

  /// The dark palette. Pass [accent] to use a custom brand color; it is
  /// lightened when needed so it stays readable on dark surfaces.
  factory UiColors.dark({Color? accent}) {
    const surface = Color(0xFF151519);
    final a = accent == null ? defaultAccentDark : _tint(accent, minLightness: 0.62);
    return UiColors(
      brightness: Brightness.dark,
      background: const Color(0xFF0C0C0F),
      surface: surface,
      surfaceMuted: const Color(0xFF1D1D22),
      surfaceRaised: const Color(0xFF202026),
      surfaceInverse: const Color(0xFFF4F4F5),
      onSurfaceInverse: const Color(0xFF18181B),
      border: const Color(0xFF2A2A31),
      borderStrong: const Color(0xFF3B3B44),
      text: const Color(0xFFF5F5F7),
      textMuted: const Color(0xFFA6A6B0),
      textSubtle: const Color(0xFF75757F),
      textDisabled: const Color(0xFF4E4E57),
      accent: a,
      onAccent: _on(a),
      accentSoft: Color.alphaBlend(a.withValues(alpha: 0.16), surface),
      onAccentSoft: _tint(a, minLightness: 0.78),
      success: const Color(0xFF34D399),
      onSuccess: const Color(0xFF052E1B),
      successSoft: const Color(0xFF12291F),
      onSuccessSoft: const Color(0xFF86EFAC),
      warning: const Color(0xFFFBBF24),
      onWarning: const Color(0xFF3A2503),
      warningSoft: const Color(0xFF2E2410),
      onWarningSoft: const Color(0xFFFCD34D),
      danger: const Color(0xFFF87171),
      onDanger: const Color(0xFF3B0A0A),
      dangerSoft: const Color(0xFF331517),
      onDangerSoft: const Color(0xFFFCA5A5),
      info: const Color(0xFF60A5FA),
      onInfo: const Color(0xFF0A1E3F),
      infoSoft: const Color(0xFF14213A),
      onInfoSoft: const Color(0xFF93C5FD),
      scrim: const Color(0x99000000),
      shimmerBase: const Color(0xFF1D1D22),
      shimmerHighlight: const Color(0xFF2A2A31),
      chart: [
        a,
        const Color(0xFF38BDF8),
        const Color(0xFF34D399),
        const Color(0xFFFBBF24),
        const Color(0xFFF87171),
        const Color(0xFFA78BFA),
        const Color(0xFFF472B6),
        const Color(0xFF2DD4BF),
      ],
    );
  }

  final Brightness brightness;

  /// App canvas behind everything (scaffold background).
  final Color background;

  /// Cards, sheets, app bars, list groups.
  final Color surface;

  /// Subtle fills: inputs, hovered rows, tracks, secondary buttons.
  final Color surfaceMuted;

  /// Floating layers: menus, popovers, dialogs.
  final Color surfaceRaised;

  /// Tooltips and snackbars.
  final Color surfaceInverse;
  final Color onSurfaceInverse;

  /// Hairline borders and dividers.
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
