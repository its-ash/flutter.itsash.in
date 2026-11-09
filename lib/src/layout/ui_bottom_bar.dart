import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Sticky bottom action area ("Checkout", "Save") with a top hairline and
/// surface fill. Stays above the home indicator and the keyboard.
///
/// Pass one [child], or [children] that share the width equally.
/// Put it in `UiScaffold.bottomBar` or `Scaffold.bottomNavigationBar`.
///
/// ```dart
/// UiBottomBar(child: FilledButton(onPressed: pay, child: const Text('Pay')));
/// ```
class UiBottomBar extends StatelessWidget {
  const UiBottomBar({
    super.key,
    this.child,
    this.children,
    this.gap = UiSpace.sm,
    this.padding,
    this.maxWidth = 720,
    this.border = true,
    this.keyboardAware = true,
  }) : assert(child != null || children != null, 'Pass child or children');

  final Widget? child;

  /// Laid out in a row, each with equal width.
  final List<Widget>? children;

  /// Space between [children].
  final double gap;

  /// Space around the content (safe area is added on top).
  final EdgeInsetsGeometry? padding;

  /// Content is centered with this max width on wide screens.
  final double maxWidth;

  /// Hairline above the bar.
  final bool border;

  /// Moves the bar above the on-screen keyboard.
  final bool keyboardAware;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final safe = MediaQuery.paddingOf(context).bottom;
    final keyboard = keyboardAware ? MediaQuery.viewInsetsOf(context).bottom : 0.0;
    final items = children;
    final content =
        child ??
        Row(
          children: [
            for (var i = 0; i < items!.length; i++) ...[if (i > 0) SizedBox(width: gap), Expanded(child: items[i])],
          ],
        );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: border ? Border(top: BorderSide(color: c.border)) : null,
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: math.max(safe, keyboard)),
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Padding(
              padding: padding ?? const EdgeInsets.fromLTRB(UiSpace.page, UiSpace.md, UiSpace.page, UiSpace.md),
              child: SizedBox(width: double.infinity, child: content),
            ),
          ),
        ),
      ),
    );
  }
}
