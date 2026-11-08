import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/navigation/ui_indicators.dart';
import 'package:theme/src/button/ui_button.dart';
import 'package:theme/src/image/ui_image.dart';

@immutable
class UiOnboardingPage {
  const UiOnboardingPage({required this.title, this.body, this.image, this.icon, this.visual});

  final String title;
  final String? body;
  final String? image;
  final IconData? icon;
  final Widget? visual;
}

class UiOnboarding extends StatefulWidget {
  const UiOnboarding({
    super.key,
    required this.pages,
    required this.onDone,
    this.onSkip,
    this.skipLabel = 'Skip',
    this.nextLabel = 'Next',
    this.doneLabel = 'Get started',
  });

  final List<UiOnboardingPage> pages;
  final VoidCallback onDone;
  final VoidCallback? onSkip;
  final String skipLabel;
  final String nextLabel;
  final String doneLabel;

  @override
  State<UiOnboarding> createState() => _UiOnboardingState();
}

class _UiOnboardingState extends State<UiOnboarding> {
  final _ctrl = PageController();
  int _i = 0;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _last => _i >= widget.pages.length - 1;

  void _go(int i) {
    if (i < 0 || i >= widget.pages.length) return;
    MediaQuery.disableAnimationsOf(context)
        ? _ctrl.jumpToPage(i)
        : _ctrl.animateToPage(i, duration: UiDuration.slow, curve: UiCurve.emphasized);
  }

  void _next() => _last ? widget.onDone() : _go(_i + 1);

  @override
  Widget build(BuildContext context) {
    final pages = widget.pages;
    if (pages.isEmpty) return const SizedBox.shrink();
    return SafeArea(
      child: Column(
        children: [
          SizedBox(
            height: 56,
            child: Align(
              alignment: AlignmentDirectional.centerEnd,
              child: AnimatedOpacity(
                opacity: _last ? 0 : 1,
                duration: UiDuration.fast,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
                  child: TextButton(
                    onPressed: _last ? null : (widget.onSkip ?? widget.onDone),
                    child: Text(widget.skipLabel),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _ctrl,
              itemCount: pages.length,
              onPageChanged: (i) => setState(() => _i = i),
              itemBuilder: (context, i) => _Page(pages[i]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(UiSpace.xxl, UiSpace.lg, UiSpace.xxl, UiSpace.xxl),
            child: Row(
              children: [
                UiPageDots(count: pages.length, index: _i, controller: _ctrl, onTap: _go),
                const Spacer(),
                AnimatedSize(
                  duration: UiDuration.normal,
                  curve: UiCurve.standard,
                  child: UiButton(
                    _last ? widget.doneLabel : widget.nextLabel,
                    trailingIcon: _last ? null : Icons.arrow_forward_rounded,
                    onPressed: _next,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page(this.page);

  final UiOnboardingPage page;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final img = page.image?.trim() ?? '';
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth > 720 && c.maxWidth > c.maxHeight;
        final dim = (wide ? c.maxHeight * 0.8 : c.maxHeight * 0.48).clamp(120.0, 420.0);
        final visual = page.visual ??
            (img.isNotEmpty
                ? UiImage(img, width: dim, height: dim, fit: BoxFit.contain, semanticLabel: page.title)
                : Container(
                    width: dim * 0.8,
                    height: dim * 0.8,
                    decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
                    child: Icon(page.icon ?? Icons.auto_awesome_rounded, size: dim * 0.32, color: cs.onPrimaryContainer),
                  ));
        final text = Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
          children: [
            Semantics(
              header: true,
              child: Text(
                page.title,
                textAlign: wide ? TextAlign.start : TextAlign.center,
                style: context.text.headlineMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.15),
              ),
            ),
            if (page.body?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: UiSpace.md),
              Text(
                page.body!,
                textAlign: wide ? TextAlign.start : TextAlign.center,
                style: context.text.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.5),
              ),
            ],
          ],
        );
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: UiSpace.xxl),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: c.maxHeight),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: wide
                    ? Row(
                        children: [
                          Expanded(child: Center(child: visual)),
                          const SizedBox(width: UiSpace.huge),
                          Expanded(child: text),
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [visual, const SizedBox(height: UiSpace.xxxl), text],
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
