import 'dart:async';

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Where toasts appear on screen.
enum UiToastPosition { top, bottom }

/// Small floating notifications drawn on the app overlay.
///
/// Toasts slide in, stack (up to [maxVisible]), auto-dismiss after
/// `duration`, and can be swiped away sideways.
///
/// ```dart
/// UiToast.show(context, 'Saved', status: UiStatus.success);
/// context.showToast('Copied to clipboard');
/// ```
abstract final class UiToast {
  /// Most toasts visible at once per position. Older ones close first.
  static int maxVisible = 3;

  static _ToastLayer? _layer;
  static int _nextId = 0;

  /// Shows a toast. The future completes when it is dismissed.
  ///
  /// A null [duration] keeps the toast until it is swiped away, its action
  /// is tapped, or [dismissAll] is called. Set [replace] to close every
  /// other toast first.
  static Future<void> show(
    BuildContext context,
    String message, {
    String? title,
    UiStatus status = UiStatus.neutral,
    IconData? icon,
    Duration? duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    UiToastPosition position = UiToastPosition.top,
    bool replace = false,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    // Closing may empty and discard the current layer, so do it before picking one.
    if (replace) dismissAll();
    var layer = _layer;
    if (layer == null || layer.overlay != overlay || !layer.overlay.mounted) {
      layer?.discard();
      layer = _layer = _ToastLayer(overlay);
    }
    final item = _ToastItem(
      id: _nextId++,
      message: message,
      title: title,
      status: status,
      icon: icon,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
      position: position,
    );
    layer.add(item);
    return item.completer.future;
  }

  /// Closes every visible toast.
  static void dismissAll() => _layer?.closeAll();
}

/// Toast and snackbar shortcuts on [BuildContext].
extension UiFeedbackContext on BuildContext {
  /// Same as [UiToast.show].
  Future<void> showToast(
    String message, {
    String? title,
    UiStatus status = UiStatus.neutral,
    IconData? icon,
    Duration? duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
    UiToastPosition position = UiToastPosition.top,
    bool replace = false,
  }) => UiToast.show(
    this,
    message,
    title: title,
    status: status,
    icon: icon,
    duration: duration,
    actionLabel: actionLabel,
    onAction: onAction,
    position: position,
    replace: replace,
  );

  /// Shows a themed [SnackBar], hiding the current one first.
  ///
  /// Pass [status] to add a colored status icon. The future completes when
  /// the snackbar closes.
  Future<SnackBarClosedReason> showSnack(
    String message, {
    String? action,
    VoidCallback? onAction,
    UiStatus? status,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
    bool? persist,
  }) {
    final c = colors;
    // The snackbar sits on the inverse surface, so status colors come from the opposite palette.
    final inverse = c.isDark ? UiColors.light() : UiColors.dark();
    final shownIcon = icon ?? status?.icon;
    final messenger = ScaffoldMessenger.of(this)..hideCurrentSnackBar();
    final style = text.bodyMedium?.copyWith(color: c.onSurfaceInverse);
    return messenger
        .showSnackBar(
          SnackBar(
            duration: duration,
            persist: persist,
            content: Row(
              children: [
                if (shownIcon != null) ...[
                  Icon(
                    shownIcon,
                    size: 18,
                    color: status == null || status == UiStatus.neutral
                        ? c.onSurfaceInverse
                        : inverse.tone(status).color,
                  ),
                  const SizedBox(width: UiSpace.md),
                ],
                Expanded(
                  child: Text(message, style: style, maxLines: 3, overflow: TextOverflow.ellipsis),
                ),
              ],
            ),
            action: action == null ? null : SnackBarAction(label: action, onPressed: onAction ?? () {}),
          ),
        )
        .closed;
  }
}

class _ToastItem {
  _ToastItem({
    required this.id,
    required this.message,
    required this.title,
    required this.status,
    required this.icon,
    required this.duration,
    required this.actionLabel,
    required this.onAction,
    required this.position,
  });

  final int id;
  final String message;
  final String? title;
  final UiStatus status;
  final IconData? icon;
  final Duration? duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final UiToastPosition position;
  final Completer<void> completer = Completer<void>();

  bool closing = false;

  /// Set by the mounted card to run its exit animation.
  VoidCallback? onClose;

  void complete() {
    if (!completer.isCompleted) completer.complete();
  }
}

class _ToastLayer {
  _ToastLayer(this.overlay) {
    entry = OverlayEntry(builder: (_) => _ToastHost(layer: this));
  }

  final OverlayState overlay;
  late final OverlayEntry entry;
  final ValueNotifier<List<_ToastItem>> items = ValueNotifier(const []);
  bool _inserted = false;
  bool _discarded = false;

  void add(_ToastItem item) {
    if (_discarded) return;
    items.value = [...items.value, item];
    if (!_inserted) {
      _inserted = true;
      overlay.insert(entry);
    }
    final open = items.value.where((e) => e.position == item.position && !e.closing).toList();
    for (var i = 0; i < open.length - UiToast.maxVisible; i++) {
      close(open[i]);
    }
  }

  void close(_ToastItem item) {
    if (item.closing) return;
    item.closing = true;
    final onClose = item.onClose;
    if (onClose != null) {
      onClose();
    } else {
      remove(item);
    }
  }

