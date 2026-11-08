import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';

enum UiCalendarMode { single, range }

class UiMonthCalendar extends StatefulWidget {
  const UiMonthCalendar({
    super.key,
    this.mode = UiCalendarMode.single,
    this.selected,
    this.range,
    this.onChanged,
    this.onRangeChanged,
    this.firstDate,
    this.lastDate,
    this.initialMonth,
    this.markers = const {},
    this.firstWeekday = DateTime.monday,
    this.isEnabled,
    this.onMonthChanged,
  });

  final UiCalendarMode mode;
  final DateTime? selected;
  final DateTimeRange? range;
  final ValueChanged<DateTime>? onChanged;
  final ValueChanged<DateTimeRange>? onRangeChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DateTime? initialMonth;
  final Set<DateTime> markers;
  final int firstWeekday;
  final bool Function(DateTime day)? isEnabled;
  final ValueChanged<DateTime>? onMonthChanged;

  @override
  State<UiMonthCalendar> createState() => _UiMonthCalendarState();
}

class _UiMonthCalendarState extends State<UiMonthCalendar> {
  late DateTime _month;
  DateTime? _sel;
  DateTime? _a;
  DateTime? _b;

  DateTime? get _first => widget.firstDate == null ? null : UiFormat.dateOnly(widget.firstDate!);
  DateTime? get _last {
    final l = widget.lastDate == null ? null : UiFormat.dateOnly(widget.lastDate!);
    final f = _first;
    return l != null && f != null && l.isBefore(f) ? f : l;
  }

  int get _fw => widget.firstWeekday.clamp(DateTime.monday, DateTime.sunday);

  @override
  void initState() {
    super.initState();
    _sync();
    final anchor = widget.initialMonth ?? _sel ?? _a ?? DateTime.now();
    _month = DateTime(anchor.year, anchor.month);
  }

  void _sync() {
    _sel = widget.selected == null ? null : UiFormat.dateOnly(widget.selected!);
    final r = widget.range;
    _a = r == null ? null : UiFormat.dateOnly(r.start);
    _b = r == null ? null : UiFormat.dateOnly(r.end);
  }

  @override
  void didUpdateWidget(UiMonthCalendar old) {
    super.didUpdateWidget(old);
    if (!UiFormat.sameDay(old.selected, widget.selected) || old.range != widget.range) _sync();
  }

  bool _enabled(DateTime d) {
    final f = _first;
    final l = _last;
    if (f != null && d.isBefore(f)) return false;
    if (l != null && d.isAfter(l)) return false;
    return widget.isEnabled?.call(d) ?? true;
  }

  bool get _canPrev {
    final f = _first;
    return f == null || DateTime(f.year, f.month).isBefore(_month);
  }

  bool get _canNext {
    final l = _last;
    return l == null || DateTime(l.year, l.month).isAfter(_month);
  }

  void _go(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
    widget.onMonthChanged?.call(_month);
  }

  void _tap(DateTime d) {
    if (widget.mode == UiCalendarMode.single) {
      setState(() => _sel = d);
      widget.onChanged?.call(d);
      return;
    }
    final a = _a;
    if (a == null || _b != null || d.isBefore(a)) {
      setState(() {
        _a = d;
        _b = null;
      });
      return;
    }
    setState(() => _b = d);
    widget.onRangeChanged?.call(DateTimeRange(start: a, end: d));
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final today = UiFormat.dateOnly(DateTime.now());
    final marks = {for (final m in widget.markers) UiFormat.dateOnly(m)};
    final days = UiFormat.daysInMonth(_month.year, _month.month);
    final lead = (DateTime(_month.year, _month.month).weekday - _fw + 7) % 7;
    final rows = ((lead + days) / 7).ceil();
    final heads = [for (var i = 0; i < 7; i++) UiFormat.weekdays[(_fw - 1 + i) % 7]];
    final range = widget.mode == UiCalendarMode.range;

    Widget cell(DateTime d) {
      final on = _enabled(d);
      final a = _a;
      final b = _b;
      final isA = range && UiFormat.sameDay(d, a);
      final isB = range && UiFormat.sameDay(d, b);
      final inside = range && a != null && b != null && d.isAfter(a) && d.isBefore(b);
      final sel = range ? (isA || isB) : UiFormat.sameDay(d, _sel);
      final isToday = UiFormat.sameDay(d, today);
      final band = cs.primaryContainer.withValues(alpha: 0.7);
      final hasBand = range && a != null && b != null && !UiFormat.sameDay(a, b) && (inside || isA || isB);
      final fg = sel
          ? cs.onPrimary
          : inside
              ? cs.onPrimaryContainer
              : on
                  ? cs.onSurface
                  : cs.onSurface.withValues(alpha: 0.3);

      return Semantics(
        button: on,
        enabled: on,
        selected: sel || inside,
        label: '${UiFormat.day(d, year: true)}${isToday ? ', today' : ''}${marks.contains(d) ? ', has events' : ''}',
        child: ExcludeSemantics(
          child: SizedBox(
            height: 44,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (hasBand)
                  Positioned.fill(
                    top: 3,
                    bottom: 3,
                    child: isA || isB
                        ? FractionallySizedBox(
                            alignment: isA ? Alignment.centerRight : Alignment.centerLeft,
                            widthFactor: 0.5,
                            child: ColoredBox(color: band),
                          )
                        : ColoredBox(color: band),
                  ),
                InkResponse(
                  onTap: on ? () => _tap(d) : null,
                  radius: 22,
                  child: AnimatedContainer(
                    duration: UiDuration.fast,
                    width: 38,
                    height: 38,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: sel ? cs.primary : Colors.transparent,
                      border: isToday && !sel ? Border.all(color: cs.primary, width: 1.5) : null,
                    ),
                    child: Text(
                      '${d.day}',
                      style: context.text.bodyMedium?.copyWith(
                        color: fg,
                        fontWeight: sel || isToday ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                if (marks.contains(d))
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: sel ? cs.onPrimary : cs.primary),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                liveRegion: true,
                child: Text(
                  UiFormat.monthYear(_month),
                  style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            UiIconButton(
              Icons.chevron_left_rounded,
              tooltip: 'Previous month',
              size: UiSize.sm,
              onPressed: _canPrev ? () => _go(-1) : null,
            ),
            const UiGap.sm(),
            UiIconButton(
              Icons.chevron_right_rounded,
              tooltip: 'Next month',
              size: UiSize.sm,
              onPressed: _canNext ? () => _go(1) : null,
            ),
          ],
        ),
        const UiGap.md(),
        Row(
          children: [
            for (final h in heads)
              Expanded(
                child: Center(
                  child: Text(
                    h.substring(0, 2),
                    style: context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
          ],
        ),
        const UiGap.xs(),
        AnimatedSwitcher(
          duration: UiDuration.normal,
          child: Column(
            key: ValueKey(_month),
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var r = 0; r < rows; r++)
                Row(
                  children: [
                    for (var c = 0; c < 7; c++)
                      Expanded(
                        child: () {
                          final n = r * 7 + c - lead + 1;
                          return n < 1 || n > days ? const SizedBox(height: 44) : cell(DateTime(_month.year, _month.month, n));
                        }(),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
