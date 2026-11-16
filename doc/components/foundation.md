# Foundation

The theme, colors, type, and tokens. Every component is built on these. Import one file:

```dart
import 'package:theme/theme.dart';
```

## App setup

### UiApp
A `MaterialApp` with the light and dark themes applied. It starts in light mode at normal text size; a mode and text size the user saved with `UiAppearanceSection` are restored on start and win over the defaults. The text size multiplies the system `TextScaler` below `UiApp` (applied before your own `builder`).

```dart
void main() => runApp(const UiApp(title: 'Notes', home: NotesPage()));
```
- `home` (required), `title`
- `themeMode` (`ThemeMode.light`): the starting mode when there is no controller. Do not pass it in apps: the default is light and the user's saved choice overrides it.
- `accent` (Primary blue `#3F88E4`): your brand color. All other colors stay the same.
- `fontFamily` (Inter): a bundled font family to use instead of Inter.
- `controller`: a `UiThemeController` to change the mode or accent at runtime.
- `routes`, `onGenerateRoute`, `navigatorKey`, `scaffoldMessengerKey`, `navigatorObservers`, `locale`, `localizationsDelegates`, `supportedLocales`, `builder`
- `UiApp.router(routerConfig: router, ...)` for `go_router` or any `RouterConfig`.

### UiThemeController
Holds the theme mode (default `ThemeMode.light`), `textSize` (`UiTextSize.normal`; `small` / `normal` / `large` / `extraLarge`) and accent. Widgets below `UiApp` can change them. `UiAppearance.load()` / `save(mode)` and `loadTextSize()` / `saveTextSize(size)` read and write the persisted choices (`SharedPreferences` keys `ui_theme_mode`, `ui_text_size`); `UiApp` loads both on start. Use `UiAppearanceSection` in settings instead of calling these.

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

The palette follows the "Themes" gray scale of the Ash Theme Figma file: nine steps where 1 is the background and 9 the foreground. Light and dark mode are the same scale flipped.

| Step | Light | Dark | Used for |
|---|---|---|---|
| 1 | `#FFFFFF` | `#000000` | `background`, `onSurfaceInverse` |
| 2 | `#F2F2F2` | `#262626` | `surface`, `surfaceRaised`, disabled fills, checkbox fill |
| 3 | `#E0E0E0` | `#3B3B3B` | slider, progress, chart and gauge tracks, tab rule |
| 4 | `#C4C4C4` | `#707070` | `borderStrong`, `textDisabled` |
| 5 | `#999999` | `#999999` | `textSubtle` (labels, placeholders, captions) |
| 6 | `#707070` | `#C4C4C4` | `textMuted` (descriptions) |
| 7 | `#4D4D4D` | `#E0E0E0` | dim/ghost button labels |
| 8 | `#262626` | `#F2F2F2` | `surfaceInverse` (tooltips, snackbars) |
| 9 | `#000000` | `#FFFFFF` | `text` |
| Overlay | `#999999` at 20% | same | `surfaceMuted` (fields, dim buttons, chips, hover), `border` (dividers) |

| Role | Colors |
|---|---|
| Surfaces | `background` (page), `surface` (cards, bars), `surfaceMuted` (inputs, tracks, hover; translucent), `surfaceRaised` (menus, dialogs), `surfaceInverse` / `onSurfaceInverse` (tooltips, snackbars) |
| Lines | `border` (dividers; translucent), `borderStrong` (control outlines) |
| Text | `text`, `textMuted`, `textSubtle`, `textDisabled` |
| Accent | `accent` (Primary, `#3F88E4` in both modes), `onAccent`, `accentSoft` (accent at 20–25%), `onAccentSoft` |
| Status | `success` `#0AB35A`, `warning` `#D69400`, `danger` `#DA3A3A`, `info` `#25A7B6`, each with `on…`, `…Soft` (30% overlay), `on…Soft` (darker tone in light, lighter tone in dark) |
| Other | `scrim`, `shimmerBase`, `shimmerHighlight`, `chart` (8 series colors from the core palette), `chartColor(i)` |

- `gray(n)`: step `n` (1..9) of the scale for the current mode. `UiColors.grayLight` / `grayDark` hold the raw lists; `UiColors.overlay` is the Overlay color.
- `surfaceMutedSolid`: `surfaceMuted` blended over `surface`, for spots that need an opaque color.
- `surfaceMuted`, `border`, `accentSoft` and the `…Soft` status colors are translucent, so they read the same on the page, a card or a dialog.
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
The Ash Theme type ramp (mobile sizes). Two weights only: regular 400 and bold 600, no letter spacing. The design uses SF Pro / Segoe UI, which cannot ship on Android, so the font is Inter from `google_fonts`. Read it with `context.text`.

| Style | Design style | Size / line height |
|---|---|---|
| `displayLarge` | display / 50 | 50 / 60, bold |
| `displayMedium` | display / 37 | 37 / 44, bold |
| `displaySmall`, `headlineLarge` | H1 | 29 / 36, bold |
| `headlineMedium` | H2 | 24 / 32, bold |
| `headlineSmall` | H3 | 21 / 24, bold (dialog titles) |
| `titleLarge` | H4 | 19 / 22, bold (app bar titles) |
| `titleMedium` | H6 | 17 / 22, bold |
| `titleSmall`, `labelLarge` | body/normal bold | 14 / 20, bold |
| `bodyLarge` | medium | 16 / 22 |
| `bodyMedium` | body/normal regular | 14 / 20 (the default text) |
| `bodySmall` | body/small | 12 / 16, muted |
| `labelMedium` | body/small bold | 12 / 16, bold |
| `labelSmall` | body/x_small | 10 / 14, bold |

- `UiTypography.mono({fontSize, fontWeight, color})`: JetBrains Mono with tabular figures, for codes and IDs.
- `UiTypography.useGoogleFonts = false`: uses the platform font, for tests and offline builds.

## Tokens

### UiSpace
Spacing on a 4 pt grid: `xxs` 2, `xs` 4, `sm` 8, `md` 12, `lg` 16, `xl` 24, `xxl` 32, `xxxl` 48, `page` 16 (page side padding).

### UiRadius
Corner radius (design "Border radius", mobile): `xs` 4 (checkboxes), `sm` 6, `md` 8 (buttons, fields), `lg` 12 (cards, dialogs, menus), `xl` 20 (sheets), `full` (controls, chips, segmented controls, avatars). Helpers: `UiRadius.all(r)`, `UiRadius.top(r)`.

### UiMotion
Durations `fast` 120 ms, `normal` 220 ms, `slow` 360 ms. Curves `standard`, `emphasized`, `bounce`. `context.motion(d)` returns zero when the user asks for reduced motion.

### UiShadows
The design's three shadow levels, each a tight plus a wide black shadow (stronger in dark mode):

| Level | Getter | Shadows | Used for |
|---|---|---|---|
| 1 | `context.shadowSm` | 0,2 blur 4 + 0,3 blur 9 | slider thumbs, small raised controls |
| 2 | `context.shadowMd` | 0,4 blur 7 + 0,8 blur 24 | menus, popovers, toasts, chart tooltips |
| 3 | `context.shadowLg` | 0,16 blur 32 + 0,4 blur 8 | dialogs, sheets |

`UiShadows.ring(color)`: the 4 px hover / focus ring around buttons, controls and fields (the color at 50%).

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
