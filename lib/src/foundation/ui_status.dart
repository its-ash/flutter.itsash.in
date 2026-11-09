import 'package:flutter/material.dart';

/// Meaning of a colored element. Resolve colors with `context.colors.tone(status)`.
enum UiStatus {
  neutral,
  accent,
  info,
  success,
  warning,
  danger;

  /// Default icon for this status (used by alerts, toasts, banners).
  IconData get icon => switch (this) {
        UiStatus.neutral => Icons.circle_outlined,
        UiStatus.accent => Icons.auto_awesome_rounded,
        UiStatus.info => Icons.info_rounded,
        UiStatus.success => Icons.check_circle_rounded,
        UiStatus.warning => Icons.warning_rounded,
        UiStatus.danger => Icons.error_rounded,
      };
}

/// Control size shared by buttons, inputs, chips, avatars and badges.
enum UiSize {
  sm,
  md,
  lg;

  /// Height of a single-line control of this size.
  double get height => switch (this) {
        UiSize.sm => 36,
        UiSize.md => 44,
        UiSize.lg => 52,
      };

  /// Icon size inside a control of this size.
  double get iconSize => switch (this) {
        UiSize.sm => 16,
        UiSize.md => 18,
        UiSize.lg => 20,
      };

  /// Label font size inside a control of this size.
  double get fontSize => switch (this) {
        UiSize.sm => 13,
        UiSize.md => 14,
        UiSize.lg => 16,
      };

  /// Horizontal padding inside a control of this size.
  double get padding => switch (this) {
        UiSize.sm => 12,
        UiSize.md => 16,
        UiSize.lg => 20,
      };
}
