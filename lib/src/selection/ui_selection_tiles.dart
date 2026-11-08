import 'package:flutter/material.dart';

import 'package:theme/src/chip/ui_chips.dart';
import 'package:theme/src/input/ui_field_label.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class _TileShell extends StatelessWidget {
  const _TileShell({
    required this.title,
    required this.control,
    required this.onTap,
    this.subtitle,
    this.leading,
    this.highlight = false,
    this.controlFirst = false,
  });

  final String title;
  final String? subtitle;
  final IconData? leading;
  final Widget control;
  final VoidCallback? onTap;
  final bool highlight;
  final bool controlFirst;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final enabled = onTap != null;
    final r = context.tokens.md;
    final fg = enabled ? cs.onSurface : cs.onSurface.withValues(alpha: 0.38);
    final sub = enabled ? cs.onSurfaceVariant : cs.onSurfaceVariant.withValues(alpha: 0.38);
    return AnimatedContainer(
      duration: UiDuration.fast,
      decoration: BoxDecoration(
        color: highlight ? cs.primaryContainer.withValues(alpha: context.isDark ? 0.35 : 0.5) : cs.surfaceContainerLow,
        borderRadius: r,
        border: Border.all(
          color: highlight ? cs.primary : cs.outlineVariant.withValues(alpha: 0.5),
          width: highlight ? 1.4 : 1,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: r,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
            child: Row(
              children: [
                if (controlFirst) ...[control, const SizedBox(width: UiSpace.md)],
                if (leading != null) ...[
                  Icon(leading, size: 22, color: highlight ? cs.primary : sub),
                  const SizedBox(width: UiSpace.md),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(title, style: context.text.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: fg)),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: UiSpace.xxs),
                          child: Text(subtitle!, style: context.text.bodyMedium?.copyWith(color: sub)),
                        ),
                    ],
                  ),
                ),
                if (!controlFirst) ...[const SizedBox(width: UiSpace.md), control],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UiCheckboxTile extends StatelessWidget {
  const UiCheckboxTile(
    this.title, {
    super.key,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? subtitle;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final cb = onChanged;
    final tap = cb == null ? null : () => cb(!value);
    return Semantics(
      container: true,
      checked: value,
      enabled: cb != null,
      label: title,
      hint: subtitle,
      onTap: tap,
      child: ExcludeSemantics(
        child: _TileShell(
          title: title,
          subtitle: subtitle,
          leading: leading,
          onTap: tap,
          highlight: value,
          control: Checkbox(value: value, onChanged: cb == null ? null : (v) => cb(v ?? false)),
        ),
      ),
    );
  }
}

class UiSwitchTile extends StatelessWidget {
  const UiSwitchTile(
    this.title, {
    super.key,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.leading,
  });

  final String title;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? subtitle;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final cb = onChanged;
    final tap = cb == null ? null : () => cb(!value);
    return Semantics(
      container: true,
      toggled: value,
      enabled: cb != null,
      label: title,
      hint: subtitle,
      onTap: tap,
      child: ExcludeSemantics(
        child: _TileShell(
          title: title,
          subtitle: subtitle,
          leading: leading,
          onTap: tap,
          control: Switch(value: value, onChanged: cb),
        ),
      ),
    );
  }
}

class _RadioDot extends StatelessWidget {
  const _RadioDot({required this.selected, required this.enabled});

  final bool selected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final c = !enabled ? cs.onSurface.withValues(alpha: 0.38) : (selected ? cs.primary : cs.outline);
    return AnimatedContainer(
      duration: UiDuration.fast,
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: c, width: 2)),
      child: AnimatedScale(
        duration: UiDuration.fast,
        curve: UiCurve.standard,
        scale: selected ? 1 : 0,
        child: Container(width: 11, height: 11, decoration: BoxDecoration(shape: BoxShape.circle, color: c)),
      ),
    );
  }
}

enum UiRadioLayout { list, chips }

class UiRadioGroup<T> extends StatelessWidget {
  const UiRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.labelBuilder,
    this.subtitleBuilder,
    this.iconBuilder,
    this.layout = UiRadioLayout.list,
    this.label,
    this.spacing = UiSpace.sm,
  });

  final List<T> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String Function(T)? labelBuilder;
  final String? Function(T)? subtitleBuilder;
  final IconData? Function(T)? iconBuilder;
  final UiRadioLayout layout;
  final String? label;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    String lbl(T v) => labelBuilder?.call(v) ?? v.toString();
    final cb = onChanged;
    final Widget body = switch (layout) {
      UiRadioLayout.chips => UiChoiceChips<T>(
          options: options,
          value: value,
          onChanged: cb,
          labelBuilder: lbl,
          iconBuilder: iconBuilder,
        ),
      UiRadioLayout.list => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (i, o) in options.indexed) ...[
              if (i > 0) SizedBox(height: spacing),
              Semantics(
                container: true,
                inMutuallyExclusiveGroup: true,
                checked: o == value,
                enabled: cb != null,
                label: lbl(o),
                onTap: cb == null ? null : () => cb(o),
                child: ExcludeSemantics(
                  child: _TileShell(
                    title: lbl(o),
                    subtitle: subtitleBuilder?.call(o),
                    leading: iconBuilder?.call(o),
                    onTap: cb == null ? null : () => cb(o),
                    highlight: o == value,
                    controlFirst: true,
                    control: _RadioDot(selected: o == value, enabled: cb != null),
                  ),
                ),
              ),
            ],
          ],
        ),
    };
    return UiFieldLabel(label, child: body);
  }
}

class UiCheckboxGroup<T> extends StatelessWidget {
  const UiCheckboxGroup({
    super.key,
    required this.options,
    required this.values,
    required this.onChanged,
    this.labelBuilder,
    this.subtitleBuilder,
    this.iconBuilder,
    this.label,
    this.max,
    this.spacing = UiSpace.sm,
  });

  final List<T> options;
  final List<T> values;
  final ValueChanged<List<T>>? onChanged;
  final String Function(T)? labelBuilder;
  final String? Function(T)? subtitleBuilder;
  final IconData? Function(T)? iconBuilder;
  final String? label;
  final int? max;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final cb = onChanged;
    final full = max != null && values.length >= max!;
    void toggle(T o, bool on) {
      if (cb == null) return;
      final next = [for (final x in options) if (x == o ? on : values.contains(x)) x];
      cb(next);
    }

    return UiFieldLabel(
      label,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (i, o) in options.indexed) ...[
            if (i > 0) SizedBox(height: spacing),
            UiCheckboxTile(
              labelBuilder?.call(o) ?? o.toString(),
              subtitle: subtitleBuilder?.call(o),
              leading: iconBuilder?.call(o),
              value: values.contains(o),
              onChanged: cb == null || (full && !values.contains(o)) ? null : (v) => toggle(o, v),
            ),
          ],
        ],
      ),
    );
  }
}
