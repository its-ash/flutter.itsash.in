import 'package:flutter/material.dart';

import 'package:theme/src/colors/app_colors.dart';
import 'package:theme/src/shadows/app_shadow_theme.dart';
import 'package:theme/src/theme_presets/app_theme_preset.dart';

class LightPresets {
  LightPresets._();

  static final default_ = AppThemePreset(
    id: 'default',
    name: 'Default',
    brightness: Brightness.light,
    colorScheme: AppColors.lightColorScheme,
    shadows: const AppShadowTheme(),
  );

  static const flat = AppThemePreset(
    id: 'flat',
    name: 'Flat',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF2196F3),
      secondary: Color(0xFF00BCD4),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF212121),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
      shadowOne: BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
      shadowTwo: BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
      shadowThree: BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
    ),
    cardRadius: 4,
    buttonRadius: 4,
    inputRadius: 4,
    dialogRadius: 4,
    borderColor: Color(0xFFBDBDBD),
    borderWidth: 1,
    forceFlat: true,
  );

  static const material = AppThemePreset(
    id: 'material',
    name: 'Material',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF6200EE),
      secondary: Color(0xFF03DAC6),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF1C1B1F),
    ),
    shadows: AppShadowTheme(),
    cardRadius: 8,
    buttonRadius: 20,
    inputRadius: 8,
    dialogRadius: 8,
  );

  static final neumorphism = AppThemePreset(
    id: 'neumorphism',
    name: 'Neumorphism',
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF5C7AEA),
      secondary: Color(0xFFA0B0E8),
      surface: Color(0xFFE3EDF7),
      onSurface: Color(0xFF3A4A5A),
    ),
    shadows: AppShadowTheme(
      hairline: const BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
      shadowOne: const BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 16, offset: Offset(-6, -6)),
      shadowTwo: const BoxShadow(color: Color(0xFFB0C0D0), blurRadius: 16, offset: Offset(6, 6)),
      shadowThree: const BoxShadow(color: Color(0xFF90A0B0), blurRadius: 24, offset: Offset(8, 8)),
    ),
    cardRadius: 24,
    buttonRadius: 24,
    inputRadius: 16,
    dialogRadius: 24,
  );

  static final glassmorphism = AppThemePreset(
    id: 'glassmorphism',
    name: 'Glassmorphism',
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF7B61FF),
      secondary: Color(0xFF61D6FF),
      surface: Color(0xF2FFFFFF),
      onSurface: Color(0xFF1A1A2E),
    ),
    shadows: AppShadowTheme(
      hairline: const BoxShadow(color: Color(0x33FFFFFF), blurRadius: 0, offset: Offset(0, 1)),
      shadowOne: const BoxShadow(color: Color(0x1A000000), blurRadius: 12, offset: Offset(0, 4)),
      shadowTwo: const BoxShadow(color: Color(0x26000000), blurRadius: 20, offset: Offset(0, 8)),
      shadowThree: const BoxShadow(color: Color(0x40000000), blurRadius: 30, offset: Offset(0, 12)),
    ),
    cardRadius: 28,
    buttonRadius: 20,
    inputRadius: 16,
    dialogRadius: 28,
  );

  static const brutalism = AppThemePreset(
    id: 'brutalism',
    name: 'Brutalism',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFFFF3B00),
      secondary: Color(0xFF00C2A8),
      surface: Color(0xFFFFFEF0),
      onSurface: Color(0xFF111111),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
      shadowOne: BoxShadow(color: Color(0xFF111111), blurRadius: 0, offset: Offset(4, 4)),
      shadowTwo: BoxShadow(color: Color(0xFF111111), blurRadius: 0, offset: Offset(6, 6)),
      shadowThree: BoxShadow(color: Color(0xFF111111), blurRadius: 0, offset: Offset(8, 8)),
    ),
    cardRadius: 0,
    buttonRadius: 0,
    inputRadius: 0,
    dialogRadius: 0,
    borderColor: Color(0xFF111111),
    borderWidth: 3,
    forceFlat: true,
    textTransform: ThemeTextTransform.uppercase,
    letterSpacingBoost: 0.8,
  );

  static const maximalism = AppThemePreset(
    id: 'maximalism',
    name: 'Maximalism',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFFFF006E),
      secondary: Color(0xFFFFD60A),
      surface: Color(0xFFFFF7E6),
      onSurface: Color(0xFF1A0033),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Color(0xFFFF006E), blurRadius: 0, offset: Offset(2, 2)),
      shadowOne: BoxShadow(color: Color(0x66FF006E), blurRadius: 12, offset: Offset(0, 4)),
      shadowTwo: BoxShadow(color: Color(0x99FFD60A), blurRadius: 20, offset: Offset(4, 8)),
      shadowThree: BoxShadow(color: Color(0x993A86FF), blurRadius: 30, offset: Offset(8, 12)),
    ),
    cardRadius: 32,
    buttonRadius: 28,
    inputRadius: 20,
    dialogRadius: 32,
    borderColor: Color(0xFF1A0033),
    borderWidth: 3,
  );

  static final skeuomorphism = AppThemePreset(
    id: 'skeuomorphism',
    name: 'Skeuomorphism',
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF6B5B45),
      secondary: Color(0xFFB8A07E),
      surface: Color(0xFFE8E2D5),
      onSurface: Color(0xFF3D3326),
    ),
    shadows: AppShadowTheme(
      hairline: const BoxShadow(color: Color(0x22000000), blurRadius: 0, offset: Offset(0, 1)),
      shadowOne: const BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 2)),
      shadowTwo: const BoxShadow(color: Color(0x4D000000), blurRadius: 10, offset: Offset(0, 5)),
      shadowThree: const BoxShadow(color: Color(0x66000000), blurRadius: 18, offset: Offset(0, 10)),
    ),
    cardRadius: 12,
    buttonRadius: 10,
    inputRadius: 8,
    dialogRadius: 14,
  );

  static const skeuominimalism = AppThemePreset(
    id: 'skeuominimalism',
    name: 'Skeuominimalism',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF4A4A4A),
      secondary: Color(0xFF8E8E8E),
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF222222),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Color(0x1A000000), blurRadius: 0, offset: Offset(0, 1)),
      shadowOne: BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
      shadowTwo: BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 3)),
      shadowThree: BoxShadow(color: Color(0x40000000), blurRadius: 10, offset: Offset(0, 6)),
    ),
    cardRadius: 12,
    buttonRadius: 8,
    inputRadius: 8,
    dialogRadius: 12,
    borderColor: Color(0xFFDADADA),
    borderWidth: 1,
  );

  static const retro8bit = AppThemePreset(
    id: 'retro-8bit',
    name: 'Retro 8-bit',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF76C043),
      secondary: Color(0xFF3E5BC5),
      surface: Color(0xFFE8E8E8),
      onSurface: Color(0xFF1A1A1A),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Color(0xFF1A1A1A), blurRadius: 0, offset: Offset(0, 4)),
      shadowOne: BoxShadow(color: Color(0xFF1A1A1A), blurRadius: 0, offset: Offset(4, 4)),
      shadowTwo: BoxShadow(color: Color(0xFF1A1A1A), blurRadius: 0, offset: Offset(6, 6)),
      shadowThree: BoxShadow(color: Color(0xFF1A1A1A), blurRadius: 0, offset: Offset(8, 8)),
    ),
    cardRadius: 0,
    buttonRadius: 0,
    inputRadius: 0,
    dialogRadius: 0,
    borderColor: Color(0xFF1A1A1A),
    borderWidth: 3,
    forceFlat: true,
    textTransform: ThemeTextTransform.uppercase,
    letterSpacingBoost: 0.5,
  );

  static const cyberpunk = AppThemePreset(
    id: 'cyberpunk',
    name: 'Cyberpunk',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFFFF00FF),
      secondary: Color(0xFF00FFFF),
      surface: Color(0xFF0A0A14),
      onSurface: Color(0xFF00FFFF),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Color(0xFFFF00FF), blurRadius: 0, offset: Offset(0, 1)),
      shadowOne: BoxShadow(color: Color(0x99FF00FF), blurRadius: 8, offset: Offset(0, 0)),
      shadowTwo: BoxShadow(color: Color(0x9900FFFF), blurRadius: 12, offset: Offset(0, 4)),
      shadowThree: BoxShadow(color: Color(0xCCFF00FF), blurRadius: 20, offset: Offset(0, 8)),
    ),
    cardRadius: 4,
    buttonRadius: 2,
    inputRadius: 2,
    dialogRadius: 4,
    borderColor: Color(0xFF00FFFF),
    borderWidth: 1.5,
    textTransform: ThemeTextTransform.uppercase,
    letterSpacingBoost: 1.2,
  );

  static final claymorphism = AppThemePreset(
    id: 'claymorphism',
    name: 'Claymorphism',
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: Color(0xFFFF7A9C),
      secondary: Color(0xFF7AC9FF),
      surface: Color(0xFFFBEFF4),
      onSurface: Color(0xFF3A2A33),
    ),
    shadows: AppShadowTheme(
      hairline: const BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
      shadowOne: const BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 14, offset: Offset(-5, -5)),
      shadowTwo: const BoxShadow(color: Color(0x4DB49ACC), blurRadius: 18, offset: Offset(7, 7)),
      shadowThree: const BoxShadow(color: Color(0x66B49ACC), blurRadius: 26, offset: Offset(10, 10)),
    ),
    cardRadius: 28,
    buttonRadius: 24,
    inputRadius: 20,
    dialogRadius: 28,
  );

  static const bauhaus = AppThemePreset(
    id: 'bauhaus',
    name: 'Bauhaus',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFFD62828),
      secondary: Color(0xFFF4B400),
      surface: Color(0xFFF5F0E6),
      onSurface: Color(0xFF1A1A1A),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Color(0xFF1A1A1A), blurRadius: 0, offset: Offset(0, 2)),
      shadowOne: BoxShadow(color: Color(0xFF1A1A1A), blurRadius: 0, offset: Offset(0, 4)),
      shadowTwo: BoxShadow(color: Color(0xFF1A1A1A), blurRadius: 0, offset: Offset(0, 6)),
      shadowThree: BoxShadow(color: Color(0xFF1A1A1A), blurRadius: 0, offset: Offset(0, 8)),
    ),
    cardRadius: 0,
    buttonRadius: 0,
    inputRadius: 0,
    dialogRadius: 0,
    borderColor: Color(0xFF1A1A1A),
    borderWidth: 2.5,
    forceFlat: true,
    textTransform: ThemeTextTransform.uppercase,
    letterSpacingBoost: 0.6,
  );

  static const organic = AppThemePreset(
    id: 'organic',
    name: 'Organic',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF6B8E4E),
      secondary: Color(0xFFD4A373),
      surface: Color(0xFFF7F3EE),
      onSurface: Color(0xFF3D3228),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Color(0x14B8956A), blurRadius: 0, offset: Offset(0, 1)),
      shadowOne: BoxShadow(color: Color(0x26B8956A), blurRadius: 14, offset: Offset(0, 6)),
      shadowTwo: BoxShadow(color: Color(0x33B8956A), blurRadius: 22, offset: Offset(0, 12)),
      shadowThree: BoxShadow(color: Color(0x40B8956A), blurRadius: 32, offset: Offset(0, 18)),
    ),
    cardRadius: 36,
    buttonRadius: 30,
    inputRadius: 24,
    dialogRadius: 36,
  );

  static const typographic = AppThemePreset(
    id: 'typographic',
    name: 'Typographic',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF111111),
      secondary: Color(0xFF888888),
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF111111),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Color(0xFF111111), blurRadius: 0, offset: Offset(0, 1)),
      shadowOne: BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
      shadowTwo: BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
      shadowThree: BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
    ),
    cardRadius: 2,
    buttonRadius: 2,
    inputRadius: 2,
    dialogRadius: 2,
    borderColor: Color(0xFF111111),
    borderWidth: 1,
    forceFlat: true,
    textTransform: ThemeTextTransform.uppercase,
    letterSpacingBoost: 1.5,
  );

  static const minimalismMono = AppThemePreset(
    id: 'minimalism-mono',
    name: 'Minimalism Mono',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF222222),
      secondary: Color(0xFF666666),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF222222),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Color(0x11000000), blurRadius: 0, offset: Offset(0, 1)),
      shadowOne: BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
      shadowTwo: BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
      shadowThree: BoxShadow(color: Colors.transparent, blurRadius: 0, offset: Offset.zero),
    ),
    cardRadius: 8,
    buttonRadius: 8,
    inputRadius: 8,
    dialogRadius: 8,
    forceFlat: true,
  );

  static const papercut = AppThemePreset(
    id: 'papercut',
    name: 'Papercut',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFFE63946),
      secondary: Color(0xFF457B9D),
      surface: Color(0xFFF1FAEE),
      onSurface: Color(0xFF1D3557),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Color(0x1A1D3557), blurRadius: 0, offset: Offset(2, 2)),
      shadowOne: BoxShadow(color: Color(0x331D3557), blurRadius: 0, offset: Offset(3, 3)),
      shadowTwo: BoxShadow(color: Color(0x4D1D3557), blurRadius: 0, offset: Offset(5, 5)),
      shadowThree: BoxShadow(color: Color(0x661D3557), blurRadius: 0, offset: Offset(7, 7)),
    ),
    cardRadius: 4,
    buttonRadius: 4,
    inputRadius: 4,
    dialogRadius: 4,
    borderColor: Color(0xFF1D3557),
    borderWidth: 1,
  );

  static const skeuomorphismClassic = AppThemePreset(
    id: 'skeuomorphism-classic',
    name: 'Skeuomorphism Classic',
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: Color(0xFF3B82C4),
      secondary: Color(0xFF9AB7D6),
      surface: Color(0xFFE0E5EC),
      onSurface: Color(0xFF2C3E50),
    ),
    shadows: AppShadowTheme(
      hairline: BoxShadow(color: Color(0xFFFFFFFF), blurRadius: 0, offset: Offset(0, -1)),
      shadowOne: BoxShadow(color: Color(0x66A3B1C6), blurRadius: 6, offset: Offset(2, 2)),
      shadowTwo: BoxShadow(color: Color(0x99A3B1C6), blurRadius: 12, offset: Offset(4, 4)),
      shadowThree: BoxShadow(color: Color(0xCCA3B1C6), blurRadius: 20, offset: Offset(6, 6)),
    ),
    cardRadius: 14,
    buttonRadius: 12,
    inputRadius: 10,
    dialogRadius: 16,
  );

  static final all = <AppThemePreset>[
    default_,
    flat,
    material,
    neumorphism,
    glassmorphism,
    brutalism,
    maximalism,
    skeuomorphism,
    skeuominimalism,
    retro8bit,
    cyberpunk,
    claymorphism,
    bauhaus,
    organic,
    typographic,
    minimalismMono,
    papercut,
    skeuomorphismClassic,
  ];

  static AppThemePreset byId(String id) =>
      all.firstWhere((p) => p.id == id, orElse: () => default_);
}