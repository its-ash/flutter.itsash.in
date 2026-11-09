import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/navigation/ui_nav_item.dart';

/// Bottom navigation bar for phones.
///
/// The standard bar sits flush at the bottom with a top hairline. The
/// [floating] variant is a rounded pill with a shadow, inset from the screen
/// edges and lifted above the home indicator. Set `extendBody: true` on the
/// `Scaffold` so content scrolls behind a floating bar (`UiShell` does this).
///
/// ```dart
/// UiBottomNav(items: items, index: tab, onChanged: (i) => setState(() => tab = i));
/// ```
class UiBottomNav extends StatelessWidget {
  const UiBottomNav({
    super.key,
    required this.items,
    required this.index,
    required this.onChanged,
    this.floating = false,
    this.showLabels = true,
  });

  final List<UiNavItem> items;

  /// Index of the selected item.
  final int index;

  /// Called with the tapped index. Null disables the bar.
  final ValueChanged<int>? onChanged;

  /// Rounded pill style that floats above the content.
  final bool floating;

  /// Shows labels under the icons. Icons get a tooltip when false.
  final bool showLabels;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final safeBottom = MediaQuery.paddingOf(context).bottom;
    final onChanged = this.onChanged;
    final row = SizedBox(
      height: showLabels ? 64 : 56,
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++)
            Expanded(
              child: _BottomNavItem(
                item: items[i],
                selected: i == index,
                showLabels: showLabels,
                onTap: onChanged == null ? null : () => onChanged(i),
              ),
            ),
        ],
      ),
    );

    final Widget bar;
    if (floating) {
      bar = Padding(
        padding: EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, math.max(safeBottom, UiSpace.lg)),
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: c.surfaceRaised,
                borderRadius: UiRadius.all(UiRadius.full),
                border: Border.all(color: c.border),
                boxShadow: context.shadowMd,
              ),
              child: Material(
                type: MaterialType.transparency,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
                  child: row,
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      bar = DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.border)),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Padding(
            padding: EdgeInsets.only(bottom: safeBottom),
            child: row,
          ),
        ),
      );
    }
    return MediaQuery.withClampedTextScaling(maxScaleFactor: 1.3, child: bar);
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({required this.item, required this.selected, required this.showLabels, required this.onTap});

  final UiNavItem item;
  final bool selected;
  final bool showLabels;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onTap != null;
    final iconColor = !enabled
        ? c.textDisabled
        : selected
        ? c.onAccentSoft
        : c.textMuted;
    final labelColor = !enabled
        ? c.textDisabled
        : selected
        ? c.text
        : c.textMuted;
    final pillColor = selected ? (enabled ? c.accentSoft : c.surfaceMuted) : c.accentSoft.withValues(alpha: 0);
    final d = context.motion(UiMotion.normal);

    Widget content = LayoutBuilder(
      builder: (context, box) {
        final maxPill = math.max(32.0, box.maxWidth - UiSpace.sm);
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: d,
              curve: UiMotion.emphasized,
              width: math.min(selected ? 56.0 : 32.0, maxPill),
              height: 32,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: pillColor, borderRadius: UiRadius.all(UiRadius.full)),
              child: item.buildIcon(context, selected: selected, color: iconColor, size: 22),
            ),
            if (showLabels) ...[
              const SizedBox(height: UiSpace.xs),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
                child: AnimatedDefaultTextStyle(
                  duration: d,
                  style: context.text.labelSmall!.copyWith(
                    color: labelColor,
                    letterSpacing: 0,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  child: Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                ),
              ),
            ],
          ],
        );
      },
    );

    content = InkWell(
      onTap: onTap,
      borderRadius: UiRadius.all(UiRadius.md),
      splashFactory: NoSplash.splashFactory,
      child: content,
    );
    if (!showLabels) content = Tooltip(message: item.label, child: content);
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      enabled: enabled,
      label: showLabels ? null : item.label,
      child: content,
    );
  }
}
