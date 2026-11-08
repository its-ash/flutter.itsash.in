import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/auth/ui_auth_kit.dart';
import 'package:theme/src/input/ui_otp_field.dart';
import 'package:theme/src/input/ui_password_field.dart';
import 'package:theme/src/input/ui_text_field.dart';
import 'package:theme/src/feedback/ui_banner.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';

const _fallbackError = 'Something went wrong. Try again.';

mixin _AsyncForm<T extends StatefulWidget> on State<T> {
  final _form = GlobalKey<FormState>();
  bool _busy = false;
  String? _error;
  AutovalidateMode _auto = AutovalidateMode.disabled;

  Future<bool> _run(Future<String?> Function() fn, {bool validate = true}) async {
    if (_busy) return false;
    FocusScope.of(context).unfocus();
    if (validate && !(_form.currentState?.validate() ?? false)) {
      setState(() {
        _error = null;
        _auto = AutovalidateMode.onUserInteraction;
      });
      return false;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    String? err;
    try {
      err = await fn();
    } catch (_) {
      err = _fallbackError;
    }
    if (!mounted) return false;
    setState(() {
      _busy = false;
      _error = err;
    });
    return err == null;
  }

  Widget _banner() => AnimatedSize(
    duration: UiDuration.normal,
    curve: UiCurve.standard,
    alignment: Alignment.topCenter,
    child: _error == null
        ? const SizedBox(width: double.infinity)
        : Padding(
            padding: const EdgeInsets.only(bottom: UiSpace.lg),
            child: UiBanner(_error!, status: UiStatus.danger),
          ),
  );
}

class UiLoginForm extends StatefulWidget {
  const UiLoginForm({
    super.key,
    required this.onSubmit,
    this.onForgotPassword,
    this.onSignUp,
    this.onRememberMeChanged,
    this.rememberMe = false,
    this.initialEmail,
    this.footer,
    this.submitLabel = 'Log in',
    this.minPasswordLength = 8,
  });

  final Future<String?> Function(String email, String password) onSubmit;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onSignUp;
  final ValueChanged<bool>? onRememberMeChanged;
  final bool rememberMe;
  final String? initialEmail;
  final Widget? footer;
  final String submitLabel;
  final int minPasswordLength;

  @override
  State<UiLoginForm> createState() => _UiLoginFormState();
}

class _UiLoginFormState extends State<UiLoginForm> with _AsyncForm {
  late final _email = TextEditingController(text: widget.initialEmail?.trim());
  final _pass = TextEditingController();
  late bool _remember = widget.rememberMe;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final ok = await _run(() => widget.onSubmit(_email.text.trim(), _pass.text));
    if (ok) TextInput.finishAutofillContext();
  }

  @override
  Widget build(BuildContext context) {
    final showRow = widget.onRememberMeChanged != null || widget.onForgotPassword != null;
    return AutofillGroup(
      child: Form(
        key: _form,
        autovalidateMode: _auto,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _banner(),
            UiTextField.email(controller: _email, validator: UiAuthValidators.email, enabled: !_busy),
            const SizedBox(height: UiSpace.md),
            UiPasswordField(
              controller: _pass,
              validator: UiAuthValidators.password(min: widget.minPasswordLength.clamp(1, 128)),
              onSubmitted: (_) => _go(),
              enabled: !_busy,
            ),
            if (showRow) ...[
              const SizedBox(height: UiSpace.xs),
              Row(
                children: [
                  if (widget.onRememberMeChanged != null)
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: _CheckRow(
                          value: _remember,
                          onChanged: _busy
                              ? null
                              : (v) {
                                  setState(() => _remember = v);
                                  widget.onRememberMeChanged!(v);
                                },
                          child: Text('Remember me', style: context.text.bodyMedium),
                        ),
                      ),
                    )
                  else
                    const Spacer(),
                  if (widget.onForgotPassword != null) UiAuthLink('Forgot password?', onTap: _busy ? null : widget.onForgotPassword),
                ],
              ),
            ],
            const SizedBox(height: UiSpace.lg),
            UiButton(widget.submitLabel, onPressed: _go, loading: _busy, expand: true),
            if (widget.footer != null) ...[const SizedBox(height: UiSpace.sm), widget.footer!],
            if (widget.onSignUp != null) ...[const SizedBox(height: UiSpace.md), UiAuthPrompt(text: "Don't have an account?", action: 'Sign up', onTap: widget.onSignUp!)],
          ],
        ),
      ),
    );
  }
}

class UiSignupForm extends StatefulWidget {
  const UiSignupForm({
    super.key,
    required this.onSubmit,
    this.onLogIn,
    this.onTermsTap,
    this.onPrivacyTap,
    this.footer,
    this.submitLabel = 'Create account',
    this.minPasswordLength = 8,
    this.showStrength = true,
  });

  final Future<String?> Function(String name, String email, String password) onSubmit;
  final VoidCallback? onLogIn;
  final VoidCallback? onTermsTap;
  final VoidCallback? onPrivacyTap;
  final Widget? footer;
  final String submitLabel;
  final int minPasswordLength;
  final bool showStrength;

