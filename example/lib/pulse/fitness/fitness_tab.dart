import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

import '../pulse_data.dart';
import 'workout_page.dart';

/// Fitness dashboard tab. The shell provides the Scaffold and app bar.
class PulseFitnessTab extends StatefulWidget {
  const PulseFitnessTab({super.key});

  @override
  State<PulseFitnessTab> createState() => _PulseFitnessTabState();
}

class _PulseFitnessTabState extends State<PulseFitnessTab> {
  int _water = 4;
  String _range = 'Week';
  final Set<String> _saved = {};

  static const _ranges = ['Day', 'Week', 'Month'];

  static const _chart = <String, (List<double>, List<String>)>{
    'Day': ([120, 340, 80, 610, 420, 260], ['6a', '9a', '12p', '3p', '6p', '9p']),
    'Week': ([6200, 8400, 5100, 9800, 7600, 11200, 8240], ['M', 'T', 'W', 'T', 'F', 'S', 'S']),
    'Month': ([48200, 56100, 51900, 60300], ['W1', 'W2', 'W3', 'W4']),
  };

  static const _program = [
    ('Full body basics', '35 min', UiProgramDayState.completed),
    ('Upper body push', '40 min', UiProgramDayState.completed),
    ('Easy run', '25 min', UiProgramDayState.completed),
    ('Lower body power', '45 min', UiProgramDayState.current),
    ('Core and mobility', '30 min', UiProgramDayState.upcoming),
    ('Upper body pull', '40 min', UiProgramDayState.upcoming),
    ('Long walk and stretch', '50 min', UiProgramDayState.locked),
  ];

  /// 8240 -> "8,240".
  static String _grouped(double v) => v.round().toString().replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');

  void _openDay(String title) => context.showToast('$title starts soon', icon: Icons.event_available_rounded);

  @override
  Widget build(BuildContext context) {
    final store = PulseScope.of(context);
    final workouts = store.data.workouts;

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        final summary = <Widget>[_rings(context), _streakAndHeart(), _waterAndMacros()];

        return ListView(
          padding: const EdgeInsets.fromLTRB(UiSpace.lg, UiSpace.lg, UiSpace.lg, UiSpace.huge),
          children: [
            _greeting(context, store.me.name.split(' ').first),
            const UiGap.lg(),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final (i, w) in summary.indexed) ...[
                    if (i > 0) const UiGap.md(),
                    Expanded(child: w),
                  ],
                ],
              )
            else
              for (final (i, w) in summary.indexed) ...[
                if (i > 0) const UiGap.md(),
                w,
              ],
            const UiGap.xxl(),
            UiSection(title: 'Today', subtitle: 'Updated a minute ago', child: _metrics()),
            UiSection(
              title: 'Activity',
              trailing: UiSegmented<String>(
                options: _ranges,
                value: _range,
                size: UiSize.sm,
                onChanged: (v) => setState(() => _range = v),
              ),
              child: _activityChart(context),
            ),
            UiSection(
              title: 'Goals',
              child: const UiResponsiveGrid(
                minItemWidth: 280,
                children: [
                  UiGoalCard(title: 'Steps', current: 8240, target: 10000, unit: 'steps', icon: Icons.directions_walk_rounded),
                  UiGoalCard(title: 'Run', subtitle: 'Weekly goal', current: 14.6, target: 20, unit: 'km', decimals: 1, icon: Icons.directions_run_rounded),
                  UiGoalCard(title: 'Workouts', subtitle: 'This week', current: 4, target: 4, unit: 'sessions', icon: Icons.fitness_center_rounded),
                ],
              ),
            ),
            UiSection(
              title: 'Plans',
              subtitle: '${workouts.length} workouts picked for you',
              child: UiResponsiveGrid(
                minItemWidth: 280,
                children: [
                  for (final w in workouts)
                    UiWorkoutCard(
                      title: w.title,
                      subtitle: 'With ${w.coach.name}',
                      image: w.image,
                      duration: Duration(minutes: w.minutes),
                      kcal: w.calories,
                      level: workoutLevel(w.level),
                      bookmarked: _saved.contains(w.id),
                      onBookmark: (v) => setState(() => v ? _saved.add(w.id) : _saved.remove(w.id)),
                      onTap: () => pulsePush(context, PulseWorkoutPage(workout: w)),
                    ),
                ],
              ),
            ),
            UiSection(
              title: '7-day program',
              subtitle: 'Strong Start · Day 4 of 7',
              child: UiCard(
                variant: UiCardVariant.outlined,
                padding: const EdgeInsets.symmetric(vertical: UiSpace.xs),
                child: Column(
                  children: [
                    for (final (i, (title, time, state)) in _program.indexed)
                      UiProgramDayTile(
                        day: i + 1,
                        title: title,
                        subtitle: time,
                        state: state,
                        onTap: () => _openDay(title),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _greeting(BuildContext context, String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Good to see you, $name', style: context.text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        const UiGap.xs(),
        Text('You are 3 days into your streak. Keep it going!', style: context.text.bodyMedium?.copyWith(color: context.colors.onSurfaceVariant)),
      ],
    );
  }

  Widget _rings(BuildContext context) {
    return UiCard(
      variant: UiCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Rings', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const UiGap.md(),
          Center(
            child: UiActivityRings(
              rings: const [
                UiActivityRing(0.82, label: 'Move'),
                UiActivityRing(1.15, label: 'Exercise'),
                UiActivityRing(0.58, label: 'Stand'),
              ],
              center: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('82%', style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  Text('of goal', style: context.text.labelSmall?.copyWith(color: context.colors.onSurfaceVariant)),
                ],
              ),
              legend: true,
            ),
          ),
          const UiGap.md(),
          const UiKeyValue('Move', '410 / 500 kcal', icon: Icons.local_fire_department_rounded),
          const UiKeyValue('Exercise', '35 / 30 min', icon: Icons.timer_outlined),
          const UiKeyValue('Stand', '7 / 12 h', icon: Icons.accessibility_new_rounded),
        ],
      ),
    );
  }

