import 'dart:async';

import 'package:flutter/material.dart';

import 'package:theme/src/feedback/ui_status_icon.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

extension UiToastX on BuildContext {
  void showToast(
    String message, {
    UiStatus status = UiStatus.neutral,
    String? title,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) =>
      UiToast.show(this, message, status: status, title: title, icon: icon, duration: duration, onTap: onTap);

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason>? showSnack(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
  }) {
    final m = ScaffoldMessenger.maybeOf(this);
    if (m == null || message.trim().isEmpty) return null;
    m.hideCurrentSnackBar();
    return m.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        action: actionLabel != null && onAction != null ? SnackBarAction(label: actionLabel, onPressed: onAction) : null,
      ),
    );
  }
}

abstract final class UiToast {
  static OverlayEntry? _entry;
  static GlobalKey<_ToastViewState>? _key;

  static void show(
    BuildContext context,
    String message, {
    UiStatus status = UiStatus.neutral,
    String? title,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null || !overlay.mounted || message.trim().isEmpty) return;
    _clear();
    final key = GlobalKey<_ToastViewState>();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastView(
        key: key,
        message: message,
        title: title,
        status: status,
        icon: icon ?? status.icon,
        duration: duration <= Duration.zero ? const Duration(seconds: 3) : duration,
        onTap: onTap,
        onDone: () => _remove(entry),
      ),
    );
    _entry = entry;
    _key = key;
    overlay.insert(entry);
  }

  static void dismiss() {
    final s = _key?.currentState;
    if (s != null) {
      s.close();
    } else {
      _clear();
    }
  }

  static void _clear() {
    final e = _entry;
    _entry = null;
    _key = null;
    if (e != null && e.mounted) e.remove();
  }

  static void _remove(OverlayEntry e) {
    if (identical(_entry, e)) {
      _entry = null;
      _key = null;
    }
    if (e.mounted) e.remove();
  }
}

class _ToastView extends StatefulWidget {
  const _ToastView({
    super.key,
    required this.message,
    required this.title,
    required this.status,
    required this.icon,
    required this.duration,
    required this.onTap,
    required this.onDone,
  });

  final String message;
  final String? title;
  final UiStatus status;
  final IconData icon;
  final Duration duration;
  final VoidCallback? onTap;
  final VoidCallback onDone;

  @override
  State<_ToastView> createState() => _ToastViewState();
}

class _ToastViewState extends State<_ToastView> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: UiDuration.slow, reverseDuration: UiDuration.normal);
  late final Animation<Offset> _slide = Tween(begin: const Offset(0, -1.2), end: Offset.zero).animate(CurvedAnimation(parent: _c, curve: UiCurve.emphasized, reverseCurve: Curves.easeInCubic));
  Timer? _timer;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _timer = Timer(widget.duration, close);
  }

  void close() {
    if (_closing || !mounted) return;
    _closing = true;
    _timer?.cancel();
    _c.reverse().then((_) {
      if (mounted) widget.onDone();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final t = context.tone(widget.status);
    final top = MediaQuery.paddingOf(context).top + UiSpace.sm;
    final card = Material(
      color: context.isDark ? cs.surfaceContainerHigh : cs.surfaceContainerLowest,
      borderRadius: context.tokens.lg,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(UiSpace.md),
        decoration: BoxDecoration(
          borderRadius: context.tokens.lg,
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: context.isDark ? 0.4 : 0.12), blurRadius: 24, offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(color: t.container, shape: BoxShape.circle),
              child: Icon(widget.icon, size: 20, color: t.onContainer),
            ),
            const UiGap.md(),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null)
                    Text(widget.title!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                  Text(widget.message, maxLines: 3, overflow: TextOverflow.ellipsis, style: context.text.bodyMedium?.copyWith(color: widget.title == null ? cs.onSurface : cs.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
    return Positioned(
      top: top,
      left: UiSpace.lg,
      right: UiSpace.lg,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _c,
              child: Semantics(
                liveRegion: true,
                container: true,
                child: Dismissible(
                  key: const ValueKey('ui_toast'),
                  direction: DismissDirection.horizontal,
                  onDismissed: (_) {
                    _timer?.cancel();
                    widget.onDone();
                  },
                  child: GestureDetector(
                    onTap: () {
                      widget.onTap?.call();
                      close();
                    },
                    onVerticalDragEnd: (d) {
                      if ((d.primaryVelocity ?? 0) < -100) close();
                    },
                    child: card,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
