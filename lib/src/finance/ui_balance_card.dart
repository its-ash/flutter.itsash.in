import 'package:flutter/material.dart';

import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/finance/ui_amount.dart';
import 'package:theme/src/finance/ui_quick_actions.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiBalanceCard extends StatefulWidget {
  const UiBalanceCard({
    super.key,
    required this.balance,
    this.label = 'Total balance',
    this.symbol,
    this.change,
    this.changeLabel,
    this.accountNumber,
    this.masked = false,
    this.onMaskChanged,
    this.actions = const [],
    this.gradient,
    this.trailing,
    this.onTap,
  });

  final double balance;
  final String label;
  final String? symbol;
  final double? change;
  final String? changeLabel;
  final String? accountNumber;
  final bool masked;
  final ValueChanged<bool>? onMaskChanged;
  final List<UiQuickAction> actions;
  final Gradient? gradient;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  State<UiBalanceCard> createState() => _UiBalanceCardState();
}

class _UiBalanceCardState extends State<UiBalanceCard> {
  late bool _masked = widget.masked;

  @override
  void didUpdateWidget(UiBalanceCard old) {
    super.didUpdateWidget(old);
    if (old.masked != widget.masked) _masked = widget.masked;
  }

  void _toggle() {
    setState(() => _masked = !_masked);
    widget.onMaskChanged?.call(_masked);
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final fg = cs.onPrimary;
    final muted = fg.withValues(alpha: 0.78);
    final ch = widget.change;
    final acct = widget.accountNumber;

    return Container(
      decoration: BoxDecoration(
        gradient: widget.gradient ?? context.palette.gradient,
        borderRadius: context.tokens.xl,
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: context.isDark ? 0.2 : 0.3),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        borderRadius: context.tokens.xl,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          child: Stack(
            children: [
              Positioned(
                right: -40,
                top: -50,
                child: _Blob(size: 160, color: fg.withValues(alpha: 0.08)),
              ),
              Positioned(
                right: 40,
                bottom: -70,
                child: _Blob(size: 140, color: fg.withValues(alpha: 0.06)),
              ),
              Padding(
                padding: const EdgeInsets.all(UiSpace.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.bodyMedium?.copyWith(color: muted),
                          ),
                        ),
                        ?widget.trailing,
                      ],
                    ),
                    const UiGap.xs(),
                    Row(
                      children: [
                        Flexible(
                          child: AnimatedSwitcher(
                            duration: UiDuration.fast,
                            child: UiAmount(
                              widget.balance,
                              key: ValueKey(_masked),
                              symbol: widget.symbol,
                              masked: _masked,
                              signed: false,
                              colored: false,
                              splitDecimals: true,
                              style: context.text.headlineLarge?.copyWith(color: fg, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        IconButton(
                          tooltip: _masked ? 'Show balance' : 'Hide balance',
                          onPressed: _toggle,
                          icon: Icon(_masked ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: muted, size: 20),
                        ),
                      ],
                    ),
                    if ((ch != null && ch.isFinite) || acct != null) ...[
                      const UiGap.sm(),
                      Row(
                        children: [
                          if (ch != null && ch.isFinite)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: UiSpace.xs),
                              decoration: BoxDecoration(color: fg.withValues(alpha: 0.18), borderRadius: context.tokens.full),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    ch >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                                    size: 16,
                                    color: fg,
                                  ),
                                  const SizedBox(width: UiSpace.xs),
                                  Text(
                                    UiFormat.percent(ch),
                                    style: context.text.labelMedium?.copyWith(color: fg, fontWeight: FontWeight.w700),
                                  ),
                                ],
                              ),
                            ),
                          if (widget.changeLabel != null) ...[
                            const UiGap.sm(),
                            Flexible(
                              child: Text(
                                widget.changeLabel!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodySmall?.copyWith(color: muted),
                              ),
                            ),
                          ],
                          const Spacer(),
                          if (acct != null)
                            Text(
                              UiFormat.masked(acct),
                              style: context.text.labelLarge?.copyWith(color: muted, letterSpacing: 1.5),
                            ),
                        ],
                      ),
                    ],
                    if (widget.actions.isNotEmpty) ...[
                      const UiGap.xl(),
                      UiQuickActions(
                        actions: widget.actions,
                        size: 48,
                        background: fg.withValues(alpha: 0.18),
                        foreground: fg,
                        labelColor: fg,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      );
}
