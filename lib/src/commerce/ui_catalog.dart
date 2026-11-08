import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:theme/src/display/ui_countdown.dart';
import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/foundation/ui_money.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/button/ui_button.dart';
import 'package:theme/src/image/ui_image.dart';

bool _has(String? s) => s != null && s.trim().isNotEmpty;

class UiCategoryChip extends StatelessWidget {
  const UiCategoryChip(this.label, {super.key, this.icon, this.imageUrl, this.selected = false, this.onTap, this.size = 64});

  final String label;
  final IconData? icon;
  final String? imageUrl;
  final bool selected;
  final VoidCallback? onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final d = size.isFinite ? size.clamp(32.0, 160.0).toDouble() : 64.0;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: context.tokens.lg,
        child: Padding(
          padding: const EdgeInsets.all(UiSpace.xs),
          child: SizedBox(
            width: d + UiSpace.md,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: UiDuration.normal,
                  curve: UiCurve.standard,
                  width: d,
                  height: d,
                  padding: EdgeInsets.all(selected ? 3 : 0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? cs.primary : Colors.transparent, width: 2),
                  ),
                  child: ClipOval(
                    child: _has(imageUrl)
                        ? UiImage(imageUrl, placeholderIcon: icon ?? Icons.category_outlined)
                        : AnimatedContainer(
                            duration: UiDuration.normal,
                            color: selected ? cs.primaryContainer : cs.surfaceContainerHigh,
                            alignment: Alignment.center,
                            child: Icon(
                              icon ?? Icons.category_outlined,
                              size: d * 0.42,
                              color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                            ),
                          ),
                  ),
                ),
                const UiGap.sm(),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: context.text.labelMedium?.copyWith(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? cs.primary : cs.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class UiCategoryTile extends StatelessWidget {
  const UiCategoryTile(this.label, {super.key, this.imageUrl, this.icon, this.subtitle, this.onTap, this.aspectRatio = 1.2, this.height});

  final String label;
  final String? imageUrl;
  final IconData? icon;
  final String? subtitle;
  final VoidCallback? onTap;
  final double aspectRatio;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final img = _has(imageUrl);
    final fg = img ? Colors.white : cs.onSecondaryContainer;
    final tile = ClipRRect(
      borderRadius: context.tokens.lg,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (img) UiImage(imageUrl) else ColoredBox(color: cs.secondaryContainer),
          if (img)
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.35, 1],
                  colors: [Colors.transparent, Colors.black54],
                ),
              ),
            )
          else
            Positioned(
              top: UiSpace.md,
              right: UiSpace.md,
              child: Icon(icon ?? Icons.category_outlined, size: 32, color: fg.withValues(alpha: 0.8)),
            ),
          Positioned(
            left: UiSpace.md,
            right: UiSpace.md,
            bottom: UiSpace.md,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w700),
                ),
                if (subtitle != null)
                  Text(subtitle!, maxLines: 1, style: context.text.bodySmall?.copyWith(color: fg.withValues(alpha: 0.85))),
              ],
            ),
          ),
          Material(type: MaterialType.transparency, child: InkWell(onTap: onTap)),
        ],
      ),
    );
    final ar = aspectRatio.isFinite && aspectRatio > 0 ? aspectRatio : 1.2;
    return Semantics(
      button: onTap != null,
      label: subtitle == null ? label : '$label, $subtitle',
      onTap: onTap,
      excludeSemantics: true,
      child: height != null ? SizedBox(height: height, child: tile) : AspectRatio(aspectRatio: ar, child: tile),
    );
  }
}

