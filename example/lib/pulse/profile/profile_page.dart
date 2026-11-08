import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';

/// Account and settings. Appearance controls restyle the whole app live.
class PulseProfilePage extends StatefulWidget {
  const PulseProfilePage({super.key});

  @override
  State<PulseProfilePage> createState() => _PulseProfilePageState();
}

class _PulseProfilePageState extends State<PulseProfilePage> {
  static const _interestOptions = ['Running', 'Yoga', 'Strength', 'Cycling', 'Hiking', 'Cooking', 'Travel', 'Tech'];
  static const _units = ['Metric (kg, km)', 'Imperial (lb, mi)'];
  static const _currencies = ['USD', 'EUR', 'GBP'];
  static const _accentLabels = ['Primary', 'Secondary', 'Tertiary', 'Error'];

  bool _push = true;
  bool _email = false;
  bool _workoutReminders = true;
  bool _orderUpdates = true;
  List<String> _interests = ['Running', 'Yoga'];
  String? _unit = _units.first;
  String _currency = 'USD';
  DateTime? _birthday = DateTime(1994, 5, 12);
  List<String> _skills = ['Design', 'Coffee'];
  int _accent = 0;
  String _bio = 'Runner, maker, and coffee fan.';

  List<Color> _accentColors(ColorScheme cs) => [cs.primary, cs.secondary, cs.tertiary, cs.error];

