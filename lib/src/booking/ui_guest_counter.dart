import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';

class UiGuestType {
  const UiGuestType(this.label, {this.subtitle, this.min = 0, this.max = 10, this.initial = 0});

  final String label;
  final String? subtitle;
  final int min;
  final int max;
  final int initial;
}

class UiGuestCounter extends StatefulWidget {
  const UiGuestCounter({
    super.key,
    this.types = defaults,
    this.maxTotal,
    this.onChanged,
  });

  static const defaults = [
    UiGuestType('Adults', subtitle: 'Ages 13 or above', min: 1, initial: 1),
    UiGuestType('Children', subtitle: 'Ages 2–12'),
    UiGuestType('Infants', subtitle: 'Under 2', max: 5),
  ];

  final List<UiGuestType> types;
  final int? maxTotal;
  final ValueChanged<List<int>>? onChanged;

  @override
  State<UiGuestCounter> createState() => _UiGuestCounterState();
}

class _UiGuestCounterState extends State<UiGuestCounter> {
  late List<int> _counts = _init();

  (int, int) _bounds(UiGuestType t) {
    final lo = t.min < 0 ? 0 : t.min;
    return (lo, t.max < lo ? lo : t.max);
  }

  List<int> _init() => [
        for (final t in widget.types) t.initial.clamp(_bounds(t).$1, _bounds(t).$2),
      ];

  @override
  void didUpdateWidget(UiGuestCounter old) {
    super.didUpdateWidget(old);
    if (old.types.length != widget.types.length) _counts = _init();
  }

  int get _total => _counts.fold(0, (a, b) => a + b);

  void _step(int i, int d) {
    final (lo, hi) = _bounds(widget.types[i]);
    final next = _counts[i] + d;
    final cap = widget.maxTotal;
    if (next < lo || next > hi) return;
    if (d > 0 && cap != null && _total >= cap) return;
    HapticFeedback.selectionClick();
    setState(() => _counts = [..._counts]..[i] = next);
    widget.onChanged?.call(List.unmodifiable(_counts));
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final cap = widget.maxTotal;
    final full = cap != null && _total >= cap;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < widget.types.length; i++) ...[
          if (i > 0) Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: UiSpace.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.types[i].label, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                      if (widget.types[i].subtitle != null)
                        Text(
                          widget.types[i].subtitle!,
                          style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
                UiIconButton(
                  Icons.remove_rounded,
                  tooltip: 'Remove ${widget.types[i].label}',
                  variant: UiIconButtonVariant.outline,
                  size: UiSize.sm,
                  onPressed: _counts[i] > _bounds(widget.types[i]).$1 ? () => _step(i, -1) : null,
                ),
                SizedBox(
                  width: 40,
                  child: Semantics(
                    label: widget.types[i].label,
                    value: '${_counts[i]}',
                    liveRegion: true,
                    child: AnimatedSwitcher(
                      duration: UiDuration.fast,
                      transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                      child: Text(
                        '${_counts[i]}',
                        key: ValueKey(_counts[i]),
                        textAlign: TextAlign.center,
                        style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ),
                UiIconButton(
                  Icons.add_rounded,
                  tooltip: 'Add ${widget.types[i].label}',
                  variant: UiIconButtonVariant.outline,
                  size: UiSize.sm,
                  onPressed: !full && _counts[i] < _bounds(widget.types[i]).$2 ? () => _step(i, 1) : null,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
