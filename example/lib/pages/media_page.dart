import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import 'common.dart';

class MediaPage extends StatefulWidget {
  const MediaPage({super.key});

  @override
  State<MediaPage> createState() => _MediaPageState();
}

class _MediaPageState extends State<MediaPage> {
  int _slide = 0;
  bool _autoPlay = true;
  int _gridCount = 6;

  void _playVideo(String source) {
    UiSheet.show<void>(
      context,
      title: source.split('/').last,
      child: UiVideoPlayer(source, autoPlay: true, loop: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridImages = productImages.take(_gridCount).toList();
    return GalleryPage(
      children: [
        Demo(
          'Images',
          subtitle: 'Asset, network (picsum.photos) and a broken source',
          child: UiResponsiveGrid(
            minItemWidth: 150,
            children: [
              UiImage(contentImages[0], aspectRatio: 1, radius: UiRadius.lg, semanticLabel: 'Asset image'),
              const UiImage('https://picsum.photos/seed/theme/400', aspectRatio: 1, radius: UiRadius.lg),
              const UiImage('assets/images/missing.jpg', aspectRatio: 1, radius: UiRadius.lg),
            ],
          ),
        ),
        Demo(
          'Carousel',
          subtitle: 'Slide ${_slide + 1} of ${contentImages.length}',
          child: UiColumn(
            children: [
              UiSwitch(_autoPlay, label: 'Autoplay', onChanged: (v) => setState(() => _autoPlay = v)),
              UiCarousel(
                itemCount: contentImages.length,
                autoPlay: _autoPlay,
                loop: true,
                onPageChanged: (i) => setState(() => _slide = i),
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => UiImageViewer.show(context, images: contentImages, initialIndex: i),
                  child: UiImage(contentImages[i]),
                ),
              ),
            ],
          ),
        ),
        Demo(
          'Image grid and viewer',
          subtitle: 'Tap a tile to open the fullscreen viewer',
          child: UiColumn(
            children: [
              UiSegmentedControl<int>(
                const [
                  UiSegment(1, label: '1'),
                  UiSegment(2, label: '2'),
                  UiSegment(3, label: '3'),
                  UiSegment(6, label: '6'),
                ],
                value: _gridCount,
                onChanged: (v) => setState(() => _gridCount = v),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: UiImageGrid(
                  images: gridImages,
                  onTap: (i) => UiImageViewer.show(context, images: gridImages, initialIndex: i),
                ),
              ),
            ],
          ),
        ),
        Demo(
          'Video',
          child: UiColumn(
            children: [
              const UiVideoPlayer('assets/video/butterfly.mp4', muted: true, loop: true),
              UiResponsiveGrid(
                minItemWidth: 200,
                children: [
                  UiVideoThumbnail(
                    'assets/images/content/run.jpg',
                    duration: const Duration(seconds: 12),
                    onTap: () => _playVideo('assets/video/bee.mp4'),
                  ),
                  UiVideoThumbnail(
                    'assets/images/content/yoga.jpg',
                    duration: const Duration(minutes: 3, seconds: 5),
                    onTap: () => _playVideo('assets/video/butterfly.mp4'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
