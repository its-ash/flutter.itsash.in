import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/media/media.dart';

/// 1×1 transparent PNG.
const _png = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
];

MemoryImage _img([int i = 0]) => MemoryImage(Uint8List.fromList([..._png]), scale: 1.0 + i * 0.001);

Widget _app(Widget child, {ThemeMode mode = ThemeMode.light, double? width}) => MaterialApp(
  theme: UiTheme.light(),
  darkTheme: UiTheme.dark(),
  themeMode: mode,
  home: Scaffold(
    body: width == null
        ? child
        : Align(
            alignment: Alignment.topCenter,
            child: SizedBox(width: width, child: child),
          ),
  ),
);

const _modes = [ThemeMode.light, ThemeMode.dark];

void main() {
  group('UiImage', () {
    for (final mode in _modes) {
      testWidgets('shows shimmer then error fallback for a missing asset ($mode)', (tester) async {
        await tester.pumpWidget(_app(const UiImage('assets/missing.png', width: 120, height: 90), mode: mode));
        expect(find.byIcon(Icons.image_not_supported_outlined), findsNothing);
        await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('custom error widget', (tester) async {
      await tester.pumpWidget(_app(const UiImage('assets/missing.png', height: 80, errorWidget: Text('broken'))));
      await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('broken'), findsOneWidget);
    });

    testWidgets('loads a MemoryImage and fades it in', (tester) async {
      await tester.pumpWidget(_app(UiImage.provider(_img(), width: 100, height: 100, radius: UiRadius.md)));
      await tester.runAsync(() async {
        final element = tester.element(find.byType(Image));
        await precacheImage(tester.widget<Image>(find.byType(Image)).image, element);
      });
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      final fade = tester.widget<AnimatedOpacity>(
        find.descendant(of: find.byType(UiImage), matching: find.byType(AnimatedOpacity)),
      );
      expect(fade.opacity, 1);
      expect(find.byIcon(Icons.image_not_supported_outlined), findsNothing);
    });

    test('resolve picks network or asset', () {
      expect(UiImage.resolve('https://x.com/a.png'), isA<NetworkImage>());
      expect(UiImage.resolve('assets/a.png'), isA<AssetImage>());
      final m = _img();
      expect(UiImage.resolve(m), same(m));
    });

    testWidgets('lazy image waits for the viewport', (tester) async {
      final scroll = ScrollController();
      addTearDown(scroll.dispose);
      await tester.pumpWidget(
        _app(
          SingleChildScrollView(
            controller: scroll,
            child: Column(children: [const SizedBox(height: 3000), UiImage.provider(_img(), height: 100, lazy: true)]),
          ),
        ),
      );
      await tester.pump();
      expect(find.byType(Image), findsNothing);
      scroll.jumpTo(2600);
      await tester.pump();
      await tester.pump();
      expect(find.byType(Image), findsOneWidget);
    });
  });

  group('UiCarousel', () {
    for (final mode in _modes) {
      testWidgets('swipes and reports page change ($mode)', (tester) async {
        final pages = <int>[];
        await tester.pumpWidget(
          _app(
            UiCarousel(
              itemCount: 3,
              itemBuilder: (context, i) => ColoredBox(color: context.colors.surfaceMuted, child: Text('Page $i')),
              onPageChanged: pages.add,
            ),
            mode: mode,
          ),
        );
        expect(find.text('Page 0'), findsOneWidget);
        await tester.fling(find.text('Page 0'), const Offset(-400, 0), 1500);
        await tester.pumpAndSettle();
        expect(pages, [1]);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('autoplay advances and its timer is disposed', (tester) async {
      final pages = <int>[];
      await tester.pumpWidget(
        _app(
          UiCarousel(
            itemCount: 3,
            autoPlay: true,
            loop: true,
            interval: const Duration(seconds: 2),
            itemBuilder: (context, i) => Text('Slide $i'),
            onPageChanged: pages.add,
          ),
        ),
      );
      Future<void> tick() async {
        await tester.pump(const Duration(milliseconds: 1900));
        await tester.pump(const Duration(milliseconds: 100)); // timer fires
        await tester.pump(); // animation starts
        await tester.pump(const Duration(milliseconds: 900)); // animation ends
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tick();
      expect(pages, [1]);
      await tick();
      expect(pages, [1, 2]);
      // Removing the widget must cancel the periodic timer (the test fails on pending timers).
      await tester.pumpWidget(_app(const SizedBox()));
    });

    testWidgets('fits 320 px', (tester) async {
      await tester.pumpWidget(_app(UiCarousel(itemCount: 12, itemBuilder: (context, i) => Text('$i')), width: 320));
      expect(tester.takeException(), isNull);
    });
  });

  group('UiImageViewer', () {
    for (final mode in _modes) {
      testWidgets('opens, shows counter, swipes and closes ($mode)', (tester) async {
        final images = [_img(0), _img(1), _img(2)];
        await tester.pumpWidget(
          _app(
            Builder(
              builder: (context) => TextButton(
                onPressed: () => UiImageViewer.show(context, images: images, initialIndex: 1),
                child: const Text('open'),
              ),
            ),
            mode: mode,
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('2 / 3'), findsOneWidget);

        await tester.fling(find.byType(PageView), const Offset(-500, 0), 2000);
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('3 / 3'), findsOneWidget);

        await tester.tap(find.byTooltip('Close'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        expect(find.text('3 / 3'), findsNothing);
        expect(find.text('open'), findsOneWidget);
      });
    }

    testWidgets('swipe down dismisses', (tester) async {
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => UiImageViewer.show(context, images: [_img(), _img(1)]),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('1 / 2'), findsOneWidget);
      await tester.fling(find.byType(PageView), const Offset(0, 400), 2000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('1 / 2'), findsNothing);
    });
  });

  group('UiImageGrid', () {
    for (final mode in _modes) {
      testWidgets('shows +N and reports taps ($mode)', (tester) async {
        int? tapped;
        await tester.pumpWidget(
          _app(
            UiImageGrid(images: [for (var i = 0; i < 6; i++) _img(i)], onTap: (i) => tapped = i),
            mode: mode,
            width: 320,
          ),
        );
        expect(find.text('+2'), findsOneWidget);
        await tester.tap(find.text('+2'));
        expect(tapped, 3);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('layouts for 1, 2 and 3 images', (tester) async {
      for (final n in [1, 2, 3]) {
        await tester.pumpWidget(_app(UiImageGrid(images: [for (var i = 0; i < n; i++) _img(i)]), width: 320));
        expect(find.byType(UiImage), findsNWidgets(n));
        expect(find.textContaining('+'), findsNothing);
      }
    });
  });

  group('UiVideoPlayer', () {
    for (final mode in _modes) {
      testWidgets('shows error UI without a platform player ($mode)', (tester) async {
        await tester.pumpWidget(_app(const UiVideoPlayer('https://example.com/clip.mp4'), mode: mode, width: 320));
        await tester.pump();
        await tester.pump();
        expect(find.text('Video unavailable'), findsOneWidget);
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump();
        expect(find.text('Video unavailable'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(_app(const SizedBox()));
      });
    }
  });

  group('UiVideoThumbnail', () {
    for (final mode in _modes) {
      testWidgets('shows duration and taps ($mode)', (tester) async {
        var taps = 0;
        await tester.pumpWidget(
          _app(
            UiVideoThumbnail(_img(), duration: const Duration(minutes: 3, seconds: 5), onTap: () => taps++),
            mode: mode,
            width: 320,
          ),
        );
        expect(find.text('3:05'), findsOneWidget);
        expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
        await tester.tap(find.byType(UiVideoThumbnail));
        expect(taps, 1);
      });
    }

    testWidgets('null onTap is disabled', (tester) async {
      await tester.pumpWidget(_app(UiVideoThumbnail(_img()), width: 320));
      expect(find.byType(InkWell), findsNothing);
    });
  });
}
