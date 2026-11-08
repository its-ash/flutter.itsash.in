# Images

Source: `lib/src/image/`. A `src` that starts with `http://` or `https://` loads from the network. Any other `src` loads as an asset.

### UiImage
Shows a network or asset image with a placeholder, a fade-in, and an error fallback.
```dart
UiImage(url, aspectRatio: 1, radius: context.tokens.md)
```
- `src`, `width`, `height`, `aspectRatio`, `fit`, `radius`, `semanticLabel`, `placeholderIcon`.

### UiLazyImage
Use this for images in long lists and grids. It does three things:
1. It does not start to load until the image is near the screen (`lazy`, `margin`).
2. It decodes the image at the size it shows on screen, not the full file size. This saves memory.
3. It shows a shimmer while it loads, then fades in.
```dart
UiLazyImage(url, aspectRatio: 1, radius: context.tokens.md)
```
- `src`, `width`, `height`, `aspectRatio`, `fit` (cover), `radius`, `semanticLabel`
- `placeholder` (default shimmer), `errorWidget`, `placeholderIcon` (used by the default error fallback)
- `lazy` (true), `margin` (300 px around the screen that counts as "near"), `fadeDuration` (250 ms), `headers` (network only)
- Give it a size: `width` + `height`, `aspectRatio`, or a parent with a fixed size. If it has no height, it uses 200 px for the placeholder.
- Turns off the fade when the device asks for less motion.

### UiAvatar
Shows an image, initials, or an icon. It can show a status dot and a gradient ring.
```dart
UiAvatar(name: 'Ana Lee', imageUrl: url, status: UiStatus.success)
```
- `name`, `imageUrl`, `icon`, `size`, `status`, `onTap`, `ring`.

### UiCarousel
Page view of widgets or images with rounded corners, dots, and autoplay. Autoplay stops when the user drags.
```dart
UiCarousel.images(urls, autoplay: true, height: 200);
```
- `UiCarousel({required children, height = 180, viewportFraction = 0.9, autoplay, interval = 4s, dots = true, radius, onChanged, initialIndex})`
- `UiCarousel.images(urls, {..., onTap})`

### UiImageViewer
Full-screen gallery. Pinch or double-tap to zoom. Swipe to change image.
```dart
UiImageViewer.open(context, urls, initialIndex: 2);
```
- `UiImageViewer.open(context, List<String> urls, {initialIndex = 0})` → `Future<void>`

### UiImageGrid
Grid of 1 to 4 images. The last tile shows `+N`. Tap opens the viewer.
```dart
UiImageGrid(urls, height: 240);
```
- `UiImageGrid(urls, {max = 4, spacing = 4, radius, height = 220, aspectRatio, onTap, onDoubleTap})`
