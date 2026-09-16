import 'package:flutter/material.dart';

import 'package:theme/src/colors/app_colors.dart';
import 'package:theme/src/shadows/app_shadow_theme.dart';
import 'package:theme/src/theme_presets/app_theme_preset.dart';

/// A named theme style (e.g. `flat`, `neumorphism`, `cyberpunk`) that
/// carries both a [light] and a [dark] [AppThemePreset]. Selecting a style
/// at runtime gives you a coherent pair of themes that swap with the
/// platform brightness, each fully overriding colors, shadows, radii,
/// elevation, and component behavior.
class AppThemeStyle {
  const AppThemeStyle({
    required this.id,
    required this.name,
    required this.lightPreset,
    required this.darkPreset,
  });

  final String id;
  final String name;
  final AppThemePreset lightPreset;
  final AppThemePreset darkPreset;

  AppThemePreset preset(Brightness brightness) =>
      brightness == Brightness.dark ? darkPreset : lightPreset;

  ThemeData themeData(Brightness brightness) => preset(brightness).toThemeData();

  // ── Shadow presets ──────────────────────────────────────────────────

  static const _soft = AppShadowTheme();
  static const _softDark = AppShadowTheme.dark();

  static const _flat = AppShadowTheme(
    hairline: BoxShadow(color: Colors.transparent),
    shadowOne: BoxShadow(color: Colors.transparent),
    shadowTwo: BoxShadow(color: Colors.transparent),
    shadowThree: BoxShadow(color: Colors.transparent),
  );

