import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/feedback/ui_progress.dart';
import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';

class UiRestTimer extends StatefulWidget {
  const UiRestTimer({
    super.key,
    this.duration = const Duration(seconds: 90),
    this.step = const Duration(seconds: 15),
    this.autoStart = true,
    this.onDone,
    this.onSkip,
    this.label = 'Rest',
    this.size = 220,
    this.color,
  });

  final Duration duration;
  final Duration step;
  final bool autoStart;
  final VoidCallback? onDone;
  final VoidCallback? onSkip;
  final String label;
  final double size;
  final Color? color;

  @override
  State<UiRestTimer> createState() => _UiRestTimerState();
}

class _UiRestTimerState extends State<UiRestTimer> {
  Timer? _timer;
  DateTime? _end;
  late Duration _total;
  late Duration _left;

  bool get _running => _timer != null;

  Duration _safe(Duration d) => d.isNegative ? Duration.zero : d;

  @override
  void initState() {
    super.initState();
    _reset(start: widget.autoStart);
  }

  @override
  void didUpdateWidget(UiRestTimer old) {
    super.didUpdateWidget(old);
    if (old.duration != widget.duration) _reset(start: widget.autoStart);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _reset({required bool start}) {
    _timer?.cancel();
    _timer = null;
    _total = _safe(widget.duration);
    _left = _total;
    if (start && _left > Duration.zero) _start();
  }

  void _start() {
    if (_left <= Duration.zero) {
      _total = _safe(widget.duration);
      _left = _total;
      if (_left <= Duration.zero) return;
    }
    _end = DateTime.now().add(_left);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  void _pause() {
    _timer?.cancel();
    _timer = null;
  }

  void _tick() {
    if (!mounted) return;
    final end = _end;
    if (end == null) return;
    final left = _safe(end.difference(DateTime.now()));
    setState(() => _left = left);
    if (left == Duration.zero) _finish(widget.onDone);
  }

  void _finish(VoidCallback? cb) {
    _pause();
    setState(() => _left = Duration.zero);
    HapticFeedback.mediumImpact();
    cb?.call();
  }

  void _adjust(int sign) {
    final step = _safe(widget.step);
    final next = _safe(_left + step * sign);
    setState(() {
      _left = next;
      if (_left > _total) _total = _left;
      if (_running) _end = DateTime.now().add(_left);
    });
    if (next == Duration.zero && _running) _finish(widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final accent = widget.color ?? cs.primary;
    final size = math.max(120.0, widget.size);
    final progress = _total.inMilliseconds == 0 ? 0.0 : (_left.inMilliseconds / _total.inMilliseconds).clamp(0.0, 1.0);
    final secs = (_left.inMilliseconds / 1000).ceil();
    final clock = UiFormat.duration(Duration(seconds: secs));
    final stepSecs = _safe(widget.step).inSeconds;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Semantics(
          label: '${widget.label} timer, $clock remaining${_running ? '' : ', paused'}',
          liveRegion: true,
          excludeSemantics: true,
          child: UiProgressRing(
            progress,
            size: size,
            stroke: size * 0.06,
            color: accent,
            trackColor: accent.withValues(alpha: 0.14),
            showPercent: false,
            animate: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.label.toUpperCase(),
                  style: context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 1.2),
                ),
                Text(
                  clock,
                  style: context.text.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: size * 0.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
        const UiGap.xl(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiButton.outline('−${stepSecs}s', size: UiSize.sm, onPressed: stepSecs > 0 && _left > Duration.zero ? () => _adjust(-1) : null),
            const UiGap.lg(),
            UiIconButton(
              _running ? Icons.pause_rounded : Icons.play_arrow_rounded,
              tooltip: _running ? 'Pause' : 'Start',
              variant: UiIconButtonVariant.filled,
              color: accent,
              size: UiSize.lg,
              onPressed: () => setState(() => _running ? _pause() : _start()),
            ),
            const UiGap.lg(),
            UiButton.outline('+${stepSecs}s', size: UiSize.sm, onPressed: stepSecs > 0 ? () => _adjust(1) : null),
          ],
        ),
        const UiGap.sm(),
        UiButton.ghost('Skip', size: UiSize.sm, onPressed: () => _finish(widget.onSkip ?? widget.onDone)),
      ],
    );
  }
}

