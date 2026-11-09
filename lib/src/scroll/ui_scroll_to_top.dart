import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Shows a floating "back to top" button over [child] once [controller] has
/// scrolled past [threshold]. Tapping it scrolls smoothly to the top.
///
/// ```dart
/// UiScrollToTop(controller: scroll, child: ListView(controller: scroll, children: rows))
/// ```
class UiScrollToTop extends StatefulWidget {
  const UiScrollToTop({
    super.key,
    required this.controller,
    required this.child,
    this.threshold = 600,
    this.label,
    this.alignment = Alignment.bottomRight,
  });

  /// Controller of the scrollable inside [child]. Not disposed here.
  final ScrollController controller;
  final Widget child;

  /// Scroll offset in pixels after which the button appears.
  final double threshold;

  /// Optional text next to the arrow, e.g. "Back to top".
  final String? label;

  /// Where the button sits. Use `bottomCenter` for a pill with a label.
  final Alignment alignment;

  @override
  State<UiScrollToTop> createState() => _UiScrollToTopState();
}

class _UiScrollToTopState extends State<UiScrollToTop> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(UiScrollToTop old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onScroll);
      widget.controller.addListener(_onScroll);
      _onScroll();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final c = widget.controller;
    final offset = c.hasClients ? c.positions.first.pixels : 0.0;
    final shown = offset > widget.threshold;
    if (shown != _shown) setState(() => _shown = shown);
  }

  void _toTop() {
    final c = widget.controller;
    if (!c.hasClients) return;
    final position = c.positions.first;
    final duration = context.motion(const Duration(milliseconds: 500));
    if (duration == Duration.zero || position.pixels > 6000) {
      // Very long jumps: snap most of the way, then animate the last part.
      if (duration == Duration.zero) {
        position.jumpTo(0);
        return;
      }
      position.jumpTo(1200);
    }
    position.animateTo(0, duration: duration, curve: UiMotion.emphasized);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = context.motion(UiMotion.normal);
    final label = widget.label;
    final tooltip = label ?? 'Back to top';

    final button = Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: Material(
          color: colors.surfaceRaised,
          shape: StadiumBorder(side: BorderSide(color: colors.border)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: _toTop,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: label == null ? UiSpace.sm + 2 : UiSpace.lg),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 20, color: colors.text),
                    if (label != null) ...[
                      const SizedBox(width: UiSpace.xs + 2),
                      Flexible(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelLarge?.copyWith(color: colors.text),
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
    );

    return Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(UiSpace.lg),
              child: Align(
                alignment: widget.alignment,
                child: IgnorePointer(
                  ignoring: !_shown,
                  child: AnimatedSlide(
                    offset: _shown ? Offset.zero : const Offset(0, 0.4),
                    duration: duration,
                    curve: UiMotion.emphasized,
                    child: AnimatedScale(
                      scale: _shown ? 1 : 0.85,
                      duration: duration,
                      curve: UiMotion.emphasized,
                      child: AnimatedOpacity(
                        opacity: _shown ? 1 : 0,
                        duration: duration,
                        curve: UiMotion.standard,
                        child: DecoratedBox(
                          decoration: ShapeDecoration(shape: const StadiumBorder(), shadows: context.shadowMd),
                          child: button,
                        ),
                      ),
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
