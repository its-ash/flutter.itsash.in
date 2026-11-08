import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/card/ui_card.dart';

class UiExpandableCard extends StatefulWidget {
  const UiExpandableCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.initiallyExpanded = false,
    this.expanded,
    this.onChanged,
    this.variant = UiCardVariant.filled,
  });

  final String title;
  final Widget child;
  final String? subtitle;
  final IconData? icon;
  final bool initiallyExpanded;
  final bool? expanded;
  final ValueChanged<bool>? onChanged;
  final UiCardVariant variant;

  @override
  State<UiExpandableCard> createState() => _UiExpandableCardState();
}

class _UiExpandableCardState extends State<UiExpandableCard> {
  late bool _open = widget.expanded ?? widget.initiallyExpanded;

  @override
  void didUpdateWidget(UiExpandableCard old) {
    super.didUpdateWidget(old);
    final e = widget.expanded;
    if (e != null && e != _open) _open = e;
  }

  void _toggle() {
    final next = !_open;
    if (widget.expanded == null) setState(() => _open = next);
    widget.onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return UiCard(
      variant: widget.variant,
      padding: EdgeInsets.zero,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: _open,
            child: InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
                child: Row(
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: cs.primary, size: 22),
                      const UiGap.md(),
                    ],
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.title, style: context.text.titleSmall?.copyWith(fontSize: 15)),
                          if (widget.subtitle != null)
                            Text(
                              widget.subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                    const UiGap.sm(),
                    AnimatedRotation(
                      turns: _open ? 0.5 : 0,
                      duration: UiDuration.normal,
                      curve: UiCurve.standard,
                      child: Icon(Icons.expand_more_rounded, color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ClipRect(
            child: AnimatedAlign(
              alignment: Alignment.topCenter,
              heightFactor: _open ? 1 : 0,
              duration: UiDuration.normal,
              curve: UiCurve.standard,
              child: ExcludeFocus(
                excluding: !_open,
                child: ExcludeSemantics(
                  excluding: !_open,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(UiSpace.lg, 0, UiSpace.lg, UiSpace.lg),
                    child: DefaultTextStyle.merge(
                      style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                      child: widget.child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

@immutable
class UiAccordionItem {
  const UiAccordionItem({required this.title, required this.child, this.subtitle, this.icon});

  UiAccordionItem.text({required this.title, required String body, this.subtitle, this.icon}) : child = Text(body);

  final String title;
  final Widget child;
  final String? subtitle;
  final IconData? icon;
}

class UiAccordion extends StatefulWidget {
  const UiAccordion({
    super.key,
    required this.items,
    this.multiple = false,
    this.initialIndex,
    this.spacing = UiSpace.sm,
    this.onChanged,
    this.variant = UiCardVariant.filled,
  });

  final List<UiAccordionItem> items;
  final bool multiple;
  final int? initialIndex;
  final double spacing;
  final ValueChanged<Set<int>>? onChanged;
  final UiCardVariant variant;

  @override
  State<UiAccordion> createState() => _UiAccordionState();
}

class _UiAccordionState extends State<UiAccordion> {
  late final Set<int> _open = {
    if (widget.initialIndex case final i? when i >= 0 && i < widget.items.length) i,
  };

  @override
  void didUpdateWidget(UiAccordion old) {
    super.didUpdateWidget(old);
    _open.removeWhere((i) => i >= widget.items.length);
    if (!widget.multiple && _open.length > 1) {
      final keep = _open.first;
      _open
        ..clear()
        ..add(keep);
    }
  }

  void _set(int i, bool open) {
    setState(() {
      if (open) {
        if (!widget.multiple) _open.clear();
        _open.add(i);
      } else {
        _open.remove(i);
      }
    });
    widget.onChanged?.call(Set.unmodifiable(_open));
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(height: widget.spacing),
          UiExpandableCard(
            title: items[i].title,
            subtitle: items[i].subtitle,
            icon: items[i].icon,
            variant: widget.variant,
            expanded: _open.contains(i),
            onChanged: (v) => _set(i, v),
            child: items[i].child,
          ),
        ],
      ],
    );
  }
}
