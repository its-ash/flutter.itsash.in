import 'package:flutter/material.dart';

import 'package:theme/src/display/display_shared.dart';
import 'package:theme/src/foundation/foundation.dart';

/// A description row: muted label on the left, value on the right.
///
/// ```dart
/// UiKeyValue('Order ID', 'A-10294', copyable: true, mono: true)
/// ```
class UiKeyValue extends StatelessWidget {
  const UiKeyValue(
    this.label,
    String this.value, {
    super.key,
    this.copyable = false,
    this.mono = false,
    this.stacked = false,
    this.maxLines = 2,
  }) : child = null;

  /// A row whose value is any widget (pill, avatar, switch).
  const UiKeyValue.custom(this.label, {super.key, required Widget this.child, this.stacked = false})
    : value = null,
      copyable = false,
      mono = false,
      maxLines = 1;

  final String label;
  final String? value;
  final Widget? child;

  /// Shows a copy button for [value].
  final bool copyable;

  /// Monospace value (IDs, hashes, codes).
  final bool mono;

  /// Label above the value instead of beside it (for long values).
  final bool stacked;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final labelText = Text(
      label,
      maxLines: stacked ? 1 : 2,
      overflow: TextOverflow.ellipsis,
      style: text.bodyMedium?.copyWith(color: colors.textMuted),
    );
    final valueStyle = mono
        ? UiTypography.mono(fontSize: 13.5, color: colors.text)
        : text.bodyMedium?.copyWith(color: colors.text, fontWeight: FontWeight.w500);
    final Widget valueWidget =
        child ??
        Text(
          value!,
          maxLines: maxLines,
          overflow: TextOverflow.ellipsis,
          textAlign: stacked ? TextAlign.start : TextAlign.end,
          style: valueStyle,
        );

    final Widget content;
    if (stacked) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          labelText,
          const SizedBox(height: UiSpace.xxs),
          valueWidget,
        ],
      );
    } else {
      content = Row(
        children: [
          Flexible(flex: 2, fit: FlexFit.tight, child: labelText),
          const SizedBox(width: UiSpace.md),
          Flexible(
            flex: 3,
            child: Align(alignment: AlignmentDirectional.centerEnd, child: valueWidget),
          ),
        ],
      );
    }

    final copy = copyable && value != null;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: copy ? UiSpace.xxs : UiSpace.sm),
        child: Row(
          children: [
            Expanded(child: content),
            if (copy)
              Padding(
                padding: const EdgeInsetsDirectional.only(start: UiSpace.xxs),
                child: DisplayCopyButton(value!, tooltip: 'Copy $label'),
              ),
          ],
        ),
      ),
    );
  }
}

/// A list of [UiKeyValue] rows with optional dividers.
///
/// ```dart
/// UiKeyValueList([UiKeyValue('Status', 'Paid'), UiKeyValue('Total', '\$42.00')])
/// ```
class UiKeyValueList extends StatelessWidget {
  const UiKeyValueList(this.entries, {super.key, this.dividers = true});

  /// Rows from a map of label → value.
  UiKeyValueList.map(Map<String, String> map, {super.key, this.dividers = true})
    : entries = [for (final e in map.entries) UiKeyValue(e.key, e.value)];

  final List<UiKeyValue> entries;
  final bool dividers;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < entries.length; i++) ...[if (i > 0 && dividers) const Divider(height: 1), entries[i]],
      ],
    );
  }
}