  @override
  State<UiSignupForm> createState() => _UiSignupFormState();
}

class _UiSignupFormState extends State<UiSignupForm> with _AsyncForm {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _go() async {
    final ok = await _run(() => widget.onSubmit(_name.text.trim(), _email.text.trim(), _pass.text));
    if (ok) TextInput.finishAutofillContext();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final min = widget.minPasswordLength.clamp(1, 128);
    return AutofillGroup(
      child: Form(
        key: _form,
        autovalidateMode: _auto,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _banner(),
            UiTextField.name(controller: _name, validator: UiAuthValidators.name, enabled: !_busy, maxLength: 80),
            const SizedBox(height: UiSpace.md),
            UiTextField.email(controller: _email, validator: UiAuthValidators.email, enabled: !_busy),
            const SizedBox(height: UiSpace.md),
            UiPasswordField(
              controller: _pass,
              validator: UiAuthValidators.password(min: min),
              showStrength: widget.showStrength,
              newPassword: true,
              textInputAction: TextInputAction.next,
              enabled: !_busy,
            ),
            const SizedBox(height: UiSpace.md),
            UiPasswordField(
              controller: _confirm,
              label: 'Confirm password',
              newPassword: true,
              validator: (v) => (v ?? '').isEmpty
                  ? 'Confirm your password'
                  : v != _pass.text
                  ? 'Passwords do not match'
                  : null,
              onSubmitted: (_) => _go(),
              enabled: !_busy,
            ),
            const SizedBox(height: UiSpace.sm),
            FormField<bool>(
              initialValue: false,
              validator: (v) => v == true ? null : 'Accept the terms to continue',
              builder: (f) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CheckRow(
                    value: f.value ?? false,
                    onChanged: _busy ? null : f.didChange,
                    child: Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text('I agree to the ', style: context.text.bodyMedium),
                        _InlineLink('Terms', widget.onTermsTap),
                        Text(' and ', style: context.text.bodyMedium),
                        _InlineLink('Privacy Policy', widget.onPrivacyTap),
                      ],
                    ),
                  ),
                  if (f.hasError)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: UiSpace.md),
                      child: Text(f.errorText!, style: context.text.bodySmall?.copyWith(color: cs.error)),
                    ),
                ],
              ),
            ),
            const SizedBox(height: UiSpace.lg),
            UiButton(widget.submitLabel, onPressed: _go, loading: _busy, expand: true),
            if (widget.footer != null) ...[const SizedBox(height: UiSpace.sm), widget.footer!],
            if (widget.onLogIn != null) ...[const SizedBox(height: UiSpace.md), UiAuthPrompt(text: 'Already have an account?', action: 'Log in', onTap: widget.onLogIn!)],
          ],
        ),
      ),
    );
  }
}

class UiForgotPasswordForm extends StatefulWidget {
  const UiForgotPasswordForm({super.key, required this.onSubmit, this.onBack, this.initialEmail, this.resendSeconds = 30, this.showHeader = true});

  final Future<String?> Function(String email) onSubmit;
  final VoidCallback? onBack;
  final String? initialEmail;
  final int resendSeconds;
  final bool showHeader;

  @override
  State<UiForgotPasswordForm> createState() => _UiForgotPasswordFormState();
}

class _UiForgotPasswordFormState extends State<UiForgotPasswordForm> with _AsyncForm {
  late final _email = TextEditingController(text: widget.initialEmail?.trim());
  String? _sentTo;
  int _wait = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _email.dispose();
    super.dispose();
  }

  void _cooldown() {
    _timer?.cancel();
    setState(() => _wait = widget.resendSeconds.clamp(0, 600));
    if (_wait == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _wait--);
      if (_wait <= 0) t.cancel();
    });
  }

  Future<void> _send() async {
    final email = _sentTo ?? _email.text.trim();
    final ok = await _run(() => widget.onSubmit(email), validate: _sentTo == null);
    if (!ok || !mounted) return;
    setState(() => _sentTo = email);
    _cooldown();
  }

  @override
  Widget build(BuildContext context) {
    final sent = _sentTo != null;
    final done = Column(
      key: const ValueKey('sent'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHeader) ...[
          UiAuthHeader(icon: Icons.mark_email_read_rounded, title: 'Check your email', subtitle: 'We sent a reset link to $_sentTo. Open the link to set a new password.'),
          const SizedBox(height: UiSpace.xxl),
        ],
        _banner(),
        UiButton.tonal(_wait > 0 ? 'Resend in ${_wait}s' : 'Resend link', onPressed: _wait > 0 ? null : _send, loading: _busy, expand: true),
        const SizedBox(height: UiSpace.sm),
        UiButton.ghost(
          'Use a different email',
          onPressed: _busy
              ? null
              : () => setState(() {
                  _sentTo = null;
                  _error = null;
                }),
          expand: true,
        ),
        if (widget.onBack != null) UiButton.ghost('Back to log in', icon: Icons.arrow_back_rounded, onPressed: widget.onBack, expand: true),
      ],
    );
    final form = Column(
      key: const ValueKey('form'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHeader) ...[
          const UiAuthHeader(icon: Icons.key_rounded, title: 'Forgot password?', subtitle: 'Enter your email. We will send you a link to reset your password.'),
          const SizedBox(height: UiSpace.xxl),
        ],
        _banner(),
        UiTextField.email(controller: _email, textInputAction: TextInputAction.done, validator: UiAuthValidators.email, onSubmitted: (_) => _send(), enabled: !_busy),
        const SizedBox(height: UiSpace.lg),
        UiButton('Send reset link', onPressed: _send, loading: _busy, expand: true),
        if (widget.onBack != null) ...[const SizedBox(height: UiSpace.sm), UiButton.ghost('Back to log in', icon: Icons.arrow_back_rounded, onPressed: _busy ? null : widget.onBack, expand: true)],
      ],
    );
    return Form(
      key: _form,
      autovalidateMode: _auto,
      child: AnimatedSwitcher(duration: UiDuration.normal, child: sent ? done : form),
    );
  }
}

