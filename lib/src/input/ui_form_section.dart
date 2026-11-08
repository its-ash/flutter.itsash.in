import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiFormSection extends StatelessWidget {
  const UiFormSection({
    super.key,
    required this.children,
    this.title,
    this.subtitle,
    this.trailing,
    this.spacing = UiSpace.lg,
    this.padding = EdgeInsets.zero,
  });

  final List<Widget> children;
  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = title?.trim() ?? '';
    final s = subtitle?.trim() ?? '';
    final gap = spacing < 0 ? 0.0 : spacing;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (t.isNotEmpty || trailing != null)
            Padding(
              padding: EdgeInsets.only(bottom: children.isEmpty ? 0 : gap),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (t.isNotEmpty)
                          Semantics(
                            header: true,
                            child: Text(t, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          ),
                        if (s.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: UiSpace.xxs),
                            child: Text(s, style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
                          ),
                      ],
                    ),
                  ),
                  ?trailing,
                ],
              ),
            ),
          for (final (i, c) in children.indexed) ...[if (i > 0) SizedBox(height: gap), c],
        ],
      ),
    );
  }
}