  static const _neuLight = AppShadowTheme(
    hairline: BoxShadow(color: Colors.transparent),
    shadowOne: BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 18, offset: Offset(-7, -7)),
    shadowTwo: BoxShadow(color: Color(0xFFC5D0DE), blurRadius: 18, offset: Offset(7, 7)),
    shadowThree: BoxShadow(color: Color(0xFFA5B5C5), blurRadius: 28, offset: Offset(10, 10)),
    cardShadows: [
      BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 16, offset: Offset(-6, -6)),
      BoxShadow(color: Color(0xFFC5D0DE), blurRadius: 16, offset: Offset(6, 6)),
    ],
    buttonShadows: [
      BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 12, offset: Offset(-5, -5)),
      BoxShadow(color: Color(0xFFC5D0DE), blurRadius: 12, offset: Offset(5, 5)),
    ],
  );

  static const _neuDark = AppShadowTheme(
    hairline: BoxShadow(color: Colors.transparent),
    shadowOne: BoxShadow(color: Color(0xFF3D4452), blurRadius: 18, offset: Offset(-7, -7)),
    shadowTwo: BoxShadow(color: Color(0xFF000000), blurRadius: 18, offset: Offset(7, 7)),
    shadowThree: BoxShadow(color: Color(0xFF000000), blurRadius: 28, offset: Offset(10, 10)),
    cardShadows: [
      BoxShadow(color: Color(0xFF3D4452), blurRadius: 16, offset: Offset(-6, -6)),
      BoxShadow(color: Color(0xFF000000), blurRadius: 16, offset: Offset(6, 6)),
    ],
    buttonShadows: [
      BoxShadow(color: Color(0xFF3D4452), blurRadius: 12, offset: Offset(-5, -5)),
      BoxShadow(color: Color(0xFF000000), blurRadius: 12, offset: Offset(5, 5)),
    ],
  );

  static const _glassLight = AppShadowTheme(
    hairline: BoxShadow(color: Color(0x55FFFFFF)),
    shadowOne: BoxShadow(color: Color(0x1A000000), blurRadius: 16, offset: Offset(0, 6)),
    shadowTwo: BoxShadow(color: Color(0x33000000), blurRadius: 28, offset: Offset(0, 12)),
    shadowThree: BoxShadow(color: Color(0x4D000000), blurRadius: 40, offset: Offset(0, 18)),
  );

  static const _glassDark = AppShadowTheme(
    hairline: BoxShadow(color: Color(0x44FFFFFF)),
    shadowOne: BoxShadow(color: Color(0x55000000), blurRadius: 18, offset: Offset(0, 6)),
    shadowTwo: BoxShadow(color: Color(0x88000000), blurRadius: 30, offset: Offset(0, 12)),
    shadowThree: BoxShadow(color: Color(0xCC000000), blurRadius: 42, offset: Offset(0, 18)),
  );

  static const _brutalLight = AppShadowTheme(
    hairline: BoxShadow(color: Colors.transparent),
    shadowOne: BoxShadow(color: Color(0xFF111111), offset: Offset(5, 5)),
    shadowTwo: BoxShadow(color: Color(0xFF111111), offset: Offset(8, 8)),
    shadowThree: BoxShadow(color: Color(0xFF111111), offset: Offset(12, 12)),
    cardShadows: [BoxShadow(color: Color(0xFF111111), offset: Offset(6, 6))],
    buttonShadows: [BoxShadow(color: Color(0xFF111111), offset: Offset(4, 4))],
  );

  static const _brutalDark = AppShadowTheme(
    hairline: BoxShadow(color: Colors.transparent),
    shadowOne: BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(5, 5)),
    shadowTwo: BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(8, 8)),
    shadowThree: BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(12, 12)),
    cardShadows: [BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(6, 6))],
    buttonShadows: [BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(4, 4))],
  );

  static const _maxiLight = AppShadowTheme(
    hairline: BoxShadow(color: Color(0xFFFF006E), offset: Offset(3, 3)),
    shadowOne: BoxShadow(color: Color(0x88FF006E), blurRadius: 16, offset: Offset(0, 6)),
    shadowTwo: BoxShadow(color: Color(0x99FFD60A), blurRadius: 24, offset: Offset(6, 12)),
    shadowThree: BoxShadow(color: Color(0x993A86FF), blurRadius: 36, offset: Offset(12, 18)),
    cardShadows: [
      BoxShadow(color: Color(0xFFFF006E), offset: Offset(5, 5)),
      BoxShadow(color: Color(0x77FFD60A), blurRadius: 22, offset: Offset(0, 12)),
      BoxShadow(color: Color(0x773A86FF), blurRadius: 32, offset: Offset(10, 16)),
    ],
    buttonShadows: [
      BoxShadow(color: Color(0xFFFF006E), offset: Offset(4, 4)),
      BoxShadow(color: Color(0xAAFFD60A), blurRadius: 18, offset: Offset(0, 8)),
      BoxShadow(color: Color(0x773A86FF), blurRadius: 22, offset: Offset(6, 10)),
    ],
  );

  static const _maxiDark = AppShadowTheme(
    hairline: BoxShadow(color: Color(0xFFFF006E), offset: Offset(3, 3)),
    shadowOne: BoxShadow(color: Color(0xCCFF006E), blurRadius: 20, offset: Offset(0, 6)),
    shadowTwo: BoxShadow(color: Color(0xCCFFD60A), blurRadius: 28, offset: Offset(6, 12)),
    shadowThree: BoxShadow(color: Color(0xCC3A86FF), blurRadius: 40, offset: Offset(12, 18)),
    cardShadows: [
      BoxShadow(color: Color(0xCCFF006E), offset: Offset(5, 5)),
      BoxShadow(color: Color(0xCCFFD60A), blurRadius: 26, offset: Offset(0, 12)),
      BoxShadow(color: Color(0xCC3A86FF), blurRadius: 36, offset: Offset(10, 16)),
    ],
    buttonShadows: [
      BoxShadow(color: Color(0xFFFF006E), offset: Offset(4, 4)),
      BoxShadow(color: Color(0xEEFFD60A), blurRadius: 20, offset: Offset(0, 8)),
      BoxShadow(color: Color(0xCC3A86FF), blurRadius: 24, offset: Offset(6, 10)),
    ],
  );

  static const _skeuLight = AppShadowTheme(
    hairline: BoxShadow(color: Color(0x33FFFFFF)),
    shadowOne: BoxShadow(color: Color(0x33000000), blurRadius: 8, offset: Offset(0, 3)),
    shadowTwo: BoxShadow(color: Color(0x55000000), blurRadius: 14, offset: Offset(0, 7)),
    shadowThree: BoxShadow(color: Color(0x77000000), blurRadius: 22, offset: Offset(0, 14)),
  );

  static const _skeuDark = AppShadowTheme(
    hairline: BoxShadow(color: Color(0x33FFFFFF)),
    shadowOne: BoxShadow(color: Color(0x66000000), blurRadius: 10, offset: Offset(0, 4)),
    shadowTwo: BoxShadow(color: Color(0x99000000), blurRadius: 16, offset: Offset(0, 8)),
    shadowThree: BoxShadow(color: Color(0xCC000000), blurRadius: 24, offset: Offset(0, 16)),
  );

  static const _retroLight = AppShadowTheme(
    hairline: BoxShadow(color: Color(0xFF222222), offset: Offset(0, 4)),
    shadowOne: BoxShadow(color: Color(0xFF222222), offset: Offset(4, 4)),
    shadowTwo: BoxShadow(color: Color(0xFF222222), offset: Offset(6, 6)),
    shadowThree: BoxShadow(color: Color(0xFF222222), offset: Offset(8, 8)),
    cardShadows: [BoxShadow(color: Color(0xFF222222), offset: Offset(6, 6))],
    buttonShadows: [BoxShadow(color: Color(0xFF222222), offset: Offset(4, 4))],
  );

  static const _retroDark = AppShadowTheme(
    hairline: BoxShadow(color: Color(0xFF00E5FF), offset: Offset(0, 4)),
    shadowOne: BoxShadow(color: Color(0xFF00E5FF), offset: Offset(4, 4)),
    shadowTwo: BoxShadow(color: Color(0xFF00E5FF), offset: Offset(6, 6)),
    shadowThree: BoxShadow(color: Color(0xFF00E5FF), offset: Offset(8, 8)),
    cardShadows: [BoxShadow(color: Color(0xFF00E5FF), offset: Offset(6, 6))],
    buttonShadows: [BoxShadow(color: Color(0xFF00E5FF), offset: Offset(4, 4))],
  );

  static const _cyber = AppShadowTheme(
    hairline: BoxShadow(color: Color(0xFFFF00FF)),
    shadowOne: BoxShadow(color: Color(0xCCFF00FF), blurRadius: 12),
    shadowTwo: BoxShadow(color: Color(0xCC00FFFF), blurRadius: 18, offset: Offset(0, 6)),
    shadowThree: BoxShadow(color: Color(0xFFFF00FF), blurRadius: 28, offset: Offset(0, 12)),
    cardShadows: [
      BoxShadow(color: Color(0x99FF00FF), blurRadius: 16, offset: Offset(0, 0)),
      BoxShadow(color: Color(0x9900FFFF), blurRadius: 24, offset: Offset(0, 8)),
    ],
    buttonShadows: [
      BoxShadow(color: Color(0xCCFF00FF), blurRadius: 14),
      BoxShadow(color: Color(0x9900FFFF), blurRadius: 18, offset: Offset(0, 4)),
    ],
  );

  static const _clayLight = AppShadowTheme(
    hairline: BoxShadow(color: Colors.transparent),
    shadowOne: BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 16, offset: Offset(-6, -6)),
    shadowTwo: BoxShadow(color: Color(0x66E89AB5), blurRadius: 20, offset: Offset(8, 8)),
    shadowThree: BoxShadow(color: Color(0x99E89AB5), blurRadius: 30, offset: Offset(12, 12)),
    cardShadows: [
      BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 14, offset: Offset(-6, -6)),
      BoxShadow(color: Color(0x66E89AB5), blurRadius: 18, offset: Offset(8, 8)),
    ],
    buttonShadows: [
      BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 10, offset: Offset(-5, -5)),
      BoxShadow(color: Color(0x66E89AB5), blurRadius: 14, offset: Offset(6, 6)),
    ],
  );

  static const _clayDark = AppShadowTheme(
    hairline: BoxShadow(color: Colors.transparent),
    shadowOne: BoxShadow(color: Color(0xFF5A4A55), blurRadius: 16, offset: Offset(-6, -6)),
    shadowTwo: BoxShadow(color: Color(0x99000000), blurRadius: 20, offset: Offset(8, 8)),
    shadowThree: BoxShadow(color: Color(0xCC000000), blurRadius: 30, offset: Offset(12, 12)),
    cardShadows: [
      BoxShadow(color: Color(0xFF5A4A55), blurRadius: 14, offset: Offset(-6, -6)),
      BoxShadow(color: Color(0x99000000), blurRadius: 18, offset: Offset(8, 8)),
    ],
    buttonShadows: [
      BoxShadow(color: Color(0xFF5A4A55), blurRadius: 10, offset: Offset(-5, -5)),
      BoxShadow(color: Color(0x99000000), blurRadius: 14, offset: Offset(6, 6)),
    ],
  );

  static const _bauhaus = AppShadowTheme(
    hairline: BoxShadow(color: Color(0xFF1A1A1A), offset: Offset(0, 3)),
    shadowOne: BoxShadow(color: Color(0xFF1A1A1A), offset: Offset(0, 6)),
    shadowTwo: BoxShadow(color: Color(0xFF1A1A1A), offset: Offset(0, 9)),
    shadowThree: BoxShadow(color: Color(0xFF1A1A1A), offset: Offset(0, 12)),
    cardShadows: [BoxShadow(color: Color(0xFF1A1A1A), offset: Offset(8, 0))],
    buttonShadows: [BoxShadow(color: Color(0xFF1A1A1A), offset: Offset(6, 0))],
  );

  static const _organic = AppShadowTheme(
    hairline: BoxShadow(color: Color(0x14B8956A)),
    shadowOne: BoxShadow(color: Color(0x26B8956A), blurRadius: 18, offset: Offset(0, 8)),
    shadowTwo: BoxShadow(color: Color(0x40B8956A), blurRadius: 28, offset: Offset(0, 16)),
    shadowThree: BoxShadow(color: Color(0x66B8956A), blurRadius: 40, offset: Offset(0, 24)),
  );

  static const _typo = AppShadowTheme(
    hairline: BoxShadow(color: Color(0xFF111111)),
    shadowOne: BoxShadow(color: Colors.transparent),
    shadowTwo: BoxShadow(color: Colors.transparent),
    shadowThree: BoxShadow(color: Colors.transparent),
  );

  static const _mono = AppShadowTheme(
    hairline: BoxShadow(color: Color(0x11000000)),
    shadowOne: BoxShadow(color: Colors.transparent),
    shadowTwo: BoxShadow(color: Colors.transparent),
    shadowThree: BoxShadow(color: Colors.transparent),
  );

  static const _paperLight = AppShadowTheme(
    hairline: BoxShadow(color: Color(0x221D3557), offset: Offset(2, 2)),
    shadowOne: BoxShadow(color: Color(0x441D3557), offset: Offset(3, 3)),
    shadowTwo: BoxShadow(color: Color(0x661D3557), offset: Offset(5, 5)),
    shadowThree: BoxShadow(color: Color(0x881D3557), offset: Offset(7, 7)),
    cardShadows: [
      BoxShadow(color: Color(0x441D3557), offset: Offset(4, 4)),
      BoxShadow(color: Color(0x221D3557), offset: Offset(7, 7)),
    ],
    buttonShadows: [BoxShadow(color: Color(0x441D3557), offset: Offset(3, 3))],
  );

  static const _paperDark = AppShadowTheme(
    hairline: BoxShadow(color: Color(0x44E63946), offset: Offset(2, 2)),
    shadowOne: BoxShadow(color: Color(0x66E63946), offset: Offset(3, 3)),
    shadowTwo: BoxShadow(color: Color(0x88E63946), offset: Offset(5, 5)),
    shadowThree: BoxShadow(color: Color(0xAAE63946), offset: Offset(7, 7)),
    cardShadows: [
      BoxShadow(color: Color(0x66E63946), offset: Offset(4, 4)),
      BoxShadow(color: Color(0x44E63946), offset: Offset(7, 7)),
    ],
    buttonShadows: [BoxShadow(color: Color(0x66E63946), offset: Offset(3, 3))],
  );

  static const _skeuClassic = AppShadowTheme(
    hairline: BoxShadow(color: Color(0xFFFFFFFF), offset: Offset(0, -1)),
    shadowOne: BoxShadow(color: Color(0x66A3B1C6), blurRadius: 8, offset: Offset(2, 2)),
    shadowTwo: BoxShadow(color: Color(0x99A3B1C6), blurRadius: 14, offset: Offset(4, 4)),
    shadowThree: BoxShadow(color: Color(0xCCA3B1C6), blurRadius: 22, offset: Offset(6, 6)),
  );

  static const _hiContrast = AppShadowTheme(
    hairline: BoxShadow(color: Color(0xFFFFFFFF)),
    shadowOne: BoxShadow(color: Color(0xFF000000), blurRadius: 6, offset: Offset(0, 3)),
    shadowTwo: BoxShadow(color: Color(0xFF000000), blurRadius: 10, offset: Offset(0, 6)),
    shadowThree: BoxShadow(color: Color(0xFF000000), blurRadius: 16, offset: Offset(0, 10)),
  );

  // ── Styles ──────────────────────────────────────────────────────────

  static final light = AppThemeStyle(
    id: 'light', name: 'Light',
    lightPreset: AppThemePreset(
      id: 'light', name: 'Light', brightness: Brightness.light,
      colorScheme: AppColors.lightColorScheme, shadows: _soft,
    ),
    darkPreset: AppThemePreset(
      id: 'light', name: 'Light', brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme, shadows: _softDark,
    ),
  );

  static final dark = AppThemeStyle(
    id: 'dark', name: 'Dark',
    lightPreset: AppThemePreset(
      id: 'dark', name: 'Dark', brightness: Brightness.light,
      colorScheme: AppColors.darkColorScheme, shadows: _softDark,
    ),
    darkPreset: AppThemePreset(
      id: 'dark', name: 'Dark', brightness: Brightness.dark,
      colorScheme: AppColors.darkColorScheme, shadows: _softDark,
    ),
  );

  static const flat = AppThemeStyle(
    id: 'flat', name: 'Flat',
    lightPreset: AppThemePreset(
      id: 'flat', name: 'Flat', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF1565C0), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE3F2FD), onPrimaryContainer: Color(0xFF0D47A1),
        secondary: Color(0xFF00897B), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFB2DFDB), onSecondaryContainer: Color(0xFF004D40),
        surface: Color(0xFFFFFFFF), onSurface: Color(0xFF212121),
        surfaceContainerLow: Color(0xFFF5F5F5), surfaceContainer: Color(0xFFEEEEEE), surfaceContainerHigh: Color(0xFFE0E0E0),
        outline: Color(0xFFBDBDBD),
      ),
      shadows: _flat,
      cardRadius: 2, buttonRadius: 2, inputRadius: 2, dialogRadius: 2,
      inputFilled: false, inputBorderWidth: 1,
      borderColor: Color(0xFFBDBDBD), borderWidth: 1, forceFlat: true,
    ),
    darkPreset: AppThemePreset(
      id: 'flat', name: 'Flat', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF82B1FF), onPrimary: Color(0xFF000000),
        primaryContainer: Color(0xFF0D47A1), onPrimaryContainer: Color(0xFFE3F2FD),
        secondary: Color(0xFF80CBC4), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF004D40), onSecondaryContainer: Color(0xFFB2DFDB),
        surface: Color(0xFF111111), onSurface: Color(0xFFEEEEEE),
        surfaceContainerLow: Color(0xFF1A1A1A), surfaceContainer: Color(0xFF222222), surfaceContainerHigh: Color(0xFF2A2A2A),
        outline: Color(0xFF424242),
      ),
      shadows: _flat,
      cardRadius: 2, buttonRadius: 2, inputRadius: 2, dialogRadius: 2,
      inputFilled: false, inputBorderWidth: 1,
      borderColor: Color(0xFF424242), borderWidth: 1, forceFlat: true,
    ),
  );

  static const material = AppThemeStyle(
    id: 'material', name: 'Material',
    lightPreset: AppThemePreset(
      id: 'material', name: 'Material', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF6750A4), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFEADDFF), onPrimaryContainer: Color(0xFF21005D),
        secondary: Color(0xFF625B71), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFE8DEF8), onSecondaryContainer: Color(0xFF1D192B),
        tertiary: Color(0xFF7D5260), onTertiary: Color(0xFFFFFFFF),
        surface: Color(0xFFFEF7FF), onSurface: Color(0xFF1D1B20),
        surfaceContainerLow: Color(0xFFF7F2FA), surfaceContainer: Color(0xFFF3EDF7), surfaceContainerHigh: Color(0xFFECE6F0),
        outline: Color(0xFF79747E),
      ),
      shadows: _soft,
      cardRadius: 12, cardElevation: 1, buttonRadius: 20, inputRadius: 12, dialogRadius: 28,
    ),
    darkPreset: AppThemePreset(
      id: 'material', name: 'Material', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFD0BCFF), onPrimary: Color(0xFF381E72),
        primaryContainer: Color(0xFF4F378B), onPrimaryContainer: Color(0xFFEADDFF),
        secondary: Color(0xFFCCC2DC), onSecondary: Color(0xFF332D41),
        secondaryContainer: Color(0xFF4A4458), onSecondaryContainer: Color(0xFFE8DEF8),
        tertiary: Color(0xFFEFB8C8), onTertiary: Color(0xFF492532),
        surface: Color(0xFF141218), onSurface: Color(0xFFE6E0E9),
        surfaceContainerLow: Color(0xFF1D1B20), surfaceContainer: Color(0xFF211F26), surfaceContainerHigh: Color(0xFF2B2930),
        outline: Color(0xFF938F99),
      ),
      shadows: _softDark,
      cardRadius: 12, cardElevation: 1, buttonRadius: 20, inputRadius: 12, dialogRadius: 28,
    ),
  );

  static const neumorphism = AppThemeStyle(
    id: 'neumorphism', name: 'Neumorphism',
    lightPreset: AppThemePreset(
      id: 'neumorphism', name: 'Neumorphism', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF4A6FA5), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFD6E4F5), onPrimaryContainer: Color(0xFF1A3A6B),
        secondary: Color(0xFF7B8FB0), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFE0E8F0), onSecondaryContainer: Color(0xFF2A3A50),
        surface: Color(0xFFE0E5EC), onSurface: Color(0xFF333B47),
        surfaceContainerLow: Color(0xFFE8ECF2), surfaceContainer: Color(0xFFDEE3EA), surfaceContainerHigh: Color(0xFFD4D9E0),
        outline: Color(0xFF8D97A6),
      ),
      shadows: _neuLight,
      cardRadius: 24, cardMargin: 12, buttonRadius: 24, inputRadius: 24, dialogRadius: 24,
      inputFilled: false, inputBorderWidth: 1,
      cardBorderColor: Color(0x338D97A6), cardBorderWidth: 1,
    ),
    darkPreset: AppThemePreset(
      id: 'neumorphism', name: 'Neumorphism', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF8AAAE0), onPrimary: Color(0xFF0A1A30),
        primaryContainer: Color(0xFF2A3A50), onPrimaryContainer: Color(0xFFD6E4F5),
        secondary: Color(0xFF90A5C0), onSecondary: Color(0xFF0A1A30),
        secondaryContainer: Color(0xFF2A3A50), onSecondaryContainer: Color(0xFFE0E8F0),
        surface: Color(0xFF2A2E35), onSurface: Color(0xFFD0D8E0),
        surfaceContainerLow: Color(0xFF32373E), surfaceContainer: Color(0xFF2A2E35), surfaceContainerHigh: Color(0xFF22262C),
        outline: Color(0xFF7A8494),
      ),
      shadows: _neuDark,
      cardRadius: 24, cardMargin: 12, buttonRadius: 24, inputRadius: 24, dialogRadius: 24,
      inputFilled: false, inputBorderWidth: 1,
      cardBorderColor: Color(0x407A8494), cardBorderWidth: 1,
    ),
  );

  static const glassmorphism = AppThemeStyle(
    id: 'glassmorphism', name: 'Glassmorphism',
    lightPreset: AppThemePreset(
      id: 'glassmorphism', name: 'Glassmorphism', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF6750A4), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0x80EADDFF), onPrimaryContainer: Color(0xFF21005D),
        secondary: Color(0xFF00BFA5), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0x80B2DFDB), onSecondaryContainer: Color(0xFF004D40),
        surface: Color(0xCCF5F0FA), onSurface: Color(0xFF1A1B22),
        surfaceContainerLow: Color(0x99F0EBF5), surfaceContainer: Color(0x88EBE6F0), surfaceContainerHigh: Color(0x77E0DBE5),
        outline: Color(0x6679747E),
      ),
      shadows: _glassLight,
      cardRadius: 28, cardMargin: 10, buttonRadius: 20, inputRadius: 28, dialogRadius: 28,
      cardElevation: 0, buttonElevation: 0, cardBlur: 18,
      cardBorderColor: Color(0x99FFFFFF), cardBorderWidth: 1,
    ),
    darkPreset: AppThemePreset(
      id: 'glassmorphism', name: 'Glassmorphism', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFB69DF8), onPrimary: Color(0xFF000000),
        primaryContainer: Color(0x804F378B), onPrimaryContainer: Color(0xFFEADDFF),
        secondary: Color(0xFF80CBC4), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0x80004D40), onSecondaryContainer: Color(0xFFB2DFDB),
        surface: Color(0xB0201A30), onSurface: Color(0xFFE6E0E9),
        surfaceContainerLow: Color(0x992B2240), surfaceContainer: Color(0x88322A50), surfaceContainerHigh: Color(0x77383058),
        outline: Color(0x66938F99),
      ),
      shadows: _glassDark,
      cardRadius: 28, cardMargin: 10, buttonRadius: 20, inputRadius: 28, dialogRadius: 28,
      cardElevation: 0, buttonElevation: 0, cardBlur: 18,
      cardBorderColor: Color(0xB3FFFFFF), cardBorderWidth: 1,
    ),
  );

  static const brutalism = AppThemeStyle(
    id: 'brutalism', name: 'Brutalism',
    lightPreset: AppThemePreset(
      id: 'brutalism', name: 'Brutalism', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFFFF3B00), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFFFE0D6), onPrimaryContainer: Color(0xFF801A00),
        secondary: Color(0xFF00C2A8), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFFD6FFF8), onSecondaryContainer: Color(0xFF003D33),
        surface: Color(0xFFFFFEF0), onSurface: Color(0xFF111111),
        surfaceContainerLow: Color(0xFFFFFBD6), surfaceContainer: Color(0xFFFFF8B0), surfaceContainerHigh: Color(0xFFFFF08A),
        outline: Color(0xFF111111),
      ),
      shadows: _brutalLight,
      cardRadius: 0, buttonRadius: 0, inputRadius: 0, dialogRadius: 0,
      inputFilled: false, inputBorderWidth: 3,
      splashFactory: NoSplash.splashFactory,
      cardBorderColor: Color(0xFF111111), cardBorderWidth: 3,
      borderColor: Color(0xFF111111), borderWidth: 3, forceFlat: true,
      textTransform: ThemeTextTransform.uppercase, letterSpacingBoost: 0.8,
    ),
    darkPreset: AppThemePreset(
      id: 'brutalism', name: 'Brutalism', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFFF5722), onPrimary: Color(0xFF000000),
        primaryContainer: Color(0xFF801A00), onPrimaryContainer: Color(0xFFFFE0D6),
        secondary: Color(0xFF00E0C0), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF003D33), onSecondaryContainer: Color(0xFFD6FFF8),
        surface: Color(0xFF111111), onSurface: Color(0xFFFFFEF0),
        surfaceContainerLow: Color(0xFF1A1A1A), surfaceContainer: Color(0xFF222222), surfaceContainerHigh: Color(0xFF2A2A2A),
        outline: Color(0xFFFFFF00),
      ),
      shadows: _brutalDark,
      cardRadius: 0, buttonRadius: 0, inputRadius: 0, dialogRadius: 0,
      inputFilled: false, inputBorderWidth: 3,
      splashFactory: NoSplash.splashFactory,
      cardBorderColor: Color(0xFFFFFFFF), cardBorderWidth: 3,
      borderColor: Color(0xFFFFFFFF), borderWidth: 3, forceFlat: true,
      textTransform: ThemeTextTransform.uppercase, letterSpacingBoost: 0.8,
    ),
  );

  static const maximalism = AppThemeStyle(
    id: 'maximalism', name: 'Maximalism',
    lightPreset: AppThemePreset(
      id: 'maximalism', name: 'Maximalism', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFFFF006E), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFFFC2D4), onPrimaryContainer: Color(0xFF5A0024),
        secondary: Color(0xFFFFD60A), onSecondary: Color(0xFF1A0033),
        secondaryContainer: Color(0xFFFFF0A0), onSecondaryContainer: Color(0xFF4D3D00),
        tertiary: Color(0xFF3A86FF), onTertiary: Color(0xFFFFFFFF),
        surface: Color(0xFFFFF7E6), onSurface: Color(0xFF1A0033),
        surfaceContainerLow: Color(0xFFFFF0CC), surfaceContainer: Color(0xFFFFE8B0), surfaceContainerHigh: Color(0xFFFFD97A),
        outline: Color(0xFFFF006E),
      ),
      shadows: _maxiLight,
      cardRadius: 32, cardMargin: 16, cardElevation: 6, buttonRadius: 28, buttonElevation: 5, inputRadius: 32, dialogRadius: 32, dialogElevation: 10,
      inputBorderWidth: 3,
      cardBorderColor: Color(0xFFFF006E), cardBorderWidth: 3,
      borderColor: Color(0xFF1A0033), borderWidth: 3,
    ),
    darkPreset: AppThemePreset(
      id: 'maximalism', name: 'Maximalism', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFFF006E), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF5A0024), onPrimaryContainer: Color(0xFFFFC2D4),
        secondary: Color(0xFFFFD60A), onSecondary: Color(0xFF1A0033),
        secondaryContainer: Color(0xFF4D3D00), onSecondaryContainer: Color(0xFFFFF0A0),
        tertiary: Color(0xFF3A86FF), onTertiary: Color(0xFFFFFFFF),
        surface: Color(0xFF1A0033), onSurface: Color(0xFFFFF7E6),
        surfaceContainerLow: Color(0xFF2A1040), surfaceContainer: Color(0xFF361852), surfaceContainerHigh: Color(0xFF422064),
        outline: Color(0xFFFFD60A),
      ),
      shadows: _maxiDark,
      cardRadius: 32, cardMargin: 16, cardElevation: 6, buttonRadius: 28, buttonElevation: 5, inputRadius: 32, dialogRadius: 32, dialogElevation: 10,
      inputBorderWidth: 3,
      cardBorderColor: Color(0xFFFFD60A), cardBorderWidth: 3,
      borderColor: Color(0xFFFFD60A), borderWidth: 3,
    ),
  );

  static const skeuomorphism = AppThemeStyle(
    id: 'skeuomorphism', name: 'Skeuomorphism',
    lightPreset: AppThemePreset(
      id: 'skeuomorphism', name: 'Skeuomorphism', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF8B6F47), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFDCC8A8), onPrimaryContainer: Color(0xFF3D2E1A),
        secondary: Color(0xFFB8A07E), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFE8D8C0), onSecondaryContainer: Color(0xFF4A3A26),
        surface: Color(0xFFF0E8D8), onSurface: Color(0xFF3D3326),
        surfaceContainerLow: Color(0xFFF5EFE2), surfaceContainer: Color(0xFFEDE5D2), surfaceContainerHigh: Color(0xFFE5DBC4),
        outline: Color(0xFFC0B098),
      ),
      shadows: _skeuLight,
      cardRadius: 14, cardElevation: 2, buttonRadius: 12, buttonElevation: 4, inputRadius: 14, dialogRadius: 16, dialogElevation: 8,
    ),
    darkPreset: AppThemePreset(
      id: 'skeuomorphism', name: 'Skeuomorphism', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFD4B898), onPrimary: Color(0xFF1A1208),
        primaryContainer: Color(0xFF3D2E1A), onPrimaryContainer: Color(0xFFDCC8A8),
        secondary: Color(0xFFC8B098), onSecondary: Color(0xFF1A1208),
        secondaryContainer: Color(0xFF4A3A26), onSecondaryContainer: Color(0xFFE8D8C0),
        surface: Color(0xFF2B2520), onSurface: Color(0xFFE8E2D5),
        surfaceContainerLow: Color(0xFF35302A), surfaceContainer: Color(0xFF2F2A24), surfaceContainerHigh: Color(0xFF272220),
        outline: Color(0xFF605040),
      ),
      shadows: _skeuDark,
      cardRadius: 14, cardElevation: 2, buttonRadius: 12, buttonElevation: 4, inputRadius: 14, dialogRadius: 16, dialogElevation: 8,
    ),
  );

  static const skeuominimalism = AppThemeStyle(
    id: 'skeuominimalism', name: 'Skeuominimalism',
    lightPreset: AppThemePreset(
      id: 'skeuominimalism', name: 'Skeuominimalism', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF555555), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFE0E0E0), onPrimaryContainer: Color(0xFF222222),
        secondary: Color(0xFF909090), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFEEEEEE), onSecondaryContainer: Color(0xFF333333),
        surface: Color(0xFFFAFAFA), onSurface: Color(0xFF222222),
        surfaceContainerLow: Color(0xFFF5F5F5), surfaceContainer: Color(0xFFEEEEEE), surfaceContainerHigh: Color(0xFFE8E8E8),
        outline: Color(0xFFCCCCCC),
      ),
      shadows: _skeuLight,
      cardRadius: 12, cardElevation: 1, buttonRadius: 8, buttonElevation: 2, inputRadius: 12, dialogRadius: 12, dialogElevation: 4,
    ),
    darkPreset: AppThemePreset(
      id: 'skeuominimalism', name: 'Skeuominimalism', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFBBBBBB), onPrimary: Color(0xFF000000),
        primaryContainer: Color(0xFF333333), onPrimaryContainer: Color(0xFFE0E0E0),
        secondary: Color(0xFF808080), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF3A3A3A), onSecondaryContainer: Color(0xFFEEEEEE),
        surface: Color(0xFF1E1E1E), onSurface: Color(0xFFE0E0E0),
        surfaceContainerLow: Color(0xFF282828), surfaceContainer: Color(0xFF232323), surfaceContainerHigh: Color(0xFF1E1E1E),
        outline: Color(0xFF555555),
      ),
      shadows: _skeuDark,
      cardRadius: 12, cardElevation: 1, buttonRadius: 8, buttonElevation: 2, inputRadius: 12, dialogRadius: 12, dialogElevation: 4,
    ),
  );

  static const darkHighContrast = AppThemeStyle(
    id: 'dark-highcontrast', name: 'Dark High Contrast',
    lightPreset: AppThemePreset(
      id: 'dark-highcontrast', name: 'Dark High Contrast', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF000000), onPrimary: Color(0xFFFFFF00),
        primaryContainer: Color(0xFF000000), onPrimaryContainer: Color(0xFFFFFF00),
        secondary: Color(0xFF00E5FF), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF00E5FF), onSecondaryContainer: Color(0xFF000000),
        surface: Color(0xFFFFFFFF), onSurface: Color(0xFF000000),
        surfaceContainerLow: Color(0xFFEEEEEE), surfaceContainer: Color(0xFFDDDDDD), surfaceContainerHigh: Color(0xFFCCCCCC),
        outline: Color(0xFF000000),
      ),
      shadows: _hiContrast,
      cardRadius: 2, buttonRadius: 2, inputRadius: 2, dialogRadius: 2,
      inputFilled: false, inputBorderWidth: 2,
    ),
    darkPreset: AppThemePreset(
      id: 'dark-highcontrast', name: 'Dark High Contrast', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFFFD700), onPrimary: Color(0xFF000000),
        primaryContainer: Color(0xFFFFD700), onPrimaryContainer: Color(0xFF000000),
        secondary: Color(0xFF00E5FF), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF00E5FF), onSecondaryContainer: Color(0xFF000000),
        surface: Color(0xFF000000), onSurface: Color(0xFFFFFFFF),
        surfaceContainerLow: Color(0xFF111111), surfaceContainer: Color(0xFF222222), surfaceContainerHigh: Color(0xFF333333),
        outline: Color(0xFFFFFFFF),
      ),
      shadows: _hiContrast,
      cardRadius: 2, buttonRadius: 2, inputRadius: 2, dialogRadius: 2,
      inputFilled: false, inputBorderWidth: 2,
    ),
  );

  static const retro8bit = AppThemeStyle(
    id: 'retro-8bit', name: 'Retro 8-bit',
    lightPreset: AppThemePreset(
      id: 'retro-8bit', name: 'Retro 8-bit', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF76C043), onPrimary: Color(0xFF000000),
        primaryContainer: Color(0xFFD4F0C0), onPrimaryContainer: Color(0xFF1A3A0A),
        secondary: Color(0xFF3E5BC5), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFC0D0FF), onSecondaryContainer: Color(0xFF0A1A4D),
        tertiary: Color(0xFFE63946), onTertiary: Color(0xFFFFFFFF),
        surface: Color(0xFFE8E8E8), onSurface: Color(0xFF1A1A1A),
        surfaceContainerLow: Color(0xFFDDDDDD), surfaceContainer: Color(0xFFD0D0D0), surfaceContainerHigh: Color(0xFFC0C0C0),
        outline: Color(0xFF1A1A1A),
      ),
      shadows: _retroLight,
      cardRadius: 0, buttonRadius: 0, inputRadius: 0, dialogRadius: 0,
      inputFilled: false, inputBorderWidth: 2,
      splashFactory: NoSplash.splashFactory,
      cardBorderColor: Color(0xFF1A1A1A), cardBorderWidth: 2,
      borderColor: Color(0xFF1A1A1A), borderWidth: 2, forceFlat: true,
      textTransform: ThemeTextTransform.uppercase, letterSpacingBoost: 0.5,
    ),
    darkPreset: AppThemePreset(
      id: 'retro-8bit', name: 'Retro 8-bit', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF76C043), onPrimary: Color(0xFF000000),
        primaryContainer: Color(0xFF1A3A0A), onPrimaryContainer: Color(0xFFD4F0C0),
        secondary: Color(0xFF5C7FE8), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF0A1A4D), onSecondaryContainer: Color(0xFFC0D0FF),
        tertiary: Color(0xFFE63946), onTertiary: Color(0xFFFFFFFF),
        surface: Color(0xFF1A1A2E), onSurface: Color(0xFFE8E8E8),
        surfaceContainerLow: Color(0xFF252540), surfaceContainer: Color(0xFF2F2F50), surfaceContainerHigh: Color(0xFF3A3A66),
        outline: Color(0xFF00E5FF),
      ),
      shadows: _retroDark,
      cardRadius: 0, buttonRadius: 0, inputRadius: 0, dialogRadius: 0,
      inputFilled: false, inputBorderWidth: 2,
      splashFactory: NoSplash.splashFactory,
      cardBorderColor: Color(0xFF00E5FF), cardBorderWidth: 2,
      borderColor: Color(0xFF00E5FF), borderWidth: 2, forceFlat: true,
      textTransform: ThemeTextTransform.uppercase, letterSpacingBoost: 0.5,
    ),
  );

  static const cyberpunk = AppThemeStyle(
    id: 'cyberpunk', name: 'Cyberpunk',
    lightPreset: AppThemePreset(
      id: 'cyberpunk', name: 'Cyberpunk', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFFFF00FF), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF4D004D), onPrimaryContainer: Color(0xFFFF80FF),
        secondary: Color(0xFF00FFFF), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF004D4D), onSecondaryContainer: Color(0xFF80FFFF),
        tertiary: Color(0xFFFFD700), onTertiary: Color(0xFF000000),
        surface: Color(0xFF0A0A14), onSurface: Color(0xFF00FFFF),
        surfaceContainerLow: Color(0xFF111122), surfaceContainer: Color(0xFF181830), surfaceContainerHigh: Color(0xFF222244),
        outline: Color(0xFFFF00FF),
      ),
      shadows: _cyber,
      cardRadius: 4, buttonRadius: 2, inputRadius: 4, dialogRadius: 4,
      inputFilled: false, inputBorderWidth: 1,
      borderColor: Color(0xFF00FFFF), borderWidth: 1.5,
      textTransform: ThemeTextTransform.uppercase, letterSpacingBoost: 1.2,
    ),
    darkPreset: AppThemePreset(
      id: 'cyberpunk', name: 'Cyberpunk', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFFF00FF), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF4D004D), onPrimaryContainer: Color(0xFFFF80FF),
        secondary: Color(0xFF00FFFF), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF004D4D), onSecondaryContainer: Color(0xFF80FFFF),
        tertiary: Color(0xFFFFD700), onTertiary: Color(0xFF000000),
        surface: Color(0xFF0A0A14), onSurface: Color(0xFF00FFFF),
        surfaceContainerLow: Color(0xFF111122), surfaceContainer: Color(0xFF181830), surfaceContainerHigh: Color(0xFF222244),
        outline: Color(0xFFFF00FF),
      ),
      shadows: _cyber,
      cardRadius: 4, buttonRadius: 2, inputRadius: 4, dialogRadius: 4,
      inputFilled: false, inputBorderWidth: 1,
      borderColor: Color(0xFF00FFFF), borderWidth: 1.5,
      textTransform: ThemeTextTransform.uppercase, letterSpacingBoost: 1.2,
    ),
  );

  static const claymorphism = AppThemeStyle(
    id: 'claymorphism', name: 'Claymorphism',
    lightPreset: AppThemePreset(
      id: 'claymorphism', name: 'Claymorphism', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFFE85D75), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFFFD6DE), onPrimaryContainer: Color(0xFF4D1A26),
        secondary: Color(0xFF6CB6E8), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFD6EEFF), onSecondaryContainer: Color(0xFF0A3A5A),
        tertiary: Color(0xFFE8A06C), onTertiary: Color(0xFFFFFFFF),
        surface: Color(0xFFFDF0F4), onSurface: Color(0xFF3A2A33),
        surfaceContainerLow: Color(0xFFF8E8EE), surfaceContainer: Color(0xFFF2E0E8), surfaceContainerHigh: Color(0xFFECD0DA),
        outline: Color(0xFFD5B5C0),
      ),
      shadows: _clayLight,
      cardRadius: 28, cardMargin: 12, cardElevation: 0, buttonRadius: 24, buttonElevation: 0, inputRadius: 28, dialogRadius: 28,
      inputFilled: false, inputBorderWidth: 0,
    ),
    darkPreset: AppThemePreset(
      id: 'claymorphism', name: 'Claymorphism', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFF07090), onPrimary: Color(0xFF1A0A12),
        primaryContainer: Color(0xFF4D1A26), onPrimaryContainer: Color(0xFFFFD6DE),
        secondary: Color(0xFF80C8F0), onSecondary: Color(0xFF0A1A2A),
        secondaryContainer: Color(0xFF0A3A5A), onSecondaryContainer: Color(0xFFD6EEFF),
        tertiary: Color(0xFFF0B080), onTertiary: Color(0xFF1A0A12),
        surface: Color(0xFF2A2230), onSurface: Color(0xFFF8E8EE),
        surfaceContainerLow: Color(0xFF352B3D), surfaceContainer: Color(0xFF2F2635), surfaceContainerHigh: Color(0xFF27202C),
        outline: Color(0xFF60506A),
      ),
      shadows: _clayDark,
      cardRadius: 28, cardMargin: 12, cardElevation: 0, buttonRadius: 24, buttonElevation: 0, inputRadius: 28, dialogRadius: 28,
      inputFilled: false, inputBorderWidth: 0,
    ),
  );

  static const bauhaus = AppThemeStyle(
    id: 'bauhaus', name: 'Bauhaus',
    lightPreset: AppThemePreset(
      id: 'bauhaus', name: 'Bauhaus', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFFD62828), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFFFE0E0), onPrimaryContainer: Color(0xFF4D0A0A),
        secondary: Color(0xFFF4B400), onSecondary: Color(0xFF1A1A1A),
        secondaryContainer: Color(0xFFFFF0B0), onSecondaryContainer: Color(0xFF4D3D00),
        tertiary: Color(0xFF003F91), onTertiary: Color(0xFFFFFFFF),
        surface: Color(0xFFF5F0E6), onSurface: Color(0xFF1A1A1A),
        surfaceContainerLow: Color(0xFFEDE5D8), surfaceContainer: Color(0xFFE5DCC8), surfaceContainerHigh: Color(0xFFDDD2B8),
        outline: Color(0xFF1A1A1A),
      ),
      shadows: _bauhaus,
      cardRadius: 0, buttonRadius: 0, inputRadius: 0, dialogRadius: 0,
      inputFilled: false, inputBorderWidth: 3,
      splashFactory: NoSplash.splashFactory,
      cardBorderColor: Color(0xFF1A1A1A), cardBorderWidth: 3,
      borderColor: Color(0xFF1A1A1A), borderWidth: 2.5, forceFlat: true,
      textTransform: ThemeTextTransform.uppercase, letterSpacingBoost: 0.6,
    ),
    darkPreset: AppThemePreset(
      id: 'bauhaus', name: 'Bauhaus', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFE5383B), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF4D0A0A), onPrimaryContainer: Color(0xFFFFE0E0),
        secondary: Color(0xFFF4B400), onSecondary: Color(0xFF1A1A1A),
        secondaryContainer: Color(0xFF4D3D00), onSecondaryContainer: Color(0xFFFFF0B0),
        tertiary: Color(0xFF3A7BD5), onTertiary: Color(0xFFFFFFFF),
        surface: Color(0xFF1A1A1A), onSurface: Color(0xFFF5F0E6),
        surfaceContainerLow: Color(0xFF262626), surfaceContainer: Color(0xFF303030), surfaceContainerHigh: Color(0xFF3A3A3A),
        outline: Color(0xFFF5F0E6),
      ),
      shadows: _bauhaus,
      cardRadius: 0, buttonRadius: 0, inputRadius: 0, dialogRadius: 0,
      inputFilled: false, inputBorderWidth: 3,
      splashFactory: NoSplash.splashFactory,
      cardBorderColor: Color(0xFFF5F0E6), cardBorderWidth: 3,
      borderColor: Color(0xFFF5F0E6), borderWidth: 2.5, forceFlat: true,
      textTransform: ThemeTextTransform.uppercase, letterSpacingBoost: 0.6,
    ),
  );

  static const organic = AppThemeStyle(
    id: 'organic', name: 'Organic',
    lightPreset: AppThemePreset(
      id: 'organic', name: 'Organic', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF6B8E4E), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFD8E8C8), onPrimaryContainer: Color(0xFF1A2D0A),
        secondary: Color(0xFFD4A373), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFF0D8B8), onSecondaryContainer: Color(0xFF4D3A1A),
        tertiary: Color(0xFFA07550), onTertiary: Color(0xFFFFFFFF),
        surface: Color(0xFFF7F3EE), onSurface: Color(0xFF3D3228),
        surfaceContainerLow: Color(0xFFEDE5DA), surfaceContainer: Color(0xFFE5DCCA), surfaceContainerHigh: Color(0xFFDDD2BA),
        outline: Color(0xFFB8A898),
      ),
      shadows: _organic,
      cardRadius: 36, cardMargin: 14, buttonRadius: 30, inputRadius: 36, dialogRadius: 36,
    ),
    darkPreset: AppThemePreset(
      id: 'organic', name: 'Organic', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF8DAE6E), onPrimary: Color(0xFF0A1A05),
        primaryContainer: Color(0xFF1A2D0A), onPrimaryContainer: Color(0xFFD8E8C8),
        secondary: Color(0xFFE8B888), onSecondary: Color(0xFF2A1A08),
        secondaryContainer: Color(0xFF4D3A1A), onSecondaryContainer: Color(0xFFF0D8B8),
        tertiary: Color(0xFFC09070), onTertiary: Color(0xFF1A0A05),
        surface: Color(0xFF2A2520), onSurface: Color(0xFFF7F3EE),
        surfaceContainerLow: Color(0xFF352F28), surfaceContainer: Color(0xFF2F2A24), surfaceContainerHigh: Color(0xFF27221E),
        outline: Color(0xFF605548),
      ),
      shadows: _organic,
      cardRadius: 36, cardMargin: 14, buttonRadius: 30, inputRadius: 36, dialogRadius: 36,
    ),
  );

  static const typographic = AppThemeStyle(
    id: 'typographic', name: 'Typographic',
    lightPreset: AppThemePreset(
      id: 'typographic', name: 'Typographic', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF111111), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFEEEEEE), onPrimaryContainer: Color(0xFF111111),
        secondary: Color(0xFF666666), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFDDDDDD), onSecondaryContainer: Color(0xFF222222),
        surface: Color(0xFFFAFAFA), onSurface: Color(0xFF111111),
        surfaceContainerLow: Color(0xFFF5F5F5), surfaceContainer: Color(0xFFEEEEEE), surfaceContainerHigh: Color(0xFFE8E8E8),
        outline: Color(0xFF111111),
      ),
      shadows: _typo,
      cardRadius: 2, buttonRadius: 2, inputRadius: 2, dialogRadius: 2,
      inputFilled: false, inputBorderWidth: 1,
      borderColor: Color(0xFF111111), borderWidth: 1, forceFlat: true,
      textTransform: ThemeTextTransform.uppercase, letterSpacingBoost: 1.5,
    ),
    darkPreset: AppThemePreset(
      id: 'typographic', name: 'Typographic', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFFFFFFF), onPrimary: Color(0xFF111111),
        primaryContainer: Color(0xFF222222), onPrimaryContainer: Color(0xFFFFFFFF),
        secondary: Color(0xFF999999), onSecondary: Color(0xFF111111),
        secondaryContainer: Color(0xFF333333), onSecondaryContainer: Color(0xFFEEEEEE),
        surface: Color(0xFF111111), onSurface: Color(0xFFFAFAFA),
        surfaceContainerLow: Color(0xFF1A1A1A), surfaceContainer: Color(0xFF222222), surfaceContainerHigh: Color(0xFF2A2A2A),
        outline: Color(0xFFFFFFFF),
      ),
      shadows: _typo,
      cardRadius: 2, buttonRadius: 2, inputRadius: 2, dialogRadius: 2,
      inputFilled: false, inputBorderWidth: 1,
      borderColor: Color(0xFFFFFFFF), borderWidth: 1, forceFlat: true,
      textTransform: ThemeTextTransform.uppercase, letterSpacingBoost: 1.5,
    ),
  );

  static const minimalismMono = AppThemeStyle(
    id: 'minimalism-mono', name: 'Minimalism Mono',
    lightPreset: AppThemePreset(
      id: 'minimalism-mono', name: 'Minimalism Mono', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF222222), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFEEEEEE), onPrimaryContainer: Color(0xFF222222),
        secondary: Color(0xFF666666), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFDDDDDD), onSecondaryContainer: Color(0xFF333333),
        surface: Color(0xFFFFFFFF), onSurface: Color(0xFF222222),
        surfaceContainerLow: Color(0xFFF8F8F8), surfaceContainer: Color(0xFFF5F5F5), surfaceContainerHigh: Color(0xFFF0F0F0),
        outline: Color(0xFFDDDDDD),
      ),
      shadows: _mono,
      cardRadius: 8, buttonRadius: 8, inputRadius: 8, dialogRadius: 8,
      inputFilled: false, inputBorderWidth: 1,
      forceFlat: true,
    ),
    darkPreset: AppThemePreset(
      id: 'minimalism-mono', name: 'Minimalism Mono', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFDDDDDD), onPrimary: Color(0xFF111111),
        primaryContainer: Color(0xFF333333), onPrimaryContainer: Color(0xFFDDDDDD),
        secondary: Color(0xFF888888), onSecondary: Color(0xFF111111),
        secondaryContainer: Color(0xFF3A3A3A), onSecondaryContainer: Color(0xFFEEEEEE),
        surface: Color(0xFF1A1A1A), onSurface: Color(0xFFDDDDDD),
        surfaceContainerLow: Color(0xFF242424), surfaceContainer: Color(0xFF2A2A2A), surfaceContainerHigh: Color(0xFF303030),
        outline: Color(0xFF444444),
      ),
      shadows: _mono,
      cardRadius: 8, buttonRadius: 8, inputRadius: 8, dialogRadius: 8,
      inputFilled: false, inputBorderWidth: 1,
      forceFlat: true,
    ),
  );

  static const papercut = AppThemeStyle(
    id: 'papercut', name: 'Papercut',
    lightPreset: AppThemePreset(
      id: 'papercut', name: 'Papercut', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFFE63946), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFFFE0E4), onPrimaryContainer: Color(0xFF4D0A14),
        secondary: Color(0xFF457B9D), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFD0E4F0), onSecondaryContainer: Color(0xFF0A2A40),
        tertiary: Color(0xFFE9C46A), onTertiary: Color(0xFF1A1A1A),
        surface: Color(0xFFF1FAEE), onSurface: Color(0xFF1D3557),
        surfaceContainerLow: Color(0xFFE8F0E2), surfaceContainer: Color(0xFFDDE8D4), surfaceContainerHigh: Color(0xFFD0E0C4),
        outline: Color(0xFF1D3557),
      ),
      shadows: _paperLight,
      cardRadius: 4, cardMargin: 10, buttonRadius: 4, inputRadius: 4, dialogRadius: 4,
      inputFilled: false, inputBorderWidth: 2,
      borderColor: Color(0xFF1D3557), borderWidth: 1,
    ),
    darkPreset: AppThemePreset(
      id: 'papercut', name: 'Papercut', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFFE63946), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFF4D0A14), onPrimaryContainer: Color(0xFFFFE0E4),
        secondary: Color(0xFF6BA8C8), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF0A2A40), onSecondaryContainer: Color(0xFFD0E4F0),
        tertiary: Color(0xFFE9C46A), onTertiary: Color(0xFF1A1A1A),
        surface: Color(0xFF1D3557), onSurface: Color(0xFFF1FAEE),
        surfaceContainerLow: Color(0xFF26416B), surfaceContainer: Color(0xFF2C4A78), surfaceContainerHigh: Color(0xFF34548A),
        outline: Color(0xFFE63946),
      ),
      shadows: _paperDark,
      cardRadius: 4, cardMargin: 10, buttonRadius: 4, inputRadius: 4, dialogRadius: 4,
      inputFilled: false, inputBorderWidth: 2,
      borderColor: Color(0xFFE63946), borderWidth: 1,
    ),
  );

  static const skeuomorphismClassic = AppThemeStyle(
    id: 'skeuomorphism-classic', name: 'Skeuomorphism Classic',
    lightPreset: AppThemePreset(
      id: 'skeuomorphism-classic', name: 'Skeuomorphism Classic', brightness: Brightness.light,
      colorScheme: ColorScheme.light(
        primary: Color(0xFF3B82C4), onPrimary: Color(0xFFFFFFFF),
        primaryContainer: Color(0xFFD0E4F5), onPrimaryContainer: Color(0xFF0A2D4D),
        secondary: Color(0xFF9AB7D6), onSecondary: Color(0xFFFFFFFF),
        secondaryContainer: Color(0xFFE0ECF5), onSecondaryContainer: Color(0xFF1A3A5A),
        surface: Color(0xFFE0E5EC), onSurface: Color(0xFF2C3E50),
        surfaceContainerLow: Color(0xFFE8ECF2), surfaceContainer: Color(0xFFDDE3EA), surfaceContainerHigh: Color(0xFFD2DAE2),
        outline: Color(0xFFA3B1C6),
      ),
      shadows: _skeuClassic,
      cardRadius: 14, cardElevation: 3, buttonRadius: 12, buttonElevation: 5, inputRadius: 14, dialogRadius: 16, dialogElevation: 10,
    ),
    darkPreset: AppThemePreset(
      id: 'skeuomorphism-classic', name: 'Skeuomorphism Classic', brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF5CA0DC), onPrimary: Color(0xFF000000),
        primaryContainer: Color(0xFF0A2D4D), onPrimaryContainer: Color(0xFFD0E4F5),
        secondary: Color(0xFFB0C8E0), onSecondary: Color(0xFF000000),
        secondaryContainer: Color(0xFF1A3A5A), onSecondaryContainer: Color(0xFFE0ECF5),
        surface: Color(0xFF2C3E50), onSurface: Color(0xFFD0D8E0),
        surfaceContainerLow: Color(0xFF36485A), surfaceContainer: Color(0xFF304454), surfaceContainerHigh: Color(0xFF2A3C4C),
        outline: Color(0xFF6080A0),
      ),
      shadows: _skeuClassic,
      cardRadius: 14, cardElevation: 3, buttonRadius: 12, buttonElevation: 5, inputRadius: 14, dialogRadius: 16, dialogElevation: 10,
    ),
  );

  static final all = <AppThemeStyle>[
    light, dark, flat, material, neumorphism, glassmorphism, brutalism,
    maximalism, skeuomorphism, skeuominimalism, darkHighContrast, retro8bit,
    cyberpunk, claymorphism, bauhaus, organic, typographic, minimalismMono,
    papercut, skeuomorphismClassic,
  ];

  static AppThemeStyle byId(String id) =>
      all.firstWhere((s) => s.id == id, orElse: () => material);
}
