import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../demos/demo_route.dart';
import '../widgets/demo_block.dart';

const onboardingPages = [
  UiOnboardingPage(icon: Icons.shopping_bag_rounded, title: 'Shop anything', body: 'Find the best brands in one place.'),
  UiOnboardingPage(icon: Icons.local_shipping_rounded, title: 'Fast delivery', body: 'Get your order in two days or less.'),
  UiOnboardingPage(icon: Icons.verified_user_rounded, title: 'Pay safely', body: 'Your payments are protected end to end.'),
];

const paywallPlans = [
  UiPlan(name: 'Monthly', price: '\$4.99', period: '/month'),
  UiPlan(name: 'Yearly', price: '\$39.99', period: '/year', badge: 'Save 33%', note: '\$3.33 per month'),
  UiPlan(name: 'Lifetime', price: '\$99', note: 'Pay once', features: ['All future updates']),
];

typedef AuthFlow = ({String label, IconData icon, Widget Function(BuildContext) build});

Future<String?> _wait(String? result) => Future.delayed(const Duration(milliseconds: 900), () => result);

final List<AuthFlow> authFlows = [
  (
    label: 'Onboarding',
    icon: Icons.slideshow_rounded,
    build: (c) => UiOnboarding(pages: onboardingPages, onDone: () => Navigator.maybePop(c)),
  ),
  (
    label: 'Paywall',
    icon: Icons.workspace_premium_rounded,
    build: (c) => Scaffold(
          body: SafeArea(
            child: UiPaywall(
              title: 'Go Premium',
              subtitle: 'Unlock all features',
              features: const ['No ads', 'Unlimited storage', 'Priority support', 'Offline mode'],
              plans: paywallPlans,
              initialPlan: 1,
              onSubscribe: (i) => _wait(i == 2 ? 'Store not available. Try again.' : null),
              onRestore: () => c.showToast('Nothing to restore'),
              onTerms: () {},
              onPrivacy: () {},
              onClose: () => Navigator.maybePop(c),
              footnote: 'Cancel at any time.',
            ),
          ),
        ),
  ),
  (
    label: 'Lock screen',
    icon: Icons.pin_rounded,
    build: (c) => Scaffold(
          appBar: const UiAppBar(),
          body: SafeArea(
            child: UiLockScreen(
              name: 'Ana Lopez',
              avatarUrl: pic('ana', 300, 300),
              subtitle: 'PIN is 1234',
              onCompleted: (pin) async => pin == '1234',
              onBiometric: () => c.showToast('Face ID'),
              onForgot: () => c.showToast('Reset PIN'),
            ),
          ),
        ),
  ),
  (
    label: 'Splash',
    icon: Icons.auto_awesome_rounded,
    build: (c) => GestureDetector(
          onTap: () => Navigator.maybePop(c),
          child: const UiSplash(name: 'Snapp', tagline: 'Share the moment', gradient: true, icon: Icons.camera_rounded),
        ),
  ),
  for (final t in UiErrorPageType.values)
    (
      label: 'Error: ${t.name}',
      icon: Icons.error_outline_rounded,
      build: (c) => Scaffold(
            appBar: const UiAppBar(),
            body: UiErrorPage(
              type: t,
              onAction: () => c.showToast('Retry'),
              secondaryLabel: 'Go home',
              onSecondary: () => Navigator.maybePop(c),
            ),
          ),
    ),
];

class AuthSection extends StatefulWidget {
  const AuthSection({super.key});

  @override
  State<AuthSection> createState() => _AuthSectionState();
}

class _AuthSectionState extends State<AuthSection> {
  int _plan = 1;
  bool _remember = true;
  final _validated = TextEditingController();

