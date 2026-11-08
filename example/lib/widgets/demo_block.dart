import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

String pic(String seed, [int w = 600, int h = 600]) => 'https://picsum.photos/seed/$seed/$w/$h';

final now = DateTime.now();

DateTime ago({int days = 0, int hours = 0, int minutes = 0}) =>
    now.subtract(Duration(days: days, hours: hours, minutes: minutes));

DateTime ahead({int days = 0, int hours = 0, int minutes = 0}) =>
    now.add(Duration(days: days, hours: hours, minutes: minutes));

class DemoBlock extends StatelessWidget {
  const DemoBlock(this.title, {super.key, required this.child, this.subtitle});

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: UiSpace.xxl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(title, style: context.text.titleMedium),
            if (subtitle != null)
              Text(subtitle!, style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant)),
            const UiGap.md(),
            child,
          ],
        ),
      );
}

class SectionPage extends StatelessWidget {
  const SectionPage({super.key, required this.children, this.maxWidth = 960});

  final List<Widget> children;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.xl),
        child: UiMaxWidth(
          maxWidth: maxWidth,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        ),
      );
}

class WrapRow extends StatelessWidget {
  const WrapRow({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: UiSpace.sm,
        runSpacing: UiSpace.sm,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      );
}

void toast(BuildContext context, String msg) => context.showToast(msg, status: UiStatus.info);
