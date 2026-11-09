import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/input/field_style.dart';
import 'package:theme/src/input/ui_field_label.dart';

/// Small date and time formatter used by the date fields (no `intl` needed).
abstract final class UiDateFormat {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  /// `Mar 5, 2026`
  static String date(DateTime d) => '${_months[d.month - 1]} ${d.day}, ${d.year}';

  /// `Mar 5 – 9, 2026`, `Mar 30 – Apr 2, 2026` or `Dec 30, 2025 – Jan 2, 2026`.
  static String range(DateTimeRange r) {
    final s = r.start;
    final e = r.end;
    if (s.year != e.year) return '${date(s)} – ${date(e)}';
    if (s.month != e.month) return '${_months[s.month - 1]} ${s.day} – ${_months[e.month - 1]} ${e.day}, ${e.year}';
    if (s.day != e.day) return '${_months[s.month - 1]} ${s.day} – ${e.day}, ${e.year}';
    return date(s);
  }

  /// `9:05 AM` or `09:05`, following the device 24-hour setting.
  static String time(BuildContext context, TimeOfDay t) => MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(t, alwaysUse24HourFormat: MediaQuery.maybeAlwaysUse24HourFormatOf(context) ?? false);
}

/// Read-only field that opens the date picker. Shows the date formatted,
/// with a clear button.
///
/// ```dart
/// UiDateField(label: 'Birthday', value: date, onChanged: (d) => setState(() => date = d))
/// ```
class UiDateField extends StatelessWidget {
  const UiDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Select date',
    this.helper,
    this.error,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.format,
    this.clearable = true,
    this.size = UiSize.md,
    this.isRequired = false,
    this.prefixIcon = Icons.calendar_today_rounded,
  });

  final DateTime? value;

  /// Called with the picked date, or null when cleared. Null disables the field.
  final ValueChanged<DateTime?>? onChanged;
  final String? label;
  final String hint;
  final String? helper;
  final String? error;
  final FormFieldValidator<DateTime>? validator;

  /// Earliest pickable date. Defaults to 1900-01-01.
  final DateTime? firstDate;

  /// Latest pickable date. Defaults to 2100-12-31.
  final DateTime? lastDate;

  /// Custom display text. Defaults to [UiDateFormat.date].
  final String Function(DateTime)? format;

  /// Shows a clear button when a value is set.
  final bool clearable;
  final UiSize size;
  final bool isRequired;
  final IconData prefixIcon;

  @override
  Widget build(BuildContext context) {
    final first = firstDate ?? DateTime(1900);
    final last = lastDate ?? DateTime(2100, 12, 31);
    return _PickerField<DateTime>(
      value: value,
      text: value == null ? null : (format ?? UiDateFormat.date)(value!),
      onChanged: onChanged,
      label: label,
      hint: hint,
      helper: helper,
      error: error,
      validator: validator,
      clearable: clearable,
      size: size,
      isRequired: isRequired,
      prefixIcon: prefixIcon,
      pick: (ctx) {
        var initial = value ?? DateTime.now();
        if (initial.isBefore(first)) initial = first;
        if (initial.isAfter(last)) initial = last;
        return showDatePicker(context: ctx, initialDate: initial, firstDate: first, lastDate: last);
      },
    );
  }
}

/// Read-only field that opens the time picker.
///
/// ```dart
/// UiTimeField(label: 'Reminder', value: time, onChanged: (t) => setState(() => time = t))
/// ```
class UiTimeField extends StatelessWidget {
  const UiTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Select time',
    this.helper,
    this.error,
    this.validator,
    this.format,
    this.clearable = true,
    this.size = UiSize.md,
    this.isRequired = false,
    this.prefixIcon = Icons.schedule_rounded,
  });

  final TimeOfDay? value;

  /// Called with the picked time, or null when cleared. Null disables the field.
  final ValueChanged<TimeOfDay?>? onChanged;
  final String? label;
  final String hint;
  final String? helper;
  final String? error;
  final FormFieldValidator<TimeOfDay>? validator;

  /// Custom display text. Defaults to [UiDateFormat.time].
  final String Function(TimeOfDay)? format;
  final bool clearable;
  final UiSize size;
  final bool isRequired;
  final IconData prefixIcon;

  @override
  Widget build(BuildContext context) {
    return _PickerField<TimeOfDay>(
      value: value,
      text: value == null ? null : (format?.call(value!) ?? UiDateFormat.time(context, value!)),
      onChanged: onChanged,
      label: label,
      hint: hint,
      helper: helper,
      error: error,
      validator: validator,
      clearable: clearable,
      size: size,
      isRequired: isRequired,
      prefixIcon: prefixIcon,
      pick: (ctx) => showTimePicker(context: ctx, initialTime: value ?? TimeOfDay.now()),
    );
  }
}

