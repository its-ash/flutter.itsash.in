import 'dart:io' show File;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

enum ThemeVideoSourceType { network, asset, file }

class ThemeVideoPlayer extends StatefulWidget {
  const ThemeVideoPlayer({
    super.key,
    required this.source,
    this.sourceType = ThemeVideoSourceType.network,
    this.autoPlay = false,
    this.looping = false,
    this.showControls = true,
    this.aspectRatio,
    this.borderRadius,
  });

  final String source;
  final ThemeVideoSourceType sourceType;
  final bool autoPlay;
  final bool looping;
  final bool showControls;
  final double? aspectRatio;

  /// Corner radius for the player surface. Defaults to the active theme's
  /// card radius (`Theme.of(context).cardTheme.shape`) — pass an explicit
  /// value to opt out.
  final double? borderRadius;

  @override
  State<ThemeVideoPlayer> createState() => _ThemeVideoPlayerState();
}

class _ThemeVideoPlayerState extends State<ThemeVideoPlayer> {
  late final VideoPlayerController _controller;
  late Future<void> _initialize;

  @override
  void initState() {
    super.initState();
    _controller = switch (widget.sourceType) {
      ThemeVideoSourceType.network => VideoPlayerController.networkUrl(Uri.parse(widget.source)),
      ThemeVideoSourceType.asset => VideoPlayerController.asset(widget.source),
      ThemeVideoSourceType.file => VideoPlayerController.file(File(widget.source)),
    };
    _controller.setLooping(widget.looping);
    _initialize = _controller.initialize().then((_) {
      if (widget.autoPlay && mounted) _controller.play();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _radius(BuildContext context) {
    if (widget.borderRadius != null) return widget.borderRadius!;
    final shape = Theme.of(context).cardTheme.shape;
    if (shape is RoundedRectangleBorder) {
      return shape.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius(context)),
      child: FutureBuilder<void>(
        future: _initialize,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return AspectRatio(
              aspectRatio: widget.aspectRatio ?? 16 / 9,
              child: Container(
                color: scheme.surfaceContainerHigh,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
            );
          }
          return AspectRatio(
            aspectRatio: widget.aspectRatio ?? _controller.value.aspectRatio,
            child: Stack(
              alignment: Alignment.center,
              children: [
                VideoPlayer(_controller),
                if (widget.showControls) _ThemeVideoControls(controller: _controller),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ThemeVideoControls extends StatefulWidget {
  const _ThemeVideoControls({required this.controller});

  final VideoPlayerController controller;

  @override
  State<_ThemeVideoControls> createState() => _ThemeVideoControlsState();
}

class _ThemeVideoControlsState extends State<_ThemeVideoControls> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _visible = !_visible),
      child: AnimatedOpacity(
        opacity: _visible ? 1 : 0,
        duration: const Duration(milliseconds: 200),
        child: Container(
          color: Colors.black.withValues(alpha: 0.25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 48,
                color: Colors.white,
                icon: Icon(
                  widget.controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                ),
                onPressed: () {
                  setState(() {
                    widget.controller.value.isPlaying ? widget.controller.pause() : widget.controller.play();
                  });
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: VideoProgressIndicator(
                  widget.controller,
                  allowScrubbing: true,
                  colors: const VideoProgressColors(
                    playedColor: Colors.white,
                    bufferedColor: Colors.white38,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
