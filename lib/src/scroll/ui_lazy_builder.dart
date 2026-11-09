import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Builds its child only once it comes within [margin] pixels of the
/// viewport of the nearest scrollable. Until then it shows a placeholder.
///
/// Outside a scrollable the child is built right away. Once built, the
/// child stays built.
///
/// ```dart
/// UiLazyBuilder(builder: (context) => const ExpensiveChart(), placeholderHeight: 240)
/// ```
class UiLazyBuilder extends StatefulWidget {
  const UiLazyBuilder({
    super.key,
    required this.builder,
    this.placeholderHeight = 200,
    this.margin = 300,
    this.placeholder,
  });

  /// Builds the real content.
  final WidgetBuilder builder;

  /// Height of the empty placeholder while the child is not built yet.
  final double placeholderHeight;

  /// Distance in pixels outside the viewport at which building starts.
  final double margin;

  /// Optional widget shown instead of the empty placeholder.
  final Widget? placeholder;

  @override
  State<UiLazyBuilder> createState() => _UiLazyBuilderState();
}

class _UiLazyBuilderState extends State<UiLazyBuilder> {
  bool _visible = false;
  ScrollPosition? _position;
  bool _checkScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_visible) return;
    final position = Scrollable.maybeOf(context)?.position;
    if (position != _position) {
      _position?.removeListener(_scheduleCheck);
      _position = position;
      _position?.addListener(_scheduleCheck);
    }
    _scheduleCheck();
  }

  @override
  void didUpdateWidget(UiLazyBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_visible) _scheduleCheck();
  }

  @override
  void dispose() {
    _position?.removeListener(_scheduleCheck);
    super.dispose();
  }

  void _scheduleCheck() {
    if (_checkScheduled || _visible) return;
    _checkScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkScheduled = false;
      _check();
    });
  }

  void _check() {
    if (_visible || !mounted) return;
    final position = _position;
    final box = context.findRenderObject();
    if (position == null) {
      _show();
      return;
    }
    if (box == null || !box.attached || (box is RenderBox && !box.hasSize)) {
      _scheduleCheck();
      return;
    }
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) {
      _show();
      return;
    }
    final leading = viewport.getOffsetToReveal(box, 0).offset;
    final trailing = viewport.getOffsetToReveal(box, 1).offset;
    final pixels = position.pixels;
    if (pixels >= trailing - widget.margin && pixels <= leading + widget.margin) _show();
  }

  void _show() {
    _position?.removeListener(_scheduleCheck);
    _position = null;
    setState(() => _visible = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_visible) return widget.builder(context);
    return SizedBox(height: widget.placeholderHeight, child: widget.placeholder);
  }
}