class UiVerifyCodeForm extends StatefulWidget {
  const UiVerifyCodeForm({super.key, required this.onSubmit, this.length = 6, this.destination, this.onResend, this.resendSeconds = 30, this.showHeader = true});

  final Future<String?> Function(String code) onSubmit;
  final int length;
  final String? destination;
  final Future<void> Function()? onResend;
  final int resendSeconds;
  final bool showHeader;

  @override
  State<UiVerifyCodeForm> createState() => _UiVerifyCodeFormState();
}

class _UiVerifyCodeFormState extends State<UiVerifyCodeForm> with _AsyncForm {
  final _code = TextEditingController();
  final _focus = FocusNode();
  int _wait = 0;
  bool _resending = false;
  Timer? _timer;

  int get _len => widget.length.clamp(4, 8);

  @override
  void initState() {
    super.initState();
    _code.addListener(_changed);
    _cooldown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _changed() => setState(() {});

  void _cooldown() {
    _timer?.cancel();
    _wait = widget.onResend == null ? 0 : widget.resendSeconds.clamp(0, 600);
    if (_wait == 0) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return t.cancel();
      setState(() => _wait--);
      if (_wait <= 0) t.cancel();
    });
  }

  Future<void> _verify() async {
    final c = _code.text;
    if (c.length != _len) {
      setState(() => _error = 'Enter the $_len-digit code');
      return;
    }
    final ok = await _run(() => widget.onSubmit(c), validate: false);
    if (!ok && mounted) {
      _code.clear();
      _focus.requestFocus();
    }
  }

  Future<void> _resend() async {
    final fn = widget.onResend;
    if (fn == null || _resending || _wait > 0) return;
    setState(() {
      _resending = true;
      _error = null;
    });
    try {
      await fn();
      if (mounted) setState(_cooldown);
    } catch (_) {
      if (mounted) setState(() => _error = _fallbackError);
    } finally {
      if (mounted) setState(() => _resending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final code = _code.text;
    final dest = widget.destination?.trim() ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.showHeader) ...[
          UiAuthHeader(icon: Icons.sms_rounded, title: 'Enter code', subtitle: dest.isEmpty ? 'We sent you a $_len-digit code.' : 'We sent a $_len-digit code to $dest.'),
          const SizedBox(height: UiSpace.xxl),
        ],
        _banner(),
        UiOtpField(length: _len, controller: _code, focusNode: _focus, autofocus: true, enabled: !_busy, error: _error == null ? null : '', onCompleted: (_) => _busy ? null : _verify()),
        const SizedBox(height: UiSpace.xl),
        UiButton('Verify', onPressed: code.length == _len ? _verify : null, loading: _busy, expand: true),
        if (widget.onResend != null) ...[
          const SizedBox(height: UiSpace.sm),
          UiButton.ghost(_wait > 0 ? 'Resend code in ${_wait}s' : 'Resend code', onPressed: _wait > 0 || _busy ? null : _resend, loading: _resending, expand: true),
        ],
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.value, required this.onChanged, required this.child});

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) => MergeSemantics(
    child: InkWell(
      onTap: onChanged == null ? null : () => onChanged!(!value),
      borderRadius: context.tokens.sm,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(value: value, onChanged: onChanged == null ? null : (v) => onChanged!(v ?? false)),
          Flexible(child: child),
        ],
      ),
    ),
  );
}

class _InlineLink extends StatelessWidget {
  const _InlineLink(this.label, this.onTap);

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final style = context.text.bodyMedium?.copyWith(color: context.colors.primary, fontWeight: FontWeight.w600);
    if (onTap == null) return Text(label, style: style);
    return Semantics(
      link: true,
      child: GestureDetector(
        onTap: onTap,
        child: Text(label, style: style?.copyWith(decoration: TextDecoration.underline)),
      ),
    );
  }
}
