import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Title row for a block of content, with an optional subtitle and a
/// trailing action ("See all").
///
/// ```dart
/// UiSectionHeader('Recent', actionLabel: 'See all', onAction: openAll);
/// ```
class UiSectionHeader extends StatelessWidget {
  const UiSectionHeader(
    this.title, {
    super.key,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.action,
    this.padding = EdgeInsets.zero,
  });

  final String title;
  final String? subtitle;

  /// Text of a trailing text button.
  final String? actionLabel;

  /// Called by the [actionLabel] button. Null disables it.
  final VoidCallback? onAction;

  /// Custom trailing widget. Used instead of [actionLabel].
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = context.text;
    final trailing =
        action ?? (actionLabel == null ? null : TextButton(onPressed: onAction, child: Text(actionLabel!)));
    return Padding(
      padding: padding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: t.titleMedium),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: UiSpace.xxs),
                  Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis, style: t.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: UiSpace.sm), trailing],
        ],
      ),
    );
  }
}

/// A [UiSectionHeader] above its content.
///
/// ```dart
/// UiSection(title: 'Recent', actionLabel: 'See all', onAction: openAll, child: list);
/// ```
class UiSection extends StatelessWidget {
  const UiSection({
    super.key,
    this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.action,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.gap = UiSpace.md,
  });

  /// Header title. Null shows no header.
  final String? title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? action;
  final Widget child;

  /// Space around the whole section.
  final EdgeInsetsGeometry padding;

  /// Space between header and content.
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            UiSectionHeader(title!, subtitle: subtitle, actionLabel: actionLabel, onAction: onAction, action: action),
            SizedBox(height: gap),
          ],
          child,
        ],
      ),
    );
  }
}
