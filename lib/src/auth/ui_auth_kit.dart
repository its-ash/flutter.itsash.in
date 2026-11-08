import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

abstract final class UiAuthValidators {
  static final _email = RegExp(
    r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
  );

  static bool isEmail(String v) {
    final s = v.trim();
    return s.length <= 254 && _email.hasMatch(s);
  }

  static String? email(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Enter your email';
    return isEmail(s) ? null : 'Enter a valid email';
  }

  static FormFieldValidator<String> password({int min = 8, int max = 128}) => (v) {
        final s = v ?? '';
        if (s.isEmpty) return 'Enter your password';
        if (s.length < min) return 'Use at least $min characters';
        if (s.length > max) return 'Use at most $max characters';
        return null;
      };

  static String? name(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'Enter your name';
    if (s.length > 80) return 'Use at most 80 characters';
    return null;
  }
}

class UiAuthPrompt extends StatelessWidget {
  const UiAuthPrompt({super.key, required this.text, required this.action, required this.onTap});

  final String text;
  final String action;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(text, style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        UiAuthLink(action, onTap: onTap),
      ],
    );
  }
}

class UiAuthLink extends StatelessWidget {
  const UiAuthLink(this.label, {super.key, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          minimumSize: const Size(44, 40),
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: context.colors.primary,
          textStyle: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        child: Text(label),
      );
}

class UiAuthHeader extends StatelessWidget {
  const UiAuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.logo,
    this.icon = Icons.lock_rounded,
    this.center = true,
  });

  final String title;
  final String? subtitle;
  final Widget? logo;
  final IconData icon;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final align = center ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: context.tokens.lg),
          child: logo ?? Icon(icon, size: 32, color: cs.onPrimaryContainer),
        ),
        const SizedBox(height: UiSpace.xl),
        Semantics(
          header: true,
          child: Text(title, textAlign: align, style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
        ),
        if (subtitle?.trim().isNotEmpty ?? false) ...[
          const SizedBox(height: UiSpace.sm),
          Text(subtitle!, textAlign: align, style: context.text.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.4)),
        ],
      ],
    );
  }
}
