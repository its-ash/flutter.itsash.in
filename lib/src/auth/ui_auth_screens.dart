import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_avatar.dart';
import 'package:theme/src/button/ui_button.dart';
import 'package:theme/src/card/ui_card.dart';
import 'package:theme/src/display/ui_tag.dart';

class UiPermissionCard extends StatelessWidget {
  const UiPermissionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.reason,
    this.onAllow,
    this.onDeny,
    this.allowLabel = 'Allow',
    this.denyLabel = 'Not now',
  });

  const UiPermissionCard.camera({
    super.key,
    this.onAllow,
    this.onDeny,
    this.title = 'Allow camera access',
    this.reason = 'We use the camera to take photos and scan documents. We do not record without your action.',
    this.allowLabel = 'Allow',
    this.denyLabel = 'Not now',
  }) : icon = Icons.photo_camera_rounded;

  const UiPermissionCard.location({
    super.key,
    this.onAllow,
    this.onDeny,
    this.title = 'Allow location access',
    this.reason = 'We use your location to show results near you. You can change this in settings at any time.',
    this.allowLabel = 'Allow',
    this.denyLabel = 'Not now',
  }) : icon = Icons.location_on_rounded;

  const UiPermissionCard.notifications({
    super.key,
    this.onAllow,
    this.onDeny,
    this.title = 'Turn on notifications',
    this.reason = 'Get alerts for messages, updates, and reminders. You can turn them off at any time.',
    this.allowLabel = 'Turn on',
    this.denyLabel = 'Not now',
  }) : icon = Icons.notifications_active_rounded;

  final IconData icon;
  final String title;
  final String reason;
  final VoidCallback? onAllow;
  final VoidCallback? onDeny;
  final String allowLabel;
  final String denyLabel;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return UiCard(
      padding: const EdgeInsets.all(UiSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: context.tokens.lg),
            child: Icon(icon, size: 28, color: cs.onPrimaryContainer),
          ),
          const SizedBox(height: UiSpace.lg),
          Semantics(header: true, child: Text(title, style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800))),
          const SizedBox(height: UiSpace.sm),
          Text(reason, style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant, height: 1.45)),
          const SizedBox(height: UiSpace.xl),
          Row(
            children: [
              if (onDeny != null) ...[
                Expanded(child: UiButton.ghost(denyLabel, onPressed: onDeny, expand: true)),
                const SizedBox(width: UiSpace.md),
              ],
              Expanded(child: UiButton(allowLabel, onPressed: onAllow, expand: true)),
            ],
          ),
        ],
      ),
    );
  }
}

class UiSplash extends StatelessWidget {
  const UiSplash({
    super.key,
    this.logo,
    this.icon = Icons.bolt_rounded,
    this.name,
    this.tagline,
    this.loading = true,
    this.gradient = false,
  });

