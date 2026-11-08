import 'package:flutter/material.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/image/ui_image.dart';

class UiAvatar extends StatelessWidget {
  const UiAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.icon = Icons.person_rounded,
    this.size = 44,
    this.status,
    this.onTap,
    this.ring = false,
  });

  final String? name;
  final String? imageUrl;
  final IconData icon;
  final double size;
  final UiStatus? status;
  final VoidCallback? onTap;
  final bool ring;

  static String initials(String? name) {
    final parts = (name ?? '').trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    return (parts.length == 1 ? parts.first.substring(0, 1) : parts.first[0] + parts.last[0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final cs = context.colors;
    final hasImg = imageUrl != null && imageUrl!.trim().isNotEmpty;
    final ini = initials(name);
    final palette = [cs.primaryContainer, cs.secondaryContainer, cs.tertiaryContainer];
    final onPalette = [cs.onPrimaryContainer, cs.onSecondaryContainer, cs.onTertiaryContainer];
    final idx = (name?.hashCode ?? 0).abs() % palette.length;

    Widget core = hasImg
        ? UiImage(imageUrl, width: size, height: size, radius: BorderRadius.circular(size), placeholderIcon: icon)
        : Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: palette[idx], shape: BoxShape.circle),
            child: ini.isEmpty
                ? Icon(icon, size: size * 0.5, color: onPalette[idx])
                : Text(
                    ini,
                    style: context.text.titleMedium?.copyWith(
                      fontSize: size * 0.36,
                      fontWeight: FontWeight.w700,
                      color: onPalette[idx],
                    ),
                  ),
          );

    if (ring) {
      core = Container(
        padding: const EdgeInsets.all(2.5),
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: context.palette.gradient),
        child: Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(shape: BoxShape.circle, color: cs.surface),
          child: core,
        ),
      );
    }

    if (status != null) {
      final dot = (size * 0.28).clamp(8.0, 16.0);
      core = Stack(
        clipBehavior: Clip.none,
        children: [
          core,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: dot,
              height: dot,
              decoration: BoxDecoration(
                color: context.tone(status!).color,
                shape: BoxShape.circle,
                border: Border.all(color: cs.surface, width: 2),
              ),
            ),
          ),
        ],
      );
    }

    return Semantics(
      label: name,
      image: true,
      button: onTap != null,
      child: onTap == null ? core : GestureDetector(onTap: onTap, child: core),
    );
  }
}
