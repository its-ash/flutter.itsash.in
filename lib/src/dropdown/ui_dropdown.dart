import 'package:flutter/material.dart';

import 'package:theme/src/input/ui_field_label.dart';
import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiDropdown<T> extends StatelessWidget {
  const UiDropdown({
    super.key,
    required this.items,
    this.value,
    this.onChanged,
    this.label,
    this.hint = 'Select',
    this.itemLabel,
    this.itemIcon,
    this.prefixIcon,
    this.validator,
    this.isRequired = false,
    this.helper,
  });

  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String? label;
  final String hint;
  final String Function(T)? itemLabel;
  final IconData? Function(T)? itemIcon;
  final IconData? prefixIcon;
  final FormFieldValidator<T>? validator;
  final bool isRequired;
  final String? helper;

  String _label(T v) => itemLabel?.call(v) ?? v.toString();

  @override
  Widget build(BuildContext context) {
    final opts = {...items}.toList();
    final sel = value != null && opts.contains(value) ? value : null;
    final enabled = onChanged != null && opts.isNotEmpty;
    return UiFieldLabel(
      label,
      isRequired: isRequired,
      child: DropdownButtonFormField<T>(
        initialValue: sel,
        isExpanded: true,
        borderRadius: context.tokens.md,
        dropdownColor: context.colors.surfaceContainer,
        icon: const Icon(Icons.keyboard_arrow_down_rounded),
        menuMaxHeight: 360,
        validator: (v) => isRequired && v == null ? '${label?.trim().isNotEmpty == true ? label!.trim() : 'A value'} is required' : validator?.call(v),
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: enabled ? onChanged : null,
        hint: Text(hint, maxLines: 1, overflow: TextOverflow.ellipsis),
        decoration: InputDecoration(
          helperText: helper,
          prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
          contentPadding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md + 2),
        ),
        items: [
          for (final o in opts)
            DropdownMenuItem<T>(
              value: o,
              child: Row(
                children: [
                  if (itemIcon?.call(o) case final ic?) ...[Icon(ic, size: 20), const SizedBox(width: UiSpace.md)],
                  Expanded(child: Text(_label(o), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
