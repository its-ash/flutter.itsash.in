import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/chart/chart_utils.dart';
import 'package:theme/src/foundation/foundation.dart';

/// Contribution / habit grid: one cell per day, one column per week, colored
/// in accent opacity steps by value.
///
/// ```dart
/// UiHeatmap(values: {DateTime(2026, 3, 4): 3, DateTime(2026, 3, 5): 7}, onTap: (day) => open(day))
/// ```
class UiHeatmap extends StatefulWidget {
  const UiHeatmap({
    super.key,
    required this.values,
    this.weeks = 17,
    this.end,
    this.onTap,
    this.color,
    this.cellSize = 14,
    this.cellGap = 3,
    this.showLabels = true,
    this.showLegend = true,
    this.semanticLabel,
  });

  /// Value per day. Times of day are ignored; same-day entries are summed.
  final Map<DateTime, int> values;

  /// Number of week columns.
  final int weeks;

  /// Last day shown. Defaults to today.
  final DateTime? end;

  /// Called with the tapped day.
  final ValueChanged<DateTime>? onTap;

  /// Base color. Defaults to `colors.accent`.
  final Color? color;

  /// Largest cell size. Cells shrink to fit narrow screens.
  final double cellSize;
  final double cellGap;

  /// Month labels on top and weekday letters on the left.
  final bool showLabels;

  /// "Less … More" scale under the grid.
  final bool showLegend;
  final String? semanticLabel;

  @override
  State<UiHeatmap> createState() => _UiHeatmapState();
}

class _UiHeatmapState extends State<UiHeatmap> with SingleTickerProviderStateMixin {
  late final UiChartAnimator _anim = UiChartAnimator(this, duration: const Duration(milliseconds: 800));
  DateTime? _selected;

  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _alphas = [0.25, 0.45, 0.7, 1.0];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _anim.start(context);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final loc = MaterialLocalizations.of(context);
    final base = widget.color ?? colors.accent;
    final weeks = math.max(1, widget.weeks);
    final firstDow = loc.firstDayOfWeekIndex; // 0 = Sunday
    final endDay = DateUtils.dateOnly(widget.end ?? DateTime.now());
    int rowOf(DateTime d) => (d.weekday % 7 - firstDow + 7) % 7;
    final lastColumnStart = DateTime(endDay.year, endDay.month, endDay.day - rowOf(endDay));
    final start = DateTime(lastColumnStart.year, lastColumnStart.month, lastColumnStart.day - (weeks - 1) * 7);
    DateTime dayAt(int col, int row) => DateTime(start.year, start.month, start.day + col * 7 + row);

    final totals = <DateTime, int>{};
    widget.values.forEach((k, v) {
      final d = DateUtils.dateOnly(k);
      totals[d] = (totals[d] ?? 0) + v;
    });
    var max = 0;
    for (var col = 0; col < weeks; col++) {
      for (var row = 0; row < 7; row++) {
        max = math.max(max, totals[dayAt(col, row)] ?? 0);
      }
    }
    int levelOf(int v) => v <= 0 || max <= 0 ? 0 : (v / max * 4).ceil().clamp(1, 4);
    Color colorOf(int level) => level == 0 ? colors.surfaceMuted : base.withValues(alpha: _alphas[level - 1]);

    final labelStyle = context.text.labelSmall?.copyWith(color: colors.textSubtle, letterSpacing: 0);
    final probe = uiChartText('M', labelStyle);
    final textH = probe.height;
    probe.dispose();
    final left = widget.showLabels ? 18.0 : 0.0;
    final top = widget.showLabels ? textH + UiSpace.xs : 0.0;
    final gap = widget.cellGap;

