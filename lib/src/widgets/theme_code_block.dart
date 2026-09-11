import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ThemeCodeBlock extends StatelessWidget {
  const ThemeCodeBlock({
    super.key,
    required this.code,
    this.language,
    this.showCopyButton = true,
    this.borderRadius,
  });

  final String code;
  final String? language;
  final bool showCopyButton;

  /// Corner radius for the code block surface. Defaults to the active
  /// theme's card radius (`Theme.of(context).cardTheme.shape`) — pass an
  /// explicit value to opt out.
  final double? borderRadius;

  double _radius(BuildContext context) {
    if (borderRadius != null) return borderRadius!;
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? scheme.surfaceContainerHigh : const Color(0xFF0D1117);
    final fg = isDark ? scheme.onSurface : const Color(0xFFE6EDF3);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_radius(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (language != null || showCopyButton)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
              child: Row(
                children: [
                  if (language != null)
                    Text(
                      language!,
                      style: TextStyle(color: fg.withValues(alpha: 0.6), fontSize: 12),
                    ),
                  const Spacer(),
                  if (showCopyButton)
                    IconButton(
                      icon: Icon(Icons.copy_outlined, size: 16, color: fg.withValues(alpha: 0.7)),
                      tooltip: 'Copy',
                      visualDensity: VisualDensity.compact,
                      onPressed: () => Clipboard.setData(ClipboardData(text: code)),
                    ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Text(
                code,
                style: TextStyle(
                  color: fg,
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
