# Nova design system (theme 4)

The design spec for every app in this workspace. It is based on a Dribbble reference shot ([image](https://cdn.dribbble.com/userupload/45244963/file/3357951d05009e39d0da995e1acd7fcd.png), a shop app called "Nova"; not copied into the repo): soft, round, airy, with one coral accent (the reference used violet; we use coral `#FF7E70`). The code that implements it is in `lib/src/foundation/` (tokens) and the `Ui*` widgets. The gallery app in `example/` shows all of it live: the **Showcase** tab rebuilds the three reference screens from theme widgets, and **Sizes** shows every component at sm / md / lg.

Change a value here first, then in the token file named next to it, then check it in the gallery.

## 1. Principles

- **Round.** Every action is a pill and every icon button a circle. Containers use large radii (24 for cards, 32 for sheets).
- **Soft.** Unselected chips, tiles and steppers sit on a light Overlay fill; selection is solid coral. Text fields are the exception: outline only (see section 6). Other borders are 1 px hairlines on cards and outline buttons.
- **One accent.** Coral `#FF7E70` is the only brand color. Status colors (red, yellow, green, blue) appear only where they mean something (delete, rating, success, info).
- **Airy.** 20 px page margins, 24 px between blocks, tall controls (48 px default).
- **Quiet type.** Outfit, a geometric sans. Headings are semibold, titles and labels medium, body regular.

## 2. Color (`ui_colors.dart`)

### Brand and text

| Token | Light | Dark | Use |
|---|---|---|---|
| `accent` | `#FF7E70` | `#FF8F83` | primary buttons, selected chip / tile / segment, links, slider, progress, focused field outline |
| `onAccent` | `#FFFFFF` | `#FFFFFF` | text and icons on `accent` (white unless the accent luminance is above 0.45) |
| `accentSoft` | accent at 12% (≈ `#FFF2F1`) | accent at 20% | promo card, soft buttons, selected rows |
| `onAccentSoft` | accent at lightness 45% | lightened accent | text on `accentSoft` |
| `text` | `#121216` | `#F7F6FB` | primary text, icons |
| `textMuted` | `#5E5B70` | `#B9B6C8` | descriptions, "Subtotal:" |
| `textSubtle` | `#8C899E` | `#8C899E` | captions, hints, placeholders |
| `textDisabled` | `#B3B0C2` | `#5A5770` | disabled labels ("10" size tile) |

### Surfaces and lines

| Token | Light | Dark | Use |
|---|---|---|---|
| `background` | `#FFFFFF` | `#0E0E12` | page, outlined cards |
| `surface` | `#F7F6FB` | `#18171F` | product hero area, list groups, app bars on tinted pages |
| `surfaceMuted` (Overlay) | `#6B5FB0` at 10% (≈ `#F0EFF7`) | `#C9C2FF` at 10% | chips, size tiles, stepper, secondary buttons (not fields) |
| `surfaceRaised` | `#FFFFFF` | `#201F29` | dialogs, sheets, menus, elevated cards |
| `surfaceInverse` | `#161616` | `#F7F6FB` | promo banner ("Free shipping"), toasts, tooltips |
| `border` | `#ECEBF2` | `#26252F` | card hairlines, dividers, outline buttons |
| `borderStrong` | `#D9D7E3` | `#383646` | field outlines, checkbox and radio outlines |

Gray scale (`gray(1..9)`), violet-tinted: light `#FFFFFF #F7F6FB #ECEBF2 #D9D7E3 #B3B0C2 #8C899E #5E5B70 #2E2C3A #121216`, dark `#0E0E12 #18171F #26252F #383646 #5A5770 #8C899E #B9B6C8 #E4E2EE #F7F6FB`.

### Status

| Status | Solid (light / dark) | Soft fill | On soft | Use |
|---|---|---|---|---|
| danger | `#E5484D` / `#F0656A` | 9% (≈ `#FDF0F1`) | `#D12F35` | "Delete all", trash buttons, errors |
| warning | `#F2B705` / `#F5C330` | 18% | `#8A6500` | rating stars, "23%" badge |
| success | `#17B26A` / `#3CCB8A` | 12% | `#067647` | confirmations |
| info | `#3B82F6` / `#60A0FA` | 10% | `#1D5BC6` | hints |

Chart series: accent, mint `#2BC9A0`, amber `#F5A524`, red `#E5484D`, blue `#3B82F6`, pink `#D65DB1`, lime `#8BC34A`, slate `#5E5B70`. Use them at 12% (see `UiMediaCard.tint`) for the pastel tile backgrounds of the reference (blue hoodie, lime pants, peach jacket).

## 3. Typography (`ui_typography.dart`)

Font: **Outfit** (Google Fonts). No letter spacing.

| Style | Size / line | Weight | Reference use |
|---|---|---|---|
| `displayLarge` | 48 / 56 | 600 | hero numbers |
| `displayMedium` | 40 / 48 | 600 | big totals |
| `displaySmall` | 32 / 40 | 600 | screen title: "NOVA", "CART" |
| `headlineLarge` | 28 / 36 | 600 | H1 |
| `headlineMedium` | 24 / 32 | 600 | product name |
| `headlineSmall` | 22 / 28 | 600 | prices, promo title, dialog title |
| `titleLarge` | 20 / 26 | 500 | app bar title, "Subtotal:" |
| `titleMedium` | 17 / 24 | 500 | cart item name, card title, banner title |
| `titleSmall` | 15 / 20 | 500 | small titles |
| `bodyLarge` | 17 / 24 | 400 | product tile name |
| `bodyMedium` | 15 / 22 | 400 | default text, "Select size" |
| `bodySmall` | 13 / 18 | 400, muted | captions, "Color:", promo message |
| `labelLarge` | 15 / 20 | 500 | buttons, chips, links |
| `labelMedium` | 13 / 16 | 500 | small buttons, badges |
| `labelSmall` | 11 / 14 | 500 | count badges |

## 4. Spacing, radius, elevation (`ui_tokens.dart`)

- **Spacing** (4 pt grid): `xxs` 2, `xs` 4, `sm` 8, `md` 12, `lg` 16, `xl` 24, `xxl` 32, `xxxl` 48. **Page margin** `page` = 20. Between blocks on a screen: 24. Inside cards: 12 to 24.
- **Radius**: `xs` 6 (checkbox, tiny tags), `sm` 10 (tooltips), `md` 14 (fields, size tiles, thumbnails, menus), `lg` 24 (cards, promo card, banner, image tiles, toasts), `xl` 32 (sheets, dialogs, phone-size panels), `full` (buttons, chips, segments, stepper, icon buttons, avatars).
- **Shadows**: used sparingly. `sm` thumbs, `md` floating banner / menus / toasts, `lg` dialogs and sheets. Light-mode shadows are tinted with the ink color `#2E2A4D` at 6–12%.

## 5. Sizes (`UiSize`: sm / md / lg, default md)

| Component | sm | md | lg | Shape | Widget |
|---|---|---|---|---|---|
| Button | 40 | 48 | 56 ("Add to bag", "Checkout") | pill | `UiButton` |
| Button padding (h) | 20 | 28 | 32 | | |
| Button label / icon | 13 / 16 | 15 / 20 | 17 / 22 | | |
| Icon button | 40 | 48 | 56 (back, heart, search) | circle | `UiIconButton` |
| Chip, segment, toggle | 32 | 40 ("Men", "Woman") | 48 | pill | `UiChip`, `UiChoiceChips`, `UiSegmentedControl` |
| Field, select, search (min height) | 40 | 48 | 56 | radius 14, outline only | `UiTextField`, `UiSelect`, `UiSearchField` |
| Quantity stepper | 40 ("1 +") | 48 | 56 | pill | `UiStepper` |
| Option tile | 40 | 48 ("7 8 9") | 56 | radius 14 square | `UiOptionTiles` |
| Color swatch | 26 | 32 | 40 (+2 px ring) | circle | `UiColorPicker` |
| Generic control (`UiSize.height`) | 36 | 44 | 52 | | |

Other fixed sizes: app bar 64, bottom nav 68 (floating bar radius 14, not a pill), list row min 52, slider track 4 / thumb 20, progress bar 6, checkbox 20, sheet handle 40 × 5, promo card min height 160, promo banner min height 72 with a 64 × 56 leading tile and a 40 px round action.

## 6. Components (what each reference element maps to)

| Reference element | Widget | Notes |
|---|---|---|
| "NOVA" / "CART" header | `Text(style: displaySmall)` + `UiIconButton(variant: outline, size: lg)` | |
| Search / back / more / heart circles | `UiIconButton(variant: UiButtonVariant.outline, size: UiSize.lg)` | white circle, hairline border |
| "Step Into Style" card | `UiPromoCard` | `accentSoft` panel, radius 24, headline + muted text + arrow link + picture |
| Category pills | `UiChoiceChips(scrollable: true)` | soft fill, solid violet when selected |
| Product tiles | `UiMediaCard(tint:, badge:)` | 12% tinted box, radius 24, yellow badge pill |
| "Free Shipping" bar | `UiPromoBanner` | inverse surface, radius 24, `md` shadow, round chevron |
| Image pager dots | `UiPageDots` | |
| Stars + "(147 Reviews)" | `UiRating(allowHalf: true)` + `UiButton(variant: link)` | stars in `warning` |
| Color circles | `UiColorPicker(size: lg)` | |
| "Select size" tiles | `UiOptionTiles` | disabled options show faded text |
| "Add to Bag" / "Checkout" | `UiButton(size: UiSize.lg, expand: true)` | |
| "Delete all" | `UiButton(variant: soft, status: danger, size: sm)` | |
| Text field (not in the reference) | `UiTextField`, `UiSearchField`, `UiSelect`, `UiOtpField`, `UiTagInput` | **outline only**: fill is the page color (white / near-black), 1 px `borderStrong` outline, 1.5 px `accent` outline when focused, `danger` when invalid; no tinted fill and no glow |
| Cart item card | `UiCard()` (outlined) | page fill, 1 px `border`, radius 24 |
| "1 +" quantity | `UiStepper(size: UiSize.sm)` | |
| Trash square | `UiIconButton(variant: soft, status: danger, size: sm)` | |
| Divider + "Subtotal" | `UiDivider` + `titleLarge` / `headlineSmall` | |

## 7. States

- **Pressed**: buttons scale to 0.97 and darken 12%; tiles scale to 0.94.
- **Focus** (keyboard): 4 px accent ring at 50% on buttons; fields only switch to the 1.5 px accent outline.
- **Disabled**: solid buttons turn `gray(3)` with `gray(5)` text; tiles, chips and options fade to 45% or `textDisabled`.
- **Selected**: solid `accent` with `onAccent` (chips, tiles, segments), or `accentSoft` with `onAccentSoft` (rows, cards).

## 8. Dark mode

Same layout and sizes. The page goes to `#0E0E12`, surfaces step up (`#18171F`, `#201F29`), the accent lightens to `#FF8F83`, fields fill with `#0E0E12` and keep their outline, the Overlay becomes lavender-white at 10%, and the promo banner turns light (inverse surface). Every component in the gallery must look right in both modes; toggle with the moon icon in its app bar.