  @override
  void dispose() {
    _validated.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void tap() => toast(context, 'Tapped');
    Widget boxed(Widget child) => UiCard(
          variant: UiCardVariant.outlined,
          padding: const EdgeInsets.all(UiSpace.xl),
          child: UiMaxWidth(maxWidth: 440, child: child),
        );
    return SectionPage(
      children: [
        DemoBlock(
          'Full-screen flows',
          subtitle: 'Each opens with Navigator.push',
          child: WrapRow(
            children: [
              for (final f in authFlows)
                UiButton.tonal(f.label, icon: f.icon, size: UiSize.sm, onPressed: () => pushPage(context, Builder(builder: f.build), fullscreen: true)),
            ],
          ),
        ),
        const DemoBlock(
          'UiAuthHeader',
          child: Column(
            children: [
              UiAuthHeader(title: 'Welcome back', subtitle: 'Log in to continue'),
              UiGap.lg(),
              UiAuthHeader(title: 'Left aligned', subtitle: 'With a custom icon', icon: Icons.rocket_launch_rounded, center: false),
            ],
          ),
        ),
        DemoBlock(
          'UiLoginForm',
          subtitle: 'Use any email and the password "password1"',
          child: boxed(
            UiLoginForm(
              rememberMe: _remember,
              onRememberMeChanged: (v) => setState(() => _remember = v),
              onSubmit: (email, password) => _wait(password == 'password1' ? null : 'Email or password is not correct'),
              onForgotPassword: tap,
              onSignUp: tap,
              footer: Column(
                children: [
                  const UiDividerText(),
                  UiSocialButton(UiSocialProvider.google, onPressed: tap),
                  const UiGap.sm(),
                  UiSocialButton(UiSocialProvider.apple, onPressed: tap),
                ],
              ),
            ),
          ),
        ),
        DemoBlock(
          'UiSignupForm',
          child: boxed(UiSignupForm(onSubmit: (name, email, password) => _wait(null), onLogIn: tap, onTermsTap: tap, onPrivacyTap: tap)),
        ),
        DemoBlock(
          'UiForgotPasswordForm',
          child: boxed(UiForgotPasswordForm(onSubmit: (email) => _wait(null), onBack: tap, resendSeconds: 15)),
        ),
        DemoBlock(
          'UiVerifyCodeForm',
          subtitle: 'Code is 123456',
          child: boxed(
            UiVerifyCodeForm(
              destination: 'ana@mail.com',
              onSubmit: (code) => _wait(code == '123456' ? null : 'Code is not correct'),
              onResend: () => _wait(null),
            ),
          ),
        ),
        DemoBlock(
          'UiAuthValidators',
          subtitle: 'Used with UiTextField',
          child: Form(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                UiTextField('Email', controller: _validated, validator: UiAuthValidators.email),
                const UiGap.sm(),
                UiTextField('Name', validator: UiAuthValidators.name),
                const UiGap.sm(),
                UiPasswordField(validator: UiAuthValidators.password(min: 10)),
              ],
            ),
          ),
        ),
        DemoBlock(
          'UiAuthPrompt and UiAuthLink',
          child: Column(
            children: [
              UiAuthPrompt(text: "Don't have an account?", action: 'Sign up', onTap: tap),
              UiAuthLink('Forgot password?', onTap: tap),
            ],
          ),
        ),
        DemoBlock(
          'UiPinPad',
          subtitle: 'PIN is 2468',
          child: Center(
            child: UiPinPad(
              onCompleted: (pin) async => pin == '2468',
              onBiometric: () => toast(context, 'Fingerprint'),
              keySize: 64,
            ),
          ),
        ),
        DemoBlock(
          'UiPermissionCard',
          child: Column(
            children: [
              UiPermissionCard.camera(onAllow: tap, onDeny: tap),
              const UiGap.sm(),
              UiPermissionCard.location(onAllow: tap),
              const UiGap.sm(),
              UiPermissionCard.notifications(onAllow: tap, onDeny: tap),
              const UiGap.sm(),
              UiPermissionCard(icon: Icons.mic_rounded, title: 'Allow microphone', reason: 'Record voice notes.', onAllow: tap),
            ],
          ),
        ),
        DemoBlock(
          'UiPlanCard',
          child: Column(
            children: [
              for (final (i, p) in paywallPlans.indexed) ...[
                UiPlanCard.plan(p, selected: _plan == i, onTap: () => setState(() => _plan = i)),
                const UiGap.sm(),
              ],
              UiPlanCard(
                name: 'Team',
                price: '\$12',
                period: '/user/month',
                badge: 'Most popular',
                features: const ['Shared workspaces', 'Admin tools', 'SSO'],
                selected: _plan == 3,
                onTap: () => setState(() => _plan = 3),
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiAccountHeader',
          child: UiAccountHeader(name: 'Ana Lopez', email: 'ana@mail.com', avatarUrl: pic('ana', 200, 200), badge: 'Pro', onEdit: tap, onTap: tap),
        ),
      ],
    );
  }
}
