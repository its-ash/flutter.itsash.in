part of 'ui_button.dart';

/// Copies [text] to the clipboard. The icon morphs to a check for 1.5 s.
///
/// ```dart
/// UiCopyButton(apiKey)
/// UiCopyButton(link, label: 'Copy link', variant: UiButtonVariant.outline)
/// ```
class UiCopyButton extends StatefulWidget {
  const UiCopyButton(
    this.text, {
    super.key,
    this.label,
    this.onCopied,
    this.tooltip = 'Copy',
    this.copiedLabel = 'Copied',
    this.variant = UiButtonVariant.ghost,
    this.size = UiSize.md,
  });

  /// Text put on the clipboard.
  final String text;

  /// Button label. Null makes an icon-only button.
  final String? label;

  /// Called after the text is copied.
  final VoidCallback? onCopied;

  /// Tooltip of the icon-only button.
  final String tooltip;

  /// Label / tooltip shown while the check is visible.
  final String copiedLabel;

  final UiButtonVariant variant;
  final UiSize size;

  /// How long the check stays.
  static const Duration feedbackDuration = Duration(milliseconds: 1500);

  @override
  State<UiCopyButton> createState() => _UiCopyButtonState();
}

class _UiCopyButtonState extends State<UiCopyButton> {
  bool _copied = false;
  Timer? _timer;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    _timer?.cancel();
    _timer = Timer(UiCopyButton.feedbackDuration, () {
      if (mounted) setState(() => _copied = false);
    });
    widget.onCopied?.call();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final icon = AnimatedSwitcher(
      duration: context.motion(UiMotion.normal),
      switchInCurve: UiMotion.bounce,
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: ScaleTransition(scale: a, child: child),
      ),
      child: _copied
          ? Icon(Icons.check_rounded, key: const ValueKey(true), color: c.success)
          : const Icon(Icons.content_copy_rounded, key: ValueKey(false)),
    );
    final label = widget.label;
    return _ButtonCore(
      onPressed: _copy,
      palette: (c, s) => _variantPalette(c, widget.variant, null, s),
      size: widget.size,
      square: label == null,
      tooltip: label == null ? (_copied ? widget.copiedLabel : widget.tooltip) : null,
      leading: icon,
      label: label == null ? null : Text(_copied ? widget.copiedLabel : label),
    );
  }
}
