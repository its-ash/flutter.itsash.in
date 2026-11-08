import 'dart:async';

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';

class UiWorkoutTimer extends StatefulWidget {
  const UiWorkoutTimer({
    super.key,
    this.initial = Duration.zero,
    this.autoStart = false,
    this.label,
    this.onChanged,
    this.onReset,
    this.showReset = true,
  });

  final Duration initial;
  final bool autoStart;
  final String? label;
  final ValueChanged<Duration>? onChanged;
  final VoidCallback? onReset;
  final bool showReset;

  @override
  State<UiWorkoutTimer> createState() => _UiWorkoutTimerState();
}

class _UiWorkoutTimerState extends State<UiWorkoutTimer> {
  final _sw = Stopwatch();
  Timer? _timer;
  late Duration _offset = widget.initial.isNegative ? Duration.zero : widget.initial;
  int _lastSec = -1;

  Duration get _elapsed => _offset + _sw.elapsed;

  @override
  void initState() {
    super.initState();
    if (widget.autoStart) _start();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sw.stop();
    super.dispose();
  }

  void _start() {
    _sw.start();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (!mounted) return;
      final s = _elapsed.inSeconds;
      if (s == _lastSec) return;
      _lastSec = s;
      setState(() {});
      widget.onChanged?.call(_elapsed);
    });
  }

  void _pause() {
    _sw.stop();
    _timer?.cancel();
    _timer = null;
  }

  void _reset() {
    _pause();
    _sw.reset();
    _offset = Duration.zero;
    _lastSec = -1;
    widget.onChanged?.call(Duration.zero);
    widget.onReset?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final running = _sw.isRunning;
    final clock = UiFormat.duration(_elapsed);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null)
          Text(
            widget.label!.toUpperCase(),
            style: context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 1.2),
          ),
        Semantics(
          label: '${widget.label ?? 'Workout'} time $clock${running ? '' : ', paused'}',
          child: ExcludeSemantics(
            child: Text(
              clock,
              style: context.text.displayLarge?.copyWith(
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: running ? cs.onSurface : cs.onSurfaceVariant,
              ),
            ),
          ),
        ),
        const UiGap.lg(),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showReset) ...[
              UiIconButton(
                Icons.restart_alt_rounded,
                tooltip: 'Reset',
                onPressed: _elapsed > Duration.zero ? () => setState(_reset) : null,
              ),
              const UiGap.lg(),
            ],
            UiIconButton(
              running ? Icons.pause_rounded : Icons.play_arrow_rounded,
              tooltip: running ? 'Pause' : 'Start',
              variant: UiIconButtonVariant.filled,
              size: UiSize.lg,
              onPressed: () => setState(running ? _pause : _start),
            ),
          ],
        ),
      ],
    );
  }
}
