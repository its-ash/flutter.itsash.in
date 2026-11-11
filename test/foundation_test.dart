import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:theme/src/about/about.dart';
import 'package:theme/src/foundation/foundation.dart';

void main() {
  group('UiColors', () {
    test('light and dark palettes have the right brightness', () {
      expect(UiColors.light().isDark, isFalse);
      expect(UiColors.dark().isDark, isTrue);
      expect(UiColors.light().accent, UiColors.defaultAccentLight);
      expect(UiColors.dark().accent, UiColors.defaultAccentDark);
    });

    test('custom accent is used and lightened for dark mode', () {
      const brand = Color(0xFF0F5132); // very dark green
      expect(UiColors.light(accent: brand).accent, brand);
      final dark = UiColors.dark(accent: brand).accent;
      expect(HSLColor.fromColor(dark).lightness, greaterThanOrEqualTo(0.6));
    });

    test('onAccent contrasts with accent', () {
      expect(UiColors.light(accent: const Color(0xFFFFEB3B)).onAccent, isNot(Colors.white));
      expect(UiColors.light(accent: const Color(0xFF1E3A8A)).onAccent, Colors.white);
    });

    test('tone returns the four status colors', () {
      final c = UiColors.light();
      final t = c.tone(UiStatus.danger);
      expect([t.color, t.onColor, t.soft, t.onSoft], [c.danger, c.onDanger, c.dangerSoft, c.onDangerSoft]);
      for (final s in UiStatus.values) {
        expect(c.tone(s), isA<UiTone>());
      }
    });

    test('lerp and copyWith', () {
      final a = UiColors.light();
      final b = UiColors.dark();
      expect(a.lerp(b, 0).background, a.background);
      expect(a.lerp(b, 1).background, b.background);
      expect(a.copyWith(accent: const Color(0xFFE11D48)).accent, const Color(0xFFE11D48));
      expect(a.chartColor(9), a.chart[1]);
    });
  });

  group('UiTheme', () {
    test('builds light and dark ThemeData with the extension', () {
      final light = UiTheme.light();
      final dark = UiTheme.dark(accent: const Color(0xFF059669));
      expect(light.brightness, Brightness.light);
      expect(dark.brightness, Brightness.dark);
      expect(light.extension<UiColors>(), isNotNull);
      expect(light.colorScheme.primary, UiColors.defaultAccentLight);
      expect(light.scaffoldBackgroundColor, UiColors.light().background);
    });

    testWidgets('Material widgets render in both modes', (t) async {
      for (final mode in [ThemeMode.light, ThemeMode.dark]) {
        await t.pumpWidget(MaterialApp(
          theme: UiTheme.light(),
          darkTheme: UiTheme.dark(),
          themeMode: mode,
          home: Scaffold(
            appBar: AppBar(title: const Text('Title')),
            body: ListView(children: [
              FilledButton(onPressed: () {}, child: const Text('Filled')),
              OutlinedButton(onPressed: () {}, child: const Text('Outlined')),
              const TextField(decoration: InputDecoration(hintText: 'Hint')),
              Switch(value: true, onChanged: (_) {}),
              Checkbox(value: true, onChanged: (_) {}),
              Slider(value: 0.5, onChanged: (_) {}),
              const LinearProgressIndicator(value: 0.4),
              const Card(child: ListTile(title: Text('Tile'))),
            ]),
          ),
        ));
        expect(t.takeException(), isNull);
      }
    });
  });

  group('UiContext', () {
    testWidgets('exposes colors, text and breakpoint', (t) async {
      late BuildContext ctx;
      await t.pumpWidget(MaterialApp(
        theme: UiTheme.light(),
        darkTheme: UiTheme.dark(),
        themeMode: ThemeMode.dark,
        home: Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        }),
      ));
      expect(ctx.isDark, isTrue);
      expect(ctx.colors.background, UiColors.dark().background);
      expect(ctx.text.titleLarge, isNotNull);
      expect(ctx.breakpoint, UiBreakpoint.of(ctx.screenSize.width));
      expect(ctx.responsive(compact: 1, medium: 2, expanded: 3, large: 4), ctx.breakpoint.index + 1);
    });

    test('UiBreakpoint thresholds', () {
      expect(UiBreakpoint.of(375), UiBreakpoint.compact);
      expect(UiBreakpoint.of(700), UiBreakpoint.medium);
      expect(UiBreakpoint.of(1000), UiBreakpoint.expanded);
      expect(UiBreakpoint.of(1400), UiBreakpoint.large);
      expect(UiBreakpoint.large >= UiBreakpoint.medium, isTrue);
    });

    testWidgets('UiGap follows the nearest Flex axis', (t) async {
      await t.pumpWidget(const Directionality(
        textDirection: TextDirection.ltr,
        child: Row(children: [
          Column(mainAxisSize: MainAxisSize.min, children: [UiGap(10, key: Key('v'))]),
          UiGap(20, key: Key('h')),
        ]),
      ));
      expect(t.getSize(find.byKey(const Key('v'))), const Size(0, 10));
      expect(t.getSize(find.byKey(const Key('h'))).width, 20);
    });
  });

  group('UiApp', () {
    testWidgets('controller switches theme mode and accent', (t) async {
      final controller = UiThemeController(mode: ThemeMode.light);
      addTearDown(controller.dispose);
      late BuildContext ctx;
      await t.pumpWidget(UiApp(
        controller: controller,
        home: Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        }),
      ));
      expect(ctx.isDark, isFalse);
      expect(UiThemeController.of(ctx), same(controller));

      controller.toggle(ctx);
      await t.pumpAndSettle();
      expect(ctx.isDark, isTrue);

      controller.accent = const Color(0xFFE11D48);
      await t.pumpAndSettle();
      expect(ctx.colors.accent, isNot(UiColors.defaultAccentDark));
    });

    testWidgets('starts light and restores a saved mode', (t) async {
      SharedPreferences.setMockInitialValues({});
      late BuildContext ctx;
      Widget app() => UiApp(
            home: Builder(builder: (c) {
              ctx = c;
              return const UiAppearanceSection();
            }),
          );
      await t.pumpWidget(app());
      await t.pumpAndSettle();
      expect(ctx.isDark, isFalse);

      await t.tap(find.text('Dark'));
      await t.pumpAndSettle();
      expect(ctx.isDark, isTrue);
      expect(await UiAppearance.load(), ThemeMode.dark);

      await t.pumpWidget(const SizedBox());
      await t.pumpWidget(app());
      await t.pumpAndSettle();
      expect(ctx.isDark, isTrue);
    });

    testWidgets('fixed themeMode without controller', (t) async {
      late BuildContext ctx;
      await t.pumpWidget(UiApp(
        themeMode: ThemeMode.dark,
        home: Builder(builder: (c) {
          ctx = c;
          return const SizedBox();
        }),
      ));
      expect(ctx.isDark, isTrue);
    });
  });
}
