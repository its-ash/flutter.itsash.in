import 'package:flutter/material.dart';

import 'package:theme/src/input/ui_field_label.dart';
import 'package:theme/src/foundation/ui_format.dart';

class _PickerField extends StatefulWidget {
  const _PickerField({
    required this.text,
    required this.onTap,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    required this.isRequired,
    required this.helper,
    required this.onClear,
  });

  final String text;
  final Future<void> Function()? onTap;
  final String? label;
  final String hint;
  final IconData icon;
  final String? Function()? validator;
  final bool isRequired;
  final String? helper;
  final VoidCallback? onClear;

  @override
  State<_PickerField> createState() => _PickerFieldState();
}

class _PickerFieldState extends State<_PickerField> {
  late final _ctrl = TextEditingController(text: widget.text);
  var _busy = false;

  @override
  void didUpdateWidget(_PickerField old) {
    super.didUpdateWidget(old);
    if (widget.text != _ctrl.text) _ctrl.text = widget.text;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _open() async {
    final fn = widget.onTap;
    if (fn == null || _busy) return;
    _busy = true;
    try {
      await fn();
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final l = widget.label?.trim() ?? '';
    return UiFieldLabel(
      widget.label,
      isRequired: widget.isRequired,
      child: TextFormField(
        controller: _ctrl,
        readOnly: true,
        enabled: enabled,
        onTap: _open,
        enableInteractiveSelection: false,
        validator: (_) => widget.isRequired && widget.text.isEmpty
            ? '${l.isEmpty ? 'This field' : l} is required'
            : widget.validator?.call(),
        decoration: InputDecoration(
          hintText: widget.hint,
          helperText: widget.helper,
          prefixIcon: Icon(widget.icon, size: 20),
          suffixIcon: widget.onClear != null && widget.text.isNotEmpty && enabled
              ? IconButton(tooltip: 'Clear', onPressed: widget.onClear, icon: const Icon(Icons.close_rounded, size: 20))
              : const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ),
    );
  }
}

DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

(DateTime, DateTime) _range(DateTime? first, DateTime? last) {
  final f = _day(first ?? DateTime(1900));
  final l = _day(last ?? DateTime(2100, 12, 31));
  return l.isBefore(f) ? (f, f) : (f, l);
}

DateTime _clampDay(DateTime d, DateTime f, DateTime l) => d.isBefore(f) ? f : (d.isAfter(l) ? l : d);

class UiDateField extends StatelessWidget {
  const UiDateField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Select date',
    this.firstDate,
    this.lastDate,
    this.format,
    this.validator,
    this.isRequired = false,
    this.clearable = false,
    this.helper,
    this.icon = Icons.calendar_today_rounded,
  });

  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final String? label;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String Function(DateTime)? format;
  final String? Function(DateTime?)? validator;
  final bool isRequired;
  final bool clearable;
  final String? helper;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cb = onChanged;
    final (f, l) = _range(firstDate, lastDate);
    return _PickerField(
      text: value == null ? '' : (format ?? UiFormat.date)(value!),
      label: label,
      hint: hint,
      icon: icon,
      helper: helper,
      isRequired: isRequired,
      validator: validator == null ? null : () => validator!(value),
      onClear: clearable && cb != null ? () => cb(null) : null,
      onTap: cb == null
          ? null
          : () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _clampDay(_day(value ?? DateTime.now()), f, l),
                firstDate: f,
                lastDate: l,
              );
              if (!context.mounted || picked == null) return;
              cb(picked);
            },
    );
  }
}

class UiTimeField extends StatelessWidget {
  const UiTimeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Select time',
    this.format,
    this.validator,
    this.isRequired = false,
    this.clearable = false,
    this.helper,
    this.icon = Icons.schedule_rounded,
  });

  final TimeOfDay? value;
  final ValueChanged<TimeOfDay?>? onChanged;
  final String? label;
  final String hint;
  final String Function(TimeOfDay)? format;
  final String? Function(TimeOfDay?)? validator;
  final bool isRequired;
  final bool clearable;
  final String? helper;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cb = onChanged;
    final h24 = MediaQuery.alwaysUse24HourFormatOf(context);
    return _PickerField(
      text: value == null ? '' : (format?.call(value!) ?? UiFormat.time(value!, h24: h24)),
      label: label,
      hint: hint,
      icon: icon,
      helper: helper,
      isRequired: isRequired,
      validator: validator == null ? null : () => validator!(value),
      onClear: clearable && cb != null ? () => cb(null) : null,
      onTap: cb == null
          ? null
          : () async {
              final picked = await showTimePicker(context: context, initialTime: value ?? TimeOfDay.now());
              if (!context.mounted || picked == null) return;
              cb(picked);
            },
    );
  }
}

class UiDateRangeField extends StatelessWidget {
  const UiDateRangeField({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.hint = 'Select dates',
    this.firstDate,
    this.lastDate,
    this.format,
    this.validator,
    this.isRequired = false,
    this.clearable = false,
    this.helper,
    this.icon = Icons.date_range_rounded,
  });

  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?>? onChanged;
  final String? label;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String Function(DateTimeRange)? format;
  final String? Function(DateTimeRange?)? validator;
  final bool isRequired;
  final bool clearable;
  final String? helper;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final cb = onChanged;
    final (f, l) = _range(firstDate, lastDate);
    final v = value;
    final init = v == null
        ? null
        : () {
            final s = _clampDay(_day(v.start), f, l);
            final e = _clampDay(_day(v.end), f, l);
            return DateTimeRange(start: s, end: e.isBefore(s) ? s : e);
          }();
    return _PickerField(
      text: v == null ? '' : (format ?? UiFormat.range)(v),
      label: label,
      hint: hint,
      icon: icon,
      helper: helper,
      isRequired: isRequired,
      validator: validator == null ? null : () => validator!(v),
      onClear: clearable && cb != null ? () => cb(null) : null,
      onTap: cb == null
          ? null
          : () async {
              final picked = await showDateRangePicker(
                context: context,
                initialDateRange: init,
                firstDate: f,
                lastDate: l,
              );
              if (!context.mounted || picked == null) return;
              cb(picked);
            },
    );
  }
}
