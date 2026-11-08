import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

enum UiSocialProvider {
  google('Google'),
  apple('Apple'),
  facebook('Facebook'),
  github('GitHub'),
  email('Email'),
  phone('Phone'),
  x('X');

  const UiSocialProvider(this.title);

  final String title;
}

class UiSocialButton extends StatelessWidget {
  const UiSocialButton(
    this.provider, {
    super.key,
    required this.onPressed,
    this.label,
    this.loading = false,
    this.expand = true,
    this.icon,
  });

  final UiSocialProvider provider;
  final VoidCallback? onPressed;
  final String? label;
  final bool loading;
  final bool expand;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final text = label ?? 'Continue with ${provider.title}';
    final enabled = onPressed != null && !loading;
    const iconSize = 22.0;
    Widget glyph(String ch, Color bg, Color fg) => Container(
          width: iconSize,
          height: iconSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Text(
            ch,
            style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w900, height: 1),
          ),
        );
    final glyphIcon = icon ??
        switch (provider) {
      UiSocialProvider.google => glyph('G', const Color(0xFF4285F4), Colors.white),
      UiSocialProvider.github => glyph('G', cs.onSurface, cs.surface),
      UiSocialProvider.x => glyph('X', cs.onSurface, cs.surface),
      UiSocialProvider.apple => Icon(Icons.apple, size: iconSize, color: cs.onSurface),
      UiSocialProvider.facebook => const Icon(Icons.facebook, size: iconSize, color: Color(0xFF1877F2)),
      UiSocialProvider.email => Icon(Icons.email_outlined, size: iconSize, color: cs.onSurface),
      UiSocialProvider.phone => Icon(Icons.phone_outlined, size: iconSize, color: cs.onSurface),
    };
    return Semantics(
      button: true,
      enabled: enabled,
      label: loading ? '$text, loading' : text,
      excludeSemantics: true,
      child: OutlinedButton(
        onPressed: enabled ? onPressed : null,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(expand ? double.infinity : 0, context.tokens.controlHeight),
          foregroundColor: cs.onSurface,
          backgroundColor: cs.surface,
          side: BorderSide(color: cs.outlineVariant),
          shape: RoundedRectangleBorder(borderRadius: context.tokens.md),
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.xl),
          textStyle: context.text.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(
              dimension: iconSize,
              child: loading
                  ? Padding(
                      padding: const EdgeInsets.all(2),
                      child: CircularProgressIndicator(strokeWidth: 2.2, color: cs.onSurface),
                    )
                  : Opacity(opacity: enabled ? 1 : 0.4, child: glyphIcon),
            ),
            const SizedBox(width: UiSpace.md),
            Flexible(child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }
}
