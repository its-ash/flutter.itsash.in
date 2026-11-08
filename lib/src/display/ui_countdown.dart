import 'dart:async';

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiCountdown extends StatefulWidget {
  const UiCountdown({
    super.key,
    this.target,
    this.duration,
    this.onDone,
    this.showDays,
    this.labels = true,
    this.size = UiSize.md,
    this.status,
    this.color,
  });

  final DateTime? target;
  final Duration? duration;
  final VoidCallback? onDone;
  final bool? showDays;
  final bool labels;
  final UiSize size;
  final UiStatus? status;
  final Color? color;

  @override
  State<UiCountdown> createState() => _UiCountdownState();
}

class _UiCountdownState extends State<UiCountdown> {
  late DateTime _end;
  Duration _left = Duration.zero;
  Timer? _timer;
  bool _fired = false;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  @override
  void didUpdateWidget(UiCountdown old) {
    super.didUpdateWidget(old);
    if (old.target != widget.target || old.duration != widget.duration) _reset();
  }

  void _reset() {
    _timer?.cancel();
    _fired = false;
    final d = widget.duration;
    _end = widget.target ?? DateTime.now().add(d == null || d.isNegative ? Duration.zero : d);
    _tick();
    if (_left > Duration.zero) _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    final left = _end.difference(DateTime.now());
    final v = left.isNegative ? Duration.zero : left;
    if (v != _left) setState(() => _left = v);
    if (v == Duration.zero) {
      _timer?.cancel();
      if (!_fired) {
        _fired = true;
        final cb = widget.onDone;
        if (cb != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) cb();
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final secs = (_left.inMilliseconds / 1000).ceil();
    final d = secs ~/ 86400;
    final h = secs % 86400 ~/ 3600;
    final m = secs % 3600 ~/ 60;
    final s = secs % 60;
    final days = widget.showDays ?? d > 0;
    final hh = days ? h : h + d * 24;
    final parts = [
      if (days) (d, 'Days'),
      (hh, 'Hours'),
      (m, 'Min'),
      (s, 'Sec'),
    ];
    final (box, fs) = switch (widget.size) {
      UiSize.sm => (40.0, 16.0),
      UiSize.md => (54.0, 22.0),
      UiSize.lg => (68.0, 28.0),
    };
    final t = widget.status == null ? null : context.tone(widget.status!);
    final c = widget.color;
    final bg = c ?? t?.container ?? cs.surfaceContainerHigh;
    final fg = c == null
        ? t?.onContainer ?? cs.onSurface
        : (ThemeData.estimateBrightnessForColor(c) == Brightness.dark ? Colors.white : Colors.black);
    final ns = context.text.titleLarge?.copyWith(
      fontSize: fs,
      fontWeight: FontWeight.w800,
      color: fg,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    final sep = Padding(
      padding: EdgeInsets.only(bottom: widget.labels ? 16 : 0, left: 4, right: 4),
      child: Text(':', style: ns?.copyWith(color: cs.onSurfaceVariant)),
    );
    return Semantics(
      label: '${days ? '$d days, ' : ''}$hh hours, $m minutes, $s seconds left',
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, (v, label)) in parts.indexed) ...[
              if (i > 0) sep,
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    constraints: BoxConstraints(minWidth: box, minHeight: box),
                    padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: bg, borderRadius: context.tokens.md),
                    child: Text(v.toString().padLeft(2, '0'), style: ns),
                  ),
                  if (widget.labels) ...[
                    const SizedBox(height: UiSpace.xs),
                    Text(label, style: context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
