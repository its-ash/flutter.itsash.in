part of 'ui_button.dart';

/// Lays out actions in a row with gaps. When they do not fit, stacks them
/// full width, primary (last) first. Use for dialog and sheet footers.
///
/// ```dart
/// UiButtonBar([
///   UiButton('Cancel', variant: UiButtonVariant.outline, onPressed: close),
///   UiButton('Save', onPressed: save),
/// ])
/// ```
class UiButtonBar extends MultiChildRenderObjectWidget {
  const UiButtonBar(
    List<Widget> children, {
    super.key,
    this.spacing = UiSpace.sm,
    this.alignment = MainAxisAlignment.end,
    this.expand = false,
    this.primaryFirstWhenStacked = true,
  }) : super(children: children);

  /// Gap between buttons, in both row and stacked layouts.
  final double spacing;

  /// Horizontal placement in the row layout.
  final MainAxisAlignment alignment;

  /// In the row layout, gives every button the same width and fills the row.
  final bool expand;

  /// Reverses the order when stacked so the last (primary) action is on top.
  final bool primaryFirstWhenStacked;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderButtonBar(
    spacing: spacing,
    alignment: alignment,
    expand: expand,
    reverseStacked: primaryFirstWhenStacked,
    textDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
  );

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) {
    (renderObject as _RenderButtonBar)
      ..spacing = spacing
      ..alignment = alignment
      ..expand = expand
      ..reverseStacked = primaryFirstWhenStacked
      ..textDirection = Directionality.maybeOf(context) ?? TextDirection.ltr;
  }
}

class _BarParentData extends ContainerBoxParentData<RenderBox> {}

class _RenderButtonBar extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _BarParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _BarParentData> {
  _RenderButtonBar({
    required double spacing,
    required MainAxisAlignment alignment,
    required bool expand,
    required bool reverseStacked,
    required TextDirection textDirection,
  }) : _spacing = spacing,
       _alignment = alignment,
       _expand = expand,
       _reverseStacked = reverseStacked,
       _textDirection = textDirection;

  double _spacing;
  set spacing(double v) {
    if (v == _spacing) return;
    _spacing = v;
    markNeedsLayout();
  }

  MainAxisAlignment _alignment;
  set alignment(MainAxisAlignment v) {
    if (v == _alignment) return;
    _alignment = v;
    markNeedsLayout();
  }

  bool _expand;
  set expand(bool v) {
    if (v == _expand) return;
    _expand = v;
    markNeedsLayout();
  }

  bool _reverseStacked;
  set reverseStacked(bool v) {
    if (v == _reverseStacked) return;
    _reverseStacked = v;
    markNeedsLayout();
  }

  TextDirection _textDirection;
  set textDirection(TextDirection v) {
    if (v == _textDirection) return;
    _textDirection = v;
    markNeedsLayout();
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _BarParentData) child.parentData = _BarParentData();
  }

  List<RenderBox> get _kids {
    final list = <RenderBox>[];
    var child = firstChild;
    while (child != null) {
      list.add(child);
      child = childAfter(child);
    }
    return list;
  }

  double _rowWidth(List<RenderBox> kids) {
    if (kids.isEmpty) return 0;
    final widths = kids.map((k) => k.getMaxIntrinsicWidth(double.infinity));
    final content = _expand ? widths.reduce(math.max) * kids.length : widths.fold(0.0, (a, b) => a + b);
    return content + _spacing * (kids.length - 1);
  }

  bool _fitsRow(List<RenderBox> kids, double maxWidth) => !maxWidth.isFinite || _rowWidth(kids) <= maxWidth + 0.5;

  Size _run(BoxConstraints constraints, {required bool dry}) {
    final kids = _kids;
    if (kids.isEmpty) return constraints.smallest;
    Size place(RenderBox k, BoxConstraints bc) {
      if (dry) return k.getDryLayout(bc);
      k.layout(bc, parentUsesSize: true);
      return k.size;
    }

    final n = kids.length;
    final maxW = constraints.maxWidth;
    if (_fitsRow(kids, maxW)) {
      double? tight;
      if (_expand) {
        tight = maxW.isFinite
            ? (maxW - _spacing * (n - 1)) / n
            : kids.map((k) => k.getMaxIntrinsicWidth(double.infinity)).reduce(math.max);
      }
      final childConstraints = tight == null
          ? BoxConstraints(maxHeight: constraints.maxHeight)
          : BoxConstraints(minWidth: tight, maxWidth: tight, maxHeight: constraints.maxHeight);
      final sizes = [for (final k in kids) place(k, childConstraints)];
      final content = sizes.fold(0.0, (a, s) => a + s.width) + _spacing * (n - 1);
      final height = sizes.map((s) => s.height).reduce(math.max);
      final size = constraints.constrain(Size(maxW.isFinite ? maxW : content, height));
      if (!dry) {
        final free = math.max(0.0, size.width - content);
        var lead = 0.0;
        var gap = _spacing;
        switch (_alignment) {
          case MainAxisAlignment.start:
            break;
          case MainAxisAlignment.end:
            lead = free;
          case MainAxisAlignment.center:
            lead = free / 2;
          case MainAxisAlignment.spaceBetween:
            if (n > 1) gap += free / (n - 1);
          case MainAxisAlignment.spaceAround:
            lead = free / n / 2;
            gap += free / n;
          case MainAxisAlignment.spaceEvenly:
            lead = free / (n + 1);
            gap += free / (n + 1);
        }
        var x = lead;
        for (var i = 0; i < n; i++) {
          final s = sizes[i];
          final dx = _textDirection == TextDirection.rtl ? size.width - x - s.width : x;
          (kids[i].parentData! as _BarParentData).offset = Offset(dx, (size.height - s.height) / 2);
          x += s.width + gap;
        }
      }
      return size;
    }

    final ordered = _reverseStacked ? kids.reversed.toList() : kids;
    final childConstraints = BoxConstraints(minWidth: maxW, maxWidth: maxW);
    var y = 0.0;
    for (var i = 0; i < n; i++) {
      final s = place(ordered[i], childConstraints);
      if (!dry) (ordered[i].parentData! as _BarParentData).offset = Offset(0, y);
      y += s.height + (i < n - 1 ? _spacing : 0);
    }
    return constraints.constrain(Size(maxW, y));
  }

  @override
  void performLayout() {
    size = _run(constraints, dry: false);
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) => _run(constraints, dry: true);

  @override
  double computeMinIntrinsicWidth(double height) =>
      _kids.fold(0.0, (m, k) => math.max(m, k.getMinIntrinsicWidth(height)));

  @override
  double computeMaxIntrinsicWidth(double height) => _rowWidth(_kids);

  @override
  double computeMinIntrinsicHeight(double width) => _intrinsicHeight(width);

  @override
  double computeMaxIntrinsicHeight(double width) => _intrinsicHeight(width);

  double _intrinsicHeight(double width) {
    final kids = _kids;
    if (kids.isEmpty) return 0;
    if (_fitsRow(kids, width)) {
      return kids.map((k) => k.getMaxIntrinsicHeight(double.infinity)).reduce(math.max);
    }
    return kids.fold(0.0, (a, k) => a + k.getMaxIntrinsicHeight(width)) + _spacing * (kids.length - 1);
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      defaultComputeDistanceToHighestActualBaseline(baseline);

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position);

  @override
  void paint(PaintingContext context, Offset offset) => defaultPaint(context, offset);
}
