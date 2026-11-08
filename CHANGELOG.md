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
