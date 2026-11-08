import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';

class UiMessageComposer extends StatefulWidget {
  const UiMessageComposer({
    super.key,
    required this.onSend,
    this.controller,
    this.focusNode,
    this.hint = 'Message',
    this.onAttach,
    this.onEmoji,
    this.onCamera,
    this.onMic,
    this.maxLines = 5,
    this.maxLength = 4000,
    this.enabled = true,
    this.autofocus = false,
  });

  final ValueChanged<String> onSend;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hint;
  final VoidCallback? onAttach;
  final VoidCallback? onEmoji;
  final VoidCallback? onCamera;
  final VoidCallback? onMic;
  final int maxLines;
  final int maxLength;
  final bool enabled;
  final bool autofocus;

  @override
  State<UiMessageComposer> createState() => _UiMessageComposerState();
}

class _UiMessageComposerState extends State<UiMessageComposer> {
  TextEditingController? _own;
  FocusNode? _ownFocus;

  TextEditingController get _ctrl => widget.controller ?? (_own ??= TextEditingController());
  FocusNode get _focus => widget.focusNode ?? (_ownFocus ??= FocusNode());

  bool get _canSend => widget.enabled && _ctrl.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _ctrl.addListener(_onText);
  }

  @override
  void didUpdateWidget(UiMessageComposer old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      (old.controller ?? _own)?.removeListener(_onText);
      _ctrl.addListener(_onText);
    }
  }

  @override
  void dispose() {
    _ctrl.removeListener(_onText);
    _own?.dispose();
    _ownFocus?.dispose();
    super.dispose();
  }

  void _onText() => setState(() {});

  void _send() {
    final t = _ctrl.text.trim();
    if (!widget.enabled || t.isEmpty) return;
    widget.onSend(t);
    _ctrl.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final showMic = widget.onMic != null && !_canSend;
    final lines = widget.maxLines.clamp(1, 12);
    return Material(
      color: cs.surface,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(UiSpace.sm, UiSpace.sm, UiSpace.sm, UiSpace.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (widget.onAttach != null)
              _ComposerIcon(Icons.add_circle_outline_rounded, 'Attach', widget.enabled ? widget.onAttach : null),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(minHeight: 48),
                decoration: BoxDecoration(color: cs.surfaceContainerHigh, borderRadius: context.tokens.xl),
                padding: EdgeInsetsDirectional.only(start: widget.onEmoji == null ? UiSpace.lg : UiSpace.xs, end: UiSpace.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.onEmoji != null)
                      _ComposerIcon(Icons.emoji_emotions_outlined, 'Emoji', widget.enabled ? widget.onEmoji : null),
                    Expanded(
                      child: CallbackShortcuts(
                        bindings: {const SingleActivator(LogicalKeyboardKey.enter, control: true): _send},
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focus,
                          enabled: widget.enabled,
                          autofocus: widget.autofocus,
                          minLines: 1,
                          maxLines: lines,
                          keyboardType: TextInputType.multiline,
                          textCapitalization: TextCapitalization.sentences,
                          inputFormatters: [LengthLimitingTextInputFormatter(widget.maxLength)],
                          style: context.text.bodyLarge,
                          decoration: InputDecoration(
                            hintText: widget.hint,
                            filled: false,
                            isDense: true,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: UiSpace.md + 2),
                          ),
                        ),
                      ),
                    ),
                    if (widget.onCamera != null && !_canSend)
                      _ComposerIcon(Icons.photo_camera_outlined, 'Camera', widget.enabled ? widget.onCamera : null),
                  ],
                ),
              ),
            ),
            const SizedBox(width: UiSpace.sm),
            AnimatedSwitcher(
              duration: UiDuration.fast,
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: showMic
                  ? _SendButton(key: const ValueKey('mic'), icon: Icons.mic_rounded, label: 'Record voice', onTap: widget.enabled ? widget.onMic : null)
                  : _SendButton(key: const ValueKey('send'), icon: Icons.send_rounded, label: 'Send', onTap: _canSend ? _send : null),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComposerIcon extends StatelessWidget {
  const _ComposerIcon(this.icon, this.tooltip, this.onTap);

  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(icon),
        color: context.colors.onSurfaceVariant,
        constraints: const BoxConstraints.tightFor(width: 44, height: 48),
        padding: EdgeInsets.zero,
      );
}

class _SendButton extends StatelessWidget {
  const _SendButton({super.key, required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final on = onTap != null;
    return IconButton(
      onPressed: onTap,
      tooltip: label,
      icon: Icon(icon, size: 22),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(48),
        backgroundColor: on ? cs.primary : cs.surfaceContainerHigh,
        foregroundColor: on ? cs.onPrimary : cs.onSurfaceVariant,
        disabledBackgroundColor: cs.surfaceContainerHigh,
        disabledForegroundColor: cs.onSurface.withValues(alpha: 0.38),
        shape: const CircleBorder(),
      ),
    );
  }
}

class UiReactionPicker extends StatelessWidget {
  const UiReactionPicker({
    super.key,
    required this.onSelected,
    this.reactions = const ['👍', '❤️', '😂', '😮', '😢', '🙏'],
    this.selected,
    this.size = 28,
  });

  final ValueChanged<String> onSelected;
  final List<String> reactions;
  final String? selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    return Material(
      color: cs.surfaceContainerHigh,
      elevation: 6,
      shadowColor: cs.shadow.withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(borderRadius: context.tokens.full),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs, vertical: UiSpace.xs),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final r in reactions) _Reaction(r, size: size, selected: r == selected, onTap: () => onSelected(r)),
          ],
        ),
      ),
    );
  }
}

class _Reaction extends StatefulWidget {
  const _Reaction(this.emoji, {required this.size, required this.selected, required this.onTap});

  final String emoji;
  final double size;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<_Reaction> createState() => _ReactionState();
}

class _ReactionState extends State<_Reaction> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scale = _down ? 1.35 : (_hover ? 1.25 : 1.0);
    return Semantics(
      button: true,
      selected: widget.selected,
      label: 'React ${widget.emoji}',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _down = true),
          onTapCancel: () => setState(() => _down = false),
          onTapUp: (_) => setState(() => _down = false),
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          child: AnimatedContainer(
            duration: UiDuration.fast,
            padding: const EdgeInsets.all(UiSpace.xs + 2),
            decoration: BoxDecoration(
              color: widget.selected ? context.colors.primaryContainer : null,
              shape: BoxShape.circle,
            ),
            child: AnimatedScale(
              scale: scale,
              duration: UiDuration.fast,
              curve: Curves.easeOutBack,
              child: Text(widget.emoji, style: TextStyle(fontSize: widget.size, height: 1.1)),
            ),
          ),
        ),
      ),
    );
  }
}
