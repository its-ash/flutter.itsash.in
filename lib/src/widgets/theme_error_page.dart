import 'package:flutter/material.dart';

import 'package:theme/src/typography/app_typography.dart';
import 'package:theme/src/components/theme_button.dart';

enum ThemeErrorPageKind { notFound, forbidden, serverError }

class ThemeErrorPage extends StatelessWidget {
  const ThemeErrorPage({
    super.key,
    required this.kind,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  /// 404 — page/resource not found.
  const ThemeErrorPage.notFound({
    super.key,
    this.title = 'Page not found',
    this.subtitle = "The page you're looking for doesn't exist or was moved.",
    this.actionLabel = 'Go home',
    this.onAction,
  }) : kind = ThemeErrorPageKind.notFound;

  /// 403 — access denied.
  const ThemeErrorPage.forbidden({
    super.key,
    this.title = 'Access denied',
    this.subtitle = "You don't have permission to view this page.",
    this.actionLabel = 'Go back',
    this.onAction,
  }) : kind = ThemeErrorPageKind.forbidden;

  /// 500 — server error.
  const ThemeErrorPage.serverError({
    super.key,
    this.title = 'Something broke on our end',
    this.subtitle = "We're already looking into it — please try again shortly.",
    this.actionLabel = 'Retry',
    this.onAction,
  }) : kind = ThemeErrorPageKind.serverError;

  final ThemeErrorPageKind kind;
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  IconData get _icon => switch (kind) {
        ThemeErrorPageKind.notFound => Icons.search_off,
        ThemeErrorPageKind.forbidden => Icons.lock_outline,
        ThemeErrorPageKind.serverError => Icons.cloud_off_outlined,
      };

  String get _code => switch (kind) {
        ThemeErrorPageKind.notFound => '404',
        ThemeErrorPageKind.forbidden => '403',
        ThemeErrorPageKind.serverError => '500',
      };

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 72, color: scheme.onSurface.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                _code,
                style: AppTypography.headlineLarge.copyWith(
                  color: scheme.onSurface.withValues(alpha: 0.2),
                ),
              ),
              const SizedBox(height: 12),
              if (title != null)
                Text(title!, style: AppTypography.titleLarge, textAlign: TextAlign.center),
              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: 24),
                ThemeButton(label: actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
