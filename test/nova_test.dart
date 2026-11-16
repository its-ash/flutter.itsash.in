import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/theme.dart';

import 'display_test.dart' show pumpUi;

void main() {
  for (final mode in [ThemeMode.light, ThemeMode.dark]) {
    group('${mode.name} mode', () {
      testWidgets('UiPromoCard action and tap', (tester) async {
        var actions = 0;
        var taps = 0;
        await pumpUi(
          tester,
          UiPromoCard(
            title: 'Step into style',
            message: 'A long message that should wrap onto more than one line without overflowing anything.',
            actionLabel: 'Show more',
            onAction: () => actions++,
            onTap: () => taps++,
            image: const Icon(Icons.star, size: 64),
          ),
          mode: mode,
          width: 320,
        );
        await tester.tap(find.text('Show more'));
        await tester.tap(find.text('Step into style'));
        expect(actions, 1);
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      });

      testWidgets('UiPromoBanner shows the action only when tappable', (tester) async {
        var taps = 0;
        await pumpUi(
          tester,
          Column(
            children: [
              UiPromoBanner(
                title: 'Free shipping',
                subtitle: 'On orders over 50',
                icon: Icons.local_shipping,
                onTap: () => taps++,
              ),
              const UiPromoBanner(title: 'Static'),
            ],
          ),
          mode: mode,
          width: 320,
        );
        expect(find.byIcon(Icons.keyboard_double_arrow_right_rounded), findsOneWidget);
        await tester.tap(find.text('Free shipping'));
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      });

      testWidgets('UiMediaCard renders badge and taps', (tester) async {
        var taps = 0;
        await pumpUi(
          tester,
          SizedBox(
            width: 150,
            child: UiMediaCard(
              title: 'A very long product name that ellipsizes',
              subtitle: '\$80',
              badge: '23%',
              tint: Colors.blue,
              image: const Icon(Icons.checkroom, size: 48),
              onTap: () => taps++,
            ),
          ),
          mode: mode,
        );
        expect(find.text('23%'), findsOneWidget);
        await tester.tap(find.byIcon(Icons.checkroom));
        expect(taps, 1);
        expect(tester.takeException(), isNull);
      });

      testWidgets('UiOptionTiles selects and skips disabled', (tester) async {
        int? value = 8;
        await pumpUi(
          tester,
          StatefulBuilder(
            builder: (context, setState) => UiOptionTiles<int>(
              options: [for (var i = 7; i <= 12; i++) UiChoice(i, '$i', enabled: i != 10)],
              value: value,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
          mode: mode,
        );
        await tester.tap(find.text('9'));
        await tester.pumpAndSettle();
        expect(value, 9);
        await tester.tap(find.text('10'));
        await tester.pumpAndSettle();
        expect(value, 9);
        expect(
          tester.getSize(find.ancestor(of: find.text('7'), matching: find.byType(AnimatedContainer)).first).height,
          48,
        );
        expect(tester.takeException(), isNull);
      });
    });
  }
}