class UiPromoBanner extends StatelessWidget {
  const UiPromoBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.ctaLabel,
    this.onTap,
    this.imageUrl,
    this.trailingImageUrl,
    this.gradient,
    this.minHeight = 168,
  });

  final String title;
  final String? subtitle;
  final String? eyebrow;
  final String? ctaLabel;
  final VoidCallback? onTap;
  final String? imageUrl;
  final String? trailingImageUrl;
  final Gradient? gradient;
  final double minHeight;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final bg = _has(imageUrl);
    final fg = bg ? Colors.white : cs.onPrimary;
    final ctaFg = bg ? Colors.black : cs.primary;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: 3),
            decoration: BoxDecoration(color: fg.withValues(alpha: 0.18), borderRadius: context.tokens.full),
            child: Text(
              eyebrow!.toUpperCase(),
              style: context.text.labelSmall?.copyWith(color: fg, fontWeight: FontWeight.w800, letterSpacing: 0.8),
            ),
          ),
          const UiGap.sm(),
        ],
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: context.text.headlineSmall?.copyWith(color: fg, fontWeight: FontWeight.w800, height: 1.15),
        ),
        if (subtitle != null) ...[
          const UiGap.xs(),
          Text(
            subtitle!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.text.bodyMedium?.copyWith(color: fg.withValues(alpha: 0.9)),
          ),
        ],
        if (ctaLabel != null) ...[
          const UiGap.md(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.sm),
            decoration: BoxDecoration(color: fg, borderRadius: context.tokens.full),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(ctaLabel!, style: context.text.labelLarge?.copyWith(color: ctaFg, fontWeight: FontWeight.w700)),
                const UiGap.xs(),
                Icon(Icons.arrow_forward_rounded, size: 16, color: ctaFg),
              ],
            ),
          ),
        ],
      ],
    );

    return Semantics(
      button: onTap != null,
      label: [eyebrow, title, subtitle, ctaLabel].nonNulls.join(', '),
      onTap: onTap,
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: context.tokens.xl,
        child: Stack(
          children: [
            Positioned.fill(
              child: bg ? UiImage(imageUrl) : DecoratedBox(decoration: BoxDecoration(gradient: gradient ?? context.palette.gradient)),
            ),
            if (bg)
              const Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [Colors.black54, Colors.transparent]),
                  ),
                ),
              )
            else ...[
              Positioned(
                right: -48,
                top: -48,
                child: Container(
                  width: 168,
                  height: 168,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: fg.withValues(alpha: 0.08)),
                ),
              ),
              Positioned(
                right: 40,
                bottom: -64,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: fg.withValues(alpha: 0.06)),
                ),
              ),
            ],
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight.isFinite && minHeight > 0 ? minHeight : 168, minWidth: double.infinity),
              child: Padding(
                padding: const EdgeInsets.all(UiSpace.xl),
                child: Row(
                  children: [
                    Expanded(child: content),
                    if (_has(trailingImageUrl)) ...[
                      const UiGap.md(),
                      UiImage(trailingImageUrl, width: 112, height: 112, fit: BoxFit.contain, radius: context.tokens.md),
                    ],
                  ],
                ),
              ),
            ),
            Positioned.fill(child: Material(type: MaterialType.transparency, child: InkWell(onTap: onTap))),
          ],
        ),
      ),
    );
  }
}

class UiFlashSale extends StatefulWidget {
  const UiFlashSale({
    super.key,
    required this.endsAt,
    this.title = 'Flash sale',
    this.endedText = 'Sale ended',
    this.onSeeAll,
    this.seeAllLabel = 'See all',
    this.onEnded,
    this.icon = Icons.bolt_rounded,
  });

  final DateTime endsAt;
  final String title;
  final String endedText;
  final VoidCallback? onSeeAll;
  final String seeAllLabel;
  final VoidCallback? onEnded;
  final IconData icon;

  @override
  State<UiFlashSale> createState() => _UiFlashSaleState();
}

class _UiFlashSaleState extends State<UiFlashSale> {
  late bool _ended = !widget.endsAt.isAfter(DateTime.now());

  @override
  void didUpdateWidget(covariant UiFlashSale old) {
    super.didUpdateWidget(old);
    if (old.endsAt != widget.endsAt) _ended = !widget.endsAt.isAfter(DateTime.now());
  }

