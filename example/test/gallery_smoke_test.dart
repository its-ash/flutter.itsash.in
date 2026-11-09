import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/theme.dart';
import 'package:theme_example/main.dart';

const _pages = [
  'Foundation',
  'Buttons',
  'Charts',
  'Display',
  'Feedback',
  'Inputs',
  'Layout',
  'Media',
  'Navigation',
  'Scroll',
  'Selection',
];

/// Lets real async work (asset decoding, fake paging delays) progress, then
/// advances fake time. No pumpAndSettle: some widgets animate forever.
Future<void> _settle(WidgetTester tester, [Duration d = const Duration(milliseconds: 1200)]) async {
  await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  await tester.pump();
  await tester.pump(d);
}

Future<void> _visitAll(WidgetTester tester, Finder Function(String label) navItem, {bool drawer = false}) async {
  for (final label in _pages) {
    if (drawer) {
      await tester.tap(find.byTooltip('Open navigation menu'));
      await _settle(tester, const Duration(milliseconds: 500));
    }
    await tester.tap(navItem(label));
    await _settle(tester);
    expect(tester.takeException(), isNull, reason: 'page $label');
    // The app bar shows the current page title.
    expect(find.descendant(of: find.byType(UiAppBar), matching: find.text(label)), findsOneWidget);
    // The paging list has loaded its first fake page by now.
    if (label == 'Scroll') expect(find.text('Post #1'), findsOneWidget);
  }
}

Future<void> _tearDown(WidgetTester tester) async {
  // Disposes timers (carousel autoplay, countdown) before the test ends.
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(seconds: 5));
}

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    testWidgets('desktop sidebar visits every page ($mode)', (tester) async {
      tester.view.physicalSize = const Size(1400, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final theme = UiThemeController(mode: mode);
      addTearDown(theme.dispose);

      await tester.pumpWidget(GalleryApp(controller: theme));
      await _settle(tester);
      expect(find.byType(UiSidebar), findsOneWidget);
      expect(
        Theme.of(tester.element(find.byType(GalleryHome))).brightness,
        mode == ThemeMode.dark ? Brightness.dark : Brightness.light,
      );

      await _visitAll(tester, (label) => find.descendant(of: find.byType(UiSidebar), matching: find.text(label)));
      await _tearDown(tester);
    });

    testWidgets('phone drawer visits every page ($mode)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final theme = UiThemeController(mode: mode);
      addTearDown(theme.dispose);

      await tester.pumpWidget(GalleryApp(controller: theme));
      await _settle(tester);
      await _visitAll(
        tester,
        (label) => find.descendant(of: find.byType(UiDrawer), matching: find.text(label)),
        drawer: true,
      );
      await _tearDown(tester);
    });
  }

  testWidgets('theme toggle and settings sheet change the theme', (tester) async {
    tester.view.physicalSize = const Size(1400, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final theme = UiThemeController(mode: ThemeMode.light);
    addTearDown(theme.dispose);

    await tester.pumpWidget(GalleryApp(controller: theme));
    await _settle(tester);
    await tester.tap(find.byTooltip('Toggle dark mode'));
    await _settle(tester, const Duration(milliseconds: 500));
    expect(theme.mode, ThemeMode.dark);

    await tester.tap(find.byTooltip('Theme settings'));
    await _settle(tester, const Duration(milliseconds: 500));
    await tester.tap(find.text('System'));
    await _settle(tester, const Duration(milliseconds: 500));
    expect(theme.mode, ThemeMode.system);
    await tester.tap(find.bySemanticsLabel('Teal'));
    await _settle(tester, const Duration(milliseconds: 500));
    expect(theme.accent, Colors.teal);
    expect(tester.takeException(), isNull);
    await _tearDown(tester);
  });
}
