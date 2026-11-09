part of 'ui_button.dart';

/// A button that stays on or off. Selected uses a soft accent tint.
///
/// ```dart
/// UiToggleButton('Bold', selected: bold, onChanged: (v) => setState(() => bold = v))
/// UiToggleButton.icon(Icons.format_bold_rounded, tooltip: 'Bold', selected: bold, onChanged: setBold)
/// ```
class UiToggleButton extends StatelessWidget {
  const UiToggleButton(
    String this.label, {
    super.key,
    required this.selected,
    this.onChanged,
    this.icon,
    this.size = UiSize.md,
    this.expand = false,
  }) : tooltip = null;

  /// Icon-only toggle. [tooltip] is also the screen-reader label.
  const UiToggleButton.icon(
    IconData this.icon, {
    super.key,
    required String this.tooltip,
    required this.selected,
    this.onChanged,
    this.size = UiSize.md,
  }) : label = null,
       expand = false;

  final String? label;
  final IconData? icon;
  final String? tooltip;

  /// Whether the button is on.
  final bool selected;

  /// Called with the new value. Null disables the button.
  final ValueChanged<bool>? onChanged;

  final UiSize size;

  /// Fills the available width.
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return _ButtonCore(
      onPressed: onChanged == null ? null : () => onChanged(!selected),
      palette: (c, s) => _togglePalette(c, selected, s),
      size: size,
      expand: expand,
      square: label == null,
      toggled: selected,
      tooltip: tooltip,
      leading: icon == null ? null : Icon(icon),
      label: label == null ? null : Text(label!),
    );
  }
}

/// A row of toggle buttons with single or multi selection. Wraps to new
/// lines when narrow.
///
/// ```dart
/// UiToggleGroup([UiSegment('s', label: 'S'), UiSegment('m', label: 'M')],
///     selected: {size}, onChanged: (s) => setState(() => size = s.first))
/// ```
class UiToggleGroup<T> extends StatelessWidget {
  const UiToggleGroup(
    this.items, {
    super.key,
    required this.selected,
    this.onChanged,
    this.multiple = false,
    this.allowEmpty,
    this.size = UiSize.md,
    this.expand = false,
  });

  final List<UiSegment<T>> items;

  /// Selected values.
  final Set<T> selected;

  /// Called with the new selection. Null disables the group.
  final ValueChanged<Set<T>>? onChanged;

  /// Lets more than one item be selected.
  final bool multiple;

  /// Lets the user clear the last selected item. Defaults to [multiple].
  final bool? allowEmpty;

  final UiSize size;

  /// Makes the items share the full width in one row instead of wrapping.
  final bool expand;

  void _tap(T value) {
    final canEmpty = allowEmpty ?? multiple;
    final next = {...selected};
    if (next.contains(value)) {
      if (!canEmpty && next.length == 1) return;
      next.remove(value);
    } else {
      if (!multiple) next.clear();
      next.add(value);
    }
    onChanged!(next);
  }

  Widget _item(UiSegment<T> item) {
    final isSelected = selected.contains(item.value);
    return _ButtonCore(
      onPressed: onChanged == null ? null : () => _tap(item.value),
      palette: (c, s) => _togglePalette(c, isSelected, s),
      size: size,
      expand: expand,
      square: item.label == null,
      selected: isSelected,
      tooltip: item.label == null ? item.tooltip : null,
      leading: item.icon == null ? null : Icon(item.icon),
      label: item.label == null ? null : Text(item.label!),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (expand) {
      return Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(width: UiSpace.sm),
            Expanded(child: _item(items[i])),
          ],
        ],
      );
    }
    return Wrap(spacing: UiSpace.sm, runSpacing: UiSpace.sm, children: [for (final item in items) _item(item)]);
  }
}
