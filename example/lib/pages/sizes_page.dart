import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

/// Every sized component at sm / md / lg with its numbers, plus the radius,
/// spacing and type scales. The live version of DESIGN.md.
class SizesPage extends StatefulWidget {
  const SizesPage({super.key});

  @override
  State<SizesPage> createState() => _SizesPageState();
}

class _SizesPageState extends State<SizesPage> {
  int _qty = 1;
  int? _tile = 8;
  String _chip = 'md';
  final _field = TextEditingController();

  @override
  void dispose() {
    _field.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    return GalleryPage(
      children: [
        Demo(
          'Buttons',
          subtitle: 'Pills · sm 40 / md 48 / lg 56 high · label 13 / 15 / 17 · icon 16 / 20 / 22',
          child: _BySize(
            (s) => Wrap(
              spacing: UiSpace.sm,
              runSpacing: UiSpace.sm,
              children: [
                UiButton('Primary', size: s, onPressed: () {}),
                UiButton('Secondary', size: s, variant: UiButtonVariant.secondary, onPressed: () {}),
                UiButton('Soft', size: s, variant: UiButtonVariant.soft, onPressed: () {}),
                UiButton('Outline', size: s, variant: UiButtonVariant.outline, onPressed: () {}),
                UiButton(
                  'Delete',
                  size: s,
                  icon: Icons.delete_outline_rounded,
                  variant: UiButtonVariant.soft,
                  status: UiStatus.danger,
                  onPressed: () {},
                ),
                UiButton('Disabled', size: s),
              ],
            ),
          ),
        ),
        Demo(
          'Icon buttons',
          subtitle: 'Circles · sm 40 / md 48 / lg 56 · ghost, outline, secondary, soft, primary',
          child: _BySize(
            (s) => Wrap(
              spacing: UiSpace.sm,
              runSpacing: UiSpace.sm,
              children: [
                UiIconButton(Icons.arrow_back_rounded, tooltip: 'Ghost', size: s, onPressed: () {}),
                UiIconButton(
                  Icons.search_rounded,
                  tooltip: 'Outline',
                  size: s,
                  variant: UiButtonVariant.outline,
                  onPressed: () {},
                ),
                UiIconButton(
                  Icons.tune_rounded,
                  tooltip: 'Secondary',
                  size: s,
                  variant: UiButtonVariant.secondary,
                  onPressed: () {},
                ),
                UiIconButton(
                  Icons.favorite_border_rounded,
                  tooltip: 'Soft',
                  size: s,
                  variant: UiButtonVariant.soft,
                  onPressed: () {},
                ),
                UiIconButton(
                  Icons.add_rounded,
                  tooltip: 'Primary',
                  size: s,
                  variant: UiButtonVariant.primary,
                  onPressed: () {},
                ),
                UiIconButton(
                  Icons.delete_outline_rounded,
                  tooltip: 'Danger',
                  size: s,
                  variant: UiButtonVariant.soft,
                  status: UiStatus.danger,
                  onPressed: () {},
                ),
                UiIconButton(Icons.notifications_none_rounded, tooltip: 'Badge', size: s, badge: 3, onPressed: () {}),
              ],
            ),
          ),
        ),
        Demo(
          'Chips',
          subtitle: 'Pills · sm 32 / md 40 / lg 48 · soft fill, solid Primary when selected',
          child: _BySize(
            (s) => UiChoiceChips<String>(
              scrollable: true,
              size: s,
              options: const [
                UiChoice('sm', 'Small'),
                UiChoice('md', 'Medium'),
                UiChoice('lg', 'Large'),
                UiChoice('x', 'Disabled', enabled: false),
              ],
              value: _chip,
              onChanged: (v) => setState(() => _chip = v),
            ),
          ),
        ),
        Demo(
          'Segmented control',
          subtitle: 'Overlay track, Primary segment · sm 32 / md 40 / lg 48',
          child: _BySize(
            (s) => UiSegmentedControl<String>(
              const [UiSegment('d', label: 'Day'), UiSegment('w', label: 'Week'), UiSegment('m', label: 'Month')],
              value: 'w',
              size: s,
              onChanged: (_) {},
            ),
          ),
        ),
        Demo(
          'Fields',
          subtitle: 'Outline only, page-colored fill, radius 14 · sm 40 / md 48 / lg 56 · 1.5 px Primary on focus',
          child: _BySize(
            (s) => UiTextField(controller: s == UiSize.md ? _field : null, hint: 'Field ${s.name}', size: s),
          ),
        ),
        Demo('Search field', child: const UiSearchField(hint: 'Search products')),
        Demo(
          'Stepper',
          subtitle: 'Quantity pill · sm 40 / md 48 / lg 56',
          child: _BySize(
            (s) => Align(
              alignment: Alignment.centerLeft,
              child: UiStepper<int>(value: _qty, min: 1, max: 9, size: s, onChanged: (v) => setState(() => _qty = v)),
            ),
          ),
        ),
        Demo(
          'Option tiles',
          subtitle: 'UiOptionTiles · radius 14 · sm 40 / md 48 / lg 56 square',
          child: _BySize(
            (s) => UiOptionTiles<int>(
              size: s,
              options: [for (var i = 7; i <= 12; i++) UiChoice(i, '$i', enabled: i != 10)],
              value: _tile,
              onChanged: (v) => setState(() => _tile = v),
            ),
          ),
        ),
        Demo(
          'Color swatches',
          subtitle: 'UiColorPicker · sm 26 / md 32 / lg 40 + 2 px ring',
          child: _BySize(
            (s) => UiColorPicker(
              value: context.colors.accent,
              colors: [context.colors.accent, context.colors.warning, context.colors.chart[1], context.colors.danger],
              size: s,
              spacing: UiSpace.sm,
              onChanged: (_) {},
            ),
          ),
        ),
        Demo(
          'Rating, avatars, badges',
          child: _BySize(
            (s) => Wrap(
              spacing: UiSpace.lg,
              runSpacing: UiSpace.sm,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                UiRating(value: 4.5, allowHalf: true, size: s),
                UiAvatar(name: 'Ana Ruiz', size: s),
                const UiTag('New', status: UiStatus.accent),
                UiStatusPill('Active', status: UiStatus.success, size: s, dot: true),
              ],
            ),
          ),
        ),
        Demo(
          'Corner radius',
          subtitle: 'UiRadius',
          child: Wrap(
            spacing: UiSpace.md,
            runSpacing: UiSpace.md,
            children: [
              for (final (name, r) in [
                ('xs 6', UiRadius.xs),
                ('sm 10', UiRadius.sm),
                ('md 14', UiRadius.md),
                ('lg 24', UiRadius.lg),
                ('xl 32', UiRadius.xl),
                ('full', UiRadius.full),
              ])
                _Box(label: name, radius: r),
            ],
          ),
        ),
        Demo(
          'Spacing',
          subtitle: 'UiSpace · 4 pt grid · page padding 20',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (name, v) in [
                ('xxs', UiSpace.xxs),
                ('xs', UiSpace.xs),
                ('sm', UiSpace.sm),
                ('md', UiSpace.md),
                ('lg', UiSpace.lg),
                ('xl', UiSpace.xl),
                ('xxl', UiSpace.xxl),
                ('xxxl', UiSpace.xxxl),
              ])
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    children: [
                      SizedBox(width: 72, child: Text('$name ${v.round()}', style: t.bodySmall)),
                      Container(
                        width: v * 3,
                        height: 12,
                        decoration: BoxDecoration(
                          color: context.colors.accent,
                          borderRadius: UiRadius.all(UiRadius.full),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Demo(
          'Type ramp',
          subtitle: 'Outfit · 400 body / 500 titles and labels / 600 headings',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (name, style) in [
                ('displayLarge', t.displayLarge),
                ('displayMedium', t.displayMedium),
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
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: UiSpace.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name · ${style!.fontSize!.round()} / ${(style.fontSize! * style.height!).round()} · '
                        'w${style.fontWeight!.value}',
                        style: t.labelSmall?.copyWith(color: context.colors.textSubtle),
                      ),
                      Text('Step into style', style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
            ],
          ),
        ),
        Demo(
          'Shadows',
          child: Wrap(
            spacing: UiSpace.lg,
            runSpacing: UiSpace.lg,
            children: [
              for (final (name, s) in [('sm', context.shadowSm), ('md', context.shadowMd), ('lg', context.shadowLg)])
                Container(
                  width: 96,
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceRaised,
                    borderRadius: UiRadius.all(UiRadius.lg),
                    boxShadow: s,
                  ),
                  child: Text(name, style: t.labelLarge),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Shows [builder] once per [UiSize], labelled.
class _BySize extends StatelessWidget {
  const _BySize(this.builder);

  final Widget Function(UiSize size) builder;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final s in UiSize.values) ...[
          Text(s.name, style: context.text.labelSmall?.copyWith(color: context.colors.textSubtle)),
          const SizedBox(height: UiSpace.xs),
          builder(s),
          const SizedBox(height: UiSpace.lg),
        ],
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.label, required this.radius});

  final String label;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: c.accentSoft,
            border: Border.all(color: c.accent),
            borderRadius: UiRadius.all(radius),
          ),
        ),
        const SizedBox(height: UiSpace.xs),
        Text(label, style: context.text.bodySmall),
      ],
    );
  }
}
