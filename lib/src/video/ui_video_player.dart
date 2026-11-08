import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'package:theme/src/foundation/tokens.dart';
import 'package:theme/src/foundation/ui_context.dart';
import 'package:theme/src/foundation/ui_format.dart';
import 'package:theme/src/image/ui_image.dart';

@immutable
class _Opts {
  const _Opts({
    required this.poster,
    required this.showControls,
    required this.allowFullscreen,
    required this.speeds,
    required this.skip,
    required this.autoHide,
  });

  final String? poster;
  final bool showControls;
  final bool allowFullscreen;
  final List<double> speeds;
  final Duration skip;
  final Duration autoHide;
}

class UiVideoPlayer extends StatefulWidget {
  const UiVideoPlayer(
    String this.src, {
    super.key,
    this.autoplay = false,
    this.loop = false,
    this.muted = false,
    this.aspectRatio,
    this.poster,
    this.showControls = true,
    this.allowFullscreen = true,
    this.speeds = const [0.5, 0.75, 1, 1.25, 1.5, 2],
    this.skip = const Duration(seconds: 10),
    this.autoHide = const Duration(seconds: 3),
    this.radius,
    this.httpHeaders = const {},
    this.onEnded,
    this.onError,
  }) : controller = null;

  const UiVideoPlayer.controller(
    VideoPlayerController this.controller, {
    super.key,
    this.autoplay = false,
    this.loop = false,
    this.muted = false,
    this.aspectRatio,
    this.poster,
    this.showControls = true,
    this.allowFullscreen = true,
    this.speeds = const [0.5, 0.75, 1, 1.25, 1.5, 2],
    this.skip = const Duration(seconds: 10),
    this.autoHide = const Duration(seconds: 3),
    this.radius,
    this.onEnded,
    this.onError,
  })  : src = null,
        httpHeaders = const {};

  final String? src;
  final VideoPlayerController? controller;
  final bool autoplay;
  final bool loop;
  final bool muted;
  final double? aspectRatio;
  final String? poster;
  final bool showControls;
  final bool allowFullscreen;
  final List<double> speeds;
  final Duration skip;
  final Duration autoHide;
  final BorderRadius? radius;
  final Map<String, String> httpHeaders;
  final VoidCallback? onEnded;
  final ValueChanged<Object>? onError;

  @override
  State<UiVideoPlayer> createState() => _UiVideoPlayerState();
}

class _UiVideoPlayerState extends State<UiVideoPlayer> {
  VideoPlayerController? _own;
  Object? _initError;
  bool _ready = false;
  bool _failed = false;
  bool _ended = false;

  VideoPlayerController get _c => widget.controller ?? _own!;

  _Opts get _opts => _Opts(
        poster: widget.poster,
        showControls: widget.showControls,
        allowFullscreen: widget.allowFullscreen,
        speeds: widget.speeds,
        skip: widget.skip,
        autoHide: widget.autoHide,
      );

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void didUpdateWidget(UiVideoPlayer old) {
    super.didUpdateWidget(old);
    if (old.src != widget.src || old.controller != widget.controller) {
      _teardown(old.controller);
      _setup();
    } else if (old.loop != widget.loop && _ready) {
      _c.setLooping(widget.loop);
    }
  }

  @override
  void dispose() {
    _teardown(widget.controller);
    super.dispose();
  }

  void _setup() {
    _initError = null;
    _ended = false;
    if (widget.controller == null) {
      final s = widget.src!.trim();
      _own = s.startsWith('http://') || s.startsWith('https://')
          ? VideoPlayerController.networkUrl(Uri.parse(s), httpHeaders: widget.httpHeaders)
          : VideoPlayerController.asset(s);
    }
    _c.addListener(_tick);
    _ready = _c.value.isInitialized;
    _failed = _c.value.hasError;
    if (_ready) {
      _apply();
    } else {
      _init();
    }
  }

  void _teardown(VideoPlayerController? external) {
    (external ?? _own)?.removeListener(_tick);
    _own?.dispose();
    _own = null;
  }

  Future<void> _init() async {
    final c = _c;
    try {
      await c.initialize();
      if (!mounted || c != _c) return;
      _apply();
    } catch (e) {
      if (!mounted || c != _c) return;
      setState(() => _initError = e);
      widget.onError?.call(e);
    }
  }

  void _apply() {
    _c.setLooping(widget.loop);
    if (widget.muted) _c.setVolume(0);
    if (widget.autoplay) _c.play();
    if (mounted) setState(() => _ready = true);
  }

