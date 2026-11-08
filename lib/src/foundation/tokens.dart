import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

abstract final class UiSpace {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;
  static const double huge = 48;

  static const EdgeInsets page = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets card = EdgeInsets.all(lg);
}

abstract final class UiDuration {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);
}

abstract final class UiCurve {
  static const standard = Curves.easeOutCubic;
  static const emphasized = Curves.easeInOutCubicEmphasized;
}

abstract final class UiBreakpoint {
  static const double compact = 600;
  static const double medium = 840;
  static const double expanded = 1200;
}

enum UiSize { sm, md, lg }

enum UiStatus { neutral, info, success, warning, danger }

@immutable
class UiTokens extends ThemeExtension<UiTokens> {
  const UiTokens({
    this.radiusXs = 6,
    this.radiusSm = 10,
    this.radiusMd = 14,
    this.radiusLg = 20,
    this.radiusXl = 28,
    this.controlHeight = 52,
  });

  factory UiTokens.scaled(double scale) => UiTokens(
        radiusXs: 6 * scale,
        radiusSm: 10 * scale,
        radiusMd: 14 * scale,
        radiusLg: 20 * scale,
        radiusXl: 28 * scale,
      );

  final double radiusXs;
  final double radiusSm;
  final double radiusMd;
  final double radiusLg;
  final double radiusXl;
  final double controlHeight;

  static const double radiusFull = 999;

  BorderRadius get xs => BorderRadius.circular(radiusXs);
  BorderRadius get sm => BorderRadius.circular(radiusSm);
  BorderRadius get md => BorderRadius.circular(radiusMd);
  BorderRadius get lg => BorderRadius.circular(radiusLg);
  BorderRadius get xl => BorderRadius.circular(radiusXl);
  BorderRadius get full => BorderRadius.circular(radiusFull);

  @override
  UiTokens copyWith({
    double? radiusXs,
    double? radiusSm,
    double? radiusMd,
    double? radiusLg,
    double? radiusXl,
    double? controlHeight,
  }) =>
      UiTokens(
        radiusXs: radiusXs ?? this.radiusXs,
        radiusSm: radiusSm ?? this.radiusSm,
        radiusMd: radiusMd ?? this.radiusMd,
        radiusLg: radiusLg ?? this.radiusLg,
        radiusXl: radiusXl ?? this.radiusXl,
        controlHeight: controlHeight ?? this.controlHeight,
      );

  @override
  UiTokens lerp(UiTokens? other, double t) {
    if (other == null) return this;
    return UiTokens(
      radiusXs: lerpDouble(radiusXs, other.radiusXs, t)!,
      radiusSm: lerpDouble(radiusSm, other.radiusSm, t)!,
      radiusMd: lerpDouble(radiusMd, other.radiusMd, t)!,
      radiusLg: lerpDouble(radiusLg, other.radiusLg, t)!,
      radiusXl: lerpDouble(radiusXl, other.radiusXl, t)!,
      controlHeight: lerpDouble(controlHeight, other.controlHeight, t)!,
    );
  }
}
