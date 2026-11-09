import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

const _cities = ['Amsterdam', 'Berlin', 'Lisbon', 'London', 'Madrid', 'Paris', 'Prague', 'Rome', 'Tokyo', 'Vienna'];

const _countries = [
  UiOption('es', 'Spain', subtitle: 'Europe'),
  UiOption('jp', 'Japan', subtitle: 'Asia'),
  UiOption('ng', 'Nigeria', subtitle: 'Africa'),
  UiOption('br', 'Brazil', subtitle: 'South America'),
  UiOption('ca', 'Canada', subtitle: 'North America', enabled: false),
];

class InputPage extends StatefulWidget {
  const InputPage({super.key});

  @override
  State<InputPage> createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  final _form = GlobalKey<FormState>();
  final _password = TextEditingController();
  String _search = '';
  int _qty = 1;
  double _guests = 2;
  String? _otp;
  String _pin = '';
  String? _pinError;
  String? _country;
  List<String> _langs = ['es'];
  String? _city;
  DateTime? _date;
  TimeOfDay? _time;
  DateTimeRange? _range;
  List<String> _skills = ['Flutter'];

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_form.currentState!.validate()) {
      context.showToast('Form is valid', status: UiStatus.success);
    } else {
      context.showToast('Fix the errors', status: UiStatus.danger);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hits = _cities.where((c) => c.toLowerCase().contains(_search.toLowerCase())).toList();
    return GalleryPage(
      children: [
        Demo(
          'Form',
          subtitle: 'Validators run on submit',
          child: Form(
            key: _form,
            child: UiColumn(
              gap: UiSpace.lg,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                UiTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  prefixIcon: Icons.mail_outline_rounded,
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                  validator: UiValidators.compose([UiValidators.required(), UiValidators.email()]),
                ),
                UiPasswordField(
                  controller: _password,
                  showStrength: true,
                  isRequired: true,
                  validator: UiValidators.compose([UiValidators.required(), UiValidators.minLength(8)]),
                ),
                UiPasswordField(
                  label: 'Confirm password',
                  validator: UiValidators.match(() => _password.text, message: 'Passwords do not match'),
                ),
                UiTextArea(label: 'Bio', hint: 'A few words about you', maxLength: 200),
                UiTextField(
                  label: 'Age',
                  keyboardType: TextInputType.number,
                  helper: '18 to 120',
                  validator: UiValidators.numeric(min: 18, max: 120, integer: true),
                ),
                UiTextField(label: 'Disabled', initialValue: 'Read only', enabled: false),
                UiButton('Submit', expand: true, onPressed: _submit),
              ],
            ),
          ),
        ),
        Demo(
          'Search',
          subtitle: '${hits.length} cities',
          child: UiColumn(
            children: [
              UiSearchField(
                hint: 'Search cities',
                debounce: const Duration(milliseconds: 250),
                onChanged: (q) => setState(() => _search = q),
                onClear: () => setState(() => _search = ''),
                onFilter: () => context.showToast('Filters'),
              ),
              Wrap(
                spacing: UiSpace.sm,
                runSpacing: UiSpace.xs,
                children: [for (final c in hits) UiHighlightText(c, _search)],
              ),
            ],
          ),
        ),
        Demo(
          'Numbers',
          child: UiColumn(
            gap: UiSpace.lg,
            children: [
              UiRow(
                children: [
                  UiStepper(value: _qty, min: 1, max: 10, onChanged: (v) => setState(() => _qty = v)),
                  Text('Quantity: $_qty', style: context.text.bodyMedium),
                ],
              ),
              UiNumberField<double>(
                label: 'Guests',
                value: _guests,
                min: 1,
                max: 12,
                step: 0.5,
                onChanged: (v) => setState(() => _guests = v),
              ),
            ],
          ),
        ),
        Demo(
          'Codes',
          child: UiColumn(
            gap: UiSpace.lg,
            children: [
              UiOtpField(
                label: 'Verification code',
                helper: 'Try 123456',
                error: _otp == null || _otp == '123456' ? null : 'Wrong code',
                onCompleted: (v) {
                  setState(() => _otp = v);
                  if (v == '123456') context.showToast('Verified', status: UiStatus.success);
                },
              ),
              Center(
                child: SizedBox(
                  width: 300,
                  child: UiPinPad(
                    error: _pinError,
                    onChanged: (v) => setState(() {
                      _pin = v;
                      _pinError = null;
                    }),
                    onCompleted: (v) => setState(() => _pinError = v == '1234' ? null : 'Wrong PIN (try 1234)'),
                    onBiometric: () => context.showToast('Biometric unlock'),
                  ),
                ),
              ),
              Text('PIN so far: ${'•' * _pin.length}', style: context.text.bodySmall),
            ],
          ),
        ),
        Demo(
          'Pickers',
          child: UiColumn(
            gap: UiSpace.lg,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiSelect<String>(
                label: 'Country',
                value: _country,
                options: _countries,
                searchable: true,
                onChanged: (v) => setState(() => _country = v),
              ),
              UiMultiSelect<String>(
                label: 'Languages',
                values: _langs,
                options: const [
                  UiOption('es', 'Spanish'),
                  UiOption('en', 'English'),
                  UiOption('ja', 'Japanese'),
                  UiOption('fr', 'French'),
                  UiOption('de', 'German'),
                ],
                onChanged: (v) => setState(() => _langs = v),
              ),
              UiAutocomplete<String>(
                label: 'City',
                helper: _city == null ? 'Async search with a fake delay' : 'Picked $_city',
                search: (q) async {
                  await Future<void>.delayed(const Duration(milliseconds: 400));
                  return _cities.where((c) => c.toLowerCase().contains(q.toLowerCase())).toList();
                },
                onSelected: (c) => setState(() => _city = c),
              ),
              UiDateField(label: 'Birthday', value: _date, onChanged: (d) => setState(() => _date = d)),
              UiTimeField(label: 'Reminder', value: _time, onChanged: (t) => setState(() => _time = t)),
              UiDateRangeField(label: 'Trip', value: _range, onChanged: (r) => setState(() => _range = r)),
              UiTagInput(
                label: 'Skills',
                tags: _skills,
                maxTags: 6,
                suggestions: const ['Dart', 'Rust', 'Figma', 'SQL'],
                onChanged: (t) => setState(() => _skills = t),
              ),
              UiFieldLabel(
                label: 'Custom control',
                helper: 'UiFieldLabel frames any widget',
                child: UiSlider(value: _guests / 12, onChanged: (v) => setState(() => _guests = (v * 12).clamp(1, 12))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
