## 4.0.0

Visual redesign to the **Nova** design system (spec in `DESIGN.md`). No public API is removed; apps only need `flutter pub upgrade theme`, but layouts get taller (48 px buttons and fields) and rounder.

* Fields (text, search, select, OTP, tags) are outline only: page-colored fill, 1 px `borderStrong` outline, 1.5 px accent when focused, no glow or hover ring. Floating `UiBottomNav` uses radius 14 instead of a pill.
* Colors: coral accent `#FF7E70` (`#FF8F83` in dark), white `onAccent` unless the accent is very light, violet-tinted gray scale, `surfaceMuted` Overlay is now `#6B5FB0` at 10%, `border` is an opaque hairline `#ECEBF2`, new status colors (red `#E5484D`, yellow `#F2B705`, green `#17B26A`, blue `#3B82F6`), and a dark inverse surface `#161616` in light mode.
* Type: Outfit instead of Inter, weights 400 / 500 / 600, body 15/22, screen titles 32/40.
* Tokens: radius 6 / 10 / 14 / 24 / 32 / full, page padding 20, `UiSize` 36 / 44 / 52 with icon 16 / 20 / 22 and label 13 / 15 / 17, softer violet-tinted shadows.
* Components: every button is a pill (40 / 48 / 56) and every icon button a circle; chips 32 / 40 / 48 with a soft fill by default and no check mark; fields 40 / 48 / 56; `UiStepper` is a pill with the body font; outlined `UiCard` is the page color with a hairline border; slider and progress use the accent; list rows 52; dialogs and sheets radius 32.
* New: `UiPromoCard`, `UiPromoBanner`, `UiMediaCard`, `UiOptionTiles`, `UiColors.overlayDark`.
* Gallery (`example/`): Android target, new Showcase (shop, product, cart screens) and Sizes tabs. `make android` installs it on a connected phone.

## 3.0.0

Visual redesign to the Ash Theme Figma file (based on Lucent UI V4). No public API is removed; apps only need `flutter pub upgrade theme`.

* Colors: a nine-step gray scale (white/black backgrounds, `#262626`/`#F2F2F2` surfaces), Primary `#3F88E4` in both modes, and new status colors (green `#0AB35A`, mustard `#D69400`, red `#DA3A3A`, turquoise `#25A7B6`). Chart series use the core palette.
* `surfaceMuted` and `border` are now the translucent Overlay (`#999999` at 20%). `accentSoft` and the `…Soft` status colors are translucent too. Use `surfaceMutedSolid` where an opaque color is needed.
* Type: two weights (400, 600), no letter spacing, Ash Theme ramp (body 14/20, small 12/16, H1 29/36 …).
* Radius 4 / 6 / 8 / 12 / 20 / full; page padding 16; buttons and fields 36 high; three design shadow levels.
* Components restyled to match: solid / dim / ghost buttons, pill controls and chips, Overlay fields with a Primary focus border, 36 px list rows, underline tabs, 2 px slider and progress, Overlay dividers, and gray dialogs.
* New: `UiColors.gray(n)`, `UiColors.surfaceMutedSolid`, `UiColors.overlay`, `UiColors.grayLight` / `grayDark`, `UiShadows.ring(color)`.
* Lazy loading for long lists: `UiScaffold.slivers` (a `CustomScrollView` page body), `UiSliverResponsiveGrid` and `UiSliverListGroup`. They build only the rows near the screen. `UiScaffold(scrollable: true)`, `UiResponsiveGrid` and `UiListGroup` still build everything at once.

## 2.0.0

Breaking: full redesign. All v1 `Ui*` widgets, `UiBrand` presets and domain kits (commerce, fitness, finance, booking, social, auth) are removed.

* One light theme and one dark theme from `UiColors.light()` / `UiColors.dark()`, with an optional custom `accent`. `UiApp` + `UiThemeController` change the mode and accent at runtime.
* New tokens: `UiSpace`, `UiRadius`, `UiMotion` (honors reduced motion), `UiShadows`, `UiSize`, `UiStatus`/`UiTone`, `UiBreakpoint`, `UiGap`.
* 11 groups: foundation, button, input, selection, display, chart, feedback, layout, navigation, media, scroll. See `COMPONENTS.md`.
* New charts group: `UiSparkline`, `UiLineChart`, `UiBarChart`, `UiDonutChart`, `UiHeatmap`, `UiGauge`.
* Dropdowns, chips, cards, images and video moved into `input`, `selection`, `display` and `media`.
* Widget tests for every group, in light and dark mode.
* The example app is now a gallery with one page per group.

## 1.0.0

Layout: generic widgets are grouped by element type in `lib/src/{button, input, dropdown, chip, selection, card, image, video, scroll}`. The old `primitives/` and `controls/` folders are removed. Domain kits stay in their own folders. Public names did not change; import `package:theme/theme.dart` as before.

New widgets:

* Dropdowns: `UiSearchableDropdown` (search sheet, local filter or async `onSearch` with debounce), `UiMultiSelectDropdown` (checkbox sheet, chips in the field, `max`), `UiAutocomplete` (suggestions under a text field).
* Chips: `UiChip` (filled, tonal, outline, soft, and elevated variants; status colors; icon or avatar; count badge; delete button; selected state) and `UiChipGroup` (wrap or horizontal scroll).
* Scroll: `UiPagingController`, `UiInfiniteList`, and `UiInfiniteGrid` (paged loading, prefetch, pull to refresh, first-page skeleton, empty, error, and load-more retry); `UiScrollToTop`; `UiLazyBuilder`.
* Images: `UiLazyImage` (loads near the screen, decodes at display size, shimmer, fade in).
* Video: `UiVideoPlayer` (play and pause, seek with buffer, ±10 s skip and double-tap skip, speed, mute and volume, full screen, loop, autoplay, poster, auto-hiding controls, retry) and `UiVideoThumbnail`.
* Display: `UiMarquee` (scrolling one-line text).

Other changes:

* Breaking: full rewrite. All `Theme*`, `App*`, preset, and style APIs are removed.
* New `UiTheme` builds Material 3 light and dark `ThemeData` from a `UiBrand`.
* 11 brand presets: neutral, commerce, fitness, finance, health, food, travel, social, education, productivity, luxury.
* New `Ui*` component library: primitives, controls, layout, navigation, feedback, display, commerce, fitness, finance, booking, social, and auth.
* Removed dependencies: `file_picker`, `markdown_widget`. `video_player` is still a dependency because `UiVideoPlayer` uses it.

## 0.0.2

* `ThemeSearchableDropdown` now searches inline.
* Input fields use the same border radius as cards.
* iOS deployment target raised to 14.0.

## 0.0.1

* Initial release.