  Future<void> _editProfile(Person me) async {
    final name = TextEditingController(text: me.name);
    final handle = TextEditingController(text: me.handle);
    final bio = TextEditingController(text: _bio);
    final saved = await UiSheet.show<bool>(
      context,
      title: 'Edit profile',
      child: Builder(
        builder: (c) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiTextField('Name', controller: name, prefixIcon: Icons.person_rounded),
            const UiGap.md(),
            UiTextField('Handle', controller: handle, prefixIcon: Icons.alternate_email_rounded),
            const UiGap.md(),
            UiTextField('Bio', controller: bio, maxLines: 3, minLines: 2),
            const UiGap.lg(),
            UiButton('Save', expand: true, onPressed: () => Navigator.pop(c, true)),
          ],
        ),
      ),
    );
    if (saved == true) {
      setState(() => _bio = bio.text.trim());
      if (mounted) context.showToast('Profile saved', status: UiStatus.success);
    }
    // Wait for the sheet's close animation before freeing the controllers.
    Future<void>.delayed(const Duration(milliseconds: 500), () {
      name.dispose();
      handle.dispose();
      bio.dispose();
    });
  }

  Future<void> _permissions() => UiSheet.show<void>(
        context,
        title: 'Permissions',
        child: Builder(
          builder: (c) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UiPermissionCard.notifications(
                onAllow: () => c.showToast('Notifications on', status: UiStatus.success),
                onDeny: () => Navigator.pop(c),
              ),
              const UiGap.md(),
              UiPermissionCard.camera(
                onAllow: () => c.showToast('Camera allowed', status: UiStatus.success),
                onDeny: () => Navigator.pop(c),
              ),
            ],
          ),
        ),
      );

  Future<void> _signOut() async {
    final ok = await UiDialog.confirm(
      context,
      title: 'Sign out?',
      message: 'You will need to log in again to use Pulse.',
      confirmLabel: 'Sign out',
      destructive: true,
      icon: Icons.logout_rounded,
    );
    if (!ok || !mounted) return;
    final store = PulseScope.read(context);
    Navigator.of(context).pop();
    store.signOut();
  }

  Widget _row(String title, Widget trailing) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
        child: Row(
          children: [
            Expanded(child: Text(title, style: context.text.bodyLarge)),
            trailing,
          ],
        ),
      );

  Widget _padded(Widget child) => Padding(padding: const EdgeInsets.all(UiSpace.lg), child: child);

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    final me = store.me;
    final accents = _accentColors(context.colors);
    return Scaffold(
      appBar: const UiAppBar(title: 'Profile'),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: UiSpace.lg),
        children: [
          UiMaxWidth(
            maxWidth: 720,
            child: Padding(
              padding: UiSpace.page,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UiAccountHeader(
                    name: me.name,
                    email: '@${me.handle}',
                    avatarUrl: me.avatar,
                    badge: me.verified ? 'Pro' : null,
                    onEdit: () => _editProfile(me),
                  ),
                  const UiGap.sm(),
                  Text(_bio, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                  const UiGap.xl(),
                  UiListGroup(
                    header: 'Appearance',
                    footer: 'Changes apply to the whole app right away.',
                    children: [
                      _row('Theme mode', const UiThemeModeSwitch()),
                      _padded(const UiBrandPicker(padding: EdgeInsets.zero)),
                    ],
                  ),
                  UiListGroup(
                    header: 'Notifications',
                    children: [
                      UiSwitchTile(
                        'Push notifications',
                        subtitle: 'Messages, likes, and follows',
                        leading: Icons.notifications_rounded,
                        value: _push,
                        onChanged: (v) => setState(() => _push = v),
                      ),
                      UiSwitchTile(
                        'Email updates',
                        subtitle: 'A short weekly summary',
                        leading: Icons.mail_rounded,
                        value: _email,
                        onChanged: (v) => setState(() => _email = v),
                      ),
                      UiSwitchTile(
                        'Workout reminders',
                        leading: Icons.fitness_center_rounded,
                        value: _workoutReminders,
                        onChanged: (v) => setState(() => _workoutReminders = v),
                      ),
                      UiSwitchTile(
                        'Order updates',
                        leading: Icons.local_shipping_rounded,
                        value: _orderUpdates,
                        onChanged: (v) => setState(() => _orderUpdates = v),
                      ),
                    ],
                  ),
                  UiListGroup(
                    header: 'Preferences',
                    children: [
                      _padded(
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            UiMultiSelectDropdown<String>(
                              label: 'Interests',
                              items: _interestOptions,
                              values: _interests,
                              max: 5,
                              prefixIcon: Icons.interests_rounded,
                              onChanged: (v) => setState(() => _interests = v),
                            ),
                            const UiGap.md(),
                            UiDropdown<String>(
                              label: 'Units',
                              items: _units,
                              value: _unit,
                              prefixIcon: Icons.straighten_rounded,
                              onChanged: (v) => setState(() => _unit = v),
                            ),
                            const UiGap.md(),
                            UiRadioGroup<String>(
                              label: 'Currency',
                              layout: UiRadioLayout.chips,
                              options: _currencies,
                              value: _currency,
                              onChanged: (v) => setState(() => _currency = v),
                            ),
                            const UiGap.md(),
                            UiDateField(
                              label: 'Birthday',
                              value: _birthday,
                              clearable: true,
                              lastDate: DateTime.now(),
                              onChanged: (v) => setState(() => _birthday = v),
                            ),
                            const UiGap.md(),
                            UiTagInput(label: 'Skills', tags: _skills, maxTags: 6, onChanged: (v) => setState(() => _skills = v)),
                            const UiGap.md(),
                            Text('Accent', style: context.text.labelLarge),
                            const UiGap.sm(),
                            UiColorSwatchPicker(
                              colors: accents,
                              value: accents[_accent],
                              labels: _accentLabels,
                              onChanged: (c) => setState(() => _accent = accents.indexOf(c).clamp(0, accents.length - 1)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  UiListGroup(
                    header: 'Account',
                    children: [
                      UiSettingsTile.nav(icon: Icons.edit_rounded, title: 'Edit profile', onTap: () => _editProfile(me)),
                      UiSettingsTile.nav(icon: Icons.privacy_tip_rounded, title: 'Permissions', subtitle: 'Notifications and camera', onTap: _permissions),
                      UiSettingsTile.value(icon: Icons.account_balance_wallet_rounded, title: 'Balance', value: money(store.balance)),
                      UiSettingsTile.nav(
                        icon: Icons.workspace_premium_rounded,
                        title: 'Go Premium',
                        value: 'Save 33%',
                        onTap: () => pulsePush(context, const PulsePremiumPage(), fullscreen: true),
                      ),
                    ],
                  ),
                  UiListGroup(
                    children: [
                      UiSettingsTile.action(icon: Icons.logout_rounded, title: 'Sign out', onTap: _signOut),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-screen paywall pushed from the profile page.
class PulsePremiumPage extends StatelessWidget {
  const PulsePremiumPage({super.key});

  static const _plans = [
    UiPlan(name: 'Monthly', price: '\$6.99', period: '/month'),
    UiPlan(name: 'Yearly', price: '\$55.99', period: '/year', badge: 'Save 33%', note: '\$4.67 per month'),
    UiPlan(name: 'Lifetime', price: '\$149', note: 'Pay once', features: ['All future updates']),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: UiMaxWidth(
          maxWidth: 560,
          child: UiPaywall(
            title: 'Pulse Premium',
            subtitle: 'Train smarter and shop for less',
            features: const ['All coach workouts', 'Free shipping on every order', 'No ads', 'Money insights in Wallet'],
            plans: _plans,
            initialPlan: 1,
            footnote: 'Cancel at any time. This is a demo, you will not be charged.',
            onSubscribe: (i) async {
              await Future<void>.delayed(const Duration(milliseconds: 900));
              if (!context.mounted) return null;
              context.showToast('Welcome to Premium', status: UiStatus.success, icon: Icons.workspace_premium_rounded);
              Navigator.of(context).pop();
              return null;
            },
            onRestore: () => context.showToast('Nothing to restore'),
            onTerms: () => context.showToast('Terms of use'),
            onPrivacy: () => context.showToast('Privacy policy'),
            onClose: () => Navigator.of(context).maybePop(),
          ),
        ),
      ),
    );
  }
}
