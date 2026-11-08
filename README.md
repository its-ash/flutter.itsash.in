# theme

A Flutter design system for every app you build: e-commerce, gym and workout, finance, health, food, travel, social, booking, education, and productivity.

- One import: `package:theme/theme.dart`.
- Light and dark mode from one brand preset.
- Modern Material 3 look: filled pill tabs, rounded corners, card layouts, filled inputs.
- More than 150 `Ui*` widgets. Each widget works with one to three arguments.

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

void main() => runApp(const UiApp(title: 'Shop', brand: UiBrand.commerce, home: HomePage()));

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => UiScaffold(
        title: 'Discover',
        scrollable: false,
        body: UiTabView(
          tabs: const ['All', 'Shoes', 'Bags'],
          children: [
            for (var i = 0; i < 3; i++)
              UiResponsiveGrid.builder(
                itemCount: 8,
                mainAxisExtent: 300,
                itemBuilder: (_, i) => UiProductCard(
                  title: 'Air Runner $i',
                  price: 129,
                  compareAt: 159,
                  rating: 4.6,
                  imageUrl: 'https://picsum.photos/seed/p$i/400',
                ),
              ),
          ],
        ),
      );
}
```

Use only the theme with your own `MaterialApp`:

```dart
MaterialApp(
  theme: UiTheme.light(UiBrand.fitness),
  darkTheme: UiTheme.dark(UiBrand.fitness),
);
```

Make a custom brand from one color:

```dart
final brand = UiBrand.neutral.copyWith(id: 'acme', name: 'Acme', seed: const Color(0xFF00897B));
```

## What is included

| Group | Examples |
|---|---|
| Foundation | `UiTheme`, `UiBrand` (11 presets), `UiColors`, `UiTokens`, `UiSpace`, context shortcuts |
| Primitives | `UiButton`, `UiIconButton`, `UiCard`, `UiImage`, `UiTag`, `UiAvatar`, `UiRatingStars` |
| Controls | text, password, search, OTP, dropdown, chips, segmented, sliders, steppers, date/time, tags |
| Layout | `UiApp`, `UiScaffold`, `UiSection`, `UiListGroup`, `UiResponsiveGrid`, accordion |
| Navigation | `UiTabView`, `UiBottomNav`, `UiFloatingNavBar`, `UiAdaptiveShell`, steps, dots |
| Feedback | toasts, dialogs, sheets, banners, empty/error states, skeletons, progress |
| Display | stat cards, charts, timeline, carousel, image viewer, countdown |
| Commerce | product cards, price, cart, order summary, coupon, checkout, order tracker, reviews |
| Fitness | activity rings, workout cards, set tracker, rest timer, streaks, goals |
| Finance | balance card, payment card, transactions, budgets, spending donut, amount keypad |
| Booking | date strip, calendar, time slots, tickets, seat picker, guest counter |
| Social | chat bubbles, composer, posts, comments, profile header, stories, notifications |
| Auth | onboarding, login, signup, PIN pad, paywall, splash, error pages |

## Run the showcase

```bash
make run         # iOS simulator
make run-macos   # macOS desktop
make docs        # build the web demo into docs/
make deploy      # docs + commit + push
```

## Contributing

- Put all theme and component code in `lib/`. Read `CLAUDE.md`.
- Put a new widget in the matching `lib/src/<group>/` folder. Export it from that folder's barrel file.
- Document it in `doc/components/<group>.md`.
- Show it in the `example` app.

## License

MIT. See [LICENSE](LICENSE).
