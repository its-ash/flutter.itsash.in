import 'package:flutter/material.dart';

import 'package:theme/src/typography/app_typography.dart';

class ThemeBreadcrumbItem {
  const ThemeBreadcrumbItem({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;
}

class ThemeBreadcrumbs extends StatelessWidget {
  const ThemeBreadcrumbs({
    super.key,
    required this.items,
    this.separatorIcon = Icons.chevron_right,
  });

  final List<ThemeBreadcrumbItem> items;
  final IconData? separatorIcon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Icon(separatorIcon, size: 16, color: scheme.onSurface.withValues(alpha: 0.4)),
            ),
          _BreadcrumbLabel(item: items[i], isCurrent: i == items.length - 1),
        ],
      ],
    );
  }
}

class _BreadcrumbLabel extends StatelessWidget {
  const _BreadcrumbLabel({required this.item, required this.isCurrent});

  final ThemeBreadcrumbItem item;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final style = AppTypography.bodyMedium.copyWith(
      color: isCurrent ? scheme.onSurface : scheme.onSurface.withValues(alpha: 0.55),
      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w400,
    );

    if (isCurrent || item.onTap == null) {
      return Text(item.label, style: style);
    }

    return InkWell(
      onTap: item.onTap,
      child: Text(item.label, style: style),
    );
  }
}
