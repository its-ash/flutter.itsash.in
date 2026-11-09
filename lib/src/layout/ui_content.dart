import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Centers [child] with a max width and page padding. Use it to keep text
/// and forms readable on wide screens. The child fills the width up to
/// [maxWidth].
///
/// ```dart
/// UiContent(child: Text('Readable on any screen'));
/// ```
class UiContent extends StatelessWidget {
  const UiContent({super.key, required this.child, this.maxWidth = 720, this.padding});

  final Widget child;

  /// Max width of the content. Use `double.infinity` for no limit.
  final double maxWidth;

  /// Defaults to horizontal page padding ([pagePadding]).
  final EdgeInsetsGeometry? padding;

  /// Default horizontal page padding for the screen width:
  /// 20 on phones, 24 on tablets, 32 on laptops and desktops.
  static double pagePadding(BuildContext context) =>
      context.responsive(compact: UiSpace.page, medium: UiSpace.xl, expanded: UiSpace.xxl);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: padding ?? EdgeInsets.symmetric(horizontal: pagePadding(context)),
            child: child,
          ),
        ),
      ),
    );
  }
}
