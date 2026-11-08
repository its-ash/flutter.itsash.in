import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';

/// First run: three intro pages. Done or skip moves the store to the sign-in stage.
class PulseOnboarding extends StatelessWidget {
  const PulseOnboarding({super.key});

  static final _pages = [
    UiOnboardingPage(
      image: PulseAssets.content('run'),
      title: 'Move every day',
      body: 'Follow short workouts from real coaches and track your progress.',
    ),
    UiOnboardingPage(
      image: PulseAssets.content('hero1'),
      title: 'Shop what you love',
      body: 'Find gear, clothes, and treats from the best brands in one place.',
    ),
    UiOnboardingPage(
      image: PulseAssets.content('post2'),
      title: 'Save and share',
      body: 'Keep an eye on your money and share wins with your friends.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    void done() => PulseScope.read(context).finishOnboarding();
    return Scaffold(
      body: SafeArea(child: UiOnboarding(pages: _pages, onDone: done, onSkip: done)),
    );
  }
}

enum _AuthMode { signIn, signUp, forgot, verify, pin }

/// Sign in, sign up, reset password, verify code, and PIN unlock in one card.
class PulseAuthScreen extends StatefulWidget {
  const PulseAuthScreen({super.key});

  @override
  State<PulseAuthScreen> createState() => _PulseAuthScreenState();
}

class _PulseAuthScreenState extends State<PulseAuthScreen> {
  static const _demoPassword = 'password1';
  static const _demoCode = '123456';
  static const _demoPin = '1234';

  _AuthMode _mode = _AuthMode.signIn;
  bool _remember = true;
  String _email = 'ana@pulse.app';
  UiSocialProvider? _socialBusy;

  void _go(_AuthMode m) => setState(() => _mode = m);

  /// Fake network delay.
  Future<void> _wait() => Future<void>.delayed(const Duration(milliseconds: 800));

  /// Swap to the app after the form finishes its own state update.
  void _signIn() => Future.microtask(() {
        if (mounted) PulseScope.read(context).signIn();
      });

  Future<String?> _login(String email, String password) async {
    await _wait();
    if (password != _demoPassword) return 'Email or password is not correct';
    _signIn();
    return null;
  }

  Future<String?> _signUp(String name, String email, String password) async {
    await _wait();
    if (mounted) {
      setState(() {
        _email = email;
        _mode = _AuthMode.verify;
      });
    }
    return null;
  }

  Future<String?> _verify(String code) async {
    await _wait();
    if (code != _demoCode) return 'Code is not correct';
    _signIn();
    return null;
  }

  Future<void> _social(UiSocialProvider p) async {
    setState(() => _socialBusy = p);
    await _wait();
    if (!mounted) return;
    setState(() => _socialBusy = null);
    PulseScope.read(context).signIn();
  }

  Widget _hint(String text) => Padding(
        padding: const EdgeInsets.only(bottom: UiSpace.lg),
        child: UiBanner(text, status: UiStatus.info),
      );

  Widget _socialButtons() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const UiDividerText(text: 'or continue with'),
          for (final p in [UiSocialProvider.google, UiSocialProvider.apple]) ...[
            UiSocialButton(
              p,
              loading: _socialBusy == p,
              onPressed: _socialBusy == null ? () => _social(p) : null,
            ),
            const UiGap.sm(),
          ],
          UiAuthLink('Use PIN instead', onTap: () => _go(_AuthMode.pin)),
        ],
      );

  Widget _body() => switch (_mode) {
        _AuthMode.signIn => Column(
            key: const ValueKey('signIn'),
            mainAxisSize: MainAxisSize.min,
            children: [
              const UiAuthHeader(title: 'Welcome back', subtitle: 'Log in to Pulse to continue', icon: Icons.favorite_rounded),
              const UiGap.xl(),
              _hint('Demo: use any email and the password "$_demoPassword".'),
              UiLoginForm(
                initialEmail: _email,
                rememberMe: _remember,
                onRememberMeChanged: (v) => setState(() => _remember = v),
                onSubmit: _login,
                onForgotPassword: () => _go(_AuthMode.forgot),
                onSignUp: () => _go(_AuthMode.signUp),
                footer: _socialButtons(),
              ),
            ],
          ),
        _AuthMode.signUp => Column(
            key: const ValueKey('signUp'),
            mainAxisSize: MainAxisSize.min,
            children: [
              const UiAuthHeader(title: 'Create your account', subtitle: 'Join Pulse in less than a minute', icon: Icons.person_add_rounded),
              const UiGap.xl(),
              UiSignupForm(
                onSubmit: _signUp,
                onLogIn: () => _go(_AuthMode.signIn),
                onTermsTap: () => context.showToast('Terms of use'),
                onPrivacyTap: () => context.showToast('Privacy policy'),
              ),
            ],
          ),
        _AuthMode.forgot => UiForgotPasswordForm(
            key: const ValueKey('forgot'),
            initialEmail: _email,
            resendSeconds: 15,
            onSubmit: (email) async {
              await _wait();
              return null;
            },
            onBack: () => _go(_AuthMode.signIn),
          ),
        _AuthMode.verify => Column(
            key: const ValueKey('verify'),
            mainAxisSize: MainAxisSize.min,
            children: [
              _hint('Demo: the code is $_demoCode.'),
              UiVerifyCodeForm(
                destination: _email,
                resendSeconds: 15,
                onSubmit: _verify,
                onResend: () async {
                  await _wait();
                  if (mounted) context.showToast('We sent a new code', status: UiStatus.success);
                },
              ),
              const UiGap.md(),
              UiAuthPrompt(text: 'Wrong email?', action: 'Go back', onTap: () => _go(_AuthMode.signUp)),
            ],
          ),
        _AuthMode.pin => Column(
            key: const ValueKey('pin'),
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 560,
                child: UiLockScreen(
                  name: PulseScope.of(context).me.name,
                  avatarUrl: PulseScope.of(context).me.avatar,
                  greeting: 'Welcome back',
                  subtitle: 'Demo PIN is $_demoPin',
                  onCompleted: (pin) async {
                    final ok = pin == _demoPin;
                    if (ok) _signIn();
                    return ok;
                  },
                  onBiometric: () => _social(UiSocialProvider.apple),
                  onForgot: () => _go(_AuthMode.forgot),
                ),
              ),
              UiAuthPrompt(text: 'Prefer a password?', action: 'Log in', onTap: () => _go(_AuthMode.signIn)),
            ],
          ),
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UiSpace.lg),
            child: UiMaxWidth(
              maxWidth: 460,
              child: UiCard(
                variant: UiCardVariant.outlined,
                padding: const EdgeInsets.all(UiSpace.xl),
                child: AnimatedSize(
                  duration: UiDuration.normal,
                  curve: UiCurve.standard,
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(duration: UiDuration.normal, child: _body()),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
