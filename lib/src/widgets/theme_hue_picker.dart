import 'package:flutter/material.dart';

/// A free-form color picker: a hue strip plus a saturation/lightness
/// square, built entirely from [Container]/[GestureDetector] — no extra
/// package. Complements [ThemeColorPicker], which only picks from a fixed
/// swatch list.
class ThemeHuePicker extends StatefulWidget {
  const ThemeHuePicker({
    super.key,
    required this.color,
    required this.onChanged,
    this.squareSize = 200,
    this.stripWidth = 28,
  });

  final Color color;
  final ValueChanged<Color> onChanged;
  final double squareSize;
  final double stripWidth;

  @override
  State<ThemeHuePicker> createState() => _ThemeHuePickerState();
}

class _ThemeHuePickerState extends State<ThemeHuePicker> {
  late HSVColor _hsv = HSVColor.fromColor(widget.color);

  @override
  void didUpdateWidget(covariant ThemeHuePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      _hsv = HSVColor.fromColor(widget.color);
    }
  }

  void _emit(HSVColor hsv) {
    setState(() => _hsv = hsv);
    widget.onChanged(hsv.toColor());
  }

  void _onSquarePan(Offset local) {
    final s = (local.dx / widget.squareSize).clamp(0.0, 1.0);
    final v = 1 - (local.dy / widget.squareSize).clamp(0.0, 1.0);
    _emit(_hsv.withSaturation(s).withValue(v));
  }

  void _onStripPan(double dy) {
    final hue = (dy / widget.squareSize).clamp(0.0, 1.0) * 360;
    _emit(_hsv.withHue(hue));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pureHue = HSVColor.fromAHSV(1, _hsv.hue, 1, 1).toColor();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onPanDown: (d) => _onSquarePan(d.localPosition),
          onPanUpdate: (d) => _onSquarePan(d.localPosition),
          child: Container(
            width: widget.squareSize,
            height: widget.squareSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_cardRadius(theme)),
              gradient: LinearGradient(colors: [Colors.white, pureHue]),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_cardRadius(theme)),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black],
              ),
            ),
            child: CustomPaint(
              painter: _ThumbPainter(
                Offset(_hsv.saturation * widget.squareSize, (1 - _hsv.value) * widget.squareSize),
                widget.color,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onPanDown: (d) => _onStripPan(d.localPosition.dy),
          onPanUpdate: (d) => _onStripPan(d.localPosition.dy),
          child: Container(
            width: widget.stripWidth,
            height: widget.squareSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(widget.stripWidth / 2),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFFF0000),
                  Color(0xFFFFFF00),
                  Color(0xFF00FF00),
                  Color(0xFF00FFFF),
                  Color(0xFF0000FF),
                  Color(0xFFFF00FF),
                  Color(0xFFFF0000),
                ],
              ),
            ),
            child: CustomPaint(
              painter: _StripThumbPainter(_hsv.hue / 360 * widget.squareSize, widget.stripWidth),
            ),
          ),
        ),
      ],
    );
  }

  double _cardRadius(ThemeData theme) {
    final shape = theme.cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 16;
  }
}

class _ThumbPainter extends CustomPainter {
  _ThumbPainter(this.position, this.color);
  final Offset position;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(position, 9, Paint()..color = Colors.white);
    canvas.drawCircle(position, 9, Paint()..color = Colors.black26..style = PaintingStyle.stroke..strokeWidth = 1.5);
    canvas.drawCircle(position, 6, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_ThumbPainter oldDelegate) => oldDelegate.position != position || oldDelegate.color != color;
}

class _StripThumbPainter extends CustomPainter {
  _StripThumbPainter(this.dy, this.width);
  final double dy;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(-2, dy - 4, width + 4, 8);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawRRect(rrect, Paint()..color = Colors.white);
    canvas.drawRRect(rrect, Paint()..color = Colors.black38..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  @override
  bool shouldRepaint(_StripThumbPainter oldDelegate) => oldDelegate.dy != dy;
}
