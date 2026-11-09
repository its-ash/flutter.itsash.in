import 'package:flutter/material.dart';

import 'package:theme/src/display/display_shared.dart';
import 'package:theme/src/foundation/foundation.dart';

/// Shape of a [UiAvatar].
enum UiAvatarShape { circle, rounded }

/// A user or entity picture with initials fallback and optional status dot.
///
/// The background tint is picked from the chart palette by [name], so the
/// same name always gets the same color.
///
/// ```dart
/// UiAvatar(name: 'Ada Lovelace', status: UiStatus.success)
/// ```
class UiAvatar extends StatelessWidget {
  const UiAvatar({
    super.key,
    this.name,
    this.image,
    this.icon,
    this.size = UiSize.md,
    this.diameter,
    this.status,
    this.shape = UiAvatarShape.circle,
    this.color,
    this.semanticLabel,
  });

  /// Used for the initials and the background tint.
  final String? name;

  /// Picture. While loading, or when it fails, the initials are shown.
  final ImageProvider? image;

  /// Shown when there is no [name] (defaults to a person icon).
  final IconData? icon;

  /// `sm` 32, `md` 40, `lg` 56 px. Ignored when [diameter] is set.
  final UiSize size;

  /// Exact size in px.
  final double? diameter;

  /// Presence dot: `success` online, `warning` away, `danger` busy,
  /// `neutral` offline.
  final UiStatus? status;
  final UiAvatarShape shape;

  /// Custom tint instead of the name-based one.
  final Color? color;
  final String? semanticLabel;

  /// Pixel size for a [UiSize].
  static double sizeOf(UiSize size) => switch (size) {
    UiSize.sm => 32,
    UiSize.md => 40,
    UiSize.lg => 56,
  };

  /// Up to two uppercase initials of [name]: "Ada Lovelace" → "AL".
  static String initialsOf(String name) {
    var n = name.trim();
    final at = n.indexOf('@');
    if (at > 0) n = n.substring(0, at);
    final parts = n.split(RegExp(r'[\s._\-]+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    String first(String s) => String.fromCharCodes(s.runes.take(1)).toUpperCase();
    if (parts.length == 1) return first(parts.first);
    return first(parts.first) + first(parts.last);
  }

  /// Stable palette index for [name].
  static int colorIndexOf(String name) {
    var h = 0;
    for (final c in name.trim().toLowerCase().codeUnits) {
      h = (h * 31 + c) & 0x7fffffff;
    }
    return h;
  }

  /// Same avatar at another size (used by `UiAvatarGroup`).
  UiAvatar resized(double d) => UiAvatar(
    key: key,
    name: name,
    image: image,
    icon: icon,
    diameter: d,
    status: status,
    shape: shape,
    color: color,
    semanticLabel: semanticLabel,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = diameter ?? sizeOf(size);
    final n = name?.trim() ?? '';
    final initials = n.isEmpty ? '' : initialsOf(n);
    final tint = color ?? (n.isEmpty ? null : colors.chartColor(colorIndexOf(n)));
    final bg = tint == null ? colors.surfaceMuted : displaySoft(colors, tint);
    final fg = tint == null ? colors.textMuted : displayOnSoft(colors, tint);
    final radius = shape == UiAvatarShape.circle ? UiRadius.all(d / 2) : UiRadius.all(d * 0.28);

    final fallback = Container(
      width: d,
      height: d,
      alignment: Alignment.center,
      color: bg,
      child: initials.isEmpty
          ? Icon(icon ?? Icons.person_rounded, size: d * 0.5, color: fg)
          : Text(
              initials,
              maxLines: 1,
              textScaler: TextScaler.noScaling,
              style: TextStyle(
                fontSize: d * (initials.length > 1 ? 0.36 : 0.42),
                fontWeight: FontWeight.w600,
                color: fg,
                height: 1,
                letterSpacing: 0,
              ),
            ),
    );

    Widget face = fallback;
    if (image != null) {
      face = Image(
        image: image!,
        width: d,
        height: d,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, sync) => frame == null && !sync ? fallback : child,
        errorBuilder: (context, error, stack) => fallback,
      );
    }

    Widget avatar = ClipRRect(
      borderRadius: radius,
      child: SizedBox.square(dimension: d, child: face),
    );

    if (status != null) {
      final dot = (d * 0.28).clamp(8.0, 16.0);
      final dotColor = status == UiStatus.neutral ? colors.textSubtle : colors.tone(status!).color;
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: shape == UiAvatarShape.circle ? d * 0.02 : -dot * 0.2,
            bottom: shape == UiAvatarShape.circle ? d * 0.02 : -dot * 0.2,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: colors.surface, width: dot > 10 ? 2 : 1.5),
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      image: true,
      label: semanticLabel ?? name,
      child: SizedBox.square(dimension: d, child: avatar),
    );
  }
}

/// Overlapping avatars with a "+N" chip for the rest.
///
/// ```dart
/// UiAvatarGroup(avatars: [UiAvatar(name: 'Ada'), UiAvatar(name: 'Alan')], max: 3)
/// ```
class UiAvatarGroup extends StatelessWidget {
  const UiAvatarGroup({super.key, required this.avatars, this.max = 4, this.size = UiSize.md, this.overlap = 0.3});

  final List<UiAvatar> avatars;

  /// Avatars shown before the "+N" chip.
  final int max;
  final UiSize size;

  /// Fraction of each avatar hidden under the next one.
  final double overlap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final d = UiAvatar.sizeOf(size);
    const ring = 2.0;
    final outer = d + ring * 2;
    final step = outer * (1 - overlap);
    final shown = avatars.length > max ? avatars.take(max).toList() : avatars;
    final rest = avatars.length - shown.length;
    final count = shown.length + (rest > 0 ? 1 : 0);
    if (count == 0) return const SizedBox.shrink();

    Widget ringed(Widget child) => Container(
      padding: const EdgeInsets.all(ring),
      decoration: BoxDecoration(color: colors.surface, shape: BoxShape.circle),
      child: child,
    );

    return Semantics(
      label: '${avatars.length} people',
      child: SizedBox(
        width: outer + step * (count - 1),
        height: outer,
        child: Stack(
          children: [
            for (var i = 0; i < shown.length; i++)
              Positioned(left: step * i, top: 0, child: ringed(shown[i].resized(d))),
            if (rest > 0)
              Positioned(
                left: step * shown.length,
                top: 0,
                child: ringed(
                  Container(
                    width: d,
                    height: d,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: colors.surfaceMuted, shape: BoxShape.circle),
                    child: Text(
                      '+$rest',
                      maxLines: 1,
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        fontSize: d * (rest > 99 ? 0.28 : 0.34),
                        fontWeight: FontWeight.w600,
                        color: colors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
