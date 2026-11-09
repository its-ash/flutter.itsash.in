import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';

/// Frames a form control: a label above it (with an optional required `*`
/// and a trailing widget such as a "Forgot?" link) and a helper or error
/// line below it, with an optional counter on the right.
///
/// ```dart
/// UiFieldLabel(label: 'Email', isRequired: true, error: err, child: myInput)
/// ```
class UiFieldLabel extends StatelessWidget {
  const UiFieldLabel({
    super.key,
    required this.child,
    this.label,
    this.isRequired = false,
    this.trailing,
    this.helper,
    this.error,
    this.counter,
    this.enabled = true,
  });

  /// The control being labelled.
  final Widget child;

  /// Text above the control. When null and [trailing] is null, no label row is shown.
  final String? label;

  /// Adds a danger-colored `*` after the label.
  final bool isRequired;

  /// Widget at the end of the label row, e.g. a small text button.
  final Widget? trailing;

  /// Hint text below the control. Replaced by [error] when set.
  final String? helper;

  /// Error text below the control, in the danger color.
  final String? error;

  /// Small text at the end of the helper row, e.g. `12 / 200`.
  final String? counter;

  /// When false the label uses the disabled text color.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasError = error != null && error!.isNotEmpty;
    final bottomText = hasError ? error : helper;
    final showBottom = (bottomText != null && bottomText.isNotEmpty) || counter != null;
    final small = context.text.bodySmall ?? const TextStyle(fontSize: 12.5);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null || trailing != null)
          Padding(
            padding: const EdgeInsets.only(bottom: UiSpace.sm - 2),
            child: Row(
              children: [
                Expanded(
                  child: label == null
                      ? const SizedBox.shrink()
                      : Text.rich(
                          TextSpan(
                            text: label,
                            children: [
                              if (isRequired)
                                TextSpan(
                                  text: ' *',
                                  style: TextStyle(color: enabled ? c.danger : c.textDisabled),
                                ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.labelLarge?.copyWith(
                            color: enabled ? c.text : c.textDisabled,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: UiSpace.sm),
                  DefaultTextStyle.merge(style: context.text.labelMedium, child: trailing!),
                ],
              ],
            ),
          ),
        child,
        AnimatedSize(
          duration: context.motion(UiMotion.fast),
          curve: UiMotion.standard,
          alignment: Alignment.topCenter,
          child: !showBottom
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: UiSpace.xs + 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasError) ...[
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Icon(Icons.error_outline_rounded, size: 14, color: c.danger),
                        ),
                        const SizedBox(width: UiSpace.xs),
                      ],
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: context.motion(UiMotion.fast),
                          layoutBuilder: (current, previous) =>
                              Stack(alignment: AlignmentDirectional.topStart, children: [...previous, ?current]),
                          child: Text(
                            bottomText ?? '',
                            key: ValueKey('${hasError}_$bottomText'),
                            style: small.copyWith(color: hasError ? c.danger : c.textSubtle),
                          ),
                        ),
                      ),
                      if (counter != null) ...[
                        const SizedBox(width: UiSpace.sm),
                        Text(
                          counter!,
                          style: small.copyWith(
                            color: hasError ? c.danger : c.textSubtle,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
