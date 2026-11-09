import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:theme/src/foundation/foundation.dart';
import 'package:theme/src/media/ui_image.dart';

/// Video player with a modern controls overlay: play/pause, scrubber, time,
/// mute and fullscreen. Shows loading and error states.
///
/// `http(s)://` sources stream from the network, anything else is an asset.
///
/// ```dart
/// UiVideoPlayer('https://example.com/clip.mp4', autoPlay: true, muted: true)
/// ```
class UiVideoPlayer extends StatefulWidget {
  const UiVideoPlayer(
    String this.source, {
    super.key,
    this.aspectRatio,
    this.autoPlay = false,
    this.loop = false,
    this.muted = false,
    this.controls = true,
    this.allowFullscreen = true,
    this.radius = UiRadius.lg,
  }) : controller = null;

  /// Uses your own [VideoPlayerController]. It is initialized if needed but
  /// never disposed by this widget.
  const UiVideoPlayer.controller(
    VideoPlayerController this.controller, {
    super.key,
    this.aspectRatio,
    this.autoPlay = false,
    this.loop = false,
    this.muted = false,
    this.controls = true,
    this.allowFullscreen = true,
    this.radius = UiRadius.lg,
  }) : source = null;

  /// Network URL or asset path.
  final String? source;

  /// External controller (see [UiVideoPlayer.controller]).
  final VideoPlayerController? controller;

  /// Box ratio. Defaults to the video's own ratio (16:9 while loading).
  final double? aspectRatio;
  final bool autoPlay;
  final bool loop;
  final bool muted;

  /// Shows the controls overlay.
  final bool controls;

  /// Shows the fullscreen button in the controls.
  final bool allowFullscreen;

  /// Corner radius.
  final double radius;

  @override
  State<UiVideoPlayer> createState() => _UiVideoPlayerState();
}

class _UiVideoPlayerState extends State<UiVideoPlayer> {
  VideoPlayerController? _controller;
  Object? _error;

  bool get _owns => widget.controller == null;

  @override
  void initState() {
    super.initState();
    _setUp();
  }

  @override
  void didUpdateWidget(UiVideoPlayer old) {
    super.didUpdateWidget(old);
    if (old.source != widget.source || old.controller != widget.controller) {
      _tearDown(old.controller == null);
      _setUp();
    } else if (_controller?.value.isInitialized ?? false) {
      if (old.loop != widget.loop) _controller!.setLooping(widget.loop);
      if (old.muted != widget.muted) _controller!.setVolume(widget.muted ? 0 : 1);
    }
  }

  @override
  void dispose() {
    _tearDown(_owns);
    super.dispose();
  }

  void _setUp() {
    _error = null;
    final c = widget.controller ?? _create(widget.source!);
    _controller = c;
    c.addListener(_onValue);
    _initialize(c);
  }

  VideoPlayerController _create(String source) {
    final s = source.trim();
    if (s.startsWith('http://') || s.startsWith('https://')) return VideoPlayerController.networkUrl(Uri.parse(s));
    return VideoPlayerController.asset(s);
  }

