import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';

class UiEmptyState extends StatelessWidget {
  const UiEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.illustration,
    this.actionLabel,
    this.onAction,
    this.compact = false,
    this.status = UiStatus.neutral,
  });

  final String title;
  final String? message;
  final IconData icon;
  final Widget? illustration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;
  final UiStatus status;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final t = status == UiStatus.neutral ? (container: cs.primaryContainer, onContainer: cs.onPrimaryContainer) : (container: context.tone(status).container, onContainer: context.tone(status).onContainer);
    final dim = compact ? 56.0 : 96.0;
    final art = illustration ??
        Container(
          width: dim,
          height: dim,
          decoration: BoxDecoration(color: t.container.withValues(alpha: 0.7), shape: BoxShape.circle),
          child: Icon(icon, size: dim * 0.46, color: t.onContainer),
        );
    final hasAction = actionLabel != null && onAction != null;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? UiSpace.lg : UiSpace.xxxl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(child: art),
              SizedBox(height: compact ? UiSpace.md : UiSpace.xxl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: (compact ? context.text.titleMedium : context.text.titleLarge)?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (message != null && message!.isNotEmpty) ...[
                const UiGap.sm(),
                Text(message!, textAlign: TextAlign.center, style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
              ],
              if (hasAction) ...[
                SizedBox(height: compact ? UiSpace.lg : UiSpace.xxl),
                compact ? UiButton.tonal(actionLabel!, size: UiSize.sm, onPressed: onAction) : UiButton(actionLabel!, onPressed: onAction),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class UiErrorState extends StatelessWidget {
  const UiErrorState({
    super.key,
    this.onRetry,
    this.title = 'Something went wrong',
    this.message = 'Please check your connection and try again.',
    this.retryLabel = 'Try again',
    this.icon = Icons.cloud_off_rounded,
    this.compact = false,
  });

  final VoidCallback? onRetry;
  final String title;
  final String? message;
  final String retryLabel;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) => UiEmptyState(
        title: title,
        message: message,
        icon: icon,
        status: UiStatus.danger,
        compact: compact,
        actionLabel: retryLabel,
        onAction: onRetry,
      );
}

class UiLoader extends StatelessWidget {
  const UiLoader({super.key, this.message, this.size = 32, this.color}) : _centered = true;

  const UiLoader._inline({this.message})
      : size = 32,
        color = null,
        _centered = false;

  final String? message;
  final double size;
  final Color? color;
  final bool _centered;

  static Future<T> overlay<T>(BuildContext context, Future<T> future, {String? message}) async {
    final nav = Navigator.of(context, rootNavigator: true);
    final route = DialogRoute<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (c) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(UiSpace.xxl),
            constraints: const BoxConstraints(minWidth: 120, maxWidth: 280),
            decoration: BoxDecoration(color: c.colors.surfaceContainerLow, borderRadius: c.tokens.lg),
            child: Material(type: MaterialType.transparency, child: UiLoader._inline(message: message)),
          ),
        ),
      ),
    );
    nav.push(route);
    try {
      return await future;
    } finally {
      if (route.isActive) nav.removeRoute(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = Semantics(
          label: message ?? 'Loading',
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: size,
                child: CircularProgressIndicator(strokeWidth: size / 10, strokeCap: StrokeCap.round, color: color ?? context.colors.primary),
              ),
              if (message != null && message!.isNotEmpty) ...[
                const UiGap.lg(),
                Text(message!, textAlign: TextAlign.center, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
              ],
            ],
          ),
        );
    return _centered ? Center(child: body) : body;
  }
}
