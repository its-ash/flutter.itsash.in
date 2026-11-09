import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

const double _crumbPad = UiSpace.sm;
const double _separatorWidth = 18;
const double _ellipsisWidth = 40;

/// Path of pages, like "Home › Projects › Theme". The last item is the
/// current page. When space is short, middle items collapse into "…", which
/// opens a menu with the hidden items.
///
/// ```dart
/// UiBreadcrumbs(const ['Home', 'Projects', 'Theme'], onTap: (i) => goTo(i));
/// ```
class UiBreadcrumbs extends StatelessWidget {
  const UiBreadcrumbs(this.items, {super.key, this.onTap});

  final List<String> items;

  /// Called with the index of a tapped item. Null makes the path read-only.
  final ValueChanged<int>? onTap;

  /// Which items to show for [maxWidth]: indices, with `null` for the "…".
  List<int?> _visible(BuildContext context, double maxWidth, TextStyle style, TextStyle current) {
    final n = items.length;
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    double measure(int i) {
      final painter = TextPainter(
        text: TextSpan(text: items[i], style: i == n - 1 ? current : style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout();
      final w = painter.width + 2 * _crumbPad;
      painter.dispose();
      return w;
    }

    final widths = [for (var i = 0; i < n; i++) measure(i)];
    double total(List<int?> list) {
      var sum = 0.0;
      for (var k = 0; k < list.length; k++) {
        final i = list[k];
        sum += (i == null ? _ellipsisWidth : widths[i]) + (k > 0 ? _separatorWidth : 0);
      }
      return sum;
    }

    final candidates = <List<int?>>[
      [for (var i = 0; i < n; i++) i],
      if (n > 3) [0, null, n - 2, n - 1],
      if (n > 2) [0, null, n - 1],
      if (n > 1) [null, n - 1],
    ];
    for (final list in candidates) {
      if (total(list) <= maxWidth) return list;
    }
    return candidates.last;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    final c = context.colors;
    final base = context.text.bodyMedium!;
    final onTap = this.onTap;
    final style = base.copyWith(color: onTap == null ? c.textSubtle : c.textMuted);
    final current = base.copyWith(color: c.text, fontWeight: FontWeight.w600);

    return LayoutBuilder(
      builder: (context, box) {
        final n = items.length;
        final visible = box.maxWidth.isFinite
            ? _visible(context, box.maxWidth, style, current)
            : [for (var i = 0; i < n; i++) i];
        final hidden = [
          for (var i = 0; i < n; i++)
            if (!visible.contains(i)) i,
        ];
        final children = <Widget>[];
        for (var k = 0; k < visible.length; k++) {
          if (k > 0) {
            children.add(
              SizedBox(
                width: _separatorWidth,
                child: Icon(Icons.chevron_right_rounded, size: 16, color: c.textSubtle),
              ),
            );
          }
          final i = visible[k];
          if (i == null) {
            children.add(_Ellipsis(items: items, hidden: hidden, onTap: onTap, style: style));
          } else if (i == n - 1) {
            children.add(
              Flexible(
                child: Semantics(
                  selected: true,
                  child: _Crumb(label: items[i], style: current, onTap: null),
                ),
              ),
            );
          } else {
            children.add(_Crumb(label: items[i], style: style, onTap: onTap == null ? null : () => onTap(i)));
          }
        }
        return Row(mainAxisSize: MainAxisSize.min, children: children);
      },
    );
  }
}

class _Crumb extends StatelessWidget {
  const _Crumb({required this.label, required this.style, required this.onTap});

  final String label;
  final TextStyle style;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: _crumbPad),
        child: Align(
          widthFactor: 1,
          child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: style),
        ),
      ),
    );
    if (onTap == null) return text;
    return Semantics(
      link: true,
      child: InkWell(onTap: onTap, borderRadius: UiRadius.all(UiRadius.xs), child: text),
    );
  }
}

class _Ellipsis extends StatelessWidget {
  const _Ellipsis({required this.items, required this.hidden, required this.onTap, required this.style});

  final List<String> items;
  final List<int> hidden;
  final ValueChanged<int>? onTap;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final onTap = this.onTap;
    return PopupMenuButton<int>(
      tooltip: MaterialLocalizations.of(context).showMenuTooltip,
      enabled: onTap != null,
      onSelected: onTap,
      position: PopupMenuPosition.under,
      itemBuilder: (context) => [
        for (final i in hidden)
          PopupMenuItem(
            value: i,
            child: Text(items[i], maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
      ],
      child: SizedBox(
        width: _ellipsisWidth,
        height: 40,
        child: Center(child: Text('…', style: style)),
      ),
    );
  }
}
