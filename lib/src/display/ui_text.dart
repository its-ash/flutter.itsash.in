import 'package:flutter/material.dart';

import 'package:theme/src/display/display_shared.dart';
import 'package:theme/src/foundation/foundation.dart';

/// Long text clamped to [maxLines] with a "Read more / Show less" toggle.
/// The toggle only appears when the text actually overflows.
///
/// ```dart
/// UiExpandableText(post.body, maxLines: 3)
/// ```
class UiExpandableText extends StatefulWidget {
  const UiExpandableText(
    this.text, {
    super.key,
    this.maxLines = 3,
    this.style,
    this.moreLabel = 'Read more',
    this.lessLabel = 'Show less',
    this.initiallyExpanded = false,
  });

  final String text;
  final int maxLines;
  final TextStyle? style;
  final String moreLabel;
  final String lessLabel;
  final bool initiallyExpanded;

  @override
  State<UiExpandableText> createState() => _UiExpandableTextState();
}

class _UiExpandableTextState extends State<UiExpandableText> {
  late bool _expanded = widget.initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = context.text.bodyMedium!.copyWith(color: colors.text).merge(widget.style);
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: widget.text, style: style),
          maxLines: widget.maxLines,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);
        final overflows = painter.didExceedMaxLines;
        painter.dispose();

        final body = Text(
          widget.text,
          style: style,
          maxLines: _expanded || !overflows ? null : widget.maxLines,
          overflow: _expanded || !overflows ? null : TextOverflow.ellipsis,
        );
        if (!overflows) return body;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedSize(
              duration: context.motion(UiMotion.normal),
              curve: UiMotion.standard,
              alignment: Alignment.topCenter,
              child: body,
            ),
            Semantics(
              button: true,
              child: InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
                borderRadius: UiRadius.all(UiRadius.xs),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: UiSpace.sm),
                  child: Text(
                    _expanded ? widget.lessLabel : widget.moreLabel,
                    style: context.text.labelLarge?.copyWith(color: colors.accent),
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

/// Text with every case-insensitive match of [query] highlighted.
///
/// ```dart
/// UiHighlightText(contact.name, searchQuery)
/// ```
class UiHighlightText extends StatelessWidget {
  const UiHighlightText(this.text, this.query, {super.key, this.style, this.maxLines, this.overflow});

  final String text;

  /// Search term. Empty means no highlight.
  final String query;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  /// Start/end ranges of [query] in [text], case-insensitive and non-overlapping.
  static List<(int, int)> matches(String text, String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    final t = text.toLowerCase();
    // Lowercasing can change length for a few scripts; skip highlighting then.
    if (t.length != text.length) return const [];
    final out = <(int, int)>[];
    var i = t.indexOf(q);
    while (i >= 0) {
      out.add((i, i + q.length));
      i = t.indexOf(q, i + q.length);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hit = TextStyle(backgroundColor: colors.accentSoft, color: colors.onAccentSoft, fontWeight: FontWeight.w600);
    final spans = <TextSpan>[];
    var last = 0;
    for (final (s, e) in matches(text, query)) {
      if (s > last) spans.add(TextSpan(text: text.substring(last, s)));
      spans.add(TextSpan(text: text.substring(s, e), style: hit));
      last = e;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(
      TextSpan(children: spans),
      style: style,
      maxLines: maxLines,
      overflow: overflow ?? (maxLines == null ? null : TextOverflow.ellipsis),
    );
  }
}

/// Inline monospace code, ID or token on a muted chip, optionally copyable.
///
/// ```dart
/// UiCodeText('A1B2-C3D4', copyable: true)
/// ```
class UiCodeText extends StatelessWidget {
  const UiCodeText(this.code, {super.key, this.copyable = false, this.fontSize = 13});

  final String code;
  final bool copyable;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: UiRadius.all(UiRadius.xs),
        border: Border.all(color: colors.border),
      ),
      child: Text(
        code,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: UiTypography.mono(fontSize: fontSize, color: colors.text),
      ),
    );
    if (!copyable) return chip;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: chip),
        DisplayCopyButton(code, size: fontSize + 1),
      ],
    );
  }
}

/// A block of monospace code with an optional title and copy button.
/// Long lines scroll horizontally unless [wrap] is true.
///
/// ```dart
/// UiCodeBlock('flutter pub add theme', title: 'Terminal')
/// ```
class UiCodeBlock extends StatelessWidget {
  const UiCodeBlock(this.code, {super.key, this.title, this.copyable = true, this.wrap = false, this.fontSize = 13});

  final String code;

  /// Caption on the top bar, e.g. a language or file name.
  final String? title;
  final bool copyable;

  /// Wraps long lines instead of scrolling.
  final bool wrap;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final codeText = Text(
      code,
      softWrap: wrap,
      style: UiTypography.mono(
        fontSize: fontSize,
        fontWeight: FontWeight.w400,
        color: colors.text,
      ).copyWith(height: 1.55),
    );
    final hasBar = title != null;
    return Container(
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: UiRadius.all(UiRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (hasBar)
            Container(
              padding: const EdgeInsetsDirectional.only(start: UiSpace.md),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.labelMedium?.copyWith(color: colors.textMuted),
                    ),
                  ),
                  if (copyable) DisplayCopyButton(code) else const SizedBox(height: 40),
                ],
              ),
            ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(UiSpace.md),
                  child: wrap ? codeText : SingleChildScrollView(scrollDirection: Axis.horizontal, child: codeText),
                ),
              ),
              if (!hasBar && copyable) DisplayCopyButton(code),
            ],
          ),
        ],
      ),
    );
  }
}
