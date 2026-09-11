import 'package:flutter/material.dart';

class ThemeAccordion extends StatefulWidget {
  const ThemeAccordion({
    super.key,
    required this.title,
    required this.children,
    this.leading,
    this.trailing,
    this.initiallyExpanded = false,
    this.expandIcon,
  });

  final Widget title;
  final List<Widget> children;
  final Widget? leading;
  final Widget? trailing;
  final bool initiallyExpanded;
  final IconData? expandIcon;

  @override
  State<ThemeAccordion> createState() => _ThemeAccordionState();
}

class _ThemeAccordionState extends State<ThemeAccordion>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 250),
  )..value = widget.initiallyExpanded ? 1 : 0;

  bool get _expanded => _c.value > 0.5;

  void _toggle() => _expanded ? _c.reverse() : _c.forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _cardRadius(BuildContext context) {
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(_cardRadius(context));
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: radius,
        border: Border.all(color: scheme.outline.withValues(alpha: 0.5)),
      ),
      // ClipRRect (not just Container.clipBehavior) so nested Material/Ink
      // layers (InkWell splash, SizeTransition content) round correctly too.
      child: ClipRRect(
        borderRadius: radius,
        child: Column(children: [
          InkWell(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                if (widget.leading != null) ...[widget.leading!, const SizedBox(width: 10)],
                Expanded(child: DefaultTextStyle.merge(style: Theme.of(context).textTheme.titleMedium ?? const TextStyle(), child: widget.title)),
                if (widget.trailing != null) ...[const SizedBox(width: 8), widget.trailing!],
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.25).animate(_c),
                  child: Icon(widget.expandIcon ?? Icons.keyboard_arrow_down_rounded, color: scheme.onSurfaceVariant),
                ),
              ]),
            ),
          ),
          SizeTransition(
            sizeFactor: _c,
            child: Column(children: [
              Divider(height: 1, color: scheme.outline.withValues(alpha: 0.5)),
              ...widget.children,
            ]),
          ),
        ]),
      ),
    );
  }
}

class ThemeAccordionList extends StatelessWidget {
  const ThemeAccordionList({super.key, required this.items, this.initiallyExpandedIndex});
  final List<ThemeAccordionItem> items;
  final int? initiallyExpandedIndex;

  @override
  Widget build(BuildContext context) => Column(
    children: [for (var i = 0; i < items.length; i++)
      Padding(padding: const EdgeInsets.only(bottom: 8), child: ThemeAccordion(
        title: items[i].title,
        children: items[i].children,
        leading: items[i].leading,
        trailing: items[i].trailing,
        initiallyExpanded: i == initiallyExpandedIndex,
      ))],
  );
}

class ThemeAccordionItem {
  const ThemeAccordionItem({required this.title, required this.children, this.leading, this.trailing});
  final Widget title;
  final List<Widget> children;
  final Widget? leading;
  final Widget? trailing;
}