import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/foundation.dart';

// Internal helpers shared by the display group. Not exported from the barrel.

/// Tells a row inside `UiListGroup` whether to draw its own bottom divider
/// (indented to start under the text, iOS style).
class DisplayDividerScope extends InheritedWidget {
  const DisplayDividerScope({super.key, required this.divider, required super.child});

  final bool divider;

  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<DisplayDividerScope>()?.divider ?? false;

  @override
  bool updateShouldNotify(DisplayDividerScope oldWidget) => divider != oldWidget.divider;
}

/// Soft background for an arbitrary [color] on the current surface.
Color displaySoft(UiColors colors, Color color) =>
    Color.alphaBlend(color.withValues(alpha: colors.isDark ? 0.18 : 0.12), colors.surface);

/// Readable foreground for an arbitrary [color] on its soft background.
Color displayOnSoft(UiColors colors, Color color) => Color.lerp(color, colors.text, colors.isDark ? 0.1 : 0.3)!;

/// Small icon button that copies [text] and shows a check for a moment.
class DisplayCopyButton extends StatefulWidget {
  const DisplayCopyButton(this.text, {super.key, this.size = 16, this.tooltip = 'Copy'});

  final String text;
  final double size;
  final String tooltip;

  @override
  State<DisplayCopyButton> createState() => _DisplayCopyButtonState();
}

class _DisplayCopyButtonState extends State<DisplayCopyButton> {
  Timer? _timer;
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Tooltip(
      message: _copied ? 'Copied' : widget.tooltip,
      child: Semantics(
        button: true,
        label: _copied ? 'Copied' : widget.tooltip,
        child: InkResponse(
          onTap: _copy,
          radius: 20,
          child: SizedBox.square(
            dimension: 40,
            child: Center(
              child: AnimatedSwitcher(
                duration: context.motion(UiMotion.fast),
                transitionBuilder: (child, a) => ScaleTransition(scale: a, child: child),
                child: Icon(
                  _copied ? Icons.check_rounded : Icons.content_copy_rounded,
                  key: ValueKey(_copied),
                  size: widget.size,
                  color: _copied ? colors.success : colors.textSubtle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
