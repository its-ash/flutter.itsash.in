part of 'ui_button.dart';

/// Resolved colors of a button for one set of states.
class _Palette {
  const _Palette(this.bg, this.fg, {this.border = Colors.transparent});

  final Color bg;
  final Color fg;
  final Color border;
}

typedef _PaletteResolver = _Palette Function(UiColors c, Set<WidgetState> states);

/// Adds the hover / press tint on top of [base].
_Palette _interactive(_Palette base, Set<WidgetState> states, {Color? hoverBorder}) {
  final overlay = states.contains(WidgetState.pressed)
      ? 0.12
      : states.contains(WidgetState.hovered)
      ? 0.07
      : 0.0;
  if (overlay == 0) return base;
  return _Palette(
    Color.alphaBlend(base.fg.withValues(alpha: overlay), base.bg),
    base.fg,
    border: hoverBorder ?? base.border,
  );
}

_Palette _variantPalette(UiColors c, UiButtonVariant v, UiStatus? status, Set<WidgetState> states) {
  const clear = Colors.transparent;
  if (states.contains(WidgetState.disabled)) {
    return switch (v) {
      UiButtonVariant.primary ||
      UiButtonVariant.secondary ||
      UiButtonVariant.soft ||
      UiButtonVariant.danger => _Palette(c.surfaceMuted, c.textDisabled),
      UiButtonVariant.outline => _Palette(clear, c.textDisabled, border: c.border),
      UiButtonVariant.ghost || UiButtonVariant.link => _Palette(clear, c.textDisabled),
    };
  }
  final tone = status == null ? null : c.tone(status);
  final base = switch (v) {
    UiButtonVariant.primary => _Palette(tone?.color ?? c.accent, tone?.onColor ?? c.onAccent),
    UiButtonVariant.secondary => _Palette(c.surfaceMuted, tone?.color ?? c.text),
    UiButtonVariant.soft => _Palette(tone?.soft ?? c.accentSoft, tone?.onSoft ?? c.onAccentSoft),
    UiButtonVariant.outline => _Palette(
      clear,
      tone?.color ?? c.text,
      border: tone?.color.withValues(alpha: 0.5) ?? c.border,
    ),
    UiButtonVariant.ghost => _Palette(clear, tone?.color ?? c.text),
    UiButtonVariant.danger => _Palette(c.danger, c.onDanger),
    UiButtonVariant.link => _Palette(clear, tone?.color ?? c.accent),
  };
  if (v == UiButtonVariant.link) return base;
  return _interactive(base, states, hoverBorder: v == UiButtonVariant.outline ? (tone?.color ?? c.borderStrong) : null);
}

/// Colors of a selectable (toggle) button.
_Palette _togglePalette(UiColors c, bool selected, Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return _Palette(selected ? c.surfaceMuted : Colors.transparent, c.textDisabled, border: c.border);
  }
  final base = selected
      ? _Palette(c.accentSoft, c.onAccentSoft, border: c.accent.withValues(alpha: 0.45))
      : _Palette(Colors.transparent, c.textMuted, border: c.border);
  return _interactive(base, states, hoverBorder: selected ? null : c.borderStrong);
}

/// Hover, focus, press and keyboard handling shared by every button.
class _Pressable extends StatefulWidget {
  const _Pressable({
    required this.onTap,
    required this.builder,
    this.busy = false,
    this.pressScale = 0.97,
    this.focusRadius = UiRadius.md,
    this.tooltip,
    this.selected,
    this.toggled,
    this.onHighlightChanged,
  });

  /// Null means disabled.
  final VoidCallback? onTap;

  /// Blocks taps without the disabled look (loading).
  final bool busy;
  final Widget Function(BuildContext context, Set<WidgetState> states) builder;
  final double pressScale;
  final double focusRadius;
  final String? tooltip;
  final bool? selected;
  final bool? toggled;

  /// Called when the pointer goes down (true) and up or away (false).
  final ValueChanged<bool>? onHighlightChanged;

  @override
  State<_Pressable> createState() => _PressableState();
}

class _PressableState extends State<_Pressable> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _active => widget.onTap != null && !widget.busy;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
    widget.onHighlightChanged?.call(value);
  }

  @override
  void didUpdateWidget(covariant _Pressable oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_active) _pressed = false;
  }

  Set<WidgetState> get _states => {
    if (widget.onTap == null) WidgetState.disabled,
    if (_hovered && _active) WidgetState.hovered,
    if (_pressed && _active) WidgetState.pressed,
    if (_focused && _active) WidgetState.focused,
    if (widget.selected ?? widget.toggled ?? false) WidgetState.selected,
  };

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final states = _states;
    final ring = widget.focusRadius + 3;
    Widget child = Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        widget.builder(context, states),
        Positioned(
          left: -3,
          top: -3,
          right: -3,
          bottom: -3,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: states.contains(WidgetState.focused) ? 1 : 0,
              duration: context.motion(UiMotion.fast),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: UiRadius.all(ring),
                  border: Border.all(color: c.accent.withValues(alpha: 0.6), width: 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
    child = AnimatedScale(
      scale: states.contains(WidgetState.pressed) ? widget.pressScale : 1,
      duration: context.motion(UiMotion.fast),
      curve: UiMotion.standard,
      child: child,
    );
    child = GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: true,
      onTapDown: _active ? (_) => _setPressed(true) : null,
      onTapUp: _active ? (_) => _setPressed(false) : null,
      onTapCancel: _active ? () => _setPressed(false) : null,
      onTap: _active ? widget.onTap : null,
      child: child,
    );
    child = FocusableActionDetector(
      enabled: _active,
      mouseCursor: _active
          ? SystemMouseCursors.click
          : widget.busy
          ? SystemMouseCursors.progress
          : SystemMouseCursors.basic,
      onShowHoverHighlight: (v) => setState(() => _hovered = v),
      onShowFocusHighlight: (v) => setState(() => _focused = v),
      actions: {
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (_) {
            if (_active) widget.onTap!();
            return null;
          },
        ),
      },
      child: child,
    );
    child = Semantics(
      container: true,
      button: true,
      enabled: widget.onTap != null,
      selected: widget.selected,
      toggled: widget.toggled,
      onTap: _active ? widget.onTap : null,
      child: child,
    );
    if (widget.tooltip != null) child = Tooltip(message: widget.tooltip, child: child);
    return child;
  }
}

