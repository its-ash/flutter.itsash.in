import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

class BrandSection extends StatelessWidget {
  const BrandSection({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final p = context.palette;
    final swatches = <(String, Color, Color)>[
      ('primary', cs.primary, cs.onPrimary),
      ('primaryContainer', cs.primaryContainer, cs.onPrimaryContainer),
      ('secondary', cs.secondary, cs.onSecondary),
      ('secondaryContainer', cs.secondaryContainer, cs.onSecondaryContainer),
      ('tertiary', cs.tertiary, cs.onTertiary),
      ('tertiaryContainer', cs.tertiaryContainer, cs.onTertiaryContainer),
      ('error', cs.error, cs.onError),
      ('errorContainer', cs.errorContainer, cs.onErrorContainer),
      ('surface', cs.surface, cs.onSurface),
      ('surfaceContainerLow', cs.surfaceContainerLow, cs.onSurface),
      ('surfaceContainer', cs.surfaceContainer, cs.onSurface),
      ('surfaceContainerHighest', cs.surfaceContainerHighest, cs.onSurfaceVariant),
      ('inverseSurface', cs.inverseSurface, cs.onInverseSurface),
      ('outline', cs.outline, cs.surface),
      ('success', p.success, p.onSuccess),
      ('warning', p.warning, p.onWarning),
      ('info', p.info, p.onInfo),
      ('rating', p.rating, Colors.black),
      ('sale', p.sale, Colors.white),
    ];
    final t = context.text;
    final scale = <(String, TextStyle?)>[
      ('displaySmall', t.displaySmall),
      ('headlineLarge', t.headlineLarge),
      ('headlineMedium', t.headlineMedium),
      ('headlineSmall', t.headlineSmall),
      ('titleLarge', t.titleLarge),
      ('titleMedium', t.titleMedium),
      ('titleSmall', t.titleSmall),
      ('bodyLarge', t.bodyLarge),
      ('bodyMedium', t.bodyMedium),
      ('bodySmall', t.bodySmall),
      ('labelLarge', t.labelLarge),
      ('labelMedium', t.labelMedium),
      ('labelSmall', t.labelSmall),
    ];
    final tk = context.tokens;
    final brand = UiThemeScope.maybeOf(context)?.brand ?? UiBrand.neutral;
    return SectionPage(
      children: [
        DemoBlock(
          'UiBrandPicker',
          subtitle: 'Current: ${brand.name} · ${brand.headingFont} / ${brand.bodyFont} · radius ×${brand.radiusScale}',
          child: const UiBrandPicker(padding: EdgeInsets.zero),
        ),
        const DemoBlock(
          'UiThemeModeSwitch',
          child: Wrap(
            spacing: UiSpace.lg,
            runSpacing: UiSpace.sm,
            children: [UiThemeModeSwitch(), UiThemeModeSwitch(showLabels: true)],
          ),
        ),
        DemoBlock(
          'Color scheme',
          subtitle: 'ColorScheme and UiColors (context.palette)',
          child: LayoutBuilder(
            builder: (context, c) {
              final cols = (c.maxWidth / 170).floor().clamp(2, 6);
              final w = (c.maxWidth - (cols - 1) * UiSpace.sm) / cols;
              return Wrap(
                spacing: UiSpace.sm,
                runSpacing: UiSpace.sm,
                children: [
                  for (final (name, bg, fg) in swatches)
                    Container(
                      width: w,
                      height: 72,
                      padding: const EdgeInsets.all(UiSpace.sm),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: tk.sm,
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.labelSmall?.copyWith(color: fg),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        DemoBlock(
          'Status tones',
          subtitle: 'context.tone(UiStatus)',
          child: WrapRow(
            children: [
              for (final s in UiStatus.values)
                Builder(builder: (context) {
                  final tone = context.tone(s);
                  return Chip(
                    avatar: Icon(s.icon, size: 18, color: tone.onContainer),
                    label: Text(s.name, style: TextStyle(color: tone.onContainer)),
                    backgroundColor: tone.container,
                  );
                }),
            ],
          ),
        ),
        DemoBlock(
          'Gradient',
          child: Container(
            height: 64,
            decoration: BoxDecoration(gradient: p.gradient, borderRadius: tk.lg),
          ),
        ),
        DemoBlock(
          'Type scale',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (name, style) in scale)
                Padding(
                  padding: const EdgeInsets.only(bottom: UiSpace.xs),
                  child: Text('$name · The quick brown fox', maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
                ),
            ],
          ),
        ),
        DemoBlock(
          'Radius tokens',
          child: WrapRow(
            children: [
              for (final (n, r) in [('xs', tk.xs), ('sm', tk.sm), ('md', tk.md), ('lg', tk.lg), ('xl', tk.xl), ('full', tk.full)])
                Container(
                  width: 72,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: r),
                  child: Text(n, style: t.labelLarge?.copyWith(color: cs.onPrimaryContainer)),
                ),
            ],
          ),
        ),
        DemoBlock(
          'Spacing (UiGap)',
          child: Row(
            children: [
              for (final g in const [UiGap.xs(), UiGap.sm(), UiGap.md(), UiGap.lg(), UiGap.xl(), UiGap.xxl()]) ...[
                Container(width: 8, height: 32, color: cs.primary),
                g,
              ],
              Container(width: 8, height: 32, color: cs.primary),
            ],
          ),
        ),
        DemoBlock(
          'Window size',
          child: UiResponsive.builder(
            builder: (context, size) => UiTag('Window: ${size.name}', status: UiStatus.info, icon: Icons.devices_rounded),
          ),
        ),
      ],
    );
  }
}
