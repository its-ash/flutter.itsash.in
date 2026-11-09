# Media

Images, carousels, a fullscreen photo viewer, photo collages and video.

### UiImage

Image with a shimmer placeholder, a fade-in and an error fallback. It is decoded at its display size to save memory.

```dart
UiImage('https://example.com/photo.jpg', height: 200, radius: UiRadius.lg)
UiImage.provider(MemoryImage(bytes), aspectRatio: 1)
```

- `src` (positional): URL (`http://`, `https://`) or asset path. Use `UiImage.provider(ImageProvider)` for any other source.
- `width`, `height`: size. Default: from the parent.
- `aspectRatio`: width / height, used when only one side is known. Default: none.
- `fit`: default `BoxFit.cover`.
- `radius`: corner radius. Default `0`.
- `placeholder`: shown while loading. Default: shimmer.
- `errorWidget`: shown on failure. Default: image icon on `surfaceMuted`.
- `semanticLabel`: accessibility label. Default: none (decorative).
- `lazy`: start loading only near the viewport. Default `false`.
- `UiImage.resolve(Object)`: turns a `String` or `ImageProvider` into an `ImageProvider`.

### UiCarousel

Swipeable cards with the neighbours peeking in, optional autoplay and a dots indicator.

```dart
UiCarousel(itemCount: banners.length, itemBuilder: (context, i) => UiImage(banners[i]), autoPlay: true)
```

- `itemCount`, `itemBuilder`: required.
- `height`: fixed page height. Default: from `aspectRatio`.
- `aspectRatio`: page width / height. Default `16 / 9`.
- `autoPlay`: default `false`. Pauses while the user drags.
- `interval`: default 4 seconds.
- `viewportFraction`: page width share. Default `0.88`.
- `indicator`: `UiCarouselIndicator.dots` (default) or `.none`.
- `onPageChanged`: called with the item index.
- `loop`: wrap around. Default `false`.
- `initialPage`: default `0`.
- `radius`: page corner radius. Default `UiRadius.lg`.

### UiImageViewer

Fullscreen black viewer. Pinch or double-tap to zoom, swipe between images, swipe down to close. Shows a close button and a "2 / 5" counter. Tap toggles the top bar.

```dart
UiImageViewer.show(context, images: urls, initialIndex: 2);
```

- `images`: list of `String` (URL or asset) or `ImageProvider`. Required.
- `initialIndex`: default `0`.
- `heroTag`: Hero tag of the thumbnail it opens from. Default: none.
- Returns a `Future<void>` that completes when the viewer closes.

### UiImageGrid

Social-post photo collage for 1, 2, 3 or 4 tiles. The last tile shows "+N" when there are more images.

```dart
UiImageGrid(images: urls, onTap: (i) => UiImageViewer.show(context, images: urls, initialIndex: i))
```

- `images`: list of `String` or `ImageProvider`. Required.
- `maxShown`: tiles to show, 1 to 4. Default `4`.
- `onTap`: called with the image index. Null disables taps.
- `radius`: outer corner radius. Default `UiRadius.lg`.
- `spacing`: gap between tiles. Default `UiSpace.xxs`.

### UiVideoPlayer

Video player with a controls overlay: play/pause, scrubber, time, mute and fullscreen. Shows a spinner while loading and a retry view on errors.

```dart
UiVideoPlayer('https://example.com/clip.mp4', autoPlay: true, muted: true)
```

- `source` (positional): URL or asset path. Use `UiVideoPlayer.controller(VideoPlayerController)` to pass your own controller (not disposed by the widget).
- `aspectRatio`: default: the video's own ratio (16:9 while loading).
- `autoPlay`: default `false`.
- `loop`: default `false`.
- `muted`: default `false`.
- `controls`: show the overlay. Default `true`.
- `allowFullscreen`: show the fullscreen button. Default `true`.
- `radius`: corner radius. Default `UiRadius.lg`.

### UiVideoThumbnail

Video preview: an image with a play badge and a duration chip.

```dart
UiVideoThumbnail(posterUrl, duration: const Duration(minutes: 3, seconds: 12), onTap: play)
```

- `image` (positional): `String` or `ImageProvider`.
- `duration`: shown at the bottom right. Default: hidden.
- `onTap`: null disables the thumbnail.
- `aspectRatio`: default `16 / 9`.
- `radius`: default `UiRadius.lg`.
- `semanticLabel`: default `'Play video'`.