/// Read-only field that opens the date range picker.
///
/// ```dart
/// UiDateRangeField(label: 'Trip', value: range, onChanged: (r) => setState(() => range = r))
/// ```
class UiDateRangeField extends StatelessWidget {
  const UiDateRangeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Select dates',
    this.helper,
    this.error,
    this.validator,
    this.firstDate,
    this.lastDate,
    this.format,
    this.clearable = true,
    this.size = UiSize.md,
    this.isRequired = false,
    this.prefixIcon = Icons.date_range_rounded,
  });

  final DateTimeRange? value;

  /// Called with the picked range, or null when cleared. Null disables the field.
  final ValueChanged<DateTimeRange?>? onChanged;
  final String? label;
  final String hint;
  final String? helper;
  final String? error;
  final FormFieldValidator<DateTimeRange>? validator;
  final DateTime? firstDate;
  final DateTime? lastDate;

  /// Custom display text. Defaults to [UiDateFormat.range].
  final String Function(DateTimeRange)? format;
  final bool clearable;
  final UiSize size;
  final bool isRequired;
  final IconData prefixIcon;

  @override
  Widget build(BuildContext context) {
    return _PickerField<DateTimeRange>(
      value: value,
      text: value == null ? null : (format ?? UiDateFormat.range)(value!),
      onChanged: onChanged,
      label: label,
      hint: hint,
      helper: helper,
      error: error,
      validator: validator,
      clearable: clearable,
      size: size,
      isRequired: isRequired,
      prefixIcon: prefixIcon,
      pick: (ctx) => showDateRangePicker(
        context: ctx,
        firstDate: firstDate ?? DateTime(1900),
        lastDate: lastDate ?? DateTime(2100, 12, 31),
        initialDateRange: value,
      ),
    );
  }
}

class _PickerField<V> extends StatelessWidget {
  const _PickerField({
    required this.value,
    required this.text,
    required this.onChanged,
    required this.pick,
    required this.label,
    required this.hint,
    required this.helper,
    required this.error,
    required this.validator,
    required this.clearable,
    required this.size,
    required this.isRequired,
    required this.prefixIcon,
  });

  final V? value;
  final String? text;
  final ValueChanged<V?>? onChanged;
  final Future<V?> Function(BuildContext context) pick;
  final String? label;
  final String hint;
  final String? helper;
  final String? error;
  final FormFieldValidator<V>? validator;
  final bool clearable;
  final UiSize size;
  final bool isRequired;
  final IconData prefixIcon;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return FormField<V>(
      initialValue: value,
      enabled: enabled,
      validator: validator == null ? null : (_) => validator!(value),
      builder: (field) {
        final err = error ?? field.errorText;
        void set(V? v) {
          field.didChange(v);
          onChanged?.call(v);
        }

        return UiFieldLabel(
          label: label,
          helper: helper,
          error: err,
          isRequired: isRequired,
          enabled: enabled,
          child: FieldBox(
            size: size,
            hasError: err != null,
            prefixIcon: prefixIcon,
            semanticLabel: label,
            onTap: !enabled
                ? null
                : () async {
                    final v = await pick(context);
                    if (v != null) set(v);
                  },
            trailing: [
              if (clearable && enabled && value != null)
                FieldIconButton(
                  icon: Icons.close_rounded,
                  tooltip: 'Clear',
                  size: size.iconSize,
                  onPressed: () => set(null),
                )
              else
                const SizedBox(width: UiSpace.sm),
            ],
            child: FieldValueText(value: text, hint: hint, enabled: enabled),
          ),
        );
      },
    );
  }
}
