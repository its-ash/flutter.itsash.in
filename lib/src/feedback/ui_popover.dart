import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Opens and closes a [UiPopover] from code.
class UiPopoverController extends ChangeNotifier {
  bool _open = false;

  bool get isOpen => _open;

  void show() => _set(true);
  void hide() => _set(false);
  void toggle() => _set(!_open);

  void _set(bool value) {
    if (value == _open) return;
    _open = value;
    notifyListeners();
  }
}

/// Floating card anchored to [child]. Tapping outside closes it.
///
/// ```dart
/// UiPopover(popover: (context) => const Text('Details'), child: const Icon(Icons.info_outline))
/// ```
/// Tapping [child] toggles the popover. If [child] is a button, pass a
/// [controller] and call `controller.toggle()` from its `onPressed`.
class UiPopover extends StatefulWidget {
  const UiPopover({
    super.key,
    required this.child,
    required this.popover,
    this.controller,
    this.width = 280,
    this.above = false,
    this.alignEnd = false,
    this.openOnTap = true,
    this.padding = const EdgeInsets.all(UiSpace.lg),
  });

  /// The anchor.
  final Widget child;

  /// Builds the popover's content.
  final WidgetBuilder popover;
  final UiPopoverController? controller;

  /// Card width; shrinks to fit narrow screens.
  final double width;

  /// Opens above the anchor instead of below.
  final bool above;

  /// Aligns the card's right edge with the anchor's right edge.
  final bool alignEnd;

  /// Toggles the popover when [child] is tapped.
  final bool openOnTap;
  final EdgeInsetsGeometry padding;

  @override
  State<UiPopover> createState() => _UiPopoverState();
}

class _UiPopoverState extends State<UiPopover> {
  final _portal = OverlayPortalController();
  final _link = LayerLink();
  UiPopoverController? _own;

  UiPopoverController get _controller => widget.controller ?? (_own ??= UiPopoverController());

  @override
  void initState() {
    super.initState();
    _controller.addListener(_sync);
    if (_controller.isOpen) WidgetsBinding.instance.addPostFrameCallback((_) => _sync());
  }

  @override
  void didUpdateWidget(UiPopover old) {
    super.didUpdateWidget(old);
    final oldController = old.controller ?? _own;
    if (oldController != _controller) {
      oldController?.removeListener(_sync);
      _controller.addListener(_sync);
      _sync();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_sync);
    _own?.dispose();
    super.dispose();
  }

  void _sync() {
    if (!mounted) return;
    if (_controller.isOpen && !_portal.isShowing) {
      _portal.show();
    } else if (!_controller.isOpen && _portal.isShowing) {
      _portal.hide();
    }
  }

  @override
  Widget build(BuildContext context) {
    final above = widget.above;
    final end = widget.alignEnd;
    final targetAnchor = above
        ? (end ? Alignment.topRight : Alignment.topLeft)
        : (end ? Alignment.bottomRight : Alignment.bottomLeft);
    final followerAnchor = above
        ? (end ? Alignment.bottomRight : Alignment.bottomLeft)
        : (end ? Alignment.topRight : Alignment.topLeft);

    return OverlayPortal(
      controller: _portal,
      overlayChildBuilder: (context) {
        final maxWidth = MediaQuery.sizeOf(context).width - UiSpace.lg * 2;
        return Positioned(
          left: 0,
          top: 0,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: targetAnchor,
            followerAnchor: followerAnchor,
            offset: Offset(0, above ? -UiSpace.sm : UiSpace.sm),
            child: TapRegion(
              groupId: this,
              onTapOutside: (_) => _controller.hide(),
              child: _PopoverCard(
                width: widget.width.clamp(0, maxWidth < 0 ? 0 : maxWidth).toDouble(),
                padding: widget.padding,
                fromAbove: above,
                child: Builder(builder: widget.popover),
              ),
            ),
          ),
        );
      },
      child: TapRegion(
        groupId: this,
        child: CompositedTransformTarget(
          link: _link,
          child: widget.openOnTap
              ? GestureDetector(behavior: HitTestBehavior.opaque, onTap: _controller.toggle, child: widget.child)
              : widget.child,
        ),
      ),
    );
  }
}

class _PopoverCard extends StatelessWidget {
  const _PopoverCard({required this.width, required this.padding, required this.fromAbove, required this.child});

  final double width;
  final EdgeInsetsGeometry padding;
  final bool fromAbove;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: context.motion(UiMotion.fast),
      curve: UiMotion.standard,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * (fromAbove ? 4 : -4)), child: child),
      ),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: c.surfaceRaised,
          borderRadius: UiRadius.all(UiRadius.lg),
          border: Border.all(color: c.border),
          boxShadow: context.shadowLg,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

/// Tooltip with the design system's defaults.
///
/// ```dart
/// UiTooltip('Copy link', child: Icon(Icons.link_rounded))
/// ```
class UiTooltip extends StatelessWidget {
  const UiTooltip(this.message, {super.key, required this.child, this.preferBelow, this.triggerMode});

  final String message;
  final Widget child;
  final bool? preferBelow;

  /// How the tooltip is opened on touch. Defaults to long press.
  final TooltipTriggerMode? triggerMode;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      preferBelow: preferBelow,
      triggerMode: triggerMode,
      showDuration: const Duration(milliseconds: 1800),
      child: child,
    );
  }
}
