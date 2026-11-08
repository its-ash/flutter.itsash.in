import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiExpandableText extends StatefulWidget {
  const UiExpandableText(
    this.text, {
    super.key,
    this.maxLines = 3,
    this.style,
    this.moreLabel = 'Read more',
    this.lessLabel = 'Read less',
  });

  final String text;
  final int maxLines;
  final TextStyle? style;
  final String moreLabel;
  final String lessLabel;

  @override
  State<UiExpandableText> createState() => _UiExpandableTextState();
}

class _UiExpandableTextState extends State<UiExpandableText> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant, height: 1.5);
    final lines = widget.maxLines < 1 ? 1 : widget.maxLines;
    return LayoutBuilder(
      builder: (_, box) {
        final tp = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: lines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: box.maxWidth.isFinite ? box.maxWidth : double.infinity);
        final overflow = tp.didExceedMaxLines;
        tp.dispose();
        if (!overflow) return Text(widget.text, style: style);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSize(
              duration: UiDuration.normal,
              curve: UiCurve.standard,
              alignment: Alignment.topCenter,
              child: Text(
                widget.text,
                style: style,
                maxLines: _open ? null : lines,
                overflow: _open ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: UiSpace.xs),
            Semantics(
              button: true,
              expanded: _open,
              child: InkWell(
                onTap: () => setState(() => _open = !_open),
                borderRadius: context.tokens.xs,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: UiSpace.xxs),
                  child: Text(
                    _open ? widget.lessLabel : widget.moreLabel,
                    style: context.text.labelLarge?.copyWith(color: context.colors.primary, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