  void closeAll() {
    for (final item in [...items.value]) {
      close(item);
    }
  }

  void remove(_ToastItem item) {
    if (_discarded) return;
    item.complete();
    final next = [...items.value]..remove(item);
    items.value = next;
    if (next.isEmpty) discard();
  }

  /// Removes the overlay entry and completes every pending toast.
  void discard() {
    if (_discarded) return;
    _discarded = true;
    for (final item in items.value) {
      item.complete();
    }
    if (_inserted) entry.remove();
    entry.dispose();
    items.dispose();
    if (UiToast._layer == this) UiToast._layer = null;
  }
}

class _ToastHost extends StatelessWidget {
  const _ToastHost({required this.layer});

  final _ToastLayer layer;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<_ToastItem>>(
      valueListenable: layer.items,
      builder: (context, items, _) {
        final top = items.where((e) => e.position == UiToastPosition.top).toList().reversed.toList();
        final bottom = items.where((e) => e.position == UiToastPosition.bottom).toList();
        final insets = MediaQuery.viewInsetsOf(context);
        Widget stack(List<_ToastItem> list, bool isTop) => Align(
          alignment: isTop ? Alignment.topCenter : Alignment.bottomCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [for (final item in list) _ToastCard(key: ObjectKey(item), item: item, layer: layer)],
              ),
            ),
          ),
        );
        return Stack(
          children: [
            if (top.isNotEmpty)
              Positioned(left: 0, right: 0, top: 0, child: SafeArea(bottom: false, child: stack(top, true))),
            if (bottom.isNotEmpty)
              Positioned(
                left: 0,
                right: 0,
                bottom: insets.bottom,
                child: SafeArea(top: false, child: stack(bottom, false)),
              ),
          ],
        );
      },
    );
  }
}

class _ToastCard extends StatefulWidget {
  const _ToastCard({super.key, required this.item, required this.layer});

  final _ToastItem item;
  final _ToastLayer layer;

  @override
  State<_ToastCard> createState() => _ToastCardState();
}

class _ToastCardState extends State<_ToastCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: UiMotion.normal);
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: UiMotion.emphasized,
    reverseCurve: Curves.easeInCubic,
  );
  Timer? _timer;

  _ToastItem get _item => widget.item;

  @override
  void initState() {
    super.initState();
    _item.onClose = _animateOut;
    _controller.addStatusListener(_onStatus);
    _controller.forward();
    _startTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _controller.duration = context.motion(UiMotion.normal);
  }

  void _startTimer() {
    _timer?.cancel();
    final d = _item.duration;
    if (d != null && !_item.closing) _timer = Timer(d, () => widget.layer.close(_item));
  }

  void _animateOut() {
    _timer?.cancel();
    if (!mounted || _controller.isDismissed) {
      widget.layer.remove(_item);
      return;
    }
    _controller.reverse();
  }

  void _onStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _item.closing) widget.layer.remove(_item);
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_item.onClose == _animateOut) _item.onClose = null;
    _item.complete();
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = context.text;
    final item = _item;
    final tone = c.tone(item.status);
    final isTop = item.position == UiToastPosition.top;
    final icon = item.icon ?? (item.status == UiStatus.neutral ? null : item.status.icon);
    final hasTitle = item.title != null && item.title!.isNotEmpty;

    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.md, UiSpace.md, UiSpace.md),
      decoration: BoxDecoration(
        color: c.surfaceRaised,
        borderRadius: UiRadius.all(UiRadius.lg),
        border: Border.all(color: c.border),
        boxShadow: context.shadowMd,
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: item.status == UiStatus.neutral ? c.textMuted : tone.color),
            const SizedBox(width: UiSpace.md),
          ],
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasTitle) Text(item.title!, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.titleSmall),
                Text(
                  item.message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodyMedium?.copyWith(color: hasTitle ? c.textMuted : c.text),
                ),
              ],
            ),
          ),
          if (item.actionLabel != null) ...[
            const SizedBox(width: UiSpace.sm),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 120),
              child: TextButton(
                onPressed: () {
                  item.onAction?.call();
                  widget.layer.close(item);
                },
                style: TextButton.styleFrom(
                  minimumSize: const Size(40, 36),
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
                  backgroundColor: c.surfaceMuted,
                  foregroundColor: c.text,
                ),
                child: Text(item.actionLabel!, maxLines: 1, overflow: TextOverflow.ellipsis),
              ),
            ),
          ],
        ],
      ),
    );

    return SizeTransition(
      sizeFactor: _curve,
      alignment: isTop ? Alignment.bottomLeft : Alignment.topLeft,
      child: FadeTransition(
        opacity: _curve,
        child: SlideTransition(
          position: Tween<Offset>(begin: Offset(0, isTop ? -0.5 : 0.5), end: Offset.zero).animate(_curve),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
            child: Dismissible(
              key: ObjectKey(item),
              direction: DismissDirection.horizontal,
              onDismissed: (_) {
                _timer?.cancel();
                item.closing = true;
                widget.layer.remove(item);
              },
              child: MouseRegion(
                onEnter: (_) => _timer?.cancel(),
                onExit: (_) => _startTimer(),
                child: Semantics(
                  container: true,
                  liveRegion: true,
                  child: Material(type: MaterialType.transparency, child: card),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
