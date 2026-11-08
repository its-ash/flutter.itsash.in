import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

class ButtonsSection extends StatefulWidget {
  const ButtonsSection({super.key});

  @override
  State<ButtonsSection> createState() => _ButtonsSectionState();
}

class _ButtonsSectionState extends State<ButtonsSection> {
  bool _busy = false;
  int _selected = 0;

  Future<void> _load() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    void tap() => toast(context, 'Pressed');
    return SectionPage(
      children: [
        DemoBlock(
          'UiButton variants',
          child: WrapRow(
            children: [
              for (final v in UiButtonVariant.values) UiButton(v.name, variant: v, onPressed: tap),
              const UiButton('Disabled', onPressed: null),
            ],
          ),
        ),
        DemoBlock(
          'Named constructors',
          child: WrapRow(
            children: [
              UiButton.secondary('Secondary', onPressed: tap),
              UiButton.tonal('Tonal', onPressed: tap),
              UiButton.outline('Outline', onPressed: tap),
              UiButton.ghost('Ghost', onPressed: tap),
              UiButton.danger('Delete', icon: Icons.delete_outline_rounded, onPressed: tap),
            ],
          ),
        ),
        DemoBlock(
          'Sizes, icons, loading',
          child: WrapRow(
            children: [
              for (final s in UiSize.values) UiButton('Size ${s.name}', size: s, icon: Icons.bolt_rounded, onPressed: tap),
              UiButton('Next', trailingIcon: Icons.arrow_forward_rounded, onPressed: tap),
              UiButton(_busy ? 'Saving' : 'Tap to load', loading: _busy, icon: Icons.cloud_upload_rounded, onPressed: _load),
            ],
          ),
        ),
        DemoBlock(
          'Expanded',
          child: UiButton('Checkout', icon: Icons.lock_rounded, expand: true, onPressed: tap),
        ),
        DemoBlock(
          'UiIconButton',
          child: WrapRow(
            children: [
              for (final v in UiIconButtonVariant.values)
                UiIconButton(Icons.favorite_border_rounded, variant: v, tooltip: v.name, onPressed: tap),
              UiIconButton(Icons.shopping_bag_outlined, badge: '3', variant: UiIconButtonVariant.tonal, onPressed: tap),
              UiIconButton(Icons.notifications_none_rounded, badge: '', variant: UiIconButtonVariant.outline, onPressed: tap),
              for (final s in UiSize.values) UiIconButton(Icons.add_rounded, size: s, variant: UiIconButtonVariant.filled, onPressed: tap),
              UiIconButton(Icons.star_rounded, color: context.palette.rating, onPressed: tap),
            ],
          ),
        ),
        DemoBlock(
          'UiCard variants',
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth >= 600 ? (c.maxWidth - UiSpace.sm * 2) / 3 : (c.maxWidth - UiSpace.sm) / 2;
              return WrapRow(
                children: [
                  for (final (i, v) in UiCardVariant.values.indexed)
                    UiCard(
                      width: w,
                      variant: v,
                      selected: _selected == i,
                      onTap: () => setState(() => _selected = i),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(v.name, style: context.text.titleSmall),
                          Text(_selected == i ? 'Selected' : 'Tap to select', style: context.text.bodySmall),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        DemoBlock(
          'UiImage',
          subtitle: 'Network, aspect ratio, radius, error fallback',
          child: Row(
            children: [
              Expanded(child: UiImage(pic('mountain', 800, 600), aspectRatio: 4 / 3, radius: context.tokens.md)),
              const UiGap.sm(),
              Expanded(child: UiImage(pic('city', 600, 600), aspectRatio: 1, radius: context.tokens.xl)),
              const UiGap.sm(),
              Expanded(child: UiImage(null, aspectRatio: 1, radius: context.tokens.md, placeholderIcon: Icons.person_rounded)),
              const UiGap.sm(),
              Expanded(child: UiImage('assets/missing.png', aspectRatio: 1, radius: context.tokens.md)),
            ],
          ),
        ),
        DemoBlock(
          'UiTag',
          child: WrapRow(
            children: [
              for (final s in UiStatus.values) UiTag(s.name, status: s),
              for (final s in UiStatus.values) UiTag(s.name, status: s, solid: true, icon: s.icon),
              for (final z in UiSize.values) UiTag('Size ${z.name}', size: z, status: UiStatus.info),
              UiTag('Custom', color: Colors.purple, icon: Icons.auto_awesome_rounded),
            ],
          ),
        ),
        DemoBlock(
          'UiAvatar',
          child: WrapRow(
            children: [
              UiAvatar(name: 'Ana Lee', imageUrl: pic('ana', 200, 200), status: UiStatus.success),
              const UiAvatar(name: 'Bo Chen', status: UiStatus.warning),
              const UiAvatar(icon: Icons.pets_rounded),
              UiAvatar(name: 'Cy Ray', imageUrl: pic('cy', 200, 200), ring: true),
              for (final s in const [28.0, 40.0, 56.0, 72.0]) UiAvatar(name: 'Dee Kay', size: s, onTap: tap),
            ],
          ),
        ),
        DemoBlock(
          'UiRatingStars',
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              UiRatingStars(4.5, count: 128, showValue: true),
              UiGap.sm(),
              UiRatingStars(3.2, size: 24),
              UiGap.sm(),
              UiRatingStars(7, max: 10, showValue: true),
            ],
          ),
        ),
      ],
    );
  }
}
