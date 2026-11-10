import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/src/display/display.dart';
import 'package:theme/src/foundation/foundation.dart';

Future<void> pumpUi(
  WidgetTester tester,
  Widget child, {
  ThemeMode mode = ThemeMode.light,
  double width = 400,
  bool scroll = true,
}) async {
  tester.view.physicalSize = Size(width, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: UiTheme.light(),
      darkTheme: UiTheme.dark(),
      themeMode: mode,
      home: Scaffold(
        body: scroll ? SingleChildScrollView(padding: const EdgeInsets.all(16), child: child) : child,
      ),
    ),
  );
}

UiColors colorsOf(WidgetTester tester, Finder f) => UiColors.of(tester.element(f));

class _Row {
  const _Row(this.name, this.size);
  final String name;
  final int size;
}

void main() {
  group('UiFormat', () {
    test('bytes', () {
      expect(UiFormat.bytes(0), '0 B');
      expect(UiFormat.bytes(512), '512 B');
      expect(UiFormat.bytes(1024), '1 KB');
      expect(UiFormat.bytes(1536), '1.5 KB');
      expect(UiFormat.bytes(5 * 1024 * 1024), '5 MB');
      expect(UiFormat.bytes(3650722201), '3.4 GB');
      expect(UiFormat.bytes(1048575), '1 MB');
    });

    test('compact', () {
      expect(UiFormat.compact(999), '999');
      expect(UiFormat.compact(1200), '1.2k');
      expect(UiFormat.compact(45000), '45k');
      expect(UiFormat.compact(3400000), '3.4M');
      expect(UiFormat.compact(999999), '1M');
      expect(UiFormat.compact(-1500), '-1.5k');
      expect(UiFormat.compact(12.5), '12.5');
    });

    test('relativeTime', () {
      final now = DateTime(2026, 6, 15, 12);
      expect(UiFormat.relativeTime(now.subtract(const Duration(seconds: 20)), now: now), 'just now');
      expect(UiFormat.relativeTime(now.subtract(const Duration(minutes: 5)), now: now), '5m');
      expect(UiFormat.relativeTime(now.subtract(const Duration(hours: 3)), now: now), '3h');
      expect(UiFormat.relativeTime(now.subtract(const Duration(days: 2)), now: now), '2d');
      expect(UiFormat.relativeTime(DateTime(2026, 3, 5), now: now), 'Mar 5');
      expect(UiFormat.relativeTime(DateTime(2024, 3, 5), now: now), 'Mar 5, 2024');
      expect(UiFormat.relativeTime(now.add(const Duration(minutes: 10)), now: now), 'in 10m');
    });

    test('duration', () {
      expect(UiFormat.duration(const Duration(minutes: 4, seconds: 9)), '4:09');
      expect(UiFormat.duration(const Duration(hours: 1, minutes: 5, seconds: 9)), '1:05:09');
      expect(UiFormat.duration(Duration.zero), '0:00');
      expect(UiFormat.duration(const Duration(seconds: -5)), '0:00');
    });
  });

  group('UiCard', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('tap and selected border ($mode)', (tester) async {
        var taps = 0;
        await pumpUi(
          tester,
          Column(
            children: [
              UiCard(
                onTap: () => taps++,
                header: const Text('Head'),
                footer: const Text('Foot'),
                child: const Text('Body'),
              ),
              const UiCard(selected: true, variant: UiCardVariant.filled, child: Text('Sel')),
              const UiCard(variant: UiCardVariant.elevated, child: Text('Elev')),
              const UiCard(variant: UiCardVariant.ghost, child: Text('Ghost')),
            ],
          ),
          mode: mode,
        );
        await tester.tap(find.text('Body'));
        await tester.pumpAndSettle();
        expect(taps, 1);
        expect(find.text('Head'), findsOneWidget);
        expect(find.text('Foot'), findsOneWidget);

        final colors = colorsOf(tester, find.text('Sel'));
        final material = tester.widget<Material>(
          find.ancestor(of: find.text('Sel'), matching: find.byType(Material)).first,
        );
        final shape = material.shape! as RoundedRectangleBorder;
        expect(shape.side.color, colors.accent);
        // Non-tappable cards have no ink.
        expect(find.ancestor(of: find.text('Sel'), matching: find.byType(InkWell)), findsNothing);
      });
    }
  });

  group('UiListTile / UiListGroup', () {
    testWidgets('dividers between rows only', (tester) async {
      await pumpUi(
        tester,
        const UiListGroup(
          header: 'Account',
          footer: 'Footer help',
          children: [
            UiListTile('One', icon: Icons.person),
            UiListTile('Two', subtitle: 'Sub'),
            UiListTile('Three', value: 'English', chevron: true),
          ],
        ),
      );
      expect(find.byType(Divider), findsNWidgets(2));
      expect(find.text('Account'), findsOneWidget);
      expect(find.text('Footer help'), findsOneWidget);
      expect(find.text('English'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
      expect(find.byType(UiIconBox), findsOneWidget);

      // Divider of the row with a leading icon starts under the text.
      final firstDivider = tester.getTopLeft(find.byType(Divider).first);
      final firstTitle = tester.getTopLeft(find.text('One'));
      expect(firstDivider.dx, closeTo(firstTitle.dx, 0.5));
    });

    testWidgets('non-tile children get group dividers', (tester) async {
      await pumpUi(tester, const UiListGroup(children: [Text('a'), Text('b'), UiListTile('c')]));
      expect(find.byType(Divider), findsNWidgets(2));
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('tap, disabled, destructive ($mode)', (tester) async {
        var taps = 0;
        await pumpUi(
          tester,
          UiListGroup(
            children: [
              UiListTile('Tap', onTap: () => taps++),
              UiListTile('Off', enabled: false, onTap: () => taps++),
              UiListTile('Delete', destructive: true, icon: Icons.delete, onTap: () {}),
              UiListTile('Sel', selected: true, onTap: () {}),
            ],
          ),
          mode: mode,
        );
        await tester.tap(find.text('Tap'));
        await tester.tap(find.text('Off'));
        await tester.pumpAndSettle();
        expect(taps, 1);
        final colors = colorsOf(tester, find.text('Delete'));
        expect(tester.widget<Text>(find.text('Delete')).style!.color, colors.danger);
        expect(tester.widget<Text>(find.text('Off')).style!.color, colors.textDisabled);
      });
    }
  });

  group('UiAvatar', () {
    test('initials', () {
      expect(UiAvatar.initialsOf('Ada Lovelace'), 'AL');
      expect(UiAvatar.initialsOf('ada'), 'A');
      expect(UiAvatar.initialsOf('john.doe@mail.com'), 'JD');
      expect(UiAvatar.initialsOf('  Mary Ann Smith '), 'MS');
      expect(UiAvatar.initialsOf(''), '');
      expect(UiAvatar.colorIndexOf('Ada'), UiAvatar.colorIndexOf('ada'));
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('initials, icon fallback, status ($mode)', (tester) async {
        await pumpUi(
          tester,
          const Row(
            children: [
              UiAvatar(name: 'Ada Lovelace', status: UiStatus.success),
              UiAvatar(size: UiSize.lg, shape: UiAvatarShape.rounded, status: UiStatus.danger),
            ],
          ),
          mode: mode,
        );
        expect(find.text('AL'), findsOneWidget);
        expect(find.byIcon(Icons.person_rounded), findsOneWidget);
        expect(tester.getSize(find.byType(UiAvatar).last), const Size(56, 56));
      });
    }

    testWidgets('broken image falls back to initials', (tester) async {
      await pumpUi(tester, UiAvatar(name: 'Grace Hopper', image: MemoryImage(Uint8List.fromList([0, 1, 2, 3, 4, 5]))));
      expect(find.text('GH'), findsOneWidget);
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
      await tester.pump();
      expect(find.text('GH'), findsOneWidget);
    });

    testWidgets('group shows +N', (tester) async {
      await pumpUi(
        tester,
        UiAvatarGroup(
          max: 3,
          avatars: [
            for (final n in ['A B', 'C D', 'E F', 'G H', 'I J', 'K L']) UiAvatar(name: n),
          ],
        ),
      );
      expect(find.text('+3'), findsOneWidget);
      expect(find.byType(UiAvatar), findsNWidgets(3));
      expect(find.text('GH'), findsNothing);
    });
  });

  group('UiBadge', () {
    test('label', () {
      expect(UiCountBadge.label(5, 99), '5');
      expect(UiCountBadge.label(120, 99), '99+');
      expect(UiCountBadge.label(12, 9), '9+');
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('count, max, dot, hidden ($mode)', (tester) async {
        await pumpUi(
          tester,
          Row(
            children: [
              const UiBadge(count: 120, child: Icon(Icons.mail)),
              const SizedBox(width: 24),
              const UiBadge(count: 0, child: Icon(Icons.home)),
              const SizedBox(width: 24),
              const UiBadge(dot: true, status: UiStatus.success, child: Icon(Icons.chat)),
              const SizedBox(width: 24),
              UiBadge.standalone(count: 7),
              const UiCountBadge(3, status: UiStatus.accent),
            ],
          ),
          mode: mode,
        );
        await tester.pumpAndSettle();
        expect(find.text('99+'), findsOneWidget);
        expect(find.text('7'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
        final hidden = tester.widget<AnimatedScale>(
          find.descendant(
            of: find.ancestor(of: find.byIcon(Icons.home), matching: find.byType(UiBadge)),
            matching: find.byType(AnimatedScale),
          ),
        );
        expect(hidden.scale, 0);
      });
    }
  });

  group('pills, tags, kbd, code', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('render and tag remove ($mode)', (tester) async {
        var removed = false;
        await pumpUi(
          tester,
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              const UiStatusPill('Online', status: UiStatus.success, pulse: true),
              const UiStatusPill('Failed', status: UiStatus.danger, icon: Icons.error, size: UiSize.lg),
              const UiStatusPill('Idle', dot: true),
              UiTag('Design', color: Colors.purple, onRemove: () => removed = true),
              const UiTag('Neutral'),
              const UiTag('Ok', status: UiStatus.success),
              const UiKbd('⌘K'),
              const UiCodeText('A1B2-C3D4', copyable: true),
              const UiCodeBlock('flutter pub add theme\nflutter run', title: 'Terminal'),
              const UiCodeBlock('no title'),
            ],
          ),
          mode: mode,
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.text('Online'), findsOneWidget);
        expect(find.text('⌘K'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.close_rounded));
        expect(removed, isTrue);
        // Replace the tree so the repeating pulse stops.
        await tester.pumpWidget(const SizedBox());
      });
    }
  });

  group('UiStatCard', () {
    test('format and trend', () {
      expect(UiStatCard.formatDelta(8.2), '+8.2%');
      expect(UiStatCard.formatDelta(-3), '-3%');
      expect(UiStatCard.formatDelta(0), '0%');
      expect(UiStatCard.formatDelta(12, ' pts'), '+12 pts');
      expect(UiStatCard.trendOf(1), UiTrend.up);
      expect(UiStatCard.trendOf(-1), UiTrend.down);
      expect(UiStatCard.trendOf(null), UiTrend.neutral);
      expect(UiStatCard.statusOf(UiTrend.up, invert: true), UiStatus.danger);
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('delta colors ($mode)', (tester) async {
        await pumpUi(
          tester,
          const Column(
            children: [
              UiStatCard(label: 'Revenue', value: '\$12.4k', delta: 8.2, deltaLabel: 'vs last week', icon: Icons.paid),
              UiStatCard(label: 'Users', value: '1,204', delta: -3),
              UiStatCard(label: 'Errors', value: '12', delta: 5, invertColors: true),
            ],
          ),
          mode: mode,
          width: 320,
        );
        final colors = colorsOf(tester, find.text('Revenue'));
        expect(tester.widget<Text>(find.text('+8.2%')).style!.color, colors.onSuccessSoft);
        expect(tester.widget<Text>(find.text('-3%')).style!.color, colors.onDangerSoft);
        expect(tester.widget<Text>(find.text('+5%')).style!.color, colors.onDangerSoft);
        expect(find.byIcon(Icons.arrow_upward_rounded), findsNWidgets(2));
        expect(find.byIcon(Icons.arrow_downward_rounded), findsOneWidget);
      });
    }
  });

  group('UiKeyValue', () {
    testWidgets('copy puts value on clipboard', (tester) async {
      String? clip;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') clip = (call.arguments as Map)['text'] as String?;
        return null;
      });
      addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.platform, null));

      await pumpUi(
        tester,
        UiKeyValueList([
          const UiKeyValue('Order ID', 'A-10294', copyable: true, mono: true),
          const UiKeyValue('Status', 'Paid'),
          const UiKeyValue.custom(
            'Owner',
            child: UiAvatar(name: 'Ada', size: UiSize.sm),
          ),
        ]),
      );
      expect(find.byType(Divider), findsNWidgets(2));
      await tester.tap(find.byIcon(Icons.content_copy_rounded));
      await tester.pump();
      expect(clip, 'A-10294');
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(find.byIcon(Icons.content_copy_rounded), findsOneWidget);
    });

    testWidgets('map constructor without dividers (dark)', (tester) async {
      await pumpUi(tester, UiKeyValueList.map(const {'A': '1', 'B': '2'}, dividers: false), mode: ThemeMode.dark);
      expect(find.byType(Divider), findsNothing);
      expect(find.text('2'), findsOneWidget);
    });
  });

  group('UiTable', () {
    final columns = [
      UiTableColumn<_Row>('Name', text: (r) => r.name, sortBy: (r) => r.name.toLowerCase()),
      UiTableColumn<_Row>('Size', text: (r) => '${r.size}', sortBy: (r) => r.size, numeric: true),
      UiTableColumn<_Row>('Note', text: (r) => 'note ${r.name}'),
    ];
    const rows = [_Row('Charlie', 3), _Row('alice', 1), _Row('Bob', 2)];

    List<String> order(WidgetTester tester) {
      final names = ['Charlie', 'alice', 'Bob'];
      names.sort((a, b) => tester.getTopLeft(find.text(a)).dy.compareTo(tester.getTopLeft(find.text(b)).dy));
      return names;
    }

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('sort toggles order and row tap ($mode)', (tester) async {
        _Row? tapped;
        await pumpUi(
          tester,
          UiTable<_Row>(columns: columns, rows: rows, striped: true, onRowTap: (r) => tapped = r),
          mode: mode,
        );
        expect(order(tester), ['Charlie', 'alice', 'Bob']);
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        expect(order(tester), ['alice', 'Bob', 'Charlie']);
        await tester.tap(find.text('Name'));
        await tester.pumpAndSettle();
        expect(order(tester), ['Charlie', 'Bob', 'alice']);
        await tester.tap(find.text('Size'));
        await tester.pumpAndSettle();
        expect(order(tester), ['alice', 'Bob', 'Charlie']);

        await tester.tap(find.text('note Bob'));
        await tester.pumpAndSettle();
        expect(tapped?.name, 'Bob');
      });
    }

    testWidgets('empty message and narrow scroll', (tester) async {
      await pumpUi(tester, UiTable<_Row>(columns: columns, rows: const [], emptyMessage: 'Nothing here'), width: 320);
      expect(find.text('Nothing here'), findsOneWidget);
      await pumpUi(
        tester,
        UiTable<_Row>(
          columns: [
            ...columns,
            UiTableColumn<_Row>('A very long column header', text: (r) => 'Some quite long cell content ${r.name}'),
          ],
          rows: rows,
          dense: true,
        ),
        width: 320,
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('UiTimeline', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('renders items ($mode)', (tester) async {
        await pumpUi(
          tester,
          const UiTimeline(
            items: [
              UiTimelineItem('Order placed', time: '09:41', status: UiStatus.success, description: 'Paid by card'),
              UiTimelineItem('Shipped', time: '2h', icon: Icons.local_shipping, status: UiStatus.info),
              UiTimelineItem('Delivered', content: Text('Signed by Ada')),
            ],
          ),
          mode: mode,
          width: 320,
        );
        expect(find.text('Order placed'), findsOneWidget);
        expect(find.text('09:41'), findsOneWidget);
        expect(find.text('Paid by card'), findsOneWidget);
        expect(find.byIcon(Icons.local_shipping), findsOneWidget);
        expect(find.text('Signed by Ada'), findsOneWidget);
      });
    }
  });

  group('UiAccordion', () {
    final items = [
      const UiAccordionItem('First', Text('Body 1'), subtitle: 'Sub', icon: Icons.info),
      const UiAccordionItem('Second', Text('Body 2')),
    ];

    testWidgets('single mode closes others', (tester) async {
      final changes = <(int, bool)>[];
      await pumpUi(tester, UiAccordion(items: items, onChanged: (i, e) => changes.add((i, e))));
      expect(find.text('Body 1'), findsNothing);
      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();
      expect(find.text('Body 1'), findsOneWidget);
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      expect(find.text('Body 1'), findsNothing);
      expect(find.text('Body 2'), findsOneWidget);
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      expect(find.text('Body 2'), findsNothing);
      expect(changes, [(0, true), (1, true), (1, false)]);
      final rotation = tester.widget<AnimatedRotation>(find.byType(AnimatedRotation).first);
      expect(rotation.turns, 0);
    });

    testWidgets('multiple mode keeps both open (dark)', (tester) async {
      await pumpUi(tester, UiAccordion(items: items, multiple: true), mode: ThemeMode.dark);
      await tester.tap(find.text('First'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Second'));
      await tester.pumpAndSettle();
      expect(find.text('Body 1'), findsOneWidget);
      expect(find.text('Body 2'), findsOneWidget);
      expect(tester.widget<AnimatedRotation>(find.byType(AnimatedRotation).first).turns, 0.5);
    });

    testWidgets('initiallyExpanded', (tester) async {
      await pumpUi(tester, const UiAccordion(items: [UiAccordionItem('X', Text('Open'), initiallyExpanded: true)]));
      expect(find.text('Open'), findsOneWidget);
    });
  });

  group('text widgets', () {
    final long = List.filled(40, 'Lorem ipsum dolor sit amet.').join(' ');

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('expandable text toggles ($mode)', (tester) async {
        await pumpUi(
          tester,
          Column(children: [UiExpandableText(long, maxLines: 2), const UiExpandableText('Short')]),
          mode: mode,
          width: 320,
        );
        expect(find.text('Read more'), findsOneWidget);
        expect(tester.widget<Text>(find.text(long)).maxLines, 2);
        await tester.tap(find.text('Read more'));
        await tester.pumpAndSettle();
        expect(find.text('Show less'), findsOneWidget);
        expect(tester.widget<Text>(find.text(long)).maxLines, isNull);
        await tester.tap(find.text('Show less'));
        await tester.pumpAndSettle();
        expect(find.text('Read more'), findsOneWidget);
      });
    }

    test('highlight matches', () {
      expect(UiHighlightText.matches('Hello hello', 'ELL'), [(1, 4), (7, 10)]);
      expect(UiHighlightText.matches('abc', ''), isEmpty);
      expect(UiHighlightText.matches('aaaa', 'aa'), [(0, 2), (2, 4)]);
    });

    testWidgets('highlight spans', (tester) async {
      await pumpUi(tester, const UiHighlightText('Download the report', 'down'));
      final rich = tester.widget<RichText>(
        find.descendant(of: find.byType(UiHighlightText), matching: find.byType(RichText)),
      );
      final spans = <TextSpan>[];
      rich.text.visitChildren((s) {
        if (s is TextSpan && s.text != null) spans.add(s);
        return true;
      });
      final colors = colorsOf(tester, find.byType(UiHighlightText));
      final hits = spans.where((s) => s.style?.backgroundColor == colors.accentSoft).map((s) => s.text).toList();
      expect(hits, ['Down']);
      expect(spans.map((s) => s.text).join(), 'Download the report');
    });
  });

  group('UiFileTile', () {
    test('kind by extension', () {
      expect(UiFileKind.fromName('IMG_01.HEIC'), UiFileKind.image);
      expect(UiFileKind.fromName('clip.mp4'), UiFileKind.video);
      expect(UiFileKind.fromName('song.flac'), UiFileKind.audio);
      expect(UiFileKind.fromName('/docs/report.pdf'), UiFileKind.pdf);
      expect(UiFileKind.fromName('backup.tar.gz'), UiFileKind.archive);
      expect(UiFileKind.fromName('notes.docx'), UiFileKind.document);
      expect(UiFileKind.fromName('main.dart'), UiFileKind.code);
      expect(UiFileKind.fromName('app-release.apk'), UiFileKind.apk);
      expect(UiFileKind.fromName('README'), UiFileKind.generic);
      expect(UiFileKind.fromName('.bashrc'), UiFileKind.generic);
    });

    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('icon, size and progress ($mode)', (tester) async {
        var taps = 0;
        await pumpUi(
          tester,
          UiListGroup(
            children: [
              UiFileTile(name: 'report.pdf', size: 2400000, onTap: () => taps++),
              const UiFileTile(name: 'movie.mkv', size: 1073741824, progress: 0.5, subtitle: '2 MB/s'),
              const UiFileTile(
                name: 'a-very-long-file-name-that-should-ellipsize-nicely.zip',
                status: UiStatus.danger,
                progress: 0.2,
                size: 100,
              ),
              const UiFileTile(name: 'app.apk'),
            ],
          ),
          mode: mode,
          width: 320,
        );
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.picture_as_pdf_rounded), findsOneWidget);
        expect(find.byIcon(Icons.movie_rounded), findsOneWidget);
        expect(find.byIcon(Icons.folder_zip_rounded), findsOneWidget);
        expect(find.byIcon(Icons.android_rounded), findsOneWidget);
        expect(find.text('2.3 MB'), findsOneWidget);
        expect(find.text('512 MB of 1 GB  ·  2 MB/s'), findsOneWidget);
        expect(find.text('50%'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
        await tester.tap(find.text('report.pdf'));
        expect(taps, 1);
      });
    }
  });

  group('UiCountdown', () {
    testWidgets('counts down and fires onComplete once', (tester) async {
      var done = 0;
      await pumpUi(
        tester,
        UiCountdown(
          period: const Duration(seconds: 30),
          remaining: const Duration(seconds: 2),
          onComplete: () => done++,
        ),
      );
      expect(find.text('2'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 1500));
      expect(find.text('1'), findsOneWidget);
      expect(done, 0);
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pump(const Duration(milliseconds: 100));
      expect(done, 1);
      expect(find.text('0'), findsOneWidget);
      await tester.pump(const Duration(seconds: 2));
      expect(done, 1);
      // Ticker is stopped: nothing is scheduled.
      expect(tester.binding.hasScheduledFrame, isFalse);
    });

    testWidgets('repeat restarts and colors turn danger (dark)', (tester) async {
      var done = 0;
      await pumpUi(
        tester,
        UiCountdown(
          period: const Duration(seconds: 3),
          remaining: const Duration(milliseconds: 400),
          repeat: true,
          size: UiSize.lg,
          label: 'OTP',
          onComplete: () => done++,
        ),
        mode: ThemeMode.dark,
      );
      expect(find.text('OTP'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('1'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      await tester.pump(const Duration(milliseconds: 16));
      expect(done, 1);
      expect(find.text('3'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('label beside small ring, minutes format', (tester) async {
      await pumpUi(
        tester,
        const UiCountdown(period: Duration(minutes: 5), size: UiSize.sm, label: 'Resend code'),
        width: 320,
      );
      expect(find.text('5:00'), findsOneWidget);
      expect(find.text('Resend code'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    });
  });

  group('320 px gallery', () {
    for (final mode in [ThemeMode.light, ThemeMode.dark]) {
      testWidgets('no overflow ($mode)', (tester) async {
        const longText = 'An extremely long label that keeps going and going to test ellipsis behaviour';
        await pumpUi(
          tester,
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              UiCard(onTap: () {}, child: const Text(longText)),
              UiListGroup(
                header: longText,
                children: [
                  UiListTile(
                    longText,
                    subtitle: longText,
                    icon: Icons.wifi,
                    value: longText,
                    chevron: true,
                    trailing: const UiCountBadge(120),
                    onTap: () {},
                  ),
                  const UiListTile(longText, leading: UiAvatar(name: 'Ada Lovelace'), dense: true),
                ],
              ),
              const UiStatCard(
                label: longText,
                value: '\$123,456,789.00',
                delta: 12.5,
                deltaLabel: longText,
                icon: Icons.paid,
              ),
              const UiKeyValue(longText, longText, copyable: true),
              const UiKeyValue(longText, longText, stacked: true),
              const UiFileTile(name: longText, size: 123456789, progress: 0.3, subtitle: longText),
              const Row(
                children: [
                  Flexible(child: UiStatusPill(longText, dot: true)),
                  Flexible(child: UiTag(longText)),
                ],
              ),
              const UiCodeText(longText, copyable: true),
              const UiCodeBlock(longText, title: longText),
              const UiTimeline(
                items: [UiTimelineItem(longText, time: '12:00 PM', description: longText)],
              ),
              const UiAccordion(
                items: [UiAccordionItem(longText, Text(longText), subtitle: longText, icon: Icons.info)],
              ),
              const UiHighlightText(longText, 'long', maxLines: 1),
              const UiExpandableText(longText, maxLines: 1),
              const UiCountdown(period: Duration(seconds: 30), label: longText),
            ],
          ),
          mode: mode,
          width: 320,
        );
        await tester.pump(const Duration(milliseconds: 100));
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox());
      });
    }
  });

  testWidgets('UiStatusPill pulse can turn on, off and on again', (tester) async {
    for (final pulse in [true, false, true, false, true]) {
      await pumpUi(tester, UiStatusPill('Live', status: UiStatus.success, pulse: pulse));
      await tester.pump(const Duration(milliseconds: 300));
      expect(tester.takeException(), isNull, reason: 'pulse: $pulse');
    }
    await tester.pumpWidget(const SizedBox());
  });
}
