import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';

/// Maps the data level string to the card enum.
UiWorkoutLevel workoutLevel(String level) => switch (level) {
      'advanced' => UiWorkoutLevel.advanced,
      'intermediate' => UiWorkoutLevel.intermediate,
      _ => UiWorkoutLevel.beginner,
    };

UiStatus _levelStatus(String level) => switch (level) {
      'advanced' => UiStatus.danger,
      'intermediate' => UiStatus.warning,
      _ => UiStatus.success,
    };

String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// Workout detail: coach, stats, technique video, exercises, sets, timers, and rating.
class PulseWorkoutPage extends StatefulWidget {
  const PulseWorkoutPage({super.key, required this.workout});

  final Workout workout;

  @override
  State<PulseWorkoutPage> createState() => _PulseWorkoutPageState();
}

class _PulseWorkoutPageState extends State<PulseWorkoutPage> {
  final Set<int> _done = {};
  double _effort = 0;
  int _restKey = 0;
  Duration _elapsed = Duration.zero;

  Workout get _w => widget.workout;

  String _detail(Exercise e) => switch (e.unit) {
        's' => '${e.sets} × ${e.reps} s',
        'min' => '${e.sets} × ${e.reps} min',
        _ => '${e.sets} × ${e.reps} reps',
      };

  Future<void> _finish() async {
    final mins = _elapsed.inMinutes > 0 ? _elapsed.inMinutes : _w.minutes;
    await UiDialog.success(
      context,
      title: 'Workout complete',
      message: 'Great job! You finished ${_done.length} of ${_w.exercises.length} exercises in $mins min and burned about ${_w.calories} kcal.',
      buttonLabel: 'Back to plans',
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final strength = _w.exercises.where((e) => e.unit == 'reps').firstOrNull;

    return Scaffold(
      appBar: UiAppBar(title: _w.title, subtitle: 'With ${_w.coach.name}'),
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 900;
          final main = <Widget>[
            _header(context),
            const UiGap.lg(),
            _stats(),
            const UiGap.xxl(),
            UiSection(
              title: 'Technique preview',
              subtitle: 'Watch the form before you start',
              child: UiVideoPlayer(PulseAssets.bee, poster: _w.image, aspectRatio: 16 / 9, muted: true),
            ),
            UiSection(
              title: 'Exercises',
              subtitle: '${_done.length} of ${_w.exercises.length} done',
              child: Column(
                children: [
                  for (final (i, e) in _w.exercises.indexed)
                    UiExerciseTile(
                      name: e.name,
                      detail: _detail(e),
                      done: _done.contains(i),
                      onDoneChanged: (v) => setState(() => v ? _done.add(i) : _done.remove(i)),
                    ),
                ],
              ),
            ),
          ];
          final side = <Widget>[
            if (strength != null)
              UiSection(
                title: 'Log sets',
                subtitle: strength.name,
                child: UiSetTracker(
                  initial: [for (var s = 0; s < strength.sets; s++) (weight: null, reps: strength.reps, done: false)],
                  previous: [for (var s = 0; s < strength.sets; s++) '20 kg × ${strength.reps}'],
                  onChanged: (_) {},
                ),
              ),
            UiSection(
              title: 'Timers',
              child: Wrap(
                spacing: UiSpace.xxl,
                runSpacing: UiSpace.lg,
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  UiWorkoutTimer(label: 'Workout', onChanged: (d) => _elapsed = d),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UiRestTimer(
                        key: ValueKey(_restKey),
                        duration: const Duration(seconds: 60),
                        autoStart: false,
                        size: 180,
                        onDone: () => context.showToast('Rest is over. Next set!', status: UiStatus.success),
                      ),
                      UiButton.ghost('Reset rest', icon: Icons.replay_rounded, onPressed: () => setState(() => _restKey++)),
                    ],
                  ),
                ],
              ),
            ),
            UiSection(
              title: 'How hard was it?',
              subtitle: _effortText,
              child: Center(child: UiRatingInput(value: _effort, onChanged: (v) => setState(() => _effort = v))),
            ),
            UiButton('Finish workout', icon: Icons.flag_rounded, expand: true, onPressed: _finish),
          ];

          if (!wide) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.sm, UiSpace.lg, UiSpace.huge),
              children: [...main, ...side],
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(UiSpace.xxl, UiSpace.sm, UiSpace.xxl, UiSpace.huge),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: main)),
                const UiGap.xxl(),
                Expanded(flex: 2, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: side)),
              ],
            ),
          );
        },
      ),
    );
  }

  String get _effortText => switch (_effort.round()) {
        0 => 'Tap the stars to rate the effort',
        1 => 'Very easy',
        2 => 'Easy',
        3 => 'Just right',
        4 => 'Hard',
        _ => 'Very hard',
      };

  Widget _header(BuildContext context) {
    final coach = _w.coach;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiImage(_w.image, aspectRatio: 16 / 9, radius: BorderRadius.circular(context.tokens.radiusLg), semanticLabel: _w.title),
        const UiGap.lg(),
        Row(
          children: [
            UiAvatar(name: coach.name, imageUrl: coach.avatar, size: 48, ring: coach.verified),
            const UiGap.md(),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          coach.name,
                          overflow: TextOverflow.ellipsis,
                          style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (coach.verified) ...[
                        const UiGap.xs(),
                        Icon(Icons.verified_rounded, size: 18, color: context.colors.primary),
                      ],
                    ],
                  ),
                  Text(
                    'Coach · ${coach.handle}',
                    overflow: TextOverflow.ellipsis,
                    style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            UiTag(_capitalize(_w.level), status: _levelStatus(_w.level), icon: Icons.bolt_rounded),
          ],
        ),
      ],
    );
  }

  Widget _stats() {
    final sets = _w.exercises.fold<int>(0, (a, e) => a + e.sets);
    return Column(
      children: [
        UiResponsiveGrid(
          minItemWidth: 140,
          children: [
            UiInfoTile(icon: Icons.timer_outlined, title: 'Time', value: '${_w.minutes} min'),
            UiInfoTile(icon: Icons.local_fire_department_rounded, title: 'Calories', value: '${_w.calories} kcal', status: UiStatus.warning),
            UiInfoTile(icon: Icons.fitness_center_rounded, title: 'Exercises', value: '${_w.exercises.length}', status: UiStatus.info),
          ],
        ),
        const UiGap.md(),
        UiKeyValue('Total sets', '$sets', icon: Icons.format_list_numbered_rounded),
        const UiKeyValue('Equipment', 'Mat, dumbbells', icon: Icons.sports_gymnastics_rounded),
        const UiKeyValue('Rest between sets', '60 s', icon: Icons.hourglass_bottom_rounded),
      ],
    );
  }
}
