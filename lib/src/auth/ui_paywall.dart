import 'package:flutter/material.dart';

import 'package:theme/src/auth/ui_auth_kit.dart';
import 'package:theme/src/feedback/ui_banner.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';
import 'package:theme/src/display/ui_tag.dart';

@immutable
class UiPlan {
  const UiPlan({required this.name, required this.price, this.period, this.note, this.features = const [], this.badge});

  final String name;
  final String price;
  final String? period;
  final String? note;
  final List<String> features;
  final String? badge;
}

class UiPlanCard extends StatelessWidget {
  const UiPlanCard({
    super.key,
    required this.name,
    required this.price,
    this.period,
    this.note,
    this.features = const [],
    this.badge,
    this.selected = false,
    this.onTap,
  });

  UiPlanCard.plan(UiPlan plan, {super.key, this.selected = false, this.onTap})
      : name = plan.name,
        price = plan.price,
        period = plan.period,
        note = plan.note,
        features = plan.features,
        badge = plan.badge;

  final String name;
  final String price;
  final String? period;
  final String? note;
  final List<String> features;
  final String? badge;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final r = context.tokens.lg;
    final b = badge?.trim() ?? '';
    final per = period?.trim() ?? '';
    final card = AnimatedContainer(
      duration: UiDuration.normal,
      curve: UiCurve.standard,
      decoration: BoxDecoration(
        color: selected ? cs.primaryContainer.withValues(alpha: context.isDark ? 0.25 : 0.4) : cs.surfaceContainerLow,
        borderRadius: r,
        border: Border.all(color: selected ? cs.primary : cs.outlineVariant, width: selected ? 2 : 1),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: r,
          child: Padding(
            padding: EdgeInsets.fromLTRB(UiSpace.lg, b.isEmpty ? UiSpace.lg : UiSpace.xl, UiSpace.lg, UiSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          if (note?.trim().isNotEmpty ?? false)
                            Text(note!, style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(width: UiSpace.md),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: price, style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w800, color: cs.onSurface)),
                          if (per.isNotEmpty) TextSpan(text: ' $per', style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    const SizedBox(width: UiSpace.md),
                    AnimatedContainer(
                      duration: UiDuration.fast,
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? cs.primary : Colors.transparent,
                        border: Border.all(color: selected ? cs.primary : cs.outline, width: 2),
                      ),
                      child: selected ? Icon(Icons.check_rounded, size: 16, color: cs.onPrimary) : null,
                    ),
                  ],
                ),
                if (features.isNotEmpty) ...[
                  const SizedBox(height: UiSpace.md),
                  for (final f in features)
                    Padding(
                      padding: const EdgeInsets.only(top: UiSpace.xs + 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 18, color: context.palette.success),
                          const SizedBox(width: UiSpace.sm),
                          Expanded(child: Text(f, style: context.text.bodyMedium)),
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: onTap != null,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: [name, if (per.isEmpty) price else '$price $per', if (b.isNotEmpty) b].join(', '),
      child: b.isEmpty
          ? card
          : Padding(
              padding: const EdgeInsets.only(top: 11),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  card,
                  PositionedDirectional(
                    start: UiSpace.lg,
                    top: -11,
                    child: UiTag(b, solid: true, color: cs.primary, icon: Icons.star_rounded),
                  ),
                ],
              ),
            ),
    );
  }
}

class UiPaywall extends StatefulWidget {
  const UiPaywall({
    super.key,
    required this.plans,
    required this.onSubscribe,
    this.title = 'Go Premium',
    this.subtitle,
    this.icon = Icons.workspace_premium_rounded,
    this.header,
    this.features = const [],
    this.initialPlan = 0,
    this.ctaLabel = 'Continue',
    this.footnote,
    this.onRestore,
    this.onTerms,
    this.onPrivacy,
    this.onClose,
  });

