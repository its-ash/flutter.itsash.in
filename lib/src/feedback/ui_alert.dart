import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Border color for a soft status surface: a light tint of the status color.
Color _softBorder(UiColors c, UiStatus status) {
  if (status == UiStatus.neutral) return c.border;
  final tone = c.tone(status);
  return Color.alphaBlend(tone.color.withValues(alpha: c.isDark ? 0.22 : 0.20), tone.soft);
}

/// Icon color on a soft status surface.
Color _softIcon(UiColors c, UiStatus status) => status == UiStatus.neutral ? c.textMuted : c.tone(status).color;

/// Inline callout box with a soft status tint.
///
/// ```dart
/// UiAlert('Your trial ends in 3 days.', title: 'Heads up', status: UiStatus.warning)
/// ```
class UiAlert extends StatelessWidget {
  const UiAlert(
    this.message, {
    super.key,
    this.title,
    this.status = UiStatus.info,
    this.icon,
    this.showIcon = true,
    this.action,
    this.onClose,
  });

  /// Body text.
  final String message;

  /// Optional bold first line.
  final String? title;

  /// Color and default icon. Defaults to [UiStatus.info].
  final UiStatus status;

  /// Leading icon. Defaults to [UiStatus.icon].
  final IconData? icon;

  /// Hides the leading icon when false.
  final bool showIcon;

  /// Widget shown under the message, e.g. a `TextButton`.
  final Widget? action;

  /// Shows a close button when set.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = c.tone(status);
    final t = context.text;
    final hasTitle = title != null && title!.isNotEmpty;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.md, onClose != null ? UiSpace.xs : UiSpace.lg, UiSpace.md),
        decoration: BoxDecoration(
          color: tone.soft,
          borderRadius: UiRadius.all(UiRadius.md),
          border: Border.all(color: _softBorder(c, status)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showIcon) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon ?? status.icon, size: 18, color: _softIcon(c, status)),
              ),
              const SizedBox(width: UiSpace.md),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasTitle) ...[
                    Text(title!, style: t.titleSmall?.copyWith(color: tone.onSoft)),
                    const SizedBox(height: UiSpace.xxs),
                  ],
                  Text(
                    message,
                    style: t.bodyMedium?.copyWith(
                      color: hasTitle ? tone.onSoft.withValues(alpha: 0.86) : tone.onSoft,
                      height: 1.45,
                    ),
                  ),
                  if (action != null) ...[const SizedBox(height: UiSpace.sm), action!],
                ],
              ),
            ),
            if (onClose != null)
              Padding(
                padding: const EdgeInsets.only(left: UiSpace.xs),
                child: _CloseButton(color: tone.onSoft, onPressed: onClose!),
              ),
          ],
        ),
      ),
    );
  }
}

class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.color, required this.onPressed});

  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 40,
      child: IconButton(
        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(minimumSize: const Size(40, 40), foregroundColor: color.withValues(alpha: 0.8)),
        icon: const Icon(Icons.close_rounded, size: 18),
      ),
    );
  }
}

/// Full-width strip for app-wide messages such as "You're offline".
///
/// Slides in and out when [visible] changes.
///
/// ```dart
/// UiBanner("You're offline", visible: offline, status: UiStatus.warning)
/// ```
class UiBanner extends StatefulWidget {
  const UiBanner(
    this.message, {
    super.key,
    this.visible = true,
    this.status = UiStatus.info,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onDismiss,
  });

  final String message;

  /// Shows or hides the banner with a size and fade animation.
  final bool visible;

  /// Color and default icon. Defaults to [UiStatus.info].
  final UiStatus status;

  /// Leading icon. Defaults to [UiStatus.icon].
  final IconData? icon;

  /// Label of a trailing text action. Needs [onAction].
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Shows a close button when set.
  final VoidCallback? onDismiss;

  @override
  State<UiBanner> createState() => _UiBannerState();
}

class _UiBannerState extends State<UiBanner> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: UiMotion.normal,
    value: widget.visible ? 1 : 0,
  );
  late final CurvedAnimation _curve = CurvedAnimation(parent: _controller, curve: UiMotion.standard);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = context.motion(UiMotion.normal);
  }

  @override
  void didUpdateWidget(UiBanner old) {
    super.didUpdateWidget(old);
    if (widget.visible != old.visible) {
      widget.visible ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final tone = c.tone(widget.status);
    final t = context.text;
    final hasAction = widget.actionLabel != null && widget.onAction != null;

    final strip = Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 44),
      padding: EdgeInsets.fromLTRB(
        UiSpace.lg,
        UiSpace.xs,
        widget.onDismiss != null ? UiSpace.xs : UiSpace.lg,
        UiSpace.xs,
      ),
      decoration: BoxDecoration(
        color: tone.soft,
        border: Border(bottom: BorderSide(color: _softBorder(c, widget.status))),
      ),
      child: Row(
        children: [
          Icon(widget.icon ?? widget.status.icon, size: 18, color: _softIcon(c, widget.status)),
          const SizedBox(width: UiSpace.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: UiSpace.sm),
              child: Text(
                widget.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: t.bodyMedium?.copyWith(color: tone.onSoft, fontWeight: FontWeight.w500),
              ),
            ),
          ),
          if (hasAction)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: TextButton(
                onPressed: widget.onAction,
                style: TextButton.styleFrom(
                  foregroundColor: tone.onSoft,
                  minimumSize: const Size(40, 36),
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
                ),
                child: Text(widget.actionLabel!, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          if (widget.onDismiss != null) _CloseButton(color: tone.onSoft, onPressed: widget.onDismiss!),
        ],
      ),
    );

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (_controller.isDismissed) return const SizedBox(width: double.infinity);
        return ClipRect(
          child: SizeTransition(
            sizeFactor: _curve,
            alignment: Alignment.topLeft,
            child: FadeTransition(opacity: _curve, child: child),
          ),
        );
      },
      child: Semantics(container: true, liveRegion: true, child: strip),
    );
  }
}
