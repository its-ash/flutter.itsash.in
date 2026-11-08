import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'auth/pulse_auth.dart';
import 'fitness/fitness_tab.dart';
import 'home/home_tab.dart';
import 'home/notifications_page.dart';
import 'profile/profile_page.dart';
import 'pulse_data.dart';
import 'shop/cart_page.dart';
import 'shop/shop_tab.dart';
import 'social/social_tab.dart';
import 'wallet/wallet_tab.dart';

/// Standalone entry: `flutter run -t lib/main_pulse.dart`.
class PulseApp extends StatefulWidget {
  const PulseApp({super.key});

  @override
  State<PulseApp> createState() => _PulseAppState();
}

class _PulseAppState extends State<PulseApp> {
  final _theme = UiThemeController(brand: UiBrand.fitness);

  @override
  void dispose() {
    _theme.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => UiApp(controller: _theme, title: 'Pulse', home: const PulseDemo());
}

/// The whole Pulse app. Also opened from the showcase "App demos" section.
/// Flow: splash (loads assets/data) -> onboarding -> sign in -> tabs.
class PulseDemo extends StatefulWidget {
  const PulseDemo({super.key});

  @override
  State<PulseDemo> createState() => _PulseDemoState();
}

class _PulseDemoState extends State<PulseDemo> {
  PulseStore? _store;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final results = await Future.wait([PulseData.load(), Future<void>.delayed(const Duration(milliseconds: 1200))]);
      if (!mounted) return;
      setState(() => _store = PulseStore(results.first as PulseData));
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _store?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = _store;
    if (_error != null) {
      return UiErrorPage(title: 'Could not load the demo data', message: '$_error', onAction: _load);
    }
    if (store == null) {
      return const UiSplash(name: 'Pulse', tagline: 'Move, shop, save, share', icon: Icons.favorite_rounded, gradient: true);
    }
    return PulseScope(
      store: store,
      child: ListenableBuilder(
        listenable: store,
        builder: (context, _) => AnimatedSwitcher(
          duration: UiDuration.slow,
          child: switch (store.stage) {
            PulseStage.onboarding => const PulseOnboarding(key: ValueKey('onboarding')),
            PulseStage.auth => const PulseAuthScreen(key: ValueKey('auth')),
            PulseStage.app => const PulseShell(key: ValueKey('app')),
          },
        ),
      ),
    );
  }
}

class PulseShell extends StatelessWidget {
  const PulseShell({super.key});

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    return UiAdaptiveShell(
      header: UiAvatar(name: store.me.name, imageUrl: store.me.avatar, size: 40, onTap: () => pulsePush(context, const PulseProfilePage())),
      appBar: UiAppBar(
        title: 'Pulse',
        showBack: false,
        actions: [
          UiIconButton(
            Icons.notifications_none_rounded,
            tooltip: 'Notifications',
            badge: '3',
            variant: UiIconButtonVariant.plain,
            onPressed: () => pulsePush(context, const PulseNotificationsPage()),
          ),
          const UiGap.xs(),
          UiCartIconButton(count: store.cartCount, onPressed: () => pulsePush(context, const PulseCartPage())),
          const UiGap.sm(),
          Padding(
            padding: const EdgeInsets.only(right: UiSpace.md),
            child: UiAvatar(
              name: store.me.name,
              imageUrl: store.me.avatar,
              size: 36,
              onTap: () => pulsePush(context, const PulseProfilePage()),
            ),
          ),
        ],
      ),
      destinations: const [
        UiNavItem(icon: Icons.home_outlined, selectedIcon: Icons.home_rounded, label: 'Home'),
        UiNavItem(icon: Icons.storefront_outlined, selectedIcon: Icons.storefront_rounded, label: 'Shop'),
        UiNavItem(icon: Icons.fitness_center_outlined, selectedIcon: Icons.fitness_center_rounded, label: 'Fitness'),
        UiNavItem(icon: Icons.account_balance_wallet_outlined, selectedIcon: Icons.account_balance_wallet_rounded, label: 'Wallet'),
        UiNavItem(icon: Icons.forum_outlined, selectedIcon: Icons.forum_rounded, label: 'Social', badge: ''),
      ],
      pages: const [PulseHomeTab(), PulseShopTab(), PulseFitnessTab(), PulseWalletTab(), PulseSocialTab()],
    );
  }
}
