part of 'ui_selection.dart';

/// One option of a selection group: radio groups, checkbox groups, choice
/// cards and choice/filter chips.
///
/// ```dart
/// const UiChoice('pro', 'Pro', description: 'For teams', icon: Icons.bolt_rounded, trailing: r'$12/mo')
/// ```
@immutable
class UiChoice<T> {
  const UiChoice(this.value, this.label, {this.description, this.icon, this.trailing, this.enabled = true});

  /// Value reported to `onChanged` when this option is picked.
  final T value;

  /// Main text.
  final String label;

  /// Secondary text under the label.
  final String? description;

  /// Optional icon (shown by cards, chips and tiles).
  final IconData? icon;

  /// Short text on the end side, such as a price. Shown by choice cards.
  final String? trailing;

  /// False greys out the option and blocks taps.
  final bool enabled;
}
