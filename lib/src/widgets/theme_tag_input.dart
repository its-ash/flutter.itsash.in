import 'package:flutter/material.dart';

import 'package:theme/src/components/theme_chip.dart';

class ThemeTagInput extends StatefulWidget {
  const ThemeTagInput({
    super.key,
    this.initialTags = const [],
    this.onChanged,
    this.maxTags,
    this.hintText,
  });

  final List<String> initialTags;
  final ValueChanged<List<String>>? onChanged;
  final int? maxTags;
  final String? hintText;

  @override
  State<ThemeTagInput> createState() => _ThemeTagInputState();
}

class _ThemeTagInputState extends State<ThemeTagInput> {
  late final List<String> _tags = List.of(widget.initialTags);
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool get _atLimit => widget.maxTags != null && _tags.length >= widget.maxTags!;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _commit(String raw) {
    final tag = raw.trim();
    if (tag.isEmpty || _tags.contains(tag) || _atLimit) {
      _controller.clear();
      return;
    }
    setState(() {
      _tags.add(tag);
      _controller.clear();
    });
    widget.onChanged?.call(List.unmodifiable(_tags));
  }

  void _remove(String tag) {
    setState(() => _tags.remove(tag));
    widget.onChanged?.call(List.unmodifiable(_tags));
  }

  void _onChanged(String value) {
    if (!value.contains(',')) return;
    final parts = value.split(',');
    for (var i = 0; i < parts.length - 1; i++) {
      _commit(parts[i]);
    }
    _controller.text = parts.last;
    _controller.selection = TextSelection.collapsed(offset: _controller.text.length);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final tag in _tags) ThemeChip(label: tag, onDeleted: () => _remove(tag)),
        SizedBox(
          width: 140,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: !_atLimit,
            onChanged: _onChanged,
            onSubmitted: _commit,
            style: TextStyle(color: _atLimit ? scheme.onSurface.withValues(alpha: 0.4) : scheme.onSurface),
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              hintText: _atLimit ? 'Limit reached' : widget.hintText,
            ),
          ),
        ),
      ],
    );
  }
}
