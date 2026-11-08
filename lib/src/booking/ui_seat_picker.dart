import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

typedef UiSeat = ({int row, int col});

class UiSeatPicker extends StatefulWidget {
  const UiSeatPicker({
    super.key,
    required this.rows,
    required this.columns,
    this.selected = const {},
    this.unavailable = const {},
    this.hidden = const {},
    this.aisleAfterColumns = const {},
    this.aisleAfterRows = const {},
    this.maxSelection = 8,
    this.onChanged,
    this.screenLabel = 'Screen',
    this.legend = true,
    this.labels = true,
    this.seatSize = 28,
  });

  final int rows;
  final int columns;
  final Set<UiSeat> selected;
  final Set<UiSeat> unavailable;
  final Set<UiSeat> hidden;
  final Set<int> aisleAfterColumns;
  final Set<int> aisleAfterRows;
  final int maxSelection;
  final ValueChanged<Set<UiSeat>>? onChanged;
  final String? screenLabel;
  final bool legend;
  final bool labels;
  final double seatSize;

  static String rowName(int r) {
    var n = r < 0 ? 0 : r;
    var s = '';
    do {
      s = String.fromCharCode(65 + n % 26) + s;
      n = n ~/ 26 - 1;
    } while (n >= 0);
    return s;
  }

  static String seatName(UiSeat s) => '${rowName(s.row)}${s.col + 1}';

  @override
  State<UiSeatPicker> createState() => _UiSeatPickerState();
}

class _UiSeatPickerState extends State<UiSeatPicker> {
  late Set<UiSeat> _sel = _clean(widget.selected);

  int get _rows => widget.rows.clamp(1, 60);
  int get _cols => widget.columns.clamp(1, 60);
  int get _max => widget.maxSelection < 1 ? 1 : widget.maxSelection;

  Set<UiSeat> _clean(Set<UiSeat> s) => {
        for (final x in s)
          if (x.row >= 0 &&
              x.row < _rows &&
              x.col >= 0 &&
              x.col < _cols &&
              !widget.unavailable.contains(x) &&
              !widget.hidden.contains(x))
            x,
      }.take(_max).toSet();

  @override
  void didUpdateWidget(UiSeatPicker old) {
    super.didUpdateWidget(old);
    if (!setEquals(old.selected, widget.selected) ||
        !setEquals(old.unavailable, widget.unavailable) ||
        old.rows != widget.rows ||
        old.columns != widget.columns) {
      _sel = _clean(widget.selected);
    }
  }

  void _tap(UiSeat s) {
    final next = {..._sel};
    if (next.contains(s)) {
      next.remove(s);
    } else if (_max == 1) {
      next
        ..clear()
        ..add(s);
    } else if (next.length >= _max) {
      HapticFeedback.heavyImpact();
      return;
    } else {
      next.add(s);
    }
    HapticFeedback.selectionClick();
    setState(() => _sel = next);
    widget.onChanged?.call(Set.unmodifiable(next));
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final size = widget.seatSize.clamp(16.0, 56.0);
    const gap = 6.0;
    final aisle = size * 0.7;
    final labelStyle = context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700);

    Widget seat(UiSeat s) {
      if (widget.hidden.contains(s)) return SizedBox(width: size, height: size);
      final off = widget.unavailable.contains(s);
      final sel = _sel.contains(s);
      final name = UiSeatPicker.seatName(s);
      return Semantics(
        button: !off,
        enabled: !off,
        selected: sel,
        label: 'Seat $name${off ? ', unavailable' : ''}',
        child: ExcludeSemantics(
          child: GestureDetector(
            onTap: off ? null : () => _tap(s),
            child: AnimatedContainer(
              duration: UiDuration.fast,
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: _seatDeco(cs, sel: sel, off: off, size: size),
              child: sel && size >= 24
                  ? Text(
                      '${s.col + 1}',
                      style: context.text.labelSmall?.copyWith(color: cs.onPrimary, fontWeight: FontWeight.w800, fontSize: size * 0.36),
                    )
                  : null,
            ),
          ),
        ),
      );
    }

    final grid = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var r = 0; r < _rows; r++)
          Padding(
            padding: EdgeInsets.only(bottom: widget.aisleAfterRows.contains(r) ? aisle : gap),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.labels) SizedBox(width: 22, child: Text(UiSeatPicker.rowName(r), style: labelStyle)),
                for (var c = 0; c < _cols; c++) ...[
                  seat((row: r, col: c)),
                  if (c < _cols - 1) SizedBox(width: widget.aisleAfterColumns.contains(c) ? aisle : gap),
                ],
                if (widget.labels) const SizedBox(width: 22),
              ],
            ),
          ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.screenLabel != null) ...[
          SizedBox(
            height: 28,
            width: double.infinity,
            child: CustomPaint(painter: _ScreenPainter(cs.primary)),
          ),
          Text(widget.screenLabel!.toUpperCase(), style: labelStyle?.copyWith(letterSpacing: 2)),
          const UiGap.xl(),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: grid,
        ),
        if (widget.legend) ...[
          const UiGap.lg(),
          Wrap(
            spacing: UiSpace.lg,
            runSpacing: UiSpace.sm,
            alignment: WrapAlignment.center,
            children: [
              _legend(context, 'Available', _seatDeco(cs, sel: false, off: false, size: 16)),
              _legend(context, 'Selected', _seatDeco(cs, sel: true, off: false, size: 16)),
              _legend(context, 'Taken', _seatDeco(cs, sel: false, off: true, size: 16)),
            ],
          ),
        ],
      ],
    );
  }

  BoxDecoration _seatDeco(ColorScheme cs, {required bool sel, required bool off, required double size}) => BoxDecoration(
        color: sel ? cs.primary : (off ? cs.onSurface.withValues(alpha: 0.14) : cs.surfaceContainerLow),
        border: sel || off ? null : Border.all(color: cs.outline.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.vertical(top: Radius.circular(size * 0.32), bottom: Radius.circular(size * 0.14)),
      );

  Widget _legend(BuildContext context, String label, BoxDecoration deco) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 16, height: 16, decoration: deco),
          const SizedBox(width: UiSpace.xs + 2),
          Text(label, style: context.text.labelMedium?.copyWith(color: context.colors.onSurfaceVariant)),
        ],
      );
}

class _ScreenPainter extends CustomPainter {
  _ScreenPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final inset = w * 0.1;
    final path = Path()
      ..moveTo(inset, size.height)
      ..quadraticBezierTo(w / 2, 0, w - inset, size.height);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..shader = LinearGradient(
          colors: [color.withValues(alpha: 0.1), color, color.withValues(alpha: 0.1)],
        ).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_ScreenPainter old) => old.color != color;
}
