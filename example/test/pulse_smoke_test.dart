import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theme/theme.dart';
import 'package:theme_example/pulse/auth/pulse_auth.dart';
import 'package:theme_example/pulse/fitness/workout_page.dart';
import 'package:theme_example/pulse/home/notifications_page.dart';
import 'package:theme_example/pulse/profile/profile_page.dart';
import 'package:theme_example/pulse/pulse_app.dart';
import 'package:theme_example/pulse/pulse_data.dart';
import 'package:theme_example/pulse/shop/cart_page.dart';
import 'package:theme_example/pulse/shop/checkout_page.dart';
import 'package:theme_example/pulse/shop/product_page.dart';
import 'package:theme_example/pulse/social/chat_page.dart';
import 'package:theme_example/pulse/social/profile_view_page.dart';
import 'package:theme_example/pulse/wallet/transfer_page.dart';

/// Renders every Pulse screen at a phone size and a desktop size and fails on any
/// Flutter error (overflow, bad constraints, exceptions in build).
/// Uses a plain ThemeData so the test never fetches Google Fonts.
void main() {
  late PulseData data;
  final errors = <String>[];

  setUp(() {
    errors.clear();
    FlutterError.onError = (d) {
      final msg = d.exceptionAsString();
      // video_player has no platform plugin in widget tests; the player shows its error view instead.
      if (msg.contains('MissingPluginException') || msg.contains('video_player')) return;
      errors.add('${d.exceptionAsString()}\n${d.context?.toDescription() ?? ''}');
    };
  });

  Future<void> show(WidgetTester t, Widget page, Size size, {PulseStage stage = PulseStage.app}) async {
    t.view.physicalSize = size;
    t.view.devicePixelRatio = 1;
    final store = PulseStore(data);
    if (stage == PulseStage.app) store.signIn();
    if (stage == PulseStage.auth) store.finishOnboarding();
    await t.pumpWidget(PulseScope(
      store: store,
      child: MaterialApp(theme: ThemeData(useMaterial3: true), home: UiThemeScope(controller: UiThemeController(), child: page)),
    ));
    for (var i = 0; i < 8; i++) {
      await t.pump(const Duration(milliseconds: 400));
    }
    await t.pumpWidget(const SizedBox());
    await t.pump(const Duration(seconds: 5));
  }

  testWidgets('loads asset data', (t) async {
    data = (await t.runAsync(PulseData.load))!;
    expect(data.products, hasLength(16));
    expect(data.people, hasLength(6));
    expect(data.posts.where((p) => p.video != null), isNotEmpty);
    expect(data.workouts, isNotEmpty);
  });

  for (final size in const [Size(400, 860), Size(1300, 900)]) {
    final tag = '${size.width.toInt()}w';

    testWidgets('shell tabs render [$tag]', (t) async {
      final store = PulseStore(data)..signIn();
      t.view.physicalSize = size;
      t.view.devicePixelRatio = 1;
      await t.pumpWidget(PulseScope(store: store, child: MaterialApp(theme: ThemeData(useMaterial3: true), home: const PulseShell())));
      for (final label in ['Home', 'Shop', 'Fitness', 'Wallet', 'Social']) {
        await t.tap(find.text(label).last);
        for (var i = 0; i < 6; i++) {
          await t.pump(const Duration(milliseconds: 400));
        }
        expect(errors, isEmpty, reason: '$label tab:\n${errors.join('\n---\n')}');
      }
      await t.pumpWidget(const SizedBox());
      await t.pump(const Duration(seconds: 5));
    });

    final pages = <String, Widget Function()>{
      'onboarding': () => const PulseOnboarding(),
      'auth': () => const PulseAuthScreen(),
      'notifications': () => const PulseNotificationsPage(),
      'product': () => PulseProductPage(product: data.products[2]),
      'cart': () => const PulseCartPage(),
      'checkout': () => const PulseCheckoutPage(),
      'workout': () => PulseWorkoutPage(workout: data.workouts[2]),
      'transfer': () => const PulseTransferPage(),
      'chat': () => PulseChatPage(person: data.people[1]),
      'profile view': () => PulseProfileViewPage(person: data.people[3]),
      'profile': () => const PulseProfilePage(),
      'premium': () => const PulsePremiumPage(),
    };
    for (final e in pages.entries) {
      testWidgets('${e.key} renders [$tag]', (t) async {
        await show(t, e.value(), size);
        expect(errors, isEmpty, reason: errors.join('\n---\n'));
      });
    }
  }
}
