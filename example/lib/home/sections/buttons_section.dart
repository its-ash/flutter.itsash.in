import 'package:flutter/material.dart';

import 'package:theme/theme.dart';
import '../showcase_tile.dart';

class ButtonsSection extends StatefulWidget {
  const ButtonsSection({super.key});

  @override
  State<ButtonsSection> createState() => _ButtonsSectionState();
}

class _ButtonsSectionState extends State<ButtonsSection> {
  Set<String> _segment = {'day'};
  final _toggleSelected = [true, false, false];

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      children: [
        ShowcaseTile(
          title: 'ThemeButton',
          description: 'elevated | filled | outlined | text',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ThemeButton(label: 'Elevated', onPressed: () {}, variant: ThemeButtonVariant.elevated),
              ThemeButton(label: 'Filled', onPressed: () {}, variant: ThemeButtonVariant.filled, icon: Icons.arrow_forward),
              ThemeButton(label: 'Outlined', onPressed: () {}, variant: ThemeButtonVariant.outlined),
              ThemeButton(label: 'Text', onPressed: () {}, variant: ThemeButtonVariant.text),
              const ThemeButton(label: 'Disabled', onPressed: null),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeButton — status colors',
          description: 'success | error | warning | info, across all variants',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ThemeButton(
                label: 'Success',
                onPressed: () {},
                icon: Icons.check_circle_outline,
                status: ThemeButtonStatus.success,
              ),
              ThemeButton(
                label: 'Error',
                onPressed: () {},
                icon: Icons.error_outline,
                status: ThemeButtonStatus.error,
              ),
              ThemeButton(
                label: 'Warning',
                onPressed: () {},
                icon: Icons.warning_amber_outlined,
                status: ThemeButtonStatus.warning,
              ),
              ThemeButton(
                label: 'Info',
                onPressed: () {},
                icon: Icons.info_outline,
                status: ThemeButtonStatus.info,
              ),
              ThemeButton(
                label: 'Success',
                onPressed: () {},
                variant: ThemeButtonVariant.outlined,
                status: ThemeButtonStatus.success,
              ),
              ThemeButton(
                label: 'Error',
                onPressed: () {},
                variant: ThemeButtonVariant.outlined,
                status: ThemeButtonStatus.error,
              ),
              ThemeButton(
                label: 'Warning',
                onPressed: () {},
                variant: ThemeButtonVariant.outlined,
                status: ThemeButtonStatus.warning,
              ),
              ThemeButton(
                label: 'Info',
                onPressed: () {},
                variant: ThemeButtonVariant.outlined,
                status: ThemeButtonStatus.info,
              ),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeIconButton',
          child: Row(
            children: [
              ThemeIconButton(icon: Icons.favorite_border, onPressed: () {}, tooltip: 'Favorite'),
              const SizedBox(width: 8),
              ThemeIconButton(icon: Icons.share_outlined, onPressed: () {}, tooltip: 'Share'),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeTapButton',
          description: 'Bare tap surface with ripple, for custom-shaped tappables',
          child: Builder(
            builder: (context) {
              final scheme = Theme.of(context).colorScheme;
              return ThemeTapButton(
                onTap: () {},
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                decoration: BoxDecoration(
                  color: scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  child: Text('Tap me', style: TextStyle(color: scheme.onPrimaryContainer)),
                ),
              );
            },
          ),
        ),
        ShowcaseTile(
          title: 'ThemeFab',
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ThemeFab(icon: Icons.add, onPressed: () {}),
              ThemeFab(icon: Icons.edit_outlined, label: 'Edit', onPressed: () {}),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeSegmentedButton<T>',
          child: ThemeSegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'day', label: Text('Day')),
              ButtonSegment(value: 'week', label: Text('Week')),
              ButtonSegment(value: 'month', label: Text('Month')),
            ],
            selected: _segment,
            onSelectionChanged: (s) => setState(() => _segment = s),
          ),
        ),
        ShowcaseTile(
          title: 'ThemeToggleButtons',
          child: ThemeToggleButtons(
            isSelected: _toggleSelected,
            onPressed: (i) => setState(() {
              for (var j = 0; j < _toggleSelected.length; j++) {
                _toggleSelected[j] = j == i;
              }
            }),
            children: const [
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.format_align_left)),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.format_align_center)),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Icon(Icons.format_align_right)),
            ],
          ),
        ),
      ],
    );
  }
}