  void _tick() {
    final v = _c.value;
    if (v.hasError != _failed) {
      _failed = v.hasError;
      if (v.hasError) widget.onError?.call(v.errorDescription ?? 'Playback error');
      if (mounted) setState(() {});
    }
    if (v.isInitialized != _ready && mounted) setState(() => _ready = v.isInitialized);
    final ended = v.isInitialized && !v.isLooping && v.duration > Duration.zero && v.position >= v.duration && !v.isPlaying;
    if (ended && !_ended) widget.onEnded?.call();
    _ended = ended;
  }

  void _retry() {
    if (widget.controller != null) {
      setState(() => _initError = null);
      _init();
      return;
    }
    _teardown(null);
    _setup();
    setState(() {});
  }

  Future<void> _fullscreen() async {
    final v = _c.value;
    final nav = Navigator.of(context, rootNavigator: true);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    if (v.aspectRatio >= 1) {
      await SystemChrome.setPreferredOrientations(const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
    if (!mounted) return;
    await nav.push(
      PageRouteBuilder<void>(
        transitionDuration: UiDuration.normal,
        reverseTransitionDuration: UiDuration.normal,
        pageBuilder: (ctx, _, _) => Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: AspectRatio(
              aspectRatio: v.aspectRatio > 0 ? v.aspectRatio : 16 / 9,
              child: _VideoSurface(controller: _c, opts: _opts, fullscreen: true, onFullscreen: () => Navigator.pop(ctx)),
            ),
          ),
        ),
        transitionsBuilder: (_, a, _, child) => FadeTransition(opacity: a, child: child),
      ),
    );
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations(const []);
  }

  @override
  Widget build(BuildContext context) {
    final v = _c.value;
    final ar = widget.aspectRatio ?? (_ready && v.aspectRatio > 0 ? v.aspectRatio : 16 / 9);
    final Widget body = _initError != null || _failed
        ? _ErrorView(onRetry: _retry)
        : _VideoSurface(
            controller: _c,
            opts: _opts,
            fullscreen: false,
            onFullscreen: widget.allowFullscreen ? _fullscreen : null,
          );
    return ClipRRect(
      borderRadius: widget.radius ?? context.tokens.lg,
      child: ColoredBox(color: Colors.black, child: AspectRatio(aspectRatio: ar, child: body)),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white70, size: 36),
            const UiGap.sm(),
            Text('Video could not be played', style: context.text.bodyMedium?.copyWith(color: Colors.white)),
            const UiGap.sm(),
            OutlinedButton.icon(
              onPressed: onRetry,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: const BorderSide(color: Colors.white54)),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
}

class _VideoSurface extends StatefulWidget {
  const _VideoSurface({required this.controller, required this.opts, required this.fullscreen, required this.onFullscreen});

  final VideoPlayerController controller;
  final _Opts opts;
  final bool fullscreen;
  final VoidCallback? onFullscreen;

  @override
  State<_VideoSurface> createState() => _VideoSurfaceState();
}

class _VideoSurfaceState extends State<_VideoSurface> {
  bool _visible = true;
  bool _started = false;
  bool _dragging = false;
  double? _drag;
  int _flash = 0;
  double _tapX = 0;
  double _lastVolume = 1;
  Timer? _hideTimer;
  Timer? _flashTimer;

  VideoPlayerController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    _started = _c.value.isPlaying || _c.value.position > Duration.zero;
    _c.addListener(_tick);
    _scheduleHide();
  }

