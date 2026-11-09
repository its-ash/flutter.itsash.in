import 'package:flutter/material.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/media/ui_image.dart';

/// Social-post style photo collage: 1, 2, 3 or 4 tiles, with a "+N" overlay
/// on the last tile when there are more images.
///
/// ```dart
/// UiImageGrid(images: urls, onTap: (i) => UiImageViewer.show(context, images: urls, initialIndex: i))
/// ```
class UiImageGrid extends StatelessWidget {
  const UiImageGrid({
    super.key,
    required this.images,
    this.maxShown = 4,
    this.onTap,
    this.radius = UiRadius.lg,
    this.spacing = UiSpace.xxs,
  });

  /// Each entry is a URL / asset path `String` or an [ImageProvider].
  final List<Object> images;

  /// Tiles to show, from 1 to 4. Extra images are counted in the "+N" overlay.
  final int maxShown;

  /// Called with the index of the tapped image. Null disables taps.
  final ValueChanged<int>? onTap;

  /// Outer corner radius.
  final double radius;

  /// Gap between tiles.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) return const SizedBox.shrink();
    final shown = images.length.clamp(1, maxShown.clamp(1, 4));
    final extra = images.length - shown;
    final g = spacing;

    Widget tile(int i) => _UiGridTile(
      image: images[i],
      extra: i == shown - 1 && extra > 0 ? extra : 0,
      onTap: onTap == null ? null : () => onTap!(i),
      label: 'Photo ${i + 1} of ${images.length}',
    );

    final Widget layout;
    final double aspect;
    switch (shown) {
      case 1:
        aspect = 4 / 3;
        layout = tile(0);
      case 2:
        aspect = 2 / 1.1;
        layout = Row(
          children: [
            Expanded(child: tile(0)),
            SizedBox(width: g),
            Expanded(child: tile(1)),
          ],
        );
      case 3:
        aspect = 4 / 3;
        layout = Row(
          children: [
            Expanded(flex: 3, child: tile(0)),
            SizedBox(width: g),
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Expanded(child: tile(1)),
                  SizedBox(height: g),
                  Expanded(child: tile(2)),
                ],
              ),
            ),
          ],
        );
      default:
        aspect = 1;
        layout = Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: tile(0)),
                  SizedBox(width: g),
                  Expanded(child: tile(1)),
                ],
              ),
            ),
            SizedBox(height: g),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: tile(2)),
                  SizedBox(width: g),
                  Expanded(child: tile(3)),
                ],
              ),
            ),
          ],
        );
    }

    return AspectRatio(
      aspectRatio: aspect,
      child: ClipRRect(borderRadius: UiRadius.all(radius), child: layout),
    );
  }
}

class _UiGridTile extends StatelessWidget {
  const _UiGridTile({required this.image, required this.extra, required this.label, this.onTap});

  final String label;
  final Object image;
  final int extra;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        UiImage.provider(UiImage.resolve(image)),
        if (extra > 0)
          ColoredBox(
            color: Colors.black.withValues(alpha: 0.5),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text('+$extra', style: context.text.headlineMedium?.copyWith(color: Colors.white)),
              ),
            ),
          ),
        if (onTap != null)
          Semantics(
            button: true,
            label: label,
            child: Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap),
            ),
          ),
      ],
    );
  }
}
