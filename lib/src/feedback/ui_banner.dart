import 'package:flutter/material.dart';

import 'package:theme/src/feedback/ui_status_icon.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiBanner extends StatelessWidget {
  const UiBanner(
    this.message, {
    super.key,
    this.status = UiStatus.info,
    this.title,
    this.icon,
    this.actionLabel,
    this.onAction,
    this.onClose,
  });

  final String message;
  final UiStatus status;
  final String? title;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final t = context.tone(status);
    final hasAction = actionLabel != null && onAction != null;
    return Semantics(
      container: true,
      liveRegion: status == UiStatus.danger || status == UiStatus.warning,
      child: Container(
        padding: EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.md, onClose == null ? UiSpace.lg : UiSpace.xs, UiSpace.md),
        decoration: BoxDecoration(
          color: t.container,
          borderRadius: context.tokens.md,
          border: Border.all(color: t.color.withValues(alpha: 0.25)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(icon ?? status.icon, size: 22, color: t.onContainer),
            ),
            const UiGap.md(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null) ...[
                    Text(title!, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: t.onContainer)),
                    const SizedBox(height: UiSpace.xxs),
                  ],
                  Text(message, style: context.text.bodyMedium?.copyWith(color: t.onContainer.withValues(alpha: 0.9))),
                  if (hasAction)
                    Padding(
                      padding: const EdgeInsets.only(top: UiSpace.sm),
                      child: InkWell(
                        onTap: onAction,
                        borderRadius: context.tokens.xs,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
                          child: Text(
                            actionLabel!,
                            style: context.text.labelLarge?.copyWith(
                              color: t.onContainer,
                              fontWeight: FontWeight.w700,
                              decoration: TextDecoration.underline,
                              decorationColor: t.onContainer,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (onClose != null)
              IconButton(
                onPressed: onClose,
                tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close_rounded, size: 18, color: t.onContainer),
              ),
          ],
        ),
      ),
    );
  }
}
