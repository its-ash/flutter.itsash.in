import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiTimeSlotGrid<T extends Object> extends StatefulWidget {
  const UiTimeSlotGrid({
    super.key,
    required this.slots,
    this.selected,
    this.unavailable = const {},
    this.onChanged,
    this.labelOf,
    this.grouped = true,
    this.use24h = false,
    this.columns = 3,
    this.sections = const ('Morning', 'Afternoon', 'Evening'),
    this.emptyLabel = 'No slots available',
  });

  final List<T> slots;
  final T? selected;
  final Set<T> unavailable;
  final ValueChanged<T>? onChanged;
  final String Function(T slot)? labelOf;
  final bool grouped;
  final bool use24h;
  final int columns;
  final (String, String, String) sections;
  final String emptyLabel;

  @override
  State<UiTimeSlotGrid<T>> createState() => _UiTimeSlotGridState<T>();
}

class _UiTimeSlotGridState<T extends Object> extends State<UiTimeSlotGrid<T>> {
  late T? _sel = widget.selected;

  @override
  void didUpdateWidget(UiTimeSlotGrid<T> old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) _sel = widget.selected;
  }

  String _label(T s) =>
      widget.labelOf?.call(s) ?? (s is TimeOfDay ? UiFormat.time(s, h24: widget.use24h) : s.toString());

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    if (widget.slots.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: UiSpace.lg),
        child: Center(
          child: Text(widget.emptyLabel, style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
        ),
      );
    }

    final cols = widget.columns.clamp(1, 6);
    final canGroup = widget.grouped && widget.slots.every((s) => s is TimeOfDay);

    Widget grid(List<T> items) => LayoutBuilder(
          builder: (_, box) {
            final w = ((box.maxWidth - (cols - 1) * UiSpace.sm) / cols).floorToDouble();
            return Wrap(
              spacing: UiSpace.sm,
              runSpacing: UiSpace.sm,
              children: [for (final s in items) SizedBox(width: w, child: _pill(s))],
            );
          },
        );

    if (!canGroup) return grid(widget.slots);

    final groups = <(String, IconData, List<T>)>[
      (widget.sections.$1, Icons.wb_twilight_rounded, []),
      (widget.sections.$2, Icons.wb_sunny_rounded, []),
      (widget.sections.$3, Icons.nights_stay_rounded, []),
    ];
    for (final s in widget.slots) {
      final h = (s as TimeOfDay).hour;
      groups[h < 12 ? 0 : (h < 17 ? 1 : 2)].$3.add(s);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final g in groups.where((g) => g.$3.isNotEmpty)) ...[
          Padding(
            padding: const EdgeInsets.only(top: UiSpace.sm, bottom: UiSpace.sm),
            child: Semantics(
              header: true,
              child: Row(
                children: [
                  Icon(g.$2, size: 18, color: cs.onSurfaceVariant),
                  const UiGap.sm(),
                  Text(g.$1, style: context.text.labelLarge?.copyWith(color: cs.onSurfaceVariant, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
          grid(g.$3),
        ],
      ],
    );
  }

  Widget _pill(T s) {
    final cs = context.colors;
    final off = widget.unavailable.contains(s);
    final sel = !off && _sel == s;
    final label = _label(s);
    return Semantics(
      button: !off,
      enabled: !off,
      selected: sel,
      label: off ? '$label, unavailable' : label,
      child: ExcludeSemantics(
        child: Material(
          color: sel ? cs.primary : (off ? cs.surfaceContainerHighest.withValues(alpha: 0.5) : Colors.transparent),
          shape: RoundedRectangleBorder(
            borderRadius: context.tokens.full,
            side: BorderSide(color: sel ? cs.primary : (off ? Colors.transparent : cs.outlineVariant)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: off
                ? null
                : () {
                    setState(() => _sel = s);
                    widget.onChanged?.call(s);
                  },
            child: SizedBox(
              height: 44,
              child: Center(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.labelLarge?.copyWith(
                    color: sel ? cs.onPrimary : (off ? cs.onSurface.withValues(alpha: 0.38) : cs.onSurface),
                    fontWeight: sel ? FontWeight.w800 : FontWeight.w600,
                    decoration: off ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
