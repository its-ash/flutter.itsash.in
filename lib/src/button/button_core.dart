part of 'ui_button.dart';

/// Resolved colors of a button for one set of states.
///
/// Follows the Ash Theme "button" / "control" components: solid (Primary
/// fill, bold label), dim (Overlay fill, regular label) and ghost (1 px
/// outline, regular label). Hover and keyboard focus draw a 4 px inner [ring].
class _Palette {
  const _Palette(this.bg, this.fg, {this.border = Colors.transparent, this.ring, this.bold = false});

  final Color bg;
  final Color fg;
  final Color border;

  /// Color of the 4 px hover / focus ring. Null draws no ring.
  final Color? ring;

  /// Bold label (solid styles).
  final bool bold;
}

typedef _PaletteResolver = _Palette Function(UiColors c, Set<WidgetState> states);

bool _highlighted(Set<WidgetState> s) => s.contains(WidgetState.hovered) || s.contains(WidgetState.focused);

/// Applies hover (ring + strong label) and press (slight tint) to [base].
_Palette _interactive(UiColors c, _Palette base, Set<WidgetState> states, {bool strongOnHover = true}) {
  final highlight = _highlighted(states);
  final pressed = states.contains(WidgetState.pressed);
  if (!highlight && !pressed) return _Palette(base.bg, base.fg, border: base.border, bold: base.bold);
  final bg = pressed
      ? Color.alphaBlend(base.fg.withValues(alpha: 0.12), base.bg == Colors.transparent ? c.surfaceMuted : base.bg)
      : base.bg;
  return _Palette(
    bg,
    strongOnHover && base.fg == c.gray(7) ? c.text : base.fg,
    border: base.border,
    ring: highlight ? base.ring : null,
    bold: base.bold,
  );
}

_Palette _variantPalette(UiColors c, UiButtonVariant v, UiStatus? status, Set<WidgetState> states) {
  const clear = Colors.transparent;
  if (states.contains(WidgetState.disabled)) {
    return switch (v) {
      UiButtonVariant.primary => _Palette(c.gray(3), c.gray(5), bold: true),
      UiButtonVariant.danger => _Palette(c.gray(3), c.gray(5), bold: true),
      UiButtonVariant.secondary || UiButtonVariant.soft => _Palette(c.gray(2), c.gray(5)),
      UiButtonVariant.outline => _Palette(clear, c.gray(3), border: c.gray(3)),
      UiButtonVariant.ghost || UiButtonVariant.link => _Palette(clear, c.gray(4)),
    };
  }
  final tone = status == null ? null : c.tone(status);
  final base = switch (v) {
    // Solid.
    UiButtonVariant.primary => _Palette(
      tone?.color ?? c.accent,
      tone?.onColor ?? c.onAccent,
      ring: (tone?.color ?? c.accent).withValues(alpha: 0.5),
      bold: true,
    ),
    // Dim.
    UiButtonVariant.secondary => _Palette(
      c.surfaceMuted,
      tone?.color ?? c.text,
      ring: c.gray(5).withValues(alpha: 0.4),
    ),
    UiButtonVariant.soft => _Palette(
      tone?.soft ?? c.accentSoft,
      tone?.onSoft ?? c.onAccentSoft,
      ring: (tone?.color ?? c.accent).withValues(alpha: 0.3),
    ),
    // Ghost (outlined).
    UiButtonVariant.outline => _Palette(
      clear,
      tone?.color ?? c.text,
      border: tone?.color ?? c.border,
      ring: (tone?.color ?? c.gray(3)).withValues(alpha: tone == null ? 1 : 0.4),
    ),
    UiButtonVariant.ghost => _Palette(clear, tone?.color ?? c.text, ring: c.surfaceMuted),
    UiButtonVariant.danger => _Palette(c.danger, c.onDanger, ring: c.danger.withValues(alpha: 0.5), bold: true),
    UiButtonVariant.link => _Palette(clear, tone?.color ?? c.accent),
  };
  if (v == UiButtonVariant.link) return base;
  final p = _interactive(c, base, states);
  // Ghost (borderless) shows the Overlay fill on hover instead of a ring.
  if (v == UiButtonVariant.ghost && _highlighted(states)) {
    return _Palette(c.surfaceMuted, p.fg, border: p.border, bold: p.bold);
  }
  return p;
}

/// Colors of a selectable (toggle) control: dim when off, solid Primary
/// when on.
_Palette _togglePalette(UiColors c, bool selected, Set<WidgetState> states) {
  if (states.contains(WidgetState.disabled)) {
    return _Palette(c.surfaceMuted, c.gray(4), bold: selected);
  }
  final base = selected
      ? _Palette(c.accent, c.onAccent, ring: c.accent.withValues(alpha: 0.5), bold: true)
      : _Palette(c.surfaceMuted, c.text, ring: c.gray(5).withValues(alpha: 0.4));
  return _interactive(c, base, states);
}

