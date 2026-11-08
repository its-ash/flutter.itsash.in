# Video

Source: `lib/src/video/`. Uses the [`video_player`](https://pub.dev/packages/video_player) package.

### UiVideoPlayer
A video player with its own controls.
```dart
UiVideoPlayer('https://example.com/clip.mp4', poster: thumbUrl)
UiVideoPlayer('assets/intro.mp4', autoplay: true, muted: true, loop: true, showControls: false)
UiVideoPlayer.controller(myController) // you create, own, and dispose the controller
```
Controls:
- Tap the video to show or hide the controls. They hide after `autoHide` (3 s) while the video plays.
- Center: back 10 s, play / pause / replay, forward 10 s. Double-tap the left or right half to skip.
- Bottom bar: time, playback speed menu, mute, volume slider (on screens 480 px or wider), full screen, and a seek bar that shows the buffered part.
- A spinner shows while the video loads or buffers. If the video fails, the player shows **Retry**.
- Full screen hides the system bars. A wide video also turns the screen to landscape. Both reset when the user leaves full screen.

Parameters:
- `src` (URL or asset path), `autoplay` (false), `loop` (false), `muted` (false)
- `aspectRatio` (default: the video's own ratio; 16:9 before it loads), `poster` (image URL or asset; shows until the first play)
- `showControls` (true; false = a tap plays or pauses), `allowFullscreen` (true)
- `speeds` (`[0.5, 0.75, 1, 1.25, 1.5, 2]`), `skip` (10 s), `autoHide` (3 s; zero = never hide)
- `radius` (default `context.tokens.lg`), `httpHeaders` (network only)
- `onEnded`, `onError`
- The player creates and disposes its own controller when you pass `src`. It does not dispose a controller that you pass to `.controller`.

Platform setup in the app that uses the player:
- **Android**: network video needs `<uses-permission android:name="android.permission.INTERNET"/>` in `AndroidManifest.xml`. Plain `http://` URLs also need `android:usesCleartextTraffic="true"`.
- **iOS**: plain `http://` URLs need an App Transport Security exception in `Info.plist`.
- **macOS**: add `com.apple.security.network.client` to the entitlements.

### UiVideoThumbnail
A poster image with a play button, a title, and a duration badge. Use it in lists, then open a `UiVideoPlayer` on tap.
```dart
UiVideoThumbnail(image: thumbUrl, title: 'Intro', duration: Duration(minutes: 2, seconds: 5), onTap: play)
```
- `image`, `duration`, `title`, `onTap`, `aspectRatio` (16 / 9), `radius`
