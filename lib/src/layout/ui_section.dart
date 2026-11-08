import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiSection extends StatelessWidget {
  const UiSection({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.onSeeAll,
    this.actionLabel = 'See all',
    this.trailing,
    this.headerPadding = EdgeInsets.zero,
    this.spacing = UiSpace.md,
    this.margin = const EdgeInsets.only(bottom: UiSpace.xxl),
  });

  final Widget child;
  final String? title;
  final String? subtitle;
  final VoidCallback? onSeeAll;
  final String actionLabel;
  final Widget? trailing;
  final EdgeInsetsGeometry headerPadding;
  final double spacing;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final hasHeader = title != null || subtitle != null || trailing != null || onSeeAll != null;
    final action = trailing ??
        (onSeeAll == null
            ? null
            : TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 36),
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(actionLabel),
              ));
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader)
            Padding(
              padding: headerPadding,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          Semantics(
                            header: true,
                            child: Text(
                              title!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.titleLarge?.copyWith(fontSize: 19),
                            ),
                          ),
                        if (subtitle != null)
                          Padding(
                            padding: const EdgeInsets.only(top: UiSpace.xxs),
                            child: Text(
                              subtitle!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                      ],
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
          if (hasHeader) SizedBox(height: spacing),
          child,
        ],
      ),
    );
  }
}

class UiDividerText extends StatelessWidget {
  const UiDividerText({super.key, this.text = 'or'});

  final String text;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Semantics(
      label: text,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: UiSpace.md),
          child: Row(
            children: [
              const Expanded(child: Divider()),
              if (text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
                  child: Text(text, style: context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant)),
                ),
              const Expanded(child: Divider()),
            ],
          ),
        ),
      ),
    );
  }
}
