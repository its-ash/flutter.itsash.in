import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiTag extends StatelessWidget {
  const UiTag(this.label, {super.key, this.status = UiStatus.neutral, this.icon, this.solid = false, this.size = UiSize.md, this.color});

  final String label;
  final UiStatus status;
  final IconData? icon;
  final bool solid;
  final UiSize size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.tone(status);
    final bg = color ?? (solid ? t.color : t.container);
    final fg = color != null ? (ThemeData.estimateBrightnessForColor(color!) == Brightness.dark ? Colors.white : Colors.black) : (solid ? t.onColor : t.onContainer);
    final (padH, padV, fs) = switch (size) {
      UiSize.sm => (6.0, 2.0, 10.0),
      UiSize.md => (10.0, 4.0, 12.0),
      UiSize.lg => (12.0, 6.0, 13.0),
    };
    return Container(
      padding: EdgeInsets.symmetric(horizontal: padH, vertical: padV),
      decoration: BoxDecoration(color: bg, borderRadius: context.tokens.full),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: fs + 2, color: fg), const SizedBox(width: UiSpace.xs)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelSmall?.copyWith(color: fg, fontSize: fs, fontWeight: FontWeight.w700, letterSpacing: 0.2),
            ),
          ),
        ],
      ),
    );
  }
}
