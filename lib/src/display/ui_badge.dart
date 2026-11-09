import 'package:flutter/material.dart';

import 'package:theme/src/display/display_shared.dart';
import 'package:theme/src/foundation/foundation.dart';

/// A small solid pill with a number, shown inline (e.g. next to a menu label).
///
/// ```dart
/// UiCountBadge(5)
/// ```
class UiCountBadge extends StatelessWidget {
  const UiCountBadge(this.count, {super.key, this.status = UiStatus.danger, this.max = 99, this.ring = false});

  final int count;
  final UiStatus status;

  /// Larger counts show as "99+".
  final int max;

  /// Adds a surface-colored outline so the badge stands out over content.
  final bool ring;

  /// Text shown for [count] with [max]: `5`, `99+`.
  static String label(int count, int max) => count > max ? '$max+' : '$count';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tone = colors.tone(status);
    return Semantics(
      label: '$count',
      excludeSemantics: true,
      child: Container(
        constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: tone.color,
          borderRadius: UiRadius.all(UiRadius.full),
          border: ring ? Border.all(color: colors.surface, width: 2, strokeAlign: BorderSide.strokeAlignOutside) : null,
        ),
        child: Center(
          widthFactor: 1,
          heightFactor: 1,
          child: Text(
            label(count, max),
            maxLines: 1,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              fontSize: 11,
              height: 1.2,
              fontWeight: FontWeight.w700,
              color: tone.onColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );
  }
}

/// Overlays a count or dot on the top-right corner of [child].
///
/// ```dart
/// UiBadge(count: 3, child: Icon(Icons.notifications_rounded))
/// ```
class UiBadge extends StatelessWidget {
  const UiBadge({
    super.key,
    required this.child,
    this.count,
    this.dot = false,
    this.status = UiStatus.danger,
    this.max = 99,
    this.show = true,
    this.offset = Offset.zero,
  });

  /// Inline badge without a child (same as [UiCountBadge], or a dot).
  static Widget standalone({Key? key, int? count, bool dot = false, UiStatus status = UiStatus.danger, int max = 99}) =>
      count != null && !dot ? UiCountBadge(count, key: key, status: status, max: max) : _Dot(key: key, status: status);

  final Widget child;

  /// Number to show. Zero or null hides the badge unless [dot] is true.
  final int? count;

  /// Shows a small dot instead of a number.
  final bool dot;
  final UiStatus status;
  final int max;

  /// Hides the badge (animated) when false.
  final bool show;

  /// Extra shift of the badge from the corner.
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final c = count;
    final visible = show && (dot || (c != null && c > 0));
    final badge = dot ? _Dot(status: status, ring: true) : UiCountBadge(c ?? 0, status: status, max: max, ring: true);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          top: (dot ? -1 : -6) + offset.dy,
          right: (dot ? -1 : -8) + -offset.dx,
          child: IgnorePointer(
            child: AnimatedScale(
              scale: visible ? 1 : 0,
              duration: context.motion(UiMotion.normal),
              curve: visible ? UiMotion.bounce : UiMotion.standard,
              child: badge,
            ),
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({super.key, required this.status, this.ring = false});

  final UiStatus status;
  final bool ring;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: colors.tone(status).color,
        shape: BoxShape.circle,
        border: ring ? Border.all(color: colors.surface, width: 2, strokeAlign: BorderSide.strokeAlignOutside) : null,
      ),
    );
  }
}

/// A soft tinted pill that shows a state, with an optional (pulsing) dot or icon.
///
/// ```dart
/// UiStatusPill('Online', status: UiStatus.success, dot: true, pulse: true)
/// ```
class UiStatusPill extends StatefulWidget {
  const UiStatusPill(
    this.label, {
    super.key,
    this.status = UiStatus.neutral,
    this.dot = false,
    this.pulse = false,
    this.icon,
    this.size = UiSize.sm,
  });

  final String label;
  final UiStatus status;

  /// Shows a colored dot before the label.
  final bool dot;

  /// Animates the dot with a soft ping (implies [dot]).
  final bool pulse;

  /// Icon before the label (instead of a dot).
  final IconData? icon;
  final UiSize size;

  @override
  State<UiStatusPill> createState() => _UiStatusPillState();
}