  final List<UiPlan> plans;
  final Future<String?> Function(int index) onSubscribe;
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget? header;
  final List<String> features;
  final int initialPlan;
  final String ctaLabel;
  final String? footnote;
  final VoidCallback? onRestore;
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;
  final VoidCallback? onClose;

  @override
  State<UiPaywall> createState() => _UiPaywallState();
}

class _UiPaywallState extends State<UiPaywall> {
  late int _sel = widget.plans.isEmpty ? 0 : widget.initialPlan.clamp(0, widget.plans.length - 1);
  bool _busy = false;
  String? _error;

  @override
  void didUpdateWidget(UiPaywall old) {
    super.didUpdateWidget(old);
    if (widget.plans.isNotEmpty && _sel >= widget.plans.length) _sel = widget.plans.length - 1;
  }

  Future<void> _buy() async {
    if (_busy || widget.plans.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    String? err;
    try {
      err = await widget.onSubscribe(_sel);
    } catch (_) {
      err = 'Something went wrong. Try again.';
    }
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = err;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final links = [
      if (widget.onRestore != null) ('Restore', widget.onRestore!),
      if (widget.onTerms != null) ('Terms', widget.onTerms!),
      if (widget.onPrivacy != null) ('Privacy', widget.onPrivacy!),
    ];
    return SafeArea(
      child: Column(
        children: [
          if (widget.onClose != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: Padding(
                padding: const EdgeInsets.all(UiSpace.sm),
                child: UiIconButton(Icons.close_rounded, onPressed: _busy ? null : widget.onClose, tooltip: 'Close', size: UiSize.sm),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(UiSpace.xl, UiSpace.sm, UiSpace.xl, UiSpace.lg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: widget.header ??
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(gradient: context.palette.gradient, borderRadius: context.tokens.xl),
                              child: Icon(widget.icon, size: 42, color: cs.onPrimary),
                            ),
                      ),
                      const SizedBox(height: UiSpace.xl),
                      Semantics(
                        header: true,
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (widget.subtitle?.trim().isNotEmpty ?? false) ...[
                        const SizedBox(height: UiSpace.sm),
                        Text(
                          widget.subtitle!,
                          textAlign: TextAlign.center,
                          style: context.text.bodyLarge?.copyWith(color: cs.onSurfaceVariant, height: 1.4),
                        ),
                      ],
                      if (widget.features.isNotEmpty) ...[
                        const SizedBox(height: UiSpace.xl),
                        for (final f in widget.features)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: UiSpace.xs + 2),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(color: cs.primaryContainer, shape: BoxShape.circle),
                                  child: Icon(Icons.check_rounded, size: 18, color: cs.onPrimaryContainer),
                                ),
                                const SizedBox(width: UiSpace.md),
                                Expanded(child: Text(f, style: context.text.bodyLarge)),
                              ],
                            ),
                          ),
                      ],
                      const SizedBox(height: UiSpace.xl),
                      for (var i = 0; i < widget.plans.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: UiSpace.md),
                          child: UiPlanCard.plan(
                            widget.plans[i],
                            selected: i == _sel,
                            onTap: _busy ? null : () => setState(() => _sel = i),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(UiSpace.xl, 0, UiSpace.xl, UiSpace.sm),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_error != null) ...[UiBanner(_error!, status: UiStatus.danger), const SizedBox(height: UiSpace.md)],
                  UiButton(
                    widget.ctaLabel,
                    onPressed: widget.plans.isEmpty ? null : _buy,
                    loading: _busy,
                    size: UiSize.lg,
                    expand: true,
                  ),
                  if (widget.footnote?.trim().isNotEmpty ?? false) ...[
                    const SizedBox(height: UiSpace.sm),
                    Text(
                      widget.footnote!,
                      textAlign: TextAlign.center,
                      style: context.text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                  if (links.isNotEmpty)
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (var i = 0; i < links.length; i++) ...[
                          if (i > 0) Text('·', style: TextStyle(color: cs.onSurfaceVariant)),
                          UiAuthLink(links[i].$1, onTap: _busy ? null : links[i].$2),
                        ],
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
