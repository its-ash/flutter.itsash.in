import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Visual style of a [UiCard].
enum UiCardVariant {
  /// Surface with a 1 px border. The default.
  outlined,

  /// Muted fill, no border.
  filled,

  /// Surface with a border and a soft shadow.
  elevated,

  /// No fill and no border; only shows feedback when tapped.
  ghost,
}

/// A rounded content container with optional header, footer and tap feedback.
///
/// ```dart
/// UiCard(child: Text('Hello'), onTap: open)
/// ```
class UiCard extends StatefulWidget {
  const UiCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(UiSpace.lg),
    this.onTap,
    this.onLongPress,
    this.variant = UiCardVariant.outlined,
    this.selected = false,
    this.header,
    this.footer,
    this.radius = UiRadius.lg,
    this.semanticLabel,
  });

  final Widget child;

  /// Padding around [child], [header] and [footer].
  final EdgeInsetsGeometry padding;

  /// Makes the card tappable with press feedback.
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final UiCardVariant variant;

  /// Shows an accent border and focus ring.
  final bool selected;

  /// Shown above [child], separated by a divider.
  final Widget? header;

  /// Shown below [child], separated by a divider.
  final Widget? footer;
  final double radius;
  final String? semanticLabel;

  @override
  State<UiCard> createState() => _UiCardState();
}

class _UiCardState extends State<UiCard> {
  bool _pressed = false;

  bool get _interactive => widget.onTap != null || widget.onLongPress != null;

  void _setPressed(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final radius = UiRadius.all(widget.radius);
    final selected = widget.selected;

    final Color fill = switch (widget.variant) {
      UiCardVariant.outlined || UiCardVariant.elevated => colors.surface,
      UiCardVariant.filled => colors.surfaceMuted,
      UiCardVariant.ghost => Colors.transparent,
    };
    final Color borderColor = selected
        ? colors.accent
        : switch (widget.variant) {
            UiCardVariant.outlined || UiCardVariant.elevated => colors.border,
            UiCardVariant.filled || UiCardVariant.ghost => Colors.transparent,
          };

    final sections = <Widget>[
      if (widget.header != null) ...[Padding(padding: widget.padding, child: widget.header), const Divider(height: 1)],
      Padding(padding: widget.padding, child: widget.child),
      if (widget.footer != null) ...[const Divider(height: 1), Padding(padding: widget.padding, child: widget.footer)],
    ];
    Widget content = sections.length == 1
        ? sections.first
        : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: sections);

    if (_interactive) {
      content = InkWell(
        onTap: widget.onTap,
        onLongPress: widget.onLongPress,
        onHighlightChanged: _setPressed,
        borderRadius: radius,
        child: content,
      );
    }

    Widget card = Material(
      color: selected && widget.variant == UiCardVariant.ghost ? colors.accentSoft : fill,
      shape: RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );

    final shadows = <BoxShadow>[
      if (widget.variant == UiCardVariant.elevated) ...context.shadowMd,
      if (selected) BoxShadow(color: colors.accent.withValues(alpha: 0.18), spreadRadius: 3),
    ];
    card = AnimatedContainer(
      duration: context.motion(UiMotion.normal),
      curve: UiMotion.standard,
      decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
      child: card,
    );

    if (_interactive) {
      card = AnimatedScale(
        scale: _pressed ? 0.985 : 1,
        duration: context.motion(UiMotion.fast),
        curve: UiMotion.standard,
        child: card,
      );
    }
    return Semantics(
      container: true,
      button: _interactive,
      selected: selected,
      label: widget.semanticLabel,
      child: card,
    );
  }
}