/// Button height for [size]: 40 / 48 / 56 (Nova "Add to Bag" is 56).
/// Icon-only buttons are circles of the same diameter.
double _buttonHeight(UiSize size) => switch (size) {
  UiSize.sm => 40,
  UiSize.md => 48,
  UiSize.lg => 56,
};

/// Horizontal button padding for [size].
double _buttonPadding(UiSize size) => switch (size) {
  UiSize.sm => 20,
  UiSize.md => 28,
  UiSize.lg => 32,
};

/// Control (chip, segment, toggle) height for [size]: 32 / 40 / 48.
double _controlHeight(UiSize size) => switch (size) {
  UiSize.sm => 32,
  UiSize.md => 40,
  UiSize.lg => 48,
};

/// Horizontal control padding for [size].
double _controlPadding(UiSize size) => switch (size) {
  UiSize.sm => 14,
  UiSize.md => 18,
  UiSize.lg => 22,
};

/// Label size for [size]: 13 / 15 / 17.
double _buttonFont(UiSize size) => size.fontSize;

/// Icon size inside buttons: 16 / 20 / 22.
double _buttonIcon(UiSize size) => size.iconSize;

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
    this.focusRing = true,
  });

  /// Draws the accent focus ring. Off when the child draws its own ring.
  final bool focusRing;

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
    final ring = widget.focusRadius + 4;
    Widget child = !widget.focusRing
        ? widget.builder(context, states)
        : Stack(
            fit: StackFit.passthrough,
            clipBehavior: Clip.none,
            children: [
              widget.builder(context, states),
              Positioned(
                left: -4,
                top: -4,
                right: -4,
                bottom: -4,
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: states.contains(WidgetState.focused) ? 1 : 0,
                    duration: context.motion(UiMotion.fast),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: UiRadius.all(ring),
                        border: Border.all(color: c.accent.withValues(alpha: 0.5), width: 4),
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
    this.shadow,
    this.tooltip,
    this.selected,
    this.toggled,
    this.badge,
    this.underlay,
    this.onHighlightChanged,
    this.pressScale = 0.97,
    this.control = false,
  });

  /// Uses the pill "control" metrics (24 / 28 / 36 high) instead of the
  /// button metrics (28 / 36 / 44).
  final bool control;

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
  final List<BoxShadow>? shadow;
  final String? tooltip;
  final bool? selected;
  final bool? toggled;
  final Widget? badge;
  final Widget? underlay;
  final ValueChanged<bool>? onHighlightChanged;
  final double pressScale;

  double get _height => height ?? (control ? _controlHeight(size) : _buttonHeight(size));

  // Every button and control is a pill; icon-only buttons are circles.
  double get _radius => _height / 2;

  double get _padding => control ? _controlPadding(size) : _buttonPadding(size);

  double get _icon => control && size == UiSize.sm ? 16 : _buttonIcon(size);

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
      focusRing: false,
      onHighlightChanged: onHighlightChanged,
      builder: (context, states) {
        final p = palette(c, states);
        final enabled = !states.contains(WidgetState.disabled);
        final hovered = states.contains(WidgetState.hovered);
        final focused = states.contains(WidgetState.focused);
        final duration = context.motion(UiMotion.fast);
        // Keyboard focus always shows a ring, even on styles without one.
        final ringColor = p.ring ?? (focused ? c.accent.withValues(alpha: 0.5) : null);
        final style = (context.text.labelLarge ?? const TextStyle()).copyWith(
          fontSize: _buttonFont(size),
          fontWeight: p.bold ? FontWeight.w500 : FontWeight.w400,
          color: p.fg,
          decoration: underlineOnHover && hovered ? TextDecoration.underline : TextDecoration.none,
          decorationColor: p.fg,
        );
        final gap = size == UiSize.sm || control ? UiSpace.xs : UiSpace.sm;
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
          data: IconThemeData(color: p.fg, size: square && !control ? _icon + 2 : _icon),
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
            if (loading) _Spinner(size: _icon, color: p.fg),
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
          // The design's 4 px hover stroke is drawn inside the button, so it
          // never changes the layout.
          foregroundDecoration: ringColor == null
              ? null
              : BoxDecoration(
                  borderRadius: UiRadius.all(_radius),
                  border: Border.all(color: ringColor, width: 4),
                ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (underlay != null) Positioned.fill(child: underlay!),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: square ? 0 : (flat ? UiSpace.xs : _padding)),
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
