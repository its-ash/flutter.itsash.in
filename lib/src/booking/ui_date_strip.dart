import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiDateStrip extends StatefulWidget {
  const UiDateStrip({
    super.key,
    this.start,
    this.days = 14,
    this.selected,
    this.onChanged,
    this.disablePast = true,
    this.markers = const {},
    this.isEnabled,
    this.padding = UiSpace.page,
  });

  final DateTime? start;
  final int days;
  final DateTime? selected;
  final ValueChanged<DateTime>? onChanged;
  final bool disablePast;
  final Set<DateTime> markers;
  final bool Function(DateTime day)? isEnabled;
  final EdgeInsetsGeometry padding;

  @override
  State<UiDateStrip> createState() => _UiDateStripState();
}

class _UiDateStripState extends State<UiDateStrip> {
  static const _w = 58.0;
  static const _gap = UiSpace.sm;

  late DateTime? _sel = widget.selected == null ? null : UiFormat.dateOnly(widget.selected!);
  late final ScrollController _sc = ScrollController(initialScrollOffset: _offsetFor(_sel));

  DateTime get _start => UiFormat.dateOnly(widget.start ?? DateTime.now());
  int get _count => widget.days.clamp(1, 366);

  double _offsetFor(DateTime? d) {
    if (d == null) return 0;
    final i = DateTime.utc(d.year, d.month, d.day).difference(DateTime.utc(_start.year, _start.month, _start.day)).inDays;
    return i <= 1 ? 0 : (i - 1) * (_w + _gap);
  }

  @override
  void didUpdateWidget(UiDateStrip old) {
    super.didUpdateWidget(old);
    if (!UiFormat.sameDay(old.selected, widget.selected)) {
      _sel = widget.selected == null ? null : UiFormat.dateOnly(widget.selected!);
    }
  }

  @override
  void dispose() {
    _sc.dispose();
    super.dispose();
  }

  bool _enabled(DateTime d, DateTime today) {
    if (widget.disablePast && d.isBefore(today)) return false;
    return widget.isEnabled?.call(d) ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final today = UiFormat.dateOnly(DateTime.now());
    final marks = {for (final m in widget.markers) UiFormat.dateOnly(m)};
    final start = _start;

    return SizedBox(
      height: 84,
      child: ListView.separated(
        controller: _sc,
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        itemCount: _count,
        separatorBuilder: (_, _) => const SizedBox(width: _gap),
        itemBuilder: (_, i) {
          final d = DateTime(start.year, start.month, start.day + i);
          final on = _enabled(d, today);
          final sel = UiFormat.sameDay(d, _sel);
          final isToday = UiFormat.sameDay(d, today);
          final fg = sel ? cs.onPrimary : (on ? cs.onSurface : cs.onSurface.withValues(alpha: 0.38));
          final sub = sel ? cs.onPrimary.withValues(alpha: 0.85) : cs.onSurfaceVariant.withValues(alpha: on ? 1 : 0.38);
          final marked = marks.contains(d);
          return Semantics(
            button: on,
            enabled: on,
            selected: sel,
            label: '${UiFormat.day(d)}${isToday ? ', today' : ''}${marked ? ', has events' : ''}',
            child: ExcludeSemantics(
              child: Material(
                color: sel ? cs.primary : (isToday ? cs.primaryContainer.withValues(alpha: 0.5) : cs.surfaceContainerLow),
                borderRadius: context.tokens.lg,
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: !on
                      ? null
                      : () {
                          setState(() => _sel = d);
                          widget.onChanged?.call(d);
                        },
                  child: AnimatedContainer(
                    duration: UiDuration.fast,
                    width: _w,
                    decoration: BoxDecoration(
                      borderRadius: context.tokens.lg,
                      border: Border.all(
                        color: sel ? cs.primary : (isToday ? cs.primary.withValues(alpha: 0.5) : cs.outlineVariant.withValues(alpha: 0.5)),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          UiFormat.weekday(d),
                          style: context.text.labelSmall?.copyWith(color: sub, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${d.day}',
                          style: context.text.titleLarge?.copyWith(
                            color: fg,
                            fontWeight: FontWeight.w800,
                            decoration: on ? null : TextDecoration.lineThrough,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: marked ? (sel ? cs.onPrimary : cs.primary) : Colors.transparent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
