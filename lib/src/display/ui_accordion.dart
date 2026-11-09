import 'package:flutter/material.dart';

import 'package:theme/src/display/ui_list.dart';
import 'package:theme/src/foundation/foundation.dart';

/// One section of a [UiAccordion].
class UiAccordionItem {
  const UiAccordionItem(this.title, this.child, {this.subtitle, this.icon, this.initiallyExpanded = false});

  final String title;

  /// Content shown when expanded.
  final Widget child;
  final String? subtitle;

  /// Leading icon in a tinted box.
  final IconData? icon;
  final bool initiallyExpanded;
}

/// Collapsible sections in a bordered group, with a rotating chevron.
///
/// ```dart
/// UiAccordion(items: [UiAccordionItem('Shipping', Text('2–4 days'))])
/// ```
class UiAccordion extends StatefulWidget {
  const UiAccordion({super.key, required this.items, this.multiple = false, this.onChanged});

  final List<UiAccordionItem> items;

  /// Allows several sections open at once. Otherwise opening one closes the rest.
  final bool multiple;

  /// Called with the section index and its new expanded state.
  final void Function(int index, bool expanded)? onChanged;

  @override
  State<UiAccordion> createState() => _UiAccordionState();
}

class _UiAccordionState extends State<UiAccordion> {
  late Set<int> _open;

  @override
  void initState() {
    super.initState();
    _open = {
      for (var i = 0; i < widget.items.length; i++)
        if (widget.items[i].initiallyExpanded) i,
    };
    if (!widget.multiple && _open.length > 1) _open = {_open.first};
  }

  void _toggle(int i) {
    final expand = !_open.contains(i);
    setState(() {
      if (expand) {
        if (!widget.multiple) _open.clear();
        _open.add(i);
      } else {
        _open.remove(i);
      }
    });
    widget.onChanged?.call(i, expand);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final duration = context.motion(UiMotion.normal);
    final items = widget.items;

    Widget section(int i) {
      final item = items[i];
      final open = _open.contains(i);
      final header = Semantics(
        button: true,
        expanded: open,
        child: InkWell(
          onTap: () => _toggle(i),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 52),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
              child: Row(
                children: [
                  if (item.icon != null) ...[UiIconBox(item.icon!, size: 28), const SizedBox(width: UiSpace.md)],
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyLarge?.copyWith(fontWeight: FontWeight.w500, height: 1.3),
                        ),
                        if (item.subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: UiSpace.xxs),
                            child: Text(
                              item.subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(color: colors.textMuted),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: UiSpace.sm),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: duration,
                    curve: UiMotion.standard,
                    child: Icon(Icons.expand_more_rounded, size: 20, color: colors.textSubtle),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final body = TweenAnimationBuilder<double>(
        tween: Tween(end: open ? 1 : 0),
        duration: duration,
        curve: UiMotion.standard,
        builder: (context, t, child) => t == 0
            ? const SizedBox(width: double.infinity)
            : ClipRect(
                child: Align(
                  alignment: Alignment.topCenter,
                  heightFactor: t,
                  child: Opacity(opacity: t, child: child),
                ),
              ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            item.icon != null ? UiSpace.lg + 28 + UiSpace.md : UiSpace.lg,
            0,
            UiSpace.lg,
            UiSpace.lg,
          ),
          child: DefaultTextStyle.merge(
            style: text.bodyMedium?.copyWith(color: colors.textMuted),
            child: item.child,
          ),
        ),
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [header, body],
      );
    }

    return Material(
      color: colors.surface,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: UiRadius.all(UiRadius.lg),
        side: BorderSide(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < items.length; i++) ...[if (i > 0) const Divider(height: 1), section(i)],
        ],
      ),
    );
  }
}
