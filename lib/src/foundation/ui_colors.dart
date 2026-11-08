import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';

typedef UiTone = ({Color color, Color onColor, Color container, Color onContainer});

@immutable
class UiColors extends ThemeExtension<UiColors> {
  const UiColors({
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
    required this.rating,
    required this.sale,
    required this.shimmerBase,
    required this.shimmerHighlight,
    required this.gradient,
  });

  factory UiColors.from(ColorScheme scheme) {
    final dark = scheme.brightness == Brightness.dark;
    UiTone tone(Color seed) {
      final s = ColorScheme.fromSeed(seedColor: seed, brightness: scheme.brightness);
      return (color: s.primary, onColor: s.onPrimary, container: s.primaryContainer, onContainer: s.onPrimaryContainer);
    }

    final ok = tone(const Color(0xFF16A34A));
    final warn = tone(const Color(0xFFF59E0B));
    final inf = tone(const Color(0xFF0284C7));
    return UiColors(
      success: ok.color,
      onSuccess: ok.onColor,
      successContainer: ok.container,
      onSuccessContainer: ok.onContainer,
      warning: warn.color,
      onWarning: warn.onColor,
      warningContainer: warn.container,
      onWarningContainer: warn.onContainer,
      info: inf.color,
      onInfo: inf.onColor,
      infoContainer: inf.container,
      onInfoContainer: inf.onContainer,
      rating: const Color(0xFFFFB400),
      sale: dark ? const Color(0xFFFF6B6B) : const Color(0xFFE11D48),
      shimmerBase: scheme.surfaceContainerHighest,
      shimmerHighlight: scheme.surfaceContainerLow,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [scheme.primary, Color.lerp(scheme.primary, scheme.tertiary, 0.7)!],
      ),
    );
  }

  final Color success;
  final Color onSuccess;
  final Color successContainer;
  final Color onSuccessContainer;
  final Color warning;
  final Color onWarning;
  final Color warningContainer;
  final Color onWarningContainer;
  final Color info;
  final Color onInfo;
  final Color infoContainer;
  final Color onInfoContainer;
  final Color rating;
  final Color sale;
  final Color shimmerBase;
  final Color shimmerHighlight;
  final LinearGradient gradient;

  UiTone tone(UiStatus status, ColorScheme scheme) => switch (status) {
        UiStatus.success => (color: success, onColor: onSuccess, container: successContainer, onContainer: onSuccessContainer),
        UiStatus.warning => (color: warning, onColor: onWarning, container: warningContainer, onContainer: onWarningContainer),
        UiStatus.info => (color: info, onColor: onInfo, container: infoContainer, onContainer: onInfoContainer),
        UiStatus.danger => (color: scheme.error, onColor: scheme.onError, container: scheme.errorContainer, onContainer: scheme.onErrorContainer),
        UiStatus.neutral => (
            color: scheme.onSurfaceVariant,
            onColor: scheme.surface,
            container: scheme.surfaceContainerHighest,
            onContainer: scheme.onSurfaceVariant,
          ),
      };

  @override
  UiColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? successContainer,
    Color? onSuccessContainer,
    Color? warning,
    Color? onWarning,
    Color? warningContainer,
    Color? onWarningContainer,
    Color? info,
    Color? onInfo,
    Color? infoContainer,
    Color? onInfoContainer,
    Color? rating,
    Color? sale,
    Color? shimmerBase,
    Color? shimmerHighlight,
    LinearGradient? gradient,
  }) =>
      UiColors(
        success: success ?? this.success,
        onSuccess: onSuccess ?? this.onSuccess,
        successContainer: successContainer ?? this.successContainer,
        onSuccessContainer: onSuccessContainer ?? this.onSuccessContainer,
        warning: warning ?? this.warning,
        onWarning: onWarning ?? this.onWarning,
        warningContainer: warningContainer ?? this.warningContainer,
        onWarningContainer: onWarningContainer ?? this.onWarningContainer,
        info: info ?? this.info,
        onInfo: onInfo ?? this.onInfo,
        infoContainer: infoContainer ?? this.infoContainer,
        onInfoContainer: onInfoContainer ?? this.onInfoContainer,
        rating: rating ?? this.rating,
        sale: sale ?? this.sale,
        shimmerBase: shimmerBase ?? this.shimmerBase,
        shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
        gradient: gradient ?? this.gradient,
      );

  @override
  UiColors lerp(UiColors? other, double t) {
    if (other == null) return this;
    Color c(Color a, Color b) => Color.lerp(a, b, t)!;
    return UiColors(
      success: c(success, other.success),
      onSuccess: c(onSuccess, other.onSuccess),
      successContainer: c(successContainer, other.successContainer),
      onSuccessContainer: c(onSuccessContainer, other.onSuccessContainer),
      warning: c(warning, other.warning),
      onWarning: c(onWarning, other.onWarning),
      warningContainer: c(warningContainer, other.warningContainer),
      onWarningContainer: c(onWarningContainer, other.onWarningContainer),
      info: c(info, other.info),
      onInfo: c(onInfo, other.onInfo),
      infoContainer: c(infoContainer, other.infoContainer),
      onInfoContainer: c(onInfoContainer, other.onInfoContainer),
      rating: c(rating, other.rating),
      sale: c(sale, other.sale),
      shimmerBase: c(shimmerBase, other.shimmerBase),
      shimmerHighlight: c(shimmerHighlight, other.shimmerHighlight),
      gradient: LinearGradient.lerp(gradient, other.gradient, t)!,
    );
  }
}