  final Widget? logo;
  final IconData icon;
  final String? name;
  final String? tagline;
  final bool loading;
  final bool gradient;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final fg = gradient ? cs.onPrimary : cs.onSurface;
    final sub = gradient ? cs.onPrimary.withValues(alpha: 0.8) : cs.onSurfaceVariant;
    return DecoratedBox(
      decoration: BoxDecoration(color: gradient ? null : cs.surface, gradient: gradient ? context.palette.gradient : null),
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: UiDuration.slow * 2,
                  curve: UiCurve.emphasized,
                  builder: (context, t, child) => Opacity(
                    opacity: t.clamp(0.0, 1.0),
                    child: Transform.scale(scale: 0.85 + 0.15 * t, child: child),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      logo ??
                          Container(
                            width: 96,
                            height: 96,
                            decoration: BoxDecoration(
                              color: gradient ? cs.onPrimary.withValues(alpha: 0.16) : null,
                              gradient: gradient ? null : context.palette.gradient,
                              borderRadius: context.tokens.xl,
                            ),
                            child: Icon(icon, size: 52, color: cs.onPrimary),
                          ),
                      if (name?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: UiSpace.xl),
                        Text(name!, textAlign: TextAlign.center, style: context.text.headlineSmall?.copyWith(color: fg, fontWeight: FontWeight.w800)),
                      ],
                      if (tagline?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: UiSpace.xs),
                        Text(tagline!, textAlign: TextAlign.center, style: context.text.bodyMedium?.copyWith(color: sub)),
                      ],
                    ],
                  ),
                ),
              ),
              if (loading)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: UiSpace.huge,
                  child: Center(
                    child: SizedBox.square(
                      dimension: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: gradient ? cs.onPrimary : cs.primary, semanticsLabel: 'Loading'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum UiErrorPageType { notFound, server, offline, maintenance, forbidden, generic }

class UiErrorPage extends StatelessWidget {
  const UiErrorPage({
    super.key,
    this.type = UiErrorPageType.generic,
    this.title,
    this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.secondaryLabel,
    this.onSecondary,
  });

  final UiErrorPageType type;
  final String? title;
  final String? message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final (code, ic, t, m, a, status) = switch (type) {
      UiErrorPageType.notFound => ('404', Icons.search_off_rounded, 'Page not found', 'The page you want does not exist or it moved.', 'Go home', UiStatus.info),
      UiErrorPageType.server => ('500', Icons.cloud_off_rounded, 'Something went wrong', 'We have a problem on our side. Try again soon.', 'Try again', UiStatus.danger),
      UiErrorPageType.offline => (null, Icons.wifi_off_rounded, 'No connection', 'Make sure that you are online, then try again.', 'Retry', UiStatus.warning),
      UiErrorPageType.maintenance => (null, Icons.construction_rounded, 'Under maintenance', 'We are making improvements. Come back soon.', 'Refresh', UiStatus.warning),
      UiErrorPageType.forbidden => ('403', Icons.lock_outline_rounded, 'Access denied', 'You do not have permission to see this page.', 'Go back', UiStatus.danger),
      UiErrorPageType.generic => (null, Icons.error_outline_rounded, 'Something went wrong', 'An error occurred. Try again.', 'Try again', UiStatus.danger),
    };
    final tone = context.tone(status);
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(UiSpace.xxl),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 140,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (code != null)
                        ExcludeSemantics(
                          child: Text(
                            code,
                            style: context.text.displayLarge?.copyWith(
                              fontSize: 120,
                              fontWeight: FontWeight.w900,
                              height: 1,
                              color: tone.color.withValues(alpha: 0.12),
                            ),
                          ),
                        ),
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(color: tone.container, shape: BoxShape.circle),
                        child: Icon(icon ?? ic, size: 44, color: tone.onContainer),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: UiSpace.xl),
                Semantics(
                  header: true,
                  child: Text(
                    title ?? t,
                    textAlign: TextAlign.center,
                    style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: UiSpace.sm),
                Text(
                  message ?? m,
                  textAlign: TextAlign.center,
                  style: context.text.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.45),
                ),
                if (onAction != null) ...[
                  const SizedBox(height: UiSpace.xxl),
                  UiButton(actionLabel ?? a, onPressed: onAction, expand: true),
                ],
                if (onSecondary != null) ...[
                  const SizedBox(height: UiSpace.sm),
                  UiButton.ghost(secondaryLabel ?? 'Contact support', onPressed: onSecondary, expand: true),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UiAccountHeader extends StatelessWidget {
  const UiAccountHeader({
    super.key,
    required this.name,
    this.email,
    this.avatarUrl,
    this.badge,
    this.onEdit,
    this.onTap,
  });

  final String name;
  final String? email;
  final String? avatarUrl;
  final String? badge;
  final VoidCallback? onEdit;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final b = badge?.trim() ?? '';
    return UiCard(
      onTap: onTap,
      child: Row(
        children: [
          UiAvatar(name: name, imageUrl: avatarUrl, size: 60),
          const SizedBox(width: UiSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    if (b.isNotEmpty) ...[const SizedBox(width: UiSpace.sm), UiTag(b, size: UiSize.sm, status: UiStatus.info)],
                  ],
                ),
                if (email?.trim().isNotEmpty ?? false)
                  Text(
                    email!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
          if (onEdit != null) ...[
            const SizedBox(width: UiSpace.sm),
            UiIconButton(Icons.edit_outlined, onPressed: onEdit, tooltip: 'Edit profile', size: UiSize.sm),
          ],
        ],
      ),
    );
  }
}