  @override
  void didUpdateWidget(_VideoSurface old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_tick);
      _c.addListener(_tick);
    }
  }

  @override
  void dispose() {
    _c.removeListener(_tick);
    _hideTimer?.cancel();
    _flashTimer?.cancel();
    super.dispose();
  }

  void _tick() {
    if (!mounted) return;
    if (_c.value.isPlaying && !_started) _started = true;
    setState(() {});
  }

  bool get _completed {
    final v = _c.value;
    return v.isInitialized && v.duration > Duration.zero && v.position >= v.duration && !v.isPlaying;
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (widget.opts.autoHide <= Duration.zero) return;
    _hideTimer = Timer(widget.opts.autoHide, () {
      if (mounted && _c.value.isPlaying && !_dragging) setState(() => _visible = false);
    });
  }

  void _show() {
    if (!_visible) setState(() => _visible = true);
    _scheduleHide();
  }

  void _toggleControls() {
    setState(() => _visible = !_visible);
    if (_visible) _scheduleHide();
  }

  Future<void> _playPause() async {
    if (!_c.value.isInitialized) return;
    if (_c.value.isPlaying) {
      await _c.pause();
    } else {
      if (_completed) await _c.seekTo(Duration.zero);
      _started = true;
      await _c.play();
    }
    _show();
  }

  void _seekBy(Duration d) {
    final v = _c.value;
    if (!v.isInitialized) return;
    var t = v.position + d;
    if (t < Duration.zero) t = Duration.zero;
    if (t > v.duration) t = v.duration;
    _c.seekTo(t);
    _flashTimer?.cancel();
    setState(() => _flash = d.isNegative ? -1 : 1);
    _flashTimer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _flash = 0);
    });
    _show();
  }

  void _toggleMute() {
    final vol = _c.value.volume;
    if (vol > 0) {
      _lastVolume = vol;
      _c.setVolume(0);
    } else {
      _c.setVolume(_lastVolume <= 0 ? 1 : _lastVolume);
    }
    _show();
  }

  String _speedLabel(double s) => '${s == s.roundToDouble() ? s.toInt() : s}x';

  Widget _round(IconData icon, String tip, VoidCallback onTap, {double size = 28}) => Semantics(
        button: true,
        label: tip,
        child: Material(
          color: Colors.black38,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(padding: EdgeInsets.all(size * 0.35), child: Icon(icon, size: size, color: Colors.white)),
          ),
        ),
      );

  Widget _controls(BuildContext context, VideoPlayerValue v) {
    final total = v.duration.inMilliseconds.toDouble();
    final max = total > 0 ? total : 1.0;
    final pos = (_drag ?? v.position.inMilliseconds.toDouble()).clamp(0.0, max);
    final buffered = v.buffered.isEmpty ? 0.0 : v.buffered.last.end.inMilliseconds.toDouble().clamp(0.0, max);
    final skipS = widget.opts.skip.inSeconds;
    final label = context.text.labelMedium?.copyWith(color: Colors.white, fontFeatures: const [FontFeature.tabularFigures()]);
    final playing = v.isPlaying;
    final muted = v.volume <= 0;
    return Stack(
      fit: StackFit.expand,
      children: [
        const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.black26, Colors.transparent, Colors.transparent, Colors.black54],
                stops: [0, 0.3, 0.6, 1],
              ),
            ),
          ),
        ),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _round(skipS == 10 ? Icons.replay_10_rounded : Icons.replay_rounded, 'Back $skipS seconds', () => _seekBy(-widget.opts.skip), size: 24),
              const SizedBox(width: UiSpace.xxl),
              if (v.isBuffering && playing)
                const SizedBox.square(dimension: 56, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
              else
                _round(
                  _completed ? Icons.replay_rounded : (playing ? Icons.pause_rounded : Icons.play_arrow_rounded),
                  _completed ? 'Replay' : (playing ? 'Pause' : 'Play'),
                  _playPause,
                  size: 36,
                ),
              const SizedBox(width: UiSpace.xxl),
              _round(skipS == 10 ? Icons.forward_10_rounded : Icons.forward_rounded, 'Forward $skipS seconds', () => _seekBy(widget.opts.skip), size: 24),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(UiSpace.md, 0, UiSpace.xs, UiSpace.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text('${UiFormat.duration(Duration(milliseconds: pos.round()))} / ${UiFormat.duration(v.duration)}', style: label),
                    const Spacer(),
                    PopupMenuButton<double>(
                      tooltip: 'Playback speed',
                      initialValue: v.playbackSpeed,
                      onOpened: _hideTimer?.cancel,
                      onCanceled: _scheduleHide,
                      onSelected: (s) {
                        _c.setPlaybackSpeed(s);
                        _scheduleHide();
                      },
                      itemBuilder: (_) => [for (final s in widget.opts.speeds) PopupMenuItem(value: s, child: Text(_speedLabel(s)))],
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: UiSpace.sm),
                        child: Text(_speedLabel(v.playbackSpeed), style: label?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    IconButton(
                      tooltip: muted ? 'Unmute' : 'Mute',
                      onPressed: _toggleMute,
                      color: Colors.white,
                      icon: Icon(muted ? Icons.volume_off_rounded : (v.volume < 0.5 ? Icons.volume_down_rounded : Icons.volume_up_rounded)),
                    ),
                    LayoutBuilder(
                      builder: (context, c) => MediaQuery.sizeOf(context).width < 480
                          ? const SizedBox.shrink()
                          : SizedBox(
                              width: 96,
                              child: _thinSlider(
                                context,
                                value: v.volume.clamp(0.0, 1.0),
                                max: 1,
                                label: 'Volume',
                                onChanged: (x) {
                                  _c.setVolume(x);
                                  _show();
                                },
                              ),
                            ),
                    ),
                    if (widget.onFullscreen != null)
                      IconButton(
                        tooltip: widget.fullscreen ? 'Exit full screen' : 'Full screen',
                        onPressed: widget.onFullscreen,
                        color: Colors.white,
                        icon: Icon(widget.fullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded),
                      ),
                  ],
                ),
                _thinSlider(
                  context,
                  value: pos,
                  max: max,
                  secondary: buffered,
                  label: 'Seek',
                  semanticValue: UiFormat.duration(Duration(milliseconds: pos.round())),
                  onChangeStart: (_) {
                    _dragging = true;
                    _hideTimer?.cancel();
                  },
                  onChanged: v.isInitialized ? (x) => setState(() => _drag = x) : null,
                  onChangeEnd: (x) async {
                    await _c.seekTo(Duration(milliseconds: x.round()));
                    if (!mounted) return;
                    setState(() {
                      _dragging = false;
                      _drag = null;
                    });
                    _scheduleHide();
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _thinSlider(
    BuildContext context, {
    required double value,
    required double max,
    required String label,
    double? secondary,
    String? semanticValue,
    ValueChanged<double>? onChanged,
    ValueChanged<double>? onChangeStart,
    ValueChanged<double>? onChangeEnd,
  }) {
    final p = context.colors.primary;
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 3,
        padding: const EdgeInsets.symmetric(horizontal: UiSpace.sm, vertical: UiSpace.sm),
        activeTrackColor: p,
        inactiveTrackColor: Colors.white24,
        secondaryActiveTrackColor: Colors.white54,
        thumbColor: p,
        overlayColor: p.withValues(alpha: 0.2),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
      ),
      child: Slider(
        value: value.clamp(0, max),
        max: max,
        secondaryTrackValue: secondary,
        onChanged: onChanged,
        onChangeStart: onChangeStart,
        onChangeEnd: onChangeEnd,
        semanticFormatterCallback: semanticValue == null ? null : (_) => semanticValue,
        label: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final v = _c.value;
    final poster = widget.opts.poster;
    final showUi = widget.opts.showControls && (_visible || !v.isPlaying);
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: v.isInitialized
              ? AspectRatio(aspectRatio: v.aspectRatio > 0 ? v.aspectRatio : 16 / 9, child: VideoPlayer(_c))
              : const SizedBox.shrink(),
        ),
        if (!_started && poster != null && poster.trim().isNotEmpty) UiImage(poster),
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.opts.showControls ? _toggleControls : _playPause,
            onDoubleTapDown: (d) => _tapX = d.localPosition.dx,
            onDoubleTap: () {
              final w = context.size?.width ?? 0;
              _seekBy(_tapX < w / 2 ? -widget.opts.skip : widget.opts.skip);
            },
          ),
        ),
        if (!v.isInitialized || (v.isBuffering && !showUi))
          const Center(child: SizedBox.square(dimension: 40, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))),
        if (_flash != 0)
          IgnorePointer(
            child: Align(
              alignment: _flash < 0 ? const Alignment(-0.6, 0) : const Alignment(0.6, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: UiSpace.md, vertical: UiSpace.sm),
                decoration: BoxDecoration(color: Colors.black54, borderRadius: context.tokens.full),
                child: Text(
                  '${_flash < 0 ? '−' : '+'}${widget.opts.skip.inSeconds}s',
                  style: context.text.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
        if (widget.opts.showControls && v.isInitialized)
          IgnorePointer(
            ignoring: !showUi,
            child: AnimatedOpacity(opacity: showUi ? 1 : 0, duration: UiDuration.normal, child: _controls(context, v)),
          ),
      ],
    );
  }
}