  void _done() {
    if (!mounted || _ended) return;
    setState(() => _ended = true);
    widget.onEnded?.call();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final sale = context.palette.sale;

    return Row(
      children: [
        Icon(widget.icon, color: sale, size: 22),
        const UiGap.xs(),
        Flexible(
          child: Text(
            widget.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
        const UiGap.md(),
        _ended
            ? Text(widget.endedText, style: context.text.labelLarge?.copyWith(color: cs.onSurfaceVariant))
            : UiCountdown(target: widget.endsAt, labels: false, size: UiSize.sm, color: sale, onDone: _done),
        const Spacer(),
        if (widget.onSeeAll != null)
          TextButton(
            onPressed: widget.onSeeAll,
            style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
            child: Text(widget.seeAllLabel),
          ),
      ],
    );
  }
}

class UiSortFilterBar extends StatelessWidget {
  const UiSortFilterBar({
    super.key,
    this.onSort,
    this.onFilter,
    this.sortLabel = 'Sort',
    this.filterLabel = 'Filter',
    this.filterCount = 0,
    this.resultCount,
    this.resultLabel = 'results',
    this.isGrid,
    this.onViewChanged,
  });

  final VoidCallback? onSort;
  final VoidCallback? onFilter;
  final String sortLabel;
  final String filterLabel;
  final int filterCount;
  final int? resultCount;
  final String resultLabel;
  final bool? isGrid;
  final ValueChanged<bool>? onViewChanged;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final n = math.max(0, filterCount);

    Widget pill(IconData icon, String label, VoidCallback? fn, {bool active = false}) => OutlinedButton.icon(
          onPressed: fn,
          icon: Icon(icon, size: 18),
          label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            visualDensity: VisualDensity.compact,
            foregroundColor: active ? cs.onSecondaryContainer : cs.onSurface,
            backgroundColor: active ? cs.secondaryContainer : null,
            side: BorderSide(color: active ? cs.secondaryContainer : cs.outlineVariant),
            padding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
          ),
        );

    return Row(
      children: [
        Expanded(
          child: resultCount == null
              ? const SizedBox.shrink()
              : Text(
                  '${UiFormat.number(math.max(0, resultCount!))} $resultLabel',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.text.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
        ),
        Flexible(flex: 0, child: pill(Icons.swap_vert_rounded, sortLabel, onSort)),
        const UiGap.sm(),
        Badge(
          isLabelVisible: n > 0,
          label: Text('$n'),
          offset: const Offset(-2, -2),
          child: Semantics(
            label: n > 0 ? '$filterLabel, $n active' : null,
            child: pill(Icons.tune_rounded, filterLabel, onFilter, active: n > 0),
          ),
        ),
        if (isGrid != null) ...[
          const UiGap.sm(),
          UiIconButton(
            isGrid! ? Icons.view_agenda_outlined : Icons.grid_view_rounded,
            onPressed: onViewChanged == null ? null : () => onViewChanged!(!isGrid!),
            tooltip: isGrid! ? 'List view' : 'Grid view',
            variant: UiIconButtonVariant.outline,
            size: UiSize.sm,
          ),
        ],
      ],
    );
  }
}

class UiPriceRangeFilter extends StatelessWidget {
  const UiPriceRangeFilter({
    super.key,
    required this.min,
    required this.max,
    required this.values,
    this.onChanged,
    this.onChangeEnd,
    this.divisions,
    this.symbol,
    this.title = 'Price range',
  });

  final num min;
  final num max;
  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;
  final int? divisions;
  final String? symbol;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final lo = UiMoney.safe(min);
    final valid = UiMoney.safe(max) > lo;
    final hi = valid ? UiMoney.safe(max) : lo + 1;
    double c(double v) => v.isFinite ? v.clamp(lo, hi).toDouble() : lo;
    final a = c(values.start);
    final b = c(values.end);
    final r = RangeValues(math.min(a, b), math.max(a, b));
    String f(double v) => UiMoney.format(v, symbol: symbol, decimals: 0);
    final muted = context.text.labelMedium?.copyWith(color: cs.onSurfaceVariant);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (title != null)
              Expanded(child: Text(title!, style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700)))
            else
              const Spacer(),
            Text(
              '${f(r.start)} – ${f(r.end)}',
              style: context.text.labelLarge?.copyWith(color: cs.primary, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        RangeSlider(
          values: r,
          min: lo,
          max: hi,
          divisions: divisions != null && divisions! > 0 ? divisions : null,
          labels: RangeLabels(f(r.start), f(r.end)),
          onChanged: valid ? onChanged : null,
          onChangeEnd: valid ? onChangeEnd : null,
        ),
        Row(
          children: [
            Text(f(lo), style: muted),
            const Spacer(),
            Text(f(valid ? hi : lo), style: muted),
          ],
        ),
      ],
    );
  }
}

class _StrikePainter extends CustomPainter {
  const _StrikePainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawLine(
      Offset(size.width * 0.15, size.height * 0.85),
      Offset(size.width * 0.85, size.height * 0.15),
      Paint()
        ..color = color
        ..strokeWidth = 1.4
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _StrikePainter old) => old.color != color;
}

