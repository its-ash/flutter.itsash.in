import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

class ThemeAppDataTable extends StatefulWidget {
  const ThemeAppDataTable({
    super.key,
    required this.columns,
    required this.rows,
    this.onRowTap,
    this.onSort,
    this.stripeRows = true,
    this.showCheckboxColumn = false,
    this.onSelectionChanged,
    this.pageSize,
    this.header,
  });

  final List<ThemeDataColumn> columns;
  final List<List<Widget>> rows;
  final ValueChanged<int>? onRowTap;
  final void Function(int columnIndex, bool ascending)? onSort;
  final bool stripeRows;
  final bool showCheckboxColumn;
  final ValueChanged<Set<int>>? onSelectionChanged;
  final int? pageSize;
  final Widget? header;

  @override
  State<ThemeAppDataTable> createState() => _ThemeAppDataTableState();
}

class _ThemeAppDataTableState extends State<ThemeAppDataTable> {
  int _sortIndex = -1;
  bool _sortAsc = true;
  final Set<int> _selected = {};
  int _page = 0;

  List<List<Widget>> get _visibleRows {
    var rows = widget.rows;
    if (widget.pageSize != null) {
      final start = _page * widget.pageSize!;
      final end = (start + widget.pageSize!).clamp(0, rows.length);
      rows = rows.sublist(start, end);
    }
    return rows;
  }

  void _toggleSort(int col) {
    if (_sortIndex == col) {
      _sortAsc = !_sortAsc;
    } else {
      _sortIndex = col;
      _sortAsc = true;
    }
    widget.onSort?.call(col, _sortAsc);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shadows = theme.extension<AppShadowTheme>() ?? const AppShadowTheme();
    final stripe = Color.alphaBlend(
        scheme.onSurface.withValues(alpha: 0.035), scheme.surface);
    final visible = _visibleRows;
    final total = widget.rows.length;
    final pageStart = widget.pageSize != null ? _page * widget.pageSize! : 0;

    final radius = BorderRadius.circular(_cardRadius(theme));

    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: radius,
        border: Border.all(
          color: shadows.borderWidth > 0
              ? (shadows.borderColor ?? scheme.outline)
              : scheme.outline.withValues(alpha: 0.5),
          width: shadows.borderWidth > 0 ? shadows.borderWidth : 1,
        ),
      ),
      // DataTable paints per-row/heading backgrounds via nested Material/Ink
      // layers that a Container's clipBehavior alone won't round at the
      // bottom corners — an explicit ClipRRect is needed to clip them too.
      child: ClipRRect(
        borderRadius: radius,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (widget.header != null)
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: widget.header),
          SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                sortColumnIndex: _sortIndex >= 0 ? _sortIndex : null,
                sortAscending: _sortAsc,
                showCheckboxColumn: widget.showCheckboxColumn,
                columns: [
                  for (var i = 0; i < widget.columns.length; i++)
                    DataColumn(
                      label: widget.columns[i].label,
                      numeric: widget.columns[i].numeric,
                      onSort: widget.columns[i].sortable
                          ? (_, __) => _toggleSort(i)
                          : null,
                    ),
                ],
                rows: [
                  for (var r = 0; r < visible.length; r++)
                    DataRow(
                      selected: _selected.contains(pageStart + r),
                      onSelectChanged: widget.showCheckboxColumn
                          ? (v) {
                              final idx = pageStart + r;
                              if (v == true) {
                                _selected.add(idx);
                              } else {
                                _selected.remove(idx);
                              }
                              widget.onSelectionChanged?.call(_selected);
                              setState(() {});
                            }
                          : null,
                      color: widget.stripeRows && r.isOdd
                          ? WidgetStatePropertyAll(stripe)
                          : null,
                      cells: [
                        for (final cell in visible[r])
                          DataCell(cell,
                              onTap: () => widget.onRowTap?.call(pageStart + r))
                      ],
                    ),
                ],
              )),
          if (widget.pageSize != null && total > widget.pageSize!)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text(
                    '${pageStart + 1}-${(pageStart + visible.length)} of $total',
                    style: Theme.of(context).textTheme.labelSmall),
                IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed:
                        _page > 0 ? () => setState(() => _page--) : null),
                IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: pageStart + widget.pageSize! < total
                        ? () => setState(() => _page++)
                        : null),
              ]),
            ),
        ]),
      ),
    );
  }

  double _cardRadius(ThemeData theme) {
    final shape = theme.cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }
}

class ThemeDataColumn {
  const ThemeDataColumn(
      {required this.label, this.numeric = false, this.sortable = false});
  final Widget label;
  final bool numeric;
  final bool sortable;
}