/// Shared button body: colored box, icon + label row, spinner, badge.
class _ButtonCore extends StatelessWidget {
  const _ButtonCore({
    required this.onPressed,
    required this.palette,
    this.size = UiSize.md,
    this.leading,
    this.label,
    this.trailing,
    this.loading = false,
    this.expand = false,
    this.square = false,
    this.circular = false,
    this.flat = false,
    this.underlineOnHover = false,
    this.height,
    this.radius,
    this.shadow,
    this.tooltip,
    this.selected,
    this.toggled,
    this.badge,
    this.underlay,
    this.onHighlightChanged,
    this.pressScale = 0.97,
  });

  final VoidCallback? onPressed;
  final _PaletteResolver palette;
  final UiSize size;
  final Widget? leading;
  final Widget? label;
  final Widget? trailing;
  final bool loading;
  final bool expand;
  final bool square;
  final bool circular;
  final bool flat;
  final bool underlineOnHover;
  final double? height;
  final double? radius;
  final List<BoxShadow>? shadow;
  final String? tooltip;
  final bool? selected;
  final bool? toggled;
  final Widget? badge;
  final Widget? underlay;
  final ValueChanged<bool>? onHighlightChanged;
  final double pressScale;

  double get _height => height ?? size.height;

  double get _radius => radius ?? (circular ? _height / 2 : (size == UiSize.sm ? UiRadius.sm : UiRadius.md));

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return _Pressable(
      onTap: onPressed,
      busy: loading,
      tooltip: tooltip,
      selected: selected,
      toggled: toggled,
      pressScale: pressScale,
      focusRadius: _radius,
      onHighlightChanged: onHighlightChanged,
      builder: (context, states) {
        final p = palette(c, states);
        final enabled = !states.contains(WidgetState.disabled);
        final hovered = states.contains(WidgetState.hovered);
        final duration = context.motion(UiMotion.fast);
        final style = (context.text.labelLarge ?? const TextStyle()).copyWith(
          fontSize: size.fontSize,
          color: p.fg,
          decoration: underlineOnHover && hovered ? TextDecoration.underline : TextDecoration.none,
          decorationColor: p.fg,
        );
        final gap = size == UiSize.sm ? UiSpace.xs + UiSpace.xxs : UiSpace.sm;
        Widget content = Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ?leading,
            if (leading != null && label != null) SizedBox(width: gap),
            if (label != null) Flexible(child: label!),
            if (trailing != null && (label != null || leading != null)) SizedBox(width: gap),
            ?trailing,
          ],
        );
        content = IconTheme.merge(
          data: IconThemeData(color: p.fg, size: square ? size.iconSize + 2 : size.iconSize),
          child: AnimatedDefaultTextStyle(
            style: style,
            duration: duration,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            child: content,
          ),
        );
        content = Stack(
          alignment: Alignment.center,
          children: [
            AnimatedOpacity(opacity: loading ? 0 : 1, duration: duration, child: content),
            if (loading) _Spinner(size: size.iconSize, color: p.fg),
          ],
        );
        Widget box = AnimatedContainer(
          duration: duration,
          curve: UiMotion.standard,
          height: _height,
          width: square ? _height : (expand ? double.infinity : null),
          constraints: square || flat ? null : BoxConstraints(minWidth: _height),
          clipBehavior: underlay != null ? Clip.antiAlias : Clip.none,
          decoration: BoxDecoration(
            color: p.bg,
            borderRadius: UiRadius.all(_radius),
            border: Border.all(color: p.border),
            boxShadow: enabled ? shadow : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (underlay != null) Positioned.fill(child: underlay!),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: square ? 0 : (flat ? UiSpace.xs : size.padding)),
                child: content,
              ),
            ],
          ),
        );
        if (badge != null) {
          box = Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.none,
            children: [
              box,
              PositionedDirectional(top: UiSpace.xxs, end: UiSpace.xxs, child: badge!),
            ],
          );
        }
        return box;
      },
    );
  }
}

/// Small indeterminate spinner used by loading buttons.
class _Spinner extends StatelessWidget {
  const _Spinner({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CircularProgressIndicator(strokeWidth: 2, color: color, strokeCap: StrokeCap.round),
    );
  }
}

/// Count pill or dot shown on the corner of an icon button.
class _Badge extends StatelessWidget {
  const _Badge({this.count});

  /// Null or zero shows a dot.
  final int? count;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final n = count ?? 0;
    if (n <= 0) {
      return Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: c.danger,
          shape: BoxShape.circle,
          border: Border.all(color: c.surface, width: 1.5),
        ),
      );
    }
    return Container(
      height: 16,
      constraints: const BoxConstraints(minWidth: 16),
      padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.danger,
        borderRadius: UiRadius.all(UiRadius.full),
        border: Border.all(color: c.surface, width: 1.5),
      ),
      child: Text(
        n > 99 ? '99+' : '$n',
        maxLines: 1,
        style: (context.text.labelSmall ?? const TextStyle()).copyWith(
          fontSize: 10,
          height: 1,
          fontWeight: FontWeight.w700,
          color: c.onDanger,
        ),
      ),
    );
  }
}
