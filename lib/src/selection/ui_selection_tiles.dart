part of 'ui_selection.dart';

/// Settings row with a switch on the end side. The whole row toggles.
///
/// ```dart
/// UiSwitchTile('Notifications', value: on, icon: Icons.notifications_rounded, onChanged: (v) => setState(() => on = v))
/// ```
class UiSwitchTile extends StatelessWidget {
  const UiSwitchTile(
    this.title, {
    super.key,
    required this.value,
    this.onChanged,
    this.subtitle,
    this.icon,
    this.status = UiStatus.accent,
  });

  final String title;
  final bool value;

  /// Called with the new value. Null disables the row.
  final ValueChanged<bool>? onChanged;
  final String? subtitle;

  /// Leading icon, shown in a tinted square.
  final IconData? icon;

  /// Tint of the icon square.
  final UiStatus status;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return MergeSemantics(
      child: Semantics(
        toggled: value,
        enabled: enabled,
        child: _SelectionTile(
          title: title,
          subtitle: subtitle,
          icon: icon,
          status: status,
          onTap: enabled ? () => onChanged!(!value) : null,
          trailing: (state) => _SwitchTrack(value: value, state: state),
        ),
      ),
    );
  }
}

/// Settings row with a checkbox on the end side. The whole row toggles.
///
/// ```dart
/// UiCheckboxTile('Remember me', value: remember, onChanged: (v) => setState(() => remember = v!))
/// ```
class UiCheckboxTile extends StatelessWidget {
  const UiCheckboxTile(
    this.title, {
    super.key,
    required this.value,
    this.onChanged,
    this.subtitle,
    this.icon,
    this.status = UiStatus.accent,
    this.tristate = false,
  });

  final String title;
  final bool? value;

  /// Called with the next value. Null disables the row.
  final ValueChanged<bool?>? onChanged;
  final String? subtitle;
  final IconData? icon;
  final UiStatus status;

  /// When true, taps cycle false → true → null → false.
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    return MergeSemantics(
      child: Semantics(
        checked: value == true,
        mixed: tristate && value == null,
        enabled: enabled,
        child: _SelectionTile(
          title: title,
          subtitle: subtitle,
          icon: icon,
          status: status,
          onTap: enabled ? () => onChanged!(UiCheckbox.next(value, tristate: tristate)) : null,
          trailing: (state) => _CheckboxMark(value: value, state: state),
        ),
      ),
    );
  }
}

/// Settings row with a radio on the end side. Tapping selects [value].
///
/// ```dart
/// UiRadioTile('Dark', value: ThemeMode.dark, groupValue: mode, onChanged: (v) => setState(() => mode = v))
/// ```
class UiRadioTile<T> extends StatelessWidget {
  const UiRadioTile(
    this.title, {
    super.key,
    required this.value,
    required this.groupValue,
    this.onChanged,
    this.subtitle,
    this.icon,
    this.status = UiStatus.accent,
  });

  final String title;
  final T value;
  final T? groupValue;

  /// Called with [value] when tapped. Null disables the row.
  final ValueChanged<T>? onChanged;
  final String? subtitle;
  final IconData? icon;
  final UiStatus status;

  @override
  Widget build(BuildContext context) {
    final enabled = onChanged != null;
    final selected = value == groupValue;
    return MergeSemantics(
      child: Semantics(
        checked: selected,
        inMutuallyExclusiveGroup: true,
        enabled: enabled,
        child: _SelectionTile(
          title: title,
          subtitle: subtitle,
          icon: icon,
          status: status,
          onTap: enabled ? () => onChanged!(value) : null,
          trailing: (state) => _RadioMark(selected: selected, state: state),
        ),
      ),
    );
  }
}

class _SelectionTile extends StatelessWidget {
  const _SelectionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.status,
    required this.onTap,
    required this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final UiStatus status;
  final VoidCallback? onTap;
  final Widget Function(_Interaction state) trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onTap != null;
    final tone = c.tone(status);
    return _Pressable(
      onTap: onTap,
      builder: (context, state) => AnimatedContainer(
        duration: context.motion(UiMotion.fast),
        curve: UiMotion.standard,
        constraints: const BoxConstraints(minHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.lg, vertical: UiSpace.md),
        decoration: BoxDecoration(
          color: state.pressed
              ? c.surfaceMuted
              : state.hovered
              ? c.surfaceMuted.withValues(alpha: 0.6)
              : c.surfaceMuted.withValues(alpha: 0),
        ),
        foregroundDecoration: state.focused
            ? BoxDecoration(
                border: Border.all(color: c.accent, width: 2),
                borderRadius: UiRadius.all(UiRadius.sm),
              )
            : null,
        child: Row(
          children: [
            if (icon != null) ...[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: enabled ? tone.soft : c.surfaceMuted,
                  borderRadius: UiRadius.all(UiRadius.sm),
                ),
                child: Icon(icon, size: 20, color: enabled ? tone.onSoft : c.textDisabled),
              ),
              const SizedBox(width: UiSpace.md),
            ],
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: enabled ? c.text : c.textDisabled,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.bodySmall?.copyWith(color: enabled ? c.textMuted : c.textDisabled),
                    ),
                ],
              ),
            ),
            const SizedBox(width: UiSpace.md),
            Opacity(opacity: enabled ? 1 : _kDisabledOpacity, child: trailing(state)),
          ],
        ),
      ),
    );
  }
}
