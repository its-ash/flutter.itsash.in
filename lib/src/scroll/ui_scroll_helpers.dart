import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';

class UiScrollToTop extends StatefulWidget {
  const UiScrollToTop({
    super.key,
    required this.controller,
    required this.child,
    this.threshold = 600,
    this.icon = Icons.arrow_upward_rounded,
    this.tooltip = 'Back to top',
    this.padding = const EdgeInsets.all(UiSpace.lg),
    this.alignment = AlignmentDirectional.bottomEnd,
  });

  final ScrollController controller;
  final Widget child;
  final double threshold;
  final IconData icon;
  final String tooltip;
  final EdgeInsetsGeometry padding;
  final AlignmentGeometry alignment;

  @override
  State<UiScrollToTop> createState() => _UiScrollToTopState();
}

class _UiScrollToTopState extends State<UiScrollToTop> {
  bool _show = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_check);
  }

  @override
  void didUpdateWidget(UiScrollToTop old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_check);
      widget.controller.addListener(_check);
      _check();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_check);
    super.dispose();
  }

  double get _offset => widget.controller.hasClients ? widget.controller.positions.first.pixels : 0;

  void _check() {
    final s = _offset > widget.threshold;
    if (s != _show && mounted) setState(() => _show = s);
  }

  void _top() {
    if (!widget.controller.hasClients) return;
    final ms = (_offset / 6).clamp(250, 700).round();
    widget.controller.animateTo(0, duration: Duration(milliseconds: ms), curve: UiCurve.emphasized);
  }

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          widget.child,
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: widget.padding,
                child: Align(
                  alignment: widget.alignment,
                  child: IgnorePointer(
                    ignoring: !_show,
                    child: AnimatedScale(
                      scale: _show ? 1 : 0.6,
                      duration: UiDuration.normal,
                      curve: UiCurve.standard,
                      child: AnimatedOpacity(
                        opacity: _show ? 1 : 0,
                        duration: UiDuration.normal,
                        child: FloatingActionButton.small(
                          heroTag: null,
                          tooltip: widget.tooltip,
                          onPressed: _top,
                          child: Icon(widget.icon),
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

class UiLazyBuilder extends StatefulWidget {
  const UiLazyBuilder({
    super.key,
    required this.builder,
    this.placeholder,
    this.placeholderHeight = 200,
    this.margin = 200,
  });

  final WidgetBuilder builder;
  final Widget? placeholder;
  final double placeholderHeight;
  final double margin;

  @override
  State<UiLazyBuilder> createState() => _UiLazyBuilderState();
}

class _UiLazyBuilderState extends State<UiLazyBuilder> {
  bool _visible = false;
  ScrollPosition? _pos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_visible) return;
    final p = Scrollable.maybeOf(context)?.position;
    if (p != _pos) {
      _pos?.removeListener(_check);
      _pos = p;
      _pos?.addListener(_check);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _check());
  }

  @override
  void dispose() {
    _pos?.removeListener(_check);
    super.dispose();
  }

  void _check() {
    if (_visible || !mounted) return;
    final me = context.findRenderObject();
    if (me is! RenderBox || !me.attached || !me.hasSize) return;
    final scrollable = Scrollable.maybeOf(context);
    var show = scrollable == null;
    if (!show) {
      final vp = scrollable.context.findRenderObject();
      if (vp is! RenderBox || !vp.attached || !vp.hasSize) return;
      final view = (vp.localToGlobal(Offset.zero) & vp.size).inflate(widget.margin);
      final rect = me.localToGlobal(Offset.zero) & me.size;
      show = view.overlaps(rect) || (rect.isEmpty && view.contains(rect.topLeft));
    }
    if (!show) return;
    _pos?.removeListener(_check);
    _pos = null;
    setState(() => _visible = true);
  }

  @override
  Widget build(BuildContext context) =>
      _visible ? widget.builder(context) : widget.placeholder ?? SizedBox(height: widget.placeholderHeight, width: double.infinity);
}