  Future<void> _initialize(VideoPlayerController c) async {
    try {
      if (!c.value.isInitialized) await c.initialize();
      if (!mounted || c != _controller) return;
      await c.setLooping(widget.loop);
      await c.setVolume(widget.muted ? 0 : 1);
      if (widget.autoPlay) await c.play();
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted && c == _controller) setState(() => _error = e);
    }
  }

  void _tearDown(bool dispose) {
    final c = _controller;
    _controller = null;
    if (c == null) return;
    c.removeListener(_onValue);
    if (dispose) c.dispose();
  }

  void _onValue() {
    if (!mounted) return;
    final v = _controller?.value;
    if (v != null && v.hasError && _error == null) {
      setState(() => _error = v.errorDescription);
    } else {
      setState(() {});
    }
  }

  void _retry() {
    _tearDown(_owns);
    setState(_setUp);
  }

  Future<void> _openFullscreen() async {
    final c = _controller;
    if (c == null) return;
    await Navigator.of(context).push<void>(
      PageRouteBuilder<void>(
        transitionDuration: context.motion(UiMotion.normal),
        reverseTransitionDuration: context.motion(UiMotion.normal),
        pageBuilder: (context, _, _) => _UiFullscreenVideo(controller: c),
        transitionsBuilder: (context, animation, _, child) => FadeTransition(opacity: animation, child: child),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final value = c?.value;
    final ready = value != null && value.isInitialized && _error == null;
    final ratio = widget.aspectRatio ?? (ready && value.aspectRatio > 0 ? value.aspectRatio : 16 / 9);

    return AspectRatio(
      aspectRatio: ratio,
      child: ClipRRect(
        borderRadius: UiRadius.all(widget.radius),
        child: ColoredBox(
          color: Colors.black,
          child: _error != null
              ? _UiVideoError(onRetry: _retry)
              : !ready
              ? const _UiVideoSpinner()
              : _UiVideoSurface(
                  controller: c!,
                  controls: widget.controls,
                  onFullscreen: widget.allowFullscreen ? _openFullscreen : null,
                ),
        ),
      ),
    );
  }
}

/// Video frame + controls overlay, shared by inline and fullscreen modes.
class _UiVideoSurface extends StatefulWidget {
  const _UiVideoSurface({required this.controller, required this.controls, this.onFullscreen, this.fullscreen = false});

  final VideoPlayerController controller;
  final bool controls;
  final VoidCallback? onFullscreen;
  final bool fullscreen;

  @override
  State<_UiVideoSurface> createState() => _UiVideoSurfaceState();
}

class _UiVideoSurfaceState extends State<_UiVideoSurface> {
  bool _visible = true;
  Timer? _hide;

  VideoPlayerController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _c.addListener(_onValue);
    _scheduleHide();
  }

  @override
  void didUpdateWidget(_UiVideoSurface old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onValue);
      widget.controller.addListener(_onValue);
    }
  }

  @override
  void dispose() {
    _hide?.cancel();
    _c.removeListener(_onValue);
    super.dispose();
  }

  bool _wasPlaying = false;

  void _onValue() {
    if (!mounted) return;
    final playing = _c.value.isPlaying;
    if (playing != _wasPlaying) {
      _wasPlaying = playing;
      if (playing) {
        _scheduleHide();
      } else {
        _hide?.cancel();
        setState(() => _visible = true);
        return;
      }
    }
    setState(() {});
  }

  void _scheduleHide() {
    _hide?.cancel();
    if (!_c.value.isPlaying) return;
    _hide = Timer(const Duration(seconds: 3), () {
      if (mounted && _c.value.isPlaying) setState(() => _visible = false);
    });
  }

  void _poke() {
    setState(() => _visible = true);
    _scheduleHide();
  }

  void _togglePlay() {
    final v = _c.value;
    if (v.isPlaying) {
      _c.pause();
    } else {
      if (v.isCompleted || (v.duration > Duration.zero && v.position >= v.duration)) _c.seekTo(Duration.zero);
      _c.play();
    }
    _poke();
  }

  void _toggleMute() {
    _c.setVolume(_c.value.volume > 0 ? 0 : 1);
    _poke();
  }

  @override
  Widget build(BuildContext context) {
    final v = _c.value;
    final video = Center(
      child: AspectRatio(aspectRatio: v.aspectRatio > 0 ? v.aspectRatio : 16 / 9, child: VideoPlayer(_c)),
    );
    if (!widget.controls) {
      return Stack(fit: StackFit.expand, children: [video, if (v.isBuffering) const _UiVideoSpinner()]);
    }
    final duration = context.motion(UiMotion.normal);
    final ended = !v.isPlaying && v.duration > Duration.zero && v.position >= v.duration;
    final text = context.text.labelSmall?.copyWith(
      color: Colors.white,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _visible ? setState(() => _visible = false) : _poke(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          video,
          if (v.isBuffering) const _UiVideoSpinner(),
          IgnorePointer(
            ignoring: !_visible,
            child: AnimatedOpacity(
              opacity: _visible ? 1 : 0,
              duration: duration,
              curve: UiMotion.standard,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.5, 1],
                        colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: 0.6)],
                      ),
                    ),
                  ),
                  Center(
                    child: _UiRoundButton(
                      size: 56,
                      icon: ended
                          ? Icons.replay_rounded
                          : v.isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      tooltip: v.isPlaying ? 'Pause' : 'Play',
                      onPressed: _togglePlay,
                    ),
                  ),
                  Positioned(
                    left: UiSpace.sm,
                    right: UiSpace.xs,
                    bottom: UiSpace.xs,
                    child: SafeArea(
                      top: false,
                      left: widget.fullscreen,
                      right: widget.fullscreen,
                      bottom: widget.fullscreen,
                      child: Row(
                        children: [
                          const SizedBox(width: UiSpace.xs),
                          Text(_format(v.position), style: text),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm),
                              child: _UiScrubber(controller: _c, onInteract: _poke),
                            ),
                          ),
                          Text(_format(v.duration), style: text?.copyWith(color: Colors.white70)),
                          _UiIconAction(
                            icon: v.volume > 0 ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                            tooltip: v.volume > 0 ? 'Mute' : 'Unmute',
                            onPressed: _toggleMute,
                          ),
                          if (widget.onFullscreen != null)
                            _UiIconAction(
                              icon: widget.fullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                              tooltip: widget.fullscreen ? 'Exit fullscreen' : 'Fullscreen',
                              onPressed: widget.onFullscreen!,
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _format(Duration d) {
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return h > 0 ? '$h:${m.toString().padLeft(2, '0')}:$s' : '$m:$s';
}

class _UiScrubber extends StatefulWidget {
  const _UiScrubber({required this.controller, required this.onInteract});

  final VideoPlayerController controller;
  final VoidCallback onInteract;

  @override
  State<_UiScrubber> createState() => _UiScrubberState();
}

class _UiScrubberState extends State<_UiScrubber> {
  double? _drag;

  double _fraction(Offset local, double width) => width <= 0 ? 0 : (local.dx / width).clamp(0.0, 1.0);

  void _seek(double f) {
    final total = widget.controller.value.duration;
    widget.controller.seekTo(total * f);
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.controller.value;
    final total = v.duration.inMilliseconds;
    final played = total <= 0 ? 0.0 : (v.position.inMilliseconds / total).clamp(0.0, 1.0);
    var buffered = 0.0;
    if (total > 0) {
      for (final r in v.buffered) {
        buffered = (r.end.inMilliseconds / total).clamp(buffered, 1.0);
      }
    }
    final accent = context.colors.accent;
    return LayoutBuilder(
      builder: (context, c) => Semantics(
        slider: true,
        label: 'Seek',
        value: '${(played * 100).round()}%',
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (d) {
            _seek(_fraction(d.localPosition, c.maxWidth));
            widget.onInteract();
          },
          onHorizontalDragStart: (d) => setState(() => _drag = _fraction(d.localPosition, c.maxWidth)),
          onHorizontalDragUpdate: (d) {
            setState(() => _drag = _fraction(d.localPosition, c.maxWidth));
            widget.onInteract();
          },
          onHorizontalDragEnd: (_) {
            if (_drag != null) _seek(_drag!);
            setState(() => _drag = null);
          },
          onHorizontalDragCancel: () => setState(() => _drag = null),
          child: SizedBox(
            height: 40,
            width: double.infinity,
            child: CustomPaint(
              painter: _ScrubberPainter(
                played: _drag ?? played,
                buffered: buffered,
                active: _drag != null,
                color: accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScrubberPainter extends CustomPainter {
  _ScrubberPainter({required this.played, required this.buffered, required this.active, required this.color});

  final double played;
  final double buffered;
  final bool active;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final h = active ? 5.0 : 3.0;
    final y = size.height / 2;
    final r = Radius.circular(h / 2);
    RRect bar(double f) => RRect.fromLTRBR(0, y - h / 2, size.width * f, y + h / 2, r);
    canvas.drawRRect(bar(1), Paint()..color = Colors.white.withValues(alpha: 0.25));
    canvas.drawRRect(bar(buffered), Paint()..color = Colors.white.withValues(alpha: 0.4));
    canvas.drawRRect(bar(played), Paint()..color = color);
    canvas.drawCircle(Offset(size.width * played, y), active ? 8 : 6, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_ScrubberPainter old) =>
      old.played != played || old.buffered != buffered || old.active != active || old.color != color;
}

class _UiRoundButton extends StatelessWidget {
  const _UiRoundButton({required this.icon, required this.tooltip, required this.onPressed, this.size = 48});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.black.withValues(alpha: 0.45),
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: SizedBox.square(
              dimension: size,
              child: Icon(
                icon,
                color: Colors.white.withValues(alpha: onPressed == null ? 0.5 : 1),
                size: size * 0.55,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UiIconAction extends StatelessWidget {
  const _UiIconAction({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    tooltip: tooltip,
    icon: Icon(icon, color: Colors.white, size: 20),
    constraints: const BoxConstraints.tightFor(width: 40, height: 40),
    padding: EdgeInsets.zero,
  );
}

class _UiVideoSpinner extends StatelessWidget {
  const _UiVideoSpinner();

  @override
  Widget build(BuildContext context) => const Center(
    child: SizedBox.square(dimension: 28, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
  );
}

class _UiVideoError extends StatelessWidget {
  const _UiVideoError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final muted = Colors.white.withValues(alpha: 0.7);
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Padding(
          padding: const EdgeInsets.all(UiSpace.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, color: muted, size: 32),
              const SizedBox(height: UiSpace.sm),
              Text('Video unavailable', style: context.text.titleSmall?.copyWith(color: Colors.white)),
              const SizedBox(height: UiSpace.md),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(borderRadius: UiRadius.all(UiRadius.full)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UiFullscreenVideo extends StatelessWidget {
  const _UiFullscreenVideo({required this.controller});

  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: _UiVideoSurface(
      controller: controller,
      controls: true,
      fullscreen: true,
      onFullscreen: () => Navigator.of(context).maybePop(),
    ),
  );
}

/// Video preview: an image with a play badge and an optional duration chip.
///
/// ```dart
/// UiVideoThumbnail('https://example.com/poster.jpg', duration: const Duration(minutes: 3, seconds: 12), onTap: play)
/// ```
class UiVideoThumbnail extends StatelessWidget {
  const UiVideoThumbnail(
    this.image, {
    super.key,
    this.duration,
    this.onTap,
    this.aspectRatio = 16 / 9,
    this.radius = UiRadius.lg,
    this.semanticLabel,
  });

  /// URL / asset path `String` or an [ImageProvider].
  final Object image;

  /// Shown in a chip at the bottom right.
  final Duration? duration;

  /// Null disables the thumbnail.
  final VoidCallback? onTap;
  final double aspectRatio;
  final double radius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Semantics(
      button: enabled,
      enabled: enabled,
      label: semanticLabel ?? 'Play video',
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: ClipRRect(
          borderRadius: UiRadius.all(radius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              UiImage.provider(UiImage.resolve(image)),
              Center(
                child: Opacity(
                  opacity: enabled ? 1 : 0.5,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(UiSpace.md),
                      child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                    ),
                  ),
                ),
              ),
              if (duration != null)
                Positioned(
                  right: UiSpace.sm,
                  bottom: UiSpace.sm,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: UiRadius.all(UiRadius.xs),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: UiSpace.xs + 2, vertical: UiSpace.xxs),
                      child: Text(
                        _format(duration!),
                        style: context.text.labelSmall?.copyWith(
                          color: Colors.white,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                ),
              if (enabled)
                Material(
                  type: MaterialType.transparency,
                  child: InkWell(onTap: onTap),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
