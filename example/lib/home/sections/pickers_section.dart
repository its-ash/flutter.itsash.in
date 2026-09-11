import 'package:flutter/material.dart';

import 'package:theme/theme.dart';
import '../showcase_tile.dart';

class PickersSection extends StatefulWidget {
  const PickersSection({super.key});

  @override
  State<PickersSection> createState() => _PickersSectionState();
}

class _PickersSectionState extends State<PickersSection> {
  DateTime? _date;
  TimeOfDay? _time;

  @override
  Widget build(BuildContext context) {
    return ShowcasePage(
      children: [
        ShowcaseTile(
          title: 'ThemeDatePicker',
          child: ThemeButton(
            label: _date == null ? 'Pick a date' : _date!.toLocal().toString().split(' ').first,
            onPressed: () async {
              final picked = await ThemeDatePicker.show(
                context,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
                initialDate: DateTime.now(),
              );
              if (picked != null) setState(() => _date = picked);
            },
          ),
        ),
        ShowcaseTile(
          title: 'ThemeTimePicker',
          child: ThemeButton(
            label: _time == null ? 'Pick a time' : _time!.format(context),
            onPressed: () async {
              final picked = await ThemeTimePicker.show(context, initialTime: TimeOfDay.now());
              if (picked != null) setState(() => _time = picked);
            },
          ),
        ),
        ShowcaseTile(
          title: 'ThemePopupMenu<T>',
          child: ThemePopupMenu<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (_) {},
            items: const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'share', child: Text('Share')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ),
        ShowcaseTile(
          title: 'ThemeContextMenu<T>',
          description: 'Right-click, or long-press on touch devices',
          child: ThemeContextMenu<String>(
            onSelected: (_) {},
            items: const [
              PopupMenuItem(value: 'copy', child: Text('Copy')),
              PopupMenuItem(value: 'rename', child: Text('Rename')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
            child: ThemeCard(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Right-click or long-press me'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
