# Components

Every public API of the `theme` package. Import one file:

```dart
import 'package:theme/theme.dart';
```

There is one light theme and one dark theme. You can set a custom accent. All public names start with `Ui`. Each widget reads its colors, type and radius from the theme, and each one works in light and dark mode.

| Group | Source | Main widgets | Reference |
|---|---|---|---|
| App info | `lib/src/about/` | `UiAppearanceSection`, `UiAppearance`, `UiTextSize`, `UiUpdateSection`, `UiUpdater`, `UiRelease`, `UiDeveloperSection`, `UiDeveloper`, `UiUrl` | [about.md](doc/components/about.md) |
| Foundation | `lib/src/foundation/` | `UiApp`, `UiThemeController`, `UiTheme`, `UiColors`, `UiTypography`, `UiSpace`, `UiRadius`, `UiMotion`, `UiSize`, `UiStatus`, `UiBreakpoint`, `UiGap`, `context.*` | [foundation.md](doc/components/foundation.md) |
| Buttons & actions | `lib/src/button/` | `UiButton`, `UiIconButton`, `UiFab`, `UiButtonBar`, `UiSegmentedControl`, `UiToggleButton`, `UiToggleGroup`, `UiCopyButton`, `UiSocialButton`, `UiHoldButton` | [button.md](doc/components/button.md) |
| Text inputs & forms | `lib/src/input/` | `UiTextField`, `UiTextArea`, `UiNumberField`, `UiPasswordField`, `UiSearchField`, `UiSelect`, `UiMultiSelect`, `UiAutocomplete`, `UiDateField`, `UiDateRangeField`, `UiTimeField`, `UiOtpField`, `UiPinPad`, `UiStepper`, `UiTagInput`, `UiFieldLabel`, validators | [input.md](doc/components/input.md) |
| Selection | `lib/src/selection/` | `UiCheckbox`, `UiSwitch`, `UiRadio`, `UiCheckboxTile`, `UiSwitchTile`, `UiRadioTile`, `UiRadioGroup`, `UiCheckboxGroup`, `UiChoice`, `UiChoiceCards`, `UiChip`, `UiChipGroup`, `UiChoiceChips`, `UiFilterChips`, `UiSlider`, `UiRangeSlider`, `UiRating`, `UiColorPicker` | [selection.md](doc/components/selection.md) |
| Data display | `lib/src/display/` | `UiCard`, `UiListTile`, `UiListGroup`, `UiAvatar`, `UiAvatarGroup`, `UiBadge`, `UiCountBadge`, `UiTag`, `UiStatusPill`, `UiIconBox`, `UiStatCard`, `UiTrend`, `UiKeyValue`, `UiTable`, `UiTimeline`, `UiAccordion`, `UiCountdown`, `UiFileTile`, `UiExpandableText`, `UiHighlightText`, `UiCodeBlock`, `UiKbd`, `UiFormat` | [display.md](doc/components/display.md) |
| Charts | `lib/src/chart/` | `UiSparkline`, `UiLineChart`, `UiBarChart`, `UiDonutChart`, `UiHeatmap`, `UiGauge`, `UiChartLegend` | [chart.md](doc/components/chart.md) |
| Feedback & overlays | `lib/src/feedback/` | `UiAlert`, `UiBanner`, `context.showToast`, `UiDialog`, `UiSheet`, `UiMenuButton`, `UiPopover`, `UiTooltip`, `UiProgressBar`, `UiProgressRing`, `UiSpinner`, `UiSkeleton`, `UiShimmer`, `UiEmptyState`, `UiErrorState`, `UiSuccessState`, `UiLoadingOverlay` | [feedback.md](doc/components/feedback.md) |
| Layout | `lib/src/layout/` | `UiScaffold`, `UiContent`, `UiSection`, `UiSectionHeader`, `UiSurface`, `UiDivider`, `UiRow`, `UiColumn`, `UiResponsiveGrid`, `UiResponsiveLayout`, `UiSplitView`, `UiBottomBar` | [layout.md](doc/components/layout.md) |
| Navigation & shell | `lib/src/navigation/` | `UiShell`, `UiNavItem`, `UiBottomNav`, `UiNavRail`, `UiSidebar`, `UiDrawer`, `UiAppBar`, `UiSliverAppBar`, `UiTabs`, `UiTabView`, `UiSteps`, `UiPageDots`, `UiPagination`, `UiBreadcrumbs` | [navigation.md](doc/components/navigation.md) |
| Media | `lib/src/media/` | `UiImage`, `UiCarousel`, `UiCarouselIndicator`, `UiImageViewer`, `UiImageGrid`, `UiVideoPlayer`, `UiVideoThumbnail` | [media.md](doc/components/media.md) |
| Scroll & lazy loading | `lib/src/scroll/` | `UiPagingController`, `UiInfiniteList`, `UiInfiniteGrid`, `UiRefresh`, `UiScrollToTop`, `UiLazyBuilder` | [scroll.md](doc/components/scroll.md) |

## Rules

- Read the group reference before you use or add a widget. Follow the conventions in `CLAUDE.md`.
- Put a new widget in the matching `lib/src/<group>/` folder and export it from the group barrel (`lib/src/<group>/<group>.dart`).
- Inside `lib/`, import the exact file (`package:theme/src/foundation/foundation.dart`), not `package:theme/theme.dart`.
- When you add, rename or change a public widget, update the group reference, this table and the tests.
- Do not hardcode colors. Use `context.colors`, `context.text` and `context.colors.tone(status)`.
