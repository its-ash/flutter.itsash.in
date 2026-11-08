import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';

class UiListTile extends StatelessWidget {
  const UiListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.destructive = false,
    this.dense = false,
    this.enabled = true,
    this.selected = false,
    this.padding,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool destructive;
  final bool dense;
  final bool enabled;
  final bool selected;
  final EdgeInsetsGeometry? padding;

  bool get hasLeading => leading != null || icon != null;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final d = dense ? 34.0 : 40.0;
    final (bg, fg) = destructive
        ? (cs.errorContainer, cs.onErrorContainer)
        : iconColor != null
            ? (iconColor!.withValues(alpha: context.isDark ? 0.22 : 0.14), iconColor!)
            : (cs.primaryContainer, cs.onPrimaryContainer);
    final lead = leading ??
        (icon == null
            ? null
            : Container(
                width: d,
                height: d,
                decoration: BoxDecoration(color: bg, borderRadius: context.tokens.sm),
                child: Icon(icon, size: dense ? 18 : 20, color: fg),
              ));
    final tap = enabled ? onTap : null;
    final trail = trailing ?? (onTap == null ? null : Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant));
    final titleStyle = (dense ? context.text.bodyMedium : context.text.bodyLarge)
        ?.copyWith(fontWeight: FontWeight.w600, color: destructive ? cs.error : cs.onSurface);

    return MergeSemantics(
      child: Semantics(
        button: tap != null,
        enabled: enabled,
        selected: selected,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: Material(
            color: selected ? cs.secondaryContainer.withValues(alpha: 0.6) : Colors.transparent,
            child: InkWell(
              onTap: tap,
              onLongPress: enabled ? onLongPress : null,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: dense ? 48 : 60),
                child: Padding(
                  padding: padding ??
                      EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: dense ? UiSpace.xs : UiSpace.sm),
                  child: Row(
                    children: [
                      if (lead != null) ...[lead, const UiGap.md()],
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: titleStyle),
                            if (subtitle != null && subtitle!.isNotEmpty)
                              Text(
                                subtitle!,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                              ),
                          ],
                        ),
                      ),
                      if (trail != null) ...[
                        const UiGap.sm(),
                        IconTheme.merge(data: IconThemeData(color: cs.onSurfaceVariant), child: trail),
                      ],
                    ],
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

enum _SettingsKind { nav, toggle, value, action }

class UiSettingsTile extends StatelessWidget {
  const UiSettingsTile.nav({
    super.key,
    required this.title,
    this.icon,
    this.subtitle,
    this.value,
    required this.onTap,
    this.iconColor,
  })  : _kind = _SettingsKind.nav,
        checked = false,
        onChanged = null,
        destructive = false;

  const UiSettingsTile.toggle({
    super.key,
    required this.title,
    required this.checked,
    required this.onChanged,
    this.icon,
    this.subtitle,
    this.iconColor,
  })  : _kind = _SettingsKind.toggle,
        value = null,
        onTap = null,
        destructive = false;

  const UiSettingsTile.value({
    super.key,
    required this.title,
    required String this.value,
    this.icon,
    this.subtitle,
    this.onTap,
    this.iconColor,
  })  : _kind = _SettingsKind.value,
        checked = false,
        onChanged = null,
        destructive = false;

  const UiSettingsTile.action({
    super.key,
    required this.title,
    required this.onTap,
    this.icon,
    this.subtitle,
    this.destructive = true,
    this.iconColor,
  })  : _kind = _SettingsKind.action,
        value = null,
        checked = false,
        onChanged = null;

  final _SettingsKind _kind;
  final String title;
  final IconData? icon;
  final String? subtitle;
  final String? value;
  final bool checked;
  final ValueChanged<bool>? onChanged;
  final VoidCallback? onTap;
  final bool destructive;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    Widget valueText(String v) => ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 160),
          child: Text(
            v,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        );
    const chevron = Icon(Icons.chevron_right_rounded);
    final trailing = switch (_kind) {
      _SettingsKind.toggle => Switch(value: checked, onChanged: onChanged),
      _SettingsKind.action => const SizedBox.shrink(),
      _SettingsKind.nav || _SettingsKind.value => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (value != null && value!.isNotEmpty) valueText(value!),
            if (onTap != null) chevron,
          ],
        ),
    };
    final change = onChanged;
    return UiListTile(
      title: title,
      subtitle: subtitle,
      icon: icon,
      iconColor: iconColor,
      destructive: destructive,
      trailing: trailing,
      enabled: _kind != _SettingsKind.toggle || change != null,
      onTap: _kind == _SettingsKind.toggle ? (change == null ? null : () => change(!checked)) : onTap,
    );
  }
}

class UiListGroup extends StatelessWidget {
  const UiListGroup({
    super.key,
    required this.children,
    this.header,
    this.footer,
    this.dividerIndent,
    this.margin = const EdgeInsets.only(bottom: UiSpace.xl),
  });

  final List<Widget> children;
  final String? header;
  final String? footer;
  final double? dividerIndent;
  final EdgeInsetsGeometry margin;

  static bool _leading(Widget w) => switch (w) {
        UiListTile t => t.hasLeading,
        UiSettingsTile t => t.icon != null,
        _ => false,
      };

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final indent = dividerIndent ?? (children.every(_leading) ? UiSpace.lg + 40 + UiSpace.md : UiSpace.lg);
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.sm),
              child: Semantics(
                header: true,
                child: Text(
                  header!,
                  style: context.text.labelLarge?.copyWith(color: cs.onSurfaceVariant, letterSpacing: 0.2),
                ),
              ),
            ),
          UiCard(
            padding: EdgeInsets.zero,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0) Divider(height: 1, indent: indent),
                  children[i],
                ],
              ],
            ),
          ),
          if (footer != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.sm, UiSpace.lg, 0),
              child: Text(footer!, style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
            ),
        ],
      ),
    );
  }
}
