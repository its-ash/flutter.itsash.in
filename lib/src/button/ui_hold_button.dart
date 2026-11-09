part of 'ui_button.dart';

/// Press and hold to confirm. A fill sweeps across the button over
/// [duration]; releasing early cancels. For destructive or important actions.
///
/// ```dart
/// UiHoldButton('Hold to delete', icon: Icons.delete_rounded, onConfirmed: delete)
/// ```
class UiHoldButton extends StatefulWidget {
  const UiHoldButton(
    this.label, {
    super.key,
    this.onConfirmed,
    this.duration = const Duration(milliseconds: 1500),
    this.icon,
    this.variant = UiButtonVariant.danger,
    this.size = UiSize.md,
    this.expand = false,
  });

  final String label;

  /// Called once the hold completes. Null disables the button.
  final VoidCallback? onConfirmed;

  /// How long the user must hold.
  final Duration duration;

  final IconData? icon;
  final UiButtonVariant variant;
  final UiSize size;

  /// Fills the available width.
  final bool expand;

  @override
  State<UiHoldButton> createState() => _UiHoldButtonState();
}

class _UiHoldButtonState extends State<UiHoldButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.duration)
    ..addStatusListener(_onStatus);
  bool _done = false;

  @override
  void didUpdateWidget(covariant UiHoldButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.duration = widget.duration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _done) return;
    setState(() => _done = true);
    HapticFeedback.mediumImpact();
    widget.onConfirmed?.call();
  }

  void _onHighlight(bool down) {
    if (down) {
      if (_done) return;
      HapticFeedback.selectionClick();
      _controller.forward();
    } else {
      if (_done) setState(() => _done = false);
      _controller.animateBack(0, duration: context.motion(UiMotion.normal), curve: UiMotion.standard);
    }
  }

  static void _noop() {}

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onConfirmed != null;
    final fill = _variantPalette(context.colors, widget.variant, null, const {}).fg.withValues(alpha: 0.22);
    final icon = _done ? Icons.check_rounded : widget.icon;
    return Semantics(
      hint: 'Press and hold to confirm',
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => _ButtonCore(
          onPressed: enabled ? _noop : null,
          onHighlightChanged: _onHighlight,
          palette: (c, s) => _variantPalette(c, widget.variant, null, s),
          size: widget.size,
          expand: widget.expand,
          pressScale: 0.98,
          leading: icon == null ? null : Icon(icon),
          label: Text(widget.label),
          underlay: Align(
            alignment: AlignmentDirectional.centerStart,
            child: FractionallySizedBox(
              widthFactor: _controller.value,
              heightFactor: 1,
              child: ColoredBox(color: fill),
            ),
          ),
        ),
      ),
    );
  }
}
