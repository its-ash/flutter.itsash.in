# theme

A Flutter design system for every app in this workspace.

- One import: `package:theme/theme.dart`.
- **One light theme and one dark theme.** You can set a custom accent color, and the other colors stay the same.
- Flat surfaces, 1 px borders, generous radius, soft accent tints. Built-in Material widgets are styled to match.
- About 190 public `Ui*` APIs in 11 groups. Most widgets need only one to three arguments: `UiButton('Save', onPressed: save)`.

See **[COMPONENTS.md](COMPONENTS.md)** for the full reference.

**[Live demo →](https://flutter.itsash.in)**

## Install

```yaml
dependencies:
  theme:
    git:
      url: https://github.com/its-ash/theme.git
      ref: main
```

```bash
flutter pub get
```

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:theme/theme.dart';

void main() => runApp(const UiApp(title: 'Notes', home: SettingsPage()));

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) => UiScaffold(
        appBar: const UiAppBar(title: 'Settings'),
        scrollable: true,
        body: Column(
          children: [
            UiListGroup(
              header: 'Account',
              children: [
                UiListTile('Profile', icon: Icons.person_rounded, chevron: true, onTap: () {}),
                UiListTile('Wi-Fi', icon: Icons.wifi_rounded, value: 'Home', chevron: true, onTap: () {}),
              ],
            ),
            const UiGap(UiSpace.xl),
            UiButton('Save', expand: true, onPressed: () => context.showToast('Saved', status: UiStatus.success)),
          ],
        ),
      );
}
```

Change the mode or accent at runtime:

```dart
final theme = UiThemeController();
UiApp(controller: theme, accent: Colors.teal, home: const HomePage());

UiThemeController.of(context)?.toggle(context); // light <-> dark
```

Use only the theme with your own `MaterialApp`:

```dart
MaterialApp(theme: UiTheme.light(accent: Colors.teal), darkTheme: UiTheme.dark(accent: Colors.teal));
```

## What is included

| Group | Examples |
|---|---|
| Foundation | `UiApp`, `UiThemeController`, `UiTheme`, `UiColors`, `UiTypography`, tokens, `context.colors` |
| Buttons | `UiButton`, `UiIconButton`, `UiFab`, `UiSegmentedControl`, `UiToggleGroup`, `UiCopyButton`, `UiHoldButton` |
| Inputs | text, password, number, search, select, multi-select, autocomplete, date/time, OTP, PIN pad, stepper, tags |
| Selection | checkbox, switch, radio, settings tiles, choice cards, chips, sliders, rating, color picker |
| Display | cards, list tiles, avatars, badges, tags, stat cards, tables, timeline, accordion, countdown, code |
| Charts | sparkline, line, bar, donut, heatmap, gauge |
| Feedback | alerts, toasts, dialogs, sheets, menus, popovers, progress, skeletons, empty/error states |
| Layout | `UiScaffold`, `UiSection`, `UiSurface`, responsive grid and layout, split view |
| Navigation | `UiShell` (bottom nav / rail / sidebar by width), app bars, tabs, steps, pagination, breadcrumbs |
| Media | `UiImage`, carousel, image viewer, image grid, `UiVideoPlayer` |
| Scroll | `UiPagingController`, infinite list and grid, refresh, scroll-to-top, lazy builder |

## Run the gallery

```bash
make run         # iOS simulator
make run-macos   # macOS desktop
make docs        # build the web demo into docs/
make deploy      # docs + commit + push
```

## Contributing

- Read `CLAUDE.md` for the component conventions.
- Put a new widget in the matching `lib/src/<group>/` folder and export it from that folder's barrel file.
- Document it in `doc/components/<group>.md` and the `COMPONENTS.md` table.
- Add a widget test in `test/<group>_test.dart` and show the widget in the `example` gallery.
- Run `flutter analyze` and `flutter test`.

## License

MIT. See [LICENSE](LICENSE).
