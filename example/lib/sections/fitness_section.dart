import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../widgets/demo_block.dart';

class FitnessSection extends StatefulWidget {
  const FitnessSection({super.key});

  @override
  State<FitnessSection> createState() => _FitnessSectionState();
}

class _FitnessSectionState extends State<FitnessSection> {
  final _done = <int>{0};
  int _water = 3;
  bool _saved = false;
  int _restKey = 0;

  static const _exercises = [
    ('Bench press', 4, 10, 60.0),
    ('Incline dumbbell press', 3, 12, 22.5),
    ('Cable fly', 3, 15, 15.0),
  ];

  @override
  Widget build(BuildContext context) {
    void tap() => toast(context, 'Tapped');
    return SectionPage(
      children: [
        const DemoBlock(
          'UiActivityRings',
          child: Wrap(
            spacing: UiSpace.xxl,
            runSpacing: UiSpace.lg,
            alignment: WrapAlignment.center,
            children: [
              UiActivityRings(
                rings: [UiActivityRing(0.8, label: 'Move'), UiActivityRing(1.2, label: 'Exercise'), UiActivityRing(0.45, label: 'Stand')],
                center: Text('80%'),
                legend: true,
              ),
              UiActivityRings(rings: [UiActivityRing(0.6, label: 'Steps')], size: 100, stroke: 12),
            ],
          ),
        ),
        DemoBlock(
          'UiMetricTile',
          child: LayoutBuilder(
            builder: (context, c) {
              final w = (c.maxWidth - UiSpace.sm) / 2;
              return WrapRow(
                children: [
                  SizedBox(width: w, child: const UiMetricTile(icon: Icons.directions_walk_rounded, value: '8,240', unit: 'steps', label: 'Today', trend: 12)),
                  SizedBox(
                    width: w,
                    child: const UiMetricTile(icon: Icons.monitor_weight_rounded, value: '72.4', unit: 'kg', label: 'Weight', trend: -1.8, trendUpIsGood: false, tonal: true),
                  ),
                  SizedBox(width: w, child: UiMetricTile(icon: Icons.bedtime_rounded, value: '7:40', unit: 'h', label: 'Sleep', onTap: tap)),
                  SizedBox(
                    width: w,
                    child: UiMetricTile(icon: Icons.local_fire_department_rounded, value: '540', unit: 'kcal', label: 'Burned', color: context.palette.sale, trend: 4),
                  ),
                ],
              );
            },
          ),
        ),
        DemoBlock(
          'UiWorkoutCard',
          child: UiResponsiveGrid(
            minItemWidth: 280,
            children: [
              UiWorkoutCard(
                title: 'Full body HIIT',
                subtitle: 'With Coach Mia',
                image: pic('hiit', 900, 600),
                duration: const Duration(minutes: 30),
                kcal: 320,
                level: UiWorkoutLevel.intermediate,
                bookmarked: _saved,
                onBookmark: (v) => setState(() => _saved = v),
                onTap: tap,
              ),
              UiWorkoutCard(
                title: 'Morning yoga flow',
                image: pic('yoga', 900, 600),
                duration: const Duration(minutes: 20),
                kcal: 120,
                level: UiWorkoutLevel.beginner,
                onTap: tap,
              ),
              UiWorkoutCard(
                title: 'Heavy legs',
                image: pic('legs', 900, 600),
                duration: const Duration(minutes: 55),
                kcal: 540,
                level: UiWorkoutLevel.advanced,
                height: 160,
              ),
            ],
          ),
        ),
        DemoBlock(
          'UiExerciseTile',
          child: Column(
            children: [
              for (final (i, (name, sets, reps, w)) in _exercises.indexed)
                UiExerciseTile(
                  name: name,
                  image: pic('ex$i', 200, 200),
                  sets: sets,
                  reps: reps,
                  weight: w,
                  done: _done.contains(i),
                  onDoneChanged: (v) => setState(() => v ? _done.add(i) : _done.remove(i)),
                  onTap: tap,
                ),
              const UiExerciseTile(name: 'Plank', detail: '3 × 60 s', trailing: Icon(Icons.chevron_right_rounded)),
            ],
          ),
        ),
        DemoBlock(
          'UiSetTracker',
          child: UiSetTracker(
            initial: const [(weight: 60, reps: 10, done: true), (weight: 62.5, reps: 8, done: false)],
            previous: const ['60 kg × 10', '60 kg × 9', '57.5 kg × 10'],
            onChanged: (_) {},
          ),
        ),
        DemoBlock(
          'UiRestTimer',
          child: Center(
            child: Column(
              children: [
                UiRestTimer(
                  key: ValueKey(_restKey),
                  duration: const Duration(seconds: 90),
                  autoStart: false,
                  size: 200,
                  onDone: () => toast(context, 'Rest done'),
                ),
                UiButton.ghost('Reset', icon: Icons.replay_rounded, onPressed: () => setState(() => _restKey++)),
              ],
            ),
          ),
        ),
        const DemoBlock('UiWorkoutTimer', child: Center(child: UiWorkoutTimer(label: 'Workout'))),
        DemoBlock(
          'UiWeekStreak',
          child: UiWeekStreak(
            days: const [UiStreakDay.done, UiStreakDay.done, UiStreakDay.missed, UiStreakDay.done, UiStreakDay.today],
            onTap: tap,
          ),
        ),
        const DemoBlock(
          'UiGoalCard',
          child: Column(
            children: [
              UiGoalCard(title: 'Steps', current: 6500, target: 10000, unit: 'steps', icon: Icons.directions_walk_rounded),
              UiGap.sm(),
              UiGoalCard(title: 'Run', subtitle: 'Weekly goal', current: 21.4, target: 20, unit: 'km', decimals: 1, icon: Icons.directions_run_rounded),
            ],
          ),
        ),
        DemoBlock(
          'UiWaterTracker',
          child: UiWaterTracker(count: _water, target: 8, onChanged: (v) => setState(() => _water = v)),
        ),
        DemoBlock(
          'UiHeartRateCard',
          child: UiHeartRateCard(bpm: 132, samples: const [92, 110, 128, 135, 140, 132, 128, 132], onTap: tap),
        ),
        DemoBlock(
          'UiProgramDayTile',
          child: Column(
            children: [
              for (final (i, s) in UiProgramDayState.values.indexed)
                UiProgramDayTile(
                  day: i + 1,
                  title: ['Full body', 'Upper body', 'Lower body', 'Conditioning'][i % 4],
                  subtitle: '${40 + i * 5} min',
                  state: s,
                  onTap: tap,
                ),
            ],
          ),
        ),
        const DemoBlock(
          'UiMacroBar',
          child: Column(
            children: [
              UiMacroBar(macros: [UiMacro('Protein', 120, 150), UiMacro('Carbs', 180, 250), UiMacro('Fat', 70, 65)]),
              UiGap.lg(),
              UiMacroBar(macros: [UiMacro('Protein', 120, 150), UiMacro('Carbs', 180, 250), UiMacro('Fat', 40, 65)], compact: true),
            ],
          ),
        ),
      ],
    );
  }
}
