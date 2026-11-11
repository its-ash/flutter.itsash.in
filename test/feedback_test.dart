import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/src/feedback/feedback.dart';
import 'package:theme/src/foundation/foundation.dart';

Future<void> _pump(WidgetTester tester, Widget body, ThemeMode mode, {bool reduceMotion = false}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: UiTheme.light(),
      darkTheme: UiTheme.dark(),
      themeMode: mode,
      builder: reduceMotion
          ? (context, child) =>
                MediaQuery(data: MediaQuery.of(context).copyWith(disableAnimations: true), child: child!)
          : null,
      home: Scaffold(body: body),
    ),
  );
}

/// A button that runs [onTap] with a context below the navigator.
Widget _trigger(String label, void Function(BuildContext context) onTap) => Center(
  child: Builder(
    builder: (context) => TextButton(onPressed: () => onTap(context), child: Text(label)),
  ),
);

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    group('${mode.name} mode', () {
      testWidgets('UiAlert shows text and close works', (tester) async {
        var closed = 0;
        await _pump(
          tester,
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                UiAlert('Trial ends soon', title: 'Heads up', status: UiStatus.warning, onClose: () => closed++),
                const UiAlert('Neutral note', status: UiStatus.neutral, action: Text('Learn more')),
              ],
            ),
          ),
          mode,
        );
        expect(find.text('Heads up'), findsOneWidget);
        expect(find.text('Trial ends soon'), findsOneWidget);
        expect(find.text('Learn more'), findsOneWidget);
        expect(find.byIcon(UiStatus.warning.icon), findsOneWidget);
        await tester.tap(find.byIcon(Icons.close_rounded));
        expect(closed, 1);
      });

      testWidgets('UiBanner animates in and out', (tester) async {
        var visible = false;
        var actions = 0;
        late StateSetter setOuter;
        await _pump(
          tester,
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return Column(
                children: [
                  UiBanner(
                    "You're offline",
                    visible: visible,
                    status: UiStatus.warning,
                    actionLabel: 'Retry',
                    onAction: () => actions++,
                    onDismiss: () => setState(() => visible = false),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              );
            },
          ),
          mode,
        );
        expect(find.text("You're offline"), findsNothing);

        setOuter(() => visible = true);
        await tester.pumpAndSettle();
        expect(find.text("You're offline"), findsOneWidget);
        await tester.tap(find.text('Retry'));
        expect(actions, 1);

        await tester.tap(find.byIcon(Icons.close_rounded));
        await tester.pumpAndSettle();
        expect(find.text("You're offline"), findsNothing);
      });

      testWidgets('toast shows and auto-dismisses', (tester) async {
        var done = false;
        await _pump(
          tester,
          _trigger('go', (context) {
            context.showToast('Saved', status: UiStatus.success).then((_) => done = true);
          }),
          mode,
        );
        await tester.tap(find.text('go'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Saved'), findsOneWidget);
        expect(find.byIcon(UiStatus.success.icon), findsOneWidget);

        await tester.pump(const Duration(seconds: 4));
        await tester.pumpAndSettle();
        expect(find.text('Saved'), findsNothing);
        expect(done, isTrue);
      });

      testWidgets('toasts stack up to 3 and dismissAll clears them', (tester) async {
        await _pump(
          tester,
          _trigger('go', (context) {
            for (var i = 1; i <= 4; i++) {
              UiToast.show(context, 'Toast $i', title: 'T$i', position: UiToastPosition.bottom);
            }
          }),
          mode,
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        expect(find.text('Toast 1'), findsNothing);
        expect(find.text('Toast 2'), findsOneWidget);
        expect(find.text('Toast 4'), findsOneWidget);

        UiToast.dismissAll();
        await tester.pumpAndSettle();
        expect(find.textContaining('Toast'), findsNothing);
      });

      testWidgets('toast action runs and replace closes others', (tester) async {
        var undone = 0;
        await _pump(
          tester,
          _trigger('go', (context) {
            context.showToast('First', duration: null);
            context.showToast('Deleted', replace: true, actionLabel: 'Undo', onAction: () => undone++);
          }),
          mode,
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        expect(find.text('First'), findsNothing);
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();
        expect(undone, 1);
        expect(find.text('Deleted'), findsNothing);
      });

      testWidgets('toast can be swiped away', (tester) async {
        await _pump(tester, _trigger('go', (context) => context.showToast('Swipe me', duration: null)), mode);
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        await tester.drag(find.text('Swipe me'), const Offset(500, 0));
        await tester.pumpAndSettle();
        expect(find.text('Swipe me'), findsNothing);
      });

      testWidgets('showSnack shows a themed snackbar', (tester) async {
        await _pump(
          tester,
          _trigger('go', (context) => context.showSnack('Archived', action: 'Undo', status: UiStatus.success)),
          mode,
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        expect(find.text('Archived'), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);
        expect(find.byIcon(UiStatus.success.icon), findsOneWidget);
      });

      testWidgets('UiDialog.confirm returns true and false', (tester) async {
        bool? result;
        await _pump(
          tester,
          _trigger('go', (context) async {
            result = await UiDialog.confirm(context, title: 'Delete?', message: 'Gone forever', destructive: true);
          }),
          mode,
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        expect(find.text('Delete?'), findsOneWidget);
        expect(find.text('Gone forever'), findsOneWidget);
        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();
        expect(result, isTrue);

        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(result, isFalse);

        // Tapping the barrier also counts as false.
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();
        expect(result, isFalse);
        expect(find.text('Delete?'), findsNothing);
      });

      testWidgets('UiDialog.show and alert return action values', (tester) async {
        String? picked;
        var alertDone = false;
        await _pump(
          tester,
          Column(
            children: [
              _trigger('show', (context) async {
                picked = await UiDialog.show<String>(
                  context,
                  title: 'Pick',
                  icon: Icons.star_rounded,
                  content: const Text('Body'),
                  actions: const [
                    UiDialogAction('A', value: 'a'),
                    UiDialogAction('B', value: 'b', primary: true),
                  ],
                );
              }),
              _trigger('alert', (context) async {
                await UiDialog.alert(context, title: 'Done', status: UiStatus.success);
                alertDone = true;
              }),
            ],
          ),
          mode,
        );
        await tester.tap(find.text('show'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.star_rounded), findsOneWidget);
        expect(find.text('Body'), findsOneWidget);
        await tester.tap(find.text('B'));
        await tester.pumpAndSettle();
        expect(picked, 'b');

        await tester.tap(find.text('alert'));
        await tester.pumpAndSettle();
        expect(find.byIcon(UiStatus.success.icon), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
        expect(alertDone, isTrue);
      });

      testWidgets('UiDialog.prompt validates and returns text', (tester) async {
        String? result = 'unset';
        await _pump(
          tester,
          _trigger('go', (context) async {
            result = await UiDialog.prompt(
              context,
              title: 'Rename',
              label: 'Name',
              initialValue: 'Old',
              validator: (v) => v.trim().isEmpty ? 'Required' : null,
            );
          }),
          mode,
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        expect(find.text('Old'), findsOneWidget);

        await tester.enterText(find.byType(TextFormField), '');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(find.text('Required'), findsOneWidget);
        expect(result, 'unset');

        await tester.enterText(find.byType(TextFormField), 'New name');
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(result, 'New name');

        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(result, isNull);
      });

      testWidgets('UiSheet returns a value', (tester) async {
        int? result;
        await _pump(
          tester,
          _trigger('go', (context) async {
            result = await UiSheet.show<int>(
              context,
              title: 'Filters',
              subtitle: 'Pick one',
              child: const Text('Sheet body'),
              actions: [
                Builder(
                  builder: (ctx) => FilledButton(onPressed: () => Navigator.pop(ctx, 7), child: const Text('Apply')),
                ),
              ],
            );
          }),
          mode,
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        expect(find.text('Filters'), findsOneWidget);
        expect(find.text('Pick one'), findsOneWidget);
        expect(find.text('Sheet body'), findsOneWidget);
        await tester.tap(find.text('Apply'));
        await tester.pumpAndSettle();
        expect(result, 7);
      });

      testWidgets('UiActionSheet returns the chosen action or null', (tester) async {
        String? result = 'unset';
        await _pump(
          tester,
          _trigger('go', (context) async {
            result = await UiActionSheet.show<String>(
              context,
              title: 'Photo',
              actions: const [
                UiSheetAction('Share', value: 'share', icon: Icons.ios_share_rounded),
                UiSheetAction('Locked', value: 'locked', enabled: false),
                UiSheetAction('Delete', value: 'delete', icon: Icons.delete_outline_rounded, destructive: true),
              ],
            );
          }),
          mode,
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Locked'));
        await tester.pumpAndSettle();
        expect(find.text('Photo'), findsOneWidget);
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        expect(result, 'delete');

        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        expect(result, isNull);
      });

      testWidgets('UiMenuButton selects an item', (tester) async {
        String? picked;
        await _pump(
          tester,
          Center(
            child: UiMenuButton<String>(
              onSelected: (v) => picked = v,
              items: const [
                UiMenuItem('rename', 'Rename', icon: Icons.edit_outlined, shortcut: 'R'),
                UiMenuItem('archive', 'Archive', enabled: false),
                UiMenuItem.divider(),
                UiMenuItem('delete', 'Delete', destructive: true),
              ],
            ),
          ),
          mode,
        );
        await tester.tap(find.byIcon(Icons.more_horiz_rounded));
        await tester.pumpAndSettle();
        expect(find.text('Rename'), findsOneWidget);
        expect(find.text('R'), findsOneWidget);
        expect(find.byType(PopupMenuDivider), findsOneWidget);
        await tester.tap(find.text('Rename'));
        await tester.pumpAndSettle();
        expect(picked, 'rename');
      });

      testWidgets('UiMenuButton with null onSelected is disabled', (tester) async {
        await _pump(
          tester,
          const Center(child: UiMenuButton<String>(onSelected: null, items: [UiMenuItem('a', 'A')])),
          mode,
        );
        await tester.tap(find.byIcon(Icons.more_horiz_rounded));
        await tester.pumpAndSettle();
        expect(find.text('A'), findsNothing);
      });

      testWidgets('UiMenu.show at a position', (tester) async {
        int? picked;
        await _pump(
          tester,
          _trigger('go', (context) async {
            picked = await UiMenu.show<int>(
              context,
              position: const Offset(40, 40),
              items: const [UiMenuItem(1, 'One')],
            );
          }),
          mode,
        );
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('One'));
        await tester.pumpAndSettle();
        expect(picked, 1);
      });

      testWidgets('UiPopover opens on tap and closes on outside tap', (tester) async {
        await _pump(
          tester,
          Center(
            child: UiPopover(popover: (context) => const Text('Popover body'), child: const Text('Anchor')),
          ),
          mode,
        );
        expect(find.text('Popover body'), findsNothing);
        await tester.tap(find.text('Anchor'));
        await tester.pumpAndSettle();
        expect(find.text('Popover body'), findsOneWidget);
        await tester.tapAt(const Offset(5, 5));
        await tester.pumpAndSettle();
        expect(find.text('Popover body'), findsNothing);
      });

      testWidgets('UiPopover opens from a controller', (tester) async {
        final controller = UiPopoverController();
        addTearDown(controller.dispose);
        await _pump(
          tester,
          Center(
            child: UiPopover(
              controller: controller,
              openOnTap: false,
              popover: (context) => const Text('Menu'),
              child: OutlinedButton(onPressed: controller.toggle, child: const Text('Open')),
            ),
          ),
          mode,
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Menu'), findsOneWidget);
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(find.text('Menu'), findsNothing);
      });

      testWidgets('UiTooltip wraps its child', (tester) async {
        await _pump(tester, const Center(child: UiTooltip('Copy link', child: Icon(Icons.link_rounded))), mode);
        expect(find.byTooltip('Copy link'), findsOneWidget);
      });

      testWidgets('progress widgets render determinate and indeterminate', (tester) async {
        var value = 0.4;
        late StateSetter setOuter;
        await _pump(
          tester,
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    UiProgressBar(value, label: 'Uploading', showPercent: true),
                    UiProgressRing(value, showPercent: true, size: 64, status: UiStatus.success),
                  ],
                ),
              );
            },
          ),
          mode,
        );
        expect(find.text('Uploading'), findsOneWidget);
        expect(find.text('40%'), findsNWidgets(2));
        setOuter(() => value = 0.9);
        await tester.pumpAndSettle();
        expect(find.text('90%'), findsNWidgets(2));
        expect(find.byType(LinearProgressIndicator), findsNothing);

        await _pump(
          tester,
          const Column(
            children: [
              UiProgressBar(null),
              UiProgressBar.indeterminate(label: 'Loading'),
              UiProgressRing(null),
              UiSpinner(),
            ],
          ),
          mode,
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
        expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
        // Swap out the endless animations so the test can end cleanly.
        await _pump(tester, const SizedBox(), mode);
      });

      testWidgets('skeletons render and share one shimmer', (tester) async {
        await _pump(
          tester,
          const Padding(
            padding: EdgeInsets.all(16),
            child: UiShimmer(
              child: Column(
                children: [
                  UiSkeleton.circle(size: 48),
                  UiSkeleton.text(lines: 3),
                  UiSkeleton.box(height: 80),
                  UiSkeleton(width: 120),
                  Expanded(child: UiSkeletonList(count: 20)),
                ],
              ),
            ),
          ),
          mode,
        );
        await tester.pump(const Duration(milliseconds: 500));
        expect(find.byType(UiSkeleton), findsWidgets);
        // UiSkeletonList adds its own shimmer; the rest share the outer one.
        expect(find.byType(UiShimmer), findsNWidgets(2));
        expect(tester.takeException(), isNull);
        await _pump(tester, const SizedBox(), mode);
      });

      testWidgets('skeleton stays still with reduced motion', (tester) async {
        await _pump(tester, const UiSkeleton.text(lines: 2), mode, reduceMotion: true);
        await tester.pumpAndSettle();
        expect(find.byType(UiSkeleton), findsOneWidget);
      });

      testWidgets('empty, error and success states', (tester) async {
        var retries = 0;
        await _pump(
          tester,
          ListView(
            children: [
              const UiEmptyState(title: 'No notes', message: 'Write one', action: Text('New note')),
              UiErrorState(message: 'Offline', onRetry: () => retries++),
              const UiSuccessState(title: 'Paid', compact: true),
            ],
          ),
          mode,
        );
        expect(find.text('No notes'), findsOneWidget);
        expect(find.text('New note'), findsOneWidget);
        expect(find.text('Something went wrong'), findsOneWidget);
        expect(find.text('Paid'), findsOneWidget);
        await tester.tap(find.text('Try again'));
        expect(retries, 1);
      });

      testWidgets('UiLoadingOverlay blocks taps while loading', (tester) async {
        var taps = 0;
        var loading = true;
        late StateSetter setOuter;
        await _pump(
          tester,
          StatefulBuilder(
            builder: (context, setState) {
              setOuter = setState;
              return UiLoadingOverlay(
                loading: loading,
                message: 'Saving',
                child: Center(
                  child: FilledButton(onPressed: () => taps++, child: const Text('Tap')),
                ),
              );
            },
          ),
          mode,
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(find.text('Saving'), findsOneWidget);
        expect(find.byType(UiSpinner), findsOneWidget);
        await tester.tap(find.text('Tap'), warnIfMissed: false);
        expect(taps, 0);

        setOuter(() => loading = false);
        await tester.pumpAndSettle();
        expect(find.text('Saving'), findsNothing);
        await tester.tap(find.text('Tap'));
        expect(taps, 1);
      });

      testWidgets('no overflow at 320 px', (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        const long = 'A very long message that keeps going and going so it has to wrap or ellipsize nicely';
        await _pump(
          tester,
          SingleChildScrollView(
            child: Column(
              children: [
                _trigger('go', (context) {
                  UiDialog.confirm(context, title: long, message: long, confirmLabel: 'Delete everything now');
                  context.showToast(long, title: long, actionLabel: 'Undo it', duration: null);
                }),
                const UiBanner(long, actionLabel: 'Reconnect now please', onAction: _noop, onDismiss: _noop),
                const UiAlert(long, title: long, onClose: _noop, action: Text('Action')),
                const UiProgressBar(0.5, label: long, showPercent: true),
                const SizedBox(
                  height: 300,
                  child: UiErrorState(title: long, message: long, onRetry: _noop),
                ),
              ],
            ),
          ),
          mode,
        );
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('go'));
        await tester.pumpAndSettle();
        expect(find.text('Delete everything now'), findsOneWidget);
        expect(find.text('Undo it'), findsOneWidget);
        expect(tester.takeException(), isNull);
        UiToast.dismissAll();
        await tester.pumpAndSettle();
      });
    });
  }

  testWidgets('UiSheet header scrolls away while the keyboard is open', (tester) async {
    tester.view.physicalSize = const Size(1080, 2160);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await _pump(
      tester,
      _trigger('go', (context) {
        UiSheet.show<void>(
          context,
          title: 'Add your birth details',
          subtitle: 'A long explanation that wraps over several lines on a phone, '
              'telling the user why the details are needed and where they are kept.',
          expand: true,
          child: Column(children: [
            const TextField(key: Key('name')),
            for (var i = 0; i < 8; i++) SizedBox(height: 60, child: Text('row $i')),
          ]),
        );
      }),
      ThemeMode.light,
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('name')));
    await tester.pump();
    final field = tester.state<EditableTextState>(find.byType(EditableText));
    expect(field.widget.focusNode.hasFocus, isTrue);

    // The keyboard opens and takes almost half the screen.
    tester.view.viewInsets = const FakeViewPadding(bottom: 960);
    await tester.pumpAndSettle();
    final viewport = tester.getSize(find.byType(SingleChildScrollView));
    expect(viewport.height, greaterThan(200), reason: 'the form keeps room to type');
    expect(tester.state<EditableTextState>(find.byType(EditableText)), same(field), reason: 'the field is not rebuilt');
    expect(field.widget.focusNode.hasFocus, isTrue);
    expect(find.text('Add your birth details'), findsOneWidget);

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pumpAndSettle();
    expect(field.widget.focusNode.hasFocus, isTrue);
    expect(tester.takeException(), isNull);
  });
}

void _noop() {}
