import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Master-detail layout. On wide screens [primary] (a list) and [secondary]
/// (the details) sit side by side. On narrow screens only one pane shows:
/// [secondary] when it is set, otherwise [primary].
///
/// Set [secondary] to null to go back to the list on phones. The primary
/// pane keeps its state (scroll position) in both modes.
///
/// ```dart
/// UiSplitView(primary: list, secondary: selected == null ? null : Details(selected), onCloseSecondary: clear);
/// ```
class UiSplitView extends StatefulWidget {
  const UiSplitView({
    super.key,
    required this.primary,
    this.secondary,
    this.placeholder,
    this.breakpoint = UiBreakpoint.expanded,
    this.primaryWidth = 360,
    this.onCloseSecondary,
    this.divider = true,
  });

  /// The list pane.
  final Widget primary;

  /// The detail pane. Null means nothing is selected.
  final Widget? secondary;

  /// Shown in the detail pane on wide screens when [secondary] is null.
  final Widget? placeholder;

  /// Smallest size class that shows both panes. Uses this widget's width.
  final UiBreakpoint breakpoint;

  /// Width of the list pane on wide screens (at most 45% of the width).
  final double primaryWidth;

  /// Called on system back while [secondary] fills a narrow screen.
  final VoidCallback? onCloseSecondary;

  /// Hairline between the panes.
  final bool divider;

  @override
  State<UiSplitView> createState() => _UiSplitViewState();
}

class _UiSplitViewState extends State<UiSplitView> {
  final _primaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final primary = KeyedSubtree(key: _primaryKey, child: widget.primary);
        final secondary = widget.secondary;
        final wide = UiBreakpoint.of(box.maxWidth) >= widget.breakpoint;
        if (wide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(width: math.min(widget.primaryWidth, box.maxWidth * 0.45), child: primary),
              if (widget.divider) VerticalDivider(width: 1, thickness: 1, color: c.border),
              Expanded(child: secondary ?? widget.placeholder ?? const SizedBox.shrink()),
            ],
          );
        }
        Widget body = IndexedStack(
          index: secondary == null ? 0 : 1,
          sizing: StackFit.expand,
          children: [primary, secondary ?? const SizedBox.shrink()],
        );
        final onClose = widget.onCloseSecondary;
        if (secondary != null && onClose != null) {
          body = PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (!didPop) onClose();
            },
            child: body,
          );
        }
        return body;
      },
    );
  }
}
