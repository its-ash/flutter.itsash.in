part of 'ui_selection.dart';

/// Star rating. Tap or drag across the stars to set it. Read-only when
/// [onChanged] is null.
///
/// ```dart
/// UiRating(value: stars, onChanged: (v) => setState(() => stars = v))
/// UiRating(value: 4.5, allowHalf: true, size: UiSize.sm) // display only
/// ```
class UiRating extends StatelessWidget {
  const UiRating({
    super.key,
    required this.value,
    this.onChanged,
    this.count = 5,
    this.size = UiSize.md,
    this.allowHalf = false,
    this.icon = Icons.star_rounded,
  }) : assert(count > 0);

  /// Current rating, from 0 to [count].
  final double value;

  /// Called with the new rating. Null makes it read-only.
  final ValueChanged<double>? onChanged;

  /// Number of stars.
  final int count;
  final UiSize size;

  /// Allows half steps (0.5, 1.5, ...).
  final bool allowHalf;

  /// Icon used for each star.
  final IconData icon;

  double get _star => switch (size) {
    UiSize.sm => 18,
    UiSize.md => 26,
    UiSize.lg => 34,
  };

  double get _gap => size == UiSize.sm ? UiSpace.xxs : UiSpace.xs;

  double get _step => allowHalf ? 0.5 : 1;

  double _valueAt(BuildContext context, double dx) {
    final slot = _star + _gap;
    final width = slot * count;
    var x = dx.clamp(0, width).toDouble();
    if (Directionality.of(context) == TextDirection.rtl) x = width - x;
    final raw = x / slot;
    final v = allowHalf ? (raw * 2).ceil() / 2 : raw.ceil().toDouble();
    return v.clamp(_step, count.toDouble()).toDouble();
  }

  void _set(BuildContext context, double dx) {
    final v = _valueAt(context, dx);
    if (v != value) onChanged!(v);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final v = value.clamp(0, count).toDouble();
    final stars = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: _gap / 2),
            child: SizedBox.square(
              dimension: _star,
              child: Stack(
                alignment: AlignmentDirectional.centerStart,
                children: [
                  Icon(icon, size: _star, color: c.borderStrong),
                  ClipRect(
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      widthFactor: (v - i).clamp(0, 1).toDouble(),
                      child: Icon(icon, size: _star, color: c.warning),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
    final label = '${_formatNumber(v)} of $count';
    if (onChanged == null) {
      return Semantics(
        label: 'Rating',
        value: label,
        child: ExcludeSemantics(
          child: Align(alignment: AlignmentDirectional.centerStart, widthFactor: 1, heightFactor: 1, child: stars),
        ),
      );
    }
    final up = (v + _step).clamp(_step, count.toDouble()).toDouble();
    final down = (v - _step).clamp(_step, count.toDouble()).toDouble();
    return Semantics(
      label: 'Rating',
      value: label,
      increasedValue: '${_formatNumber(up)} of $count',
      decreasedValue: '${_formatNumber(down)} of $count',
      onIncrease: () => onChanged!(up),
      onDecrease: () => onChanged!(down),
      child: ExcludeSemantics(
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          widthFactor: 1,
          heightFactor: 1,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            // Local x of this detector maps straight to star slots.
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => _set(context, d.localPosition.dx),
              onHorizontalDragStart: (d) => _set(context, d.localPosition.dx),
              onHorizontalDragUpdate: (d) => _set(context, d.localPosition.dx),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: _star < 40 ? (40 - _star) / 2 : 0),
                child: stars,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
