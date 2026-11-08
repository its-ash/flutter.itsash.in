# Components

Every public API of the `theme` package. Import one file:

```dart
import 'package:theme/theme.dart';
```

All public names start with `Ui`. Each widget reads its colors, fonts, and radius from the theme. Each widget works in light and dark mode.

Generic widgets are grouped by element type. Domain kits are grouped by app type.

### Element types

| Group | Source | Main widgets | Reference |
|---|---|---|---|
| Foundation | `lib/src/foundation/` | `UiTheme`, `UiBrand`, tokens, `UiFormat`, `UiMoney` | [foundation.md](doc/components/foundation.md) |
| Buttons | `lib/src/button/` | `UiButton`, `UiIconButton`, `UiSocialButton`, `UiToggleButton` | [button.md](doc/components/button.md) |
| Inputs | `lib/src/input/` | `UiTextField`, `UiPasswordField`, `UiSearchField`, `UiOtpField`, sliders, date fields, `UiTagInput` | [input.md](doc/components/input.md) |
| Dropdowns | `lib/src/dropdown/` | `UiDropdown`, `UiSearchableDropdown`, `UiMultiSelectDropdown`, `UiAutocomplete` | [dropdown.md](doc/components/dropdown.md) |
| Chips | `lib/src/chip/` | `UiChip`, `UiChipGroup`, `UiChoiceChips`, `UiFilterChips` | [chip.md](doc/components/chip.md) |
| Selection | `lib/src/selection/` | `UiCheckboxTile`, `UiSwitchTile`, `UiRadioGroup`, `UiCheckboxGroup`, `UiSegmented` | [selection.md](doc/components/selection.md) |
| Cards | `lib/src/card/` | `UiCard` | [card.md](doc/components/card.md) |
| Images | `lib/src/image/` | `UiImage`, `UiLazyImage`, `UiAvatar`, `UiCarousel`, `UiImageViewer`, `UiImageGrid` | [image.md](doc/components/image.md) |
| Video | `lib/src/video/` | `UiVideoPlayer`, `UiVideoThumbnail` | [video.md](doc/components/video.md) |
| Scroll and lazy loading | `lib/src/scroll/` | `UiPagingController`, `UiInfiniteList`, `UiInfiniteGrid`, `UiScrollToTop`, `UiLazyBuilder` | [scroll.md](doc/components/scroll.md) |
| Layout and app shell | `lib/src/layout/` | `UiApp`, `UiScaffold`, `UiSection`, `UiListTile`, grids | [layout.md](doc/components/layout.md) |
| Navigation | `lib/src/navigation/` | bottom nav, drawer, tabs, indicators | [navigation.md](doc/components/navigation.md) |
| Feedback | `lib/src/feedback/` | dialogs, sheets, toasts, banners, skeletons, empty and error states | [feedback.md](doc/components/feedback.md) |
| Data display | `lib/src/display/` | `UiTag`, `UiRatingStars`, `UiMarquee`, charts, stats, timeline | [display.md](doc/components/display.md) |

### Domain kits

| Group | Source | Reference |
|---|---|---|
| Commerce | `lib/src/commerce/` | [commerce.md](doc/components/commerce.md) |
| Fitness | `lib/src/fitness/` | [fitness.md](doc/components/fitness.md) |
| Finance | `lib/src/finance/` | [finance.md](doc/components/finance.md) |
| Booking | `lib/src/booking/` | [booking.md](doc/components/booking.md) |
| Social and chat | `lib/src/social/` | [social.md](doc/components/social.md) |
| Auth, onboarding, account | `lib/src/auth/` | [auth.md](doc/components/auth.md) |

## Rules

- Read the group reference before you use or add a widget.
- Put a new widget in the matching group folder. A generic widget goes in the folder for its element type (for example a new chip goes in `lib/src/chip/`). Export it from the group barrel file (for example `lib/src/chip/chip.dart`).
- Inside `lib/`, import the exact file (`package:theme/src/chip/ui_chip.dart`), not `package:theme/theme.dart`.
- Update the group reference file when you add, rename, or change a public widget.
- Do not hard-code colors. Use `context.colors`, `context.palette`, and `context.tone(status)`.
