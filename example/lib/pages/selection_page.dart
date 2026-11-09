import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

const _plans = [
  UiChoice('free', 'Free', description: 'For trying things out', icon: Icons.rocket_launch_outlined, trailing: r'$0'),
  UiChoice('pro', 'Pro', description: 'For individuals', icon: Icons.bolt_rounded, trailing: r'$12/mo'),
  UiChoice('team', 'Team', description: 'For growing teams', icon: Icons.groups_outlined, trailing: r'$49/mo'),
];

const _goals = [
  UiChoice('fit', 'Get fit', icon: Icons.fitness_center_rounded),
  UiChoice('sleep', 'Sleep better', icon: Icons.bedtime_outlined),
  UiChoice('focus', 'Focus', icon: Icons.center_focus_strong_outlined),
  UiChoice('calm', 'Stay calm', icon: Icons.self_improvement_rounded, enabled: false),
];

const _topics = [
  UiChoice('design', 'Design'),
  UiChoice('dev', 'Development', icon: Icons.code_rounded),
  UiChoice('ai', 'AI'),
  UiChoice('ops', 'DevOps'),
  UiChoice('data', 'Data'),
];

class SelectionPage extends StatefulWidget {
  const SelectionPage({super.key});

  @override
  State<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends State<SelectionPage> {
  bool _agree = false;
  bool? _all;
  Set<String> _toppings = {'cheese'};
  bool _wifi = true;
  bool _bluetooth = false;
  String _radio = 'b';
  String _size = 'm';
  bool _notify = true;
  bool _remember = false;
  ThemeMode _mode = ThemeMode.system;
  String _plan = 'pro';
  Set<String> _picked = {'fit'};
  final _chips = <String>{'design'};
  final _removable = ['flutter', 'dart', 'rust'];
  Set<String> _filters = {'dev'};
  String _choice = 'ai';
  double _volume = 0.4;
  RangeValues _price = const RangeValues(50, 300);
  double _stars = 3.5;
  Color? _color;

  @override
  Widget build(BuildContext context) {
    return GalleryPage(
      children: [
        Demo(
          'Checkboxes',
          child: UiColumn(
            children: [
              UiCheckbox(_agree, label: 'I agree to the terms', onChanged: (v) => setState(() => _agree = v!)),
              UiCheckbox(
                _all,
                label: 'Tristate',
                description: 'false → true → null',
                tristate: true,
                onChanged: (v) => setState(() => _all = v),
              ),
              const UiCheckbox(true, label: 'Disabled'),
              UiCheckboxGroup<String>(
                values: _toppings,
                direction: Axis.horizontal,
                options: const [UiChoice('cheese', 'Cheese'), UiChoice('olives', 'Olives'), UiChoice('basil', 'Basil')],
                onChanged: (s) => setState(() => _toppings = s),
              ),
            ],
          ),
        ),
        Demo(
          'Switches and radios',
          child: UiColumn(
            children: [
              UiSwitch(_wifi, label: 'Wi-Fi', onChanged: (v) => setState(() => _wifi = v)),
              UiSwitch(
                _bluetooth,
                label: 'Bluetooth',
                description: 'Needs Wi-Fi on',
                onChanged: _wifi ? (v) => setState(() => _bluetooth = v) : null,
              ),
              UiRow(
                children: [
                  for (final v in ['a', 'b', 'c'])
                    UiRadio(
                      v,
                      groupValue: _radio,
                      label: v.toUpperCase(),
                      onChanged: (x) => setState(() => _radio = x),
                    ),
                ],
              ),
              UiRadioGroup<String>(
                value: _size,
                direction: Axis.horizontal,
                options: const [UiChoice('s', 'Small'), UiChoice('m', 'Medium'), UiChoice('l', 'Large')],
                onChanged: (v) => setState(() => _size = v),
              ),
            ],
          ),
        ),
        Demo(
          'Settings tiles',
          child: UiListGroup(
            children: [
              UiSwitchTile(
                'Notifications',
                subtitle: 'Push and email',
                value: _notify,
                icon: Icons.notifications_outlined,
                onChanged: (v) => setState(() => _notify = v),
              ),
              UiCheckboxTile(
                'Remember me',
                value: _remember,
                icon: Icons.key_outlined,
                status: UiStatus.success,
                onChanged: (v) => setState(() => _remember = v!),
              ),
              for (final m in ThemeMode.values)
                UiRadioTile(m.name, value: m, groupValue: _mode, onChanged: (v) => setState(() => _mode = v)),
            ],
          ),
        ),
        Demo(
          'Choice cards',
          child: UiColumn(
            gap: UiSpace.lg,
            children: [
              UiChoiceCards<String>(options: _plans, value: _plan, onChanged: (v) => setState(() => _plan = v)),
              UiChoiceCards<String>.multi(
                options: _goals,
                values: _picked,
                columns: 2,
                onChanged: (s) => setState(() => _picked = s),
              ),
            ],
          ),
        ),
        Demo(
          'Chips',
          child: UiColumn(
            children: [
              UiChipGroup(
                children: [
                  for (final t in ['design', 'motion', 'color'])
                    UiChip(
                      t,
                      selected: _chips.contains(t),
                      onTap: () => setState(() => _chips.contains(t) ? _chips.remove(t) : _chips.add(t)),
                    ),
                  for (final t in _removable)
                    UiChip(t, variant: UiChipVariant.soft, onDeleted: () => setState(() => _removable.remove(t))),
                  const UiChip('Static', status: UiStatus.info, variant: UiChipVariant.filled),
                  const UiChip('Disabled', enabled: false),
                ],
              ),
              UiFilterChips<String>(
                options: _topics,
                values: _filters,
                scrollable: true,
                onChanged: (s) => setState(() => _filters = s),
              ),
              UiChoiceChips<String>(
                options: _topics,
                value: _choice,
                size: UiSize.sm,
                onChanged: (v) => setState(() => _choice = v),
              ),
            ],
          ),
        ),
        Demo(
          'Sliders and rating',
          child: UiColumn(
            gap: UiSpace.lg,
            children: [
              UiSlider(
                value: _volume,
                label: 'Volume',
                format: (v) => '${(v * 100).round()}%',
                onChanged: (v) => setState(() => _volume = v),
              ),
              UiRangeSlider(
                values: _price,
                max: 500,
                divisions: 50,
                label: 'Price',
                format: (v) => '\$${v.round()}',
                onChanged: (r) => setState(() => _price = r),
              ),
              UiRow(
                children: [
                  UiRating(value: _stars, allowHalf: true, onChanged: (v) => setState(() => _stars = v)),
                  Text('$_stars', style: context.text.labelLarge),
                ],
              ),
              const UiRating(value: 4, size: UiSize.sm),
            ],
          ),
        ),
        Demo(
          'Color picker',
          child: UiColumn(
            children: [
              UiColorPicker(
                value: _color,
                colors: context.colors.chart,
                size: UiSize.lg,
                onChanged: (c) => setState(() => _color = c),
              ),
              AnimatedContainer(
                duration: context.motion(UiMotion.normal),
                height: 24,
                decoration: BoxDecoration(
                  color: _color ?? context.colors.surfaceMuted,
                  borderRadius: UiRadius.all(UiRadius.full),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
