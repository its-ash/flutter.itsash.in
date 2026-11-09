import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

import 'package:theme/src/feedback/ui_progress.dart';

/// Shared layout of the empty, error and success states.
class _StateView extends StatelessWidget {
  const _StateView({
    required this.icon,
    required this.status,
    required this.title,
    required this.message,
    required this.action,
    required this.compact,
  });

  final IconData icon;
  final UiStatus status;
  final String title;
  final String? message;
  final Widget? action;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final tone = c.tone(status);
    final circle = compact ? 48.0 : 72.0;
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(compact ? UiSpace.lg : UiSpace.xl),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: circle,
                height: circle,
                decoration: BoxDecoration(
                  color: tone.soft,
                  shape: BoxShape.circle,
                  border: status == UiStatus.neutral ? Border.all(color: c.border) : null,
                ),
                child: Icon(
                  icon,
                  size: compact ? 22 : 32,
                  color: status == UiStatus.neutral ? c.textMuted : tone.color,
                ),
              ),
              SizedBox(height: compact ? UiSpace.md : UiSpace.lg),
              Semantics(
                header: true,
                child: Text(title, textAlign: TextAlign.center, style: compact ? t.titleSmall : t.titleLarge),
              ),
              if (message != null) ...[
                const SizedBox(height: UiSpace.xs),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: (compact ? t.bodySmall : t.bodyMedium)?.copyWith(color: c.textMuted),
                ),
              ],
              if (action != null) ...[SizedBox(height: compact ? UiSpace.md : UiSpace.xl), action!],
            ],
          ),
        ),
      ),
    );
  }
}

/// Centered placeholder for screens and lists with no content yet.
///
/// ```dart
/// UiEmptyState(title: 'No notes yet', message: 'Tap + to write one.')
/// ```
class UiEmptyState extends StatelessWidget {
  const UiEmptyState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
    this.compact = false,
  });

  final String title;
  final String? message;
  final IconData icon;

  /// Widget under the text, usually a button.
  final Widget? action;

  /// Smaller icon and text, for cards and list sections.
  final bool compact;

  @override
  Widget build(BuildContext context) => _StateView(
    icon: icon,
    status: UiStatus.neutral,
    title: title,
    message: message,
    action: action,
    compact: compact,
  );
}

/// Centered error message with an optional retry button.
///
/// ```dart
/// UiErrorState(message: 'Check your connection.', onRetry: load)
/// ```
class UiErrorState extends StatelessWidget {
  const UiErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
    this.icon = Icons.error_outline_rounded,
    this.compact = false,
  });

  final String title;
  final String? message;

  /// Shows a retry button when set.
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  /// Smaller icon and text, for cards and list sections.
  final bool compact;

  @override
  Widget build(BuildContext context) => _StateView(
    icon: icon,
    status: UiStatus.danger,
    title: title,
    message: message,
    compact: compact,
    action: onRetry == null
        ? null
        : OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(retryLabel),
          ),
  );
}

/// Centered confirmation that something finished.
///
/// ```dart
/// UiSuccessState(title: 'Payment sent', message: 'We emailed your receipt.')
/// ```
class UiSuccessState extends StatelessWidget {
  const UiSuccessState({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.check_rounded,
    this.action,
    this.compact = false,
  });

  final String title;
  final String? message;
  final IconData icon;

  /// Widget under the text, usually a button.
  final Widget? action;

  /// Smaller icon and text, for cards and list sections.
  final bool compact;

  @override
  Widget build(BuildContext context) => _StateView(
    icon: icon,
    status: UiStatus.success,
    title: title,
    message: message,
    action: action,
    compact: compact,
  );
}

/// Dims [child] and blocks input while [loading] is true.
///
/// ```dart
/// UiLoadingOverlay(loading: saving, message: 'Saving…', child: form)
/// ```
class UiLoadingOverlay extends StatelessWidget {
  const UiLoadingOverlay({super.key, required this.loading, required this.child, this.message});

  final bool loading;
  final Widget child;

  /// Text next to the spinner.
  final String? message;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    return Stack(
      children: [
        AbsorbPointer(
          absorbing: loading,
          child: ExcludeFocus(excluding: loading, child: child),
        ),
        Positioned.fill(
          child: AnimatedSwitcher(
            duration: context.motion(UiMotion.normal),
            child: !loading
                ? const SizedBox.shrink()
                : ColoredBox(
                    key: const ValueKey('loading'),
                    color: c.background.withValues(alpha: 0.7),
                    child: Center(
                      child: Semantics(
                        liveRegion: true,
                        label: message ?? 'Loading',
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: UiSpace.xl, vertical: UiSpace.lg),
                          margin: const EdgeInsets.all(UiSpace.xl),
                          decoration: BoxDecoration(
                            color: c.surfaceRaised,
                            borderRadius: UiRadius.all(UiRadius.lg),
                            border: Border.all(color: c.border),
                            boxShadow: context.shadowMd,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const UiSpinner(size: 22),
                              if (message != null) ...[
                                const SizedBox(width: UiSpace.md),
                                Flexible(
                                  child: Text(
                                    message!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}
