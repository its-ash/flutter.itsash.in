import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/src/button/button.dart';
import 'package:theme/src/foundation/foundation.dart';

Future<void> _pump(WidgetTester tester, Widget child, {ThemeMode mode = ThemeMode.light, double? width}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: UiTheme.light(),
      darkTheme: UiTheme.dark(),
      themeMode: mode,
      home: Scaffold(
        body: Center(
          child: width == null ? child : SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('UiButton', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('all variants render in ${mode.name}', (tester) async {
        await _pump(
          tester,
          mode: mode,
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final v in UiButtonVariant.values) ...[
                UiButton(v.name, variant: v, icon: Icons.add, onPressed: () {}),
                UiButton('${v.name} off', variant: v),
              ],
              UiButton('Status', status: UiStatus.success, onPressed: () {}),
            ],
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('primary'), findsOneWidget);
        expect(find.text('link off'), findsOneWidget);
      });
    }

    testWidgets('tap calls onPressed', (tester) async {
      var taps = 0;
      await _pump(tester, UiButton('Save', onPressed: () => taps++));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(taps, 1);
    });

    testWidgets('null onPressed is disabled', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const UiButton('Save'));
      await tester.tap(find.text('Save'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(
        tester.getSemantics(find.byType(UiButton)),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false, label: 'Save'),
      );
      handle.dispose();
    });

    testWidgets('loading shows spinner, keeps width and blocks taps', (tester) async {
      var taps = 0;
      await _pump(tester, UiButton('Submit', onPressed: () => taps++));
      final width = tester.getSize(find.byType(UiButton)).width;
      await _pump(tester, UiButton('Submit', loading: true, onPressed: () => taps++));
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(tester.getSize(find.byType(UiButton)).width, width);
      await tester.tap(find.byType(UiButton));
      await tester.pump(const Duration(milliseconds: 300));
      expect(taps, 0);
    });

    testWidgets('expand fills width', (tester) async {
      await _pump(tester, UiButton('Go', expand: true, onPressed: () {}), width: 300);
      expect(tester.getSize(find.byType(UiButton)).width, 300);
    });

    testWidgets('long label at 320 px does not overflow', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _pump(
        tester,
        UiButton(
          'A very long label that will not fit in the width at all',
          icon: Icons.add,
          trailingIcon: Icons.arrow_forward,
          onPressed: () {},
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(UiButton)).width, lessThanOrEqualTo(320));
    });
  });

  group('UiIconButton', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('renders with badges in ${mode.name}', (tester) async {
        await _pump(
          tester,
          mode: mode,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              UiIconButton(Icons.mail, tooltip: 'Mail', badge: 3, onPressed: () {}),
              UiIconButton(Icons.notifications, tooltip: 'Alerts', badge: 120, onPressed: () {}),
              UiIconButton(Icons.chat, tooltip: 'Chat', dot: true, circular: true, onPressed: () {}),
              const UiIconButton(Icons.block, tooltip: 'Off', variant: UiButtonVariant.outline),
            ],
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('3'), findsOneWidget);
        expect(find.text('99+'), findsOneWidget);
      });
    }

    testWidgets('tap and tooltip', (tester) async {
      var taps = 0;
      await _pump(tester, UiIconButton(Icons.add, tooltip: 'Add', onPressed: () => taps++));
      expect(find.byTooltip('Add'), findsOneWidget);
      await tester.tap(find.byType(UiIconButton));
      await tester.pumpAndSettle();
      expect(taps, 1);
      expect(tester.getSize(find.byType(UiIconButton)), const Size(44, 44));
    });
  });

  group('UiFab', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('works as floatingActionButton in ${mode.name}', (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.light(),
            darkTheme: UiTheme.dark(),
            themeMode: mode,
            home: Scaffold(
              body: const SizedBox.expand(),
              floatingActionButton: UiFab(Icons.add, label: 'New', onPressed: () => taps++),
            ),
          ),
        );
        await tester.tap(find.text('New'));
        await tester.pumpAndSettle();
        expect(taps, 1);
        expect(tester.getSize(find.byType(UiFab)).height, UiFab.height);
      });
    }

    testWidgets('icon-only is square', (tester) async {
      await _pump(tester, UiFab(Icons.add, tooltip: 'Add', onPressed: () {}));
      expect(tester.getSize(find.byType(UiFab)), const Size(56, 56));
      expect(find.byTooltip('Add'), findsOneWidget);
    });
  });

  group('UiButtonBar', () {
    Widget bar(void Function(String) onTap) => UiButtonBar([
      UiButton('Cancel', variant: UiButtonVariant.outline, onPressed: () => onTap('cancel')),
      UiButton('Save', onPressed: () => onTap('save')),
    ]);

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('wide: row, end aligned in ${mode.name}', (tester) async {
        final taps = <String>[];
        await _pump(tester, bar(taps.add), mode: mode, width: 600);
        final cancel = tester.getRect(find.widgetWithText(UiButton, 'Cancel'));
        final save = tester.getRect(find.widgetWithText(UiButton, 'Save'));
        expect(cancel.center.dy, save.center.dy);
        expect(save.left, greaterThan(cancel.right));
        expect(save.right, closeTo(tester.getRect(find.byType(UiButtonBar)).right, 0.01));
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(taps, ['save']);
      });
    }

    testWidgets('narrow: stacks full width, primary first, no overflow', (tester) async {
      final taps = <String>[];
      await _pump(tester, bar(taps.add), width: 160);
      expect(tester.takeException(), isNull);
      final cancel = tester.getRect(find.widgetWithText(UiButton, 'Cancel'));
      final save = tester.getRect(find.widgetWithText(UiButton, 'Save'));
      expect(save.bottom, lessThanOrEqualTo(cancel.top));
      expect(save.width, 160);
      expect(cancel.width, 160);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(taps, ['cancel']);
    });

    testWidgets('expand: equal widths', (tester) async {
      await _pump(
        tester,
        UiButtonBar(expand: true, [UiButton('No', onPressed: () {}), UiButton('Yes', onPressed: () {})]),
        width: 320,
      );
      final a = tester.getSize(find.widgetWithText(UiButton, 'No'));
      final b = tester.getSize(find.widgetWithText(UiButton, 'Yes'));
      expect(a.width, b.width);
      expect(a.width, (320 - UiSpace.sm) / 2);
    });
  });

  group('UiSegmentedControl', () {
    Widget host({ValueChanged<String>? onChanged, required String value, bool expand = false}) => UiSegmentedControl(
      const [
        UiSegment('day', label: 'Day'),
        UiSegment('week', label: 'Week', icon: Icons.view_week),
        UiSegment('month', icon: Icons.calendar_month, tooltip: 'Month'),
      ],
      value: value,
      onChanged: onChanged,
      expand: expand,
    );

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('selection changes in ${mode.name}', (tester) async {
        var value = 'day';
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.light(),
            darkTheme: UiTheme.dark(),
            themeMode: mode,
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) => host(value: value, onChanged: (v) => setState(() => value = v)),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Week'));
        await tester.pumpAndSettle();
        expect(value, 'week');
        await tester.tap(find.byTooltip('Month'));
        await tester.pumpAndSettle();
        expect(value, 'month');
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('null onChanged does nothing', (tester) async {
      await _pump(tester, host(value: 'day'));
      await tester.tap(find.text('Week'), warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('equal segment widths; expand fills; narrow no overflow', (tester) async {
      await _pump(tester, host(value: 'day', onChanged: (_) {}));
      final a = tester.getSize(find.ancestor(of: find.text('Day'), matching: find.byType(Expanded)).first);
      final b = tester.getSize(find.ancestor(of: find.text('Week'), matching: find.byType(Expanded)).first);
      expect(a.width, b.width);
      await _pump(tester, host(value: 'day', onChanged: (_) {}, expand: true), width: 300);
      expect(tester.getSize(find.byType(UiSegmentedControl<String>)).width, 300);
      await _pump(
        tester,
        width: 320,
        UiSegmentedControl(
          const [
            UiSegment(1, label: 'Everything at once'),
            UiSegment(2, label: 'Only the new ones', icon: Icons.fiber_new),
            UiSegment(3, label: 'Archived and old'),
            UiSegment(4, icon: Icons.star, tooltip: 'Starred'),
          ],
          value: 2,
          onChanged: (_) {},
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(UiSegmentedControl<int>)).width, lessThanOrEqualTo(320));
    });
  });

  group('UiToggleButton', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('toggles in ${mode.name}', (tester) async {
        var on = false;
        await tester.pumpWidget(
          MaterialApp(
            theme: UiTheme.light(),
            darkTheme: UiTheme.dark(),
            themeMode: mode,
            home: Scaffold(
              body: Center(
                child: StatefulBuilder(
                  builder: (context, setState) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UiToggleButton('Bold', selected: on, onChanged: (v) => setState(() => on = v)),
                      UiToggleButton.icon(Icons.format_italic, tooltip: 'Italic', selected: on, onChanged: null),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('Bold'));
        await tester.pumpAndSettle();
        expect(on, isTrue);
        await tester.tap(find.text('Bold'));
        await tester.pumpAndSettle();
        expect(on, isFalse);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('UiToggleGroup', () {
    const items = [
      UiSegment('a', label: 'Alpha'),
      UiSegment('b', label: 'Beta'),
      UiSegment('c', icon: Icons.star, tooltip: 'Star'),
    ];

    Future<Set<String>> run(WidgetTester tester, {required bool multiple, required List<Finder> taps}) async {
      var selected = <String>{'a'};
      await _pump(
        tester,
        StatefulBuilder(
          builder: (context, setState) => UiToggleGroup(
            items,
            selected: selected,
            multiple: multiple,
            onChanged: (s) => setState(() => selected = s),
          ),
        ),
      );
      for (final f in taps) {
        await tester.tap(f);
        await tester.pumpAndSettle();
      }
      return selected;
    }

    testWidgets('single select replaces and keeps one', (tester) async {
      expect(await run(tester, multiple: false, taps: [find.text('Beta')]), {'b'});
      expect(await run(tester, multiple: false, taps: [find.text('Alpha')]), {'a'});
    });

    testWidgets('multi select adds and removes', (tester) async {
      expect(await run(tester, multiple: true, taps: [find.text('Beta'), find.byTooltip('Star')]), {'a', 'b', 'c'});
      expect(await run(tester, multiple: true, taps: [find.text('Alpha')]), <String>{});
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('wraps when narrow in ${mode.name}', (tester) async {
        await _pump(
          tester,
          mode: mode,
          width: 140,
          UiToggleGroup(items, selected: const {'a'}, onChanged: (_) {}),
        );
        expect(tester.takeException(), isNull);
        await _pump(tester, mode: mode, width: 300, UiToggleGroup(items, selected: const {'a'}, expand: true));
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('UiCopyButton', () {
    late List<MethodCall> calls;

    setUp(() {
      calls = [];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (call) async {
          calls.add(call);
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      );
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('copies text and shows check in ${mode.name}', (tester) async {
        var copied = 0;
        await _pump(tester, mode: mode, UiCopyButton('secret-123', onCopied: () => copied++));
        expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
        await tester.tap(find.byType(UiCopyButton));
        await tester.pump();
        final set = calls.where((c) => c.method == 'Clipboard.setData').toList();
        expect(set, hasLength(1));
        expect((set.single.arguments as Map)['text'], 'secret-123');
        expect(copied, 1);
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
        await tester.pump(UiCopyButton.feedbackDuration);
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.check_rounded), findsNothing);
        expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
      });
    }

    testWidgets('with label swaps to copied label', (tester) async {
      await _pump(tester, const UiCopyButton('x', label: 'Copy link'));
      await tester.tap(find.text('Copy link'));
      await tester.pump();
      expect(find.text('Copied'), findsOneWidget);
      await tester.pump(UiCopyButton.feedbackDuration);
      await tester.pumpAndSettle();
      expect(find.text('Copy link'), findsOneWidget);
    });
  });

  group('UiSocialButton', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('renders and taps in ${mode.name}', (tester) async {
        var taps = 0;
        await _pump(
          tester,
          mode: mode,
          width: 320,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UiSocialButton('Google', icon: Icons.g_mobiledata, onPressed: () => taps++),
              const UiSocialButton('Apple', leading: FlutterLogo()),
            ],
          ),
        );
        expect(find.text('Continue with Google'), findsOneWidget);
        expect(tester.getSize(find.widgetWithText(UiSocialButton, 'Continue with Google')).width, 320);
        await tester.tap(find.text('Continue with Google'));
        await tester.pumpAndSettle();
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      });
    }
  });

  group('UiHoldButton', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('completes when held for the duration in ${mode.name}', (tester) async {
        var confirmed = 0;
        await _pump(tester, mode: mode, UiHoldButton('Hold to delete', onConfirmed: () => confirmed++));
        final gesture = await tester.startGesture(tester.getCenter(find.byType(UiHoldButton)));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 800));
        expect(confirmed, 0);
        await tester.pump(const Duration(milliseconds: 800));
        expect(confirmed, 1);
        expect(find.byIcon(Icons.check_rounded), findsOneWidget);
        await gesture.up();
        await tester.pumpAndSettle();
        expect(confirmed, 1);
        expect(find.byIcon(Icons.check_rounded), findsNothing);
      });
    }

    testWidgets('releasing early cancels', (tester) async {
      var confirmed = 0;
      await _pump(tester, UiHoldButton('Hold', onConfirmed: () => confirmed++));
      final gesture = await tester.startGesture(tester.getCenter(find.byType(UiHoldButton)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await gesture.up();
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 2));
      expect(confirmed, 0);
    });

    testWidgets('a quick tap does not confirm; null is disabled', (tester) async {
      var confirmed = 0;
      await _pump(tester, UiHoldButton('Hold', onConfirmed: () => confirmed++));
      await tester.tap(find.byType(UiHoldButton));
      await tester.pumpAndSettle();
      expect(confirmed, 0);
      await _pump(tester, const UiHoldButton('Hold'));
      final gesture = await tester.startGesture(tester.getCenter(find.byType(UiHoldButton)));
      await tester.pump(const Duration(seconds: 2));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });
}
