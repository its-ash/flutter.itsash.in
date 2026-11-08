import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../demos/demo_route.dart';
import '../widgets/demo_block.dart';

const _video = 'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';
const _video2 = 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4';

class MediaSection extends StatelessWidget {
  const MediaSection({super.key});

  @override
  Widget build(BuildContext context) {
    final photos = [for (var i = 0; i < 5; i++) pic('media$i', 900, 600)];
    return SectionPage(
      children: [
        DemoBlock(
          'UiVideoPlayer',
          subtitle: 'Tap to show controls. Double-tap left or right to skip 10 s.',
          child: UiVideoPlayer(_video, poster: pic('butterfly', 1280, 720)),
        ),
        DemoBlock(
          'Autoplay, muted, loop, no fullscreen',
          child: const UiVideoPlayer(_video2, autoplay: true, muted: true, loop: true, allowFullscreen: false),
        ),
        DemoBlock(
          'UiVideoThumbnail',
          child: UiVideoThumbnail(
            image: pic('thumb', 1280, 720),
            title: 'Butterfly in the garden',
            duration: const Duration(seconds: 7),
            onTap: () => pushPage(
              context,
              Scaffold(
                appBar: const UiAppBar(title: 'Video'),
                body: const Center(child: UiVideoPlayer(_video, autoplay: true, radius: BorderRadius.zero)),
              ),
            ),
          ),
        ),
        DemoBlock(
          'UiLazyImage',
          subtitle: 'Decodes at the shown size to save memory',
          child: Row(
            children: [
              for (var i = 0; i < 3; i++) ...[
                if (i > 0) const UiGap.sm(),
                Expanded(child: UiLazyImage(pic('lazy$i', 600, 600), aspectRatio: 1, radius: context.tokens.md)),
              ],
            ],
          ),
        ),
        DemoBlock('UiImage', child: UiImage(pic('still', 1200, 600), aspectRatio: 2, radius: context.tokens.lg)),
        DemoBlock('UiCarousel', child: UiCarousel.images(photos, autoplay: true, onTap: (i) => UiImageViewer.open(context, photos, initialIndex: i))),
        DemoBlock('UiImageGrid', subtitle: 'Tap to open the viewer', child: UiImageGrid(photos)),
        DemoBlock(
          'UiAvatar',
          child: WrapRow(
            children: [
              UiAvatar(name: 'Ana Lee', imageUrl: pic('ana', 200, 200), size: 56, ring: true),
              const UiAvatar(name: 'Ben Ortiz', size: 56, status: UiStatus.success),
              const UiAvatar(size: 56),
            ],
          ),
        ),
      ],
    );
  }
}
