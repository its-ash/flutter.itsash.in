import 'package:flutter/gestures.dart' show kLongPressTimeout;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/input/input.dart';

Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
  Size? size,
  bool scroll = true,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }
  await tester.pumpWidget(
    MaterialApp(
      theme: UiTheme.light(),
      darkTheme: UiTheme.dark(),
      themeMode: mode,
      home: Scaffold(
        body: scroll
            ? SingleChildScrollView(padding: const EdgeInsets.all(UiSpace.lg), child: child)
            : Padding(padding: const EdgeInsets.all(UiSpace.lg), child: child),
      ),
    ),
  );
}

const _fruits = [
  UiOption('apple', 'Apple', icon: Icons.circle),
  UiOption('banana', 'Banana', subtitle: 'Yellow'),
  UiOption('cherry', 'Cherry'),
  UiOption('mango', 'Mango', enabled: false),
];

/// Holds state for controlled widgets in tests.
class _Host<V> extends StatefulWidget {
  const _Host({required this.initial, required this.builder});

  final V initial;
  final Widget Function(V value, ValueChanged<V> set) builder;

  @override
  State<_Host<V>> createState() => _HostState<V>();
}

class _HostState<V> extends State<_Host<V>> {
  late V value = widget.initial;

  @override
  Widget build(BuildContext context) => widget.builder(value, (v) => setState(() => value = v));
}

Widget _gallery() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      UiTextField(
        label: 'A very long label that should ellipsize nicely on narrow screens',
        hint: 'Hint',
        helper: 'Helper text that is long enough to wrap onto a second line on narrow screens',
        maxLength: 20,
        isRequired: true,
        labelTrailing: TextButton(onPressed: () {}, child: const Text('Forgot?')),
        prefixIcon: Icons.mail_outline,
      ),
      const UiGap(UiSpace.lg),
      UiTextField(label: 'Disabled', initialValue: 'x', enabled: false),
      const UiGap(UiSpace.lg),
      UiTextField(label: 'With error', error: 'Something is wrong', size: UiSize.lg),
      const UiGap(UiSpace.lg),
      UiTextArea(label: 'Bio', maxLength: 200),
      const UiGap(UiSpace.lg),
      const UiPasswordField(showStrength: true),
      const UiGap(UiSpace.lg),
      UiSearchField(onChanged: (_) {}, onFilter: () {}, filterActive: true),
      const UiGap(UiSpace.lg),
      UiStepper(value: 3, onChanged: (_) {}),
      const UiGap(UiSpace.lg),
      UiNumberField(label: 'Guests', value: 2, min: 1, max: 9, onChanged: (_) {}),
      const UiGap(UiSpace.lg),
      const UiOtpField(error: 'Wrong code'),
      const UiGap(UiSpace.lg),
      UiPinPad(onCompleted: (_) {}, onBiometric: () {}, error: 'Try again'),
      const UiGap(UiSpace.lg),
      UiSelect<String>(label: 'Fruit', value: 'banana', options: _fruits, onChanged: (_) {}),
      const UiGap(UiSpace.lg),
      const UiSelect<String>(label: 'Disabled select', options: _fruits, onChanged: null),
      const UiGap(UiSpace.lg),
      UiMultiSelect<String>(
        label: 'Fruits',
        values: const ['apple', 'banana', 'cherry'],
        options: _fruits,
        maxChips: 2,
        onChanged: (_) {},
      ),
      const UiGap(UiSpace.lg),
      const UiAutocomplete<String>(label: 'City', options: ['Paris', 'Prague']),
      const UiGap(UiSpace.lg),
      UiDateField(label: 'Date', value: DateTime(2026, 3, 5), onChanged: (_) {}),
      const UiGap(UiSpace.lg),
      UiTimeField(label: 'Time', value: const TimeOfDay(hour: 9, minute: 5), onChanged: (_) {}),
      const UiGap(UiSpace.lg),
      UiDateRangeField(
        label: 'Trip',
        value: DateTimeRange(start: DateTime(2025, 12, 30), end: DateTime(2026, 1, 2)),
        onChanged: (_) {},
      ),
      const UiGap(UiSpace.lg),
      UiTagInput(
        label: 'Tags',
        tags: const ['design', 'a-very-long-tag-name-that-should-ellipsize-without-overflowing-anything'],
        maxTags: 5,
        onChanged: (_) {},
      ),
    ],
  );
}

