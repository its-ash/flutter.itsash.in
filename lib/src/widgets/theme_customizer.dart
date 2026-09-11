import 'package:flutter/material.dart';

import 'package:theme/src/theme_presets/app_theme_generator.dart';
import 'package:theme/src/widgets/theme_color_picker.dart';
import 'package:theme/src/widgets/theme_hue_picker.dart';

/// The font choice a [ThemeCustomizer] reports back through [ThemeCustomizerResult].
/// Either pick [pairing] (one of [AppFontPairings]' curated heading+body
/// pairs) or set [headingFont]/[bodyFont] independently — when either is
/// set it wins over [pairing] for that slot, so heading and body can come
/// from entirely different sources.
class ThemeCustomizerResult {
  const ThemeCustomizerResult({
    required this.seedColor,
    this.pairing,
    this.headingFont,
    this.bodyFont,
  });

  final Color seedColor;
  final AppFontPairing? pairing;
  final String? headingFont;
  final String? bodyFont;
}

/// A brand customizer: pick a seed color (from [AppSeedPalette] or the
/// free-form [ThemeHuePicker]) and a font — a curated pairing, or the
/// heading/body font picked independently from [AppFontCatalog] — while
/// [onChanged] reports back a [ThemeCustomizerResult] the caller feeds into
/// [AppThemeGenerator.generate] (typically with `baseStyle:` set to the
/// currently-selected [AppThemeStyle], so color/font/style stay fully
/// independent — any theme, any color, any font, together).
///
/// ```dart
/// ThemeCustomizer(
///   seedColor: _seed,
///   headingFont: _heading,
///   bodyFont: _body,
///   onChanged: (r) => setState(() {
///     _seed = r.seedColor;
///     _heading = r.headingFont;
///     _body = r.bodyFont;
///   }),
/// )
/// ```
class ThemeCustomizer extends StatelessWidget {
  const ThemeCustomizer({
    super.key,
    required this.seedColor,
    required this.onChanged,
    this.pairing,
    this.headingFont,
    this.bodyFont,
    this.showHuePicker = true,
  });

  final Color seedColor;
  final AppFontPairing? pairing;
  final String? headingFont;
  final String? bodyFont;
  final ValueChanged<ThemeCustomizerResult> onChanged;
  final bool showHuePicker;

  bool get _isCustomFont => headingFont != null || bodyFont != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final suggested = AppThemeGenerator.suggestFontPairing(seedColor);
    final effectiveHeading = headingFont ?? pairing?.heading ?? suggested.heading;
    final effectiveBody = bodyFont ?? pairing?.body ?? suggested.body;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Color', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ThemeColorPicker(
          colors: AppSeedPalette.swatches,
          selected: seedColor,
          onSelected: (c) => onChanged(ThemeCustomizerResult(
            seedColor: c,
            pairing: pairing,
            headingFont: headingFont,
            bodyFont: bodyFont,
          )),
        ),
        if (showHuePicker) ...[
          const SizedBox(height: 16),
          ThemeHuePicker(
            color: seedColor,
            onChanged: (c) => onChanged(ThemeCustomizerResult(
              seedColor: c,
              pairing: pairing,
              headingFont: headingFont,
              bodyFont: bodyFont,
            )),
          ),
        ],
        const SizedBox(height: 20),
        Text('Font', style: theme.textTheme.titleMedium),
        const SizedBox(height: 4),
        Text(
          '$effectiveHeading (headings) + $effectiveBody (body)',
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ChoiceChip(
              label: const Text('Auto'),
              selected: pairing == null && !_isCustomFont,
              onSelected: (_) => onChanged(ThemeCustomizerResult(seedColor: seedColor)),
            ),
            for (final p in AppFontPairings.all)
              ChoiceChip(
                label: Text(p.name),
                selected: pairing == p,
                onSelected: (_) => onChanged(ThemeCustomizerResult(seedColor: seedColor, pairing: p)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _FontDropdown(
                label: 'Heading font',
                value: effectiveHeading,
                onChanged: (f) => onChanged(ThemeCustomizerResult(
                  seedColor: seedColor,
                  headingFont: f,
                  bodyFont: bodyFont ?? effectiveBody,
                )),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FontDropdown(
                label: 'Body font',
                value: effectiveBody,
                onChanged: (f) => onChanged(ThemeCustomizerResult(
                  seedColor: seedColor,
                  headingFont: headingFont ?? effectiveHeading,
                  bodyFont: f,
                )),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FontDropdown extends StatelessWidget {
  const _FontDropdown({required this.label, required this.value, required this.onChanged});

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final fonts = AppFontCatalog.all;
    return DropdownButtonFormField<String>(
      initialValue: fonts.contains(value) ? value : null,
      decoration: InputDecoration(labelText: label, isDense: true),
      hint: Text(value),
      items: [
        for (final entry in AppFontCatalog.byCategory.entries) ...[
          DropdownMenuItem<String>(
            enabled: false,
            value: '__group_${entry.key}',
            child: Text(entry.key, style: Theme.of(context).textTheme.labelSmall),
          ),
          for (final font in entry.value)
            DropdownMenuItem<String>(value: font, child: Text(font)),
        ],
      ],
      onChanged: (f) {
        if (f != null && !f.startsWith('__group_')) onChanged(f);
      },
    );
  }
}
