import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiFieldLabel extends StatelessWidget {
  const UiFieldLabel(this.label, {super.key, required this.child, this.isRequired = false, this.trailing});

  final String? label;
  final Widget child;
  final bool isRequired;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l = label?.trim() ?? '';
    if (l.isEmpty && trailing == null) return child;
    final cs = context.colors;
    final style = context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600, color: cs.onSurface);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text.rich(
                TextSpan(
                  text: l,
                  children: [if (isRequired) TextSpan(text: ' *', style: TextStyle(color: cs.error))],
                ),
                style: style,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ?trailing,
          ],
        ),
        const SizedBox(height: UiSpace.sm),
        child,
      ],
    );
  }
}