class _UiStatusPillState extends State<UiStatusPill> with SingleTickerProviderStateMixin {
  AnimationController? _pulse;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPulse();
  }

  @override
  void didUpdateWidget(UiStatusPill oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncPulse();
  }

  void _syncPulse() {
    final want = widget.pulse && context.motion(UiMotion.slow) > Duration.zero;
    if (want && _pulse == null) {
      _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    } else if (!want && _pulse != null) {
      _pulse!.dispose();
      _pulse = null;
    }
  }

  @override
  void dispose() {
    _pulse?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tone = colors.tone(widget.status);
    final fg = widget.status == UiStatus.neutral ? colors.textMuted : tone.onSoft;
    final dotColor = widget.status == UiStatus.neutral ? colors.textSubtle : tone.color;
    final (height, font, pad) = switch (widget.size) {
      UiSize.sm => (22.0, 11.5, 8.0),
      UiSize.md => (26.0, 12.5, 10.0),
      UiSize.lg => (30.0, 13.5, 12.0),
    };

    Widget? lead;
    if (widget.icon != null) {
      lead = Icon(widget.icon, size: font + 2, color: fg);
    } else if (widget.dot || widget.pulse) {
      final dot = Container(
        width: 6,
        height: 6,
        decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
      );
      final pulse = _pulse;
      lead = SizedBox.square(
        dimension: 10,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (pulse != null)
              AnimatedBuilder(
                animation: pulse,
                builder: (context, _) {
                  final t = Curves.easeOut.transform(pulse.value);
                  return Container(
                    width: 6 + 6 * t,
                    height: 6 + 6 * t,
                    decoration: BoxDecoration(
                      color: dotColor.withValues(alpha: 0.5 * (1 - t)),
                      shape: BoxShape.circle,
                    ),
                  );
                },
              ),
            dot,
          ],
        ),
      );
    }

    return Container(
      height: height,
      padding: EdgeInsets.symmetric(horizontal: pad),
      decoration: BoxDecoration(color: tone.soft, borderRadius: UiRadius.all(UiRadius.full)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (lead != null) ...[lead, SizedBox(width: pad * 0.5)],
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: font, fontWeight: FontWeight.w600, color: fg, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small rectangular label, optionally colored and removable.
///
/// ```dart
/// UiTag('Design', color: Colors.purple, onRemove: () => remove('Design'))
/// ```
class UiTag extends StatelessWidget {
  const UiTag(this.label, {super.key, this.color, this.status, this.icon, this.onRemove});

  final String label;

  /// Custom tint (e.g. a category color).
  final Color? color;

  /// Status tint, used when [color] is null. Null is a neutral outlined tag.
  final UiStatus? status;
  final IconData? icon;

  /// Shows a small remove button.
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final Color bg;
    final Color fg;
    Color? border;
    final c = color;
    if (c != null) {
      bg = displaySoft(colors, c);
      fg = displayOnSoft(colors, c);
    } else if (status != null && status != UiStatus.neutral) {
      final tone = colors.tone(status!);
      bg = tone.soft;
      fg = tone.onSoft;
    } else {
      bg = colors.surfaceMuted;
      fg = colors.textMuted;
      border = colors.border;
    }
    return Container(
      height: 24,
      padding: EdgeInsets.only(left: UiSpace.sm, right: onRemove == null ? UiSpace.sm : UiSpace.xxs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: UiRadius.all(UiRadius.xs),
        border: border == null ? null : Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: fg), const SizedBox(width: UiSpace.xs)],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg, height: 1.2),
            ),
          ),
          if (onRemove != null)
            Semantics(
              button: true,
              label: 'Remove $label',
              child: InkResponse(
                onTap: onRemove,
                radius: 14,
                child: Padding(
                  padding: const EdgeInsets.all(UiSpace.xs),
                  child: Icon(Icons.close_rounded, size: 12, color: fg),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A keyboard key chip for shortcuts.
///
/// ```dart
/// UiKbd('⌘K')
/// ```
class UiKbd extends StatelessWidget {
  const UiKbd(this.keys, {super.key});

  final String keys;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      constraints: const BoxConstraints(minWidth: 22, minHeight: 22),
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: UiRadius.all(UiRadius.xs),
        border: Border.all(color: colors.border),
        boxShadow: [BoxShadow(color: colors.border, offset: const Offset(0, 1))],
      ),
      child: Center(
        widthFactor: 1,
        heightFactor: 1,
        child: Text(
          keys,
          maxLines: 1,
          style: UiTypography.mono(fontSize: 11.5, fontWeight: FontWeight.w600, color: colors.textMuted),
        ),
      ),
    );
  }
}
