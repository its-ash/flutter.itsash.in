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
- `accent` (Primary coral `#FF7E70`): your brand color. All other colors stay the same.
- `fontFamily` (Outfit): a bundled font family to use instead of Outfit.
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

The full palette with every hex value is in [DESIGN.md](../../DESIGN.md) section 2 (Nova). It uses a violet-tinted nine-step gray scale where 1 is the background and 9 the foreground.

| Step | Light | Dark | Used for |
|---|---|---|---|
| 1 | `#FFFFFF` | `#0E0E12` | `background` |
| 2 | `#F7F6FB` | `#18171F` | `surface`, checkbox fill |
| 3 | `#ECEBF2` | `#26252F` | `border`, tracks |
| 4 | `#D9D7E3` | `#383646` | `borderStrong`, disabled button fill |
| 5 | `#B3B0C2` | `#5A5770` | `textDisabled` |
| 6 | `#8C899E` | `#8C899E` | `textSubtle` |
| 7 | `#5E5B70` | `#B9B6C8` | `textMuted` |
| 8 | `#2E2C3A` | `#E4E2EE` | |
| 9 | `#121216` | `#F7F6FB` | `text` |
| Overlay | `#6B5FB0` at 10% | `#C9C2FF` at 10% | `surfaceMuted` (chips, tiles, stepper, secondary buttons, hover). Fields are outline only: page-colored fill with a `borderStrong` outline |

| Role | Colors |
|---|---|
| Surfaces | `background` (page, outlined cards), `surface` (tinted areas, list groups), `surfaceMuted` (Overlay; translucent), `surfaceRaised` (menus, dialogs, sheets), `surfaceInverse` / `onSurfaceInverse` (promo banner, toasts, tooltips) |
| Lines | `border` (hairlines, dividers), `borderStrong` (control outlines) |
| Text | `text`, `textMuted`, `textSubtle`, `textDisabled` |
| Accent | `accent` (coral `#FF7E70`, `#FF8F83` in dark), `onAccent`, `accentSoft` (accent at 12% / 20%), `onAccentSoft` |
| Status | `success` `#17B26A`, `warning` `#F2B705`, `danger` `#E5484D`, `info` `#3B82F6`, each with `on…`, `…Soft` (translucent), `on…Soft` |
| Other | `scrim`, `shimmerBase`, `shimmerHighlight`, `chart` (8 series colors), `chartColor(i)` |

- `gray(n)`: step `n` (1..9) of the scale for the current mode. `UiColors.grayLight` / `grayDark` hold the raw lists; `UiColors.overlay` / `overlayDark` are the Overlay colors.
- `surfaceMutedSolid`: `surfaceMuted` blended over `surface`, for spots that need an opaque color.
- `surfaceMuted`, `accentSoft` and the `…Soft` status colors are translucent, so they read the same on the page, a card or a dialog.
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
The Nova type ramp: Outfit from `google_fonts`, weights 400 (body), 500 (titles, labels) and 600 (headings), no letter spacing. Read it with `context.text`.

| Style | Size / line height |
|---|---|
| `displayLarge` | 48 / 56, 600 |
| `displayMedium` | 40 / 48, 600 |
| `displaySmall` | 32 / 40, 600 (screen titles) |
| `headlineLarge` | 28 / 36, 600 |
| `headlineMedium` | 24 / 32, 600 |
| `headlineSmall` | 22 / 28, 600 (prices, dialog titles) |
| `titleLarge` | 20 / 26, 500 (app bar titles) |
| `titleMedium` | 17 / 24, 500 |
| `titleSmall` | 15 / 20, 500 |
| `bodyLarge` | 17 / 24 |
| `bodyMedium` | 15 / 22 (the default text) |
| `bodySmall` | 13 / 18, muted |
| `labelLarge` | 15 / 20, 500 (buttons, chips) |
| `labelMedium` | 13 / 16, 500 |
| `labelSmall` | 11 / 14, 500 |

- `UiTypography.mono({fontSize, fontWeight, color})`: JetBrains Mono with tabular figures, for codes and IDs.
- `UiTypography.useGoogleFonts = false`: uses the platform font, for tests and offline builds.

## Tokens

### UiSpace
Spacing on a 4 pt grid: `xxs` 2, `xs` 4, `sm` 8, `md` 12, `lg` 16, `xl` 24, `xxl` 32, `xxxl` 48, `page` 20 (page side padding).

### UiRadius
Corner radius: `xs` 6 (checkboxes), `sm` 10 (tooltips), `md` 14 (fields, option tiles, thumbnails, menus), `lg` 24 (cards, promo cards, image tiles, toasts), `xl` 32 (sheets, dialogs), `full` (buttons, icon buttons, chips, segmented controls, steppers, avatars). Helpers: `UiRadius.all(r)`, `UiRadius.top(r)`.

### UiMotion
Durations `fast` 120 ms, `normal` 220 ms, `slow` 360 ms. Curves `standard`, `emphasized`, `bounce`. `context.motion(d)` returns zero when the user asks for reduced motion.

### UiShadows
Three shadow levels, each a tight plus a wide shadow, tinted violet-gray in light mode (black and stronger in dark mode):

| Level | Getter | Shadows | Used for |
|---|---|---|---|
| 1 | `context.shadowSm` | 0,2 blur 4 + 0,3 blur 9 | slider thumbs, small raised controls |
| 2 | `context.shadowMd` | 0,4 blur 7 + 0,8 blur 24 | menus, popovers, toasts, chart tooltips |
| 3 | `context.shadowLg` | 0,16 blur 32 + 0,4 blur 8 | dialogs, sheets |

`UiShadows.ring(color)`: the 4 px hover / focus ring around buttons, controls and fields (the color at 50%).

### UiSize
Size of a control: `sm` (36), `md` (44, default), `lg` (52). It also gives `.iconSize` (16 / 20 / 22), `.fontSize` (13 / 15 / 17), and `.padding` (14 / 18 / 22). Buttons and icon buttons are 40 / 48 / 56, chips and segments 32 / 40 / 48, fields and steppers 40 / 48 / 56; the full table is in [DESIGN.md](../../DESIGN.md) section 5.

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
