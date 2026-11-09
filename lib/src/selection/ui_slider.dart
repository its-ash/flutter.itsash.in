part of 'ui_selection.dart';

/// Slider with an optional label row and the current value on the end side.
///
/// ```dart
/// UiSlider(value: volume, label: 'Volume', onChanged: (v) => setState(() => volume = v))
/// ```
class UiSlider extends StatelessWidget {
  const UiSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.showValue = true,
    this.format,
  });

  final double value;

  /// Called while dragging. Null disables the slider.
  final ValueChanged<double>? onChanged;

  /// Called once when the drag ends.
  final ValueChanged<double>? onChangeEnd;

  final double min;
  final double max;

  /// Number of discrete steps, or null for a continuous slider.
  final int? divisions;

  /// Text above the slider on the start side.
  final String? label;

  /// Shows the formatted value above the slider on the end side.
  final bool showValue;

  /// Turns the value into text. Defaults to a short number.
  final String Function(double value)? format;

  @override
  Widget build(BuildContext context) {
    final fmt = format ?? _formatNumber;
    final v = value.clamp(min, max).toDouble();
    return _SliderFrame(
      label: label,
      valueText: showValue ? fmt(v) : null,
      enabled: onChanged != null,
      slider: Slider(
        value: v,
        min: min,
        max: max,
        divisions: divisions,
        label: divisions != null ? fmt(v) : null,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}

/// Two-thumb slider for picking a range, with a label row like [UiSlider].
///
/// ```dart
/// UiRangeSlider(values: price, min: 0, max: 500, label: 'Price', onChanged: (r) => setState(() => price = r))
/// ```
class UiRangeSlider extends StatelessWidget {
  const UiRangeSlider({
    super.key,
    required this.values,
    this.onChanged,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.label,
    this.showValue = true,
    this.format,
  });

  final RangeValues values;

  /// Called while dragging. Null disables the slider.
  final ValueChanged<RangeValues>? onChanged;

  /// Called once when the drag ends.
  final ValueChanged<RangeValues>? onChangeEnd;

  final double min;
  final double max;
  final int? divisions;
  final String? label;

  /// Shows "start – end" above the slider on the end side.
  final bool showValue;

  /// Turns one value into text. Defaults to a short number.
  final String Function(double value)? format;

  @override
  Widget build(BuildContext context) {
    final fmt = format ?? _formatNumber;
    final start = values.start.clamp(min, max).toDouble();
    final end = values.end.clamp(start, max).toDouble();
    final v = RangeValues(start, end);
    return _SliderFrame(
      label: label,
      valueText: showValue ? '${fmt(start)} – ${fmt(end)}' : null,
      enabled: onChanged != null,
      slider: RangeSlider(
        values: v,
        min: min,
        max: max,
        divisions: divisions,
        labels: divisions != null ? RangeLabels(fmt(start), fmt(end)) : null,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
      ),
    );
  }
}

class _SliderFrame extends StatelessWidget {
  const _SliderFrame({required this.label, required this.valueText, required this.enabled, required this.slider});

  final String? label;
  final String? valueText;
  final bool enabled;
  final Widget slider;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    if (label == null && valueText == null) return slider;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: label == null
                  ? const SizedBox.shrink()
                  : Text(
                      label!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: enabled ? c.text : c.textDisabled,
                      ),
                    ),
            ),
            if (valueText != null) ...[
              const SizedBox(width: UiSpace.sm),
              Text(
                valueText!,
                style: context.text.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: enabled ? c.textMuted : c.textDisabled,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: UiSpace.xs),
        slider,
      ],
    );
  }
}
