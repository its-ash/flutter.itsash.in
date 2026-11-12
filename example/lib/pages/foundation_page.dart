import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

class FoundationPage extends StatelessWidget {
  const FoundationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final swatches = <String, Color>{
      'background': c.background,
      'surface': c.surface,
      'surfaceMuted': c.surfaceMuted,
      'surfaceRaised': c.surfaceRaised,
      'surfaceInverse': c.surfaceInverse,
      'border': c.border,
      'borderStrong': c.borderStrong,
      'text': c.text,
      'textMuted': c.textMuted,
      'textSubtle': c.textSubtle,
      'accent': c.accent,
      'accentSoft': c.accentSoft,
    };
    final styles = <String, TextStyle?>{
      'displaySmall': t.displaySmall,
      'headlineMedium': t.headlineMedium,
      'headlineSmall': t.headlineSmall,
      'titleLarge': t.titleLarge,
      'titleMedium': t.titleMedium,
      'bodyLarge': t.bodyLarge,
      'bodyMedium': t.bodyMedium,
      'bodySmall': t.bodySmall,
      'labelLarge': t.labelLarge,
      'labelSmall': t.labelSmall,
    };
    return GalleryPage(
      children: [
        Demo(
          'Breakpoint',
          subtitle: 'Resize the window to see it change',
          child: UiRow(
            children: [
              UiStatusPill(context.breakpoint.name, status: UiStatus.accent, dot: true),
              Flexible(
                child: Text(
                  '${context.screenSize.width.round()} × ${context.screenSize.height.round()} · '
                  '${context.isDark ? 'dark' : 'light'} mode',
                  style: t.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const Demo(
          'Appearance section',
          subtitle: 'UiAppearanceSection: Light / Dark / Auto and text size, saved',
          child: UiAppearanceSection(),
        ),
        Demo(
          'Palette',
          child: UiResponsiveGrid(
            minItemWidth: 130,
            children: [for (final e in swatches.entries) _Swatch(e.key, e.value)],
          ),
        ),
        Demo(
          'Status tones',
          child: UiResponsiveGrid(
            minItemWidth: 130,
            children: [
              for (final s in UiStatus.values)
                UiSurface(
                  tone: s,
                  padding: const EdgeInsets.all(UiSpace.md),
                  child: UiRow(
                    children: [
                      Icon(s.icon, size: 18, color: c.tone(s).onSoft),
                      Flexible(
                        child: Text(s.name, style: t.labelLarge!.copyWith(color: c.tone(s).onSoft)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Demo(
          'Chart colors',
          child: UiRow(
            gap: UiSpace.xs,
            children: [
              for (var i = 0; i < c.chart.length; i++)
                Expanded(
                  child: Container(
                    height: 32,
                    decoration: BoxDecoration(color: c.chartColor(i), borderRadius: UiRadius.all(UiRadius.xs)),
                  ),
                ),
            ],
          ),
        ),
        Demo(
          'Typography',
          child: UiColumn(
            gap: UiSpace.sm,
            children: [
              for (final e in styles.entries) Text(e.key, style: e.value, maxLines: 1, overflow: TextOverflow.ellipsis),
              Text('A1B2-C3D4 · 0123456789', style: UiTypography.mono(fontSize: 14, color: c.textMuted)),
            ],
          ),
        ),
        Demo(
          'Spacing',
          child: UiColumn(
            gap: UiSpace.xs,
            children: [
              for (final s in const [UiSpace.xs, UiSpace.sm, UiSpace.md, UiSpace.lg, UiSpace.xl, UiSpace.xxl])
                UiRow(
                  children: [
                    SizedBox(width: 40, child: Text('${s.round()}', style: t.labelSmall)),
                    Container(width: s * 4, height: 10, color: c.accentSoft),
                  ],
                ),
            ],
          ),
        ),
        Demo(
          'Radius and shadows',
          child: DemoWrap(
            children: [
              for (final (name, r, shadow) in [
                ('sm', UiRadius.sm, context.shadowSm),
                ('md', UiRadius.md, context.shadowMd),
                ('lg', UiRadius.lg, context.shadowLg),
                ('xl', UiRadius.xl, context.shadowMd),
              ])
                UiSurface(
                  width: 96,
                  height: 72,
                  radius: r,
                  shadow: shadow,
                  child: Center(child: Text(name, style: t.labelLarge)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch(this.name, this.color);

  final String name;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return UiSurface(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(color: color, borderRadius: UiRadius.top(UiRadius.lg)),
          ),
          Padding(
            padding: const EdgeInsets.all(UiSpace.sm),
            child: Text(name, style: context.text.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ],
      ),
    );
  }
}