    return Semantics(
      label: widget.semanticLabel ?? 'Activity heatmap, $weeks weeks',
      child: LayoutBuilder(
        builder: (context, c) {
          final available = c.hasBoundedWidth ? c.maxWidth : weeks * (widget.cellSize + gap) + left;
          final fit = (available - left + gap) / weeks - gap;
          final cell = fit.clamp(8.0, widget.cellSize);
          final gridWidth = left + weeks * (cell + gap) - gap;
          final gridHeight = top + 7 * (cell + gap) - gap;
          final geometry = _HeatGeometry(left: left, top: top, cell: cell, gap: gap, weeks: weeks);

          final cells = <_HeatCell>[];
          final monthLabels = <(int, String)>[];
          var lastLabelCol = -10;
          for (var col = 0; col < weeks; col++) {
            final first = dayAt(col, 0);
            final prev = col == 0 ? null : dayAt(col - 1, 0);
            if ((prev == null || prev.month != first.month) && col - lastLabelCol >= 3 && col < weeks - 1) {
              final label = first.day <= 7 || col == 0 ? _months[first.month - 1] : null;
              if (label != null) {
                monthLabels.add((col, label));
                lastLabelCol = col;
              }
            }
            for (var row = 0; row < 7; row++) {
              final day = dayAt(col, row);
              if (day.isAfter(endDay)) continue;
              final v = totals[day] ?? 0;
              cells.add(_HeatCell(col, row, colorOf(levelOf(v))));
            }
          }
          final weekdayLabels = <(int, String)>[
            for (final row in [1, 3, 5]) (row, loc.narrowWeekdays[(firstDow + row) % 7]),
          ];

          final sel = _selected;
          int? selCol;
          int? selRow;
          if (sel != null) {
            final diff = DateTime.utc(
              sel.year,
              sel.month,
              sel.day,
            ).difference(DateTime.utc(start.year, start.month, start.day)).inDays;
            if (diff >= 0 && diff < weeks * 7 && !sel.isAfter(endDay)) {
              selCol = diff ~/ 7;
              selRow = diff % 7;
            }
          }

          void pick(Offset p, {required bool tap}) {
            final hit = geometry.hit(p);
            if (hit == null) return;
            final day = dayAt(hit.$1, hit.$2);
            if (day.isAfter(endDay)) return;
            if (tap && widget.onTap != null) widget.onTap!(day);
            if (!DateUtils.isSameDay(day, _selected)) setState(() => _selected = day);
          }

          Widget grid = SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: UiChartPointer(
              onPoint: (p) => pick(p, tap: false),
              onTap: (p) => pick(p, tap: true),
              onLeave: () {
                if (_selected != null) setState(() => _selected = null);
              },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _anim.curve,
                      builder: (context, _) => CustomPaint(
                        painter: _HeatPainter(
                          geometry: geometry,
                          cells: cells,
                          months: widget.showLabels ? monthLabels : const [],
                          weekdays: widget.showLabels ? weekdayLabels : const [],
                          labelStyle: labelStyle,
                          progress: _anim.value,
                          outline: colors.text,
                          selected: selCol == null ? null : (selCol, selRow!),
                        ),
                      ),
                    ),
                  ),
                  if (sel != null && selCol != null)
                    UiChartTooltipOverlay(
                      anchor: geometry.rect(selCol, selRow!).topCenter,
                      tooltip: UiChartTooltip(
                        title: loc.formatMediumDate(sel),
                        rows: [
                          UiChartTooltipRow(
                            '',
                            '${totals[DateUtils.dateOnly(sel)] ?? 0}',
                            color: colorOf(levelOf(totals[DateUtils.dateOnly(sel)] ?? 0)),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          );
          if (gridWidth > available) {
            grid = SingleChildScrollView(scrollDirection: Axis.horizontal, reverse: true, child: grid);
          }

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              grid,
              if (widget.showLegend) ...[
                const SizedBox(height: UiSpace.sm),
                SizedBox(
                  width: math.min(math.max(gridWidth, 160.0), available),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Less', style: labelStyle),
                        const SizedBox(width: UiSpace.xs),
                        for (var l = 0; l <= 4; l++)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 1.5),
                            child: DecoratedBox(
                              decoration: BoxDecoration(color: colorOf(l), borderRadius: UiRadius.all(2.5)),
                              child: const SizedBox.square(dimension: 10),
                            ),
                          ),
                        const SizedBox(width: UiSpace.xs),
                        Text('More', style: labelStyle),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _HeatCell {
  const _HeatCell(this.col, this.row, this.color);

  final int col;
  final int row;
  final Color color;
}

class _HeatGeometry {
  const _HeatGeometry({
    required this.left,
    required this.top,
    required this.cell,
    required this.gap,
    required this.weeks,
  });

  final double left;
  final double top;
  final double cell;
  final double gap;
  final int weeks;

  Rect rect(int col, int row) => Rect.fromLTWH(left + col * (cell + gap), top + row * (cell + gap), cell, cell);

  (int, int)? hit(Offset p) {
    final col = ((p.dx - left + gap / 2) / (cell + gap)).floor();
    final row = ((p.dy - top + gap / 2) / (cell + gap)).floor();
    if (col < 0 || col >= weeks || row < 0 || row >= 7) return null;
    return (col, row);
  }
}

class _HeatPainter extends CustomPainter {
  _HeatPainter({
    required this.geometry,
    required this.cells,
    required this.months,
    required this.weekdays,
    required this.labelStyle,
    required this.progress,
    required this.outline,
    required this.selected,
  });

  final _HeatGeometry geometry;
  final List<_HeatCell> cells;
  final List<(int, String)> months;
  final List<(int, String)> weekdays;
  final TextStyle? labelStyle;
  final double progress;
  final Color outline;
  final (int, int)? selected;

  @override
  void paint(Canvas canvas, Size size) {
    final g = geometry;
    for (final (col, label) in months) {
      final tp = uiChartText(label, labelStyle);
      tp.paint(canvas, Offset(g.rect(col, 0).left, 0));
      tp.dispose();
    }
    for (final (row, label) in weekdays) {
      final tp = uiChartText(label, labelStyle);
      final r = g.rect(0, row);
      tp.paint(canvas, Offset(0, r.center.dy - tp.height / 2));
      tp.dispose();
    }
    final radius = Radius.circular(math.max(1.5, g.cell * 0.24));
    for (final c in cells) {
      // Columns fade in left to right.
      final a = (progress * 1.6 - c.col / g.weeks * 0.6).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final paint = Paint()..color = c.color.withValues(alpha: c.color.a * a);
      canvas.drawRRect(RRect.fromRectAndRadius(g.rect(c.col, c.row), radius), paint);
    }
    final s = selected;
    if (s != null) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(g.rect(s.$1, s.$2).inflate(1), radius),
        Paint()
          ..color = outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }
  }

  @override
  bool shouldRepaint(_HeatPainter old) => true;
}
