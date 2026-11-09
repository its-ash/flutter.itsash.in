import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// One column of a [UiTable].
///
/// ```dart
/// UiTableColumn<User>('Name', text: (u) => u.name, sortBy: (u) => u.name)
/// ```
class UiTableColumn<T> {
  const UiTableColumn(
    this.label, {
    this.text,
    this.builder,
    this.sortBy,
    this.width,
    this.numeric = false,
    this.mono = false,
  }) : assert(text != null || builder != null, 'Pass text or builder');

  final String label;

  /// Cell text for a row.
  final String Function(T row)? text;

  /// Custom cell widget for a row. Takes precedence over [text].
  final Widget Function(BuildContext context, T row)? builder;

  /// Sort key. When set the header is tappable and sorts by it.
  final Comparable<Object?> Function(T row)? sortBy;

  /// Fixed column width. Otherwise the column fits its content and shares
  /// the spare width.
  final double? width;

  /// Right-aligned with tabular figures.
  final bool numeric;

  /// Monospace cell text.
  final bool mono;

  bool get sortable => sortBy != null;
}

/// A bordered data table with sortable headers, row taps, striping and
/// horizontal scroll when it is wider than the screen.
///
/// ```dart
/// UiTable<User>(columns: cols, rows: users, onRowTap: open)
/// ```
class UiTable<T> extends StatefulWidget {
  const UiTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.striped = false,
    this.dense = false,
    this.emptyMessage = 'No data',
    this.initialSortColumn,
    this.initialSortAscending = true,
    this.onSort,
  });

  final List<UiTableColumn<T>> columns;
  final List<T> rows;
  final ValueChanged<T>? onRowTap;

  /// Alternate row backgrounds.
  final bool striped;

  /// Tighter rows.
  final bool dense;

  /// Shown when [rows] is empty.
  final String emptyMessage;

  /// Column index to sort by at start.
  final int? initialSortColumn;
  final bool initialSortAscending;

  /// Called after the user changes the sort.
  final void Function(int column, bool ascending)? onSort;

  @override
  State<UiTable<T>> createState() => _UiTableState<T>();
}

class _UiTableState<T> extends State<UiTable<T>> {
  int? _sortColumn;
  bool _ascending = true;

  @override
  void initState() {
    super.initState();
    _sortColumn = widget.initialSortColumn;
    _ascending = widget.initialSortAscending;
  }

  void _toggleSort(int index) {
    setState(() {
      if (_sortColumn == index) {
        _ascending = !_ascending;
      } else {
        _sortColumn = index;
        _ascending = true;
      }
    });
    widget.onSort?.call(index, _ascending);
  }

  List<T> get _sortedRows {
    final col = _sortColumn;
    if (col == null || col >= widget.columns.length) return widget.rows;
    final key = widget.columns[col].sortBy;
    if (key == null) return widget.rows;
    final sorted = List<T>.of(widget.rows);
    sorted.sort((a, b) {
      final c = key(a).compareTo(key(b));
      return _ascending ? c : -c;
    });
    return sorted;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final columns = widget.columns;
    final rows = _sortedRows;
    final vPad = widget.dense ? UiSpace.sm : UiSpace.md;
    final cellPad = EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: vPad);
    final cellStyle = text.bodyMedium?.copyWith(color: colors.text);

    Widget header(int i) {
      final col = columns[i];
      final active = _sortColumn == i;
      final label = Text(
        col.label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: text.labelMedium?.copyWith(color: active ? colors.text : colors.textMuted),
      );
      Widget content = Padding(
        padding: EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: widget.dense ? UiSpace.sm : 10),
        child: Row(
          mainAxisAlignment: col.numeric ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(child: label),
            if (col.sortable) ...[
              const SizedBox(width: UiSpace.xs),
              AnimatedRotation(
                turns: active && !_ascending ? 0.5 : 0,
                duration: context.motion(UiMotion.fast),
                child: Icon(
                  active ? Icons.arrow_upward_rounded : Icons.unfold_more_rounded,
                  size: 14,
                  color: active ? colors.accent : colors.textSubtle,
                ),
              ),
            ],
          ],
        ),
      );
      if (col.sortable) {
        content = Semantics(
          button: true,
          label: 'Sort by ${col.label}',
          child: InkWell(onTap: () => _toggleSort(i), child: content),
        );
      }
      return content;
    }

    Widget cell(UiTableColumn<T> col, T row) {
      final Widget child =
          col.builder?.call(context, row) ??
          Text(
            col.text!(row),
            maxLines: col.width == null ? 1 : 2,
            overflow: TextOverflow.ellipsis,
            textAlign: col.numeric ? TextAlign.end : TextAlign.start,
            style: col.mono
                ? UiTypography.mono(fontSize: 13, color: colors.text)
                : col.numeric
                ? cellStyle?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])
                : cellStyle,
          );
      final aligned = Padding(
        padding: cellPad,
        child: Align(
          alignment: col.numeric ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
          widthFactor: 1,
          child: child,
        ),
      );
      final onTap = widget.onRowTap;
      return onTap == null ? aligned : TableRowInkWell(onTap: () => onTap(row), child: aligned);
    }

    final table = Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      columnWidths: {
        for (var i = 0; i < columns.length; i++)
          i: columns[i].width != null ? FixedColumnWidth(columns[i].width!) : const IntrinsicColumnWidth(flex: 1),
      },
      border: TableBorder(horizontalInside: BorderSide(color: colors.border)),
      children: [
        TableRow(
          decoration: BoxDecoration(color: colors.surfaceMuted),
          children: [for (var i = 0; i < columns.length; i++) header(i)],
        ),
        for (var r = 0; r < rows.length; r++)
          TableRow(
            decoration: widget.striped && r.isOdd
                ? BoxDecoration(color: colors.surfaceMuted.withValues(alpha: colors.isDark ? 0.5 : 0.6))
                : null,
            children: [for (final col in columns) cell(col, rows[r])],
          ),
      ],
    );

    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: UiRadius.all(UiRadius.lg),
        side: BorderSide(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth.isFinite ? constraints.maxWidth : 0),
                child: table,
              ),
            ),
          ),
          if (rows.isEmpty) ...[
            Divider(height: 1, color: colors.border),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.xl),
              child: Text(
                widget.emptyMessage,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: colors.textSubtle),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
