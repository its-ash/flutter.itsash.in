import 'package:flutter/material.dart';

class UiMarquee extends StatefulWidget {
  const UiMarquee(
    this.text, {
    super.key,
    this.style,
    this.velocity = 40,
    this.gap = 48,
    this.pause = const Duration(seconds: 1),
    this.fadeEdges = true,
  });

  final String text;
  final TextStyle? style;
  final double velocity;
  final double gap;
  final Duration pause;
  final bool fadeEdges;

  @override
  State<UiMarquee> createState() => _UiMarqueeState();
}

class _UiMarqueeState extends State<UiMarquee> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _sync(Duration? total) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (total == null) {
        if (_c.isAnimating) _c.stop();
        _c.value = 0;
        return;
      }
      if (_c.duration != total || !_c.isAnimating) {
        _c.duration = total;
        _c.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = DefaultTextStyle.of(context).style.merge(widget.style);
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Semantics(
      label: widget.text,
      excludeSemantics: true,
      child: LayoutBuilder(
        builder: (context, box) {
          final tp = TextPainter(
            text: TextSpan(text: widget.text, style: style),
            maxLines: 1,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final w = tp.width;
          final h = tp.height;
          tp.dispose();
          final plain = Text(widget.text, style: style, maxLines: 1, overflow: TextOverflow.ellipsis, softWrap: false);
          if (!box.hasBoundedWidth || w <= box.maxWidth || reduce || widget.velocity <= 0) {
            _sync(null);
            return plain;
          }
          final gap = widget.gap < 0 ? 0.0 : widget.gap;
          final distance = w + gap;
          final moveMs = distance / widget.velocity * 1000;
          final pauseMs = widget.pause.inMilliseconds < 0 ? 0 : widget.pause.inMilliseconds;
          final totalMs = moveMs + pauseMs;
          _sync(Duration(milliseconds: totalMs.round()));
          final line = Text(widget.text, style: style, maxLines: 1, softWrap: false);
          Widget strip = SizedBox(
            width: box.maxWidth,
            height: h,
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, _) {
                final t = _c.value * totalMs;
                final dx = t <= pauseMs ? 0.0 : -(t - pauseMs) / moveMs * distance;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(left: dx, top: 0, child: line),
                    Positioned(left: dx + distance, top: 0, child: line),
                  ],
                );
              },
            ),
          );
          if (widget.fadeEdges) {
            strip = ShaderMask(
              blendMode: BlendMode.dstIn,
              shaderCallback: (r) => const LinearGradient(
                colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
                stops: [0, 0.06, 0.94, 1],
              ).createShader(r),
              child: strip,
            );
          }
          return ClipRect(child: strip);
        },
      ),
    );
  }
}
