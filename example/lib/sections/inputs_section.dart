import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

enum Plan { free, pro, team }

class InputsSection extends StatefulWidget {
  const InputsSection({super.key});

  @override
  State<InputsSection> createState() => _InputsSectionState();
}

class _InputsSectionState extends State<InputsSection> {
  final _form = GlobalKey<FormState>();
  String? _size = 'M';
  bool _terms = false;
  bool _push = true;
  Plan _plan = Plan.pro;
  Plan _chipPlan = Plan.free;
  List<String> _goals = ['Strength'];
  String _gender = 'All';
  List<String> _brands = ['Nike'];
  String _range = 'Week';
  double _volume = 40;
  RangeValues _price = const RangeValues(80, 420);
  int _qty = 2;
  DateTime? _dob;
  TimeOfDay? _time = const TimeOfDay(hour: 9, minute: 30);
  DateTimeRange? _stay;
  List<String> _tags = ['Flutter', 'Dart'];
  Color _color = Colors.indigo;
  double _stars = 3.5;
  bool _liked = true;
  bool _saved = false;
  String _otp = '';

  static const _colors = [Colors.black, Colors.indigo, Colors.teal, Colors.orange, Colors.pink, Colors.white];

  @override
  Widget build(BuildContext context) => SectionPage(
        children: [
          DemoBlock(
            'UiTextField',
            child: Form(
              key: _form,
              child: UiFormSection(
                title: 'Profile',
                subtitle: 'UiFormSection with validated fields',
                trailing: UiButton.ghost('Validate', size: UiSize.sm, onPressed: () => _form.currentState?.validate()),
                children: [
                  const UiTextField('Name', hint: 'Ana Lee', isRequired: true, prefixIcon: Icons.person_outline_rounded),
                  UiTextField.email(),
                  UiTextField.phone(),
                  UiTextField.number(label: 'Weight', decimal: true),
                  UiTextField.name(),
                  UiTextField.multiline('Bio'),
                  const UiTextField('With helper', helper: 'Shown below the field', maxLength: 40),
                  const UiTextField('With error', error: 'This value is taken'),
                  const UiTextField('Disabled', initialValue: 'Read only', enabled: false),
                ],
              ),
            ),
          ),
          const DemoBlock(
            'UiPasswordField',
            child: UiPasswordField(showStrength: true, minLength: 8, newPassword: true),
          ),
          DemoBlock(
            'UiFieldLabel',
            child: UiFieldLabel(
              'Notes',
              isRequired: true,
              trailing: Text('0/200', style: context.text.labelSmall),
              child: const TextField(decoration: InputDecoration(hintText: 'Any custom field')),
            ),
          ),
          DemoBlock(
            'UiSearchField',
            child: UiSearchField(
              hint: 'Search products',
              filterCount: 2,
              onChanged: (_) {},
              onFilterTap: () => toast(context, 'Filters'),
            ),
          ),
          DemoBlock(
            'UiOtpField',
            subtitle: _otp.isEmpty ? 'Type 6 digits' : 'Code: $_otp',
            child: UiOtpField(
              onCompleted: (v) => setState(() => _otp = v),
              error: _otp.isNotEmpty && _otp != '123456' ? 'Wrong code, try 123456' : null,
            ),
          ),
          DemoBlock(
            'UiDropdown',
            child: UiDropdown<String>(
              label: 'Size',
              items: const ['XS', 'S', 'M', 'L', 'XL'],
              value: _size,
              prefixIcon: Icons.straighten_rounded,
              onChanged: (v) => setState(() => _size = v),
            ),
          ),
          DemoBlock(
            'UiCheckboxTile and UiSwitchTile',
            child: Column(
              children: [
                UiCheckboxTile(
                  'Accept terms',
                  subtitle: 'You agree to the terms of use',
                  value: _terms,
                  onChanged: (v) => setState(() => _terms = v),
                ),
                const UiGap.sm(),
                UiSwitchTile(
                  'Push notifications',
                  subtitle: 'Orders and offers',
                  leading: Icons.notifications_rounded,
                  value: _push,
                  onChanged: (v) => setState(() => _push = v),
                ),
              ],
            ),
          ),
          DemoBlock(
            'UiRadioGroup',
            child: Column(
              children: [
                UiRadioGroup<Plan>(
                  label: 'Plan (list)',
                  options: Plan.values,
                  value: _plan,
                  labelBuilder: (p) => p.name.toUpperCase(),
                  subtitleBuilder: (p) => switch (p) {
                    Plan.free => 'For trying out',
                    Plan.pro => 'For individuals',
                    Plan.team => 'For teams of 5+',
                  },
                  iconBuilder: (p) => switch (p) {
                    Plan.free => Icons.emoji_people_rounded,
                    Plan.pro => Icons.workspace_premium_rounded,
                    Plan.team => Icons.groups_rounded,
                  },
                  onChanged: (v) => setState(() => _plan = v),
                ),
                const UiGap.md(),
                UiRadioGroup<Plan>(
                  label: 'Plan (chips)',
                  layout: UiRadioLayout.chips,
                  options: Plan.values,
                  value: _chipPlan,
                  labelBuilder: (p) => p.name,
                  onChanged: (v) => setState(() => _chipPlan = v),
                ),
              ],
            ),
          ),
          DemoBlock(
            'UiCheckboxGroup',
            child: UiCheckboxGroup<String>(
              label: 'Goals (max 2)',
              options: const ['Strength', 'Cardio', 'Mobility', 'Weight loss'],
              values: _goals,
              max: 2,
              onChanged: (v) => setState(() => _goals = v),
            ),
          ),
          DemoBlock(
            'UiChoiceChips and UiFilterChips',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UiChoiceChips<String>(
                  options: const ['All', 'Men', 'Women', 'Kids', 'Sport', 'Outdoor'],
                  value: _gender,
                  scrollable: true,
                  onChanged: (v) => setState(() => _gender = v),
                ),
                const UiGap.md(),
                UiFilterChips<String>(
                  options: const ['Nike', 'Adidas', 'Puma', 'New Balance', 'Asics'],
                  selected: _brands,
                  onChanged: (v) => setState(() => _brands = v),
                ),
              ],
            ),
          ),
          DemoBlock(
            'UiSegmented',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final s in UiSize.values) ...[
                  UiSegmented<String>(
                    options: const ['Day', 'Week', 'Month'],
                    value: _range,
                    size: s,
                    onChanged: (v) => setState(() => _range = v),
                  ),
                  const UiGap.sm(),
                ],
              ],
            ),
          ),
          DemoBlock(
            'UiSlider and UiRangeSlider',
            child: Column(
              children: [
                UiSlider(
                  label: 'Volume',
                  value: _volume,
                  format: (v) => '${v.round()}%',
                  onChanged: (v) => setState(() => _volume = v),
                ),
                const UiGap.md(),
                UiRangeSlider(
                  label: 'Price',
                  values: _price,
                  max: 1000,
                  format: (v) => '\$${v.round()}',
                  onChanged: (v) => setState(() => _price = v),
                ),
              ],
            ),
          ),
          DemoBlock(
            'UiNumberStepper',
            child: WrapRow(
              children: [
                for (final s in UiSize.values)
                  UiNumberStepper(value: _qty, min: 1, max: 10, size: s, onChanged: (v) => setState(() => _qty = v)),
              ],
            ),
          ),
          DemoBlock(
            'UiDateField, UiTimeField, UiDateRangeField',
            child: Column(
              children: [
                UiDateField(label: 'Date of birth', value: _dob, clearable: true, onChanged: (v) => setState(() => _dob = v)),
                const UiGap.md(),
                UiTimeField(label: 'Start', value: _time, onChanged: (v) => setState(() => _time = v)),
                const UiGap.md(),
                UiDateRangeField(
                  label: 'Check-in – Check-out',
                  value: _stay,
                  firstDate: now,
                  lastDate: now.add(const Duration(days: 365)),
                  onChanged: (v) => setState(() => _stay = v),
                ),
              ],
            ),
          ),
          DemoBlock(
            'UiTagInput',
            child: UiTagInput(label: 'Skills', tags: _tags, maxTags: 5, onChanged: (v) => setState(() => _tags = v)),
          ),
          DemoBlock(
            'UiColorSwatchPicker',
            child: UiColorSwatchPicker(
              colors: _colors,
              value: _color,
              labels: const ['Black', 'Indigo', 'Teal', 'Orange', 'Pink', 'White'],
              onChanged: (v) => setState(() => _color = v),
            ),
          ),
          DemoBlock(
            'UiRatingInput',
            subtitle: 'Value: $_stars',
            child: UiRatingInput(value: _stars, allowHalf: true, onChanged: (v) => setState(() => _stars = v)),
          ),
          DemoBlock(
            'UiToggleButton',
            child: WrapRow(
              children: [
                UiToggleButton(value: _liked, onChanged: (v) => setState(() => _liked = v)),
                UiToggleButton.bookmark(value: _saved, onChanged: (v) => setState(() => _saved = v)),
                UiToggleButton(
                  value: _push,
                  icon: Icons.notifications_none_rounded,
                  selectedIcon: Icons.notifications_active_rounded,
                  filled: false,
                  onChanged: (v) => setState(() => _push = v),
                ),
              ],
            ),
          ),
          DemoBlock(
            'UiSocialButton',
            child: Column(
              children: [
                for (final p in UiSocialProvider.values) ...[
                  UiSocialButton(p, onPressed: () => toast(context, p.name)),
                  const UiGap.sm(),
                ],
                const UiSocialButton(UiSocialProvider.google, loading: true, onPressed: null),
              ],
            ),
          ),
        ],
      );
}
