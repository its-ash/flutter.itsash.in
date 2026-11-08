import 'package:flutter/material.dart';

@immutable
class UiBrand {
  const UiBrand({
    required this.id,
    required this.name,
    required this.seed,
    this.headingFont = 'Plus Jakarta Sans',
    this.bodyFont = 'Inter',
    this.radiusScale = 1,
    this.variant = DynamicSchemeVariant.tonalSpot,
  });

  final String id;
  final String name;
  final Color seed;
  final String headingFont;
  final String bodyFont;
  final double radiusScale;
  final DynamicSchemeVariant variant;

  static const neutral = UiBrand(id: 'neutral', name: 'Neutral', seed: Color(0xFF4F46E5));
  static const commerce = UiBrand(
    id: 'commerce',
    name: 'Commerce',
    seed: Color(0xFFFF5A36),
    headingFont: 'Outfit',
    variant: DynamicSchemeVariant.fidelity,
  );
  static const fitness = UiBrand(
    id: 'fitness',
    name: 'Fitness',
    seed: Color(0xFF84CC16),
    headingFont: 'Sora',
    radiusScale: 1.2,
    variant: DynamicSchemeVariant.vibrant,
  );
  static const finance = UiBrand(
    id: 'finance',
    name: 'Finance',
    seed: Color(0xFF0F766E),
    headingFont: 'Manrope',
    bodyFont: 'Manrope',
    radiusScale: 0.85,
  );
  static const health = UiBrand(id: 'health', name: 'Health', seed: Color(0xFF0EA5E9), headingFont: 'Nunito', bodyFont: 'Nunito', radiusScale: 1.2);
  static const food = UiBrand(
    id: 'food',
    name: 'Food',
    seed: Color(0xFFF59E0B),
    headingFont: 'Poppins',
    radiusScale: 1.1,
    variant: DynamicSchemeVariant.fidelity,
  );
  static const travel = UiBrand(id: 'travel', name: 'Travel', seed: Color(0xFF2563EB), headingFont: 'DM Sans', bodyFont: 'DM Sans');
  static const social = UiBrand(
    id: 'social',
    name: 'Social',
    seed: Color(0xFFE1306C),
    headingFont: 'Poppins',
    radiusScale: 1.3,
    variant: DynamicSchemeVariant.vibrant,
  );
  static const education = UiBrand(id: 'education', name: 'Education', seed: Color(0xFF7C3AED), headingFont: 'Lexend', bodyFont: 'Lexend');
  static const productivity = UiBrand(
    id: 'productivity',
    name: 'Productivity',
    seed: Color(0xFF475569),
    radiusScale: 0.75,
    variant: DynamicSchemeVariant.neutral,
  );
  static const luxury = UiBrand(
    id: 'luxury',
    name: 'Luxury',
    seed: Color(0xFF8B6F47),
    headingFont: 'Playfair Display',
    bodyFont: 'Lato',
    radiusScale: 0.5,
    variant: DynamicSchemeVariant.fidelity,
  );

  static const values = [neutral, commerce, fitness, finance, health, food, travel, social, education, productivity, luxury];

  static UiBrand byId(String id) => values.firstWhere((b) => b.id == id, orElse: () => neutral);

  UiBrand copyWith({
    String? id,
    String? name,
    Color? seed,
    String? headingFont,
    String? bodyFont,
    double? radiusScale,
    DynamicSchemeVariant? variant,
  }) =>
      UiBrand(
        id: id ?? this.id,
        name: name ?? this.name,
        seed: seed ?? this.seed,
        headingFont: headingFont ?? this.headingFont,
        bodyFont: bodyFont ?? this.bodyFont,
        radiusScale: (radiusScale ?? this.radiusScale).clamp(0, 3),
        variant: variant ?? this.variant,
      );

  @override
  bool operator ==(Object other) =>
      other is UiBrand &&
      other.id == id &&
      other.seed == seed &&
      other.headingFont == headingFont &&
      other.bodyFont == bodyFont &&
      other.radiusScale == radiusScale &&
      other.variant == variant;

  @override
  int get hashCode => Object.hash(id, seed, headingFont, bodyFont, radiusScale, variant);
}
