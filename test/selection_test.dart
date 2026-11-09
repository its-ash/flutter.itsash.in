import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/selection/selection.dart';

Future<void> _pump(WidgetTester tester, Widget child, {ThemeMode mode = ThemeMode.light, double width = 400}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UiTheme.light(),
      darkTheme: UiTheme.dark(),
      themeMode: mode,
      home: Scaffold(
        body: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: width,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

const _fruits = [
  UiChoice('apple', 'Apple', description: 'Crisp and sweet', icon: Icons.apple),
  UiChoice('banana', 'Banana', icon: Icons.eco_rounded, trailing: r'$2'),
  UiChoice('cherry', 'Cherry', enabled: false),
];

void main() {
  group('UiCheckbox', () {
    testWidgets('toggles via label tap', (tester) async {
      var value = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) =>
              UiCheckbox(value, label: 'Accept', description: 'Terms', onChanged: (v) => setState(() => value = v!)),
        ),
      );
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      await tester.tap(find.text('Terms'));
      await tester.pumpAndSettle();
      expect(value, isFalse);
    });

    testWidgets('null onChanged disables', (tester) async {
      await _pump(tester, const UiCheckbox(false, label: 'Off'));
      await tester.tap(find.text('Off'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final semantics = tester.getSemantics(find.byType(UiCheckbox));
      expect(semantics.flagsCollection.isEnabled, isNot(true));
    });

    testWidgets('tristate cycles false -> true -> null -> false', (tester) async {
      bool? value = false;
      final seen = <bool?>[];
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => UiCheckbox(
            value,
            tristate: true,
            label: 'All',
            onChanged: (v) => setState(() {
              value = v;
              seen.add(v);
            }),
          ),
        ),
      );
      for (var i = 0; i < 3; i++) {
        await tester.tap(find.text('All'));
        await tester.pumpAndSettle();
      }
      expect(seen, [true, null, false]);
    });

    testWidgets('without label has 40px tap target', (tester) async {
      await _pump(tester, Row(children: [UiCheckbox(true, onChanged: (_) {})]));
      final size = tester.getSize(find.byType(UiCheckbox));
      expect(size.width, greaterThanOrEqualTo(40));
      expect(size.height, greaterThanOrEqualTo(40));
    });

    testWidgets('labelled checkbox inside an unbounded Row does not throw', (tester) async {
      await _pump(
        tester,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [UiCheckbox(true, label: 'In a row', onChanged: (_) {})],
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('UiSwitch', () {
    testWidgets('toggles and disables', (tester) async {
      var value = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              UiSwitch(value, label: 'Wi-Fi', onChanged: (v) => setState(() => value = v)),
              const UiSwitch(true, label: 'Locked'),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Wi-Fi'));
      await tester.pumpAndSettle();
      expect(value, isTrue);
      await tester.tap(find.text('Locked'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  group('UiRadio', () {
    testWidgets('group selects tapped option and skips disabled', (tester) async {
      String? value;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) =>
              UiRadioGroup<String>(value: value, options: _fruits, onChanged: (v) => setState(() => value = v)),
        ),
      );
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(value, 'banana');
      await tester.tap(find.text('Cherry'));
      await tester.pumpAndSettle();
      expect(value, 'banana');
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(value, 'apple');
    });

    testWidgets('horizontal group and null onChanged', (tester) async {
      await _pump(
        tester,
        const UiRadioGroup<String>(value: 'apple', options: _fruits, direction: Axis.horizontal),
        width: 320,
      );
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('single radio reports its value', (tester) async {
      int? picked;
      await _pump(tester, UiRadio<int>(3, groupValue: 1, label: 'Three', onChanged: (v) => picked = v));
      await tester.tap(find.text('Three'));
      expect(picked, 3);
    });
  });

  testWidgets('UiCheckboxGroup adds and removes values', (tester) async {
    var values = <String>{'apple'};
    await _pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) =>
            UiCheckboxGroup<String>(values: values, options: _fruits, onChanged: (s) => setState(() => values = s)),
      ),
    );
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();
    expect(values, {'apple', 'banana'});
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    expect(values, {'banana'});
    await tester.tap(find.text('Cherry'));
    await tester.pumpAndSettle();
    expect(values, {'banana'});
  });

  group('tiles', () {
    testWidgets('switch, checkbox and radio tiles toggle', (tester) async {
      var on = false;
      bool? checked = false;
      var mode = 'light';
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => Column(
            children: [
              UiSwitchTile(
                'Notifications',
                subtitle: 'Push and email',
                icon: Icons.notifications_rounded,
                value: on,
                onChanged: (v) => setState(() => on = v),
              ),
              UiCheckboxTile(
                'Remember me',
                icon: Icons.lock_rounded,
                value: checked,
                onChanged: (v) => setState(() => checked = v),
              ),
              UiRadioTile<String>('Dark', value: 'dark', groupValue: mode, onChanged: (v) => setState(() => mode = v)),
              const UiSwitchTile('Disabled', value: true, icon: Icons.block, status: UiStatus.danger),
            ],
          ),
        ),
        width: 320,
      );
      await tester.tap(find.text('Notifications'));
      await tester.tap(find.text('Remember me'));
      await tester.tap(find.text('Dark'));
      await tester.tap(find.text('Disabled'));
      await tester.pumpAndSettle();
      expect(on, isTrue);
      expect(checked, isTrue);
      expect(mode, 'dark');
      expect(tester.takeException(), isNull);
    });
  });

  group('UiChoiceCards', () {
    testWidgets('single choice', (tester) async {
      String? value;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => UiChoiceCards<String>(
            options: _fruits,
            value: value,
            columns: 2,
            onChanged: (v) => setState(() => value = v),
          ),
        ),
        width: 320,
      );
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(value, 'apple');
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(value, 'banana');
      await tester.tap(find.text('Cherry'));
      await tester.pumpAndSettle();
      expect(value, 'banana');
      expect(find.byIcon(Icons.check_rounded), findsWidgets);
    });

    testWidgets('multi choice', (tester) async {
      var values = <String>{};
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => UiChoiceCards<String>.multi(
            options: _fruits,
            values: values,
            onChanged: (s) => setState(() => values = s),
          ),
        ),
      );
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Banana'));
      await tester.pumpAndSettle();
      expect(values, {'apple', 'banana'});
      await tester.tap(find.text('Apple'));
      await tester.pumpAndSettle();
      expect(values, {'banana'});
    });

    testWidgets('columns shrink to fit narrow widths', (tester) async {
      await _pump(tester, const UiChoiceCards<String>(options: _fruits, value: 'apple', columns: 4), width: 200);
      expect(tester.takeException(), isNull);
      // One card per row at 200 px: the cards stack vertically.
      final a = tester.getTopLeft(find.text('Apple'));
      final b = tester.getTopLeft(find.text('Banana'));
      expect(b.dy, greaterThan(a.dy));
    });
  });

  group('UiChip', () {
    testWidgets('tap selects and delete removes', (tester) async {
      var selected = false;
      var deleted = false;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => UiChipGroup(
            children: [
              UiChip('Design', selected: selected, onTap: () => setState(() => selected = !selected)),
              UiChip('flutter', icon: Icons.tag, onDeleted: () => deleted = true),
              const UiChip('Done', status: UiStatus.success, variant: UiChipVariant.soft),
              const UiChip('Error', status: UiStatus.danger, variant: UiChipVariant.filled, size: UiSize.sm),
              const UiChip('Off', enabled: false, size: UiSize.lg),
            ],
          ),
        ),
      );
      await tester.tap(find.text('Design'));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();
      expect(deleted, isTrue);
    });

    testWidgets('disabled chip ignores taps', (tester) async {
      var taps = 0;
      await _pump(tester, UiChip('Off', enabled: false, onTap: () => taps++));
      await tester.tap(find.text('Off'));
      expect(taps, 0);
    });

    testWidgets('long label ellipsizes', (tester) async {
      await _pump(tester, UiChip('A very long chip label ' * 10, onTap: () {}), width: 200);
      expect(tester.takeException(), isNull);
    });

    testWidgets('scrollable group with 20 chips at 200 px does not overflow', (tester) async {
      await _pump(
        tester,
        UiChipGroup(scrollable: true, children: [for (var i = 0; i < 20; i++) UiChip('Chip number $i', onTap: () {})]),
        width: 200,
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(UiChip), findsNWidgets(20));
      await tester.drag(find.byType(SingleChildScrollView).last, const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('UiFilterChips toggles values', (tester) async {
    var values = <String>{};
    await _pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) =>
            UiFilterChips<String>(options: _fruits, values: values, onChanged: (s) => setState(() => values = s)),
      ),
    );
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cherry'));
    await tester.pumpAndSettle();
    expect(values, {'apple', 'banana'});
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();
    expect(values, {'banana'});
  });

  testWidgets('UiChoiceChips picks one value, scrollable', (tester) async {
    String? value = 'apple';
    await _pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) => UiChoiceChips<String>(
          options: _fruits,
          value: value,
          scrollable: true,
          onChanged: (v) => setState(() => value = v),
        ),
      ),
      width: 200,
    );
    await tester.tap(find.text('Banana'));
    await tester.pumpAndSettle();
    expect(value, 'banana');
    expect(tester.takeException(), isNull);
  });

  group('sliders', () {
    testWidgets('UiSlider drag changes value and shows it', (tester) async {
      var value = 0.0;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) =>
              UiSlider(value: value, max: 100, label: 'Volume', onChanged: (v) => setState(() => value = v)),
        ),
      );
      expect(find.text('Volume'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
      await tester.drag(find.byType(Slider), const Offset(200, 0));
      await tester.pumpAndSettle();
      expect(value, greaterThan(0));
    });

    testWidgets('UiSlider with null onChanged is disabled', (tester) async {
      await _pump(tester, UiSlider(value: 0.4, label: 'Locked', format: (v) => '${(v * 100).round()}%'));
      expect(find.text('40%'), findsOneWidget);
      await tester.drag(find.byType(Slider), const Offset(100, 0));
      await tester.pumpAndSettle();
      expect(find.text('40%'), findsOneWidget);
    });

    testWidgets('UiRangeSlider drag changes the end', (tester) async {
      var values = const RangeValues(20, 40);
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => UiRangeSlider(
            values: values,
            max: 100,
            divisions: 10,
            label: 'Price',
            onChanged: (r) => setState(() => values = r),
          ),
        ),
      );
      expect(find.text('20 – 40'), findsOneWidget);
      final rect = tester.getRect(find.byType(RangeSlider));
      await tester.tapAt(Offset(rect.left + rect.width * 0.9, rect.center.dy));
      await tester.pumpAndSettle();
      expect(values.end, greaterThan(40));
    });
  });

  group('UiRating', () {
    testWidgets('tap sets rating', (tester) async {
      var value = 0.0;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => UiRating(value: value, onChanged: (v) => setState(() => value = v)),
        ),
      );
      final icons = find.byIcon(Icons.star_rounded);
      // Each star is drawn twice (empty + filled overlay).
      await tester.tap(icons.at(2 * 2));
      await tester.pumpAndSettle();
      expect(value, 3);
    });

    testWidgets('half steps and drag', (tester) async {
      var value = 0.0;
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) =>
              UiRating(value: value, allowHalf: true, onChanged: (v) => setState(() => value = v)),
        ),
      );
      final first = tester.getRect(find.byIcon(Icons.star_rounded).first);
      await tester.tapAt(Offset(first.left + first.width * 0.25, first.center.dy));
      await tester.pumpAndSettle();
      expect(value, 0.5);
      await tester.dragFrom(first.center, const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(value, 5);
    });

    testWidgets('read-only when onChanged is null', (tester) async {
      await _pump(tester, const UiRating(value: 3.5, size: UiSize.sm));
      await tester.tap(find.byIcon(Icons.star_rounded).first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('UiColorPicker selects a swatch', (tester) async {
    const palette = [Color(0xFF4F46E5), Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFFFFFFF)];
    Color? value;
    await _pump(
      tester,
      StatefulBuilder(
        builder: (context, setState) => UiColorPicker(
          value: value,
          colors: palette,
          labels: const ['Indigo', 'Green', 'Amber', 'White'],
          onChanged: (c) => setState(() => value = c),
        ),
      ),
      width: 200,
    );
    await tester.tap(find.bySemanticsLabel('Green'));
    await tester.pumpAndSettle();
    expect(value, palette[1]);
    await tester.tap(find.bySemanticsLabel('White'));
    await tester.pumpAndSettle();
    expect(value, palette[3]);
  });

  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('everything renders at 320 px in ${mode.name} mode', (tester) async {
      await _pump(
        tester,
        mode: mode,
        width: 320,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UiCheckbox(true, label: 'Checked ' * 20, description: 'Description ' * 20, onChanged: (_) {}),
            const UiCheckbox(null, tristate: true, label: 'Mixed'),
            UiSwitch(true, label: 'Switch', onChanged: (_) {}),
            const UiSwitch(false, label: 'Disabled switch'),
            UiRadioGroup<String>(value: 'apple', options: _fruits, onChanged: (_) {}),
            UiCheckboxGroup<String>(values: const {'banana'}, options: _fruits, onChanged: (_) {}),
            UiSwitchTile('Tile ' * 20, subtitle: 'Sub ' * 30, icon: Icons.wifi, value: true, onChanged: (_) {}),
            UiChoiceCards<String>(options: _fruits, value: 'banana', onChanged: (_) {}),
            UiChoiceCards<String>.multi(options: _fruits, values: const {'apple'}, columns: 2, onChanged: (_) {}),
            UiChipGroup(
              children: [
                UiChip('Selected', selected: true, onTap: () {}),
                for (final s in UiStatus.values)
                  for (final v in UiChipVariant.values) UiChip(s.name, status: s, variant: v),
              ],
            ),
            UiFilterChips<String>(options: _fruits, values: const {'apple'}, onChanged: (_) {}),
            UiSlider(value: 0.5, label: 'Slider', onChanged: (_) {}),
            UiRangeSlider(values: const RangeValues(0.2, 0.8), label: 'Range', onChanged: (_) {}),
            const UiRating(value: 3.5),
            UiColorPicker(value: const Color(0xFF10B981), colors: UiColors.light().chart, onChanged: (_) {}),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
    });
  }
}