  Widget _streakAndHeart() {
    return Column(
      children: [
        UiWeekStreak(
          days: const [UiStreakDay.done, UiStreakDay.missed, UiStreakDay.done, UiStreakDay.done, UiStreakDay.today],
          onTap: () => context.showToast('Best streak: 12 days', icon: Icons.local_fire_department_rounded),
        ),
        const UiGap.md(),
        UiHeartRateCard(
          bpm: 74,
          samples: const [68, 72, 70, 88, 112, 96, 80, 74],
          title: 'Heart rate',
          onTap: () => context.showToast('Resting heart rate: 58 bpm'),
        ),
      ],
    );
  }

  Widget _waterAndMacros() {
    return Column(
      children: [
        UiWaterTracker(
          count: _water,
          target: 8,
          title: 'Water',
          onChanged: (v) {
            setState(() => _water = v);
            if (v == 8) context.showToast('Water goal reached', status: UiStatus.success);
          },
        ),
        const UiGap.md(),
        UiCard(
          variant: UiCardVariant.outlined,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Nutrition', style: context.text.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const UiGap.md(),
              const UiMacroBar(
                macros: [UiMacro('Protein', 96, 140), UiMacro('Carbs', 182, 240), UiMacro('Fat', 58, 70)],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metrics() {
    return UiResponsiveGrid(
      minItemWidth: 160,
      children: [
        const UiMetricTile(icon: Icons.directions_walk_rounded, value: '8,240', unit: 'steps', label: 'Steps', trend: 12),
        const UiMetricTile(icon: Icons.route_rounded, value: '6.1', unit: 'km', label: 'Distance', trend: 8),
        UiMetricTile(
          icon: Icons.bedtime_rounded,
          value: '7:25',
          unit: 'h',
          label: 'Sleep',
          trend: -4,
          tonal: true,
          onTap: () => context.showToast('You slept 25 minutes less than usual'),
        ),
        UiMetricTile(
          icon: Icons.favorite_rounded,
          value: '58',
          unit: 'bpm',
          label: 'Resting HR',
          trend: -3,
          trendUpIsGood: false,
          color: context.tone(UiStatus.danger).color,
        ),
      ],
    );
  }

  Widget _activityChart(BuildContext context) {
    final (values, labels) = _chart[_range]!;
    final total = values.fold<double>(0, (a, b) => a + b);
    return UiCard(
      variant: UiCardVariant.outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_grouped(total)} steps', style: context.text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
          Text(
            switch (_range) {
              'Day' => 'Today so far',
              'Week' => 'This week',
              _ => 'This month',
            },
            style: context.text.bodySmall?.copyWith(color: context.colors.onSurfaceVariant),
          ),
          const UiGap.lg(),
          UiBarChart(
            values,
            key: ValueKey(_range),
            labels: labels,
            highlight: values.length - 1,
            format: _grouped,
          ),
        ],
      ),
    );
  }
}
