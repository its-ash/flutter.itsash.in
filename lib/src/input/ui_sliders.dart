import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

String _defaultFormat(double v) => v == v.roundToDouble() ? v.toInt().toString() : v.toStringAsFixed(1);

(double, double) _bounds(double min, double max) {
  final lo = min.isFinite ? min : 0.0;
  final hi = max.isFinite ? max : lo + 1;
  return hi > lo ? (lo, hi) : (lo, lo + 1);
}

int? _divs(int? d) => d != null && d > 0 ? d : null;

class _Header extends StatelessWidget {
  const _Header(this.label, this.value);

  final String? label;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final l = label?.trim() ?? '';
    if (l.isEmpty && value == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: UiSpace.xs),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.text.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          if (value != null)
            Text(
              value!,
              style: context.text.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.primary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
        ],
      ),
    );
  }
}

class UiSlider extends StatelessWidget {
  const UiSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.label,
    this.format,
    this.showValue = true,
    this.onChangeEnd,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String Function(double)? format;
  final bool showValue;
  final ValueChanged<double>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final (lo, hi) = _bounds(min, max);
    final v = value.isFinite ? value.clamp(lo, hi) : lo;
    final f = format ?? _defaultFormat;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(label, showValue ? f(v) : null),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm)),
          child: Slider(
            value: v,
            min: lo,
            max: hi,
            divisions: _divs(divisions),
            label: f(v),
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
            semanticFormatterCallback: f,
          ),
        ),
      ],
    );
  }
}

class UiRangeSlider extends StatelessWidget {
  const UiRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.label,
    this.format,
    this.showInputs = true,
    this.onChangeEnd,
  });

  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final String Function(double)? format;
  final bool showInputs;
  final ValueChanged<RangeValues>? onChangeEnd;

  @override
  Widget build(BuildContext context) {
    final (lo, hi) = _bounds(min, max);
    double c(double x) => x.isFinite ? x.clamp(lo, hi) : lo;
    final a = c(values.start);
    final b = c(values.end);
    final r = RangeValues(a <= b ? a : b, a <= b ? b : a);
    final f = format ?? _defaultFormat;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(label, showInputs ? null : '${f(r.start)} – ${f(r.end)}'),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm)),
          child: RangeSlider(
            values: r,
            min: lo,
            max: hi,
            divisions: _divs(divisions),
            labels: RangeLabels(f(r.start), f(r.end)),
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
            semanticFormatterCallback: f,
          ),
        ),
        if (showInputs) ...[
          const SizedBox(height: UiSpace.sm),
          Row(
            children: [
              Expanded(child: _ValuePill('Min', f(r.start))),
              const SizedBox(width: UiSpace.md),
              Expanded(child: _ValuePill('Max', f(r.end))),
            ],
          ),
        ],
      ],
    );
  }
}

class _ValuePill extends StatelessWidget {
  const _ValuePill(this.caption, this.value);

  final String caption;
  final String value;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.sm + 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: context.isDark ? 0.6 : 0.7),
        borderRadius: context.tokens.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(caption, style: context.text.labelSmall?.copyWith(color: cs.onSurfaceVariant)),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
