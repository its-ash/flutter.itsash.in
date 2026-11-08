import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

class HomeSection extends StatefulWidget {
  const HomeSection({super.key});

  @override
  State<HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<HomeSection> {
  late final Future<String> _readme = rootBundle.loadString('assets/README.md');

  @override
  Widget build(BuildContext context) => FutureBuilder<String>(
        future: _readme,
        builder: (context, snap) => switch (snap) {
          AsyncSnapshot(hasError: true) => UiErrorState(
              title: 'README not found',
              message: '${snap.error}',
              compact: true,
            ),
          AsyncSnapshot(:final data?) => SectionPage(maxWidth: 820, children: _blocks(context, data)),
          _ => const UiLoader(message: 'Loading README'),
        },
      );

  List<Widget> _blocks(BuildContext context, String src) {
    final out = <Widget>[];
    final para = <String>[];
    final code = <String>[];
    var inCode = false;
    final mono = context.text.bodySmall?.copyWith(fontFamily: 'monospace', height: 1.5);

    void flush() {
      if (para.isEmpty) return;
      out.add(Padding(
        padding: const EdgeInsets.only(bottom: UiSpace.md),
        child: SelectableText(para.join('\n'), style: context.text.bodyMedium?.copyWith(height: 1.5)),
      ));
      para.clear();
    }

    for (final line in const LineSplitter().convert(src)) {
      if (line.trimLeft().startsWith('```')) {
        if (inCode) {
          out.add(Container(
            margin: const EdgeInsets.only(bottom: UiSpace.md),
            padding: const EdgeInsets.all(UiSpace.md),
            decoration: BoxDecoration(color: context.colors.surfaceContainerHighest, borderRadius: context.tokens.sm),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(code.join('\n'), style: mono),
            ),
          ));
          code.clear();
        } else {
          flush();
        }
        inCode = !inCode;
      } else if (inCode) {
        code.add(line);
      } else if (line.startsWith('#')) {
        flush();
        final level = line.indexOf(RegExp(r'[^#]')).clamp(1, 6);
        final style = switch (level) {
          1 => context.text.headlineMedium,
          2 => context.text.titleLarge,
          _ => context.text.titleMedium,
        };
        out.add(Padding(
          padding: const EdgeInsets.only(top: UiSpace.md, bottom: UiSpace.sm),
          child: SelectableText(line.substring(level).trim(), style: style),
        ));
      } else if (line.trim().isEmpty) {
        flush();
      } else {
        para.add(line);
      }
    }
    flush();
    if (code.isNotEmpty) out.add(SelectableText(code.join('\n'), style: mono));
    return out.isEmpty ? [const UiEmptyState(title: 'README is empty')] : out;
  }
}
