# Foundation

The theme, colors, type, and tokens. Every component is built on these. Import one file:

```dart
import 'package:theme/theme.dart';
```

## App setup

### UiApp
A `MaterialApp` with the light and dark themes applied. It follows the system mode by default.

```dart
void main() => runApp(const UiApp(title: 'Notes', home: NotesPage()));
```
- `home` (required), `title`
- `themeMode` (`ThemeMode.system`): a fixed mode when there is no controller.
- `accent` (indigo): your brand color. All other colors stay the same.
- `fontFamily` (Inter): a bundled font family to use instead of Inter.
- `controller`: a `UiThemeController` to change the mode or accent at runtime.
- `routes`, `onGenerateRoute`, `navigatorKey`, `scaffoldMessengerKey`, `navigatorObservers`, `locale`, `localizationsDelegates`, `supportedLocales`, `builder`
- `UiApp.router(routerConfig: router, ...)` for `go_router` or any `RouterConfig`.

### UiThemeController
Holds the theme mode and accent. Widgets below `UiApp` can change them.

```dart
final theme = UiThemeController();
UiApp(controller: theme, home: const HomePage());

UiThemeController.of(context)?.toggle(context);        // light <-> dark
UiThemeController.of(context)?.mode = ThemeMode.system;
UiThemeController.of(context)?.accent = Colors.teal;
```

### UiTheme
Builds the `ThemeData` for each mode. Use it if you keep your own `MaterialApp`.

```dart
MaterialApp(theme: UiTheme.light(), darkTheme: UiTheme.dark(), themeMode: ThemeMode.system);
```
- `UiTheme.light({accent, fontFamily})`, `UiTheme.dark({accent, fontFamily})`
- `UiTheme.fromColors(UiColors, {fontFamily})`
- It styles all built-in Material widgets (buttons, fields, switches, sheets, dialogs, nav bars, tabs, and more), so they match the `Ui*` components.

## Colors

### UiColors
The color palette. There are two: `UiColors.light()` and `UiColors.dark()`. Read it with `context.colors`.

```dart
Container(color: context.colors.surface, child: Text('Hi', style: TextStyle(color: context.colors.textMuted)));
```

| Role | Colors |
|---|---|
| Surfaces | `background` (page), `surface` (cards, bars), `surfaceMuted` (inputs, tracks, hover), `surfaceRaised` (menus, dialogs), `surfaceInverse` / `onSurfaceInverse` (tooltips, snackbars) |
| Lines | `border` (hairlines), `borderStrong` (control outlines) |
| Text | `text`, `textMuted`, `textSubtle`, `textDisabled` |
| Accent | `accent`, `onAccent`, `accentSoft` (tinted fill), `onAccentSoft` |
| Status | `success`, `warning`, `danger`, `info`, each with `on…`, `…Soft`, `on…Soft` |
| Other | `scrim`, `shimmerBase`, `shimmerHighlight`, `chart` (8 series colors), `chartColor(i)` |

- `tone(UiStatus)` returns a `UiTone` with `color`, `onColor`, `soft`, `onSoft`.
- If you pass an accent, dark mode lightens it when needed so that it stays readable.

### UiStatus
The meaning of a colored element: `neutral`, `accent`, `info`, `success`, `warning`, `danger`. `status.icon` gives a default icon.

```dart
final tone = context.colors.tone(UiStatus.success);
Container(color: tone.soft, child: Icon(UiStatus.success.icon, color: tone.onSoft));
```

## Typography

### UiTypography
The type scale is Inter, from `google_fonts`. Read it with `context.text`.

| Style | Size / weight |
|---|---|
| `displayLarge` / `Medium` / `Small` | 48 / 40 / 32, bold |
| `headlineLarge` / `Medium` / `Small` | 28 / 24 bold, 20 semibold |
| `titleLarge` / `Medium` / `Small` | 18 / 16 / 14, semibold |
| `bodyLarge` / `Medium` / `Small` | 16 / 14 / 12.5 (`bodySmall` is muted) |
| `labelLarge` / `Medium` / `Small` | 14 / 12.5 / 11, semibold |

- `UiTypography.mono({fontSize, fontWeight, color})`: JetBrains Mono with tabular figures, for codes and IDs.
- `UiTypography.useGoogleFonts = false`: uses the platform font, for tests and offline builds.

## Tokens

### UiSpace
Spacing on a 4 pt grid: `xxs` 2, `xs` 4, `sm` 8, `md` 12, `lg` 16, `xl` 24, `xxl` 32, `xxxl` 48, `page` 20 (page side padding).

### UiRadius
Corner radius: `xs` 6, `sm` 10, `md` 14 (controls), `lg` 18 (cards), `xl` 26 (sheets, dialogs), `full` (pills). Helpers: `UiRadius.all(r)`, `UiRadius.top(r)`.

### UiMotion
Durations `fast` 120 ms, `normal` 220 ms, `slow` 360 ms. Curves `standard`, `emphasized`, `bounce`. `context.motion(d)` returns zero when the user asks for reduced motion.

### UiShadows
`context.shadowSm`, `context.shadowMd`, `context.shadowLg`: soft shadows that suit the current mode.

### UiSize
Size of a control: `sm` (36), `md` (44, default), `lg` (52). It also gives `.iconSize`, `.fontSize`, and `.padding`.

## Layout helpers

### UiBreakpoint
Window size class: `compact` (< 600), `medium` (< 840), `expanded` (< 1200), `large`. Read it with `context.breakpoint`. Use `context.isCompact` for phones.

```dart
final columns = context.responsive(compact: 2, medium: 3, expanded: 4);
```

### UiGap
A gap in a `Row` or `Column`. It uses the direction of the nearest one.

```dart
Row(children: [icon, const UiGap(UiSpace.sm), label]);
```

### UiContext and UiResponsive extensions
`UiContext`: `context.theme`, `context.colors`, `context.text`, `context.isDark`, `context.screenSize`, `context.breakpoint`, `context.isCompact`, `context.shadowSm/Md/Lg`, `context.motion(d)`.
`UiResponsive`: `context.responsive(compact: ..., medium: ..., expanded: ..., large: ...)`.