void main() {
  group('UiValidators', () {
    test('required', () {
      final v = UiValidators.required<String>();
      expect(v(null), isNotNull);
      expect(v('  '), isNotNull);
      expect(v('a'), isNull);
      expect(UiValidators.required<List<int>>(message: 'Pick one')(const []), 'Pick one');
    });

    test('email, length, pattern, numeric', () {
      expect(UiValidators.email()('a@b.co'), isNull);
      expect(UiValidators.email()('nope'), isNotNull);
      expect(UiValidators.email()(''), isNull);
      expect(UiValidators.minLength(3)('ab'), isNotNull);
      expect(UiValidators.maxLength(3)('abcd'), isNotNull);
      expect(UiValidators.pattern(RegExp(r'\d+'))('12a'), isNotNull);
      expect(UiValidators.pattern(RegExp(r'\d+'))('123'), isNull);
      expect(UiValidators.numeric()('1.5'), isNull);
      expect(UiValidators.numeric(integer: true)('1.5'), isNotNull);
      expect(UiValidators.numeric(min: 2)('1'), isNotNull);
      expect(UiValidators.numeric(max: 2, message: 'Too big')('3'), 'Too big');
    });

    test('match and compose', () {
      var other = 'secret';
      final m = UiValidators.match(() => other);
      expect(m('secret'), isNull);
      other = 'changed';
      expect(m('secret'), isNotNull);
      final c = UiValidators.compose<String>([UiValidators.required(message: 'R'), UiValidators.minLength(5)]);
      expect(c(''), 'R');
      expect(c('abc'), contains('5'));
      expect(c('abcdef'), isNull);
    });
  });

  test('UiPasswordStrength.of', () {
    expect(UiPasswordStrength.of(''), isNull);
    expect(UiPasswordStrength.of('abc'), UiPasswordStrength.weak);
    expect(UiPasswordStrength.of('abcdefgh1'), UiPasswordStrength.fair);
    expect(UiPasswordStrength.of('Abcdefgh1'), UiPasswordStrength.good);
    expect(UiPasswordStrength.of('Abcdefgh1!xyz'), UiPasswordStrength.strong);
  });

  test('UiDateFormat', () {
    expect(UiDateFormat.date(DateTime(2026, 3, 5)), 'Mar 5, 2026');
    expect(
      UiDateFormat.range(DateTimeRange(start: DateTime(2026, 3, 5), end: DateTime(2026, 3, 9))),
      'Mar 5 – 9, 2026',
    );
    expect(
      UiDateFormat.range(DateTimeRange(start: DateTime(2026, 3, 30), end: DateTime(2026, 4, 2))),
      'Mar 30 – Apr 2, 2026',
    );
    expect(
      UiDateFormat.range(DateTimeRange(start: DateTime(2025, 12, 30), end: DateTime(2026, 1, 2))),
      'Dec 30, 2025 – Jan 2, 2026',
    );
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('all inputs render at 320 px in ${mode.name} mode', (tester) async {
      await _pump(tester, _gallery(), mode: mode, size: const Size(320, 4000));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Wrong code'), findsOneWidget);
      expect(find.text('Mar 5, 2026'), findsOneWidget);
      expect(find.text('Dec 30, 2025 – Jan 2, 2026'), findsOneWidget);
      expect(find.text('+1'), findsOneWidget);
    });
  }

  group('UiTextField', () {
    testWidgets('validator errors show inside a Form', (tester) async {
      final formKey = GlobalKey<FormState>();
      await _pump(
        tester,
        Form(
          key: formKey,
          child: UiTextField(
            label: 'Email',
            validator: UiValidators.compose([UiValidators.required(), UiValidators.email()]),
          ),
        ),
      );
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('This field is required'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'nope');
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'me@site.com');
      expect(formKey.currentState!.validate(), isTrue);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email address'), findsNothing);
    });

    testWidgets('counter, onChanged, controller sync and reset', (tester) async {
      final formKey = GlobalKey<FormState>();
      final controller = TextEditingController(text: 'hi');
      addTearDown(controller.dispose);
      String? changed;
      await _pump(
        tester,
        Form(
          key: formKey,
          child: UiTextField(label: 'Name', controller: controller, maxLength: 5, onChanged: (v) => changed = v),
        ),
      );
      expect(find.text('2 / 5'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'hello world');
      await tester.pump();
      expect(controller.text, 'hello');
      expect(changed, 'hello');
      expect(find.text('5 / 5'), findsOneWidget);

      controller.text = 'abc';
      await tester.pump();
      expect(find.text('3 / 5'), findsOneWidget);

      formKey.currentState!.reset();
      await tester.pump();
      expect(controller.text, 'hi');
    });

    testWidgets('UiTextArea is multi-line', (tester) async {
      await _pump(tester, UiTextArea(label: 'Bio', maxLength: 100));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLines, 6);
      expect(field.minLines, 3);
      expect(find.text('0 / 100'), findsOneWidget);
    });
  });

  testWidgets('UiPasswordField toggles visibility and shows strength', (tester) async {
    await _pump(tester, const UiPasswordField(showStrength: true), mode: ThemeMode.dark);
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(tester.widget<TextField>(find.byType(TextField)).obscureText, isFalse);
    expect(find.byTooltip('Hide password'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'abc');
    await tester.pumpAndSettle();
    expect(find.text('Weak'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Abcdefgh1!xyz');
    await tester.pumpAndSettle();
    expect(find.text('Strong'), findsOneWidget);
  });

  group('UiSearchField', () {
    testWidgets('debounces onChanged', (tester) async {
      final calls = <String>[];
      await _pump(tester, UiSearchField(onChanged: calls.add, debounce: const Duration(milliseconds: 300)));
      await tester.enterText(find.byType(TextField), 'a');
      await tester.pump(const Duration(milliseconds: 100));
      await tester.enterText(find.byType(TextField), 'ab');
      await tester.pump(const Duration(milliseconds: 200));
      expect(calls, isEmpty);
      await tester.pump(const Duration(milliseconds: 150));
      expect(calls, ['ab']);
    });

    testWidgets('clear button empties the field', (tester) async {
      final calls = <String>[];
      var cleared = false;
      var filtered = false;
      await _pump(
        tester,
        UiSearchField(onChanged: calls.add, onClear: () => cleared = true, onFilter: () => filtered = true),
      );
      expect(find.byTooltip('Clear'), findsNothing);
      await tester.enterText(find.byType(TextField), 'shoes');
      await tester.pumpAndSettle();
      expect(find.byTooltip('Clear'), findsOneWidget);
      await tester.tap(find.byTooltip('Clear'));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, isEmpty);
      expect(calls.last, '');
      expect(cleared, isTrue);
      expect(find.byTooltip('Clear'), findsNothing);
      await tester.tap(find.byTooltip('Filters'));
      expect(filtered, isTrue);
    });
  });

  group('UiStepper', () {
    testWidgets('respects bounds', (tester) async {
      var value = 0;
      await _pump(
        tester,
        _Host<int>(
          initial: 9,
          builder: (v, set) => UiStepper(
            value: v,
            min: 8,
            max: 10,
            onChanged: (n) {
              value = n;
              set(n);
            },
          ),
        ),
      );
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(value, 10);
      expect(find.text('10'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add_rounded));
      await tester.pumpAndSettle();
      expect(value, 10);
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.tap(find.byIcon(Icons.remove_rounded));
      await tester.pumpAndSettle();
      expect(value, 8);
    });

    testWidgets('long press repeats', (tester) async {
      var value = 0;
      await _pump(
        tester,
        _Host<int>(
          initial: 0,
          builder: (v, set) => UiStepper(
            value: v,
            max: 100,
            onChanged: (n) {
              value = n;
              set(n);
            },
          ),
        ),
      );
      final gesture = await tester.startGesture(tester.getCenter(find.byIcon(Icons.add_rounded)));
      await tester.pump(kLongPressTimeout + const Duration(milliseconds: 20));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 120));
      }
      await gesture.up();
      final reached = value;
      expect(reached, greaterThan(3));
      await tester.pump(const Duration(seconds: 1));
      expect(value, reached);
    });

    testWidgets('doubles and disabled', (tester) async {
      double? value;
      await _pump(
        tester,
        Column(
          children: [
            UiStepper(value: 1.5, step: 0.5, onChanged: (v) => value = v),
            const UiStepper(value: 2, onChanged: null),
          ],
        ),
      );
      expect(find.text('1.5'), findsOneWidget);
      await tester.tap(find.byIcon(Icons.add_rounded).first);
      expect(value, 2.0);
      final disabled = tester.widgetList<IconButton>(find.byType(IconButton)).skip(2);
      expect(disabled.every((b) => b.onPressed == null), isTrue);
    });

    testWidgets('UiNumberField accepts typed values and clamps', (tester) async {
      var value = 2;
      await _pump(
        tester,
        _Host<int>(
          initial: 2,
          builder: (v, set) => UiNumberField(
            label: 'Guests',
            value: v,
            min: 1,
            max: 10,
            onChanged: (n) {
              value = n;
              set(n);
            },
          ),
        ),
      );
      expect(find.text('Guests'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '7');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(value, 7);
      await tester.enterText(find.byType(TextField), '99');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(value, 10);
    });
  });

  group('UiOtpField', () {
    testWidgets('auto-advances and completes', (tester) async {
      String? done;
      final changes = <String>[];
      await _pump(tester, UiOtpField(length: 4, onCompleted: (v) => done = v, onChanged: changes.add));
      Finder box(String d) => find.byWidgetPredicate((w) => w is Text && w.data == d);
      await tester.enterText(find.byType(TextField), '1');
      await tester.pump();
      expect(box('1'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '12');
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();
      expect(done, isNull);
      // Backspace.
      await tester.enterText(find.byType(TextField), '12');
      await tester.pump();
      expect(box('3'), findsNothing);
      expect(box('2'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1234');
      await tester.pump();
      expect(done, '1234');
      expect(changes.last, '1234');
    });

    testWidgets('paste fills all boxes and drops non-digits', (tester) async {
      String? done;
      await _pump(tester, UiOtpField(onCompleted: (v) => done = v, obscure: false), mode: ThemeMode.dark);
      await tester.enterText(find.byType(TextField), 'Code: 482-913 thanks');
      await tester.pump();
      expect(done, '482913');
      for (final d in ['4', '8', '2', '9', '1', '3']) {
        expect(find.text(d), findsOneWidget);
      }
    });
  });

  testWidgets('UiPinPad enters, deletes and completes', (tester) async {
    final changes = <String>[];
    String? done;
    var bio = false;
    await _pump(
      tester,
      UiPinPad(onChanged: changes.add, onCompleted: (v) => done = v, onBiometric: () => bio = true),
      size: const Size(320, 700),
    );
    await tester.tap(find.text('1'));
    await tester.tap(find.text('2'));
    expect(changes.last, '12');
    await tester.pump();
    await tester.tap(find.bySemanticsLabel('Delete'));
    expect(changes.last, '1');
    for (final d in ['5', '6', '7']) {
      await tester.tap(find.text(d));
    }
    expect(done, '1567');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(find.bySemanticsLabel('Use biometrics'));
    expect(bio, isTrue);
    await tester.tap(find.text('9'));
    expect(changes.last, '9');
  });

  group('UiSelect', () {
    testWidgets('opens a sheet on compact screens and returns the value', (tester) async {
      String? picked;
      await _pump(
        tester,
        _Host<String?>(
          initial: null,
          builder: (v, set) => UiSelect<String>(
            label: 'Fruit',
            hint: 'Pick a fruit',
            value: v,
            options: _fruits,
            searchable: true,
            onChanged: (n) {
              picked = n;
              set(n);
            },
          ),
        ),
        size: const Size(400, 800),
      );
      await tester.tap(find.text('Pick a fruit'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsOneWidget);
      expect(find.text('Yellow'), findsOneWidget);

      await tester.enterText(find.widgetWithText(TextField, 'Search'), 'che');
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsNothing);
      await tester.tap(find.text('Cherry'));
      await tester.pumpAndSettle();
      expect(picked, 'cherry');
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.text('Cherry'), findsOneWidget);
    });

    testWidgets('opens an anchored menu on wide screens', (tester) async {
      String? picked;
      await _pump(
        tester,
        UiSelect<String>(label: 'Fruit', value: 'apple', options: _fruits, onChanged: (n) => picked = n),
        size: const Size(1000, 800),
        mode: ThemeMode.dark,
      );
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(find.byType(BottomSheet), findsNothing);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      // Disabled option does nothing.
      await tester.tap(find.text('Mango'));
      await tester.pumpAndSettle();
      expect(picked, isNull);
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(picked, 'banana');
    });

    testWidgets('validator works in a Form', (tester) async {
      final formKey = GlobalKey<FormState>();
      await _pump(
        tester,
        Form(
          key: formKey,
          child: UiSelect<String>(
            label: 'Fruit',
            options: _fruits,
            onChanged: (_) {},
            validator: UiValidators.required(message: 'Pick a fruit first'),
          ),
        ),
      );
      expect(formKey.currentState!.validate(), isFalse);
      await tester.pumpAndSettle();
      expect(find.text('Pick a fruit first'), findsOneWidget);
    });

    testWidgets('UiMultiSelect picks several values and removes chips', (tester) async {
      List<String>? picked;
      await _pump(
        tester,
        _Host<List<String>>(
          initial: const [],
          builder: (v, set) => UiMultiSelect<String>(
            label: 'Fruits',
            hint: 'Pick fruits',
            values: v,
            options: _fruits,
            onChanged: (n) {
              picked = n;
              set(n);
            },
          ),
        ),
        size: const Size(400, 800),
      );
      await tester.tap(find.text('Pick fruits'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cherry'));
      await tester.tap(find.text('Apple'));
      await tester.pump();
      await tester.tap(find.text('Done (2)'));
      await tester.pumpAndSettle();
      expect(picked, ['apple', 'cherry']);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Cherry'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel('Remove Apple'));
      await tester.pumpAndSettle();
      expect(picked, ['cherry']);
      expect(find.text('Apple'), findsNothing);
    });
  });

  group('UiAutocomplete', () {
    testWidgets('filters a sync list and selects', (tester) async {
      String? picked;
      await _pump(
        tester,
        UiAutocomplete<String>(
          label: 'Fruit',
          options: const ['Apple', 'Banana', 'Cherry', 'Mango'],
          onSelected: (v) => picked = v,
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'an');
      await tester.pumpAndSettle();
      expect(find.text('Banana'), findsOneWidget);
      expect(find.text('Mango'), findsOneWidget);
      expect(find.text('Apple'), findsNothing);

      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No matches'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'ban');
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(picked, 'Banana');
      expect(tester.widget<TextField>(find.byType(TextField)).controller!.text, 'Banana');
      expect(find.text('No matches'), findsNothing);
    });

    testWidgets('async search shows a loading row', (tester) async {
      final queries = <String>[];
      await _pump(
        tester,
        UiAutocomplete<String>(
          label: 'City',
          debounce: const Duration(milliseconds: 200),
          search: (q) async {
            queries.add(q);
            await Future<void>.delayed(const Duration(milliseconds: 100));
            return ['Paris', 'Parma'].where((c) => c.toLowerCase().startsWith(q.toLowerCase())).toList();
          },
        ),
        mode: ThemeMode.dark,
      );
      await tester.showKeyboard(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'par');
      await tester.pump();
      expect(find.text('Searching…'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(queries, ['par']);
      expect(find.text('Paris'), findsOneWidget);
      expect(find.text('Parma'), findsOneWidget);
      expect(find.text('Searching…'), findsNothing);
    });
  });

  group('Date and time fields', () {
    testWidgets('UiDateField picks and clears', (tester) async {
      DateTime? picked = DateTime(2000);
      await _pump(
        tester,
        _Host<DateTime?>(
          initial: null,
          builder: (v, set) => UiDateField(
            label: 'Date',
            value: v,
            onChanged: (d) {
              picked = d;
              set(d);
            },
          ),
        ),
      );
      await tester.tap(find.text('Select date'));
      await tester.pumpAndSettle();
      expect(find.byType(DatePickerDialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      final now = DateTime.now();
      expect(picked, DateTime(now.year, now.month, now.day));
      expect(find.text(UiDateFormat.date(now)), findsOneWidget);

      await tester.tap(find.byTooltip('Clear'));
      await tester.pumpAndSettle();
      expect(picked, isNull);
      expect(find.text('Select date'), findsOneWidget);
    });

    testWidgets('UiTimeField opens the time picker', (tester) async {
      TimeOfDay? picked;
      await _pump(tester, UiTimeField(label: 'Time', value: null, onChanged: (t) => picked = t));
      await tester.tap(find.text('Select time'));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(picked, isNotNull);
    });

    testWidgets('UiDateRangeField opens the range picker', (tester) async {
      await _pump(tester, UiDateRangeField(label: 'Trip', value: null, onChanged: (_) {}));
      await tester.tap(find.text('Select dates'));
      await tester.pumpAndSettle();
      expect(find.byType(DateRangePickerDialog), findsOneWidget);
    });
  });

  group('UiTagInput', () {
    testWidgets('adds with enter and comma, removes, respects max', (tester) async {
      List<String> tags = const [];
      await _pump(
        tester,
        _Host<List<String>>(
          initial: const [],
          builder: (v, set) => UiTagInput(
            label: 'Tags',
            tags: v,
            maxTags: 3,
            suggestions: const ['rust', 'swift'],
            onChanged: (n) {
              tags = n;
              set(n);
            },
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'flutter');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      expect(tags, ['flutter']);
      expect(find.text('1 / 3'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'dart, Flutter,');
      await tester.pumpAndSettle();
      expect(tags, ['flutter', 'dart']);

      await tester.tap(find.bySemanticsLabel('Remove flutter'));
      await tester.pumpAndSettle();
      expect(tags, ['dart']);

      await tester.showKeyboard(find.byType(TextField));
      await tester.pumpAndSettle();
      await tester.tap(find.text('rust'));
      await tester.pumpAndSettle();
      expect(tags, ['dart', 'rust']);

      await tester.enterText(find.byType(TextField), 'go,kotlin,');
      await tester.pumpAndSettle();
      expect(tags, ['dart', 'rust', 'go']);
      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('backspace on empty input removes the last tag', (tester) async {
      List<String> tags = const ['a', 'b'];
      await _pump(
        tester,
        _Host<List<String>>(
          initial: const ['a', 'b'],
          builder: (v, set) => UiTagInput(
            tags: v,
            onChanged: (n) {
              tags = n;
              set(n);
            },
          ),
        ),
      );
      await tester.showKeyboard(find.byType(TextField));
      await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
      await tester.pumpAndSettle();
      expect(tags, ['a']);
    });
  });

  testWidgets('UiFieldLabel shows required mark, trailing and error', (tester) async {
    await _pump(
      tester,
      UiFieldLabel(
        label: 'Password',
        isRequired: true,
        trailing: const Text('Forgot?'),
        helper: 'Helper',
        error: 'Bad',
        counter: '1 / 2',
        child: const SizedBox(height: 40),
      ),
    );
    expect(find.text('Password *'), findsOneWidget);
    expect(find.text('Forgot?'), findsOneWidget);
    expect(find.text('Bad'), findsOneWidget);
    expect(find.text('Helper'), findsNothing);
    expect(find.text('1 / 2'), findsOneWidget);
  });
}
