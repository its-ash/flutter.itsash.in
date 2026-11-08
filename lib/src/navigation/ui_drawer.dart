import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/navigation/ui_bottom_nav.dart';
import 'package:theme/src/image/ui_avatar.dart';

class UiDrawer extends StatelessWidget {
  const UiDrawer({
    super.key,
    required this.items,
    this.selectedIndex,
    this.onSelected,
    this.name,
    this.email,
    this.avatarUrl,
    this.header,
    this.footer,
  });

  final List<UiNavItem> items;
  final int? selectedIndex;
  final ValueChanged<int>? onSelected;
  final String? name;
  final String? email;
  final String? avatarUrl;
  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final sel = selectedIndex;
    final hasUser = name != null || email != null || avatarUrl != null;
    return NavigationDrawer(
      selectedIndex: sel == null || items.isEmpty || sel < 0 || sel >= items.length ? null : sel,
      onDestinationSelected: (i) {
        Scaffold.maybeOf(context)?.closeDrawer();
        onSelected?.call(i);
      },
      tilePadding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
      children: [
        ?header,
        if (header == null && hasUser)
          Padding(
            padding: const EdgeInsets.fromLTRB(UiSpace.xxl, UiSpace.lg, UiSpace.lg, UiSpace.lg),
            child: Row(
              children: [
                UiAvatar(name: name, imageUrl: avatarUrl, size: 52),
                const UiGap.md(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (name != null)
                        Text(name!, maxLines: 1, overflow: TextOverflow.ellipsis, style: context.text.titleMedium),
                      if (email != null)
                        Text(
                          email!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (header != null || hasUser)
          const Padding(
            padding: EdgeInsets.fromLTRB(UiSpace.xxl, 0, UiSpace.xxl, UiSpace.sm),
            child: Divider(),
          ),
        for (final it in items)
          NavigationDrawerDestination(
            icon: it.iconWidget(),
            selectedIcon: it.iconWidget(selected: true),
            label: Text(it.label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        if (footer != null) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(UiSpace.xxl, UiSpace.sm, UiSpace.xxl, UiSpace.sm),
            child: Divider(),
          ),
          footer!,
        ],
      ],
    );
  }
}