Widget _header(BuildContext context, String? label, String? value, Widget? action) {
  if (label == null && action == null) return const SizedBox.shrink();
  return Padding(
    padding: const EdgeInsets.only(bottom: UiSpace.sm),
    child: Row(
      children: [
        if (label != null)
          Expanded(
            child: Text.rich(
              TextSpan(
                text: label,
                children: [
                  if (value != null)
                    TextSpan(
                      text: ': $value',
                      style: TextStyle(fontWeight: FontWeight.w500, color: context.colors.onSurfaceVariant),
                    ),
                ],
              ),
              style: context.text.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          )
        else
          const Spacer(),
        ?action,
      ],
    ),
  );
}

class UiSizeSelector extends StatelessWidget {
  const UiSizeSelector({
    super.key,
    required this.options,
    this.selected,
    this.onChanged,
    this.unavailable = const {},
    this.label = 'Size',
    this.guideLabel = 'Size guide',
    this.onGuide,
  });

  final List<String> options;
  final String? selected;
  final ValueChanged<String>? onChanged;
  final Set<String> unavailable;
  final String? label;
  final String guideLabel;
  final VoidCallback? onGuide;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final r = context.tokens.md;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(
          context,
          label,
          options.contains(selected) ? selected : null,
          onGuide == null
              ? null
              : TextButton(
                  onPressed: onGuide,
                  style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                  child: Text(guideLabel),
                ),
        ),
        Wrap(
          spacing: UiSpace.sm,
          runSpacing: UiSpace.sm,
          children: [
            for (final o in options)
              Builder(
                builder: (context) {
                  final off = unavailable.contains(o);
                  final on = o == selected && !off;
                  final tap = off || onChanged == null ? null : () => onChanged!(o);
                  return Semantics(
                    button: true,
                    selected: on,
                    enabled: tap != null,
                    inMutuallyExclusiveGroup: true,
                    label: off ? '$o, unavailable' : o,
                    onTap: tap,
                    excludeSemantics: true,
                    child: AnimatedContainer(
                      duration: UiDuration.fast,
                      height: 44,
                      constraints: const BoxConstraints(minWidth: 52),
                      decoration: BoxDecoration(
                        color: on ? cs.primary : cs.surface,
                        borderRadius: r,
                        border: Border.all(color: on ? cs.primary : cs.outlineVariant, width: on ? 1.5 : 1),
                      ),
                      child: Material(
                        type: MaterialType.transparency,
                        borderRadius: r,
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: tap,
                          child: CustomPaint(
                            foregroundPainter: off ? _StrikePainter(cs.outline) : null,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: UiSpace.md),
                              child: Center(
                                widthFactor: 1,
                                child: Text(
                                  o,
                                  style: context.text.labelLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: on
                                        ? cs.onPrimary
                                        : off
                                            ? cs.onSurface.withValues(alpha: 0.38)
                                            : cs.onSurface,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}

class UiColorOption {
  const UiColorOption(this.color, this.name);

  final Color color;
  final String name;
}

class UiColorSelector extends StatelessWidget {
  const UiColorSelector({
    super.key,
    required this.options,
    this.selected,
    this.onChanged,
    this.unavailable = const {},
    this.label = 'Color',
    this.size = 36,
  });

  final List<UiColorOption> options;
  final String? selected;
  final ValueChanged<String>? onChanged;
  final Set<String> unavailable;
  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) return const SizedBox.shrink();
    final cs = context.colors;
    final d = size.isFinite ? size.clamp(20.0, 72.0).toDouble() : 36.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _header(context, label, options.any((o) => o.name == selected) ? selected : null, null),
        Wrap(
          spacing: UiSpace.sm,
          runSpacing: UiSpace.sm,
          children: [
            for (final o in options)
              Builder(
                builder: (context) {
                  final off = unavailable.contains(o.name);
                  final on = o.name == selected && !off;
                  final tap = off || onChanged == null ? null : () => onChanged!(o.name);
                  final check = ThemeData.estimateBrightnessForColor(o.color) == Brightness.dark ? Colors.white : Colors.black;
                  return Semantics(
                    button: true,
                    selected: on,
                    enabled: tap != null,
                    inMutuallyExclusiveGroup: true,
                    label: off ? '${o.name}, unavailable' : o.name,
                    onTap: tap,
                    excludeSemantics: true,
                    child: Tooltip(
                      message: o.name,
                      child: GestureDetector(
                        onTap: tap,
                        child: AnimatedContainer(
                          duration: UiDuration.fast,
                          width: d + 8,
                          height: d + 8,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: on ? cs.primary : Colors.transparent, width: 2),
                          ),
                          child: Opacity(
                            opacity: off ? 0.4 : 1,
                            child: CustomPaint(
                              foregroundPainter: off ? _StrikePainter(cs.onSurface) : null,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: o.color,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: cs.outlineVariant),
                                ),
                                child: AnimatedScale(
                                  scale: on ? 1 : 0,
                                  duration: UiDuration.fast,
                                  child: Icon(Icons.check_rounded, size: d * 0.5, color: check),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ],
    );
  }
}
