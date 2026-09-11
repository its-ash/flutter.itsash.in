import 'package:flutter/material.dart';

import 'package:theme/src/typography/app_typography.dart';

class ThemePagination extends StatelessWidget {
  const ThemePagination({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    this.maxVisiblePages = 7,
    this.borderRadius,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int maxVisiblePages;
  final double? borderRadius;

  double _radius(BuildContext context) {
    if (borderRadius != null) return borderRadius!;
    final shape = Theme.of(context).filledButtonTheme.style?.shape?.resolve({});
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 8;
  }

  // Keeps first/last page always visible with an ellipsis run either side
  // of a window centered on the current page.
  List<Object> _pageItems() {
    if (totalPages <= maxVisiblePages) {
      return List.generate(totalPages, (i) => i + 1);
    }
    const ellipsis = '…';
    final items = <int>{1, totalPages};
    final windowSize = maxVisiblePages - 4;
    final half = windowSize ~/ 2;
    var start = (currentPage - half).clamp(2, totalPages - 1);
    var end = (start + windowSize - 1).clamp(2, totalPages - 1);
    start = (end - windowSize + 1).clamp(2, totalPages - 1);
    for (var p = start; p <= end; p++) {
      items.add(p);
    }
    final sorted = items.toList()..sort();
    final result = <Object>[];
    for (var i = 0; i < sorted.length; i++) {
      if (i > 0 && sorted[i] - sorted[i - 1] > 1) result.add(ellipsis);
      result.add(sorted[i]);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = _radius(context);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _NavArrow(
          icon: Icons.chevron_left,
          radius: radius,
          onTap: currentPage > 1 ? () => onPageChanged(currentPage - 1) : null,
        ),
        const SizedBox(width: 4),
        for (final item in _pageItems())
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: item is int
                ? _PageCell(
                    page: item,
                    selected: item == currentPage,
                    radius: radius,
                    onTap: () => onPageChanged(item),
                  )
                : SizedBox(
                    width: 32,
                    child: Text(
                      '…',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium.copyWith(
                        color: scheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
          ),
        const SizedBox(width: 4),
        _NavArrow(
          icon: Icons.chevron_right,
          radius: radius,
          onTap: currentPage < totalPages ? () => onPageChanged(currentPage + 1) : null,
        ),
      ],
    );
  }
}

class _PageCell extends StatelessWidget {
  const _PageCell({required this.page, required this.selected, required this.radius, required this.onTap});

  final int page;
  final bool selected;
  final double radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: selected ? scheme.primary : Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: selected ? null : onTap,
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Center(
            child: Text(
              '$page',
              style: AppTypography.labelLarge.copyWith(
                color: selected ? scheme.onPrimary : scheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavArrow extends StatelessWidget {
  const _NavArrow({required this.icon, required this.radius, required this.onTap});

  final IconData icon;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final enabled = onTap != null;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 18,
            color: enabled ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
