# Auth and onboarding

Screens and forms for sign in, sign up, PIN lock, permissions, and subscriptions. Async callbacks return an error message, or `null` for success. If a callback throws, the widget shows "Something went wrong. Try again."

### UiAuthHeader
Logo in a tonal rounded square, then a title and a subtitle.

```dart
const UiAuthHeader(title: 'Welcome back', subtitle: 'Log in to continue')
```
- `title`, `subtitle`, `logo` (widget), `icon` (used when `logo` is `null`), `center` (default `true`).

### UiLoginForm
Email and password form with validation, loading state, and an error banner.

```dart
UiLoginForm(
  onSubmit: (email, password) async {
    final ok = await auth.signIn(email, password);
    return ok ? null : 'Email or password is not correct';
  },
  onForgotPassword: () => go('/forgot'),
  onSignUp: () => go('/signup'),
  onRememberMeChanged: (v) => prefs.remember = v,
  footer: Column(children: [
    const UiDividerText(),
    UiSocialButton(UiSocialProvider.google, onPressed: google),
  ]),
)
```
- `onSubmit` (required, `Future<String?> Function(String email, String password)`). The email is trimmed.
- `onForgotPassword`, `onSignUp`, `onRememberMeChanged` (shows the checkbox), `rememberMe`.
- `initialEmail`, `footer`, `submitLabel` ('Log in'), `minPasswordLength` (8).
- Uses `UiTextField.email` and `UiPasswordField` from controls. The fields use autofill hints. The password field has a show/hide button.
- The error message shows in a `UiBanner` with `UiStatus.danger`.

### UiSignupForm
Name, email, password, confirm password, and a required terms checkbox. Uses `UiTextField.name`, `UiTextField.email`, and `UiPasswordField`. The password field shows the `UiPasswordField` strength bar.

```dart
UiSignupForm(
  onSubmit: (name, email, password) => auth.signUp(name, email, password),
  onLogIn: () => go('/login'),
  onTermsTap: openTerms,
  onPrivacyTap: openPrivacy,
)
```
- `onSubmit` (required), `onLogIn`, `onTermsTap`, `onPrivacyTap`, `footer`.
- `submitLabel` ('Create account'), `minPasswordLength` (8), `showStrength` (`true`).

### UiForgotPasswordForm
Email form. After success it shows "Check your email" with a resend timer.

```dart
UiForgotPasswordForm(
  onSubmit: (email) => auth.sendReset(email),
  onBack: () => Navigator.pop(context),
)
```
- `onSubmit` (required), `onBack`, `initialEmail`, `resendSeconds` (30), `showHeader` (`true`).

### UiVerifyCodeForm
Uses `UiOtpField`. It submits when all digits are entered. It supports paste and SMS autofill.

```dart
UiVerifyCodeForm(
  destination: 'ana@mail.com',
  onSubmit: (code) => auth.verify(code),
  onResend: () => auth.resend(),
)
```
- `onSubmit` (required), `length` (6, range 4 to 8), `destination`, `onResend`, `resendSeconds` (30), `showHeader`.

### UiAuthValidators
Validators for forms. Use them with `UiTextField` and `UiPasswordField`.
- `email(String?)`, `isEmail(String)`, `password({min = 8, max = 128})`, `name(String?)`.
- For password strength, use `UiPasswordField.strengthOf` (controls).

### UiAuthPrompt / UiAuthLink
Small parts for auth screens.

```dart
UiAuthPrompt(text: "Don't have an account?", action: 'Sign up', onTap: signUp)
UiAuthLink('Forgot password?', onTap: forgot)
```

For other parts, use the shared widgets:
- Social sign-in: `UiSocialButton` (controls).
- "or" divider: `UiDividerText` (layout).
- Status message: `UiBanner` (feedback).

### UiPinPad
Number keypad with PIN dots. The dots shake when the PIN is wrong. It also accepts keyboard digits and Backspace.

```dart
UiPinPad(
  length: 4,
  onCompleted: (pin) => vault.check(pin),
  onBiometric: unlockWithFace,
)
```
- `onCompleted` (required, `Future<bool> Function(String pin)`). Return `false` to shake and clear.
- `length` (4, range 4 to 8), `onBiometric` (shows the key), `biometricIcon`, `errorText`, `keySize` (72).
- Long-press the delete key to clear all digits.

