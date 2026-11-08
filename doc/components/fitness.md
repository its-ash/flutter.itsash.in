# Fitness

Import: `package:theme/theme.dart`. All widgets use the theme colors. They work in light mode and dark mode.

### UiActivityRings
Shows 1 to 3 animated rings. A value above 1 shows a lap.
```dart
UiActivityRings(
  rings: const [UiActivityRing(0.8, label: 'Move'), UiActivityRing(1.2, label: 'Exercise')],
  center: const Text('80%'),
  legend: true,
)
```
Params: `rings` (max 3), `size` 160, `stroke` 16, `gap` 4, `center`, `legend` false, `duration`. Ring colors: primary, tertiary, secondary.

### UiMetricTile
Shows one metric with an icon, value, unit, and trend.
```dart
UiMetricTile(icon: Icons.directions_walk, value: '8,240', unit: 'steps', label: 'Today', trend: 12)
```
Params: `icon`, `value`, `label`, `unit`, `trend` (%), `trendUpIsGood` true, `color`, `tonal` false, `onTap`.

### UiWorkoutCard
Image card with a dark scrim, title, duration, kcal, level tag, and bookmark.
```dart
UiWorkoutCard(
  title: 'Full body HIIT',
  image: 'https://…',
  duration: const Duration(minutes: 30),
  kcal: 320,
  level: UiWorkoutLevel.intermediate,
  onBookmark: (v) {},
)
```
Params: `title`, `image`, `subtitle`, `duration`, `kcal`, `level` (`UiWorkoutLevel.beginner|intermediate|advanced`), `onTap`, `bookmarked`, `onBookmark`, `height` 200, `width`.

### UiExerciseTile
Exercise row with thumbnail, summary text, and a done check.
```dart
UiExerciseTile(name: 'Bench press', sets: 4, reps: 12, weight: 20, done: false, onDoneChanged: (v) {})
```
Params: `name`, `image`, `sets`, `reps`, `weight`, `unit` 'kg', `detail` (replaces summary), `done` (null hides the check), `onDoneChanged`, `onTap`, `trailing`.

### UiSetTracker
Table of sets: set number, previous, weight, reps, done. Swipe a row to remove it.
```dart
UiSetTracker(previous: const ['20 kg × 12'], onChanged: (sets) {})
```
Params: `initial` (`List<UiSetEntry>`), `previous`, `onChanged`, `unit` 'kg', `maxSets` 20, `addLabel`.
Type: `UiSetEntry = ({double? weight, int? reps, bool done})`. Weight: max 4 digits and 2 decimals. Reps: max 3 digits.

### UiRestTimer
Circular countdown with −/+ step, pause, resume, and skip. The timer stops on dispose.
```dart
UiRestTimer(duration: const Duration(seconds: 90), onDone: () {})
```
Params: `duration` 90 s, `step` 15 s, `autoStart` true, `onDone`, `onSkip` (default `onDone`), `label` 'Rest', `size` 220, `color`.

### UiWorkoutTimer
Stopwatch with a large mm:ss display, start, pause, and reset.
```dart
UiWorkoutTimer(label: 'Workout', onChanged: (d) {})
```
Params: `initial`, `autoStart` false, `label`, `onChanged`, `onReset`, `showReset` true.

### UiWeekStreak
Seven day circles and a streak count with a flame.
```dart
UiWeekStreak(days: const [UiStreakDay.done, UiStreakDay.done, UiStreakDay.missed, UiStreakDay.today])
```
Params: `days` (`UiStreakDay.done|today|missed|upcoming`, pads to 7), `streak` (null calculates it), `labels`, `title`, `streakLabel`, `onTap`.

### UiGoalCard
Goal with current and target values, progress bar, and percent.
```dart
UiGoalCard(title: 'Steps', current: 6500, target: 10000, unit: 'steps', icon: Icons.directions_walk)
```
Params: `title`, `current`, `target`, `unit`, `icon`, `subtitle`, `color`, `decimals` 0, `onTap`. At 100% the color changes to success.

### UiWaterTracker
Tap cups to fill them. Tap the last full cup to empty it.
```dart
UiWaterTracker(count: water, target: 8, onChanged: (v) => setState(() => water = v))
```
Params: `count`, `target` 8, `onChanged`, `title`, `perCup` 250, `unit` 'ml', `color` (default info). Max 24 cups.

### UiHeartRateCard
BPM value, zone label, and a sparkline.
```dart
UiHeartRateCard(bpm: 132, samples: const [92, 110, 128, 135, 132])
```
Params: `bpm`, `samples`, `maxHeartRate` 190, `zone`, `zoneStatus`, `title`, `onTap`. `UiHeartRateCard.zoneFor(bpm, max)` gives the zone.

### UiProgramDayTile
One day of a training plan.
```dart
UiProgramDayTile(day: 3, title: 'Upper body', state: UiProgramDayState.current, onTap: () {})
```
Params: `day`, `title`, `subtitle`, `state` (`completed|current|upcoming|locked`), `onTap` (off when locked), `dayLabel`.

### UiMacroBar
Nutrition bars, for example protein, carbs, and fat.
```dart
UiMacroBar(macros: const [UiMacro('Protein', 120, 150), UiMacro('Carbs', 180, 250)], compact: true)
```
Params: `macros` (`UiMacro(label, value, target, {unit 'g', color})`), `compact` false (true shows a row).

### Formatting
The fitness widgets use the shared `UiFormat` helpers ([foundation.md](foundation.md#formatting)): `UiFormat.duration(d)` for a clock (`05:30`, `1:02:05`), `UiFormat.minutes(d)` for `45 min` / `1h 15m`, and `UiFormat.number(v, decimals: 1, trimZeros: true)` for distances and weights. There is no separate fitness formatter.
