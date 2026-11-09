import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

const double _buttonSize = 40;
const double _gap = UiSpace.xs;

/// Compact page switcher: "‹ 1 … 4 5 6 … 20 ›".
///
/// [page] is 1-based. On narrow widths it shows fewer numbers, and on very
/// narrow widths just "‹ 5 / 20 ›".
///
/// ```dart
/// UiPagination(page: page, pageCount: 20, onChanged: (p) => setState(() => page = p));
/// ```
class UiPagination extends StatelessWidget {
  const UiPagination({
    super.key,
    required this.page,
    required this.pageCount,
    required this.onChanged,
    this.siblings = 1,
  });

  /// Current page, starting at 1.
  final int page;
  final int pageCount;

  /// Called with the new page (1-based). Null disables the control.
  final ValueChanged<int>? onChanged;

  /// How many pages to show on each side of the current one.
  final int siblings;

  /// Page numbers to show for [page] of [pageCount]. `null` marks a "…" gap.
  ///
  /// `UiPagination.pages(5, 20)` is `[1, null, 4, 5, 6, null, 20]`.
  static List<int?> pages(int page, int pageCount, {int siblings = 1}) {
    if (pageCount <= 0) return const [];
    final s = siblings < 0 ? 0 : siblings;
    final p = page.clamp(1, pageCount);
    final slots = s * 2 + 5;
    if (pageCount <= slots) return [for (var i = 1; i <= pageCount; i++) i];

    final left = (p - s).clamp(1, pageCount);
    final right = (p + s).clamp(1, pageCount);
    final leftGap = left > 3;
    final rightGap = right < pageCount - 2;
    final edge = 3 + 2 * s;

    if (!leftGap && rightGap) {
      return [for (var i = 1; i <= edge; i++) i, null, pageCount];
    }
    if (leftGap && !rightGap) {
      return [1, null, for (var i = pageCount - edge + 1; i <= pageCount; i++) i];
    }
    return [1, null, for (var i = left; i <= right; i++) i, null, pageCount];
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l = MaterialLocalizations.of(context);
    final p = pageCount <= 0 ? 0 : page.clamp(1, pageCount);
    final onChanged = this.onChanged;
    final style = context.text.labelLarge!.copyWith(fontFeatures: const [FontFeature.tabularFigures()]);

    void go(int to) => onChanged?.call(to);

    return LayoutBuilder(
      builder: (context, box) {
        double widthFor(int slots) => slots * _buttonSize + (slots - 1) * _gap;
        List<int?>? list = pages(p, pageCount, siblings: siblings);
        if (box.maxWidth.isFinite && widthFor(list.length + 2) > box.maxWidth) {
          final tight = pages(p, pageCount, siblings: 0);
          list = widthFor(tight.length + 2) <= box.maxWidth ? tight : null;
        }

        final children = <Widget>[
          _PageButton(
            tooltip: l.previousPageTooltip,
            onTap: onChanged != null && p > 1 ? () => go(p - 1) : null,
            child: const Icon(Icons.chevron_left_rounded, size: 20),
          ),
        ];
        if (list == null) {
          children.add(
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '$p / $pageCount',
                    style: style.copyWith(color: onChanged == null ? c.textDisabled : c.text),
                  ),
                ),
              ),
            ),
          );
        } else {
          for (final n in list) {
            if (n == null) {
              children.add(
                SizedBox(
                  width: _buttonSize,
                  height: _buttonSize,
                  child: Center(
                    child: Text('…', style: style.copyWith(color: c.textSubtle)),
                  ),
                ),
              );
            } else {
              children.add(
                _PageButton(
                  selected: n == p,
                  semanticLabel: 'Page $n',
                  onTap: onChanged == null ? null : () => go(n),
                  child: FittedBox(fit: BoxFit.scaleDown, child: Text('$n')),
                ),
              );
            }
          }
        }
        children.add(
          _PageButton(
            tooltip: l.nextPageTooltip,
            onTap: onChanged != null && p < pageCount ? () => go(p + 1) : null,
            child: const Icon(Icons.chevron_right_rounded, size: 20),
          ),
        );

        return Semantics(
          container: true,
          label: 'Page $p of $pageCount',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: _gap), children[i]],
            ],
          ),
        );
      },
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.child,
    required this.onTap,
    this.selected = false,
    this.tooltip,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool selected;
  final String? tooltip;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onTap != null;
    final Color fg;
    if (selected) {
      fg = enabled ? c.onAccent : c.textDisabled;
    } else {
      fg = enabled ? c.text : c.textDisabled;
    }
    final shape = RoundedRectangleBorder(borderRadius: UiRadius.all(UiRadius.sm));
    Widget button = AnimatedContainer(
      duration: context.motion(UiMotion.fast),
      width: _buttonSize,
      height: _buttonSize,
      decoration: ShapeDecoration(
        shape: shape,
        color: selected ? (enabled ? c.accent : c.surfaceMuted) : c.accent.withValues(alpha: 0),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: selected ? null : onTap,
          customBorder: shape,
          child: Center(
            child: IconTheme.merge(
              data: IconThemeData(color: fg),
              child: DefaultTextStyle.merge(
                style: context.text.labelLarge!.copyWith(color: fg, fontFeatures: const [FontFeature.tabularFigures()]),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
    if (tooltip != null) button = Tooltip(message: tooltip, child: button);
    return Semantics(button: true, selected: selected, enabled: enabled, label: semanticLabel, child: button);
  }
}