### UiLockScreen
Avatar, greeting, and a `UiPinPad`.

```dart
UiLockScreen(name: 'Ana Lopez', avatarUrl: me, onCompleted: vault.check, onForgot: resetPin)
```
- `onCompleted` (required), `name`, `avatarUrl`, `greeting`, `subtitle`, `length`, `onBiometric`, `onForgot`, `forgotLabel`.

### UiOnboarding / UiOnboardingPage
Swipe pages with stretching dots, Skip, and Next. The last page shows "Get started". On wide screens the visual and the text are side by side.

```dart
UiOnboarding(
  pages: const [
    UiOnboardingPage(icon: Icons.chat_rounded, title: 'Chat', body: 'Talk with friends.'),
    UiOnboardingPage(image: 'assets/share.png', title: 'Share', body: 'Post photos.'),
  ],
  onDone: () => go('/login'),
)
```
- `UiOnboardingPage({title, body, image, icon, visual})`. `visual` wins, then `image`, then `icon`.
- `pages`, `onDone` (required), `onSkip` (default `onDone`), `skipLabel`, `nextLabel`, `doneLabel`.

The dots are `UiPageDots` (navigation). They follow the page controller.

### UiPermissionCard
Asks for a permission and tells the user why.

```dart
UiPermissionCard.camera(onAllow: request, onDeny: skip)
UiPermissionCard(icon: Icons.mic_rounded, title: 'Allow microphone', reason: 'Record voice notes.', onAllow: request)
```
- Presets: `.camera`, `.location`, `.notifications`.
- `icon`, `title`, `reason`, `onAllow`, `onDeny` (shows "Not now"), `allowLabel`, `denyLabel`.

### UiPlanCard / UiPlan
Subscription plan card with features, a badge, and a selected state.

```dart
UiPlanCard(name: 'Yearly', price: '\$49.99', period: '/year', badge: 'Most popular', selected: true, onTap: pick)
UiPlanCard.plan(plan, selected: true, onTap: pick)
```
- `UiPlan({name, price, period, note, features, badge})`.
- `name`, `price`, `period`, `note`, `features`, `badge`, `selected`, `onTap`.

### UiPaywall
Full-screen subscription page: header, feature list, plan cards, CTA, and links.

```dart
UiPaywall(
  title: 'Go Premium',
  subtitle: 'Unlock all features',
  features: const ['No ads', 'Unlimited storage', 'Priority support'],
  plans: const [
    UiPlan(name: 'Monthly', price: '\$4.99', period: '/month'),
    UiPlan(name: 'Yearly', price: '\$39.99', period: '/year', badge: 'Save 33%', note: '\$3.33 per month'),
  ],
  initialPlan: 1,
  onSubscribe: (i) => store.buy(i),
  onRestore: store.restore,
  onTerms: openTerms,
  onPrivacy: openPrivacy,
  onClose: () => Navigator.pop(context),
  footnote: 'Cancel at any time.',
)
```
- `plans`, `onSubscribe` (required, `Future<String?> Function(int index)`).
- `title`, `subtitle`, `icon`, `header`, `features`, `initialPlan`, `ctaLabel`, `footnote`, `onRestore`, `onTerms`, `onPrivacy`, `onClose`.
- Use it as a full-screen body. It needs a bounded height.

### UiSplash
Centered logo, app name, and a small loader. The logo fades and scales in.

```dart
const UiSplash(name: 'Snapp', tagline: 'Share the moment', gradient: true)
```
- `logo`, `icon`, `name`, `tagline`, `loading` (`true`), `gradient` (`false`).

### UiErrorPage / UiErrorPageType
Full error state with a default icon and text for each type.

```dart
UiErrorPage(type: UiErrorPageType.offline, onAction: retry)
```
- Types: `notFound` (404), `server` (500), `offline`, `maintenance`, `forbidden` (403), `generic`.
- `title`, `message`, `icon`, `actionLabel`, `onAction`, `secondaryLabel`, `onSecondary`.

### UiAccountHeader
Account card for settings and profile screens.

```dart
UiAccountHeader(name: 'Ana Lopez', email: 'ana@mail.com', badge: 'Pro', onEdit: editProfile)
```
- `name`, `email`, `avatarUrl`, `badge`, `onEdit`, `onTap`.
