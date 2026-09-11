import 'package:flutter/material.dart';

import 'package:theme/src/shadows/app_shadow_theme.dart';

class ThemeDataTable extends StatelessWidget {
  const ThemeDataTable({super.key, required this.columns, required this.rows});

  final List<DataColumn> columns;
  final List<DataRow> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shadows = theme.extension<AppShadowTheme>() ?? const AppShadowTheme();
    final stripe = Color.alphaBlend(
        scheme.onSurface.withValues(alpha: 0.035), scheme.surface);

    final stripedRows = [
      for (var i = 0; i < rows.length; i++)
        if (rows[i].color != null)
          rows[i]
        else
          DataRow(
            key: rows[i].key,
            selected: rows[i].selected,
            onSelectChanged: rows[i].onSelectChanged,
            color: i.isOdd ? WidgetStatePropertyAll(stripe) : null,
            cells: rows[i].cells,
          ),
    ];

    final radius = BorderRadius.circular(_cardRadius(theme));

    return Container(
      decoration: BoxDecoration(
          border: Border.all(
            color: shadows.borderWidth > 0 ? (shadows.borderColor ?? scheme.outline) : scheme.outline,
            width: shadows.borderWidth > 0 ? shadows.borderWidth : 1,
          ),
          borderRadius: radius),
      // DataTable paints per-row/heading backgrounds via nested Material/Ink
      // layers that a Container's clipBehavior alone won't round at the
      // bottom corners — an explicit ClipRRect is needed to clip them too.
      child: ClipRRect(
        borderRadius: radius,
        child: DataTable(columns: columns, rows: stripedRows),
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
