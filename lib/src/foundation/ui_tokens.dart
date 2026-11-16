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
  static const double page = 16;
}

/// Corner radius scale (Ash Theme "Border radius", mobile values).
abstract final class UiRadius {
  /// Checkboxes, small tags.
  static const double xs = 4;
  static const double sm = 6;

  /// Buttons, fields, tiles.
  static const double md = 8;

  /// Cards, sheets, dialogs.
  static const double lg = 12;
  static const double xl = 20;

  /// Pills: controls, chips, segmented controls, avatars.
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

/// The three shadow levels of the design ("shadow/level 1..3"). Each is a
/// tight shadow (Shadow2) plus a wide one (Shadow1); both are stronger in
/// dark mode.
abstract final class UiShadows {
  static Color _s1(Brightness b) => b == Brightness.dark ? const Color(0x80000000) : const Color(0x26000000);
  static Color _s2(Brightness b) => b == Brightness.dark ? const Color(0x4D000000) : const Color(0x14000000);

  /// Level 1: slider thumbs, small raised controls.
  static List<BoxShadow> sm(Brightness b) => [
        BoxShadow(color: _s2(b), blurRadius: 4, offset: const Offset(0, 2)),
        BoxShadow(color: _s1(b), blurRadius: 9, offset: const Offset(0, 3)),
      ];

  /// Level 2: menus, popovers, toasts.
  static List<BoxShadow> md(Brightness b) => [
        BoxShadow(color: _s2(b), blurRadius: 7, offset: const Offset(0, 4)),
        BoxShadow(color: _s1(b), blurRadius: 24, offset: const Offset(0, 8)),
      ];

  /// Level 3: dialogs and sheets.
  static List<BoxShadow> lg(Brightness b) => [
        BoxShadow(color: _s2(b), blurRadius: 32, offset: const Offset(0, 16)),
        BoxShadow(color: _s1(b), blurRadius: 8, offset: const Offset(0, 4)),
      ];

  /// Hover / focus ring drawn around buttons, controls and fields: a 4 px
  /// outer ring of [color] at 50% (the design's 4 px stroke).
  static List<BoxShadow> ring(Color color) => [
        BoxShadow(color: color.withValues(alpha: color.a * 0.5), spreadRadius: 4),
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
