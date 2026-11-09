import 'package:flutter/material.dart';

/// Spacing scale (4 pt grid). Use these for padding, gaps and margins.
abstract final class UiSpace {
  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Default horizontal page padding.
  static const double page = 20;
}

/// Corner radius scale.
abstract final class UiRadius {
  static const double xs = 6;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 26;
  static const double full = 999;

  static BorderRadius all(double r) => BorderRadius.all(Radius.circular(r));
  static BorderRadius top(double r) => BorderRadius.vertical(top: Radius.circular(r));
}

/// Durations and curves for motion. Respect `MediaQuery.disableAnimations`
/// with [UiMotion.of].
abstract final class UiMotion {
  static const Duration fast = Duration(milliseconds: 120);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 360);

  static const Curve standard = Curves.easeOutCubic;
  static const Curve emphasized = Curves.easeOutQuart;
  static const Curve bounce = Curves.easeOutBack;

  /// Returns [d], or zero when the user asked for reduced motion.
  static Duration of(BuildContext context, Duration d) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false ? Duration.zero : d;
}

/// Soft, layered shadows. Dark mode uses deeper, tighter shadows because
/// surfaces are separated by tone, not by shadow.
abstract final class UiShadows {
  static List<BoxShadow> sm(Brightness b) => b == Brightness.dark
      ? const [BoxShadow(color: Color(0x66000000), blurRadius: 2, offset: Offset(0, 1))]
      : const [
          BoxShadow(color: Color(0x0F101828), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0A101828), blurRadius: 3, offset: Offset(0, 1)),
        ];

  static List<BoxShadow> md(Brightness b) => b == Brightness.dark
      ? const [BoxShadow(color: Color(0x80000000), blurRadius: 16, offset: Offset(0, 6))]
      : const [
          BoxShadow(color: Color(0x14101828), blurRadius: 16, offset: Offset(0, 6), spreadRadius: -4),
          BoxShadow(color: Color(0x0A101828), blurRadius: 6, offset: Offset(0, 2), spreadRadius: -2),
        ];

  static List<BoxShadow> lg(Brightness b) => b == Brightness.dark
      ? const [BoxShadow(color: Color(0x99000000), blurRadius: 32, offset: Offset(0, 16))]
      : const [
          BoxShadow(color: Color(0x1F101828), blurRadius: 40, offset: Offset(0, 20), spreadRadius: -8),
          BoxShadow(color: Color(0x0D101828), blurRadius: 12, offset: Offset(0, 6), spreadRadius: -4),
        ];
}

/// Window size classes (Material 3 widths).
enum UiBreakpoint {
  /// Phones in portrait, under 600 dp.
  compact,

  /// Large phones in landscape, small tablets: 600–839 dp.
  medium,

  /// Tablets, small laptops: 840–1199 dp.
  expanded,

  /// Desktop: 1200 dp and wider.
  large;

  static UiBreakpoint of(double width) => width < 600
      ? compact
      : width < 840
          ? medium
          : width < 1200
              ? expanded
              : large;

  bool operator >=(UiBreakpoint other) => index >= other.index;
  bool operator <(UiBreakpoint other) => index < other.index;
}