class UiVideoThumbnail extends StatelessWidget {
  const UiVideoThumbnail({
    super.key,
    required this.image,
    this.duration,
    this.title,
    this.onTap,
    this.aspectRatio = 16 / 9,
    this.radius,
  });

  final String? image;
  final Duration? duration;
  final String? title;
  final VoidCallback? onTap;
  final double aspectRatio;
  final BorderRadius? radius;

  @override
  Widget build(BuildContext context) {
    final r = radius ?? context.tokens.lg;
    return Semantics(
      button: onTap != null,
      label: ['Play video', ?title, if (duration != null) UiFormat.duration(duration!)].join(', '),
      excludeSemantics: true,
      child: ClipRRect(
        borderRadius: r,
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Material(
            color: Colors.black,
            child: InkWell(
              onTap: onTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  UiImage(image, width: double.infinity, height: double.infinity, placeholderIcon: Icons.movie_outlined),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                        stops: [0.5, 1],
                      ),
                    ),
                  ),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(UiSpace.md),
                      decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
                    ),
                  ),
                  if (title != null)
                    Positioned(
                      left: UiSpace.md,
                      right: duration == null ? UiSpace.md : 72,
                      bottom: UiSpace.md,
                      child: Text(
                        title!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.titleSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  if (duration != null)
                    Positioned(
                      right: UiSpace.sm,
                      bottom: UiSpace.sm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: Colors.black87, borderRadius: context.tokens.xs),
                        child: Text(
                          UiFormat.duration(duration!),
                          style: context.text.labelSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
